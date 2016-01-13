module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace qt = 'http://xokomola.com/xquery/origami/examples'
    at 'check.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(: TODO: rerun failed tests :)
(: TODO: maybe collect timing as well :)
(: TODO: a HTML report (with live-page extension in Chrome 
   we can have a poor man's dash) :)
(: TODO: unit module also returns type info of expected and result :)

(: An example test suite for generating test cases based on an existing Origami test suite :)

(: use an external XML file for test cases, then test round tripping :)
declare variable $ex:xml-cases as element(case)* := 
    doc(file:base-dir() || 'cases.xml')/*/case;

(: a) Import this suite and interactively run tests :)

(: TODO: we can embed stuff from the test case XML :)

declare function ex:check()
{
    ['check',
        for $case in $ex:xml-cases
        let $xml := $case/*
        let $fail := ex:equals(o:xml(o:doc($xml)), $xml)
        let $case-attrs := map { 'id': string($case/@id) }
        return
            if (exists($fail)) then
                $fail => 
                o:set-attrs($case-attrs)
            else
                ['pass', $case-attrs]
    ] => ex:report()
};

(: TODO: other reporters could group by module :)
declare function ex:report($results)
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

declare function ex:equals($result,$expect)
{
    try {
        unit:assert-equals($result, $expect)
    } catch * {
        (: TODO: categorize fails/errors with $err:code :)
        ['fail',
            map {
                'code': trace($err:code, 'XXX: '),
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

declare %unit:test function ex:test-xml() 
{
    ex:check()
};

declare %unit:test function ex:test-xml2() 
{
    for $case in $ex:xml-cases
    let $xml := $case/*
    return
        unit:assert-equals(o:xml(o:doc($xml)), $xml)
};
