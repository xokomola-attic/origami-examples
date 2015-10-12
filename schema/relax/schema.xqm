xquery version "3.1";

(: TODO: align schema functions with Relax names s:zeroOrMore etc. :)
(: TODO: merge with DT code :)
(: TODO: issue with schema fun ref in key of param entry :)
(: TODO: can we use same approach as Relax-NG with Schematron? :)
(: TODO: although schemas are data we have to take care about other funcs embedded :)
module namespace s = 'http://xokomola.com/ns/xml/validation/json/schema';

import module namespace μ = 'http://xokomola.com/xquery/origami/μ'
    at '../origami/mu.xqm';

declare function s:Error($msg)
{
    function ($e) { error(xs:QName('Error'), $msg, $e) }
};

declare function s:assert($cond, $x, $error)
{
    if ($cond) then $x else $error($x) 
};

(: TODO: I think this can be generalized one step further :)
declare function s:string($x) { s:assert($x instance of xs:string, $x, s:Error('String expected.')) };

declare function s:integer($x) { s:assert($x instance of xs:integer, $x, s:Error('Integer expected.')) };

(:~ 
 : This is a schema expressed as data. It can be compiled into a
 : Relax-NG schema that can be used when validating the JSON (serialized
 : as XML).
 :
 : These schemas are composable similar to how Relax-NG can be composed.
 :
 : Further exploration will tell if the is better than JSON-Schema or not.
 :
 : In this setup we do not use the fact that these functions can validate
 : atomic values. It would be interesting to see how we can create a validate
 : function that doesn't require Relax-NG (like Prismatic schema for Clojure).
 : 
 : If that is possible then we can also contemplate transforming JSON-Schema
 : into Relax-NG or provide a simple validation function.
 :
 : Also interesting to see if we can do coercion (cast as) and other
 : Schema driven transformations.
 :
 : Note that there is also a link with Demand Driven Architecture.
 :)
 
(: I can use both #1 or #0 as we currently only use the function name not it's arity :)
(: ISSUE: I think we gain nothing from having #0 functions :)

declare variable $s:example-schema :=
    map {
        'address': map {
            'streetAddress': s:string#1,
            'city': s:string#1
        },
        'phoneNumber': [
            map { 'location': s:string#1, 'code': s:integer#1 }
        ]
    };

declare function s:f($f)
{
    function($args) { apply($f,$args) }
};


(: DONE: fail with a runtime error :)
(: TODO: fail with an error object, to collect errors and only raise errors at top :)
(: TODO: not sure what s:check should do different from s:validate: a) validate return true/false and check returns object or nil? :)

(: s:check('1', s:string#1) :)
(: s:validate(["1","2","3"], [s:string#1]) now works :)
(: s:validate([map {'a': "1"}], [map { 'a': s:string#1}]) :)

(: TODO: check if all keys mentioned are present (required) :)
(: TODO: check if other keys allowed :)

declare function s:check($instance, $schema)
{    
    apply($schema, [$instance]) 
};

(: TODO: collect errors :)
(: TODO: the map constructor must be called only when the condition is true :)
(: TODO: also validate keys :)
declare function s:Map($x, $s as map(*)) { 
    s:assert(
        $x instance of map(*), 
        map:merge((
            map:for-each($x, 
                function($k,$v) { 
                    if (map:contains($s, $k))
                    then map:entry($k, s:walker(trace($v,'V: '), trace($s($k), 'S: '))) 
                    else s:Error(concat('Illegal key ', $k))($k)
                }
            )
        )), 
        s:Error('Map expected.')
    ) 
};

(: TODO: the map constructor must be called only when the condition is true :)
declare function s:Array($x, $s as array(*)) {
    s:assert(
        $x instance of array(*),
        array {
            for $item in $x?* 
            return s:walker($item, $s?*)
        },
        s:Error('Array expected.')
    ) 
};

declare function s:validate($data, $schema) { s:walker($data, $schema) };

(: provide the instance as data to a schema transformation function which consumes data from the instance :)
(: if it can be fully consumed it is valid, viewed like this it's a kind of templating. :)
(: @see https://github.com/Prismatic/schema/wiki/Writing-Custom-Transformations :)
(: TODO: make walker return a function which gets an instance :)

declare %private function s:walker($instance, $schema)
{ 
    for $schema-item at $i in $schema
    return
        typeswitch($schema-item)
        
        case map(*)
        return s:Map($instance[$i], $schema-item)
        
        case array(*)
        return s:Array($instance[$i], $schema-item)
        
        case function(*)
        return s:check($instance[$i], $schema-item)
        
        default
        return $instance[$i]
};

(:~
 : Generate an Relax-NG schema compatible with the BaseX json:parse
 : serialization. This is a proof of concept and other serializations
 : can be supported as well.
 :)
declare function s:schema($schema)
{
    ['s:grammar', map { 'datatypeLibrary': 'http://www.w3.org/2001/XMLSchema-datatypes' },
        ['s:start',
            ['s:element', map { 'name': 'json' },
                s:compile-schema($schema)
            ]
        ]
    ]
};

declare %private function s:compile-schema($schema)
{
    for $item in $schema
    return
        typeswitch ($item)
        
        case map(*)
        return 
            ['s:interleave',
                ['s:attribute', map { 'name': 'type' },
                    ['s:value', 'object']
                ],
                map:for-each($item,
                    function($k,$v) {
                        ['s:element', map { 'name': $k}, 
                            s:compile-schema($v)
                        ]
                    }
                )
            ]
            
        case array(*)
        return
            ['s:interleave', 
                ['s:attribute', map { 'name': 'type' },
                    ['s:value', 'array']
                ],
                ['s:zeroOrMore',
                    ['s:element', map { 'name': '_' },
                        for $it in $item?*
                        return s:compile-schema($it)
                    ]
                ]
            ]
        
        case function(*)
        return
            (: TODO: should do proper QName checking :)
            let $fn := string(function-name($item)) 
            return
                switch ($fn)
                case 's:integer'
                return
                    ['s:interleave',
                        ['s:attribute', map { 'name': 'type' },
                            ['s:value', 'number']
                        ],
                        ['s:data', map { 'type': 'integer' }]
                    ]

                case 's:string'
                return
                    ['s:text']
                    
                default
                return ()

        default
        return $item
};

(: TODO: needs to return same type as $form :)
declare function s:walk($inner, $outer, $form)
{
    $outer(
        fold-left(
            $form,
            (),
            function($x,$y) { ($x, $inner($y)) }
        )
    )
};
