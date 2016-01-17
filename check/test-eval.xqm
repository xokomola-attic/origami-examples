xquery version "3.1";

(:~
 : Tests for xquery:eval returning function items.
 : These functions will only pass on BaseX 8.4-20160115 or higher.
 :)
module namespace test = 'http://xokomola.com/xquery/origami/tests';

declare %unit:test function test:map()
{
    unit:assert-equals(
        xquery:eval('map { "x": 10 }'),
        map { 'x': 10 }
    )
};

declare %unit:test function test:map-with-function()
{
    unit:assert-equals(
        xquery:eval('map { "x": function($y) { $y * 2 } }')?x(2),
        4
    )
};

declare %unit:test function test:array()
{
    unit:assert-equals(
        xquery:eval('[1,2,"3"]'),
        [1,2,'3']
    )
};

declare %unit:test function test:array-with-function()
{
    unit:assert-equals(
        xquery:eval('[1, function($y) { $y * 2 },"3"]')?2(2),
        4
    )
};

declare %unit:test function test:function()
{
    unit:assert-equals(
        xquery:eval('function() { 10 }')(),
        10
    )
};

declare %unit:test function test:function-args()
{
    unit:assert-equals(
        xquery:eval('function($x) { $x * 2 }')(2),
        4
    )
};

declare %unit:test function test:function-using-anon-fn()
{
    unit:assert-equals(
        xquery:eval(
            '
             let $mul := function($x) { $x * 2 } 
             return function($x) { $mul($x) }
            ')(2),
        4
    )
};

declare %unit:test function test:named-function()
{
    unit:assert-equals(
        xquery:eval(
            '
             declare function local:mul($x) { $x * 2 }; 
             local:mul#1
            ')(2),
        4
    )
};

declare %unit:test function test:named-function-using-named-function()
{
    unit:assert-equals(
        xquery:eval(
            '
             declare function local:mul($x) { $x * 2 }; 
             function($x) { local:mul($x) }
            ')(2),
        4
    )
};

declare %unit:test function test:anon-function-using-named-function()
{
    unit:assert-equals(
        xquery:eval(
            '
             declare function local:mul($x) { $x * 2 }; 
             function() { local:mul#1 }
            ')()(2),
        4
    )
};

(: FAILS with [bxerr:BXXQ0001] No updating expression allowed. :)

declare %unit:test %unit:ignore function test:function-with-closure()
{
    unit:assert-equals(
        xquery:eval(
            '
             let $fn := function($x) { 
                function() { $x } 
             }
             return $fn(4)
            ')(),
        4
    )
};
