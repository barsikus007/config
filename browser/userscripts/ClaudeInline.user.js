// ==UserScript==
// @name         claude.ai autosubmit from q param
// @namespace    https://github.com/barsikus007/
// @version      1.0
// @author       barsikus007
// @icon         https://claude.ai/favicon.svg
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/ClaudeInline.user.js
// @match        https://claude.ai/new*
// @run-at       document-idle
// ==/UserScript==

(function () {
  'use strict';

  // ? only act if the q param was actually present, otherwise stay out of the way
  const params = new URLSearchParams(location.search);
  if (!params.has('q')) return;

  const expected = params.get('q').trim();

  // ? claude fills the composer asynchronously after page load, so poll for it
  const interval = setInterval(() => {
    const editor = document.querySelector('div[contenteditable="true"]');
    if (!editor) return;

    const current = editor.innerText.trim();
    if (!current || current !== expected) return;

    clearInterval(interval);

    // ? simulate a real keydown so react's listener picks it up, dispatchEvent alone is not enough
    editor.dispatchEvent(
      new KeyboardEvent('keydown', {
        key: 'Enter',
        code: 'Enter',
        keyCode: 13,
        which: 13,
        bubbles: true,
        cancelable: true,
      }),
    );
  }, 200);

  // ? stop polling after 10s so we don't spin forever on a page that never fills
  setTimeout(() => clearInterval(interval), 10000);
})();
