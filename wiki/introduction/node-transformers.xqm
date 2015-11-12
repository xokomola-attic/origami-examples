xquery version "3.1";

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare function local:map-do()
{
    let $nodes := (['x'],['y'],['z'])
    return
        o:map($nodes, 
            o:do((
                o:insert('foo'),
                o:insert-after('bar'),
                o:set-attr(map { 'class': 'yo' }),
                o:wrap(['p']))))  
};

declare function local:map-do2()
{
    let $nodes := (['x'],['y'],['z'])
    return
      $nodes ! o:do((
                o:insert('foo'),
                o:insert-after('bar'),
                o:set-attr(map { 'class': 'yo' }),
                o:wrap(['p'])))(.)
};

declare function local:map-filter-map()
{
    let $nodes := (['x'],'x', ['y'],['z'])
    return
      $nodes
      => o:filter(o:is-element#1) 
      => o:map(
            o:do((
              o:insert('foo'),
              o:insert-after('bar'),
              o:set-attr(map { 'class': 'yo' }),
              o:wrap(['p'])
            )))
};

declare function local:filter-elements()
{
    let $nodes := (['a'],'x',['b'],'x',['c'],'x',['d'])
    return
        o:filter($nodes,
            o:is-element#1)
};

declare function local:sort-elements()
{
    let $nodes := (['d'],'x',['b'],'x',['c'],'x',['a'])
    return
        $nodes
        => o:filter(o:is-element#1)
        => o:sort(o:tag#1)
};

declare function local:filter-attrs()
{
    let $nodes := (['a'],'x',['b', map { 'x': 10 }],'x',['c'],'x',['d'])
    return
        o:filter($nodes,
            o:has-attrs#1)
};


o:xml(local:sort-elements())