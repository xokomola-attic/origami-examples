import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'xliff.xqm'; 

declare namespace its = 'http://www.w3.org/2005/11/its';
declare namespace xliff = 'urn:oasis:names:tc:xliff:document:1.2';
declare namespace html = 'http://www.w3.org/1999/xhtml';

ex:xliff(concat(file:base-dir(),'document.html'))
