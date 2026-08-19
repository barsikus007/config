// ==UserScript==
// @name         VK Player Max Quality
// @namespace    https://github.com/barsikus007/
// @version      1.0.0
// @author       barsikus007
// @description  Auto-selects the highest available quality in the cdnvideohub (VK) player iframe (shikimori default player)
// @icon         https://www.google.com/s2/favicons?sz=64&domain=cdnvideohub.com
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/VKPlayerMaxQuality.user.js
// @match        https://player.cdnvideohub.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

const main = () => {
  //! must live inside main: the body is serialized into a page-context <script>, the outer scope is not
  'use strict';

  //? false = keep re-forcing the max even after a manual pick from the settings menu
  const RESPECT_MANUAL_CHOICE = true;
  const DEBUG = false;

  //? player quality ids, best first (see Mn enum in frame/index.js)
  const QUALITY_ORDER = ['4320p', '2160p', '1440p', '1080p', '720p', '576p', '480p', '360p', '240p', '144p'];

  const log = (...args) => DEBUG && console.log('VK Player Max Quality:', ...args);

  //? stores are svelte-like in the ui and rxjs-like in the core, so both shapes have to be handled
  const read = (store) => {
    if (typeof store?.getValue === 'function') {
      return store.getValue();
    }
    let value;
    const result = store?.subscribe((next) => {
      value = next;
    });
    if (typeof result === 'function') {
      result();
    } else {
      result?.unsubscribe?.();
    }
    return value;
  };

  //? menu items are {value, displayValue, selected}, where value is a quality id or 'auto'
  const toValue = (item) => (item && typeof item === 'object' ? item.value : item);

  const pickBest = (qualities) => qualities.filter((quality) => QUALITY_ORDER.includes(quality)).sort((a, b) => QUALITY_ORDER.indexOf(a) - QUALITY_ORDER.indexOf(b))[0];

  let boundStore = null;
  let appliedFor = Symbol('none');
  let loggedQualities = null;

  const tick = () => {
    const element = document.querySelector('vk-video-player');
    //? the store appears only after the parent frame posts videoData, and is replaced on failover re-init
    const store = element?.store;
    if (!store) {
      return;
    }
    if (store !== boundStore) {
      boundStore = store;
      appliedFor = Symbol('none');
      loggedQualities = null;
      log('store found', store);
    }

    //? videoId changes on the next video in a playlist, which releases the one-shot guard below
    const videoId = read(store.videoId$);
    const qualities = (read(store.state.availableQualities$) ?? []).map(toValue);
    const serialized = qualities.join();
    if (serialized !== loggedQualities) {
      loggedQualities = serialized;
      log('available', qualities, 'videoId', videoId);
    }
    const best = pickBest(qualities);
    if (!best) {
      return;
    }
    if (RESPECT_MANUAL_CHOICE && appliedFor === videoId) {
      return;
    }
    appliedFor = videoId;
    if (!read(store.state.isAutoQualityEnabled$) && read(store.state.currentQuality$) === best) {
      return;
    }
    if (store.actions?.external?.setQuality) {
      store.actions.external.setQuality(best);
    } else {
      store.actions?.internal?.setQuality?.(best, { appliesTo: 'to-video', byUser: true });
    }
    log('forced', best);
  };

  log('running in', location.href);
  setInterval(tick, 500);
};

//? Firefox hides page-set expando props (element.store) behind Xray wrappers, so the logic has to live in page context
const inject = () => {
  const script = document.createElement('script');
  script.textContent = `(${main})();`;
  (document.head ?? document.documentElement).append(script);
  script.remove();
};

if (document.documentElement) {
  inject();
} else {
  document.addEventListener('DOMContentLoaded', inject, { once: true });
}
