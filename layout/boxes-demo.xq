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
    <vbox width="640" height="480">
      <box height="200"/>
      <box height="200"/>
      <hbox height="100">
        <box width="40"/>
        <box width="20"/>
      </hbox>
    </vbox>;

(: o:xml(ex:layout-top-down(o:doc($ex:vbox))) :)
(: o:xml(ex:layout-bottom-up(o:doc($ex:vbox))) :)
file:write('/Users/marcvangrootel/tmp/foo.svg', o:xml(ex:svg(ex:layout-top-down(o:doc($ex:hbox))), ex:svg-builder()))
(: o:xml(ex:svg(ex:layout-top-down(o:doc($ex:vbox))), ex:svg-builder()) :)

(: ex:sum-values([1,2,1,1]) :)