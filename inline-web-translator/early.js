(function () {
  'use strict';

  var enabled = true;
  var observer = null;
  var killTimer = null;

  function killWidget() {
    if (!enabled) return;
    try {
      var nodes = document.querySelectorAll(
        '#google_translate_element, iframe.goog-te-banner-frame, .goog-te-banner-frame, .goog-te-spinner-pos'
      );
      for (var i = nodes.length - 1; i >= 0; i--) {
        if (nodes[i].parentNode) nodes[i].parentNode.removeChild(nodes[i]);
      }
      if (document.body && document.body.style.top && document.body.style.top !== '0px') {
        document.body.style.top = '0px';
        if (document.body.style.position === 'relative') document.body.style.position = '';
      }
    } catch (e) { /* 清理失败不影响页面 */ }
  }

  function scheduleKill() {
    if (killTimer) return;
    killTimer = setTimeout(function () {
      killTimer = null;
      killWidget();
    }, 300);
  }

  function clearCookie() {
    try {
      document.cookie = 'googtrans=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
      document.cookie = 'googtrans=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; domain=' + location.hostname;
    } catch (e) { /* 忽略 Cookie 清理失败 */ }
  }

  function apply(nextEnabled) {
    enabled = nextEnabled;
    if (!enabled) {
      if (observer) {
        observer.disconnect();
        observer = null;
      }
      return;
    }
    try {
      document.documentElement.setAttribute('translate', 'no');
      document.documentElement.classList.add('notranslate');
    } catch (e) { /* 忽略 */ }
    clearCookie();
    killWidget();
    if (!observer && document.documentElement) {
      observer = new MutationObserver(scheduleKill);
      observer.observe(document.documentElement, { childList: true, subtree: true });
    }
  }

  chrome.storage.sync.get({ blockGoogleWidget: true }, function (res) {
    apply(res.blockGoogleWidget !== false);
  });

  chrome.storage.onChanged.addListener(function (changes, area) {
    if (area !== 'sync' || !changes.blockGoogleWidget) return;
    var next = changes.blockGoogleWidget.newValue !== false;
    if (!next) {
      try {
        document.documentElement.removeAttribute('translate');
        document.documentElement.classList.remove('notranslate');
      } catch (e) { /* 忽略 */ }
    }
    apply(next);
  });
})();
