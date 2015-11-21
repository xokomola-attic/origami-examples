xquery version "3.1";

(: http://limpet.net/mbrubeck/2014/09/08/toy-layout-engine-5-boxes.html :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare function ex:report($node)
{
    let $report := trace(o:tag($node), 'TAG: ')
    return
        $node
};

declare function ex:layout-node($node, $container)
{
    let $c-attrs := o:attrs($container)
    let $c-height := $c-attrs?height
    let $c-width := $c-attrs?width
    let $attrs := o:attrs($node)
    let $height := ($attrs?height, $c-height)[1]
    let $width := ($attrs?width, $c-width)[1]
    return
        array { 
            o:tag($node), 
            map { 'height': $height, 'width': $width }, 
            o:children($node)
        }
};

declare function ex:layout-children($node)
{
    let $node-fn := ex:layout-node(?,$node)
    return
        $node => o:insert(o:map(o:children($node), $node-fn))
};

declare function ex:layout($mu)
{
    o:prewalk($mu, ex:layout-children#1)
};