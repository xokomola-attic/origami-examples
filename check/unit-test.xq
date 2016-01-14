import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'unit-test.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(: provide the names of test modules :)
(: load and inspect them for test functions :)
(: build a test data structure :)
(: invoke the tests :)

(:
let $uri := file:base-dir() || '../../origami/test/test-xml.xqm'
let $tests := ex:load-module($uri)
for $test in $tests
return
  (: $test :)
  xquery:eval(ex:build-test-query($test))
  (: inspect:module($uri) :)
  (: ex:test($test) :)
:)
(: ex:run-test(unit:assert-equals#2, [3,4]) :)
(: o:xml(ex:run-test(ex:example-failing-unit-test#0,[])) :)
(: o:xml(ex:run-test(ex:example-passing-unit-test#0,[])) :)
(: unit:assert-equals(3,4) :)
(: apply(unit:assert-equals#2,[3,4]) :)

(: xquery:eval('[1,2]') :)
(: xquery:eval('map { "x": 10 }') :)