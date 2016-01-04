xquery version "3.1";

module namespace sql = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare variable $sql:ns := 'http://xokomola.com/xquery/origami/examples';

(: TODO: add o:text-children($node), o:element-children($node) or other kind of node type filter :)

declare function sql:text-nodes($node)
{
    o:filter(o:children($node), o:is-text-node#1)
};

declare function sql:elements($node)
{
    o:filter(o:children($node), o:is-element#1)
};

declare function sql:query($mu)
{
    string-join($mu ! o:attrs(o:postwalk(.,sql:to-sql#1))?sql, ' ')
};

declare %private function sql:to-sql($node as array(*))
{
    let $attrs := o:attrs($node)
    let $sql := $attrs?sql
    let $tag := trace(o:tag($node), 'TAG: ')
    let $children := o:children($node)
    let $fn := function-lookup(QName($sql:ns, $tag), 1)
    return
        if (exists($fn)) then
            array {
                $tag,
                map:merge((
                    $attrs,
                    map:entry('sql', $fn($node))
                )),
                $children
            }
        else
            error(QName($sql:ns, 'sql-error'),'No function found for &quot;' || $tag || '&quot;', $node)
};

declare function sql:child-nodes($node)
{
    o:map(sql:elements($node), function($n) { o:attrs($n)?sql })
};

declare function sql:select($node)
{
    ('SELECT', string-join(sql:text-nodes($node), ' '))
};

declare function sql:from($node)
{
    ('FROM', string-join(sql:text-nodes($node), ' '))
};

declare function sql:where($node)
{
    ('WHERE', string-join(sql:text-nodes($node), ' '))
};

declare function sql:order($node)
{
    ('ORDER BY', string-join(sql:text-nodes($node), ' '))
};

declare function sql:limit($node)
{
    ('LIMIT', string-join(sql:text-nodes($node), ' '))
};

declare function sql:offset($node)
{
    ('OFFSET', string-join(sql:text-nodes($node), ' '))
};