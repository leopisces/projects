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
  const DEEPSEEK_MODEL = 'deepseek-flash';
  const DEEPSEEK_PROMPT = 'You are a translation engine. Translate every line of the user message into Simplified Chinese. Preserve the exact number of lines and their order. Output only the translated lines, one per line, without numbering, explanations, or markdown.';
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

  const settings = { enabled: true, provider: 'google', blockGoogleWidget: true, skipChinesePages: true, fileConfig: null };
  const TARGET_LANG = 'zh-CN';
  const memo = new Map();
  const inflight = new Map();
  let warned = false;
  let warnedNoKey = false;
  let lastRequestAt = 0;
  let cooldownUntil = 0;
  let serialChain = Promise.resolve();

  const batchQueue = [];
  let batchTimer = null;

  function sleep(ms) {
    return new Promise(function (resolve) { setTimeout(resolve, ms); });
  }

  function serial(task) {
    const p = serialChain.then(task);
    serialChain = p.catch(function () {});
    return p;
  }

  function backoff(attempt) {
    return Math.min(30000, RETRY_BASE_MS * Math.pow(2, attempt));
  }

  function requestGap() {
    return settings.provider === 'deepseek' ? 150 : MIN_GAP_MS;
  }

  function batchConfig() {
    if (settings.provider === 'deepseek') {
      return { items: 12, chars: 2400, wait: 800 };
    }
    return { items: BATCH_MAX_ITEMS, chars: BATCH_MAX_CHARS, wait: BATCH_WAIT_MS };
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
      const wait = Math.max(0, lastRequestAt + requestGap() - now, cooldownUntil - now);
      return sleep(wait).then(function () {
        if (isStaleItem(item)) {
          const stale = new Error('stale');
          stale.stale = true;
          throw stale;
        }
        lastRequestAt = Date.now();
        const url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=' +
          encodeURIComponent(TARGET_LANG) + '&dt=t&q=' + encodeURIComponent(chunk);
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
    });
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

  function deepseekRequest(lines, attempt, item) {
    return serial(function () {
      const now = Date.now();
      const wait = Math.max(0, lastRequestAt + requestGap() - now, cooldownUntil - now);
      return sleep(wait).then(function () {
        if (isStaleItem(item)) {
          const stale = new Error('stale');
          stale.stale = true;
          throw stale;
        }
        lastRequestAt = Date.now();
        return fetch(DEEPSEEK_URL, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + deepseekKey()
          },
          body: JSON.stringify({
            model: deepseekModel(),
            temperature: 0,
            max_tokens: 8192,
            stream: false,
            thinking: { type: 'disabled' },
            messages: [
              { role: 'system', content: DEEPSEEK_PROMPT },
              { role: 'user', content: lines.join('\n') }
            ]
          })
        });
      }).then(function (res) {
        if (res.ok) return res.json();
        return res.text().then(function (body) {
          const detail = (body || '').slice(0, 300);
          const err = new Error('DeepSeek HTTP ' + res.status + (detail ? ' | ' + detail : ''));
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
        const msg = data && data.choices && data.choices[0] && data.choices[0].message;
        return (msg && msg.content) || '';
      });
    });
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
    console.warn('[Inline Web Translator] DeepSeek 翻译失败，已回退 Google 翻译:', e && e.message ? e.message : e);
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
      if (items.length > 2) {
        const mid = Math.ceil(items.length / 2);
        runDeepSeekBatch(items.slice(0, mid), 0);
        runDeepSeekBatch(items.slice(mid), 0);
        return;
      }
      items.forEach(function (it) { runDeepSeekSingle(it, 0); });
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
    if (settings.provider === 'deepseek') {
      if (deepseekKey()) {
        runDeepSeekBatch(items, attempt);
      } else {
        if (!warnedNoKey) {
          warnedNoKey = true;
          console.warn('[Inline Web Translator] config.json 未配置 deepseekApiKey，已回退到 Google 翻译');
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

  function translateText(text, opts) {
    const fast = !!(opts && opts.fast);
    const key = settings.provider + '|' + text;
    if (memo.has(key)) return Promise.resolve(memo.get(key));
    if (inflight.has(key)) return inflight.get(key);
    const p = new Promise(function (resolve, reject) {
      const item = { text: text, key: key, resolve: resolve, reject: reject, el: (opts && opts.el) || null };
      if (fast) {
        if (item.el && !item.el.isConnected) {
          resolve('');
          return;
        }
        runBatch([item], 0);
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
      if (t && t.trim()) memo.set(key, t);
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

  function deepseekKey() {
    const cfg = settings.fileConfig;
    return cfg && cfg.deepseekApiKey ? String(cfg.deepseekApiKey).trim() : '';
  }

  function deepseekModel() {
    const cfg = settings.fileConfig;
    return cfg && cfg.model === 'deepseek-v4-pro' ? 'deepseek-v4-pro' : DEEPSEEK_MODEL;
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
      if (fast) trans.classList.add('ppp-sub');
      if (!settings.enabled) trans.classList.add('ppp-hidden');
      anchor.parentNode.insertBefore(trans, anchor.nextSibling);
      translateText(sentences[k].text, fast ? { fast: true, el: trans } : null).then(function (t) {
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
      scheduleBlock(block, nodes);
    });
  }

  function processRoot(node) {
    if (!settings.enabled || !node) return;
    if (node.nodeType === 3) {
      const p = node.parentElement;
      if (!p) return;
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
    if (batchTimer) {
      clearTimeout(batchTimer);
      batchTimer = null;
    }
  }

  const pending = [];
  let timer = null;

  function flush() {
    timer = null;
    const batch = pending.splice(0, pending.length);
    for (let i = 0; i < batch.length; i++) processRoot(batch[i]);
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
        pending.push(node);
        const el = node.nodeType === 1 ? node : node.parentElement;
        if (el && isSubtitleElement(el)) hasSubtitle = true;
      }
    }
    if (!pending.length) return;
    if (timer) clearTimeout(timer);
    timer = setTimeout(flush, hasSubtitle ? SUB_DEBOUNCE_MS : DEBOUNCE_MS);
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
    console.info('[Inline Web Translator] 已启动（目标语言：简体中文）');
    loadMemo();

    chrome.storage.local.get({ fileConfig: null }, function (local) {
      settings.fileConfig = (local && local.fileConfig) || null;
      chrome.storage.sync.get({ enabled: true, provider: '', blockGoogleWidget: true, skipChinesePages: true }, function (res) {
        settings.enabled = res.enabled !== false;
        const chosenProvider = res.provider || (settings.fileConfig && settings.fileConfig.provider) || 'google';
        settings.provider = chosenProvider === 'deepseek' ? 'deepseek' : 'google';
        settings.blockGoogleWidget = res.blockGoogleWidget !== false;
        settings.skipChinesePages = res.skipChinesePages !== false;
        cleanupGoogleWidget();
        [600, 1500, 3000].forEach(function (delay) { setTimeout(cleanupGoogleWidget, delay); });
        setTimeout(function () {
          if (!settings.enabled) return;
          if (settings.skipChinesePages && pageIsChinese()) {
            console.info('[Inline Web Translator] 检测到中文页面，已跳过翻译（可在弹窗关闭该限制）');
            return;
          }
          activateCollect();
        }, 300);
      });
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
        settings.provider = changes.provider.newValue === 'deepseek' ? 'deepseek' : 'google';
        warnedNoKey = false;
      }
      if (changes.blockGoogleWidget) {
        settings.blockGoogleWidget = changes.blockGoogleWidget.newValue !== false;
        if (settings.blockGoogleWidget) cleanupGoogleWidget();
      }
      if (changes.skipChinesePages) {
        settings.skipChinesePages = changes.skipChinesePages.newValue !== false;
        if (settings.enabled) {
          if (settings.skipChinesePages && pageIsChinese()) suspendCollect();
          else activateCollect();
        }
      }
      if (!changes.enabled) return;
      settings.enabled = changes.enabled.newValue !== false;
      setAllVisible(settings.enabled);
      if (!settings.enabled) {
        clearPending();
      } else if (settings.skipChinesePages && pageIsChinese()) {
        suspendCollect();
      } else {
        activateCollect();
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();
