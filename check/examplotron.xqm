xquery version "3.1";

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare namespace eg = 'http://examplotron.org/0/';
declare namespace a = 'http://relaxng.org/ns/compatibility/annotations/1.0';
declare namespace ega = 'http://examplotron.org/annotations/';
declare namespace rng = 'http://relaxng.org/ns/structure/1.0';
declare namespace sch = 'http://www.ascc.net/xml/schematron';

(: using Origami to implement an Examplotron-like contraption :)

(:~
 : Use a document with it's annotations to generate a RelaxNG schema.
 : Based on Eric van der Vlist's http://examplotron.org/compile.xsl
 :)
declare function ex:generate-schema($xml)
{
    o:doc($xml,
        ['/*',
            function($n) {
                ['grammar',
                    map {
                        'dataTypeLibrary': 'http://www.w3.org/2001/XMLSchema-datatypes'
                    },
                    ['start',
                        o:apply(o:children($n))
                    ],
                    o:apply(o:children($n))
                ]
            },
            ['*', 
                function($n) {
                    1
                }
            ],
            ['eg:*',
                function($n) {
                    1
                }
            ],
            ['eg:attribute/@*',
                function($n) {
                    1
                }
            ],
            ['eg:attribute',
                function($n) {
                    1
                }
            ]
            
            
        ]
    )
};
