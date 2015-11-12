xquery version "3.1";

(:~
 : o:doc tests
 :)
module namespace test = 'http://xokomola.com/xquery/origami/tests';


import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'groceries.xqm'; 

declare %unit:test function test:groceries() 
{
    unit:assert-equals(
        ex:groceries(),
        <html>
            <head>
              <title>Shopping List</title>
              <meta charset="UTF-8"/>
              <link href="base.css" rel="stylesheet" type="text/css"/>
              <link href="shopping-list.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
              <ul class="groceries">
                <li>Apples</li>
                <li>Bananas</li>
                <li>Pears</li>
              </ul>
            </body>
          </html>
        ,
        'Render the shopping list example'
    )
};

declare %unit:test function test:grocery-list()
{
    unit:assert-equals(
        ex:groceries(('Pumpkins','Avocados','Olives'))//li/text() ! string(.),
        ('Pumpkins','Avocados','Olives'),
        'A different shopping list'
    )
};
