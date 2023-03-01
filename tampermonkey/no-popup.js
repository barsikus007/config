// ==UserScript==
// @name         no popup
// @version      1.0
// @description  shitcoded popup remover via semantics magic
// @author       barsikus007
// @match        https://*/*
// @require      https://code.jquery.com/jquery-3.6.3.slim.min.js
// ==/UserScript==

const $ = window.jQuery

function getElementWithStyle() {
    const vw = $(window).width()
    const vh = $(window).height()
    const elements = $('*').filter( function(){
        return ($(this).css('position') == 'fixed');
    }).filter( function(){
        return ($(this).css('z-index') > 100);
    }).filter( function(){
        return ($(this).css('top') == '0px');
    }).filter( function(){
        return ($(this).css('left') == '0px');
    }).filter( function(){
        return ($(this).css('width') == `${vw}px`);
    }).filter( function(){
        return ($(this).css('height') == `${vh}px`);
    })
    return [...elements]
}

function clearPopups() {
    console.log("WIP due to many false positives at vk.com")
    return
    console.log("no popup started work")
    const elementsToDelete = getElementWithStyle()
    console.log("no popup found these elements to hide")
    console.log(elementsToDelete)
    elementsToDelete.forEach(el => { el.style.display = 'none' })
    console.log("no popup finished work")
}

(function () {
    clearPopups()
})()
