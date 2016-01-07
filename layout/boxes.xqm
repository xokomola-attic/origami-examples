xquery version "3.1";

(: TODO: handle svg:text :)
(: TODO: compose/collage SVG :)

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
as array(*)
{
    array {
        o:tag($node),
        o:advise-attrs($node, map { 
            'width': $width,
            'height': $height
        }),
        o:children($node)
    }
};

declare function ex:collect-attribute($nodes, $attribute as xs:string)
as array(*)
{
    fold-left(
        $nodes,
        [],
        function($result,$item) {
            array:append($result,o:attrs($item)($attribute))
        }
    )
};

declare function ex:count-values($values as array(*))
as xs:integer
{
    count($values?*)
};

declare function ex:sum-values($values as array(*))
{
    let $values := $values?*
    return
        array {
            fold-left($values,(0),
                function($result,$item) {
                    ($result, sum($result[last()] + $item))
                }
            )
        }
};

declare function ex:advise-values($a,$b)
{
    let $b :=
        if ($b instance of array(*)) then 
            $b
        else
            array { for $i in 1 to array:size($a) return $b }
    return
        array:for-each-pair($a,$b, function($a,$b) { ($a,$b)[1] })
};

declare function ex:layout-node-children($node)
{
    let $tag := o:tag($node)
    let $attrs := o:attrs($node)
    let $children := o:children($node)
    let $child-count := count($children)
    let $width := $attrs?width
    let $height := $attrs?height
    let $x := ($attrs?x, 0)[1]
    let $y := ($attrs?y, 0)[1]
    return
        if (starts-with($tag,'svg:')) then
            $node
        else
            array {
                $tag,
                $attrs,
                if ($child-count = 0) then
                    ()
                else if (every $node in o:filter($children, o:is-element#1) 
                            satisfies o:tag($node) = 'layer') then
                    fold-left(
                        $children,
                        (),
                        function($result, $child) {
                            ($result, $child => o:set-attrs(map {
                                'x': $x,
                                'y': $y,
                                'height': $height, 
                                'width': $width 
                            }))                    
                        }
                    )
                else if ($tag = 'hbox') then
                    let $child-widths := ex:collect-attribute($children,'width')
                    let $advised-width := 
                        ($width - sum($child-widths)) 
                        div ($child-count - ex:count-values($child-widths))
                    let $advice := ex:advise-values($child-widths, $advised-width)
                    let $x := ex:sum-values($advice)
                    return
                        fold-left(
                            $children,
                            (),
                            function($result, $child) {
                                let $pos := count($result) + 1
                                return
                                    ($result, $child => o:set-attrs(map {
                                        'x': $x($pos),
                                        'y': $y,
                                        'height': (o:attrs($child)?height,$height)[1], 
                                        'width': $advice($pos) 
                                    }))
                            }
                        )
                else
                    let $child-heights := ex:collect-attribute($children,'height') 
                    let $advised-height := 
                        ($height - sum($child-heights)) 
                        div ($child-count - ex:count-values($child-heights))
                    let $advice := ex:advise-values($child-heights, $advised-height)
                    let $y := ex:sum-values($advice)
                    return
                        fold-left(
                            $children,
                            (),
                            function($result, $child) {
                                let $pos := count($result) + 1
                                return
                                    ($result, $child => o:set-attrs(map {
                                        'x': $x,
                                        'y': $y($pos),
                                        'height': $advice($pos), 
                                        'width': (o:attrs($child)?width,$width)[1] 
                                    }))
                            }
                        )
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
                sum(o:for-each($children, function($n) { o:attrs($n)?width })),
                max(o:for-each($children, function($n) { o:attrs($n)?height }))
            )
        else
            ex:advise-dimensions($node,
                max(o:for-each($children, function($n) { o:attrs($n)?width })),
                sum(o:for-each($children, function($n) { o:attrs($n)?height }))
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
    let $tag := o:tag($node)
    let $attrs := o:attrs($node)
    let $children := o:children($node)
    where $tag != 'spacer'
    return (
        if (starts-with($tag,'svg:')) then
            array { substring-after($tag,'svg:'), $attrs, $children }
        else if ($tag != 'layer') then
            (
                array { 'rect',
                    $node =>
                    o:advise-attrs(map { 
                            'fill': ex:rgb(),
                            'fill-opacity': 0.6,
                            'stroke-width': 1,
                            'stroke': 'black',
                            'stroke-opacity': 1
                    }) =>
                    o:remove-attr('layers') =>
                    o:attrs()
                },
                $children
            )
        else
            array { 'g',
                $attrs?id,
                $children
            }
    )
};

declare function ex:rgb()
{
    'rgb(' || string-join((1 to 3) ! random:integer(255), ',') || ')'
};

(: TODO: maybe instead use o:transformer :)

declare function ex:svg-builder()
{
    o:ns-builder((
        ['v', 'http://xokomola.com/xquery/collage'],
        ['svg', 'http://www.w3.org/2000/svg'],
        ['', 'http://www.w3.org/2000/svg']
    ))
};

declare function ex:svg($mu)
{
    let $layers := tokenize(o:attrs($mu)?layers,'\s+')
    return
        ['svg',
            o:sort(
                o:postwalk($mu, ex:render-svg-node#1),
                function($node) {
                    if (o:tag($node) = 'g') then
                        index-of($layers, (o:attrs($node)?id,-10)[1])
                    else
                        -10
                }
            )
        ]    
};

(:~
 : Generate an $i x $j grid with random colors.
 :)
declare function ex:mosaic($i,$j)
{
    let $cell-width := 100
    return
        ['vbox', 
            map { 'width': $i * $cell-width, 'height': $j * $cell-width },
            for $row in 1 to $i
            return
                ['hbox',
                    for $col in 1 to $j
                    return
                        ['box']
                ]
        ]
};