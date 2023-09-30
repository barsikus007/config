// ==UserScript==
// @name         mpd dumper
// @namespace    https://aniboom.one/
// @version      1.1
// @description  mpd dumper from aniboom.one player
// @author       barsikus007
// @match        https://aniboom.one/*
// ==/UserScript==

(function () {
  const url = JSON.parse(JSON.parse(document.getElementById('video')?.getAttribute('data-parameters'))?.dash)?.src
  if (!url) return
  console.log(`mpv ${url} --snap-window --no-border --ytdl-raw-options=referer='' --ytdl-format='bestaudio+bestvideo[height<=?1080]'`)
  console.log(`yt-dlp ${url} --referer='' --no-part`)
})()
