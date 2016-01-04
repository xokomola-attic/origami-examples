xquery version "3.1";

module namespace json = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(: demonstrate various ways of generating json using o:json function and a transformer :)
(: incorporate into o:json :)

(: TODO: handle mixed content :)
(: TODO: data types? :)

declare function json:xf($nodes as item()*)
{
    json:xf($nodes, ())
};

declare function json:xf($nodes as item()*, $wrap as xs:string?)
{
    $nodes ! (
        typeswitch (.)
        case array(*) return
            let $attrs := json:attrs-to-elements(o:attrs(.))
            let $children := o:children(.)
            let $element-children := o:filter($children, o:is-element#1)
            let $other-children := o:filter($children, o:is-text-node#1)
            return
                array {
                    ($wrap, o:tag(.))[1],
                    if (count($element-children) = count($children)) then
                        for $children in ($attrs, $element-children)
                        let $tag := o:tag($children)
                        group by $tag
                        return
                            if (count($children) > 1) then
                                array {
                                    $tag,
                                    map { 'type': 'array' },
                                    json:xf($children, '_')
                                }
                            else
                                json:xf($children)
                    else
                        (: mixed content :)
                        json:xf(($attrs, $children)) 
                }
        default return
            .
    )
};

declare %private function json:attrs-to-elements($attrs as map(*))
{
    for $name in map:keys($attrs)
    return
        [$name, data($attrs($name))]
};

declare function json:to-json($nodes as item()*)
{
    if (count(o:filter($nodes, o:is-element#1)) > 0) then
        if (o:tag($nodes[1]) = '_') then
            $nodes ! json:node(.)
        else
            map:merge((
                $nodes ! json:node(.)                
            ))
    else
        $nodes ! json:node(.)
};

declare %private function json:node($node as item())
{
    typeswitch ($node)
    case array(*) return
        let $tag := o:tag($node)
        let $type := o:attrs($node)?type
        let $children := o:children($node)
        return
            if ($type = 'array') then
                map:entry($tag, array { json:to-json($children) })
            else if ($tag = '_') then
                json:to-json($children)
            else
                map:entry($tag, json:to-json($children))
    default return
        $node
};
