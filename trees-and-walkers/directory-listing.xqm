xquery version "3.1";

(:~
 : Using o:tree-seq to generate a directory listing.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../origami/origami.xqm'; 

(:~ 
 : List all files in the examples directory.
 :)
declare function ex:demo1()
{
    ex:files($ex:dir)
};

(:~ 
 : List all XQuery modules, HTML and XML files in the examples directory.
 :)
declare function ex:demo2()
{
    ex:fileset($ex:dir, ('\.xqm$','\.xml$','\.html$'))
};

declare variable $ex:dir := file:parent(file:base-dir());

declare function ex:files($dir as xs:string)
{
    o:filter(
        file:children($dir) => 
        o:tree-seq(
            file:is-dir#1,
            file:children#1
        ),
        (: filter out all file nodes :)
        o:do((file:is-dir#1, not#1))
    ) => o:map(function($f) { ['file', map {'path': $f }]})
};

declare function ex:fileset($dir,$patterns)
{
    o:xml(
        o:filter(
            ex:files($dir),
            (: filter out all file node whose path matches at least one of the patterns :)
            function($n) { 
                some $pattern in $patterns 
                satisfies matches(o:attrs($n)?path, $pattern) 
            }
        )
    )
};

declare %unit:test function ex:test-fileset()
{
    unit:assert-equals(
        ex:demo2(),
        for $f in 
            (
                '3col.html', 'base.html', 'example-html-template.xqm',
                'example-scraper.xqm', 'examples-components.xqm',
                'examples.xqm', 'json-ld/delta.xqm', 'json-ld/dt.xqm',
                'magic/wtf.xqm', 'navs.html', 'node-transformers/node-transformers-1.xqm',
                'ny-times.html', 'svg/examples.xqm', 'templates/task-list.xqm',
                'trees-and-walkers/directory-listing.xqm'
            )
        return
          <file path="/Users/marcvangrootel/data/fold-webapp/webapp/origami-examples/{$f}"/>
    )
};