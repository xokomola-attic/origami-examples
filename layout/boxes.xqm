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
as array(*)
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
    let $x := ($attrs?x,0)[1]
    let $y := ($attrs?y,0)[1]
    return
        array {
            $tag,
            $attrs,
            if ($child-count = 0) then
                ()
            else if ($tag = 'hbox') then
                let $child-widths := ex:collect-attribute($children,'width')
                let $advised-width := 
                    ($width - sum($child-widths)) 
                    div ($child-count - ex:count-values($child-widths))
                let $advice := ex:advise-values($child-widths, $advised-width)
                let $x := ex:sum-values($advice)
                for $child at $pos in $children
                return 
                    $child => o:set-attr(map {
                        'x': $x($pos),
                        'y': $y,
                        'height': (o:attrs($child)?height,$height)[1], 
                        'width': $advice($pos) 
                    })
            else
                let $child-heights := ex:collect-attribute($children,'height') 
                let $advised-height := 
                    ($height - sum($child-heights)) 
                    div ($child-count - ex:count-values($child-heights))
                let $advice := ex:advise-values($child-heights, $advised-height)
                let $y := ex:sum-values($advice)
                for $child at $pos in $children
                return
                    $child => o:set-attr(map {
                        'x': $x,
                        'y': $y($pos),
                        'height': $advice($pos), 
                        'width': (o:attrs($child)?width,$width)[1] 
                    })
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
    let $tag := o:tag($node)
    where $tag != 'spacer'
    return (
        array { 
            'rect', 
            map { 
                'x': o:attrs($node)?x, 
                'y': o:attrs($node)?y, 
                'width': o:attrs($node)?width,
                'height': o:attrs($node)?height,
                'fill': ex:random-color(),
                'fill-opacity': 0.8,
                'stroke-width': 1,
                'stroke': 'black',
                'stroke-opacity': 1
            }
        },
        o:children($node)
    )
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

declare function ex:mosaic($i,$j)
{
    let $cell-width := 100
    return
        ['vbox', map { 'width': $i * $cell-width, 'height': $j * $cell-width },
            for $row in 1 to $i
            return
                ['hbox',
                    for $col in 1 to $j
                    return
                        ['box']
                ]
        ]
};