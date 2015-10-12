xquery version "3.1";

(:~
 : Templating a task list.
 :
 : @see http://jawher.net/2011/03/03/moulder-in-action/
 : @see http://scalate.github.io/scalate/which.html
 :)

module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../origami/origami.xqm';

declare variable $ex:template :=
    <ul id="tasks">
        <li>
            <img src="/images/circle_red.png"/>
     
            <h2>[title]</h2>
     
            <p>[description]</p>
            <span>urgent</span>
        </li>
    </ul>;

declare variable $ex:tasks := (
    map { 'type': 'bug', 'status': 'open', 'title': 'Urgent bug', 'description': 'This is an urgent bug.', 'urgent': true() },
    map { 'type': 'bug', 'status': 'closed', 'title': 'Another bug', 'description': 'This is another bug.' },
    map { 'type': 'feature', 'status': 'ready', 'title': 'Great feature', 'description': 'I see a great future for this feature.' }   
);
    
declare function ex:task-list-1($tasks as map(*)*)
{
    o:doc($ex:template,
      o:xform( 
        ['ul[@id="tasks"]',
            ['li', o:repeat($tasks,
                function($n,$task) { 
                    $n => o:insert($task?title) 
                }
            )]
        ]
      )
    )
};

declare %unit:test function ex:test-task-list-1()
{
  unit:assert-equals(
    o:apply(ex:task-list-1($ex:tasks)),
    ['ul', map { 'id': 'tasks' },
      ['li', 'Urgent bug'],
      ['li', 'Another bug'],
      ['li', 'Great feature']
    ]
  )
};

(: about the same length as the Java version but more readable :)
(: a little bit longer than the Scala version but I could squish it further, and it's more readable :)
(: NOTE: the way the XSLT stage works we apply will only find the rules embedded in a parent rule (li) :)
declare function ex:task-list-2($tasks as map(*)*)
{
    o:doc($ex:template, 
      o:xform(
        ['ul[@id="tasks"]',
            ['li', o:repeat($ex:tasks, 
                function($n,$task) {
                    $n => o:insert(o:content($n) => o:apply([$task]))
                }),
                ['img', function($n,$task) {
                    let $color :=
                        switch($task?type)
                        case 'bug' return 'red'
                        case 'feature' return 'green'
                        default return 'blue'
                    return
                        $n => o:set-attr(map { 'src': replace(o:attrs($n)?src, 'red', $color) })
                }],
                ['h2', function($n,$task) { 
                    $n => o:insert($task?title) 
                }],
                ['p', function($n,$task) {
                    $n => o:insert($task?description) 
                }],
                ['span', function($n,$task) {
                    if ($task?urgent) then $n => o:insert('urgent') else () 
                }]                
            ]
        ]
      )
    )
};

declare %unit:test function ex:test-task-list-2()
{
  unit:assert-equals(
    o:xml(o:apply(ex:task-list-2($ex:tasks))),
    <ul id="tasks">
      <li>
        <img src="/images/circle_red.png"/>
        <h2>Urgent bug</h2>
        <p>This is an urgent bug.</p>
        <span>urgent</span>
      </li>
      <li>
        <img src="/images/circle_red.png"/>
        <h2>Another bug</h2>
        <p>This is another bug.</p>
      </li>
      <li>
        <img src="/images/circle_green.png"/>
        <h2>Great feature</h2>
        <p>I see a great future for this feature.</p>
      </li>
    </ul>
  )
};

(: In the previous examples the tasks where 'baked in'. The compilation of the
 : template involves a lot of work which can be re-used and may happen at compile time
 : rather than run-time.
 : This example has much better performance, it's about 50 times faster (mainly due to
 : an XSLT transform being run every time or only once). The idea being
 : that as much as possible of the templating work should be done at compile time.
 :
 : On my machine 1000 runs apply calls on this document costs ~140ms, if each of
 : them is also serialized into XML it goes up to ~250ms.
 :)
declare function ex:task-list-3()
{
    o:doc($ex:template, 
      o:xform(
        ['ul[@id="tasks"]',
            ['li', function($n,$tasks) {
                o:repeat($n,$tasks,
                    function($n,$task) {
                        $n => o:insert(o:content($n) => o:apply([$task]))
                    }
                )},
                ['img', function($n,$task) {
                    let $color :=
                        switch($task?type)
                        case 'bug' return 'red'
                        case 'feature' return 'green'
                        default return 'blue'
                    return
                        $n => o:set-attr(map { 'src': replace(o:attrs($n)?src, 'red', $color) })
                }],
                ['h2', function($n,$task) { 
                    $n => o:insert($task?title) 
                }],
                ['p', function($n,$task) {
                    $n => o:insert($task?description) 
                }],
                ['span', function($n,$task) {
                    if ($task?urgent) then $n => o:insert('urgent') else () 
                }]                
            ]
        ]
      )
    )
};
