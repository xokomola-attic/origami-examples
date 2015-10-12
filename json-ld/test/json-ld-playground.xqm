xquery version "3.1";

module namespace pg = 'http://xokomola.com/xquery/origami-data/tests';

(:~
 : Tests for the various forms of JSON-LD expressed as μ-nodes.
 :
 : Note that this is NOT a way to transform graphs into a different
 : form but ONLY a way to encode these various forms using μ-nodes.
 : The form hint (first argument in α:json#2) determines how the
 : structure provided as the second argument is interpreted.
 :
 : @see http://json-ld.org/playground/index.html
 :)

import module namespace α = 'http://xokomola.com/xquery/origami-data/α' 
    at '../alpha.xqm'; 

(: Helper function to write cleaner tests :)
declare function pg:each-equals($examples, $json)
{
  for $example in $examples
  return unit:assert-equals($example, $json)  
};

(:~
 : The default form for JSON-LD is compact as it is the most readable form.
 : It can be used by conforming JSON-LD processors but needs parsing via
 : specified algorithms to expand into a full graph.  
 :)
declare %unit:test %unit:ignore function pg:person-compact() 
{
    unit:assert-equals(
        α:json(
            ['@description', map {
                '@context': 'http://schema.org/',
                '@type': 'Person'},
                ['jobTitle', 'Professor'],
                ['name', 'Jane Doe'],
                ['telephone', '(425) 123-4567'],
                ['url', map {'iri': 'http://www.janedoe.com'}]
            ]
        ),
        map {
          "@context": "http://schema.org/",
          "@type": "Person",
          "jobTitle": "Professor",
          "name": "Jane Doe",
          "telephone": "(425) 123-4567",
          "url": "http://www.janedoe.com"
        }
    )
};

(:~ 
 : In normalized form output a sequence of strings, each is a fact in 
 : triple form but without the trailing "."
 : Normalized form is especially suited for tests as the results are output
 : in a predictable order. 
 :)
declare %unit:test %unit:ignore function pg:person-normalized() 
{
    unit:assert-equals(
        α:json('normalized',
            ['_:c14n0',
                ['http://schema.org/jobTitle', 'Professor'],
                ['http://schema.org/name', 'Jane Doe'],
                ['http://schema.org/telephone', '(425) 123-4567'],
                ['http://schema.org/url', map {'iri': 'http://www.janedoe.com'}],
                ['http://www.w3.org/1999/02/22-rdf-syntax-ns#type', map {'iri': 'http://schema.org/Person'}] 
            ]    
        ),
        (
            "_:c14n0 &lt;http://schema.org/jobTitle&gt; &quot;Professor&quot;",
            "_:c14n0 &lt;http://schema.org/name&gt; &quot;Jane Doe&quot;",
            "_:c14n0 &lt;http://schema.org/telephone&gt; &quot;(425) 123-4567&quot;",
            "_:c14n0 &lt;http://schema.org/url&gt; &lt;http://www.janedoe.com&gt;",
            "_:c14n0 &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://schema.org/Person&gt;"
        )
    )
};

(:~ 
 : In nquads form output a sequence of strings, each is a fact in 
 : triple form but without the trailing "."
 : N-Quads form is especially suited for exchange with RDF libraries that
 : read facts.
 : In contrast to normalized form the output cannot be readily compared for
 : equality as the output is not in a predictable order. Otherwise it is the
 : same as normalized form.
 :)
declare %unit:test %unit:ignore function pg:person-nquads() 
{
    unit:assert-equals(
        α:json('nquads',
            ['_:b0',
                ['http://schema.org/jobTitle', 'Professor'],
                ['http://schema.org/name', 'Jane Doe'],
                ['http://schema.org/telephone', '(425) 123-4567'],
                ['http://schema.org/url', map {'iri': 'http://www.janedoe.com'}],
                ['http://www.w3.org/1999/02/22-rdf-syntax-ns#type', map {'iri': 'http://schema.org/Person'}] 
            ]    
        ),
        (
            "_:b0 &lt;http://schema.org/jobTitle&gt; &quot;Professor&quot;",
            "_:b0 &lt;http://schema.org/name&gt; &quot;Jane Doe&quot;",
            "_:b0 &lt;http://schema.org/telephone&gt; &quot;(425) 123-4567&quot;",
            "_:b0 &lt;http://schema.org/url&gt; &lt;http://www.janedoe.com&gt;",
            "_:b0 &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; &lt;http://schema.org/Person&gt;"
        )
    )
};

(:~
 : Flattened form has one map for each object and there will be no nested objects.
 : The flat structure may be easier to consume in some context but it may lead to
 : a lot of link traversal to get to a deeply nested object in the compact form.
 :)
(: TODO: but how does this behave with nested @context's? :)
declare %unit:test %unit:ignore function pg:person-flattened() 
{
    unit:assert-equals(
        α:json('flattened',
            ['@description', map {
                '@context': 'http://schema.org/'},
                ['@graph', map {
                    '@id': '_:b0',
                    '@type': 'Person'},
                    ['jobTitle', 'Professor'],
                    ['name', 'Jane Doe'],
                    ['telephone', '(425) 123-4567'],
                    ['url', map {'iri': 'http://www.janedoe.com'}]
                ]
            ]
        ),
        map {
          "@context": "http://schema.org/",
          "@type": "Person",
          "jobTitle": "Professor",
          "name": "Jane Doe",
          "telephone": "(425) 123-4567",
          "url": "http://www.janedoe.com"
        }
    )
};
