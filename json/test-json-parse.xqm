module namespace test = 'http://xokomola.com/xquery/origami/examples/test/parse-json';

declare function test:json($name) 
{ 
  file:read-text(
    concat(
      file:base-dir(), 
      'resources/test/', 
      $name))
};

declare %unit:test function test:json-pass1()
{
  let $xdm := parse-json(test:json('pass1.json'))
  return
    unit:assert(true())
};
