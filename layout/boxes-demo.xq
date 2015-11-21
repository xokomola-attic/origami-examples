import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'boxes.xqm'; 

declare variable $ex:boxes :=
  <canvas width="640" height="480">
    <vbox>
      <box height="200"/>
        <vbox width="120">
          <box height="10"/>
          <box/>
          <box height="20"/>
        </vbox>
      <box/>
      <box/>
    </vbox>
  </canvas>;

o:xml(ex:layout(o:doc($ex:boxes)))