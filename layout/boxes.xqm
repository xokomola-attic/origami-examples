xquery version "3.1";

(: http://limpet.net/mbrubeck/2014/09/08/toy-layout-engine-5-boxes.html :)
(: https://github.com/tel/frame :)
(: https://github.com/tel/frame/blob/master/src/frame/fstate.clj :)
(: http://www.ibm.com/developerworks/library/j-treevisit/ :)
(: https://github.com/akhudek/zip-visit :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare function ex:report($node)
{
    let $report := trace(o:tag($node), 'TAG: ')
    return
        $node
};

declare function ex:advise-dimensions($node, $width, $height)
{
    array {
        o:tag($node),
        map:merge((
            map { 
                'width': $width,
                'height': $height
            },
            o:attrs($node)
        )),
        o:children($node)
    }
};

declare function ex:collect-attribute($nodes, $attribute)
{
    fold-left(
        $nodes,
        [],
        function($result,$item) {
            array:append($result,o:attrs($item)($attribute))
        }
    )
};

declare function ex:count-attribute($nodes, $attribute)
as xs:integer
{
    sum(
        for $node in $nodes
        where o:attrs($node)($attribute)
        return 1
    )
};

declare function ex:layout-node-children($node)
{
    let $tag := o:tag($node)
    let $attrs := o:attrs($node)
    let $children := o:children($node)
    let $child-count := count($children)
    let $width := $attrs?width
    let $height := $attrs?height
    return
        array {
            $tag,
            $attrs,
            if ($tag = 'hbox') then
                let $child-widths := ex:collect-attribute($children,'width')
                let $advised-width := 
                    ($width - sum($child-widths)) 
                    div ($child-count - ex:count-attribute($children,'width'))
                for $child in $children
                return
                    ex:advise-dimensions($child, $advised-width, $height)
            else
                let $child-heights := ex:collect-attribute($children,'height') 
                let $advised-height := 
                    ($height - sum($child-heights)) 
                    div ($child-count - ex:count-attribute($children,'height'))
                for $child in $children
                return
                    ex:advise-dimensions($child, $width, $advised-height)
        }
};

declare function ex:layout-node($node)
{
    let $tag := o:tag($node)
    let $attrs := o:attrs($node)
    let $children := o:children($node)
    let $height := 40
    let $width := 100
    return
        if (count($children) = 0) then
            ex:advise-dimensions($node,
                $width,
                $height
            )        
        else if ($tag = 'hbox') then
            ex:advise-dimensions($node,
                sum(o:map($children, function($n) { o:attrs($n)?width })),
                max(o:map($children, function($n) { o:attrs($n)?height }))
            )
        else
            ex:advise-dimensions($node,
                max(o:map($children, function($n) { o:attrs($n)?width })),
                sum(o:map($children, function($n) { o:attrs($n)?height }))
            )
};
declare function ex:layout-top-down($mu)
{
    o:prewalk($mu, ex:layout-node-children#1)
};

declare function ex:layout-bottom-up($mu)
{
    o:postwalk($mu, ex:layout-node#1)
};

declare function ex:render-svg-node($node)
{
    array { 
        'rect', 
        map { 'x': 0, 'y': 0, 
            'width': o:attrs($node)?width,
            'height': o:attrs($node)?height,
            'fill': ex:random-color(),
            'fill-opacity': 0.5,
            'stroke-width': 1,
            'stroke': 'black',
            'stroke-opacity': 1
        }
    },
    o:children($node)
};

declare function ex:random-color()
{
    concat(
        'rgb(',
        random:integer(255), ',',
        random:integer(255), ',',
        random:integer(255),
        ')'
    )
};

declare function ex:svg-builder()
{
    o:default-ns-builder(
        'http://www.w3.org/2000/svg'
    )
};

declare function ex:svg($mu)
{
    ['svg', o:postwalk($mu, ex:render-svg-node#1)]    
};
