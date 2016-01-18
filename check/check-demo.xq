import module namespace qt = 'http://xokomola.com/xquery/check'
    at 'check.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare variable $local:dir := file:base-dir() || '../../origami/test';

(: o:xml(qt:test(file:base-dir())) :)
(: inspect:module($local:dir || '/test-xml.xqm') :)
(: inspect:xqdoc($local:dir || '/test-xml.xqm') :)
(: qt:module-selector(file:base-dir() || '../../origami/test') :)

  qt:run-tests(qt:load-suite(
    map { 
      'dir': $local:dir,
      'include': '*.xqm' 
    }
  ))
  
(:
file:write(
  file:base-dir() || '_origami-tests.xml',
  o:xml(qt:unit-test(file:base-dir() || '../../origami/test')))
:)
  
(: inspect:module(file:base-dir() || 'check.xqm') :)
(: return 10 random integers :)
(: (1 to 10) ! qt:integer()() :)

(: return 10 random integers between 1 and 3 :)
(: (1 to 10) ! qt:integer(1,5)() :)

(: return 10 random integers between -5 and 5 :)
(: (1 to 10) ! qt:integer(-5,5)() :)

(: return a sequence of two random integers :)
(: (qt:integer(1,10)(),qt:integer(1,10)()) :)

(:
declare function local:is-sort-idempotent($coll)
{
  deep-equal(sort($coll), sort(sort($coll)))
};

qt:check(
  local:is-sort-idempotent#1, 
  qt:seq(qt:integer())
)
:)

(:
for $a in qt:array(qt:integer(1,10))(1,101)?*
return
  array:size($a)
:)

(: [ qt:gen-args(qt:seq(qt:integer())(3,2)) ] :)


(: provide the names of test modules :)
(: load and inspect them for test functions :)
(: build a test data structure :)
(: invoke the tests :)
(:
let $uri := file:base-dir() || '../../origami/test/test-xml.xqm'
let $tests := qt:load-module($uri)
for $test in $tests
return
  (: $test :)
  (: qt:build-test-query($test) :)
  qt:test($test)
  (: o:xml(qt:test($test)) :)
  (: inspect:module($uri) :)
  (: qt:test($test) :)
:)
(: qt:run-test(unit:assert-equals#2, [3,4]) :)
(: o:xml(qt:run-test(qt:example-failing-unit-test#0,[])) :)
(: o:xml(qt:run-test(qt:example-passing-unit-test#0,[])) :)
(: unit:assert-equals(3,4) :)
(: apply(unit:assert-equals#2,[3,4]) :)

(: xquery:eval('[1,2]') :)
(: xquery:eval('map { "x": 10 }') :)