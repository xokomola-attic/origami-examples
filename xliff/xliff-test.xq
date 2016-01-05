module namespace test = 'http://xokomola.com/xquery/origami/examples';

import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'xliff.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';


declare %unit:test function test:prepare-html()
{
    unit:assert-equals(
        o:xml(ex:prepare-html(concat(file:base-dir(),'document.html')))
        ,
        <html>
            <head>
                <meta charset="utf-8"/>
                <title translate="yes">Translate flag global rules example</title>
            </head>
            <body>
                <p translate="yes">This sentence should be translated, but code names like the <code translate="no">span</code> element should not be translated. Of course there are always exceptions: certain code values should be translated, e.g. to a value in your language like <code translate="yes">warning</code>.</p>
            </body>
        </html>
        ,
        "Add ITS annotations to an HTML file."
    )
};

declare %unit:test function test:extract-translatable()
{
    unit:assert-equals(
        let $html := ex:prepare-html(concat(file:base-dir(),'document.html')) 
        for $tu in ex:extract-translatable($html)
        return
            <tu>{
                o:xml($tu)
            }</tu>
        ,
        (
            <tu>
                <title translate="yes">Translate flag global rules example</title>
            </tu>,
            <tu>
                <p translate="yes">This sentence should be translated, but code names like the <code translate="no">span</code> element should not be translated. Of course there are always exceptions: certain code values should be translated, e.g. to a value in your language like <code translate="yes">warning</code>.</p>
            </tu>
        )
        ,
        "Extract each translatable element."
    )
};
