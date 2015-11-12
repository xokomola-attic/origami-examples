xquery version "3.1";

(:~
 : Templating a shopping list.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare variable $ex:html :=
  o:read-html(concat(file:base-dir(),'groceries.html'));

declare variable $ex:template := 
  o:doc(
    $ex:html,
    ['html', 
      ['head',
        ['title', function($node, $data) { 
          $node => o:insert($data?title) 
        }],
        ['link[@rel="stylesheet"][last()]', function($node, $data) {
          let $link := $node => o:set-attr(map { 'href': $data?css })
          return
            $node => o:after($link)
        }]
      ],
      ['ul[@class="groceries"]',
        ['li[1]', function($node, $data) {
          for $item in $data?items
          return
            $node => o:insert($item)
        }],
        ['li', ()]
      ]
    ]
  );

declare function ex:groceries()
{
    ex:groceries(('Apples','Bananas','Pears'))
};

declare function ex:groceries($items)
{
    let $defaults :=
        map {
            'title': 'Shopping List',
            'css': 'shopping-list.css',
            'items': ('Apples','Bananas','Pears')
        }
    let $data := 
        typeswitch ($items)
        case map(*) return
          map:merge(($defaults, $items))
        default return
          map:merge(($defaults, map { 'items': $items }))
  
    return 
        o:xml(
            o:apply($ex:template, $data)
        )
};
