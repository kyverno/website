// dom lookup helpers

function isObj(obj) {
  return (obj && typeof obj === 'object' && obj !== null) ? true : false;
}

function createEl(el="div") {
  return document.createElement(el);
}

function emptyEl(el) {
  while(el.firstChild)
  el.removeChild(el.firstChild);
}

function elem(selector, parent = document){
  let elem = isObj(parent) ? parent.querySelector(selector) : false;
  return elem ? elem : false;
}

function elems(selector, parent = document) {
  let elems = isObj(parent) ? parent.querySelectorAll(selector) : [];
  return elems.length ? elems : false;
}