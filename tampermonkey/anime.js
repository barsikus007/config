// ==UserScript==
// @name         mpd dumper
// @namespace    https://aniboom.one/
// @version      1.0
// @description  mpd dumper from aniboom.one player
// @author       barsikus007
// @match        https://aniboom.one/*
// ==/UserScript==

(function () {
  console.log(`yt-dlp ${JSON.parse(JSON.parse(document.getElementById('video').getAttribute('data-parameters')).dash).src} --referer='' --no-part`)
})()