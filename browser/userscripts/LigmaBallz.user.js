// ==UserScript==
// @name         Ligma Ballz
// @namespace    https://github.com/barsikus007/
// @version      1.3.3.7
// @author       barsikus007
// @description  Hacks ligma dev mode
// @icon         https://static.figma.com/app/icon/1/favicon.ico
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/LigmaBallz.user.js
// @match        https://www.figma.com/file/*
// @run-at       document-start
// ==/UserScript==

const logger = console.log.bind(console, 'Ligma Ballz:');

(function () {
  // @match        https://www.figma.com/file/*
  'use strict';

  new MutationObserver(async (mutations, observer) => {
    logger('Loaded Chrome');
    let oldScript = mutations
      .flatMap((e) => [...e.addedNodes])
      .filter((e) => e.tagName == 'SCRIPT')
      .find((e) => e.src.match(/figma_app\.min\.js\.br/));

    if (oldScript) {
      logger('script found', oldScript);
      observer.disconnect();
      oldScript.remove();

      let text = await fetch(oldScript.src)
        .then((e) => e.text())
        .then((e) => e.replace(/[tk_].canAccessFullDevMode/g, 'true'));

      let newScript = document.createElement('script');
      newScript.type = 'module';
      newScript.textContent = text;
      logger('script patched', newScript);
      document.head.appendChild(newScript);
      logger('script injected', newScript);
    }
  }).observe(document, {
    childList: true,
    subtree: true,
  });
})();
