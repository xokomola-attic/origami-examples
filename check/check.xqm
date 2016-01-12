xquery version "3.1";

module namespace qt = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

(:~
 : Basic concept: compose generator functions that produce argument lists for
 : each iteration. The argument list for each iteration is applied to the test 
 : function, each should return true, but an exception may be generated too.
 : The results can be returned in summary or as a large data-structure.
 : Reproducability is achieved by using and recording a seed so if we know the
 : seed we can re-run the tests.
 :)

(: TODO: check if this is really the maximum/minimum for xs:integer? It should be unbounded :)
declare variable $qt:min-integer := -854775808;
declare variable $qt:max-integer := 854775808;
declare variable $qt:max-seq := 20;

declare variable $qt:iterations := 100;

(:~
 : Having some fun with the QuickCheck concept using generative
 : testing for XML.
 :
 : To avoid combinatorial explosion the results should be treated
 : as a search space with the possibility to "zoom" in problematic
 : siutations.
 :)

(:~
 : Build the argument arrays for function application.
 :)
 
(: TODO: how to keep seq identity / avoid flattening :)

declare function qt:gen-args($tests as item()*)
{
    if ($tests instance of array(*)) then
        switch (o:tag($tests))
        case 'qt:array' return 
            o:children($tests) ! [ qt:gen-args(.) ]
        case 'qt:seq' return
            o:children($tests) ! qt:gen-args(.)
        default return
            o:children($tests)
    else
        $tests
};

(:~
 : Use the generators to test a function.
 :)
declare function qt:check($check as function(*), $gen as item()*)
{
    qt:check($qt:iterations, $check, $gen)
};

declare function qt:check($iterations, $check, $gen)
{
    qt:check($iterations, $check, $gen, false())
};

declare function qt:check($iterations, $check, $gen, $include-tests as xs:boolean)
{
    let $seed := random:integer()
    let $tests := $gen($seed, $iterations)
    let $calls := [ qt:gen-args($tests) ]
    return
        ['qt:check',
            map {
                'num-tests': $iterations,
                'seed': $seed,
                'tests': if ($include-tests) then $tests else (),
                'result': 
                    every $result in (
                        for $args in $calls
                        let $result := 
                            try {
                                apply($check, $args)
                            } catch * {
                                'Error [' || $err:code || ']: ' || $err:description
                            }
                        return
                            $result = true()
                    ) satisfies true()
            }
        ]
};

(:~
 : An XML generator is a Mu data structure with handlers for elements
 : and attributes. These will be invoked when generating.
 : It is similar to Origami apply. The node handlers are the generators
 : that produce new nodes or atomic values.
 :)
declare function qt:generate-xml($schema)
{
1    
};

(:~
 : Return a random integers (implementation dependent)
 :)
declare function qt:integer()
{
    qt:integer($qt:min-integer,$qt:max-integer)
};

(:~
 : Return a random number between `$min` (inclusive) and `$max` (exclusive).
 :)
declare function qt:integer($min as xs:integer, $max as xs:integer)
{
    function($s,$i) {
        array {'qt:seq', 
            map { 
                'seed': $s, 
                'num': $i, 
                'max': $max, 
                'min': $min
            },
            for $integer in random:seeded-integer($s, $i, $max - $min)
            return
                xs:integer($integer + $min)
        }
    }
};

declare function qt:seq($gen as function(*))
{
    let $sizes := qt:integer(1,$qt:max-seq + 1)
    return
        function($s,$i) as array(*)* {
            array {
                'qt:seq',
                map { 
                    'seed': $s, 
                    'num': $i, 
                    'max': $qt:max-seq + 1
                },
                let $seeds := random:seeded-integer($s, $i, $qt:max-integer)
                for $size at $j in o:children($sizes($s,$i))
                return
                    $gen($seeds[$j],$size)
            }
        }
};

declare function qt:array($gen as function(*))
{
    let $sizes := qt:integer(1,$qt:max-seq + 1)
    return
        function($s,$i) as array(*)* {
            array {
                'qt:array',
                map { 
                    'seed': $s, 
                    'num': $i, 
                    'max': $qt:max-seq + 1
                },
                let $seeds := random:seeded-integer($s, $i, $qt:max-integer)
                for $size at $j in o:children($sizes($s,$i))
                return
                    $gen($seeds[$j],$size)
            }
        }
};