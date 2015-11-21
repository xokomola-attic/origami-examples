xquery version "3.1";

(: http://limpet.net/mbrubeck/2014/09/08/toy-layout-engine-5-boxes.html :)
(: https://github.com/tel/frame :)
(: https://github.com/tel/frame/blob/master/src/frame/fstate.clj :)

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

declare function ex:layout-children($node)
{
    array {
        o:tag($node),
        o:attributes($node),
        let $children := o:children($node)
        let $attrs := o:attrs($node)
        let $height := $attrs?height
        let $width := $attrs?width
        let $child-count := count($children)
        let $child-explicit-height := o:map($children, function($n) { xs:integer(o:attrs($n)?height) })
        let $advised-height := 
            ($height - sum($child-explicit-height)) 
            div ($child-count - count($child-explicit-height))
        for $child at $pos in $children
        return
            ex:advise-dimensions($child, $width, $advised-height)
    }
};

declare function ex:layout($mu)
{
    o:prewalk($mu, ex:layout-children#1)
};