// ==UserScript==
// @name         YouTube Fix
// @namespace    https://github.com/barsikus007/
// @version      2.1.0
// @author       XpucT & AngusWR & barsikus007
// @description  Force focus and scroll to player when mouse enters it & 'Video paused. Continue watching?' auto confirmer
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/YouTubeFix.user.js
// @match        *://*.youtube.com/*
// ==/UserScript==

'use strict';

//! Credits: https://boosty.to/xpuct
const player = document.querySelector('video.video-stream');
if (player) {
  player.onmouseenter = () => {
    player.focus();
    scrollTo({ top: 0, behavior: 'smooth' });
    console.log('YouTube Fix:', 'Player focused and scrolled to');
  };
}

//! Credits: https://greasyfork.org/en/scripts/377506-youtube-video-paused-continue-watching-auto-confirmer
const continueTexts = [
  'Video paused. Continue watching?',
  'Воспроизведение приостановлено. Продолжить?',
];

const selectors = {
  //? youtube.com
  '.line-text.style-scope.yt-confirm-dialog-renderer': {
    popupTexts: continueTexts,
    confirmSelector: '#confirm-button',
  },
  //? music.youtube.com
  '.text.style-scope.ytmusic-you-there-renderer': {
    popupTexts: continueTexts,
    confirmSelector: '[dialog-confirm]',
  },
  //? https://music.youtube.com/watch?v=eBo3LU7Do9o
  'div#info.style-scope.yt-player-error-message-renderer': {
    popupTexts: [
      'The following content may contain suicide or self-harm topics.',
      // TODO: ru
    ],
    // 'I understand and wish to proceed',
    confirmSelector:
      '#button button[aria-label="I understand and wish to proceed"]',
  },
};

setInterval(() => {
  /** @type HTMLCollectionOf<Element> **/
  let popups;
  /** @type selectors[keyof selectors] **/
  let selector;
  Object.keys(selectors).forEach((popupTextSelector) => {
    popups = document.querySelectorAll(popupTextSelector);
    if (!popups.length) return;
    selector = selectors[popupTextSelector];
  });
  if (!selector) return;
  [...popups].forEach((popup) => {
    const { popupTexts, confirmSelector } = selector;
    if (!popupTexts.some((popupText) => popup.innerText.includes(popupText)))
      return;
    popup.querySelector(confirmSelector).click();
    // popupNode.remove();
    console.log('YouTube Fix:', 'Confirmed in', popup.innerText);
  });
}, 250);
