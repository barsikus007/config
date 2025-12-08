// ==UserScript==
// @name         Gemini URL Param Pre-fill
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Allows ?q=query in URL to auto-fill Gemini chat
// @author       You
// @match        https://gemini.google.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // 1. Get the 'q' parameter from the URL
    const url = new URL(window.location);
    const query = url.searchParams.get('q');

    if (!query) return

    // This prevents the script from running again if you refresh the page
    // TODO: don't work
    url.searchParams.delete('q');
    window.history.replaceState({}, '', url);

    // 2. Wait for the input box to load (it's dynamic)
    const waitForInput = setInterval(() => {
        // Selects the main contenteditable div (rich text editor)
        const inputField = document.querySelector('div[contenteditable="true"]');

        if (!inputField) return

        clearInterval(waitForInput);

        // 3. Simulate user typing (required for React/Angular apps to register change)
        inputField.focus();
        document.execCommand('insertText', false, query);

        // 4. Auto-send after a delay
        setTimeout(() => {
            const sendBtn = document.querySelector('button[aria-label*="Send"]'); // Selector may vary
            if (sendBtn) sendBtn.click();
        }, 500);

    }, 500); // Checks every 500ms
})();
