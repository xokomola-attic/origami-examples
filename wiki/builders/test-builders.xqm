xquery version "3.1";

(:~
 : Document Builder tests
 :)
module namespace test = 'http://xokomola.com/xquery/origami/tests';


import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'builders.xqm'; 

declare %unit:test function test:extract-articles() 
{
    unit:assert-equals(
        ex:extract-articles(), (
        <div class="article">
            <div class="desc">Article 1</div>
            <div class="price">9.99</div>
        </div>,
        <div class="article">
            <div class="desc">Article 2</div>
            <div class="price">10.99</div>
        </div>,
        <div class="article">
            <div class="desc">Article 3</div>
            <div class="price">12.99</div>
        </div>,
        <div class="article">
            <div class="desc">Article 4</div>
            <div class="price">4.99</div>
        </div>),
        'Extract the article divs'
    )
};

declare %unit:test function test:extract-first-article-of-each-row() 
{
    unit:assert-equals(
        ex:extract-first-article-of-each-row(), (
        <div class="article">
            <div class="desc">Article 1</div>
            <div class="price">9.99</div>
        </div>,
        <div class="article">
            <div class="desc">Article 3</div>
            <div class="price">12.99</div>
        </div>),
        'Extract the article divs'
    )
};

declare %unit:test function test:render-template()
{
  unit:assert-equals(
    ex:render-template(),
    <html>
      <head>
        <title>Base Template</title>
        <link href="main.css" rel="stylesheet" type="text/css"/>
      </head>
      <body>
        <div id="header">Header text</div>
        <div id="main">
          <div class="article">
            <div class="desc">Article 1</div>
            <div class="price">9.99</div>
          </div>
          <div class="article">
            <div class="desc">Article 2</div>
            <div class="price">10.99</div>
          </div>
          <div class="article">
            <div class="desc">Article 3</div>
            <div class="price">12.99</div>
          </div>
          <div class="article">
            <div class="desc">Article 4</div>
            <div class="price">4.99</div>
          </div>
        </div>
        <div id="footer">Footer text</div>
      </body>
    </html>
  )  
};