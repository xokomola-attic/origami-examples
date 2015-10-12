xquery version "3.1";

module namespace test = 'http://xokomola.com/xquery/origami/tests';

(:~
 : Tests for JSON-LD syntax serialization.
 :
 : @see http://www.w3.org/TR/json-ld
 :)

import module namespace α = 'http://xokomola.com/xquery/origami/α' 
    at '../alpha.xqm'; 

(: Helper function to write cleaner tests :)
declare function test:each-equals($examples, $json)
{
  for $example in $examples
  return unit:assert-equals($example, $json)  
};

(:~ EXAMPLE 4: Referencing a JSON-LD context :)
declare %unit:test function test:example-4() 
{
    let $json :=
        map {
          "@context": "http://json-ld.org/contexts/person.jsonld",
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/",
          "image": "http://manu.sporny.org/images/manu.png"
        }

    let $ex1 :=
        α:json(
            ['@', map {'@context': 'http://json-ld.org/contexts/person.jsonld'},
              ['name', 'Manu Sporny'],
              ['homepage', map {'@iri': 'http://manu.sporny.org/'}],
              ['image', map {'@iri': 'http://manu.sporny.org/images/manu.png'}]
            ]
        )
        
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 5: In-line context definition :)
declare %unit:test function test:example-5() 
{
    let $json :=
        map {
          "@context":
          map {
            "name": "http://schema.org/name",
            "image": map {
              "@id": "http://schema.org/image",
              "@type": "@id"
            },
            "homepage": map {
              "@id": "http://schema.org/url",
              "@type": "@id"
            }
          },
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/",
          "image": "http://manu.sporny.org/images/manu.png"
        }

    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                  ['name', map {'@iri': 'http://schema.org/name'}],
                  ['image', map {'@id': 'http://schema.org/image', '@type': '@id'}],
                  ['homepage', map {'@id': 'http://schema.org/url', '@type': '@id'}]
              ],
              ['name', 'Manu Sporny'],
              ['homepage', map {'@iri': 'http://manu.sporny.org/'}],
              ['image', map {'@iri': 'http://manu.sporny.org/images/manu.png'}]
            ]
        )
        
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 6: Values of @id are interpreted as IRI :)
declare %unit:test function test:example-6() 
{
    let $json :=
        map {
          "homepage": map { "@id": "http://example.com/" }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['homepage', map {'@id': 'http://example.com/'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 7: IRIs can be relative :)
declare %unit:test function test:example-7() 
{
    let $json :=
        map {
          "homepage": map { "@id": "../" }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['homepage', map {'@id': '../'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 8: IRI as a key :)
declare %unit:test function test:example-8() 
{
    let $json :=
        map {
          "http://schema.org/name": "Manu Sporny"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['http://schema.org/name', 'Manu Sporny']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 9: Term expansion from context definition :)
declare %unit:test function test:example-9() 
{
  
    let $json :=
       map {
          "@context": map {
            "name": "http://schema.org/name"
          },
          "name": "Manu Sporny",
          "status": "trollin"
        }
    
    let $ex1 :=
        α:json(
            ['@', 
              [
                '@context',
                  ['name', map {'@iri': 'http://schema.org/name'}]
              ],
              ['name', 'Manu Sporny'],
              ['status', 'trollin']
            ]
        )
     
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 10: Type coercion :)
declare %unit:test function test:example-10() 
{
    let $json :=
        map {
          "@context": map {
            "homepage": map {
              "@id": "http://schema.org/url",
              "@type": "@id"
            }
          },
          "homepage": "http://manu.sporny.org/"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['homepage', map {'@id': 'http://schema.org/url', '@type': '@id'}]
              ],
              ['homepage', map {'@iri': 'http://manu.sporny.org/'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 11: Identifying a node :)
declare %unit:test function test:example-11() 
{
    let $json :=
        map {
          "@context": map {
            "name": "http://schema.org/name"
          },
          "@id": "http://me.markus-lanthaler.com/",
          "name": "Markus Lanthaler"
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context',
                    ['name', map {'@iri': 'http://schema.org/name'}]
                ],
                ['@id', map {'@iri': 'http://me.markus-lanthaler.com/'}],
                ['name', 'Markus Lanthaler']
            ]
        )
    
    (: @type and @id specified as attributes of @ :)
    let $ex2 :=
        α:json(
            ['@', map {'@id': 'http://me.markus-lanthaler.com/'},
                ['@context',
                    ['name', map {'@iri': 'http://schema.org/name'}]
                ],
                ['name', 'Markus Lanthaler']
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 12: Specifying the type for a node :)
declare %unit:test function test:example-12() 
{
    let $json :=
        map {
          "@id": "http://example.org/places#BrewEats",
          "@type": "http://schema.org/Restaurant"
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@id', map {'@iri': 'http://example.org/places#BrewEats'}],
                ['@type', map {'@iri': 'http://schema.org/Restaurant'}]
            ]
        )
    
    (: @type and @id specified as attributes of @ :)
    let $ex2 :=
        α:json(
            ['@', map {
                '@id':  'http://example.org/places#BrewEats',
                '@type': 'http://schema.org/Restaurant' }
            ]
        )
    
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 13: Specifying multiple types for a node :)
declare %unit:test function test:example-13() 
{
    let $json :=
        map {
          "@id": "http://example.org/places#BrewEats",
          "@type": [ "http://schema.org/Restaurant", "http://schema.org/Brewery" ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@id', map {'@iri': 'http://example.org/places#BrewEats'}],
              ['@type', map {'@iri': 'http://schema.org/Restaurant'}],
              ['@type', map {'@iri': 'http://schema.org/Brewery'}]
            ]
        )
    
    (: @type and @id specified as attributes of @ even if there are multiple :)
    let $ex2 :=
        α:json(
            ['@', map {
              '@id': 'http://example.org/places#BrewEats',
              '@type': ('http://schema.org/Restaurant', 'http://schema.org/Brewery')}
            ]
        )
    
    (: using some sugar :)
    let $ex3 :=
        α:json(
            ['@', 
              α:id('http://example.org/places#BrewEats',
                    ('http://schema.org/Restaurant', 'http://schema.org/Brewery'))
            ]
        )
    
    return ($ex1,$ex2,$ex3) => test:each-equals($json)
};

(:~ EXAMPLE 14: Using a term to specify the type :)
declare %unit:test function test:example-14() 
{
    let $json :=
        map {
          "@context": map {
            "Restaurant": "http://schema.org/Restaurant", 
            "Brewery": "http://schema.org/Brewery"
          },
          "@id": "http://example.org/places#BrewEats",
          "@type": [ "Restaurant", "Brewery" ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['Restaurant', map {'@iri': 'http://schema.org/Restaurant'}],
                ['Brewery', map {'@iri': 'http://schema.org/Brewery'}]
              ],
              ['@id', map {'@iri': 'http://example.org/places#BrewEats'}],
              ['@type', map {'@term': 'Restaurant'}],
              ['@type', map {'@term': 'Brewery'}]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {
              '@id': 'http://example.org/places#BrewEats',
              '@type': ('Restaurant', 'Brewery')},
              ['@context',
                ['Restaurant', map {'@iri': 'http://schema.org/Restaurant'}],
                ['Brewery', map {'@iri': 'http://schema.org/Brewery'}]
              ]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 15: Use a relative IRI as node identifier :)
declare %unit:test function test:example-15() 
{
    let $json :=
        map {
          "@context": map {
            "label": "http://www.w3.org/2000/01/rdf-schema#label"
          },
          "@id": "",
          "label": "Just a simple document"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['label', map {'@iri': 'http://www.w3.org/2000/01/rdf-schema#label'}]
              ],
              ['@id', ''],
              ['label', 'Just a simple document']
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {'@id': ''},
              ['@context',
                ['label', map {'@iri': 'http://www.w3.org/2000/01/rdf-schema#label'}]
              ],
              ['label', 'Just a simple document']
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 16: Setting the document base in a document :)
declare %unit:test function test:example-16() 
{
    let $json :=
        map {
          "@context": map {
            "@base": "http://example.com/document.jsonld"
          },
          "@id": "",
          "label": "Just a simple document"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['@base', map {'@iri': 'http://example.com/document.jsonld'}]
              ],
              ['@id', ''],
              ['label', 'Just a simple document']
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {'@id': ''},
              ['@context',
                ['@base', map {'@iri': 'http://example.com/document.jsonld'}]
              ],
              ['label', 'Just a simple document']
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 17: Using a common vocabulary prefix :)
declare %unit:test function test:example-17() 
{
    let $json :=
        map {
          "@context": map {
            "@vocab": "http://schema.org/"
          },
          "@id": "http://example.org/places#BrewEats",
          "@type": "Restaurant",
          "name": "Brew Eats"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['@vocab', map {'@iri': 'http://schema.org/'}]
              ],
              ['@id', 'http://example.org/places#BrewEats'],
              ['@type', map {'@term': 'Restaurant'}],
              ['name', 'Brew Eats']
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {
              '@id': 'http://example.org/places#BrewEats',
              '@type': 'Restaurant'},
              ['@context',
                ['@vocab', map {'@iri': 'http://schema.org/'}]
              ],
              ['name', 'Brew Eats']
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 18: Using the null keyword to ignore data :)
declare %unit:test function test:example-18() 
{
    let $json :=
        map {
            "@context":
            map {
                "@vocab": "http://schema.org/",
                "databaseId": ()
            },
            "@id": "http://example.org/places#BrewEats",
            "@type": "Restaurant",
            "name": "Brew Eats",
            "databaseId": "23987520"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['@vocab', map {'@iri': 'http://schema.org/'}],
                ['databaseId']
              ],
              ['@id', map {'@iri': 'http://example.org/places#BrewEats'}],
              ['@type', map {'@term': 'Restaurant'}],
              ['name', 'Brew Eats'],
              ['databaseId', '23987520']
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {
              '@id': 'http://example.org/places#BrewEats',
              '@type': 'Restaurant'},
              ['@context',
                ['@vocab', map {'@iri': 'http://schema.org/'}],
                ['databaseId']
              ],
              ['name', 'Brew Eats'],
              ['databaseId', '23987520']
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 19: Prefix expansion :)
declare %unit:test function test:example-19() 
{
    let $json :=
        map {
          "@context":
          map {
            "foaf": "http://xmlns.com/foaf/0.1/"
          },
          "@type": "foaf:Person",
          "foaf:name": "Dave Longley"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context', 
                ['foaf', map { '@iri': 'http://xmlns.com/foaf/0.1/' }]
              ],
              ['@type', map {'@iri': 'foaf:Person'}],
              ['foaf:name', 'Dave Longley']
            ]
        )

    let $ex2 :=
        α:json(
            ['@', map {'@type': 'foaf:Person'},
              ['@context', 
                ['foaf', map { '@iri': 'http://xmlns.com/foaf/0.1/' }]
              ],
              ['foaf:name', 'Dave Longley']
            ]
        )
        
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 20: Using vocabularies :)
declare %unit:test function test:example-20() 
{
    let $json :=
        map {
          "@context":
          map {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "foaf": "http://xmlns.com/foaf/0.1/",
            "foaf:homepage": map { "@type": "@id" },
            "picture": map { "@id": "foaf:depiction", "@type": "@id" }
          },
          "@id": "http://me.markus-lanthaler.com/",
          "@type": "foaf:Person",
          "foaf:name": "Markus Lanthaler",
          "foaf:homepage": "http://www.markus-lanthaler.com/",
          "picture": "http://twitter.com/account/profile_image/markuslanthaler"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['foaf', map {'@iri': 'http://xmlns.com/foaf/0.1/'}],                
                ['foaf:homepage', map {'@type': '@id'}],
                ['picture', map {'@id': 'foaf:depiction', '@type': '@id'}]
              ],
              ['@id', map {'@iri': 'http://me.markus-lanthaler.com/'}],
              ['@type', map {'@iri': 'foaf:Person'}],
              ['foaf:name', 'Markus Lanthaler'],
              ['foaf:homepage', map {'@iri': 'http://www.markus-lanthaler.com/'}],
              ['picture', map {'@iri': 'http://twitter.com/account/profile_image/markuslanthaler'}]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {'@id': 'http://me.markus-lanthaler.com/', '@type': 'foaf:Person'},
              ['@context',
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['foaf', map {'@iri': 'http://xmlns.com/foaf/0.1/'}],                
                ['foaf:homepage', map {'@type': '@id'}],
                ['picture', map {'@id': 'foaf:depiction', '@type': '@id'}]
              ],
              ['foaf:name', 'Markus Lanthaler'],
              ['foaf:homepage', map {'@iri': 'http://www.markus-lanthaler.com/'}],
              ['picture', map {'@iri': 'http://twitter.com/account/profile_image/markuslanthaler'}]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 21: Expanded term definition with type coercion :)
declare %unit:test function test:example-21() 
{
    let $json :=
        map {
          "@context":
          map {
            "modified":
            map {
              "@id": "http://purl.org/dc/terms/modified",
              "@type": "http://www.w3.org/2001/XMLSchema#dateTime"
            }
          },
          "@id": "http://example.com/docs/1",
          "modified": xs:dateTime("2010-05-29T14:17:39+02:00")
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['modified', map {
                    '@id': 'http://purl.org/dc/terms/modified', 
                    '@type': 'http://www.w3.org/2001/XMLSchema#dateTime' }
                ]
              ],
              ['@id', map {'@iri': 'http://example.com/docs/1'}],
              ['modified', xs:dateTime("2010-05-29T14:17:39+02:00")]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {'@id': 'http://example.com/docs/1'},
              ['@context',
                ['modified', map {
                    '@id': 'http://purl.org/dc/terms/modified', 
                    '@type': 'http://www.w3.org/2001/XMLSchema#dateTime' }
                ]
              ],
              ['modified', xs:dateTime("2010-05-29T14:17:39+02:00")]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 22: Expanded value with type :)
declare %unit:test function test:example-22() 
{
    let $json :=
        map {
          "@context":
          map {
            "modified":
            map {
              "@id": "http://purl.org/dc/terms/modified"
            }
          },
          "modified":
          map {
            "@value": xs:dateTime('2010-05-29T14:17:39+02:00'),
            "@type": "http://www.w3.org/2001/XMLSchema#dateTime"
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['modified', map {
                    '@id': 'http://purl.org/dc/terms/modified'}
                ]
              ],
              ['modified', map {
                '@value': xs:dateTime('2010-05-29T14:17:39+02:00'),
                '@type': 'http://www.w3.org/2001/XMLSchema#dateTime'}
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 23: Example demonstrating the context-sensitivity for @type :)
declare %unit:test function test:example-23() 
{
    let $json :=
        map {
          "@id": "http://example.org/posts#TripToWestVirginia",
          "@type": "http://schema.org/BlogPosting",
          "modified":
          map {
            "@value": xs:dateTime("2010-05-29T14:17:39+02:00"),
            "@type": "http://www.w3.org/2001/XMLSchema#dateTime"
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@id', map {'@iri': 'http://example.org/posts#TripToWestVirginia'}],
              ['@type', map {'@iri': 'http://schema.org/BlogPosting'}],
              ['modified', map { 
                '@value': xs:dateTime('2010-05-29T14:17:39+02:00'), 
                '@type': 'http://www.w3.org/2001/XMLSchema#dateTime'}]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {
              '@id': 'http://example.org/posts#TripToWestVirginia',
              '@type': 'http://schema.org/BlogPosting'},
              ['modified', map { 
                '@value': xs:dateTime('2010-05-29T14:17:39+02:00'), 
                '@type': 'http://www.w3.org/2001/XMLSchema#dateTime'}]
            ]
        )

    let $ex3 :=
        α:json(
            ['@', α:id('http://example.org/posts#TripToWestVirginia','http://schema.org/BlogPosting'),
              ['modified', map { 
                '@value': xs:dateTime('2010-05-29T14:17:39+02:00'), 
                '@type': 'http://www.w3.org/2001/XMLSchema#dateTime'}]
            ]
        )
        
    return ($ex1,$ex2,$ex3) => test:each-equals($json)
};

(:~ EXAMPLE 24: Expanded term definition with types :)
declare %unit:test function test:example-24() 
{
    let $json :=
        map {
          "@context":
          map {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "http://xmlns.com/foaf/0.1/name",
            "age":
            map {
              "@id": "http://xmlns.com/foaf/0.1/age",
              "@type": "xsd:integer"
            },
            "homepage":
            map {
              "@id": "http://xmlns.com/foaf/0.1/homepage",
              "@type": "@id"
            }
          },
          "@id": "http://example.com/people#john",
          "name": "John Smith",
          "age": 41,
          "homepage":
              [
                "http://personal.example.org/",
                "http://work.example.com/jsmith/"
              ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                ['age', map {'@id': 'http://xmlns.com/foaf/0.1/age', '@type': 'xsd:integer'}],
                ['homepage', map {'@id': 'http://xmlns.com/foaf/0.1/homepage', '@type': '@id'}]
              ],
              ['@id', map {'@iri': 'http://example.com/people#john'}],
              ['name', 'John Smith'],
              ['age', 41],
              ['homepage', map {'@iri': 'http://personal.example.org/'}],
              ['homepage', map {'@iri': 'http://work.example.com/jsmith/'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 25: Term definitions using compact and absolute IRIs :)
declare %unit:test function test:example-25() 
{
    let $json :=
        map {
          "@context":
          map {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "foaf": "http://xmlns.com/foaf/0.1/",
            "foaf:age":
            map {
              "@id": "http://xmlns.com/foaf/0.1/age",
              "@type": "xsd:integer"
            },
            "http://xmlns.com/foaf/0.1/homepage":
            map {
              "@type": "@id"
            }
          },
          "foaf:name": "John Smith",
          "foaf:age": 41,
          "http://xmlns.com/foaf/0.1/homepage":
          [
            "http://personal.example.org/",
            "http://work.example.com/jsmith/"
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context', 
                  ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                  ['foaf', map {'@iri': 'http://xmlns.com/foaf/0.1/'}],
                  ['foaf:age', map {'@id': 'http://xmlns.com/foaf/0.1/age','@type': 'xsd:integer'}],
                  ['http://xmlns.com/foaf/0.1/homepage', map { '@type': '@id' }]
                ],
                ['foaf:name', 'John Smith'],
                ['foaf:age', 41],
                ['http://xmlns.com/foaf/0.1/homepage', map {'@iri': 'http://personal.example.org/'}],
                ['http://xmlns.com/foaf/0.1/homepage', map {'@iri': 'http://work.example.com/jsmith/'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 26: Embedding a node object as property value of another node object :)
declare %unit:test function test:example-26() 
{
    let $json :=
        map {
          "name": "Manu Sporny",
          "knows":
              map {
                "@type": "Person",
                "name": "Gregg Kellogg"
              }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['name', 'Manu Sporny'],
              ['knows',
                ['@', map {'@type': 'Person'},
                  ['name', 'Gregg Kellogg']
                ]
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 27: Using multiple contexts :)
declare %unit:test function test:example-27() 
{
    let $json :=
        [
          map {
            "@context": "http://example.org/contexts/person.jsonld",
            "name": "Manu Sporny",
            "homepage": "http://manu.sporny.org/",
            "depiction": "http://twitter.com/account/profile_image/manusporny"
          },
          map {
            "@context": "http://example.org/contexts/place.jsonld",
            "name": "The Empire State Building",
            "description": "The Empire State Building is a 102-story landmark in New York City.",
            "geo": map {
              "latitude": 40.75,
              "longitude": 73.98
            }
          }
        ]
    
    let $ex1 :=
        α:json(
            (
              ['@',
                ['@context', map {'@iri': 'http://example.org/contexts/person.jsonld'}],
                ['name', 'Manu Sporny'],
                ['homepage', map {'@iri': 'http://manu.sporny.org/'}],
                ['depiction', map {'@iri': 'http://twitter.com/account/profile_image/manusporny'}]
              ],
              ['@',
                ['@context', map {'@iri': 'http://example.org/contexts/place.jsonld'}],
                ['name', 'The Empire State Building'],
                ['description', 'The Empire State Building is a 102-story landmark in New York City.'],
                ['geo', ['latitude', 40.75], ['longitude', 73.98]]
              ]      
            )
        )
        
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 28: Scoped contexts within node objects :)
declare %unit:test function test:example-28() 
{
    let $json :=
        map {
            "@context":
            map {
              "name": "http://example.com/person#name",
              "details": "http://example.com/person#details"
            },
            "name": "Markus Lanthaler",
            "details":
            map {
              "@context":
              map {
                "name": "http://example.com/organization#name"
              },
              "name": "Graz University of Technology"
            }
          }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['name', map {'@iri': 'http://example.com/person#name'}],
                ['details', map {'@iri': 'http://example.com/person#details'}]
              ],
              ['name', 'Markus Lanthaler'],
              ['details',
                ['@context',
                  ['name', map {'@iri': 'http://example.com/organization#name'}]
                ],
                ['name', 'Graz University of Technology']
              ]
            ]
        )
        
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 29: Combining external and local contexts :)
declare %unit:test function test:example-29() 
{
    let $json :=
        map {
          "@context": [
            "http://json-ld.org/contexts/person.jsonld",
            map {
              "pic": "http://xmlns.com/foaf/0.1/depiction"
            }
          ],
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/",
          "pic": "http://twitter.com/account/profile_image/manusporny"
        }
    
    let $ex1 :=
        α:json(
            ['@', map {'@context': 'http://json-ld.org/contexts/person.jsonld'},
              ['@context',
                ['pic', map {'@iri': 'http://xmlns.com/foaf/0.1/depiction'}]
              ],
              ['name', 'Manu Sporny'],
              ['homepage', map {'@iri': 'http://manu.sporny.org/'}],
              ['pic', map {'@iri': 'http://twitter.com/account/profile_image/manusporny'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 31: Setting the default language of a JSON-LD document :)
declare %unit:test function test:example-31() 
{
    let $json :=
        map {
              "@context":
              map {
                "@language": "ja"
              },
              "name": "花澄",
              "occupation": "科学者"
            }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['@language', 'ja']
              ],
              ['name', '花澄'],
              ['occupation', '科学者']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 32: Clearing default language :)
declare %unit:test function test:example-32() 
{
    let $json :=
        map {
          "@context": map {
            "@language": "ja"
          },
          "name": "花澄",
          "details": map {
            "@context": map {
              "@language": ()
            },
            "occupation": "Ninja"
          }
        }
    
    let $ex1 :=
        α:json(
            ['@', 
                ['@context', map {'@language': 'ja'}],
                ['name', '花澄'],
                ['details', 
                    ['@context', map {'@language': ()}],
                    ['occupation', 'Ninja']
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 33: Expanded term definition with language :)
declare %unit:test function test:example-33() 
{
    let $json :=
        map {
          "@context": map {
            "ex": "http://example.com/vocab/",
            "@language": "ja",
            "name": map { "@id": "ex:name", "@language": () },
            "occupation": map { "@id": "ex:occupation" },
            "occupation_en": map { "@id": "ex:occupation", "@language": "en" },
            "occupation_cs": map { "@id": "ex:occupation", "@language": "cs" }
          },
          "name": "Yagyū Muneyoshi",
          "occupation": "忍者",
          "occupation_en": "Ninja",
          "occupation_cs": "Nindža"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['ex', map {'@iri': 'http://example.com/vocab/'}],
                ['@language', 'ja'],
                ['name', map {'@id': 'ex:name', '@language': () }],
                ['occupation', map {'@id': 'ex:occupation'}],
                ['occupation_en', map {'@id': 'ex:occupation', '@language': 'en'}],
                ['occupation_cs', map {'@id': 'ex:occupation', '@language': 'cs'}]        
              ],
              ['name', 'Yagyū Muneyoshi'],
              ['occupation', '忍者'],
              ['occupation_en', 'Ninja'],
              ['occupation_cs', 'Nindža']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 34: Language map expressing a property in three languages :)
declare %unit:test function test:example-34() 
{
    let $json :=
        map {
          "@context":
          map {
            "occupation": map { "@id": "ex:occupation", "@container": "@language" }
          },
          "name": "Yagyū Muneyoshi",
          "occupation":
          map {
            "ja": "忍者",
            "en": "Ninja",
            "cs": "Nindža"
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['occupation', map {'@id': 'ex:occupation', '@container': '@language'}]
              ],
              ['name', 'Yagyū Muneyoshi'],
              ['occupation',
                ['ja', '忍者'],
                ['en', 'Ninja'],
                ['cs', 'Nindža']
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 35: Overriding default language using an expanded value :)
declare %unit:test function test:example-35() 
{
    let $json :=
        map {
          "@context": map {
            "@language": "ja"
          },
          "name": "花澄",
          "occupation": map {
            "@value": "Scientist",
            "@language": "en"
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['@language', 'ja']
              ],
              ['name', '花澄'],
              ['occupation', map {'@language': 'en'}, 'Scientist']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 36: Removing language information using an expanded value :)
declare %unit:test function test:example-36() 
{
    let $json :=
        map {
          "@context": map {
            "@language": "ja"
          },
          "name": map {
            "@value": "Frank"
          },
          "occupation": map {
            "@value": "Ninja",
            "@language": "en"
          },
          "specialty": "手裏剣"
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['@language', 'ja']
              ],
              ['name', map {'@value': 'Frank'}],
              ['occupation', map {'@language': 'en', '@value': 'Ninja'}],
              ['specialty', '手裏剣']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 37: IRI expansion within a context :)
declare %unit:test function test:example-37() 
{
    let $json :=
        map {
          "@context":
          map {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "http://xmlns.com/foaf/0.1/name",
            "age":
            map {
              "@id": "http://xmlns.com/foaf/0.1/age",
              "@type": "xsd:integer"
            },
            "homepage":
            map {
              "@id": "http://xmlns.com/foaf/0.1/homepage",
              "@type": "@id"
            }
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                ['age', map {'@id': 'http://xmlns.com/foaf/0.1/age', '@type': 'xsd:integer'}],
                ['homepage', map {'@id': 'http://xmlns.com/foaf/0.1/homepage', '@type': '@id'}]                
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 38: Using a term to define the IRI of another term within a context :)
declare %unit:test function test:example-38() 
{
    let $json :=
        map {
          "@context":
          map {
            "foaf": "http://xmlns.com/foaf/0.1/",
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "foaf:name",
            "age":
            map {
              "@id": "foaf:age",
              "@type": "xsd:integer"
            },
            "homepage":
            map {
              "@id": "foaf:homepage",
              "@type": "@id"
            }
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['foaf', map {'@iri': 'http://xmlns.com/foaf/0.1/'}],
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['name', map {'@iri': 'foaf:name'}],
                ['age', map {'@id': 'foaf:age', '@type': 'xsd:integer'}],
                ['homepage', map {'@id': 'foaf:homepage', '@type': '@id'}]                
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 39: Using a compact IRI as a term :)
declare %unit:test function test:example-39() 
{
    let $json :=
        map {
          "@context":
          map {
            "foaf": "http://xmlns.com/foaf/0.1/",
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "foaf:name",
            "foaf:age":
            map {
              "@type": "xsd:integer"
            },
            "foaf:homepage":
            map {
              "@type": "@id"
            }
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['foaf', map {'@iri': 'http://xmlns.com/foaf/0.1/'}],
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['name', map {'@iri': 'foaf:name'}],
                ['foaf:age', map {'@type': 'xsd:integer'}],
                ['foaf:homepage', map {'@type': '@id'}]                
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 40: Associating context definitions with absolute IRIs :)
declare %unit:test function test:example-40() 
{
    let $json :=
        map {
          "@context":
          map {
            "foaf": "http://xmlns.com/foaf/0.1/",
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "foaf:name",
            "foaf:age":
            map {
              "@id": "foaf:age",
              "@type": "xsd:integer"
            },
            "http://xmlns.com/foaf/0.1/homepage":
            map {
              "@type": "@id"
            }
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['foaf', map {'@iri': 'http://xmlns.com/foaf/0.1/'}],
                ['xsd', map {'@iri': 'http://www.w3.org/2001/XMLSchema#'}],
                ['name', map {'@iri': 'foaf:name'}],
                ['foaf:age', map {'@id': 'foaf:age', '@type': 'xsd:integer'}],
                ['http://xmlns.com/foaf/0.1/homepage', map {'@type': '@id'}]                
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 41: Illegal circular definition of terms within a context :)
declare %unit:test function test:example-41() 
{
    let $json :=
        map {
          "@context":
          map {
            "term1": "term2:foo",
            "term2": "term1:bar"
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['term1', map {'@iri': 'term2:foo'}],
                ['term2', map {'@iri': 'term1:bar'}]
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 42: Multiple values with no inherent order :)
declare %unit:test function test:example-42() 
{
    let $json :=
        map {
          "@id": "http://example.org/people#joebob",
          "nick": [ "joe", "bob", "JB" ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@id', map {'@iri': 'http://example.org/people#joebob' }],
              ['nick', 'joe'],
              ['nick', 'bob'],
              ['nick', 'JB']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 43: Using an expanded form to set multiple values :)
declare %unit:test %unit:ignore function test:example-43() 
{
    let $json :=
        map {
          "@id": "http://example.org/articles/8",
          "dc:title": 
          [
            map {
              "@value": "Das Kapital",
              "@language": "de"
            },
            map {
              "@value": "Capital",
              "@language": "en"
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@id', map {'@iri': 'http://example.org/articles/8' }],
              ['dc:title', map {'@language': 'de'}, 'Das Kapital'],
              ['dc:title', map {'@language': 'en'}, 'Capital']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 43: Using an expanded form to set multiple values (alternative) :)
declare %unit:test %unit:ignore function test:example-43-alternative() 
{
    let $json :=
        map {
          "@id": "http://example.org/articles/8",
          "dc:title": 
          [
            map {
              "@value": "Das Kapital",
              "@language": "de"
            },
            map {
              "@value": "Capital",
              "@language": "en"
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@id', map {'@iri': 'http://example.org/articles/8' }],
              ['dc:title', 
                ['@item', map {'@language': 'de'}, 'Das Kapital'],
                ['@item', map {'@language': 'en'}, 'Capital']
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 44: An ordered collection of values in JSON-LD :)
declare %unit:test %unit:ignore function test:example-44() 
{
    let $json :=
        map {
          "@id": "http://example.org/people#joebob",
          "foaf:nick":
          map {
            "@list": [ "joe", "bob", "jaybee" ]
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@id', map {'@iri': 'http://example.org/people#joebob' }],
              ['foaf:nick', 
                ['@li', 'joe'],
                ['@li', 'bob'],
                ['@li', 'jaybee']
              ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 45: Specifying that a collection is ordered in the context :)
declare %unit:test %unit:ignore function test:example-45() 
{
    let $json :=
        map {
          "@context":
          map {
            "nick":
            map {
              "@id": "http://xmlns.com/foaf/0.1/nick",
              "@container": "@list"
            }
          },
          "@id": "http://example.org/people#joebob",
          "nick": [ "joe", "bob", "jaybee" ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
              ['@context',
                ['nick', map { 
                    '@id': 'http://xmlns.com/foaf/0.1/nick', 
                    '@container': '@list'}]
              ],
              ['@id', map {'@iri': 'http://example.org/people#joebob' }],
              ['foaf:nick', 'joe'],
              ['foaf:nick', 'bob'],
              ['foaf:nick', 'jaybee']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 46: A document with children linking to their parent :)
declare %unit:test %unit:ignore function test:example-46() 
{
    let $json :=
        [
              map {
                "@id": "#homer",
                "http://example.com/vocab#name": "Homer"
              },
              map {
                "@id": "#bart",
                "http://example.com/vocab#name": "Bart",
                "http://example.com/vocab#parent": map { "@id": "#homer" }
              },
              map {
                "@id": "#lisa",
                "http://example.com/vocab#name": "Lisa",
                "http://example.com/vocab#parent": map { "@id": "#homer" }
              }
        ]
    
    let $ex1 :=
        α:json(
            (
                ['@',
                    map {'@id': '#homer'},
                    ['http://example.com/vocab#name', 'Homer']
                ],
                ['@',
                    map {'@id': '#bart'},
                    ['http://example.com/vocab#name', 'Bart'],
                    ['http://example.com/vocab#parent', map { '@id': '#homer'}]
                ],                
                ['@',
                    map {'@id': '#lisa'},
                    ['http://example.com/vocab#name', 'Lisa'],
                    ['http://example.com/vocab#parent', map { '@id': '#homer'}]
                ]         
            )
        )
        
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 47: A person and its children using a reverse property :)
declare %unit:test %unit:ignore function test:example-47() 
{
    let $json :=
        map {
          "@id": "#homer",
          "http://example.com/vocab#name": "Homer",
          "@reverse": map {
            "http://example.com/vocab#parent": [
              map {
                "@id": "#bart",
                "http://example.com/vocab#name": "Bart"
              },
              map {
                "@id": "#lisa",
                "http://example.com/vocab#name": "Lisa"
              }
            ]
          }
        }
    
    let $ex1 :=
        α:json(
            ['@', map {'@id': '#homer'},
                ['http://example.com/vocab#name', 'Homer'],
                ['@reverse',
                    ['http://example.com/vocab#parent',
                        ['@', 
                            map {'@id': '#bart'},
                            ['http://example.com/vocab#name', 'Bart']
                        ],
                        ['@', 
                            map {'@id': '#lisa'},
                            ['http://example.com/vocab#name', 'Lisa']
                        ]
                    ]
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 48: Using @reverse to define reverse properties :)
declare %unit:test %unit:ignore function test:example-48() 
{
    let $json :=
        map {
          "@context": map {
            "name": "http://example.com/vocab#name",
            "children": map { "@reverse": "http://example.com/vocab#parent" }
          },
          "@id": "#homer",
          "name": "Homer",
          "children": [
            map {
              "@id": "#bart",
              "name": "Bart"
            },
            map {
              "@id": "#lisa",
              "name": "Lisa"
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@', map {'@id': '#homer'},
                ['@context',
                    ['name', map {'@iri': 'http://example.com/vocab#name'}],
                    ['children', map{'@reverse': 'http://example.com/vocab#parent'}]
                ],
                ['name', 'Homer'],
                ['children',
                    ['@', map {'@id': '#bart'}, ['name', 'Bart']],
                    ['@', map {'@id': '#lisa'}, ['name', 'Lisa']]
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 49: Identifying and making statements about a graph :)
declare %unit:test %unit:ignore function test:example-49() 
{
    let $json :=
        map {
          "@context": map {
            "generatedAt": map {
              "@id": "http://www.w3.org/ns/prov#generatedAtTime",
              "@type": "http://www.w3.org/2001/XMLSchema#date"
            },
            "Person": "http://xmlns.com/foaf/0.1/Person",
            "name": "http://xmlns.com/foaf/0.1/name",
            "knows": "http://xmlns.com/foaf/0.1/knows"
          },
          "@id": "http://example.org/graphs/73",
          "generatedAt": "2012-04-09",
          "@graph":
          [
            map {
              "@id": "http://manu.sporny.org/about#manu",
              "@type": "Person",
              "name": "Manu Sporny",
              "knows": "http://greggkellogg.net/foaf#me"
            },
            map {
              "@id": "http://greggkellogg.net/foaf#me",
              "@type": "Person",
              "name": "Gregg Kellogg",
              "knows": "http://manu.sporny.org/about#manu"
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context',
                    ['generatedAt', 
                        map {
                            '@id': 'http://www.w3.org/ns/prov#generatedAtTime', 
                            '@type': 'http://www.w3.org/2001/XMLSchema#date'
                        }],
                    ['Person', map { '@iri': 'http://xmlns.com/foaf/0.1/Person'}],
                    ['name', map { '@iri': 'http://xmlns.com/foaf/0.1/name'}],
                    ['knowns', map { '@iri': 'http://xmlns.com/foaf/0.1/knows'}]
                ],
                ['generatedAt', xs:date('2012-04-09')],
                ['@graph',
                    ['@', map {
                        '@id': 'http://manu.sporny.org/about#manu', 
                        '@type': 'Person'},
                        ['name', 'Manu Sporny'],
                        ['knows', map {'@iri': 'http://greggkellogg.net/foaf#me'}]
                    ],
                    ['@', map {
                        '@id': 'http://greggkellogg.net/foaf#me', 
                        '@type': 'Person'},
                        ['name', 'Greg Kellogg'],
                        ['knows', map {'@iri': 'http://manu.sporny.org/about#manu'}]
                    ]
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 50: Using @graph to explicitly express the default graph :)
declare %unit:test %unit:ignore function test:example-50() 
{
    let $json :=
        map {
          "@context": map {},
          "@graph":
          [
            map {
              "@id": "http://manu.sporny.org/about#manu",
              "@type": "foaf:Person",
              "name": "Manu Sporny",
              "knows": "http://greggkellogg.net/foaf#me"
            },
            map {
              "@id": "http://greggkellogg.net/foaf#me",
              "@type": "foaf:Person",
              "name": "Gregg Kellogg",
              "knows": "http://manu.sporny.org/about#manu"
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context', map {}],
                ['@graph',
                    ['@', map {
                        '@id': 'http://manu.sporny.org/about#manu', 
                        '@type': 'Person'},
                        ['name', 'Manu Sporny'],
                        ['knows', map {'@iri': 'http://greggkellogg.net/foaf#me'}]
                    ],
                    ['@', map {
                        '@id': 'http://greggkellogg.net/foaf#me', 
                        '@type': 'Person'},
                        ['name', 'Greg Kellogg'],
                        ['knows', map {'@iri': 'http://manu.sporny.org/about#manu'}]
                    ]                        
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 51: Context needs to be duplicated if @graph is not used :)
declare %unit:test %unit:ignore function test:example-51() 
{
    let $json :=
        [
          map {
            "@context": map {},
            "@id": "http://manu.sporny.org/about#manu",
            "@type": "foaf:Person",
            "name": "Manu Sporny",
            "knows": "http://greggkellogg.net/foaf#me"
          },
          map {
            "@context": map {},
            "@id": "http://greggkellogg.net/foaf#me",
            "@type": "foaf:Person",
            "name": "Gregg Kellogg",
            "knows": "http://manu.sporny.org/about#manu"
          }
        ]
    
    let $ex1 :=
        α:json(
            (
                ['@', map {
                    '@id': 'http://manu.sporny.org/about#manu',
                    '@type': 'foaf:Person'},
                    ['@context', map {}],
                    ['name', 'Manu Sporny'],
                    ['knowns', map {'@iri': 'http://greggkellogg.net/foaf#me'}]
                ],
                ['@', map {
                    '@id': 'http://greggkellogg.net/foaf#me',
                    '@type': 'foaf:Person'},
                    ['@context', map {}],
                    ['name', 'Gregg Kellogg'],
                    ['knowns', map {'@iri': 'http://manu.sporny.org/about#manu'}]
                ]
            )
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 52: Specifying a local blank node identifier :)
declare %unit:test %unit:ignore function test:example-52() 
{
    let $json :=
        map {
           "@id": "_:n1",
           "name": "Secret Agent 1",
           "knows":
             map {
               "name": "Secret Agent 2",
               "knows": map { "@id": "_:n1" }
             }
        }
    
    let $ex1 :=
        α:json(
            ['@', map { '@id': '_:n1'},
                ['name', 'Secret Agent 1'],
                ['knowns',
                    ['@',
                        ['name', 'Secret Agent 2'],
                        ['knows', map { '@id': '_:n1'}]
                    ]
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 53: Aliasing keywords :)
declare %unit:test %unit:ignore function test:example-53() 
{
    let $json :=
        map {
          "@context":
          map {
             "url": "@id",
             "a": "@type",
             "name": "http://xmlns.com/foaf/0.1/name"
          },
          "url": "http://example.com/about#gregg",
          "a": "http://xmlns.com/foaf/0.1/Person",
          "name": "Gregg Kellogg"
        }
    
    let $ex1 :=
        α:json(
            ['@'
                ['@context',
                    ['url', '@id'],
                    ['a', '@type'],
                    ['name', map { '@iri': 'http://xmlns.com/foaf/0.1/name'}]
                ],
                ['url', map { '@iri': 'http://example.com/about#gregg'}],
                ['a', map { '@iri': 'http://xmlns.com/foaf/0.1/Person'}],
                ['name', 'Gregg Kellogg']
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 54: Indexing data :)
declare %unit:test %unit:ignore function test:example-54() 
{
    let $json :=
        map {
          "@context":
          map {
             "schema": "http://schema.org/",
             "name": "schema:name",
             "body": "schema:articleBody",
             "words": "schema:wordCount",
             "post": map {
               "@id": "schema:blogPost",
               "@container": "@index"
             }
          },
          "@id": "http://example.com/",
          "@type": "schema:Blog",
          "name": "World Financial News",
          "post": map {
             "en": map {
               "@id": "http://example.com/posts/1/en",
               "body": "World commodities were up today with heavy trading of crude oil...",
               "words": 1539
             },
             "de": map {
               "@id": "http://example.com/posts/1/de",
               "body": "Die Werte an Warenbörsen stiegen im Sog eines starken Handels von Rohöl...",
               "words": 1204
             }
          }
        }
    
    let $ex1 :=
        α:json(
            ['@', map { '@id': 'http://example.com/', '@type': 'schema:Blog'},
                ['@context',
                    ['schema', map { '@iri': 'http://schema.org/'}],
                    ['name', map { '@iri': 'schema:name'}],
                    ['body', map { '@iri': 'schema:articleBody'}],
                    ['words', map { '@iri': 'schema:wordCount'}]
                    ['post', map { 
                        '@id': 'schema:blogPost',
                        '@container': '@index'}]
                ],
                ['name', 'World Financial News'],
                ['post',
                    ['en', map {'@id': 'http://example.com/posts/1/en'},
                        ['body', 'World commodities were up today with heavy trading of crude oil...'],
                        ['words', 1539]
                    ],
                    ['en', map {'@id': 'http://example.com/posts/1/de'},
                        ['body', 'Die Werte an Warenbörsen stiegen im Sog eines starken Handels von Rohöl...'],
                        ['words', 1204]
                    ]
                ]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 55: Sample JSON-LD document :)
declare %unit:test %unit:ignore function test:example-55() 
{
    let $json :=
        map {
           "@context":
           map {
              "name": "http://xmlns.com/foaf/0.1/name",
              "homepage": map {
                "@id": "http://xmlns.com/foaf/0.1/homepage",
                "@type": "@id"
              }
           },
           "name": "Manu Sporny",
           "homepage": "http://manu.sporny.org/"
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context',
                    ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                    ['homepage', map {
                        '@id': 'http://xmlns.com/foaf/0.1/homepage', 
                        '@type': '@id'}]
                ],
                ['name', 'Manu Sporny'],
                ['homepage', map {'@iri': 'http://manu.sporny.org/'}]
            ]
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 56: Expanded form for the previous example :)
declare %unit:test %unit:ignore function test:example-56() 
{
    let $json := 
      [
        map {
          "http://xmlns.com/foaf/0.1/name": [
            map { "@value": "Manu Sporny" }
          ],
          "http://xmlns.com/foaf/0.1/homepage": [
            map { "@id": "http://manu.sporny.org/" }
          ]
        }
      ]
    let $ex1 :=
        α:json(
            ['@',
                ['http://xmlns.com/foaf/0.1/name',
                    ['@value', 'Manu Sporny']
                ],
                ['http://xmlns.com/foaf/0.1/homepage',
                    ['@id', 'http://manu.sporny.org/']
                ]
            ]
        )

    let $ex2 :=
        α:json(
            ['@',
                ['http://xmlns.com/foaf/0.1/name',
                    map {'@value': 'Manu Sporny'}
                ],
                ['http://xmlns.com/foaf/0.1/homepage',
                    map {'@id': 'http://manu.sporny.org/'}
                ]
            ]
        )
        
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 57: Sample expanded JSON-LD document :)
declare %unit:test %unit:ignore function test:example-57() 
{
    let $json :=
        [
          map {
            "http://xmlns.com/foaf/0.1/name": [ "Manu Sporny" ],
            "http://xmlns.com/foaf/0.1/homepage": [
              map {
               "@id": "http://manu.sporny.org/"
              }
            ]
          }
        ]
    
    let $ex1 :=
        α:json(
            (
                ['@',
                    ['http://xmlns.com/foaf/0.1/name',
                        ['@seq', 'Manu Sporny']
                    ],
                    ['http://xmlns.com/foaf/0.1/homepage',
                        ['@seq', map {'@id': 'http://manu.sporny.org/'}]
                    ]
                ]
            )
        )
    
    return ($ex1) => test:each-equals($json)
};

(:~ EXAMPLE 58: Sample context :)
declare %unit:test %unit:ignore function test:example-58() 
{
    let $json :=
        map {
          "@context": map {
            "name": "http://xmlns.com/foaf/0.1/name",
            "homepage": map {
              "@id": "http://xmlns.com/foaf/0.1/homepage",
              "@type": "@id"
            }
          }
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context',
                    ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                    ['homepage', map {
                        '@id': 'http://xmlns.com/foaf/0.1/homepage', 
                        '@type': '@id'}]
                ]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@',
                ['@context',
                    ['name', 'http://xmlns.com/foaf/0.1/name'],
                    ['homepage', map {
                        '@id': 'http://xmlns.com/foaf/0.1/homepage', 
                        '@type': '@id'}]
                ]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 59: Compact form of the sample document once sample context has been applied :)
declare %unit:test %unit:ignore function test:example-59() 
{
    let $json :=
        map {
          "@context": map {
            "name": "http://xmlns.com/foaf/0.1/name",
            "homepage": map {
              "@id": "http://xmlns.com/foaf/0.1/homepage",
              "@type": "@id"
            }
          },
          "name": "Manu Sporny",
          "homepage": "http://manu.sporny.org/"
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context',
                    ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                    ['homepage', map {
                        '@id': 'http://xmlns.com/foaf/0.1/homepage', 
                        '@type': '@id'}]
                ],
                ['name', 'Manu Sporny'],
                ['homepage', map {'@iri': 'http://manu.sporny.org/'}]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@',
                ['@context',
                    ['name','http://xmlns.com/foaf/0.1/name'],
                    ['homepage', map {
                        '@id': 'http://xmlns.com/foaf/0.1/homepage', 
                        '@type': '@id'}]
                ],
                ['name', 'Manu Sporny'],
                ['homepage', map {'@iri': 'http://manu.sporny.org/'}]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 60: Sample JSON-LD document :)
declare %unit:test %unit:ignore function test:example-60() 
{
    let $json :=
        map {
          "@context": map {
            "name": "http://xmlns.com/foaf/0.1/name",
            "knows": "http://xmlns.com/foaf/0.1/knows"
          },
          "@id": "http://me.markus-lanthaler.com/",
          "name": "Markus Lanthaler",
          "knows": [
            map {
              "@id": "http://manu.sporny.org/about#manu",
              "name": "Manu Sporny"
            },
            map {
              "name": "Dave Longley"
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@', map {'@id': 'http://me.markus-lanthaler.com/'},
                ['@context',
                    ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                    ['knows', map {'@iri': 'http://xmlns.com/foaf/0.1/knows'}]
                ],
                ['name', 'Markus Lanthaler'],
                ['knows',
                    ['@', map {
                        '@id': 'http://manu.sporny.org/about#manu'}, 
                        ['name', 'Manu Sporny']],
                    ['@', 
                        ['name', 'Dave Longley']]
                ]
            ]
        )
    
    let $ex2 :=
        α:json(
            ['@', map {'@id': 'http://me.markus-lanthaler.com/'},
                ['@context',
                    ['name', 'http://xmlns.com/foaf/0.1/name'],
                    ['knows', 'http://xmlns.com/foaf/0.1/knows']
                ],
                ['name', 'Markus Lanthaler'],
                ['knows',
                    ['@', map {'@id': 'http://manu.sporny.org/about#manu'}, 
                        ['name', 'Manu Sporny']],
                    ['@', 
                        ['name', 'Dave Longley']]
                ]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};


(:~ EXAMPLE 61: Flattened and compacted form for the previous example :)
declare %unit:test %unit:ignore function test:example-61() 
{
    let $json :=
        map {
          "@context": map {
            "name": "http://xmlns.com/foaf/0.1/name",
            "knows": "http://xmlns.com/foaf/0.1/knows"
          },
          "@graph": [
            map {
              "@id": "_:b0",
              "name": "Dave Longley"
            },
            map {
              "@id": "http://manu.sporny.org/about#manu",
              "name": "Manu Sporny"
            },
            map {
              "@id": "http://me.markus-lanthaler.com/",
              "name": "Markus Lanthaler",
              "knows": [
                map { "@id": "http://manu.sporny.org/about#manu" },
                map { "@id": "_:b0" }
              ]
            }
          ]
        }
    
    let $ex1 :=
        α:json(
            ['@',
                ['@context',
                    ['name', map {'@iri': 'http://xmlns.com/foaf/0.1/name'}],
                    ['knows', map {'@iri': 'http://xmlns.com/foaf/0.1/knows'}]
                ],
                ['@graph',
                    ['@', map {'@id': '_:b0'},
                        ['name', 'Dave Longley']
                    ],
                    ['@', map {'@id': 'http://manu.sporny.org/about#manu'},
                        ['name', 'Manu Sporny']
                    ]
                    ['@', map {'@id': 'http://me.markus-lanthaler.com/'},
                        ['name', 'Markus Lanthaler'],
                        ['knows',
                            ['@id', map {'@iri': 'http://manu.sporny.org/about#manu'}],
                            ['@id', map {'@iri': '_:b0'}]
                        ]
                    ]
                ]
            ]
        )
    
    (: an @id element either has a map or a plain IRI string :)
    (: inside @context element a plain string is also interpreted as an IRI :)
    let $ex2 :=
        α:json(
            ['@',
                ['@context',
                    ['name', 'http://xmlns.com/foaf/0.1/name'],
                    ['knows', 'http://xmlns.com/foaf/0.1/knows']
                ],
                ['@graph',
                    ['@', map {'@id': '_:b0'},
                        ['name', 'Dave Longley']
                    ],
                    ['@', map {'@id': 'http://manu.sporny.org/about#manu'},
                        ['name', 'Manu Sporny']
                    ]
                    ['@', map {'@id': 'http://me.markus-lanthaler.com/'},
                        ['name', 'Markus Lanthaler'],
                        ['knows',
                            ['@id', 'http://manu.sporny.org/about#manu'],
                            ['@id', '_:b0']
                        ]
                    ]
                ]
            ]
        )
    
    return ($ex1,$ex2) => test:each-equals($json)
};

(:~ EXAMPLE 62: Embedding JSON-LD in HTML :)
declare %unit:test %unit:ignore function test:example-62() 
{
    let $html :=
        <script type="application/ld+json">{
            α:json(
                ['@', map {
                    '@id': 'http://dbpedia.org/resource/John_Lennon',
                    '@context': 'http://json-ld.org/contexts/person.jsonld'},
                    ['name', 'John Lennon'],
                    ['born', xs:date('1940-10-09')],
                    ['spouse', map {'@iri': 'http://dbpedia.org/resource/Cynthia_Lennon'}]
                ]
            )   
        }</script>
    
    let $ex1 :=
        map {}
    
    return ($ex1) => test:each-equals($html)
};
