xquery version "3.1";

(:~
 : Origami-data α
 :
 : JSON-LD for XML.
 :
 : @see /Users/marcvangrootel/Dropbox/projects/basex-json-validation/basex/webapp
 :)

module namespace γ = 'http://xokomola.com/xquery/origami/γ';

import module namespace μ = 'http://xokomola.com/xquery/origami/μ'
    at '../origami/mu.xqm';

declare function γ:String($x) { $x instance of xs:string };

declare function γ:Integer($x) { $x instance of xs:integer };

declare function γ:Key($x) { $x instance of xs:string };

declare function γ:Double($x) { $x instance of xs:double };

declare function γ:validate($data, $schema)
{
    1
};


declare function γ:schema($schema)
{
    for $item in $schema
    return
        typeswitch ($item)
        
        case map(*)
        return 
            ['γ:map', 
                map:for-each($item,
                    function($k,$v) {
                        [$k, γ:schema($v)]
                    }
                )
            ]
            
        case array(*)
        return
            ['γ:array',
                for $it in $item?*
                return γ:schema($it)
            ]
        
        case function(*)
        return
            [string(function-name($item))]
            
        default
        return $item
};

(:
declare function γ:json($mu as item()*)
{
    γ:json('compact', $mu)
};

declare function γ:json($form as xs:string,$mu as item()*)
{
        γ:maybe-array(
            γ:to-json($mu, function($name) { $name })
        )
};

declare function γ:atts-to-elements($atts as map(*))
{
    map:for-each($atts, 
        function($k,$v) {
            switch($k)
            case '@iri' return $v
            case '@term' return $v
            default return [$k, $v] 
        }
    )    
};

declare function γ:text-nodes($map)
{
    if ($map instance of map(*)) then
        $map('&amp;')
    else
        $map
};

declare function γ:to-json($mu as item()*, $name-resolver as function(*))
as item()*
{
    for $item in $mu
    let $name := μ:element($item)
    let $children := (γ:atts-to-elements(μ:attributes($item)), μ:children($item))
    return 
        if ($name = '@') then
            map:merge(γ:process-children($children, $name-resolver))
        else
            map:entry($name, γ:process-children($children, $name-resolver))           
};

declare function γ:process-children($children, $name-resolver)
{
            let $children := γ:collect-keys($children)
            return
                if (map:contains($children, '@language') and map:contains($children, '&amp;')) then
                    map:merge((map:remove($children,'&amp;'), map:entry('@value', $children('&amp;'))))
                else if (map:contains($children, '&amp;')) then
                    if (map:size($children) eq 1) then
                        γ:maybe-array($children('&amp;')) 
                    else
                        γ:maybe-array(($children('&amp;'), map:remove($children,'&amp;')))
                else
                    map:merge((
                        map:for-each($children,
                            function($k, $v) {
                                if (count($v) eq 0) then
                                    map:entry($k, ())
                                else
                                    γ:to-json([$k, $v], $name-resolver)
                            }
                        )
                    ))
};

declare function γ:maybe-array($items as item()*)
{
    if (count($items) gt 1) then
        array { $items }
    else
        $items
};

declare function γ:collect-keys($mu as item()*)
as map(*)
{
    fold-left($mu, map {},
        function($kmap, $item) {
            typeswitch ($item)
            case array(*)
            return
                let $name := μ:element($item)
                let $atts := μ:attributes($item)
                let $children := (γ:atts-to-elements($atts), μ:children($item))
                let $collected-children := $kmap($name)
                return
                    map:merge((
                        $kmap,
                        map:entry(
                            $name,
                            (
                                $collected-children,
                                $children
                            )
                        )
                    ))
            case map(*)
            return error(μ:ZombieMap, 
                        'A standalone map is not a valid μ-node')
            default
            return map:merge(($kmap, map:entry('&amp;', ($kmap('&amp;'), $item))))
        })
};

declare function γ:map-union($maps as map(*)*)
{
    map:merge(
        for $key in distinct-values($maps ! map:keys(.))
        return map { $key: ($maps ! .($key)) }
    )
};

(: Experimental sugar for map {'iri': ... } :)
declare function γ:iri($iri) as map(*)
{
    map {'@iri': string($iri) }
};

(: Experimental sugar for map {'@id': ... } :)
declare function γ:id($id) as map(*)
{
    map {'@id': string($id) }
};

(: Experimental sugar for map {'@id': ...,'@type': ... } :)
declare function γ:id($id,$type) as map(*)
{
    map {'@id': string($id), '@type': $type }
};

:)
