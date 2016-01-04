import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'xliff.xqm'; 

declare namespace its = 'http://www.w3.org/2005/11/its';
declare namespace xliff = 'urn:oasis:names:tc:xliff:document:1.2';
declare namespace html = 'http://www.w3.org/1999/xhtml';

let $its := o:read-xml(concat(file:base-dir(),'rules.its'))
let $builder := ex:its-builder($its)
let $html :=
  o:read-html(concat(file:base-dir(),'document.html'))
return
    (: o:apply($ex:xliff-template, map { 'srclang': 'es', 'tgtlang': 'de'}) :)
    (: o:xml(ex:extract-translatable(o:apply(o:doc($html, $builder)))) :)
    o:xml(o:apply($builder($html)))
    (: $builder :)
    (: ex:its-rules($its) :)
    (: o:compile-stylesheet(o:compile-rules(ex:its-rules($its))) :)

