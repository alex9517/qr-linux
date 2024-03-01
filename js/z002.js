// Modified : 2020-Dec-15;

const keyStyle = 'qr_lin_style';
const keyPage = 'qr_lin_page';

const styleMobile = 'mobile';
const styleOneCol = 'one';
const styleTwoCol = 'two';

$(function() {
  let currPage = window.location.href;
  // console.log(currPage + ' is loaded.');
  let currPath = currPage.substring(0, currPage.lastIndexOf("/") + 1);
  // console.log('path: ' + currPath);
  // console.log('history: ' + history.length);

  let refStyle = localStorage.getItem(keyStyle)
  // console.log(keyStyle + ': ' + refStyle);

  if (!refStyle) {
    refStyle = styleMobile;
  }

  if (refStyle == styleMobile) {
    $('td.menu1').css('padding-top','4%');
    $('td.menu2').css('padding-top','4%');
    $('td.menu1').css('padding-bottom','5%');
    $('td.menu2').css('padding-bottom','5%');
  }

  if (refStyle == styleTwoCol) {
    if (currPage.indexOf('toc.html') < 0
        && currPage.indexOf('abbrev.html') < 0
        && currPage.indexOf('shortcuts.html') < 0) {
      localStorage.setItem(keyPage, currPage);
      // console.log('Saving cookie : ' + currPage);
    }
  }

  $('body').on('click', '#restart', function(e) {
    let refStyle = localStorage.getItem(keyStyle);

    if (!refStyle) {
      refStyle = styleMobile;
    }

    if (refStyle == styleTwoCol) {
      localStorage.setItem(keyPage, currPath + "keys.html");

      // window.parent.location.reload();

      // The above stmt throws ..
      // "Uncaught DOMException: Permission denied
      //  to access property "reload" on cross-origin object"

      // So, I had to replace it with following ..
      // (the receiving part of it is in "index_2.html");

      window.parent.postMessage("reload", "*");
    } else {
      window.history.back();
      // window.location.replace(currPath + "toc.html");
    }
  });

  $('body').on('click', '#layout', function(e) {

    let refStyle = localStorage.getItem(keyStyle);

    if (!refStyle) {
      refStyle = styleMobile;
    }

    if (refStyle == styleOneCol) {
      localStorage.setItem(keyStyle, styleTwoCol);
    } else if (refStyle == styleTwoCol) {
      localStorage.setItem(keyStyle, styleOneCol);
      window.parent.postMessage("reload", "*");
      //window.parent.location.reload();
      //window.location.replace(currPath + "index.html");
    }
  });
});


$(window).on('hashchange', function() {
  // console.log('hashchange event: ' + location.hash);

  let currPage = window.location.href;
  let refStyle = localStorage.getItem(keyStyle);

  if (refStyle == styleTwoCol) {
    if (currPage.indexOf('toc.html') < 0
        && currPage.indexOf('abbrev.html') < 0
        && currPage.indexOf('shortcuts.html') < 0) {
      localStorage.setItem(keyPage, currPage);
    }
  }
});


var getCurrFileName = function() {
  let currPage = window.location.pathname;
  return currPage.substring(currPage.lastIndexOf("/") + 1);
  // ... currPage.split('/').pop();
};


var getScrollbarWidth = function() {
  let W = window.browserScrollbarWidth;

  if (W === undefined) {
    let body = document.body;
    let div = document.createElement('div');
    div.innerHTML = '<div style="width: 50px; height: 50px; position: absolute; left: -100px; top: -100px; overflow: auto;"><div style="width: 1px; height: 100px;"></div></div>';
    div = div.firstChild;
    body.appendChild(div);
    W = window.browserScrollbarWidth = div.offsetWidth - div.clientWidth;
    body.removeChild(div);
  }
  return W;
};


var resetState = function() {
  localStorage.setItem(keyStyle, '');
  localStorage.setItem(keyPage, '');
};


var isMobile = function() {
  if (navigator.userAgent.match(/Android/i)
      || navigator.userAgent.match(/iPhone/i)
      || navigator.userAgent.match(/iPad/i)
      || navigator.userAgent.match(/Opera Mini/i)
      || navigator.userAgent.match(/Windows Phone/i)
      || navigator.userAgent.match(/IEMobile/i)
      || navigator.userAgent.match(/WPDesktop/i)
      || navigator.userAgent.match(/iPod/i)
      || navigator.userAgent.match(/webOS/i)
      || navigator.userAgent.match(/BlackBerry/i)) {
    return true;
  }
  return false;
};

// -END-
