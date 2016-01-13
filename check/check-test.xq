import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'check-test.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(: $ex:xml-cases :)

o:xml(ex:check())

(: o:xml(ex:equals(4,3)) :)