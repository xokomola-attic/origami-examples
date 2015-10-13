xquery version "3.1";

(: Contact List example (from Reagent tutorial) :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../origami/origami.xqm'; 

declare variable $ex:state :=
    map { 'contacts':
        [
            map { 'first': 'Ben', 'last': 'Bitdiddle', 'email': 'benb@mit.edu' },
            map { 'first': 'Alyssa', 'middleinitial': 'P', 'last': 'Hacker', 'email': 'aphacker@mit.edu' },
            map { 'first': 'Eva', 'middle': 'Lu', 'last': 'Ator', 'email': 'eval@mit.edu' },
            map { 'first': 'Louis', 'last': 'Reasoner', 'email': 'prolog@mit.edu' },
            map { 'first': 'Cy', 'middleinitial': 'D', 'last': 'Effect', 'email': 'bugs@mit.edu' },
            map { 'first': 'Lem', 'middleinitial': 'E', 'last': 'Tweakit', 'email': 'morebugs@mit.edu' }
        ]            
    };

declare function ex:display-name($c)
{
    concat($c('last'), ', ', $c('first'))
};

declare function ex:add-contact($c)
{
    'Adding ' || ex:display-name($c)
};

declare function ex:remove-contact($c)
{
    'Removing ' || ex:display-name($c)
};

declare function ex:contact($c) 
{
    ['li',
        ['span', ex:display-name($c)],
        ['button', map { 'on-click': function($c) { ex:remove-contact($c) }}, 'Delete']
    ]
};

declare function ex:contact-list()
{
    ['div',
        ['h1', 'Contact List'],
        ['ul', function() {
                for $c in $ex:state?contacts?*
                return [ex:contact#1, $c]
        }],
        [ex:new-contact#0]
    ]
};

declare function ex:new-contact()
{
    ['div',
        ['input', map { 
            'type': 'text',
            'placeholder': 'Contact Name',
            'value': '',
            'on-change': '' }],
        ['button', map { 'on-click': [ex:add-contact#1, ex:data('name')] }, 'Add']
    ]
};
