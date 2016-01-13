import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'examplotron.xqm'; 

(: Example 1 :)
(: 
let $fn := unit:assert-equals(?,?, 'Not equal') 
return
  $fn(4,3) 
:) 

(: Example 2: Catching the error :)
(: also demonstrates that we can return structured data :)
(:
let $fn := 
  function($a as xs:integer, $b as xs:integer) {
    unit:assert-equals($a,$b, <args><a>{$a}</a><b>{$b}</b></args>)     
  }
return
  try {
    $fn(4,3) 
  } catch * {
    <error>
      <code>{ $err:code }</code>
      <description>{ $err:description }</description>
      <value>{ $err:value }</value>
      <module>{ $err:module }</module>
      <line-number>{ $err:line-number }</line-number>
      <column-number>{ $err:column-number }</column-number>
    </error>
  }
:)

(: Example 3 produce a customized test function via a Closure :)

let $fn := function($msg) {
  function($a,$b) { 
    unit:assert-equals($a,$b, $msg) 
  }
}
let $test := $fn('booh')
return
  try {
    $test(4,3) 
  } catch * {
    <error>
      <code>{ $err:code }</code>
      <description>{ $err:description }</description>
      <value>{ $err:value }</value>
      <module>{ $err:module }</module>
      <line-number>{ $err:line-number }</line-number>
      <column-number>{ $err:column-number }</column-number>
      <additional>{ $err:additional }</additional>
    </error>
  }


