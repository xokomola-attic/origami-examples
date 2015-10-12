xquery version "3.1";

(:~
 : Tests for μ-templates
 :
 : CSV test cases copied from CSVW (W3C) Test cases
 : @see https://github.com/w3c/csvw.git
 :)
module namespace test = 'http://xokomola.com/xquery/origami/tests';

import module namespace μ = 'http://xokomola.com/xquery/origami/μ' at '../mu.xqm'; 

declare function test:csv($name)
{
    concat('file://',file:base-dir(), 'csv/', $name)
};

declare function test:read($name)
{
    μ:parse-csv(μ:read-csv(test:csv($name)))
};

declare function test:read($name, $options)
{
    μ:parse-csv(μ:read-csv(test:csv($name), $options))
};

declare function test:parse($name)
{
    μ:parse-csv(unparsed-text(test:csv($name)))
};

declare %unit:test function test:read-csv() 
{
    let $csv := test:read('countries.csv')
    return (
        unit:assert-equals(μ:size($csv), 4)
    )
};

declare %unit:test function test:parse-csv() 
{
    let $csv := test:parse('countries.csv')
    return (
        unit:assert-equals(μ:size($csv), 4)
    )
};

declare %unit:test function test:xml() 
{
    let $csv := test:parse('countries.csv')
    let $xml := μ:xml($csv)
    return (
        unit:assert-equals(count($xml/μ:tr[1]/μ:td), 4)
    )
};

declare %unit:test function test:csv() 
{
    true()
};
