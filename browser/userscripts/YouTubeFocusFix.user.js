// ==UserScript==
// @name         YouTube Focus Fix
// @namespace    http://tampermonkey.net/
// @version      1.0
// @author       XpucT
// @description  Force focus and scroll to player when mouse enters it
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @updateURL    https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/YouTubeFocusFix.user.js
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/YouTubeFocusFix.user.js
// @match        *.youtube.com/watch?v=*
// ==/UserScript==

const player = document.querySelector('video.video-stream')
player.onmouseenter = () => {
  player.focus()
  scrollTo({ top: 0, behavior: 'smooth' })
}
