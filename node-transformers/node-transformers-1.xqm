xquery version "3.1";

(:~
 : Code for node-transformers tutorial 1.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare function ex:creating-lists()
{
    (: wrap a list item into an unordered list element :)
    <div id="ex1">{
        <li>item</li> 
        => o:doc() 
        => o:insert('hello') 
        => o:wrap(['ul']) 
        => o:xml()
    }</div>,
    
    (: repeat the list item, then wrap it in a list element :)
    <div id="ex2">{
      <li>item</li>
      => o:doc()
      => o:repeat(1 to 3, o:insert('hello'))
      => o:wrap(['ul']) 
      => o:xml()
    }</div>,

    (: use repeat with arity 2 function to get the iteration value :)
    <div id="ex3">{
      <li>item</li>
      => o:doc()
      => o:repeat(1 to 3, function($n, $i) { $n => o:insert('hello ' || $i) })
      => o:wrap(['ul']) 
      => o:xml()      
    }</div>,

    (: use choose with a sequence to repeat :)
    <div id="ex4">{
      <li>item</li>
      => o:doc()
      => o:choose(1 to 3, function($x) { o:insert('hello ' || $x) })
      => o:wrap(['ul']) 
      => o:xml()     
    }</div>

    (: there are other techniques involving rules but that's for a next tutorial :)
    
};

declare function ex:creating-lists()
{
    
};

(: each / do :)

(: text :)
