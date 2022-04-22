// ==UserScript==
// @name        Aliexpress No Auto Translate fixed
// @name:ru     Aliexpress No Auto Translate fixed
// @description Aliexpress disable auto translate in title and description + tracking fixed
// @description:ru Отключение автоматического перевода названия и описания товара на Алиэкспресс + tracking fixed
// @namespace   http://aliexpress.com
// @author      barsikus07
// @version     2.0
// @grant       none
// @include     http://*aliexpress*
// @include     https://*aliexpress*
// ==/UserScript==

const blacklistedUrlParams = [
  'spm', 'algo_pvid', 'algo_exp_id',
  'srcSns', 'spreadType', 'bizType', 'social_params', 'aff_fcid', 'tt', 'aff_fsk', 'aff_platform', 'sk', 'aff_trace_key', 'businessType', 'platform', 'terminal_id',
];

const clearLink = (href, com=true, shit=true) => {
  const link = href.split('/');
  let newLink = link;
  if (link.length < 3) return href;
  if (com && link[2].indexOf('aliexpress.ru') !== -1) {
    newLink[2] = 'www.aliexpress.com'
    console.log('Redirect to .com');
  };
  if (shit && newLink.join('/').split('?').length > 1) {
    const newShit = newLink.join('/').split('?').slice(1).join('?').split('&').map((param) => param.split('=')).filter((param) => !blacklistedUrlParams.includes(param[0]));
    newLink = (newLink.join('/').split('?')[0] + '?' + newShit.map(param => param.join('=')).join('&')).split('/');
    console.log('Cleared shit from link');
  };
  return newLink.join('/');
}

const checkLocation = () => {
  console.log('Checking location...');
  const redirectCount = localStorage.getItem('redirectCount') || 0
  console.log(`Redirect count = ${redirectCount}`);
  const link = location.href;
  const newLink = clearLink(location.href);
  if (redirectCount > 2) {
    localStorage.removeItem('redirectCount');
    console.log('Too many redirects...');
    return;
  }
  if (newLink !== link) {
    localStorage.setItem('redirectCount', redirectCount + 1)
    console.log('Redirecting...');
    location.href = newLink;
  } else {
    localStorage.removeItem('redirectCount')
    console.log('Location - ok!');
  }
}

const removeSPMMeta = () => {
  const metas = document.getElementsByTagName('meta');
  for (let i = 0; i < metas.length; i++) {
    if (metas[i].name === 'data-spm') metas[i].remove();
  }
}

const clearDOMLinks = () => {
  const links = document.getElementsByTagName('a');
  for (let i = 0; i < links.length; i++) {
    if (links[i].href.indexOf('/item/') !== -1) continue;
    const newHref = clearLink(links[i].href);
    if (links[i].href !== newHref) links[i].href = newHref;
  }
}

const fixOnClickLinks = () => {
  var links = document.getElementsByTagName('a');

  for (var i = 0; i < links.length ; i++) {
    const process = (event) => {
      event.target.href = clearLink(event.target.href);
    }
    links[i].addEventListener('auxclick', process, false);
    links[i].addEventListener('click', process, false);
  }
}

const old = (link) => {
  let url = link.href;
  link.href = url.replace(/\?spm=[^=&]*&?/g, '?');
  if (url.indexOf('ru.aliexpress.com') > - 1 || url.indexOf('pt.aliexpress.com') > - 1 || url.indexOf('es.aliexpress.com') > - 1 || url.indexOf('id.aliexpress.com') > - 1 || url.indexOf('fr.aliexpress.com') > - 1) {
    console.log(url);
    if (url.indexOf('.aliexpress.com/item/') > - 1 || url.indexOf('.aliexpress.com/store/product/') > - 1) {
      if (url.indexOf('isOrigTitle') == - 1 && url.indexOf('isOrig') == - 1) {
        if (url.indexOf('?') > - 1) {
          link.href = url.replace('?', '?isOrigTitle=true&isOrig=true&');
        } else if (url.indexOf('#') > - 1) {
          link.href = url.replace('#', '?isOrigTitle=true&isOrig=true#');
        } else {
          link.href += '?isOrigTitle=true&isOrig=true';
        }
      }
    }
  }
}

(function () {
  checkLocation();
  removeSPMMeta();
  clearDOMLinks();
  fixOnClickLinks();
})();