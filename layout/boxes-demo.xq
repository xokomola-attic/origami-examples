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
      <spacer/>
      <box height="200"/>
      <hbox>
        <spacer/>
        <box width="40"/>
        <box width="20"/>
        <spacer/>
        <spacer/>
      </hbox>
    </vbox>;

declare variable $ex:layers :=
    <vbox width="640" height="480" layers="b a">
      <layer id="a">
        <vbox>
          <box/>
          <box/>
        </vbox>
      </layer>
      <layer id="b">
        <hbox>
          <spacer/>
          <vbox>
            <spacer/>
            <box/>
            <spacer/>
            <box/>
            <spacer/>
          </vbox>
        </hbox>
      </layer>
    </vbox>;
    
declare function local:save($svg)
{
  file:write(
    '/Users/marcvangrootel/tmp/foo.svg',
    o:xml(ex:svg($svg), ex:svg-builder())
  )
};
(: o:xml(ex:layout-top-down(o:doc($ex:vbox))) :)
(: o:xml(ex:layout-bottom-up(o:doc($ex:vbox))) :)
(: o:xml(ex:svg(ex:layout-top-down(o:doc($ex:layers)))) :)
local:save(ex:layout-top-down(o:doc($ex:layers)))
(: o:xml(ex:svg(ex:layout-top-down(o:doc($ex:layers))), ex:svg-builder()) :)
 (: o:xml(ex:svg(ex:layout-top-down(o:doc($ex:layers)))) :)
(: ex:sum-values([1,2,1,1]) :)

(: local:save(ex:layout-top-down(ex:mosaic(4,4))) :)