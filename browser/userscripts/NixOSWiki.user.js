// ==UserScript==
// @name        switch nixos.wiki to wiki.nixos.org
// @namespace   akellare.ru
// @match       https://nixos.wiki/*
// @grant       none
// @version     0.1.0
// @author      Sweetdogs
// @description Redirect nixos.wiki URLs to wiki.nixos.org
// @downloadURL https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/NixOSWiki.user.js
// ==/UserScript==

window.location.host = "wiki.nixos.org";
