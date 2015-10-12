module namespace wtf = 'http://xokomola.com/xquery/origami/wtf';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare %unit:test function wtf:double-b()
{
  let $f := o:insert('hello') => o:wrap(['b'])
  return
    unit:assert-equals(
      o:xml(o:apply($f)),
      <b>
        <b>hello</b>
      </b>,
      'The b element gets duplicated'
    )
};
