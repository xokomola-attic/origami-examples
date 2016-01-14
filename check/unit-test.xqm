module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(:~
 : Run unit tests.
 : Use `xquery:eval` to set up a test environment. Can also set timeout
 : so non-terminating tests can finish.
 :)

(:~
 : Load test modules and return a data structure with test functions embedded.
 :)
declare function ex:load-suite($modules as xs:string*)
{
    $modules ! ex:load-module(.)
};

(:~
 : Load a test module and return a data structure with test functions embeded.
 :)
(: inspect will take the last xqdoc comment from the function, not the one
 : preceding it!
 :)
(: TODO: maybe matching/filtering of tests? Can use standard techniques for this :)
declare function ex:load-module($module)
{
    for $fn in inspect:module($module)/function
    where $fn/annotation/@name = 'unit:test' and $fn/@name = 'test:xml'
    return
        map {
            'name': string($fn/@name),
            'uri': string($fn/@uri),
            'module': $module
        }
};

(:~
 : Run the one test (specified as a map)
 :)
declare function ex:test($test)
{
    xquery:eval(ex:build-test-query($test))
};

(:~
 : Build a query string that can be used with `xquery:eval`.
 : The query calls one unit test function. It will also use some
 : test utility functions that are used in this test harness.
 :
 : This is the normal XML representation from inspection:
 :
 : <function name="test:xml" uri="http://xokomola.com/xquery/origami/tests">
 :   <annotation name="unit:test" uri="http://basex.org/modules/unit"/>
 :   <description>Sequence as content.</description>
 :   <return type="item()" occurrence="*"/>
 : </function>
 :
 : It is, instead, represented using a map.
 :
 : map {
 :   'name': 'test:xml',
 :   'uri': '...',
 :   'module': '.../path/to/module/test.xqm'
 : }
 :)
(: Maybe it's better to eval only once and many tests with one eval. :)
(: For test functions with arguments we can add this info to the map as well :)
(: Expect should also be handled :)
declare function ex:build-test-query($test)
{
    'import module namespace ex = "' || 
    'http://xokomola.com/xquery/origami/examples' || 
    '" at "' || 
    file:base-dir() ||
    'unit-test.xqm' ||
    '"; ' ||
    'import module namespace test = "' || 
    $test?uri || 
    '" at "' || 
    $test?module || 
    '"; ' ||
    'ex:run-test(' || 
    $test?name 
    || '#0,[])'
};

declare %unit:test function ex:example-failing-unit-test()
{
    unit:assert-equals(3,4)
};

declare %unit:test function ex:example-passing-unit-test()
{
    unit:assert-equals(4,4)
};

declare function ex:run-test2($fn, $args)
{
    ['test',
            let $fail := 
                try {
                    apply($fn,$args)
                } catch * {
                    ['fail',
                        map {
                            'code': trace($err:code, 'XXX: '),
                            'module': $err:module,
                            'line': $err:line-number, 
                            'column': $err:column-number,
                            'fn': $fn,
                            'args': $args
                        },
                        ['desc', $err:description],
                        ['value', $err:value]
                    ]
                }
            return
                if (exists($fail)) then
                    $fail
                else
                    ['pass', map { 'fn': $fn, 'args': $args }]
    ]
};

declare function ex:run-test($fn, $args)
{
    (: apply($fn,$args) :)
    [1,2]
};
