import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'boxes.xqm'; 

declare variable $ex:hbox :=
  <canvas width="640" height="480">
    <hbox>
      <box width="10"/>
      <box height="80"/>
      <box/>
      <box width="320"/>
    </hbox>
  </canvas>;
  
declare variable $ex:vbox :=
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

(: o:xml(ex:layout-top-down(o:doc($ex:hbox))) :)
(: o:xml(ex:layout-bottom-up(o:doc($ex:vbox))) :)
file:write('/Users/marcvangrootel/tmp/foo.svg', o:xml(ex:svg(ex:layout-top-down(o:doc($ex:vbox))), ex:svg-builder()))
