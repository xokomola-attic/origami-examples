xquery version "3.1";

(:~
 : Examples for μ-documents
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../origami/origami.xqm'; 

declare variable $ex:dir := file:parent(file:base-dir());

declare function ex:files($dir as xs:string)
{
    o:select(
        file:children($dir) => 
        o:tree-seq(
            file:is-dir#1,
            file:children#1
        ),
        o:comp((file:is-dir#1,not#1))
    ) => o:map(function($f) { ['file', map {'path': $f }]})
};

(:~ 
 : example: ex:fileset(('\.xqm$','\.xml$','\.html$')) 
 :
 : List all XQuery modules, HTML and XML files in the origami directory.
 :)
declare function ex:fileset($dir,$patterns)
{
    o:xml(o:select(
        ex:files($dir),
        function($n) { 
          some $pattern in $patterns 
          satisfies matches(o:attrs($n)?path, $pattern) 
        }
    ))
};
