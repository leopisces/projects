(function () {
  'use strict';

  function findVideo(id) {
    try {
      return document.querySelector('video[data-ppp-cue-id="' + id + '"]');
    } catch (e) {
      return null;
    }
  }

  function resolveTracks(video) {
    try {
      if (window.videojs && typeof window.videojs.getPlayer === 'function') {
        var player = null;
        try { player = window.videojs.getPlayer(video); } catch (e) { player = null; }
        if (!player) {
          try { player = window.videojs.getPlayer(video.id); } catch (e2) { player = null; }
        }
        if (player && typeof player.textTracks === 'function') return player.textTracks();
      }
    } catch (e) { /* 忽略 */ }
    return video.textTracks || null;
  }

  function collectCues(video) {
    var current = Number(video.currentTime) || 0;
    var ahead = current + 120;
    var tracks = resolveTracks(video);
    var out = [];
    if (!tracks) return out;
    for (var t = 0; t < tracks.length; t++) {
      var track = tracks[t];
      if (!track || track.mode === 'disabled' || !track.cues) continue;
      var cues = track.cues;
      for (var i = 0; i < cues.length; i++) {
        var cue = cues[i];
        if (!cue) continue;
        var start = Number(cue.startTime) || 0;
        var end = Number(cue.endTime) || 0;
        if (end < current - 2) continue;
        if (start > ahead) break;
        out.push({ s: start, e: end, t: String(cue.text || '') });
        if (out.length >= 400) return out;
      }
    }
    return out;
  }

  window.addEventListener('message', function (event) {
    if (event.source !== window) return;
    var data = event.data;
    if (!data || data.__ppp !== 'request-cues' || !data.id) return;
    var video = findVideo(data.id);
    if (!video) return;
    var cues;
    try { cues = collectCues(video); } catch (e) { cues = []; }
    window.postMessage({
      __ppp: 'cues',
      id: data.id,
      current: Number(video.currentTime) || 0,
      cues: cues
    }, '*');
  });
})();
