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

declare function ex:layout-node-children($node)
{
    let $tag := o:tag($node)
    let $attrs := o:attrs($node)
    let $children := o:children($node)
    let $child-count := count($children)
    return
        array {
            $tag,
            $attrs,
            if ($tag = 'hbox') then
                let $child-explicit-width := 
                    o:map($children, function($n) { o:attrs($n)?width })
                let $advised-width := 
                    ($attrs?width - sum($child-explicit-width)) 
                    div ($child-count - count($child-explicit-width))
                for $child in $children
                return
                    ex:advise-dimensions($child, $advised-width, $attrs?height)
            else
                let $child-explicit-height := 
                    o:map($children, function($n) { o:attrs($n)?height })
                let $advised-height := 
                    ($attrs?height - sum($child-explicit-height)) 
                    div ($child-count - count($child-explicit-height))
                for $child in $children
                return
                    ex:advise-dimensions($child, $attrs?width, $advised-height)
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