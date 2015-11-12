xquery version "3.1";

(:~
 : Templating a shopping list.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare variable $ex:html := 
<html>
    <body>
      <p>This is a table</p>
      <table>
        <tr class="odd" x="foo">
          <th>hello <b>world</b>!</th>
          <th>foobar</th>
        </tr>
        <tr class="even" y="bar">
          <td>bla <b>bla</b></td>
          <td>foobar</td>
        </tr>
      </table>
    </body>
  </html>;

declare function ex:extract-table()
{
    let $builder := ['table']
    return
        o:xml(
            o:doc($ex:html, $builder)
        )    
};

declare function ex:extract-table-sans-attributes()
{
    let $builder := ['table', ['@*', ()]]
    return
        o:xml(
            o:doc($ex:html, $builder)
        )    
};

declare function ex:extract-table-no-inline()
{
    let $builder :=
        ['table',
            ['@*', ()],
            ['td|th', 
                ['*', (), 
                    ['text()']
                ]
            ]
        ]
    return
        o:xml(
            o:doc($ex:html, $builder)
        )    
};
