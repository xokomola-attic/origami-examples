xquery version "3.1";

(:~
 : Pure code templating (components)
 :
 : XQuery / XML variant for comparison
 : By far the fastest.
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

declare function ex:AuthorName($author)
{
    <a class="byline" href="{$author/@email}">
        { string($author) }
    </a>
};

declare function ex:Article($article)
{
    <div class="article">
        <div class="title">{ string($article/title) }</div>
        {
            ex:AuthorName($article/author)
        }
        <div class="article-body">{ $article/body }</div>        
    </div>
};

declare function ex:ArticleList($data)
{
    <div class="articles">{
        for $article in $data/article
        return
            ex:Article($article) 
    }</div>
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
    o:xml(ex:ArticleList($data))
};
