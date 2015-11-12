xquery version "3.1";

(:~
 : Pure code templating (components)
 :
 : Clean but shows little advantage over standard XML XQuery templates.
 : The speed is great as long as you don't have to serialize to XML.
 : so to get this advantage in a web front end we need to become smarter
 : maybe a Clojure web layer that can use Mu can tap into this raw speed.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare function ex:Authorname($author)
{
    ['a',
        map { 
            'class': 'byline',
            'href': o:text($author/@email) 
        },
        o:text($author)
    ]
};

declare function ex:Article($article)
{
    ['div', map { 'class': 'article' },
        ['div', map { 'class': 'title' }, $article/title ],
        ex:Authorname($article/author),
        ['div', map { 'class': 'article-body' }, $article/body ]
    ]
};

declare function ex:ArticleList($data)
{
    ['div', map { 'class': 'articles' },
        for $article in $data/article
        return
            ex:Article($article) 
    ]
};

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
    ex:ArticleList($data)
};
