// query selector vs jquery
// http://jsperf.com/jquery-vs-queryselectorall-to-array
//
// get element by id vs query selector
// http://jsperf.com/getelementbyid-v-s-queryselector
define(["jquery","cs!umobi.core"],function($,umobi) {
    var dom = {  };
    dom.supportClassList = (typeof document.documentElement.classList !== 'undefined');

    dom.query = function(q,c) {
        c = c || document;
        return c.querySelector(q);
    };

    dom.queryAll = function(q,c) {
        c = c || document;
        // querySelectorAll is available in IE8, Chrome, Firefox and Safari
        // in this library we don't consider IE7
        return c.querySelectorAll(q);
    };

    // get element by id, which is faster than querySelectorAll
    dom.get = function(d,c) {
        c = c || document;
        return c.getElementById(d);
    };


    // convert element collection to array
    // which is needed when iterating huge collection.
    dom.collectionToArray = function(c) {
        var i = 0, len = c.length;
        var list = [];
        for (; i < len ; i++ ) {
            list.push(c[i]);
        }
        return list;
    };

    // get by tagname
    dom.byTagName = function(n,c) {
        c = c || document;
        return c.getElementsByTagName(n);
    };
    dom.byClassName = function(n,c) {
            c = c || document;
            return c.getElementsByClassName(n);
    };


    // http://jsperf.com/jquery-addclass-vs-dom-classlist/2
    dom.addClass = function(e,cls) {
        if(typeof e.classList !== 'undefined')
            e.classList.add(cls);
        // jquery fallback
        else $(e).addClass(cls);
    };
    dom.removeClass = function(e,cls) {
        if(this.supportClassList)
            e.classList.remove(cls);
        else $(e).removeClass(cls);
    };
    dom.toggleClass = function(e,cls) {
        if(this.supportClassList)
            e.classList.toggle(cls)
        else $(e).toggleClass(cls);
    };
    dom.bind = function(el,n,cb) {
        el.addEventListener(n,cb);
    };
    umobi.dom = dom;
    return dom;
});
