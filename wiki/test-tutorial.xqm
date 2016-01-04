xquery version "3.1";

module namespace x = 'http://xokomola.com/xquery/origami/wiki/tutorial';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm'; 

(: ==== The Mu data structure ==== :)

declare variable $x:xml :=
    <p>Hello, <span class="name">Origami</span>!</p>;

declare %unit:test function x:test-doc()
{
    unit:assert-equals(
        o:doc($x:xml)
        ,
        ['p',
            'Hello, ',
            ['span', map { 'class': 'name' }, 'Origami'],
            '!'
        ]
    ),
    
    unit:assert-equals(
        o:xml(o:doc($x:xml))
        ,
        $x:xml
    )
};

(: ==== Pure code templates ==== :)

declare function x:list($items)
{
    ['ul', map { 'class': 'groceries' },
        for $item in $items
        return ['li', $item]
    ]
};

declare function x:list-xq($items)
{
    <ul class="groceries">{
        for $item in $items
        return <li>{ $item }</li>
    }</ul>
};

declare %unit:test function x:test-list()
{
    unit:assert-equals(
        x:list(('Apples', 'Bananas', 'Pears'))
        ,
        ['ul', map { 'class': 'groceries' }, 
            (
                ['li', 'Apples'],
                ['li', 'Bananas'],
                ['li', 'Pears']
            )
        ]
    ),

    (: 
     : NOTE: the function returns a 3 item array. Use the following if you
     :       want to avoid this. For Origami it usually doesn't make a 
     :       difference but some code may.
     :)
    
    unit:assert-equals(
        array { 
            'ul', 
            map { 'class': 'groceries' },
            for $item in ('Apples', 'Bananas', 'Pears')
            return
                ['li', $item]
        }
        ,
        ['ul', map { 'class': 'groceries' }, 
            ['li', 'Apples'],
            ['li', 'Bananas'],
            ['li', 'Pears']
        ]
    ),

    unit:assert-equals(
        o:xml(x:list(('Apples', 'Bananas', 'Pears')))
        ,
        <ul class="groceries">
            <li>Apples</li>
            <li>Bananas</li>
            <li>Pears</li>
        </ul>
    ),
    
    unit:assert-equals(
        o:xml(x:list-xq(('Apples', 'Bananas', 'Pears')))
        ,
        <ul class="groceries">
            <li>Apples</li>
            <li>Bananas</li>
            <li>Pears</li>
        </ul>
    )        
};

(: ==== Mu pipelines ==== :)

declare variable $x:list :=
    <list>
        <item>A</item>
        <item>B</item>
        <item>C</item>
    </list>;
            
declare function x:ul($list as element(list))
as element(ul)
{
    ['ul',
        o:doc($list)
        => o:unwrap()
        => for-each(o:rename('li'))
    ] => o:xml()
};

declare %unit:test function x:test-ul()
{
    unit:assert-equals(
        x:ul($x:list)
        ,
        <ul>
            <li>A</li>
            <li>B</li>
            <li>C</li>
        </ul>
    )
};

declare function x:ul-2($list as element(list))
as element(ul)
{
    o:doc($list)
    => o:rename('ul')
    => o:insert(
        function($n) {
            o:for-each(
                o:children($n),
                o:rename('li')
            )
        }
    ) => o:xml()
};

declare %unit:test function x:test-ul-2()
{
    unit:assert-equals(
        x:ul-2($x:list)
        ,
        <ul>
            <li>A</li>
            <li>B</li>
            <li>C</li>
        </ul>
    )
};

declare function x:ul-xf($list as element(list))
as element(ul)
{
    o:doc(
        $list, 
        map { 
            'list': o:rename('ul'),
            'item': o:rename('li')
        }
    ) => o:apply() => o:xml()
};

declare %unit:test function x:test-ul-xf()
{
    unit:assert-equals(
        x:ul-xf($x:list)
        ,
        <ul>
            <li>A</li>
            <li>B</li>
            <li>C</li>
        </ul>
    )
};

declare function x:ul-xslt($list as element(list))
as element(ul)
{
    o:doc(
        $list,
        ['list', o:rename('ul'),
            ['item', o:rename('li')]
        ]
    ) => o:apply() => o:xml()
};

declare %unit:test function x:test-ul-xslt()
{
    unit:assert-equals(
        x:ul-xslt($x:list)
        ,
        <ul>
            <li>A</li>
            <li>B</li>
            <li>C</li>
        </ul>
    )
};

declare function x:ul-xslt-2($list as element(list))
{
    o:doc(
        $list,
        ['list', o:rename('ul'),
            ['item', o:rename('li')],
            ['item[1]', o:comp((o:rename('li'),o:insert('replaced')))]
        ]
    ) => o:apply() => o:xml()
};

declare %unit:test function x:test-ul-xslt-2()
{
    unit:assert-equals(
        x:ul-xslt-2(
            <list>
                <item>A</item>
                <item>B</item>
                <item>C</item>
            </list>
        ),
        <ul>
            <li>replaced</li>
            <li>B</li>
            <li>C</li>
        </ul>
    )
};

(: ==== Extracting nodes from a table ==== :)

declare variable $x:html :=
    <html>
        <body>
            <p>This is a table</p>
            <table>
                <tr class="odd" x="foo">
                    <th>hello <b><i>world</i></b>!</th>
                    <th>foobar</th>
                </tr>
                <tr class="even" y="bar">
                    <td>bla <b>bla</b></td>
                    <td>foobar</td>
                </tr>
            </table>
        </body>
    </html>;

declare variable $x:data :=
    <table>
        <tr>
            <td>Pears</td>
            <td>10</td>
        </tr>
        <tr>
            <td>Bananas</td>
            <td>4</td>
        </tr>
        <tr>
            <td>Apples</td>
            <td>8</td>
        </tr>
    </table>;

declare %unit:test function x:test-extract-table()
{
    unit:assert-equals(
        o:xml(
            o:doc(
                $x:html, 
                ['table']
            )
        )
        ,
        $x:html//table
    )
};

declare %unit:test function x:test-remove-attributes()
{
    unit:assert-equals(
        o:xml(
            o:doc(
                $x:html, 
                ['table', ['@*', ()]]
            )
        )
        ,
        <table>
            <tr>
                <th>hello <b><i>world</i></b>!</th>
                <th>foobar</th>
            </tr>
            <tr>
                <td>bla <b>bla</b></td>
                <td>foobar</td>
            </tr>
        </table>
    )
};

declare %unit:test function x:test-remove-inline-markup()
{
    unit:assert-equals(
        o:xml(
            o:apply(
                o:doc(
                    $x:html,
                    ['table',
                        ['td|th', 
                            ['*', o:unwrap()]
                        ]
                    ]
                )
            )
        )
        ,
        <table>
            <tr x="foo" class="odd">
                <th>hello world!</th>
                <th>foobar</th>
            </tr>
            <tr class="even" y="bar">
                <td>bla bla</td>
                <td>foobar</td>
            </tr>
        </table>
    )
};

declare %unit:test function x:test-sort-rows()
{
    unit:assert-equals(
        o:xml(
            o:apply(
                o:doc(
                    $x:data,
                    ['table', function($n) {
                        $n => o:insert(
                            for $row in o:children($n)
                            order by o:text(o:children($row)[1]) 
                            return $row
                        )
                    }]
                )
            )
        )
        ,
        <table>
            <tr>
                <td>Apples</td>
                <td>8</td>
            </tr>
            <tr>
                <td>Bananas</td>
                <td>4</td>
            </tr>
            <tr>
                <td>Pears</td>
                <td>10</td>
            </tr>
        </table>
    )
};