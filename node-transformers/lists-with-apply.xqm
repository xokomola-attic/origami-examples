xquery version "3.1";

(:~
 : Building a list from a sequence using different templating techniques.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../origami/origami.xqm'; 

(: Example 1 :)

declare function ex:list-template-traditional() 
{
    let $groceries := ('Apples', 'Bananas', 'Pears')
    let $template :=   
        function($items) {
            <ul class="groceries">{ 
                for $item in $items
                return 
                    <li>{ $item }</li>
            }</ul>
        }
    return $template($groceries)
};

declare %unit:test function ex:test-list-template-traditional()
{
    unit:assert-equals(
        ex:list-template-traditional(),
        <ul class="groceries">
            <li>Apples</li>
            <li>Bananas</li>
            <li>Pears</li>
        </ul>,
        'Traditional template'
    )
};

(: Example 2 :)

declare function ex:list-template-pure() 
{
    let $groceries := ('Apples', 'Bananas', 'Pears')
    let $template :=   
        function($items) {
            ['ul', map { 'class': 'groceries' }, 
                for $item in $items
                return 
                    ['li', $item]
            ]
        }
    return o:xml($template($groceries))
};

declare %unit:test function ex:test-list-template-pure()
{
    unit:assert-equals(
        ex:list-template-pure(),
        <ul class="groceries">
            <li>Apples</li>
            <li>Bananas</li>
            <li>Pears</li>
        </ul>,
        'Pure code template'
    )
};

(: Example 3 :)

declare function ex:list-template-apply() 
{
    let $groceries := [('Apples', 'Bananas', 'Pears')]
    let $template :=   
        ['ul', map { 'class': 'groceries' },  
            [function($n,$items) {
                for $item in $items
                return 
                    ['li', $item]
            }]
        ]
    return o:xml(o:apply($template, $groceries))
};

declare %unit:test function ex:test-list-template-apply()
{
    unit:assert-equals(
        ex:list-template-apply(),
        <ul class="groceries">
            <li>Apples</li>
            <li>Bananas</li>
            <li>Pears</li>
        </ul>,
        'Apply template'
    )
};

(: Example 4 :)

(: Create a template doc from $xml with embedded templating attributes :)
declare function ex:template($xml) {
    o:doc(
        $xml,
        o:xform(
          ['ul',
            ['li[@o:for-each]', ex:for-each#2],
            ['li[@o:remove]', ()]
          ]
        )
    )
};

(: Apply the template to data :)
declare function ex:list-template-dsl()
{
    let $groceries := [('Apples', 'Bananas', 'Pears')]
    let $list := 
        ex:template(
            <ul>
                <li o:for-each=".">item 1</li>
                <li o:remove=".">item 2</li>
                <li o:remove=".">item 3</li>
            </ul>
        )
    return o:apply($list, $groceries)
};

declare function ex:for-each($nodes, $items) {
    for $item in $items
    return
        $nodes => o:remove-attr('ex:for-each') => o:insert($item)
};

declare %unit:test function ex:test-list-template-dsl()
{
    unit:assert-equals(
        o:xml(ex:list-template-dsl()),
        <ul>
            <li>Apples</li>
            <li>Bananas</li>
            <li>Pears</li>
        </ul>,
        'Template DSL'
    )  
};

(:
 : Composing templates.
 :
 : TODO: this is way too confusing example (the args with the handlers)
 :)
declare variable $ex:list-item :=
  ['li', [function($n,$seq,$pair) { sum($pair) }, (1,2,3)]];
  
declare variable $ex:ol-list :=
  ['ol', function($n,$seq) {
    for $pair in $seq
    return o:apply($ex:list-item, [$pair])      
  }];

declare function ex:list-template3() 
{
    o:apply($ex:ol-list, [([1,2],[3,4],[5,6])])
};

declare %unit:test function ex:test-list-template3()
{
    unit:assert-equals(
        o:xml(ex:list-template3()),
        <ol>
            <li>3</li>
            <li>7</li>
            <li>11</li>
        </ol>,
        'Compose a template'
    )
};
