module namespace test = 'http://xokomola.com/xquery/origami/examples';

import module namespace b = 'http://xokomola.com/xquery/origami/examples'
    at 'boxes.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare variable $test:vbox :=
  <canvas width="640" height="480">
    <vbox>
      <box height="10"/>
      <box/>
    </vbox>
  </canvas>;

declare variable $test:hbox :=
 <canvas width="640" height="480">
    <hbox>
      <box width="10"/>
      <box/>
      <box width="20"/>
    </hbox>
  </canvas>;

declare %unit:test function test:vbox-top-down()
{
  unit:assert-equals(
      o:xml(b:layout-top-down(o:doc($test:vbox))),
      <canvas width="640" height="480">
        <vbox width="640" height="480">
          <box width="640" height="10"/>
          <box width="640" height="470"/>
        </vbox>
      </canvas>
  )
};

declare %unit:test function test:hbox-top-down()
{
  unit:assert-equals(
      o:xml(b:layout-top-down(o:doc($test:hbox))),
      <canvas width="640" height="480">
        <hbox width="640" height="480">
          <box width="10" height="480"/>
          <box width="610" height="480"/>
          <box width="20" height="480"/>
        </hbox>
      </canvas>
  )
};

declare %unit:test function test:vbox-bottom-up()
{
  unit:assert-equals(
      o:xml(b:layout-bottom-up(o:doc($test:vbox))),
       <canvas width="640" height="480">
          <vbox width="100" height="50">
            <box width="100" height="10"/>
            <box width="100" height="40"/>
          </vbox>
        </canvas>
  )
};

declare %unit:test function test:hbox-bottom-up()
{
  unit:assert-equals(
      o:xml(b:layout-bottom-up(o:doc($test:hbox))),
      <canvas width="640" height="480">
        <hbox width="130" height="40">
          <box width="10" height="40"/>
          <box width="100" height="40"/>
          <box width="20" height="40"/>
        </hbox>
      </canvas>
  )
};
