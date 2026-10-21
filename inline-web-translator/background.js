'use strict';

const BLOCK_RULES = [
  {
    id: 1,
    priority: 1,
    action: { type: 'block' },
    condition: {
      urlFilter: '||translate.googleapis.com/translate_a/element.js',
      resourceTypes: ['script', 'sub_frame', 'xmlhttprequest']
    }
  },
  {
    id: 2,
    priority: 1,
    action: { type: 'block' },
    condition: {
      urlFilter: '||translate.google.com/translate_a/element.js',
      resourceTypes: ['script', 'sub_frame', 'xmlhttprequest']
    }
  },
  {
    id: 3,
    priority: 1,
    action: { type: 'block' },
    condition: {
      urlFilter: '||translate-pa.googleapis.com',
      resourceTypes: ['script', 'sub_frame', 'xmlhttprequest']
    }
  }
];

function applyRules(enabled) {
  chrome.declarativeNetRequest.getDynamicRules(function (existing) {
    const options = {
      removeRuleIds: existing.map(function (rule) { return rule.id; })
    };
    if (enabled) options.addRules = BLOCK_RULES;
    chrome.declarativeNetRequest.updateDynamicRules(options, function () {
      if (chrome.runtime.lastError) {
        console.warn('[Inline Web Translator] 拦截规则更新失败:', chrome.runtime.lastError.message);
      }
    });
  });
}

function loadConfigFile() {
  fetch(chrome.runtime.getURL('config.json'))
    .then(function (res) {
      return res.ok ? res.json() : null;
    })
    .then(function (cfg) {
      chrome.storage.local.set({
        fileConfig: {
          deepseekApiKey: cfg && typeof cfg.deepseekApiKey === 'string' ? cfg.deepseekApiKey.trim() : '',
          provider: cfg && typeof cfg.provider === 'string' ? cfg.provider.trim() : '',
          model: cfg && typeof cfg.model === 'string' ? cfg.model.trim() : ''
        }
      });
    })
    .catch(function () {
      chrome.storage.local.set({ fileConfig: { deepseekApiKey: '', provider: '', model: '' } });
    });
}

function init() {
  chrome.storage.sync.get({ blockGoogleWidget: true }, function (res) {
    applyRules(res.blockGoogleWidget !== false);
  });
  loadConfigFile();
}

chrome.runtime.onInstalled.addListener(init);
chrome.runtime.onStartup.addListener(init);

chrome.runtime.onMessage.addListener(function (msg, sender, sendResponse) {
  if (msg && msg.type === 'reloadFileConfig') {
    loadConfigFile();
    sendResponse({ ok: true });
  }
});

chrome.storage.onChanged.addListener(function (changes, area) {
  if (area !== 'sync' || !changes.blockGoogleWidget) return;
  applyRules(changes.blockGoogleWidget.newValue !== false);
});
