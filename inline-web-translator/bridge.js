(function () {
  'use strict';

  function findVideo(id) {
    try {
      return document.querySelector('video[data-ppp-cue-id="' + id + '"]');
    } catch (e) {
      return null;
    }
  }

  function playerRoots(video) {
    var roots = [];
    try {
      var root = video.closest && video.closest('.video-js');
      if (root) roots.push(root);
      var tagRoot = video.closest && video.closest('video-js');
      if (tagRoot && roots.indexOf(tagRoot) === -1) roots.push(tagRoot);
      var idRoot = video.closest && video.closest('[id]');
      if (idRoot && roots.indexOf(idRoot) === -1) roots.push(idRoot);
    } catch (e) { /* 忽略 */ }
    roots.push(video);
    return roots;
  }

  function getPlayer(roots) {
    var apis = [];
    if (window.videojs && typeof window.videojs.getPlayer === 'function') apis.push(window.videojs);
    if (window.bc && typeof window.bc.getPlayer === 'function') apis.push(window.bc);
    for (var a = 0; a < apis.length; a++) {
      for (var i = 0; i < roots.length; i++) {
        var root = roots[i];
        var player = null;
        try { player = apis[a].getPlayer(root); } catch (e1) { player = null; }
        if (!player && root.id) {
          try { player = apis[a].getPlayer(root.id); } catch (e2) { player = null; }
        }
        if (!player) {
          try {
            if (root.player_) player = root.player_;
            else if (root.player) player = root.player;
          } catch (e3) { player = null; }
        }
        if (player) return player;
      }
    }
    return null;
  }

  function pushTracks(list, out) {
    if (!list) return;
    for (var i = 0; i < list.length; i++) {
      var track = list[i];
      if (track && out.indexOf(track) === -1) out.push(track);
    }
  }

  function collectTracks(video, player, roots) {
    var tracks = [];
    if (player) {
      try { if (typeof player.textTracks === 'function') pushTracks(player.textTracks(), tracks); } catch (e) { /* 忽略 */ }
      try { if (player.tech_ && typeof player.tech_.textTracks === 'function') pushTracks(player.tech_.textTracks(), tracks); } catch (e) { /* 忽略 */ }
      try {
        if (typeof player.tech === 'function') {
          var tech = player.tech(true);
          if (tech && typeof tech.textTracks === 'function') pushTracks(tech.textTracks(), tracks);
        }
      } catch (e) { /* 忽略 */ }
    }
    try { if (video.textTracks) pushTracks(video.textTracks, tracks); } catch (e) { /* 忽略 */ }
    for (var r = 0; r < roots.length; r++) {
      var els = roots[r] && roots[r].querySelectorAll ? roots[r].querySelectorAll('track') : [];
      for (var i = 0; i < els.length; i++) {
        var track = els[i].track;
        if (track && tracks.indexOf(track) === -1) tracks.push(track);
      }
    }
    return tracks;
  }

  function looksLikeCue(text) {
    var t = String(text || '');
    if (!t.trim() || t.length > 500) return false;
    if (/(byteLength|fastly_token|"uri"\s*:|https?:\/\/)/i.test(t)) return false;
    return true;
  }

  function collectCues(video) {
    var roots = playerRoots(video);
    var player = getPlayer(roots);
    var tracks = collectTracks(video, player, roots);
    var current = Number(video.currentTime) || 0;
    var ahead = current + 120;
    var out = [];
    var debug = {
      videojs: typeof window.videojs,
      bc: typeof window.bc,
      player: !!player,
      roots: roots.map(function (r) { return r.id || r.className || r.tagName; }),
      tracks: tracks.map(function (t) {
        return (t.kind || '') + ':' + (t.mode || '') + ':' + (t.cues ? t.cues.length : -1);
      })
    };
    var picked = null;
    for (var t = 0; t < tracks.length; t++) {
      var track = tracks[t];
      if (!track || track.mode !== 'showing' || !track.cues) continue;
      if (track.kind && track.kind !== 'subtitles' && track.kind !== 'captions') continue;
      picked = track;
      break;
    }
    debug.picked = picked ? ((picked.kind || '') + ':' + (picked.cues ? picked.cues.length : -1)) : null;
    if (picked) {
      var cues = picked.cues;
      for (var i = 0; i < cues.length; i++) {
        var cue = cues[i];
        if (!cue || !looksLikeCue(cue.text)) continue;
        var start = Number(cue.startTime) || 0;
        var end = Number(cue.endTime) || 0;
        if (end < current - 2) continue;
        if (start > ahead) break;
        out.push({ s: start, e: end, t: String(cue.text || '') });
        if (out.length >= 400) break;
      }
    }
    return { cues: out, debug: debug };
  }

  window.addEventListener('message', function (event) {
    if (event.source !== window) return;
    var data = event.data;
    if (!data || data.__ppp !== 'request-cues' || !data.id) return;
    var video = findVideo(data.id);
    if (!video) return;
    var result;
    try { result = collectCues(video); } catch (e) { result = { cues: [], debug: { error: String(e) } }; }
    window.postMessage({
      __ppp: 'cues',
      id: data.id,
      current: Number(video.currentTime) || 0,
      cues: result.cues,
      debug: result.debug
    }, '*');
  });
})();
