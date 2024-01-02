// ==UserScript==
// @name         Video link dumper
// @namespace    https://animego.org/
// @version      1.2
// @description  Dumps video links from players on animego.org
// @author       barsikus007
// @match        https://aniboom.one/*
// @match        https://video.sibnet.ru/*
// @match        https://kodik.info/*
// ==/UserScript==

(async function () {
  let aniboomURL
  const videoElement = document.getElementById('video')
  try {
    aniboomURL = JSON.parse(JSON.parse(videoElement?.getAttribute('data-parameters'))?.dash)?.src
  } catch {}
  const sibnetURL = document.querySelector('video')?.src
  const url = aniboomURL || (sibnetURL || undefined)
  if (!url) { console.log('Failed to extract url'); return }
  const mpvBase = `mpv '${url}' --snap-window --no-border`
  console.log('MPV max quality ("_" key for switch quality)')
  console.log(`${mpvBase} --http-header-fields="Referer: https://video.sibnet.ru"`)
  console.log('MPV 1080p')
  console.log(`${mpvBase} --ytdl-raw-options=referer='' --ytdl-format='bestaudio+bestvideo[height<=?1080]'`)
  console.log('MPV 720p')
  console.log(`${mpvBase} --ytdl-raw-options=referer='' --ytdl-format='bestaudio+bestvideo[height<=?720]'`)
  console.log('MPV 480p')
  console.log(`${mpvBase} --ytdl-raw-options=referer='' --ytdl-format='bestaudio+bestvideo[height<=?480]'`)
  console.log('Just download with yt-dlp')
  console.log(`yt-dlp '${url}' --referer='' --no-part`)
})()
