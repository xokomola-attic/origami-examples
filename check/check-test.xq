module namespace test = 'http://xokomola.com/xquery/origami/tests';

import module namespace qt = 'http://xokomola.com/xquery/check'
    at 'check.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare %unit:test function test:check() 
{
    qt:check()
};

declare %unit:test function test:xml() 
{
    for $case in $ex:xml-cases
    let $xml := $case/*
    return
        unit:assert-equals(o:xml(o:doc($xml)), $xml)
};
