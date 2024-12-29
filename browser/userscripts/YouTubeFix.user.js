// ==UserScript==
// @name         YouTube Fix
// @namespace    https://github.com/barsikus007/
// @version      2.0.1
// @author       XpucT & AngusWR
// @description  Force focus and scroll to player when mouse enters it & 'Video paused. Continue watching?' auto confirmer
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/YouTubeFix.user.js
// @match        *://*.youtube.com/watch?v=*
// ==/UserScript==

"use strict";

// Credits: https://boosty.to/xpuct
const player = document.querySelector("video.video-stream");
player.onmouseenter = () => {
  player.focus();
  scrollTo({ top: 0, behavior: "smooth" });
  console.log("YouTube Fix:", "Player focused and scrolled to");
};

// Credits: https://greasyfork.org/en/scripts/377506-youtube-video-paused-continue-watching-auto-confirmer
const texts = [
  "Video paused. Continue watching?",
  "Воспроизведение приостановлено. Продолжить?",
]

setInterval(() => {
  const popup = document.getElementsByClassName("line-text style-scope yt-confirm-dialog-renderer");
  if (popup.length >= 1) {
    for (let i = 0; i < popup.length; i++) {
      if (texts.includes(popup[i].innerText)) {
        popup[i].parentNode.parentNode.parentNode.querySelector("#confirm-button").click();
        console.log("YouTube Fix:", "Continue watching confirmed in", popup[i].innerText);
      }
    }
  }
}, 250)();
