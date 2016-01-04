xquery version "3.1";

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

(: A simple demo for ITS 2.0 and XLIFF 1.2 
   A full ITS 2.0 processor will be more complex than this
 :)
import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare namespace its = 'http://www.w3.org/2005/11/its';
declare namespace xliff = 'urn:oasis:names:tc:xliff:document:1.2';
declare namespace html = 'http://www.w3.org/1999/xhtml';

(: ISSUE: have to sort out the namespace issues :)
(: ISSUE: its:translateRules uses selectors like '//code' :)
(: ISSUE: when catching 'p' with a rule then a rule like 'code' 
   won't match unless embedded in the 'p' rule :)
(: I believe this requires a different type of stylesheet where all selectors
   live in the same mode, suitable for using absolute xpath selectors :)

declare variable $ex:xliff-builder-wrong :=
    o:transformer(
        ['xlf:xliff',
            ['xlf:file/@source-language', function($n,$d) { $d?srclang }],
            ['xlf:file/@target-language',  function($n,$d) { $d?tgtlang }],
            ['xlf:file/@original',  function($n,$d) { $d?original }],
            ['xlf:file/@*', function($n,$d) { $d?datatype }]
        ], 
        o:ns((
            ['xlf', 'urn:oasis:names:tc:xliff:document:1.2'],
            ['o', $o:ns?origami],
            ['', $o:ns?html]
        ))
    );

declare variable $ex:xliff-builder :=
    o:transformer(
        ['xlf:xliff',
            ['xlf:file',
                function($n,$d) { 
                    $n 
                    => o:set-attr('source-language', $d?srclang)
                    => o:set-attr('target-language', $d?tgtlang)
                    => o:set-attr('original', $d?original)
                }
            ]
        ], 
        o:ns((
            ['xlf', 'urn:oasis:names:tc:xliff:document:1.2'],
            ['o', $o:ns?origami],
            ['', $o:ns?html]
        ))
    );

declare variable $ex:xliff-template :=
    o:doc(
        o:read-xml(concat(file:base-dir(),'template.xlf')),
        $ex:xliff-builder
    );
    
declare function ex:translate-rule($xpath, $translate)
{
    [$xpath, function($n) {
        $n
        => o:advise-attr('translate', $translate)
        => o:apply()
    }]
};

declare variable $ex:html-rules :=
    (
        ex:translate-rule('//head/title', 'yes'),
        ex:translate-rule('//p', 'yes')
    );

(: TODO: using (...) is necessary to get what we need (investigate) :)
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

declare function ex:its-builder($its)
{
    o:transformer(
        ex:its-rules($its),
        o:ns((
            ['xlf', 'urn:oasis:names:tc:xliff:document:1.2'],
            ['o', $o:ns?origami],
            ['h', $o:ns?html],
            ['', $o:ns?html]
        ))
    )
};

(: Extract translatable nodes using ITS annotations :)
declare function ex:extract-translatable($doc)
{
    $doc ! (
        if (o:is-element(.) and o:attrs(.)?translate = 'yes') then
            .
        else
            ex:extract-translatable(o:children(.))
    )
};

(: Prepare ITS prepped HTML and generate XLIFF :)
declare function ex:xliff($doc)
{
    1
};
