(function () {
  'use strict';

  const BLOCK_TAGS = {
    P: 1, DIV: 1, LI: 1, TD: 1, TH: 1,
    H1: 1, H2: 1, H3: 1, H4: 1, H5: 1, H6: 1,
    BLOCKQUOTE: 1, FIGCAPTION: 1, DD: 1, DT: 1,
    SECTION: 1, ARTICLE: 1, MAIN: 1, NAV: 1, HEADER: 1,
    FOOTER: 1, ASIDE: 1, FORM: 1, DIALOG: 1, DETAILS: 1,
    SUMMARY: 1, CAPTION: 1, LEGEND: 1, ADDRESS: 1, FIGURE: 1
  };
  const EXCLUDE_TAGS = {
    SCRIPT: 1, STYLE: 1, NOSCRIPT: 1, CODE: 1, PRE: 1,
    TEXTAREA: 1, INPUT: 1, SELECT: 1, OPTION: 1,
    KBD: 1, SAMP: 1, VAR: 1, IFRAME: 1, CANVAS: 1, SVG: 1
  };
  const MAX_CHUNK = 3000;
  const MIN_GAP_MS = 500;
  const MAX_RETRIES = 4;
  const RETRY_BASE_MS = 2500;
  const BATCH_MAX_ITEMS = 8;
  const BATCH_MAX_CHARS = 1200;
  const BATCH_WAIT_MS = 600;
  const MAX_BLOCK_LEN = 20000;
  const MIN_SENT_LEN = 4;
  const DEBOUNCE_MS = 300;
  const SKIP_ATTR = 'data-ppp-skip';
  const SENT_TAG = 'ppp-sent';
  const TRANS_TAG = 'ppp-trans';
  const CACHE_KEY = 'ppp-trans-cache-v2';
  const DEEPSEEK_URL = 'https://api.deepseek.com/chat/completions';
  const ARK_BASE_URL = 'https://ark.cn-beijing.volces.com/api/coding/v3';
  const DEEPSEEK_MODEL = 'deepseek-flash';
  const DEEPSEEK_PROMPT = 'You are a subtitle translation engine. Translate every line of the user message into Simplified Chinese. Preserve the exact number of lines and their order. Output only the translated lines, one per line, without numbering, explanations, or markdown. Do not answer questions, continue the text, or add any content that is not present in the source.';
  const SENT_RE = /[^.!?。！？]+[.!?。！？]+["'”’)\]]*\s*|[^.!?。！？]+$/g;
  const SUB_DEBOUNCE_MS = 40;
  const SUBTITLE_STRONG = [
    '.ytp-caption-segment',
    '.ytp-caption-window-container',
    '.ytp-caption-window',
    '.caption-window',
    '.vjs-text-track-cue',
    '.vjs-text-track-display',
    '.bpx-player-subtitle-panel-text',
    '.bilibili-player-video-subtitle',
    '.jw-text-track-cue',
    '.plyr__captions',
    '.shaka-text-container',
    '[data-purpose="captions"]'
  ].join(',');
  const SUBTITLE_WEAK = '[class*="subtitle" i],[class*="subtitles" i],[class*="caption" i]';
  const EXCLUDE_UI_SELECTOR = '.vjs-control-bar,.vjs-control-text,.vjs-time-control,.vjs-big-play-button,.vjs-poster,.vjs-loading-spinner,.vjs-error-display,.vjs-modal-dialog,.vjs-menu,.plyr__controls,.jw-controlbar,.ytp-chrome-bottom';
  const PREFETCH_MIN_INTERVAL_MS = 1500;
  const PREFETCH_MAX_TEXTS = 120;
  const PREFETCH_AHEAD_GOOGLE = 40;
  const PREFETCH_AHEAD_DEEPSEEK = 25;

  const settings = { enabled: true, provider: 'google', blockGoogleWidget: true, skipChinesePages: true, hoverReveal: false, fileConfig: null };
  let chinesePageSkip = false;
  const TARGET_LANG = 'zh-CN';
  const memo = new Map();
  const inflight = new Map();
  let warned = false;
  let warnedNoKey = false;
  let lastRequestAt = 0;
  let cooldownUntil = 0;

  const batchQueue = [];
  let batchTimer = null;
  const prefetchQueue = [];
  let prefetchTimer = null;
  let prefetchBatchSize = 0;
  let prefetchAheadSec = 0;
  const STATS_KEY = 'ppp-sub-stats-v1';
  let stats = null;
  let statsStore = {};
  let statsKey = '';
  let statsSaveTimer = null;
  let lastStatText = '';

  function sleep(ms) {
    return new Promise(function (resolve) { setTimeout(resolve, ms); });
  }

  const serialQueue = [];
  let serialBusy = false;

  function drainSerial() {
    if (serialBusy) return;
    const entry = serialQueue.shift();
    if (!entry) return;
    serialBusy = true;
    let p;
    try { p = entry.task(); } catch (e) { p = Promise.reject(e); }
    Promise.resolve(p).then(function (v) {
      serialBusy = false;
      entry.resolve(v);
      drainSerial();
    }, function (e) {
      serialBusy = false;
      entry.reject(e);
      drainSerial();
    });
  }

  function serial(task, priority) {
    return new Promise(function (resolve, reject) {
      const entry = { task: task, resolve: resolve, reject: reject };
      if (priority) serialQueue.unshift(entry);
      else serialQueue.push(entry);
      drainSerial();
    });
  }

  function backoff(attempt) {
    return Math.min(30000, RETRY_BASE_MS * Math.pow(2, attempt));
  }

  function requestGap(priority) {
    if (isLlmProvider()) return priority ? 80 : 150;
    return priority ? 200 : MIN_GAP_MS;
  }

  function isLlmProvider() {
    return settings.provider === 'deepseek' || settings.provider === 'ark';
  }

  function llmConfig() {
    const cfg = settings.fileConfig || {};
    if (settings.provider === 'ark') {
      const base = String(cfg.arkBaseUrl || ARK_BASE_URL).replace(/\/+$/, '');
      return {
        url: base + '/chat/completions',
        key: cfg.arkApiKey ? String(cfg.arkApiKey).trim() : '',
        model: cfg.arkModel ? String(cfg.arkModel).trim() : 'ark-code-latest',
        name: 'Ark'
      };
    }
    return {
      url: DEEPSEEK_URL,
      key: cfg.deepseekApiKey ? String(cfg.deepseekApiKey).trim() : '',
      model: cfg.model === 'deepseek-v4-pro' ? 'deepseek-v4-pro' : DEEPSEEK_MODEL,
      name: 'DeepSeek'
    };
  }

  function looseKey(text) {
    return settings.provider + '|~|' + String(text || '').toLowerCase().replace(/[\s\p{P}\p{S}]+/gu, '');
  }

  function batchConfig() {
    if (isLlmProvider()) {
      return { items: 12, chars: 2400, wait: 800 };
    }
    return { items: BATCH_MAX_ITEMS, chars: BATCH_MAX_CHARS, wait: BATCH_WAIT_MS };
  }

  function prefetchConfig() {
    const items = prefetchBatchSize || (isLlmProvider() ? 12 : 8);
    const chars = isLlmProvider() ? 2400 : 1200;
    return { items: items, chars: chars, wait: 250 };
  }

  function readIntOverride(name, def) {
    try {
      const v = parseInt(localStorage.getItem(name), 10);
      return isFinite(v) && v > 0 ? v : def;
    } catch (e) { return def; }
  }

  function initStats() {
    statsKey = settings.provider + '|b' + prefetchBatchSize + '|a' + prefetchAheadSec;
    try { statsStore = JSON.parse(localStorage.getItem(STATS_KEY) || '{}') || {}; } catch (e) { statsStore = {}; }
    stats = statsStore[statsKey] || { total: 0, hit: 0, exact: 0, loose: 0, miss: 0, missMs: 0, net: 0, since: Date.now() };
    statsStore[statsKey] = stats;
  }

  function saveStats() {
    if (!stats) return;
    statsStore[statsKey] = stats;
    if (statsSaveTimer) return;
    statsSaveTimer = setTimeout(function () {
      statsSaveTimer = null;
      try { localStorage.setItem(STATS_KEY, JSON.stringify(statsStore)); } catch (e) { /* 忽略 */ }
    }, 1000);
  }

  function flushStats() {
    if (!stats) return;
    statsStore[statsKey] = stats;
    try { localStorage.setItem(STATS_KEY, JSON.stringify(statsStore)); } catch (e) { /* 忽略 */ }
  }

  function loadMemo() {
    try {
      const raw = localStorage.getItem(CACHE_KEY);
      if (!raw) return;
      const obj = JSON.parse(raw);
      let count = 0;
      for (const k in obj) {
        if (typeof obj[k] === 'string' && k.length < 2000) {
          memo.set(k, obj[k]);
          count++;
        }
        if (count >= 2000) break;
      }
    } catch (e) { /* 缓存不可用时直接跳过 */ }
  }

  let persistTimer = null;

  function persistMemo() {
    if (persistTimer) return;
    persistTimer = setTimeout(function () {
      persistTimer = null;
      try {
        const out = {};
        let count = 0;
        memo.forEach(function (v, k) {
          if (count >= 1500) return;
          out[k] = v;
          count++;
        });
        localStorage.setItem(CACHE_KEY, JSON.stringify(out));
      } catch (e) { /* 写入失败不影响翻译 */ }
    }, 2000);
  }

  function parseResponse(data) {
    if (!data || !data[0]) return '';
    let out = '';
    for (let i = 0; i < data[0].length; i++) {
      const seg = data[0][i];
      if (seg && seg[0]) out += seg[0];
    }
    return out;
  }

  function fetchChunk(chunk, attempt, item) {
    return serial(function () {
      const now = Date.now();
      const wait = Math.max(0, lastRequestAt + requestGap(item && item.fast) - now, cooldownUntil - now);
      return sleep(wait).then(function () {
        if (isStaleItem(item)) {
          const stale = new Error('stale');
          stale.stale = true;
          throw stale;
        }
        lastRequestAt = Date.now();
        const url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=' +
          encodeURIComponent(TARGET_LANG) + '&dt=t&q=' + encodeURIComponent(chunk);
        if (stats) { stats.net++; saveStats(); }
        return fetch(url);
      }).then(function (res) {
        if (res.status === 429 || res.status === 503) {
          const err = new Error('HTTP ' + res.status);
          err.retryable = true;
          cooldownUntil = Math.max(cooldownUntil, Date.now() + backoff(attempt));
          throw err;
        }
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
      }).then(parseResponse);
    }, item && item.priority);
  }

  function splitIntoChunks(text, max) {
    if (text.length <= max) return [text];
    const sentences = text.match(/[^.!?;:\n]+[.!?;:\n]+|[\s\S]+$/g) || [text];
    const chunks = [];
    let cur = '';
    for (let i = 0; i < sentences.length; i++) {
      const s = sentences[i];
      if (cur && cur.length + s.length > max) {
        chunks.push(cur);
        cur = s;
      } else {
        cur += s;
      }
      while (cur.length > max) {
        chunks.push(cur.slice(0, max));
        cur = cur.slice(max);
      }
    }
    if (cur) chunks.push(cur);
    return chunks;
  }

  function requestSingle(text, attempt, item) {
    const chunks = splitIntoChunks(text, MAX_CHUNK);
    let out = '';
    let index = 0;
    function next() {
      if (index >= chunks.length) return Promise.resolve(out);
      const chunk = chunks[index++];
      return fetchChunk(chunk, attempt, item).then(function (t) {
        out += t;
        return next();
      });
    }
    return next();
  }

  function isStaleItem(item) {
    return !!(item && item.el && !item.el.isConnected);
  }

  function splitLines(content) {
    let text = String(content || '').trim();
    text = text.replace(/^```[a-zA-Z]*\s*/, '').replace(/```$/, '').trim();
    return text.split(/\n+/).map(function (s) {
      return s.replace(/^\s*\d+[.)、]\s*/, '').trim();
    }).filter(Boolean);
  }

  function readDeepSeekStream(res, item) {
    return new Promise(function (resolve, reject) {
      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      let content = '';
      let lastPush = 0;

      function push(force) {
        if (!content) return;
        const now = Date.now();
        if (!force && now - lastPush < 80) return;
        lastPush = now;
        try { item.onPartial(content); } catch (e) { /* 忽略 */ }
      }

      function pump() {
        reader.read().then(function (r) {
          if (r.done) {
            push(true);
            resolve(content);
            return;
          }
          buffer += decoder.decode(r.value, { stream: true });
          let idx;
          while ((idx = buffer.indexOf('\n')) !== -1) {
            const line = buffer.slice(0, idx).trim();
            buffer = buffer.slice(idx + 1);
            if (!line || line.indexOf('data:') !== 0) continue;
            const payload = line.slice(5).trim();
            if (!payload || payload === '[DONE]') continue;
            try {
              const obj = JSON.parse(payload);
              const delta = obj.choices && obj.choices[0] && obj.choices[0].delta;
              if (delta && delta.content) content += delta.content;
            } catch (e) { /* 忽略非 JSON 行 */ }
          }
          push(false);
          pump();
        }, function (err) { reject(err); });
      }

      pump();
    });
  }

  function arkBackgroundRequest(conf, lines, attempt) {
    return new Promise(function (resolve, reject) {
      const body = {
        model: conf.model,
        temperature: 0,
        max_tokens: 8192,
        stream: false,
        messages: [
          { role: 'system', content: DEEPSEEK_PROMPT },
          { role: 'user', content: lines.join('\n') }
        ]
      };
      chrome.runtime.sendMessage({
        type: 'llmRequest',
        url: conf.url,
        apiKey: conf.key,
        body: body
      }, function (resp) {
        if (chrome.runtime.lastError) {
          reject(new Error(chrome.runtime.lastError.message));
          return;
        }
        if (!resp) {
          reject(new Error('后台无响应'));
          return;
        }
        if (!resp.ok) {
          const detail = resp.text ? String(resp.text).slice(0, 300) : (resp.error || '');
          const err = new Error('Ark HTTP ' + resp.status + (detail ? ' | ' + detail : ''));
          if (resp.status === 401 || resp.status === 402 || resp.status === 403) {
            err.fatal = true;
          }
          if (resp.status === 429 || resp.status >= 500) {
            err.retryable = true;
            cooldownUntil = Math.max(cooldownUntil, Date.now() + backoff(attempt));
          }
          reject(err);
          return;
        }
        try {
          const data = JSON.parse(resp.text || '{}');
          const msg = data && data.choices && data.choices[0] && data.choices[0].message;
          resolve((msg && msg.content) || '');
        } catch (e) {
          reject(new Error('Ark 返回解析失败: ' + e.message));
        }
      });
    });
  }

  function deepseekRequest(lines, attempt, item) {
    const streaming = !!(item && item.el && item.onPartial);
    return serial(function () {
      const conf = llmConfig();
      const now = Date.now();
      const wait = Math.max(0, lastRequestAt + requestGap(item && item.fast) - now, cooldownUntil - now);
      return sleep(wait).then(function () {
        if (isStaleItem(item)) {
          const stale = new Error('stale');
          stale.stale = true;
          throw stale;
        }
        lastRequestAt = Date.now();
        if (stats) { stats.net++; saveStats(); }
        if (settings.provider === 'ark') {
          return arkBackgroundRequest(conf, lines, attempt);
        }
        const body = {
          model: conf.model,
          temperature: 0,
          max_tokens: 8192,
          stream: streaming,
          messages: [
            { role: 'system', content: DEEPSEEK_PROMPT },
            { role: 'user', content: lines.join('\n') }
          ]
        };
        if (settings.provider === 'deepseek') body.thinking = { type: 'disabled' };
        return fetch(conf.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + conf.key
          },
          body: JSON.stringify(body)
        });
      }).then(function (res) {
        if (typeof res === 'string') return res;
        if (res.ok) {
          const ctype = res.headers && res.headers.get ? String(res.headers.get('content-type') || '') : '';
          if (streaming && ctype.indexOf('text/event-stream') !== -1 && res.body && res.body.getReader) {
            return readDeepSeekStream(res, item);
          }
          return res.json();
        }
        return res.text().then(function (body) {
          const detail = (body || '').slice(0, 300);
          const err = new Error(conf.name + ' HTTP ' + res.status + (detail ? ' | ' + detail : ''));
          if (res.status === 401 || res.status === 402 || res.status === 403) {
            err.fatal = true;
          }
          if (res.status === 429 || res.status >= 500) {
            err.retryable = true;
            cooldownUntil = Math.max(cooldownUntil, Date.now() + backoff(attempt));
          }
          throw err;
        });
      }).then(function (data) {
        if (typeof data === 'string') return data;
        const msg = data && data.choices && data.choices[0] && data.choices[0].message;
        return (msg && msg.content) || '';
      });
    }, item && item.priority);
  }

  function googleFallback(item) {
    requestSingle(item.text, 0, item).then(function (t) {
      if (!t || !t.trim()) {
        item.reject(new Error('空译文'));
        return;
      }
      item.resolve(t);
    }).catch(function (e) {
      if (e && e.stale) { item.resolve(''); return; }
      item.reject(e);
    });
  }

  function warnDeepSeekFailure(e) {
    if (warned) return;
    warned = true;
    console.warn('[Inline Web Translator] 大模型翻译失败，已回退 Google 翻译:', e && e.message ? e.message : e);
  }

  function runDeepSeekSingle(item, attempt) {
    deepseekRequest([item.text], attempt, item).then(function (content) {
      const lines = splitLines(content);
      if (!lines.length) {
        warnDeepSeekFailure(new Error('DeepSeek 返回空译文'));
        googleFallback(item);
        return;
      }
      item.resolve(lines.join(' '));
    }).catch(function (e) {
      if (e && e.stale) { item.resolve(''); return; }
      if (e && e.retryable && attempt < MAX_RETRIES) {
        setTimeout(function () { runDeepSeekSingle(item, attempt + 1); }, backoff(attempt));
      } else {
        warnDeepSeekFailure(e);
        googleFallback(item);
      }
    });
  }

  function runDeepSeekBatch(items, attempt) {
    if (!items.length) return;
    if (items.length === 1) {
      runDeepSeekSingle(items[0], attempt);
      return;
    }
    const lines = items.map(function (it) { return it.text; });
    deepseekRequest(lines, attempt).then(function (content) {
      const parts = splitLines(content);
      if (parts.length === items.length) {
        items.forEach(function (it, i) { it.resolve(parts[i]); });
        return;
      }
      warnDeepSeekFailure(new Error('DeepSeek 行数不匹配，回退 Google 翻译本批'));
      runGoogleBatch(items, 0);
    }).catch(function (e) {
      if (e && e.retryable && attempt < MAX_RETRIES) {
        setTimeout(function () { runDeepSeekBatch(items, attempt + 1); }, backoff(attempt));
      } else {
        warnDeepSeekFailure(e);
        items.forEach(function (it) { googleFallback(it); });
      }
    });
  }

  function splitBack(text, count) {
    if (!text) return null;
    const parts = text.split(/\n+/).map(function (s) { return s.trim(); }).filter(Boolean);
    if (parts.length === count) return parts;
    return null;
  }

  function runSingle(item, attempt) {
    requestSingle(item.text, attempt, item).then(function (t) {
      if (!t || !t.trim()) {
        item.reject(new Error('empty translation'));
        return;
      }
      item.resolve(t);
    }).catch(function (e) {
      if (e && e.stale) { item.resolve(''); return; }
      if (e && e.retryable && attempt < MAX_RETRIES) {
        setTimeout(function () { runSingle(item, attempt + 1); }, backoff(attempt));
      } else {
        item.reject(e);
      }
    });
  }

  function runBatch(items, attempt) {
    const live = [];
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      if (it.el && !it.el.isConnected) {
        it.resolve('');
        continue;
      }
      live.push(it);
    }
    if (!live.length) return;
    items = live;
    if (!items.length) return;
    if (isLlmProvider()) {
      if (llmConfig().key) {
        runDeepSeekBatch(items, attempt);
      } else {
        if (!warnedNoKey) {
          warnedNoKey = true;
          console.warn('[Inline Web Translator] config.json 未配置 ' + (settings.provider === 'ark' ? 'arkApiKey' : 'deepseekApiKey') + '，已回退到 Google 翻译');
        }
        runGoogleBatch(items, attempt);
      }
      return;
    }
    runGoogleBatch(items, attempt);
  }

  function runGoogleBatch(items, attempt) {
    if (!items.length) return;
    if (items.length === 1) {
      runSingle(items[0], attempt);
      return;
    }
    const joined = items.map(function (it) { return it.text; }).join('\n');
    requestSingle(joined, attempt).then(function (t) {
      const parts = splitBack(t, items.length);
      if (!parts) {
        items.forEach(function (it) { runSingle(it, 0); });
        return;
      }
      items.forEach(function (it, i) { it.resolve(parts[i]); });
    }).catch(function (e) {
      if (e && e.retryable && attempt < MAX_RETRIES) {
        setTimeout(function () { runGoogleBatch(items, attempt + 1); }, backoff(attempt));
      } else {
        items.forEach(function (it) { it.reject(e); });
      }
    });
  }

  function flushBatch() {
    if (batchTimer) {
      clearTimeout(batchTimer);
      batchTimer = null;
    }
    if (!batchQueue.length) return;
    const cfg = batchConfig();
    const items = [];
    let chars = 0;
    while (batchQueue.length && items.length < cfg.items) {
      const next = batchQueue[0];
      if (items.length > 0 && chars + next.text.length > cfg.chars) break;
      batchQueue.shift();
      items.push(next);
      chars += next.text.length;
    }
    runBatch(items, 0);
  }

  function flushPrefetch() {
    if (prefetchTimer) {
      clearTimeout(prefetchTimer);
      prefetchTimer = null;
    }
    if (!prefetchQueue.length) return;
    const cfg = prefetchConfig();
    const items = [];
    let chars = 0;
    while (prefetchQueue.length && items.length < cfg.items) {
      const next = prefetchQueue[0];
      if (items.length > 0 && chars + next.text.length > cfg.chars) break;
      prefetchQueue.shift();
      items.push(next);
      chars += next.text.length;
    }
    runBatch(items, 0);
  }

  function translateText(text, opts) {
    const fast = !!(opts && opts.fast);
    const prefetch = !!(opts && opts.prefetch);
    const key = settings.provider + '|' + text;
    const lkey = looseKey(text);
    let wasMiss = false;
    const missAt = fast ? performance.now() : 0;
    if (fast) {
      if (text !== lastStatText) {
        lastStatText = text;
        if (stats) {
          stats.total++;
          if (memo.has(key)) {
            stats.hit++;
            stats.exact++;
          } else if (memo.has(lkey)) {
            stats.hit++;
            stats.loose++;
          } else {
            stats.miss++;
            wasMiss = true;
          }
          saveStats();
        }
      }
    }
    if (memo.has(key) || memo.has(lkey)) {
      return Promise.resolve(memo.has(key) ? memo.get(key) : memo.get(lkey));
    }
    if (inflight.has(key)) {
      const existing = inflight.get(key);
      if (wasMiss && stats) {
        existing.then(function () {
          stats.missMs += Math.round(performance.now() - missAt);
          saveStats();
        }).catch(function () { /* 忽略 */ });
      }
      return existing;
    }
    const p = new Promise(function (resolve, reject) {
      const item = { text: text, key: key, resolve: resolve, reject: reject, el: (opts && opts.el) || null, priority: fast || prefetch, fast: fast, onPartial: (opts && opts.onPartial) || null };
      if (fast) {
        if (item.el && !item.el.isConnected) {
          resolve('');
          return;
        }
        runBatch([item], 0);
        return;
      }
      if (prefetch) {
        const pcfg = prefetchConfig();
        prefetchQueue.push(item);
        if (prefetchQueue.length >= pcfg.items) flushPrefetch();
        else if (!prefetchTimer) prefetchTimer = setTimeout(flushPrefetch, pcfg.wait);
        return;
      }
      const cfg = batchConfig();
      batchQueue.push(item);
      if (batchQueue.length >= cfg.items) flushBatch();
      else if (!batchTimer) batchTimer = setTimeout(flushBatch, cfg.wait);
    });
    inflight.set(key, p);
    p.then(function (t) {
      inflight.delete(key);
      if (wasMiss && stats) {
        stats.missMs += Math.round(performance.now() - missAt);
        saveStats();
      }
      if (t && t.trim()) {
        memo.set(key, t);
        memo.set(lkey, t);
      }
      persistMemo();
    }).catch(function (e) {
      inflight.delete(key);
      if (!warned) {
        warned = true;
        console.warn('[Inline Web Translator] 翻译失败:', e && e.message ? e.message : e);
      }
    });
    return p;
  }

  function needsTranslation(text) {
    const letters = text.match(/\p{L}/gu);
    if (!letters || letters.length < 3) return false;
    const han = text.match(/[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]/g);
    const hanCount = han ? han.length : 0;
    if (hanCount / letters.length > 0.6) return false;
    const total = text.replace(/\s+/g, '').length;
    if (total === 0) return false;
    return letters.length / total > 0.4;
  }

  function isNoiseText(text) {
    return /(byteLength|fastly_token|"uri"\s*:|https?:\/\/)/i.test(String(text || ''));
  }

  function extractSentences(text) {
    const out = [];
    SENT_RE.lastIndex = 0;
    let m;
    while ((m = SENT_RE.exec(text))) {
      const s = m[0].replace(/\s+/g, ' ').trim();
      if (s.length >= MIN_SENT_LEN && needsTranslation(s)) out.push(s);
    }
    return out;
  }

  function findVideo(block) {
    let cur = block;
    for (let i = 0; i < 12 && cur && cur.nodeType === 1; i++) {
      if (cur.tagName === 'VIDEO') return cur;
      if (cur.querySelector) {
        const video = cur.querySelector('video');
        if (video) return video;
      }
      cur = cur.parentElement;
    }
    return null;
  }

  function initCueBridge() {
    if (initCueBridge.done) return;
    initCueBridge.done = true;
    window.addEventListener('message', function (event) {
      if (event.source !== window) return;
      const data = event.data;
      if (!data || data.__ppp !== 'cues' || !data.id) return;
      const video = document.querySelector('video[data-ppp-cue-id="' + data.id + '"]');
      if (!video) return;
      if (Array.isArray(data.cues)) video.__pppBridgeCues = data.cues;
      prefetchVideoCues(video, true);
    });
  }

  function requestBridgeCues(video) {
    if (!video || !video.getAttribute) return;
    const nowMs = Date.now();
    if (video.__pppBridgeAt && nowMs - video.__pppBridgeAt < 3000) return;
    video.__pppBridgeAt = nowMs;
    let id = video.getAttribute('data-ppp-cue-id');
    if (!id) {
      id = 'ppp' + Math.random().toString(36).slice(2) + nowMs.toString(36);
      video.setAttribute('data-ppp-cue-id', id);
    }
    try {
      window.postMessage({ __ppp: 'request-cues', id: id }, '*');
    } catch (e) { /* 忽略 */ }
  }

  function plainCueText(raw) {
    let text = String(raw || '')
      .replace(/<br\s*\/?>/gi, '\n')
      .replace(/<v(?:\.[^ >]+)?\s+([^>]+)>/gi, '$1 ')
      .replace(/<[^>]*>/g, ' ');
    try {
      const ta = document.createElement('textarea');
      ta.innerHTML = text;
      text = ta.value;
    } catch (e) { /* 忽略 */ }
    return text;
  }

  function cueKey(start, end) {
    return Math.round(Number(start) * 10) + '|' + Math.round(Number(end) * 10);
  }

  function lookupCueTranslation(video, cueText) {
    if (!video) return '';
    const map = video.__pppCueTrans;
    const cues = video.__pppBridgeCues;
    if (!map || !map.size || !cues || !cues.length) return '';
    const now = Number(video.currentTime) || 0;
    const dom = String(cueText || '').replace(/\s+/g, ' ').trim().toLowerCase();
    let best = '';
    let bestScore = 0;
    for (let i = 0; i < cues.length; i++) {
      const cue = cues[i];
      if (!cue) continue;
      const start = Number(cue.s);
      const end = Number(cue.e);
      if (!isFinite(start) || !isFinite(end)) continue;
      if (start > now + 1.5 || end < now - 1.5) continue;
      const rec = map.get(cueKey(start, end));
      if (!rec) continue;
      const translation = typeof rec === 'string' ? rec : rec.t;
      if (!translation) continue;
      const src = rec && rec.src ? rec.src : plainCueText(cue.t).replace(/\s+/g, ' ').trim().toLowerCase();
      let score = 0;
      if (src && dom) {
        if (src === dom) score = 4;
        else if (src.indexOf(dom) !== -1 || dom.indexOf(src) !== -1) score = 3;
        else score = 1;
      } else {
        score = 1;
      }
      if (start <= now + 0.5 && end >= now - 0.5) score += 2;
      if (score >= 3 && score > bestScore) {
        bestScore = score;
        best = translation;
      }
    }
    return best;
  }

  const prefetchRecent = new Map();
  const subOverlays = new Map();

  function findOverlayContainer(video, block) {
    let cur = video || block;
    let fallback = null;
    for (let i = 0; cur && cur.nodeType === 1 && i < 12; i++) {
      if (cur.querySelector && cur.querySelector('video')) fallback = cur;
      try {
        if (fallback && getComputedStyle(cur).position !== 'static') return cur;
      } catch (e) { /* 忽略 */ }
      cur = cur.parentElement;
    }
    const container = fallback || (video && video.parentElement) || document.body;
    try {
      if (container && getComputedStyle(container).position === 'static') container.style.position = 'relative';
    } catch (e) { /* 忽略 */ }
    return container;
  }

  function getSubOverlay(container) {
    let entry = subOverlays.get(container);
    if (entry && entry.el && entry.el.isConnected) return entry;
    const el = document.createElement(TRANS_TAG);
    el.setAttribute('translate', 'no');
    el.classList.add('notranslate', 'ppp-sub-overlay');
    if (!settings.enabled) el.classList.add('ppp-hidden');
    container.appendChild(el);
    if (!container.__pppHoverBound) {
      container.__pppHoverBound = true;
      try {
        container.addEventListener('mouseenter', function () {
          if (!settings.hoverReveal || !settings.enabled) return;
          const entry = subOverlays.get(container);
          if (!entry || !entry.el || !entry.el.textContent.trim()) return;
          const block = entry.block;
          const rect = block && block.getBoundingClientRect ? block.getBoundingClientRect() : container.getBoundingClientRect();
          showHoverTip(entry.el.textContent, rect);
        });
        container.addEventListener('mouseleave', function () { hideHoverTip(); });
      } catch (e) { /* 忽略 */ }
    }
    entry = { el: el, block: null, cueText: '', timer: null };
    subOverlays.set(container, entry);
    return entry;
  }

  function positionSubOverlay(entry) {
    const block = entry.block;
    const el = entry.el;
    if (!block || !block.isConnected || !el || !el.isConnected) return;
    const op = el.offsetParent || el.parentElement;
    if (!op) return;
    const rect = block.getBoundingClientRect();
    const crect = op.getBoundingClientRect();
    if (!rect.width || !rect.height) return;
    let cs = null;
    try { cs = getComputedStyle(block); } catch (e) { /* 忽略 */ }
    if (cs) {
      el.style.fontSize = cs.fontSize;
      el.style.fontFamily = cs.fontFamily;
      el.style.fontWeight = cs.fontWeight;
    }
    el.style.left = (rect.left - crect.left + rect.width / 2) + 'px';
    el.style.maxWidth = Math.max(120, Math.round(rect.width)) + 'px';
    const h = el.offsetHeight || 0;
    let top = rect.bottom - crect.top + 4;
    if (top + h > crect.height - 4) top = rect.top - crect.top - h - 4;
    if (top < 4) top = 4;
    el.style.top = Math.round(top) + 'px';
  }

  function setSubOverlayText(entry, text) {
    if (!entry || !entry.el || !entry.el.isConnected) return;
    if (entry.el.textContent !== text) entry.el.textContent = text;
    positionSubOverlay(entry);
  }

  function ensureSubOverlayWatcher(entry) {
    if (!entry || entry.timer) return;
    entry.timer = setInterval(function () {
      if (!entry.el || !entry.el.isConnected || !entry.block || !entry.block.isConnected) {
        if (entry.el) entry.el.textContent = '';
        clearInterval(entry.timer);
        entry.timer = null;
        return;
      }
      const current = (entry.block.textContent || '').replace(/\s+/g, ' ').trim();
      if (!current) {
        if (entry.el.textContent) entry.el.textContent = '';
        clearInterval(entry.timer);
        entry.timer = null;
      }
    }, 500);
  }

  function renderSubtitleOverlay(block, cueText) {
    const video = findVideo(block);
    const container = findOverlayContainer(video, block);
    const entry = getSubOverlay(container);
    entry.block = block;
    entry.cueText = cueText;
    const timed = video ? lookupCueTranslation(video, cueText) : '';
    if (timed) memo.set(settings.provider + '|' + cueText, timed);
    translateText(cueText, {
      fast: true,
      el: video || null,
      onPartial: function (partial) {
        if (partial && entry.cueText === cueText) setSubOverlayText(entry, partial);
      }
    }).then(function (t) {
      if (t && t.trim() && entry.cueText === cueText) {
        setSubOverlayText(entry, t);
      }
    }).catch(function () { /* 忽略 */ });
    ensureSubOverlayWatcher(entry);
    if (video) prefetchVideoCues(video);
  }

  function prefetchVideoCues(video, force) {
    if (!video) return;
    if (!video.__pppPrefetchBound) {
      video.__pppPrefetchBound = true;
      try {
        video.addEventListener('timeupdate', function () { prefetchVideoCues(video); });
        video.addEventListener('loadedmetadata', function () { prefetchVideoCues(video); });
      } catch (e) { /* 忽略 */ }
    }
    initCueBridge();
    const nowMs = Date.now();
    if (!force && video.__pppPrefetchAt && nowMs - video.__pppPrefetchAt < PREFETCH_MIN_INTERVAL_MS) return;
    video.__pppPrefetchAt = nowMs;
    const now = Number(video.currentTime) || 0;
    const ahead = now + (prefetchAheadSec || (isLlmProvider() ? PREFETCH_AHEAD_DEEPSEEK : PREFETCH_AHEAD_GOOGLE));
    let budget = PREFETCH_MAX_TEXTS;

    function handleCue(start, end, raw) {
      if (budget <= 0) return;
      if (!isFinite(start) || !isFinite(end)) return;
      if (end < now - 2) return;
      if (start <= now + 0.25 && end > now) return;
      if (start > ahead) return;
      const plain = plainCueText(raw).replace(/\s+/g, ' ').trim();
      if (!plain || plain.length > 500 || !needsTranslation(plain) || isNoiseText(plain)) return;
      if (!video.__pppCueTrans) video.__pppCueTrans = new Map();
      const ck = cueKey(start, end);
      const key = settings.provider + '|' + plain;
      const nowMs = Date.now();
      const lastAt = prefetchRecent.get(key);
      if (lastAt && nowMs - lastAt < 120000) return;
      prefetchRecent.set(key, nowMs);
      if (prefetchRecent.size > 2000) {
        prefetchRecent.forEach(function (v, k) {
          if (nowMs - v > 180000) prefetchRecent.delete(k);
        });
      }
      const cached = memo.get(key) || memo.get(looseKey(plain));
      const src = plain.toLowerCase();
      if (cached) {
        video.__pppCueTrans.set(ck, { t: cached, src: src });
        return;
      }
      if (inflight.has(key)) {
        inflight.get(key).then(function (t) {
          if (t) video.__pppCueTrans.set(ck, { t: t, src: src });
        }).catch(function () { /* 忽略 */ });
        return;
      }
      translateText(plain, { prefetch: true }).then(function (t) {
        if (t) video.__pppCueTrans.set(ck, { t: t, src: src });
      }).catch(function () { /* 忽略 */ });
      budget--;
    }

    let found = false;
    const bridgeCues = video.__pppBridgeCues;
    if (bridgeCues && bridgeCues.length) {
      found = true;
      requestBridgeCues(video);
      for (let i = 0; i < bridgeCues.length && budget > 0; i++) {
        const cue = bridgeCues[i];
        if (!cue) continue;
        handleCue(Number(cue.s), Number(cue.e), cue.t);
      }
    }
    if (!found) {
      const tracks = video.textTracks;
      if (tracks) {
        for (let t = 0; t < tracks.length && budget > 0; t++) {
          const track = tracks[t];
          if (!track || track.mode !== 'showing' || !track.cues) continue;
          if (track.kind && track.kind !== 'subtitles' && track.kind !== 'captions') continue;
          found = true;
          for (let i = 0; i < track.cues.length && budget > 0; i++) {
            const cue = track.cues[i];
            if (!cue) continue;
            handleCue(Number(cue.startTime), Number(cue.endTime), cue.text);
          }
          break;
        }
      }
    }
    if (!found) {
      const els = [];
      try {
        const root = video.closest ? video.closest('.video-js') : null;
        if (root && root.querySelectorAll) {
          const list = root.querySelectorAll('track');
          for (let i = 0; i < list.length; i++) els.push(list[i]);
        }
      } catch (e) { /* 忽略 */ }
      if (video.querySelectorAll) {
        const list = video.querySelectorAll('track');
        for (let i = 0; i < list.length; i++) {
          if (els.indexOf(list[i]) === -1) els.push(list[i]);
        }
      }
      for (let i = 0; i < els.length && budget > 0; i++) {
        const track = els[i].track;
        if (!track || !track.cues) continue;
        if (track.mode && track.mode !== 'showing') continue;
        if (track.kind && track.kind !== 'subtitles' && track.kind !== 'captions') continue;
        found = true;
        for (let k = 0; k < track.cues.length && budget > 0; k++) {
          const cue = track.cues[k];
          if (!cue) continue;
          handleCue(Number(cue.startTime), Number(cue.endTime), cue.text);
        }
        break;
      }
    }
    if (!found) requestBridgeCues(video);
  }

  function prefetchAllVideos() {
    try {
      const videos = document.querySelectorAll('video');
      for (let i = 0; i < videos.length; i++) prefetchVideoCues(videos[i]);
    } catch (e) { /* 忽略 */ }
  }

  function findBlockAncestor(el) {
    let cur = el;
    while (cur && cur.nodeType === 1) {
      if (BLOCK_TAGS[cur.tagName]) return cur;
      cur = cur.parentElement;
    }
    return null;
  }

  function isSubtitleElement(el) {
    if (!el || el.nodeType !== 1 || !el.closest) return false;
    if (el.closest(SUBTITLE_STRONG)) return true;
    const weak = el.closest(SUBTITLE_WEAK);
    if (!weak) return false;
    let cur = weak;
    for (let i = 0; i < 5 && cur && cur.nodeType === 1; i++) {
      if (cur.tagName === 'VIDEO') return true;
      try {
        if (cur.querySelector && cur.querySelector('video')) return true;
      } catch (e) { /* 忽略 */ }
      cur = cur.parentElement;
    }
    return false;
  }

  function isOwnNode(el) {
    if (!el || el.nodeType !== 1) return false;
    return el.tagName === SENT_TAG.toUpperCase() || el.tagName === TRANS_TAG.toUpperCase();
  }

  function processBlock(block, nodes, fast) {
    if (!settings.enabled) return;

    let full = '';
    const map = [];
    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if (!node.isConnected || !node.nodeValue) continue;
      const value = node.nodeValue;
      if (full && !/\s$/.test(full) && !/^\s/.test(value)) full += ' ';
      map.push({ node: node, start: full.length, end: full.length + value.length });
      full += value;
    }
    if (!full.trim()) return;

    const sentences = [];
    SENT_RE.lastIndex = 0;
    let m;
    while ((m = SENT_RE.exec(full))) {
      const raw = m[0];
      if (!raw || !raw.trim()) continue;
      const text = raw.replace(/\s+/g, ' ').trim();
      if (text.length < MIN_SENT_LEN || !needsTranslation(text)) continue;
      sentences.push({ start: m.index, end: m.index + raw.length, text: text });
    }
    if (!sentences.length) return;

    if (fast) {
      const cueText = full.replace(/\s+/g, ' ').trim();
      if (cueText && needsTranslation(cueText) && !isNoiseText(cueText)) renderSubtitleOverlay(block, cueText);
      return;
    }

    const spansPerSentence = sentences.map(function () { return []; });

    for (let i = 0; i < map.length; i++) {
      const item = map[i];
      const node = item.node;
      const value = node.nodeValue;
      let cursor = item.start;
      const frag = document.createDocumentFragment();
      for (let k = 0; k < sentences.length; k++) {
        const s = sentences[k];
        const a = Math.max(item.start, s.start);
        const b = Math.min(item.end, s.end);
        if (b <= a) continue;
        if (a > cursor) {
          frag.appendChild(document.createTextNode(value.slice(cursor - item.start, a - item.start)));
        }
        const piece = value.slice(a - item.start, b - item.start);
        const el = document.createElement(SENT_TAG);
        el.setAttribute('translate', 'no');
        el.classList.add('notranslate');
        el.textContent = piece;
        frag.appendChild(el);
        spansPerSentence[k].push(el);
        cursor = b;
      }
      if (cursor < item.end) {
        frag.appendChild(document.createTextNode(value.slice(cursor - item.start)));
      }
      if (node.parentNode) node.parentNode.replaceChild(frag, node);
    }

    for (let k = 0; k < sentences.length; k++) {
      const spans = spansPerSentence[k];
      if (!spans.length) continue;
      const anchor = spans[spans.length - 1];
      if (!anchor.parentNode) continue;
      let nxt = anchor.nextSibling;
      while (nxt && nxt.nodeType === 1 && nxt.tagName === TRANS_TAG.toUpperCase()) {
        const rm = nxt;
        nxt = nxt.nextSibling;
        if (rm.parentNode) rm.parentNode.removeChild(rm);
      }
      const trans = document.createElement(TRANS_TAG);
      trans.setAttribute('translate', 'no');
      trans.classList.add('notranslate');
      if (!settings.enabled) trans.classList.add('ppp-hidden');
      anchor.parentNode.insertBefore(trans, anchor.nextSibling);
      translateText(sentences[k].text).then(function (t) {
        if (!t || !t.trim()) {
          if (trans.parentNode) trans.remove();
          return;
        }
        trans.textContent = t;
      }).catch(function () {
        if (trans.parentNode) trans.remove();
      });
    }
  }

  const pendingBlocks = new Map();

  const io = ('IntersectionObserver' in window) ? new IntersectionObserver(function (entries) {
    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      if (!entry.isIntersecting) continue;
      const block = entry.target;
      io.unobserve(block);
      const nodes = pendingBlocks.get(block);
      pendingBlocks.delete(block);
      if (nodes && settings.enabled) processBlock(block, nodes);
    }
  }, { rootMargin: '400px 0px' }) : null;

  function scheduleBlock(block, nodes) {
    if (pendingBlocks.has(block)) return;
    pendingBlocks.set(block, nodes);
    if (io) io.observe(block);
    else processBlock(block, nodes);
  }

  function collect(root) {
    if (!root || !settings.enabled) return;
    const map = new Map();
    let walker;
    try {
      walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
        acceptNode: function (node) {
          if (!node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
          const p = node.parentElement;
          if (!p) return NodeFilter.FILTER_REJECT;
          if (EXCLUDE_TAGS[p.tagName]) return NodeFilter.FILTER_REJECT;
          if (p.closest(EXCLUDE_UI_SELECTOR)) return NodeFilter.FILTER_REJECT;
          if (p.closest(SENT_TAG + ',' + TRANS_TAG)) return NodeFilter.FILTER_REJECT;
          return NodeFilter.FILTER_ACCEPT;
        }
      });
    } catch (e) {
      return;
    }
    let n;
    while ((n = walker.nextNode())) {
      const block = findBlockAncestor(n.parentElement);
      if (!block) continue;
      let arr = map.get(block);
      if (!arr) {
        arr = [];
        map.set(block, arr);
      }
      arr.push(n);
    }
    map.forEach(function (nodes, block) {
      if (block.hasAttribute(SKIP_ATTR)) return;
      let len = 0;
      for (let i = 0; i < nodes.length; i++) len += nodes[i].nodeValue.length;
      if (len > MAX_BLOCK_LEN) {
        block.setAttribute(SKIP_ATTR, '1');
        return;
      }
      if (isSubtitleElement(block)) {
        processBlock(block, nodes, true);
        return;
      }
      if (chinesePageSkip) return;
      scheduleBlock(block, nodes);
    });
  }

  function processRoot(node) {
    if (!settings.enabled || !node) return;
    if (node.nodeType === 3) {
      const p = node.parentElement;
      if (!p) return;
      if (p.closest(EXCLUDE_UI_SELECTOR)) return;
      if (p.closest(SENT_TAG + ',' + TRANS_TAG)) return;
      const block = findBlockAncestor(p);
      if (block && !block.hasAttribute(SKIP_ATTR)) collect(block);
      return;
    }
    if (node.nodeType !== 1 && node.nodeType !== 9 && node.nodeType !== 11) return;
    if (isOwnNode(node)) return;
    if (node.nodeType === 1 && node.closest && node.closest(SENT_TAG + ',' + TRANS_TAG)) return;
    collect(node);
  }

  function setAllVisible(visible) {
    const list = document.querySelectorAll(TRANS_TAG);
    for (let i = 0; i < list.length; i++) {
      if (visible) list[i].classList.remove('ppp-hidden');
      else list[i].classList.add('ppp-hidden');
    }
  }

  function clearPending() {
    if (io) {
      pendingBlocks.forEach(function (v, block) { io.unobserve(block); });
    }
    pendingBlocks.clear();
    batchQueue.length = 0;
    prefetchQueue.length = 0;
    if (batchTimer) {
      clearTimeout(batchTimer);
      batchTimer = null;
    }
    if (prefetchTimer) {
      clearTimeout(prefetchTimer);
      prefetchTimer = null;
    }
    if (timer) {
      clearTimeout(timer);
      timer = null;
    }
    timerSub = false;
  }

  const pending = [];
  let timer = null;
  let timerSub = false;

  function flush() {
    timer = null;
    timerSub = false;
    const batch = pending.splice(0, pending.length);
    for (let i = 0; i < batch.length; i++) processRoot(batch[i]);
  }

  function scheduleFlush(subtitle) {
    if (subtitle) {
      if (!timer) {
        timer = setTimeout(flush, SUB_DEBOUNCE_MS);
        timerSub = true;
      } else if (!timerSub) {
        clearTimeout(timer);
        timer = setTimeout(flush, SUB_DEBOUNCE_MS);
        timerSub = true;
      }
      return;
    }
    if (!timer) {
      timer = setTimeout(flush, DEBOUNCE_MS);
      timerSub = false;
    }
  }

  const observer = new MutationObserver(function (mutations) {
    if (!settings.enabled) return;
    let hasSubtitle = false;
    for (let i = 0; i < mutations.length; i++) {
      const m = mutations[i];
      if (m.type === 'characterData') {
        const target = m.target;
        const parent = target && target.parentElement;
        if (!parent || !target.nodeValue || !target.nodeValue.trim()) continue;
        if (parent.closest(SENT_TAG + ',' + TRANS_TAG)) continue;
        if (parent.closest(EXCLUDE_UI_SELECTOR)) continue;
        if (isSubtitleElement(parent)) {
          pending.push(target);
          hasSubtitle = true;
        }
        continue;
      }
      const added = m.addedNodes;
      for (let j = 0; j < added.length; j++) {
        const node = added[j];
        if (node.nodeType === 1) {
          if (isOwnNode(node)) continue;
          if (node.closest && node.closest(SENT_TAG + ',' + TRANS_TAG)) continue;
        }
        const el = node.nodeType === 1 ? node : node.parentElement;
        if (el && el.closest && el.closest(EXCLUDE_UI_SELECTOR)) continue;
        pending.push(node);
        if (el && isSubtitleElement(el)) hasSubtitle = true;
      }
    }
    if (!pending.length) return;
    scheduleFlush(hasSubtitle);
  });

  function cleanupGoogleWidget() {
    if (settings.blockGoogleWidget === false) return;
    try {
      const nodes = document.querySelectorAll('#google_translate_element, iframe.goog-te-banner-frame, .goog-te-banner-frame, .goog-te-spinner-pos');
      for (let i = 0; i < nodes.length; i++) {
        const el = nodes[i];
        if (el.parentNode) el.parentNode.removeChild(el);
      }
      if (document.body && document.body.style.top && document.body.style.top !== '0px') {
        document.body.style.top = '0px';
        if (document.body.style.position === 'relative') document.body.style.position = '';
      }
    } catch (e) { /* 清理失败不影响翻译 */ }
  }

  function applyHoverMode() {
    try {
      document.documentElement.classList.toggle('ppp-hover-mode', !!settings.hoverReveal);
    } catch (e) { /* 忽略 */ }
  }

  function transForSent(sent) {
    let node = sent;
    while (node && node.nextSibling) {
      node = node.nextSibling;
      if (node.nodeType === 1 && node.tagName === TRANS_TAG.toUpperCase()) return node;
    }
    return null;
  }

  let hoverTip = null;

  function getHoverTip() {
    if (hoverTip && hoverTip.isConnected) return hoverTip;
    hoverTip = document.createElement(TRANS_TAG);
    hoverTip.setAttribute('translate', 'no');
    hoverTip.classList.add('notranslate', 'ppp-hover-tip');
    document.body.appendChild(hoverTip);
    return hoverTip;
  }

  function showHoverTip(text, rect) {
    if (!settings.hoverReveal || !settings.enabled || !text || !rect) return;
    const tip = getHoverTip();
    tip.textContent = text;
    const margin = 6;
    const vw = window.innerWidth || document.documentElement.clientWidth || 0;
    let left = rect.left + rect.width / 2;
    let top = rect.top - tip.offsetHeight - margin;
    if (top < 4) top = 4;
    const half = tip.offsetWidth / 2;
    if (left - half < 4) left = half + 4;
    if (left + half > vw - 4) left = vw - half - 4;
    tip.style.left = Math.round(left) + 'px';
    tip.style.top = Math.round(top) + 'px';
  }

  function hideHoverTip() {
    if (hoverTip) hoverTip.textContent = '';
  }

  function setupHoverReveal() {
    if (setupHoverReveal.done) return;
    setupHoverReveal.done = true;
    document.addEventListener('mouseover', function (event) {
      if (!settings.hoverReveal || !settings.enabled) return;
      const target = event.target;
      if (!target || !target.closest) return;
      const sent = target.closest(SENT_TAG);
      if (!sent) return;
      const trans = transForSent(sent);
      if (trans && trans.textContent.trim()) showHoverTip(trans.textContent, sent.getBoundingClientRect());
    });
    document.addEventListener('mouseout', function (event) {
      if (!settings.hoverReveal) return;
      const target = event.target;
      if (!target || !target.closest) return;
      const sent = target.closest(SENT_TAG);
      if (!sent) return;
      const related = event.relatedTarget;
      if (related && related.closest && related.closest(SENT_TAG) === sent) return;
      hideHoverTip();
    });
    window.addEventListener('scroll', hideHoverTip, true);
    window.addEventListener('resize', hideHoverTip);
  }

  function pageIsChinese() {
    try {
      const lang = (document.documentElement.getAttribute('lang') || '').toLowerCase();
      if (lang.indexOf('zh') === 0) return true;
    } catch (e) { /* 忽略 */ }
    try {
      const sample = ((document.body && document.body.innerText) || '').slice(0, 4000);
      if (!sample) return false;
      const letters = sample.match(/\p{L}/gu);
      if (!letters || letters.length < 20) return false;
      const han = sample.match(/[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]/g);
      const hanCount = han ? han.length : 0;
      return hanCount / letters.length > 0.3;
    } catch (e) {
      return false;
    }
  }

  function activateCollect() {
    try { observer.observe(document.body, { childList: true, subtree: true, characterData: true }); } catch (e) { /* 忽略 */ }
    collect(document.body);
  }

  function suspendCollect() {
    try { observer.disconnect(); } catch (e) { /* 忽略 */ }
    setAllVisible(false);
  }

  function start() {
    if (!document.body) return;
    loadMemo();

    chrome.storage.local.get({ fileConfig: null }, function (local) {
      settings.fileConfig = (local && local.fileConfig) || null;
      chrome.storage.sync.get({ enabled: true, provider: '', blockGoogleWidget: true, skipChinesePages: true, hoverReveal: false }, function (res) {
        settings.enabled = res.enabled !== false;
        const chosenProvider = res.provider || (settings.fileConfig && settings.fileConfig.provider) || 'google';
        settings.provider = chosenProvider === 'deepseek' || chosenProvider === 'ark' ? chosenProvider : 'google';
        settings.blockGoogleWidget = res.blockGoogleWidget !== false;
        settings.skipChinesePages = res.skipChinesePages !== false;
        settings.hoverReveal = res.hoverReveal === true;
        chinesePageSkip = settings.skipChinesePages && pageIsChinese();
        applyHoverMode();
        setupHoverReveal();
        prefetchBatchSize = readIntOverride('pppSubBatch', isLlmProvider() ? 12 : 8);
        prefetchAheadSec = readIntOverride('pppSubAhead', isLlmProvider() ? PREFETCH_AHEAD_DEEPSEEK : PREFETCH_AHEAD_GOOGLE);
        initStats();
        cleanupGoogleWidget();
        [600, 1500, 3000].forEach(function (delay) { setTimeout(cleanupGoogleWidget, delay); });
        prefetchAllVideos();
        setTimeout(function () {
          if (!settings.enabled) return;
          activateCollect();
          prefetchAllVideos();
        }, 300);
      });
    });

    window.addEventListener('pagehide', function () {
      flushStats();
    });

    chrome.storage.onChanged.addListener(function (changes, area) {
      if (area === 'local') {
        if (changes.fileConfig) {
          settings.fileConfig = changes.fileConfig.newValue || null;
          warnedNoKey = false;
        }
        return;
      }
      if (area !== 'sync') return;
      if (changes.provider) {
        const nextProvider = changes.provider.newValue;
        settings.provider = nextProvider === 'deepseek' || nextProvider === 'ark' ? nextProvider : 'google';
        prefetchBatchSize = readIntOverride('pppSubBatch', isLlmProvider() ? 12 : 8);
        prefetchAheadSec = readIntOverride('pppSubAhead', isLlmProvider() ? PREFETCH_AHEAD_DEEPSEEK : PREFETCH_AHEAD_GOOGLE);
        initStats();
        warnedNoKey = false;
      }
      if (changes.blockGoogleWidget) {
        settings.blockGoogleWidget = changes.blockGoogleWidget.newValue !== false;
        if (settings.blockGoogleWidget) cleanupGoogleWidget();
      }
      if (changes.skipChinesePages) {
        settings.skipChinesePages = changes.skipChinesePages.newValue !== false;
        chinesePageSkip = settings.skipChinesePages && pageIsChinese();
        if (settings.enabled) {
          activateCollect();
          prefetchAllVideos();
        }
      }
      if (changes.hoverReveal) {
        settings.hoverReveal = changes.hoverReveal.newValue === true;
        applyHoverMode();
      }
      if (!changes.enabled) return;
      settings.enabled = changes.enabled.newValue !== false;
      setAllVisible(settings.enabled);
      if (!settings.enabled) {
        clearPending();
      } else {
        chinesePageSkip = settings.skipChinesePages && pageIsChinese();
        activateCollect();
        prefetchAllVideos();
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();
