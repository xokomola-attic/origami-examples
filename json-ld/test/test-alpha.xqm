xquery version "3.1";

module namespace test = 'http://xokomola.com/xquery/origami/tests';

(:~
 : Tests for JSON-LD transform collect-keys#1
 :)

import module namespace α = 'http://xokomola.com/xquery/origami/α' 
    at '../alpha.xqm'; 

declare %unit:test function test:collect-keys()
{
    unit:assert-equals(
        α:collect-keys(
            ['a',1]), 
        map {'a': 1}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            (['a',1],['b',2])), 
        map {'a': 1, 'b': 2}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            (['a',1],['b',2],['a',3])), 
        map {'a': (1,3), 'b': 2}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            ()), 
        map {}
    ), 
       
    unit:assert-equals(
        α:collect-keys(
            'foo'), 
        map {'&amp;': 'foo'}
    ), 
       
    unit:assert-equals(
        α:collect-keys(
            ('foo','bar')), 
        map {'&amp;': ('foo', 'bar')}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            (['a',1],'foo','bar')), 
        map {'a': 1, '&amp;': ('foo', 'bar')}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            (['a',1],'foo',['a',2],'bar')), 
        map {'a': (1,2), '&amp;': ('foo', 'bar')}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            (['a',1],'foo',['a',2],'bar')), 
        map {'a': (1,2), '&amp;': ('foo', 'bar')}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            ['foo', map {'a':1}, 1]),
        map {'foo': (['a', 1], 1)}
    ),
    
    unit:assert-equals(
        α:collect-keys(
            (['latitude', 40.75], ['longitude', 73.98])),
        map { 'latitude': 40.75, 'longitude': 73.98 } 
    ),
    
    (: 
     : NOTE: this may look weird, but collect keys only works on the top level.
     :       children will be left as-is until a next recursive call re-organizes
     :       them
     :)
    unit:assert-equals(
        α:collect-keys(
            (['foo', map {'a':1}, 1],['bar', 2],['foo', map {'a':2}, 3])),
        map {'foo': (['a', 1],1,['a',2],3), 'bar': 2}
    )
};