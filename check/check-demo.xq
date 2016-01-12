import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace qt = 'http://xokomola.com/xquery/origami/examples'
    at 'check.xqm'; 

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

[ qt:gen-args(qt:seq(qt:integer())(3,2)) ]