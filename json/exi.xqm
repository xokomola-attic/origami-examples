xquery version '3.1';

module namespace j = 'https://www.w3.org/2015/EXI/json';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(: TODO: BUG in o:xml - o:xml(..., nsmap) :)
(: TODO: re-evaluate how to treat prefixes in o:doc() :)
(: TODO: have a look at Transit (and EDN)
   https://github.com/cognitect/transit-format
   http://swannodette.github.io/2014/07/26/transit--clojurescript/
 :)

(:~
 : Support for JSON / XDM values to EXI and back.
 :
 : First use parse-json to transform a JSON string into an XDM value.
 : Then convert it to Mu nodes using `j:from-xdm`. Finally use `o:xml`
 : to serialize the Mu nodes to XML.
 :
 : Why?
 :
 : Transforming JSON using XSLT, storing it in an XML database.
 :
 : @see http://www.w3.org/TR/exi-for-json/
 : @see http://www.w3.org/TR/exi/
 :)

declare function j:xml($mu as array(*))
{
    o:xml(
        $mu, 
        map { 
            '': 'https://www.w3.org/2015/EXI/json'
            (: 'o': 'http://xokomola.com/xquery/origami' :)
        })
};

(:~
 : Transforming from JSON to EXI
 :
 : > A JSON value is an object, array, number, or string, or one of the 
 : > following three literal names: true false null.
 :)
declare function j:doc($xdm as item())
as array(*)?
{
    j:doc($xdm, map {})
};

declare function j:doc($xdm as item()?, $options as map(*))
as array(*)?
{
    j:from-xdm($xdm, $options)
};

declare function j:xdm($exi as item())
as item()?
{
    if ($exi instance of element()) then
        j:to-xdm($exi)
    else
        j:to-xdm($exi)
};

declare %private function j:from-xdm($xdm as item()?, $options as map(*))
{
    j:from-xdm($xdm, (), j:options($options))
};

declare %private function j:from-xdm($xdm as item()?, $key as xs:string?, $options as map(*))
as item()*
{
    let $attrs :=
        if (exists($key) or $options('type-info') = true()) then
            map:merge((
                if (exists($key)) then map:entry('key',$key) else (),
                if ($options('type-info') = true() and $xdm instance of xs:anyAtomicType) then
                    map:entry('type', j:atomic-type($xdm)) 
                else 
                    ()
            ))
        else
            ()
    let $atomic-type := j:atomic-type($xdm)
    let $add-type-info := $options('type-info') = true()
    return
        typeswitch ($xdm)
        case array(*) return
            array { 'array', $attrs,
                array:for-each(
                    $xdm,
                    function($i) { j:from-xdm($i, (), $options) }
                )?*
            }
        case map(*) return
            array { 'map', $attrs,
                map:for-each(
                    $xdm,
                    function($k,$v) { j:from-xdm($v,$k, $options) }
                )
            }
        case xs:string return
            array { 'string', $attrs, string($xdm) }
        case xs:double return
            array { 'number', $attrs, $xdm }
        case xs:integer return
            (: alternatively ['other', ['integer', $n]] :)
            array { 'number', $attrs, $xdm }
        case xs:decimal return
            (: alternatively ['other', ['decimal', $n]] :)
            array { 'number', $attrs, $xdm }
        case xs:boolean return
            array { 'boolean', $attrs, if ($xdm) then true() else false() }
        case empty-sequence() return
            array { 'null', $attrs }
        default return
            array { 'other', $attrs, $xdm }
};

declare %private function j:options($options as map(*))
as map(*)
{
    map:merge((
        map:entry('strict', true()),
        map:entry('type-info', false()),
        $options
    ))
};

(:~ @see https://www.w3.org/TR/xpath-functions-31 :)

declare function j:atomic-type($item as xs:anyAtomicType)
as xs:QName?
{
    typeswitch ($item)
    
    case xs:ENTITY return xs:QName('xs:ENTITY')
    case xs:IDREF return xs:QName('xs:IDREF')
    case xs:ID return xs:QName('xs:ID')
    case xs:NCName return xs:QName('xs:NCName')
    (: case xs:name return 'xs:name' :)
    case xs:NMTOKEN return xs:QName('xs:NMTOKEN')
    case xs:language return xs:QName('xs:language')
    case xs:token return xs:QName('xs:token')
    case xs:normalizedString return xs:QName('xs:normalizedString')
    case xs:string return xs:QName('xs:string')
    (: case xs:dateTimeStamp return 'xs:dateTimeStamp' :)
    case xs:dateTime return xs:QName('xs:dateTime')
    case xs:date return xs:QName('xs:date')
    case xs:yearMonthDuration return xs:QName('xs:yearMonthDuration')
    case xs:dayTimeDuration return xs:QName('xs:dayTimeDuration')
    case xs:duration return xs:QName('xs:duration')
    case xs:positiveInteger return xs:QName('xs:positiveInteger')
    case xs:unsignedByte return xs:QName('xs:unsignedByte')
    case xs:unsignedShort return xs:QName('xs:unsignedShort')
    case xs:unsignedInt return xs:QName('xs:unsignedInt')
    case xs:unsignedLong return xs:QName('xs:unsignedLong')
    case xs:nonNegativeInteger return xs:QName('xs:nonNegativeInteger')
    case xs:byte return xs:QName('xs:byte')
    case xs:short return xs:QName('xs:short')
    case xs:int return xs:QName('xs:int')
    case xs:long return xs:QName('xs:long')
    case xs:negativeInteger return xs:QName('xs:negativeInteger')
    case xs:nonPositiveInteger return xs:QName('xs:nonPositiveInteger')  
    case xs:integer return xs:QName('xs:integer')
    case xs:decimal return xs:QName('xs:decimal')
    (: case xs:NOTATION return xs:NOTATION :)
    case xs:QName return xs:QName('xs:QName')
    case xs:anyURI return xs:QName('xs:anyURI')
    case xs:hexBinary return xs:QName('xs:hexBinary')
    case xs:base64Binary return xs:QName('xs:base64Binary')
    case xs:boolean return xs:QName('xs:boolean')
    case xs:gDay return xs:QName('xs:gDay')
    case xs:gMonth return xs:QName('xs:gMonth')
    case xs:gMonthDay return xs:QName('xs:gMonthDay')
    case xs:gYear return xs:QName('xs:gYear')
    case xs:gYearMonth return xs:QName('xs:gYearMonth')
    case xs:double return xs:QName('xs:double')
    case xs:float return xs:QName('xs:float')
    case xs:time return xs:QName('xs:time')
    (: <foo/> also returns xs:untypedAtomic :)
    case xs:untypedAtomic return xs:QName('xs:untypedAtomic')
    case xs:anyAtomicType return xs:QName('xs:anyAtomicType')
    default return ()   
};

(:~
 : Transforming from EXI to JSON
 :
 : > The EXI for JSON stream has the following information items: j:map, 
 : > j:array , j:string , j:number , j:boolean , j:null , or j:other.
 :)
declare %private function j:to-xdm($exi as element())
{
    let $value :=
        typeswitch ($exi)
        case element(j:array) return
            fold-left(
                $exi/*,
                [],
                function($arr,$item) { array:append($arr,j:to-xdm($item)) }
            )
        case element(j:map) return
            map:merge(
                for $item in $exi/*
                return
                    j:to-xdm($item)
            )
        case element(j:string) return
            string($exi)
        case element(j:number) return
            let $v := string($exi)
            return
                if ($v castable as xs:integer) then
                    xs:integer($v)
                else
                    xs:double($v)
        case element(j:boolean) return
            xs:boolean(string($exi))
        case element(j:null) return
            ()
        case element(j:other) return
            string($exi)
        default return ()
    let $value :=
        if ($exi/@type and $value instance of xs:anyAtomicType) then
            function-lookup(xs:QName($exi/@type),1)($value)
        else
            $value
    return
        if ($exi/@key) then
            map:entry(string($exi/@key), $value)
        else
            $value
        
};
