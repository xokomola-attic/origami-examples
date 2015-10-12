xquery version "3.1";

module namespace s2 = 'http://xokomola.com/ns/xml/validation/my-types';

import module namespace s = 'http://xokomola.com/ns/xml/validation/json/schema'
    at 'schema.xqm';

(:~
 : An atomic schema type.
 :
 : @see https://github.com/Prismatic/schema/wiki/Defining-New-Schema-Types
 : 
 : Demonstrates how to write a custom type that verifies if a
 : value is equal to a string.
 : As this returns an anonymous functions it cannot be used to 
 : generate Relax-NG schemas.
 :
 : Note that this is already defined in schema.xqm as s:eq.
 :)

declare function s2:check($instance,$schema) { s:check($instance,$schema) };

declare function s2:eq($test)
{
    let $msg := s:Error(concat('Not equal to: ', $test))
    return
        function ($x) {
            if ($x eq $test)
            then $x
            else $msg($x)
        }
};

declare function s2:even-pos($x)
{
    s2:both(
        s2:pred(s2:is-even#1),
        s2:pred(s2:is-pos#1)
    )($x)
};

declare function s2:pred($p)
{
    let $msg := s:Error('error in pred')
    return
        function ($x) {
            if ($p($x))
            then $x
            else $msg($x)
        }
};

declare function s2:is-pos($x) { $x gt 0 };
declare function s2:is-even($x) { $x mod 2 eq 0 };

(: s:check(4, s2:even-pos#1) :)
(: s:check(-5, s2:even-pos#1) :)

declare function s2:both($s1, $s2)
{
    let $msg := s:Error('both error')
    return
        function ($x) {
            fold-left(
                ($s1,$s2),
                $x,
                function($x, $s) {
                    $s($x)
                }
            )
        }
};

(: ---- examples ---- :)

declare function s2:check-atomic-type($x)
{
    s:check($x, s2:eq("Schemas are cool!"))
};

declare function s2:check-composite-type($x)
{
    s:check($x, s2:eq("Schemas are cool!"))
};

(: ---- walk examples ---- :)

declare function s2:walk1()
{
    let $inner := function($x) { $x * 2 }
    let $outer := function($x) { sum($x) }
    return
        s:walk($inner, $outer, (1,2,3,4,5))
};
(: => 30 :)

declare function s2:walk2()
{
    let $inner := function($x) { $x(2) }
    let $outer := max#1
    return
        s:walk($inner, $outer, ([1,2],[3,4],[5,6]))
};

(: => 6 :)

declare function s2:walk3()
{
    let $inner := function($x) { $x(1) }
    let $outer := max#1
    return
        s:walk($inner, $outer, ([1,2],[3,4],[5,6]))
    
};

(: => 5 :)

declare function s2:walk4()
{
    let $inner := function($x) { $x(1) }
    let $outer := reverse#1
    return
        s:walk($inner, $outer, ([1,2],[3,4],[5,6]))
};

(: => (5 3 1) :)
