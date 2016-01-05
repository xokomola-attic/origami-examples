xquery version "3.1";

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

(:~
 : A simple demo for ITS 2.0 and XLIFF 1.2 
 : A real ITS 2.0 processor will be more complex than this.
 :
 : See also: https://wiki.oasis-open.org/xliff/FAQ
 : See also: http://docs.oasis-open.org/xliff/v1.2/xliff-profile-html/xliff-profile-html-1.2-cd02.html
 :)

(: TODO: check if we should go for XLIFF 2.0 :)
(: TODO: fix namespace issues for o:xml :)
(: TODO: build a function to take the XLIFF and generate the translated HTML :)

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare namespace its = 'http://www.w3.org/2005/11/its';
declare namespace xliff = 'urn:oasis:names:tc:xliff:document:1.2';
declare namespace html = 'http://www.w3.org/1999/xhtml';

declare variable $ex:ns :=
    o:ns((
        ['xlf', 'urn:oasis:names:tc:xliff:document:1.2'],
        ['its', 'http://www.w3.org/2005/11/its'],
        ['', $o:ns?html]
    ));
        
(: TODO: o:transformer won't work :)
(: TODO: xlf:internal-file should add ids for tus :)

declare variable $ex:xliff-builder :=
    o:builder(
        ['xlf:xliff',
            ['xlf:internal-file',
                function($n,$d) {
                    $n =>
                    o:set-attrs(map {
                        'form': 'application/xhtml+xml'
                    }) =>
                    o:insert($d?content)
                }
            ],
            ['xlf:file',
                function($n,$d) { 
                    $n => 
                    o:set-attrs(map {
                        'source-language': $d?srclang,
                        'target-language': $d?tgtlang,
                        'original': $d?original
                    }) =>
                    o:apply($d)
                }
            ],
            ['xlf:trans-unit',
                function($n,$d) {
                    for $html at $id in ex:extract-translatable($d?content)
                    let $tu := map { 
                        'content': $html,
                        'id': $id,
                        'resname': o:tag($html),
                        'srclang': $d?srclang,
                        'tgtlang': $d?tgtlang
                    }
                    let $xlf := ex:xliff-trans-unit($n,$tu)
                    return $xlf
                }
            ]
        ],
        $ex:ns
    );

declare variable $ex:xliff-template :=
    o:doc(
        o:read-xml(concat(file:base-dir(),'template.xlf')),
        $ex:xliff-builder
    );

(:~
 : Create a "translate" rule.
 :)
declare function ex:translate-rule($xpath, $translate)
{
    [$xpath, function($n) {
        $n
        => o:advise-attr('translate', $translate)
        => o:apply()
    }]
};

(:~
 : The ITS rules that describe what should be translated in an HTML document.
 :)
declare variable $ex:html-rules :=
    (
        ex:translate-rule('//head/title', 'yes'),
        ex:translate-rule('//p', 'yes')
    );

(:~
 : Create the ITS rules that describe the annotation transform.
 : This will also add the built-in standard HTML rules.
 :)
declare function ex:its-rules($its)
{
    ['/*', (
      $ex:html-rules,
      for $its-rule in $its//its:translateRule
      let $translate := string($its-rule/@translate)
      let $select := string($its-rule/@selector)
      return
          ex:translate-rule($select, $translate) 
    )]
};

(:~
 : Build an annotation transformer (a function) using the provided 
 : ITS rules (rules.its).
 :)
declare function ex:its-builder($its)
{
    o:transformer(ex:its-rules($its), $ex:ns)
};

(:~
 : Extract translatable elements using ITS annotations.
 : Such an element may contain other (inline) elements
 : that have their own translate attribute. 
 :)
declare function ex:extract-translatable($doc)
{
    $doc ! (
        if (o:is-element(.) and o:attrs(.)?translate = 'yes') then
            .
        else
            ex:extract-translatable(o:children(.))
    )
};

(:~
 : Annotates HTML and generates XLIFF file. 
 :)
declare function ex:xliff($path)
{
    let $html := ex:prepare-html($path)
    let $res := map {
        'srclang': 'en',
        'tgtlang': 'nl',
        'datatype': 'xhtml',
        'original': $path,
        'content': $html
    }
    where exists($html)
    return
        o:xml(o:apply($ex:xliff-template, $res), o:ns-builder($ex:ns))
};

(:~
 : Takes an XLIFF trans-unit as template and uses an HTML translation unit map
 : as data for generating the final XLIFF translation unit.
 :)
declare function ex:xliff-trans-unit($tpl, $tu)
{
    (: TODO: adapt o:xml and namespace code to handle 'xml:lang' correctly :)
    (: TODO: add other attributes (needs-translation etc.) :)
    let $content := ex:xliff-content($tu?content)
    return
        $tpl => 
        o:set-attrs(map {
            'id': $tu?id,
            'resname': $tu?resname
        }) =>
        o:insert(
            o:wrap(
                $content, 
                ['xlf:source', 
                    map { 'lang': $tu?srclang }
                ]
            )
        ) => 
        o:insert-after(
            o:wrap(
                $content, 
                ['xlf:target', 
                    map { 'lang': $tu?tgtlang }
                ]
            )
        )
};

(: TODO: inlines should be using ids :)

declare function ex:xliff-content($mu)
{
    o:postwalk($mu, function($n) {
        typeswitch($n)
        case array(*) return
            let $html-tag := o:tag($n)
            let $children := o:children($n)
            let $translatable := o:attrs($n)?translate = 'yes'
            return
                if ($translatable) then
                    array {
                       'xlf:g',
                       map { 'ctype': $html-tag },
                       $children
                    }
                else
                    array {
                        'xlf:x',
                        map { 'ctype': $html-tag, 'equiv-text': o:ntext($n) }
                    }
        default return
            $n
    }) => 
    o:unwrap()
};

(:~
 : Ties everything together: annotate HTML with ITS data, extract the
 : translatable units from the HTML and use an XLIFF template to generate
 : a translatable XLIFF files.
 :)
declare function ex:prepare-html($path)
{
    let $its := o:read-xml(concat(file:base-dir(), 'rules.its'))
    let $builder := ex:its-builder($its)
    let $html := o:read-html($path)
    where exists($html)
    return
        o:apply($builder($html))
};
