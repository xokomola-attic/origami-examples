import module namespace qt = 'http://xokomola.com/xquery/check'
    at 'check.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

o:xml(qt:test(file:base-dir() || '../../origami/test'))
