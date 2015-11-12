xquery version "3.1";

(:~
 : Pure code templating (components)
 :
 : Trying a different approach but this is about twice (1.5 - 2) as slow as components.xqm
 : As we are not trying to build something that has to respond to state changes
 : the first approach is not only faster, cleaner but also preferred.
 : The code is cumbersome.
 :
 : Learned: having a o:component is nice as it allows a mu data structure to be
 : hung into a larger structure (a kind of components).
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare variable $ex:Authorname :=
    o:component(
        ['a',
            map { 
                'class': 'byline',
                'href': [o:text#1, function ($n,$d) { [$d/@email] }] 
            },
            [o:text#1, function ($n,$d) { [$d] }]
        ]
    );
    
declare variable $ex:Article :=
    o:component(
        ['div', map { 'class': 'article' },
            ['div', map { 'class': 'title' }, [o:text#1, function ($n,$d) { [$d/title] } ]],
            [$ex:Authorname, function ($n,$d) { [$d/author] }],
            ['div', map { 'class': 'article-body' }, 
                [o:text#1, function ($n,$d) { [$d/body] }] 
            ]
        ]
    );

declare variable $ex:ArticleList :=
    o:component(
        ['div', map { 'class': 'articles' },
            [o:map($ex:Article), function($n,$d) { [$d/article] }]
        ]
    );

declare variable $ex:data as element(articles) :=
    <articles>
        <article>
            <title>Why Origami rocks</title>
            <author email="xokomola@example.com">Xokomola</author>
            <body>...</body>
        </article>
        <article>
            <title>Why XQuery is awesome</title>
            <author email="foo@example.com">Joe Foo</author>
            <body>...</body>
        </article>
    </articles>;

declare function ex:render($data)
{
    $ex:ArticleList($data)
};
