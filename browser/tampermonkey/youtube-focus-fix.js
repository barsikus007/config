// ==UserScript==
// @name         YouTube focus fix
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  YouTube focus fix
// @author       XpucT
// @match        *.youtube.com/watch?v=*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @grant        none
// ==/UserScript==

const player = document.querySelector('video.video-stream')
player.onmouseenter = () => {
  player.focus()
  scrollTo({ top: 0, behavior: 'smooth' })
}
