module namespace api = 'http://theapsgroup.com/socialnetworker/json/schema';

import module namespace rest = 'http://exquery.org/ns/restxq';
import module namespace μ = 'http://xokomola.com/xquery/origami/μ' at 'origami/mu.xqm';
import module namespace ex = 'http://xokomola.com/ns/xml/validation/json/ex' at 'examples/examples.xqm';
import module namespace s = 'http://xokomola.com/ns/xml/validation/json/schema' at 'examples/schema.xqm';

declare variable $api:schema := μ:xml(s:schema($s:example-schema));
declare variable $api:validator := ex:validator($api:schema);
declare variable $api:example-schema := 
    "    
    map {
        'address': map {
            'streetAddress': s:string#1,
            'city': s:string#1
        },
        'phoneNumber': [
            map { 'location': s:string#1, 'code': s:integer#1 }
        ]
    };
    ";

declare %rest:GET %rest:path("/")
function api:doc()
{ 
    μ:xml(
        ['h:html', 
            ['h:body', 
                ['h:h1', 'JSON validation three ways'],
                ['h:p', '1) With a manually written Relax-NG (compact) schema, 2) with an
                automatically generated Relax-NG schema based on a simple schema language and, finally, 3)
                directly validating parsed JSON datastructures using a simple schema language [TODO]. 
                For the first 
                two the JSON has to be serialized into XML before validation. In the third way it can be
                validated directly on the parsed JSON (maps and arrays). All this in an attempt to show that
                a) XML has mature and capable validation technology suitable for validating JSON, b) showing a 
                different approach made possible with XQuery 3.1 for validating data structures. In a future 
                project we can compose all these forms and switch validation technology on the fly within the
                same μ-document.'],
                ['h:ul', (
                    api:link('JSON Example','/json'),
                    api:link('JSON Parsed into XML','/json-xml'),
                    api:link('1) JSON Validate with Relax', '/json-validate'),
                    api:link('2) JSON Validate with generated grammar', '/json-grammar'),
                    api:link('3) JSON Validate with validation function', '/json-schema')
                )]
            ]
        ])
};

declare %rest:GET %rest:path("/json")
function api:json-example()
{ 
    μ:xml(
        ['h:html', 
            ['h:body', 
                ['h:h1', 'JSON Example'],
                ['h:pre', serialize(file:read-text(concat(file:base-dir(), 'examples/schema-net-address.json')))]
            ]
        ])
};

declare %rest:GET %rest:path("/json-xml")
function api:json-xml-example()
{ 
    μ:xml(
        ['h:html', 
            ['h:body', 
                ['h:h1', 'JSON Example (XML)'],
                ['h:pre', serialize(ex:to-xml('schema-net-address.json'))]
            ]
        ])
};

declare %rest:GET %rest:path("/json-validate")
function api:json-validate-example()
{ 
    μ:xml(
        ['h:html', 
            ['h:body', 
                ['h:h1', 'JSON Schema'],
                let $result := (
                    prof:current-ns(),
                    ex:validate('schema-net-address.json', 'schema-net-address.rnc'),
                    prof:current-ns())
                return (
                    ['h:pre', $result[2] ],
                    ['h:p', (($result[3] - $result[1]) idiv 1000) div 1000, ' ms']
                ),
                ['h:hr'],
                ['h:pre', serialize(ex:to-xml('schema-net-address.json'))],
                ['h:hr'],
                ['h:pre', file:read-text(concat(file:base-dir(), 'examples/schema-net-address.rnc'))]
                
            ]
        ])
};

(:~ Runs the same validation but now with a generated schema :)
declare %rest:GET %rest:path("/json-grammar")
function api:json-grammar-example()
{ 
    μ:xml(
        ['h:html', 
            ['h:body', 
                ['h:h1', 'JSON Grammar'],
                let $result := (
                    prof:current-ns(),
                    $api:validator('schema-net-address.json'),
                    prof:current-ns())
                return (
                    ['h:pre', $result[2] ],
                    ['h:p', (($result[3] - $result[1]) idiv 1000) div 1000, ' ms']
                ),
                ['h:hr'],
                ['h:pre', serialize(ex:to-xml('schema-net-address.json'))],
                ['h:hr'],
                ['h:pre', $api:example-schema],
                ['h:hr'],
                ['h:pre', serialize($api:schema)]
            ]
        ])
};

(:~ Runs the same validation but now with a generated schema :)
declare %rest:GET %rest:path("/json-schema")
function api:json-schema-example()
{ 
    μ:xml(
        ['h:html', 
            ['h:body', 
                ['h:h1', 'JSON Validation function'],
                let $result := (
                    prof:current-ns(),
                    'TODO',
                    prof:current-ns())
                return (
                    ['h:pre', $result[2] ],
                    ['h:p', (($result[3] - $result[1]) idiv 1000) div 1000, ' ms']
                ),
                ['h:hr'],
                ['h:pre', $api:example-schema],
                ['h:hr'],
                ['h:pre', serialize(file:read-text(concat(file:base-dir(), 'examples/schema-net-address.json')))]
            ]
        ])
};

declare %private function api:link($text, $url)
{
    ['h:li', ['h:a', map { 'href': $url }, $text]]
};
 
