xquery version '3.1';

module namespace qt = 'http://xokomola.com/xquery/check';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(: ==================== Unit tests ==================== :)

declare %private variable $qt:eval-options := ('timeout', 'permission', 'memory');

declare %private variable $qt:default-options :=
    map {
        'annotation': 'unit:test',
        'exclude-annotation': 'unit:ignore',
        'doc': true(),
        'timeout': 30
    };
    
(:~
 : Run a test suite just like the built-in Unit test command.
 : Takes a sequence of path strings, file names are modules which get
 : parsed for unit tests. Directories will be scanned for modules.
 :
 :)
declare function qt:unit-test($paths as item()*)
{
    qt:unit-test($paths, map {})
};

declare function qt:unit-test($paths as item()*, $options as map(*))
{
    qt:run-tests(qt:load-suite($paths, $options))
};

(:~
 : Run the one test (specified as a map)
 :)
declare function qt:eval-test($test as array(*))
as item()*
{
    xquery:eval(
        qt:build-test-query($test), 
        o:select-keys($qt:default-options, $qt:eval-options)
    )
};

declare function qt:run-tests($suite as array(*))
{
    o:xml(
        let $results := o:apply($suite)
        return
            $results => 
                o:set-attrs(
                    map {
                        'passed': sum(fold-left(o:children($results), (), function($acc, $module) { ($acc, o:attrs($module)?passed) })),
                        'failed': sum(fold-left(o:children($results), (), function($acc, $module) { ($acc, o:attrs($module)?failed) })),
                        'errors': sum(fold-left(o:children($results), (), function($acc, $module) { ($acc, o:attrs($module)?errors) })),
                        'skipped': sum(fold-left(o:children($results), (), function($acc, $module) { ($acc, o:attrs($module)?skipped) }))
                    }
                )
    )   
};

(:~
 : The function that is called when running the test. It will
 : try the function with the arguments (using fn:apply) and build 
 : a result data structure.
 :)
(: TODO: pushing $err:value into Mu data may cause problems serializing as it might be a function item (for now simply serialize the value) :)
declare function qt:run-test($fn, $args as array(*))
{
    let $test-attrs :=
        map:merge((
            map:entry('name', function-name($fn)),
            if (array:size($args) gt 0) then map:entry('args', $args) else ()
        ))
    let $start-ns := prof:current-ns()
    let $fail := 
        try {
            apply($fn,$args)
        } catch * {
            ['fail',
                let $duration := qt:time($start-ns)
                return
                    map:merge((
                        $test-attrs,
                        map {
                            'error': $err:code,
                            'module': $err:module,
                            'line': $err:line-number, 
                            'column': $err:column-number,
                            'time': $duration
                            
                        }
                    )),
                ['desc', $err:description],
                ['value', 
                    try {
                        serialize($err:value)
                    } catch * {
                        'NOT-SERIALIZABLE'
                    }
                ]
            ]
        }
    return
        if ($fail instance of array(*) and o:tag($fail) = 'fail') then
            $fail
        else
            ['pass', 
                map:merge(($test-attrs, map:entry('time', qt:time($start-ns))))
            ]
};

declare %private function qt:time($start-ns)
{
    concat(round((prof:current-ns() - $start-ns) div 1000) div 1000, 'ms')
};

(:~
 : Use the selectors which can be a string (path) or a selector
 : map that includes, excludes certain files.
 : By default it will just list all files in a specified path.
 :
 : map {
 :   'dir': 'foo/bar',
 :   'include': '*.xq?',
 :   'recurse': false()
 : }
 :)
(: TODO: maybe return the module/resource map :)
(: TODO: I would like to maintain the root directory :)
declare function qt:find-modules($paths as item()*)
{
    for $path in $paths
    return
        qt:resolve-module-selector(qt:module-selector($path))
};

declare function qt:module-selector($path as item())
{
    let $module-selector-defaults :=
        map {
            'include': '*.xq?',
            'recurse': false()
        }
    return
        typeswitch ($path)
        case map(*) return
            map:merge((
                $module-selector-defaults,
                $path
            ))
        case xs:string return
            map:merge((
                $module-selector-defaults,
                map:entry('dir', $path)
            ))
        default return
            ()
};

(: TODO: support multiple includes/excludes :)
declare function qt:resolve-module-selector($selector as map(*))
{
    if (file:exists($selector?dir)) then
        filter(
            file:list(
                $selector?dir, 
                ($selector?recurse,false())[1],
                ($selector?include,'*.*')[1]
            ) ! file:resolve-path(concat($selector?dir,'/',.)),
            file:is-file#1
        )   
    else
        ()
};

(:~
 : Load test modules and return a data structure with test functions embedded.
 :)
declare function qt:load-suite($paths as item()*)
{
    qt:load-suite($paths, map {})
};

declare function qt:load-suite($paths as item()*, $options as map(*))
{
    ['suite',
        map:merge((
            $qt:default-options, 
            $options
        )),
        qt:find-modules($paths) ! qt:load-module(., $options)    
    ]
};

(:~
 : Load a test module and return a data structure with test functions embeded.
 :)
(: inspect will take the last xqdoc comment from the function, not the one
 : preceding it!
 :)
(: TODO: maybe matching/filtering of tests? Can use standard techniques for this :)
(: TODO: provide a map of module loading options (e.g. to use comments or not?) :)
(: TODO: other annotations :)
declare function qt:load-module($module as xs:string)
{
    qt:load-module($module, map {})
};

declare function qt:load-module($module as xs:string, $options as map(*))
{
    (: TODO: derive module path from suite path :)
    let $options := map:merge(($qt:default-options, $options))
    return
        ['module',
            map { 
                'uri': $module,
                'name': tokenize($module, '/')[last()],
                'last-modified': file:last-modified($module),
                '@': function($n) {
                    let $results := o:children($n) ! o:apply(., o:attrs($n))
                    let $passed := count(o:filter($results, function($n) { o:tag($n) = 'pass' }))
                    let $skipped := count(o:filter($results, function($n) { o:tag($n) = 'skipped' }))
                    let $failed := count(o:filter($results, function($n) { o:tag($n) = 'fail' }))
                    let $errors := count(o:filter($results, function($n) { o:tag($n) = 'error' }))
                    return
                        array {
                            o:tag($n),
                            map:merge((
                                o:attrs($n),
                                map:entry('passed', $passed),
                                map:entry('skipped', $skipped),
                                map:entry('failed', $failed),
                                map:entry('errors', $errors)
                            )),
                            $results
                        }
                }
            },
            let $fns :=
                try {
                    inspect:module($module)/function
                } catch * {
                    ()
                }
            return
                qt:load-tests($fns, $options)
        ]
};

(:~
 : Filter sequence of function elements with test options.
 :
 : map {
 :   'annotation': 'unit:test',
 :   'exclude-annotation': 'unit:ignore'
 : }
 :)
(: TODO: only last xqdoc comment is put in description :)
(: TODO: handle expect :)
declare function qt:load-tests($fns as element(function)*, $options)
{
    for $fn in $fns
    let $test :=  
        map {
            'name': string($fn/@name),
            'uri': string($fn/@uri)
        }
    let $description :=
        if ($options?doc and $fn/description) then
            ['description', string($fn/description)]
        else    
            ()
    return
        if (some $name in $fn/annotation/@name satisfies $name = $options?exclude-annotation) then
            ['test',
                map:merge(($test, 
                    map:entry('active', false()),
                    map:entry('@', function($test, $module) {
                        let $attrs := o:attrs($test)
                        return
                            ['skipped',
                                map {
                                    'name': $attrs?name,
                                    'uri': $attrs?uri
                                }
                            ]
                    })
                )),
                $description
            ]
        else if (some $name in $fn/annotation/@name satisfies $name = $options?annotation) then
            ['test',
                map:merge(($test, 
                    map:entry('active', true()),
                    map:entry('@', function($test, $module) {
                        xquery:eval(qt:build-test-query(
                            $test => 
                            o:set-attr('module', $module?uri)
                        ),
                        o:select-keys($qt:default-options, $qt:eval-options))
                    })
                )),
                $description
            ]
        else
            ()
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
declare function qt:build-test-query($test as array(*))
as xs:string?
{
    let $attrs := o:attrs($test)
    where $attrs?active
    return
        let $import-check :=
            concat(
                'import module namespace qt = "',
                $qt:uri, '" at "', file:base-dir(), 'check.xqm', '";'
            )
        let $import-module :=
            if ($attrs?uri != $qt:uri) then
                concat(
                    'import module namespace test = "', $attrs?uri, 
                    '" at "', $attrs?module, '"; '
                )
            else
                ()
        return
            concat(
                $import-check,
                $import-module,
                'qt:run-test(', $attrs?name, '#0,[])')
};

declare %unit:test function qt:example-failing-unit-test()
{
    unit:assert-equals(3,4)
};

declare %unit:test function qt:example-passing-unit-test()
{
    unit:assert-equals(4,4)
};

(: ==================== Property-based tests ==================== :)

(:~
 : Basic concept: compose generator functions that produce argument lists for
 : each iteration. The argument list for each iteration is applied to the test 
 : function, each should return true, but an exception may be generated too.
 : The results can be returned in summary or as a large data-structure.
 : Reproducability is achieved by using and recording a seed so if we know the
 : seed we can re-run the tests.
 :)

declare variable $qt:uri := 'http://xokomola.com/xquery/check';

(: TODO: check if this is really the maximum/minimum for xs:integer? It should be unbounded :)
declare variable $qt:min-integer := -854775808;
declare variable $qt:max-integer := 854775808;
declare variable $qt:max-seq := 20;

declare variable $qt:iterations := 100;

(:~
 : Having some fun with the QuickCheck concept using generative
 : testing for XML.
 :
 : To avoid combinatorial explosion the results should be treated
 : as a search space with the possibility to "zoom" in problematic
 : siutations.
 :)

(:~
 : Build the argument arrays for function application.
 :)
 
(: TODO: how to keep seq identity / avoid flattening :)

declare function qt:gen-args($tests as item()*)
{
    if ($tests instance of array(*)) then
        switch (o:tag($tests))
        case 'qt:array' return 
            o:children($tests) ! [ qt:gen-args(.) ]
        case 'qt:seq' return
            o:children($tests) ! qt:gen-args(.)
        default return
            o:children($tests)
    else
        $tests
};

(:~
 : Use the generators to test a function.
 :)
declare function qt:check($check as function(*), $gen as item()*)
{
    qt:check($qt:iterations, $check, $gen)
};

declare function qt:check($iterations, $check, $gen)
{
    qt:check($iterations, $check, $gen, false())
};

declare function qt:check($iterations, $check, $gen, $include-tests as xs:boolean)
{
    let $seed := random:integer()
    let $tests := $gen($seed, $iterations)
    let $calls := [ qt:gen-args($tests) ]
    return
        ['qt:check',
            map {
                'num-tests': $iterations,
                'seed': $seed,
                'tests': if ($include-tests) then $tests else (),
                'result': 
                    every $result in (
                        for $args in $calls
                        let $result := 
                            try {
                                apply($check, $args)
                            } catch * {
                                'Error [' || $err:code || ']: ' || $err:description
                            }
                        return
                            $result = true()
                    ) satisfies true()
            }
        ]
};

(:~
 : An XML generator is a Mu data structure with handlers for elements
 : and attributes. These will be invoked when generating.
 : It is similar to Origami apply. The node handlers are the generators
 : that produce new nodes or atomic values.
 :)
declare function qt:generate-xml($schema)
{
1    
};

(:~
 : Return a random integers (implementation dependent)
 :)
declare function qt:integer()
{
    qt:integer($qt:min-integer,$qt:max-integer)
};

(:~
 : Return a random number between `$min` (inclusive) and `$max` (exclusive).
 :)
declare function qt:integer($min as xs:integer, $max as xs:integer)
{
    function($s,$i) {
        array {'qt:seq', 
            map { 
                'seed': $s, 
                'num': $i, 
                'max': $max, 
                'min': $min
            },
            for $integer in random:seeded-integer($s, $i, $max - $min)
            return
                xs:integer($integer + $min)
        }
    }
};

declare function qt:seq($gen as function(*))
{
    let $sizes := qt:integer(1,$qt:max-seq + 1)
    return
        function($s,$i) as array(*)* {
            array {
                'qt:seq',
                map { 
                    'seed': $s, 
                    'num': $i, 
                    'max': $qt:max-seq + 1
                },
                let $seeds := random:seeded-integer($s, $i, $qt:max-integer)
                for $size at $j in o:children($sizes($s,$i))
                return
                    $gen($seeds[$j],$size)
            }
        }
};

declare function qt:array($gen as function(*))
{
    let $sizes := qt:integer(1,$qt:max-seq + 1)
    return
        function($s,$i) as array(*)* {
            array {
                'qt:array',
                map { 
                    'seed': $s, 
                    'num': $i, 
                    'max': $qt:max-seq + 1
                },
                let $seeds := random:seeded-integer($s, $i, $qt:max-integer)
                for $size at $j in o:children($sizes($s,$i))
                return
                    $gen($seeds[$j],$size)
            }
        }
};

(: TODO: rerun failed tests :)
(: TODO: maybe collect timing as well :)
(: TODO: a HTML report (with live-page extension in Chrome 
   we can have a poor man's dash) :)
(: TODO: unit module also returns type info of expected and result :)
(: TODO: embed documentation so we can use this to generate on-line docs :)

(: An example test suite for generating test cases based on an existing Origami test suite :)

(: use an external XML file for test cases, then test round tripping :)
declare variable $qt:xml-cases as element(case)* := 
    doc(file:base-dir() || 'cases.xml')/*/case;

(: a) Import this suite and interactively run tests :)

(: TODO: we can embed stuff from the test case XML :)

declare function qt:check()
{
    ['check',
        for $case in $qt:xml-cases
        let $xml := $case/*
        let $fail := qt:equals(o:xml(o:doc($xml)), $xml)
        let $case-attrs := map { 'id': string($case/@id) }
        return
            if (exists($fail)) then
                $fail => 
                o:set-attrs($case-attrs)
            else
                ['pass', $case-attrs]
    ] => qt:report()
};

(: TODO: other reporters could group by module :)
declare function qt:report($results)
{
    let $tests := count(o:children($results))
    let $failed := count(o:filter(o:children($results), function($n) { o:tag($n) = 'fail' }))
    let $passed :=  $tests - $failed
    let $pass-rate := round(($passed div $tests) * 100) div 100
    return
        o:set-attrs(
            $results,
            map { 
                'tests': $tests,
                'pass-rate': $pass-rate,
                'passed': $passed,
                'failed': $failed 
            }
        )
};

declare function qt:equals($result,$expect)
{
    try {
        unit:assert-equals($result, $expect)
    } catch * {
        (: TODO: categorize fails/errors with $err:code :)
        ['fail',
            map {
                'code': $err:code,
                'module': $err:module,
                'line': $err:line-number, 
                'column': $err:column-number
            },
            ['desc', $err:description],
            ['result', $result],
            ['expect', $expect],
            ['value', $err:value]
        ]
    }
};

(: b) Use a test runner (which may use xquery eval to set up a test environment :)

(: c) Use it with the unit module by wrapping test runs in annotated unit test functions :)

(: TODO: when it is run like this the tests are executed but failures are not reported :)
