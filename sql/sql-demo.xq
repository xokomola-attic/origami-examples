import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace sql = 'http://xokomola.com/xquery/origami/examples'
    at 'sql.xqm'; 

let $sql := (
    ['select', '*'],
    ['from', 'users'], 
    ['where', 'active', '=', 'true'], 
    ['order', 'created'], 
    ['limit', 5], 
    ['offset', 3]
)
return
  o:xml($sql)
  (: sql:query($sql) :)
