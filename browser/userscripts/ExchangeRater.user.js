// ==UserScript==
// @name         Exchange Rate converteR
// @namespace    https://github.com/barsikus007/
// @version      0.1.0
// @author       barsikus007
// @description  Exchange rate converter on selection
// @icon         https://www.google.com/s2/favicons?sz=64&domain=exchangerate-api.com
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/ExchangeRate.user.js
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_registerMenuCommand
// @run-at       document-body
// ==/UserScript==

const defaultTargetCurrency = "RUB";
const defaultRates = {
  RUB: 1,
  USD: 0.01,
  EUR: 0.009,
};
const currencyAliases = {
  RUB: "₽", // Russian Ruble
  USD: "$", // US Dollar
  EUR: "€", // Euro
  CRC: "₡", // Costa Rican Colón
  GBP: "£", // British Pound Sterling
  ILS: "₪", // Israeli New Sheqel
  INR: "₹", // Indian Rupee
  JPY: "¥", // Japanese Yen
  KRW: "₩", // South Korean Won
  NGN: "₦", // Nigerian Naira
  PHP: "₱", // Philippine Peso
  PLN: "zł", // Polish Zloty
  PYG: "₲", // Paraguayan Guarani
  THB: "฿", // Thai Baht
  UAH: "₴", // Ukrainian Hryvnia
  VND: "₫", // Vietnamese Dong
};

const contextDivId = "exchange-rate-context";
const refreshRate = 1000 * 60 * 60 * 3; // 3 hours
const apiEndpoint = "https://api.exchangerate-api.com/v6/latest/";

GM_registerMenuCommand("Choose Currency", () => {
  GM_setValue("targetCurrency", prompt("Type your Currency (RUB,USD,EUR)", "RUB"));
});

GM_registerMenuCommand("Update Rates", () => {
  updateCurrency();
  const rates = GM_getValue("rates", defaultRates);
  alert(`Updated:\n${JSON.stringify(rates)}`);
});

const updateCurrency = async () => {
  const targetCurrency = GM_getValue("targetCurrency", defaultTargetCurrency);
  const response = await fetch(apiEndpoint + targetCurrency);
  const data = await response.json();
  // console.log('data.rates: ', data.rates);
  GM_setValue("rates", data.rates);
  GM_setValue("lastUpdateTime", Date.now());
};

/**
 * @param {number} amount
 * @param {string} currencyId
 */
const convertCurrency = async (amount, currencyId) => {
  const targetCurrency = GM_getValue("targetCurrency", defaultTargetCurrency);
  if (GM_getValue("lastUpdateTime", 0) + refreshRate < Date.now()) {
    console.log("[ExchangeRater] Rates are outdated. Updating...");
    await updateCurrency();
  }
  const rates = GM_getValue("rates", defaultRates);
  return parseFloat(((amount / rates[currencyId]) * rates[targetCurrency]).toFixed(2));
};

/**
 * @param {MouseEvent} e
 * @param {string} popupText
 */
const renderContext = (e, popupText, textToCopy) => {
  // https://stackoverflow.com/a/73196291
  // Find out how much (if any) user has scrolled
  const scrollTop =
    window.scrollY !== undefined
      ? window.scrollY
      : (document.documentElement || document.body.parentNode || document.body).scrollTop;

  // Get cursor position
  const posX = e.clientX;
  const posY = e.clientY + 20 + scrollTop;

  // TODO replace with https://violentmonkey.github.io/guide/using-modern-syntax/
  document.getElementById(contextDivId)?.remove();
  const contextDiv = document.createElement("div");
  const contextDivText = document.createElement("div");
  contextDiv.id = contextDivId;
  contextDiv.style.position = "absolute";
  contextDiv.style.top = posY + "px";
  contextDiv.style.left = Math.abs(posX) + "px";

  contextDiv.style.color = "white";
  contextDiv.style.backgroundColor = "#303030";
  contextDiv.style.border = "1px solid #636363";
  contextDiv.style.borderRadius = "8px";
  contextDiv.style.padding = "4px";

  contextDivText.innerHTML = popupText;
  contextDivText.style.borderRadius = "4px";
  contextDivText.style.padding = "4px";
  contextDivText.style.lineHeight = "20px";
  contextDivText.style.fontFamily = "Segoe UI, sans-serif";
  contextDivText.style.cursor = "default";

  contextDivText.onmouseover = () => {
    contextDivText.style.backgroundColor = "#393939";
  };
  contextDivText.onmouseout = () => {
    contextDivText.style.backgroundColor = null;
  };
  contextDiv.onmousedown = () => {
    navigator.clipboard.writeText(textToCopy);
    window.getSelection().empty();
    // console.log("textToCopy: ", textToCopy);
  };
  contextDiv.appendChild(contextDivText);
  document.body.insertAdjacentElement("beforeend", contextDiv);
  // console.log("popupText: ", popupText);
};

window.addEventListener("mouseup", async (e) => {
  const selection = window.getSelection().toString();
  if (!selection.length) {
    document.getElementById(contextDivId)?.remove();
    return;
  }
  Object.entries(currencyAliases).forEach(async ([currencyId, currencySymbols]) => {
    for (const currency of [currencyId, currencySymbols]) {
      if (!selection.includes(currency)) {
        continue;
      }
      const processedSelection = selection
        .replace(currency, " ")
        .replace(/[^\d. ]/g, "")
        .trim();
      const amount = parseFloat(processedSelection);
      const convertedAmount = await convertCurrency(amount, currencyId);
      const targetCurrency = GM_getValue("targetCurrency", defaultTargetCurrency);
      const popupText = `${amount} ${currencyAliases[currencyId]} ≈ ${convertedAmount} ${currencyAliases[targetCurrency]}`;
      renderContext(e, popupText, convertedAmount);
      return;
    }
  });
});
