(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    var toggle = document.getElementById('enabled');
    var provider = document.getElementById('provider');
    var blockWidget = document.getElementById('blockGoogleWidget');
    var skipChinese = document.getElementById('skipChinesePages');

    chrome.storage.local.get({ fileConfig: null }, function (local) {
      var cfg = local && local.fileConfig;
      var fileProvider = cfg && cfg.provider ? cfg.provider : '';
      chrome.storage.sync.get(['enabled', 'provider', 'blockGoogleWidget', 'skipChinesePages'], function (res) {
        toggle.checked = res.enabled !== false;
        var chosen = res.provider || fileProvider || 'google';
        provider.value = chosen === 'deepseek' || chosen === 'ark' ? chosen : 'google';
        blockWidget.checked = res.blockGoogleWidget !== false;
        skipChinese.checked = res.skipChinesePages !== false;
      });
    });

    toggle.addEventListener('change', function () {
      chrome.storage.sync.set({ enabled: toggle.checked });
    });

    blockWidget.addEventListener('change', function () {
      chrome.storage.sync.set({ blockGoogleWidget: blockWidget.checked });
    });

    skipChinese.addEventListener('change', function () {
      chrome.storage.sync.set({ skipChinesePages: skipChinese.checked });
    });

    provider.addEventListener('change', function () {
      chrome.storage.sync.set({ provider: provider.value });
    });
  });
})();
