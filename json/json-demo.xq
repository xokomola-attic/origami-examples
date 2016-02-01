import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace json = 'http://xokomola.com/xquery/origami/examples'
    at 'json.xqm'; 

import module namespace t = 'http://xokomola.com/xquery/origami/examples/test/exi'
    at 'test-exi.xqm'; 

import module namespace j = 'https://www.w3.org/2015/EXI/json'
    at 'exi.xqm';
    
serialize(map { 'foo': function-lookup(xs:QName('xs:date'),1)('2016-01-01') }, map { 'method': 'json' })
  
(: example XML taken from http://www.w3.org/2011/10/integration-workshop/s/ExperienceswithJSONandXMLTransformations.v08.pdf :)
(: also see http://www.w3.org/TR/xslt-xquery-serialization-31/#json-output :)

(:
declare variable $local:xml :=
    <people>
        <actor name="Steve Martin" age="60"/>
        <person>
            <name>John Smith</name>
            <name>Foo Bar</name>
            <age>40</age>
        </person>
        <actor name="Jerry Seinfeld" age="56"/>
        <person>
            <name>Jane Foster</name>
            <age>43</age>
        </person>
    </people>;

(:~
 : This returns a Mu data structure which is easy to translate to JSON....
 :)
declare function local:to-doc($xml)
{
    o:doc($xml)
};

(:~
 : But doing this results in a JSON serialization error "Value has more than one item".
 :)
declare function local:to-json($xml)
{
    o:json(o:doc($xml))
};

serialize(json:to-json(json:xf(o:doc($local:xml))), map {'method': 'json'})
(: json:to-json(json:xf(o:doc($local:xml))) :)
(: o:xml(json:xf(o:doc($local:xml))) :)

(: local:to-json($local:xml) :)
:)