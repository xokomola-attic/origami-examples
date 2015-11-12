xquery version "3.1";

(:~
 : Templating a shopping list.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare variable $ex:html := 
  <html>
    <head>
        <title>My little web shop</title>
        <link rel="stylesheet" type="text/css" href="main.css"></link>
    </head>
    <body>
        <div id="header">My shop</div>
        <div id="content">
            <table>
                <tr>
                    <td>
                        <div class="article">
                            <img src="article1.jpg"/>
                            <div class="desc">Article 1</div>
                            <div class="price">9.99</div>
                        </div>
                    </td>
                    <td>
                        <div class="article">
                            <img src="article2.jpg"/>
                            <div class="desc">Article 2</div>
                            <div class="price">10.99</div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div class="article">
                            <img src="article3.jpg"/>
                            <div class="desc">Article 3</div>
                            <div class="price">12.99</div>
                        </div>
                    </td>
                    <td>
                        <div class="article">
                            <img src="article4.jpg"/>
                            <div class="desc">Article 4</div>
                            <div class="price">4.99</div>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <div id="footer">More info</div>
    </body>
  </html>;

declare function ex:extract-articles()
{
    let $builder := 
        ['div[@class="article"]',
            ['img', ()],
            ['div[@class="desc"]'],
            ['div[@class="price"]']
        ]
    return
        o:xml(
            o:doc($ex:html, $builder)
        )    
};

declare function ex:extract-first-article-of-each-row()
{
    let $builder := 
        ['td[1]/div[@class="article"]',
            ['img', ()],
            ['div[@class="desc"]'],
            ['div[@class="price"]']
        ]
    return
        o:xml(
            o:doc($ex:html, $builder)
        )    
};

declare variable $ex:template := 
  <html>
    <head>
        <title>Base Template</title>
        <link rel="stylesheet" type="text/css" href="main.css"></link>
    </head>
    <body>
        <div id="header">
            The base header
        </div>
        <div id="main">
            The base body
        </div>
        <div id="footer">
            The base footer
        </div>
    </body>
  </html>;

declare function ex:build-template()
{
  let $builder :=
    ['html',
      ['div[@id="header"]', o:insert('Header text')],
      ['div[@id="main"]', function($n,$d) { $n => o:insert($d) }],
      ['div[@id="footer"]', o:insert('Footer text')]
    ]
  return
    o:doc($ex:template, $builder)
};

declare function ex:render-template()
{
  o:xml(
    o:apply(
      ex:build-template(),
      ex:extract-articles()
    )
  )
};