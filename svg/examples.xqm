xquery version "3.1";

(:~
 : SVG examples
 :)
module namespace ex = 'http://xokomola.com/xquery/origami/examples';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../origami/origami.xqm'; 

declare variable $ex:svg := 
  ['rect', map { 'x': 0, 'y': 0 },
    ['rect',
      ['rect', map { 'width': 30, 'height': 20 }],
      ['rect', map { 'width': 40, 'height': 20 }]
    ],
    ['rect',
      ['rect', map { 'width': 50, 'height': 20 }],
      ['rect', map { 'width': 60, 'height': 20 }]    
    ]
  ];

(: 
 : Sets @height and @width attributes on a node to the sum of the child 
 : elements dimensions 
 :)
declare function ex:layout($n) {
    let $tag := o:tag($n)
    let $atts := o:attributes($n)
    let $content := o:content($n)
    let $atts := 
      if (exists($content))
      then map:merge((
        $atts,
        map:entry('height', sum(for $node in $content return o:attributes($node)?height)),
        map:entry('width', sum(for $node in $content return o:attributes($node)?width))
      ))
      else $atts      
    return
      array { $tag, $atts, $content }
};

declare function ex:svg-layout-postwalk()
{
    o:xml(o:postwalk($ex:svg, ex:layout#1))  
};

declare %unit:test function ex:test-postwalk-layout-example()
{
    unit:assert-equals(
      ex:svg-layout-postwalk(),
      <rect width="180" height="80" x="0" y="0">
        <rect width="70" height="40">
          <rect width="30" height="20"/>
          <rect width="40" height="20"/>
        </rect>
        <rect width="110" height="40">
          <rect width="50" height="20"/>
          <rect width="60" height="20"/>
        </rect>
      </rect>,
      'Generate SVG'
    )  
};

(:~ 
 : A bar chart
 :
 : see http://bost.ocks.org/mike/bar/2/
 :)
declare variable $ex:chart-data := (4,8,15,16,23,42);
declare variable $ex:chart-width := 420;
declare variable $ex:chart-bar-height := 20;

declare function ex:scale-linear($domain,$range)
{
   let $factor := ( $range?2 - $range?1 ) idiv  ( $domain?2 - $domain?1 )
   return
     function($x) {
       $x * $factor
     } 
};

declare function ex:bars($data)
{
    let $text-atts := map { 
        'fill': 'white', 
        'font': '10px sans-serif', 
        'text-anchor': 'end' }
    let $width := ex:scale-linear([0, max($data)], [0, $ex:chart-width])
    for $bar at $pos in $data
    return
      ['g', map { 
        'transform': "translate(0," || ($pos - 1) * $ex:chart-bar-height || ")" },
        ['rect', map { 
            'width': $width($bar) , 
            'height': $ex:chart-bar-height - 1, 
            'fill': 'steelblue' }],
        ['text', map:merge(($text-atts, map { 
            'x': $width($bar) - 4, 
            'y': $ex:chart-bar-height div 2, 
            'dy': '.35em' })), $bar]
      ]  
};

declare function ex:bar-chart($data)
{
    o:xml(
      ['svg', 
        map { 
          'class': 'chart', 
          'width': $ex:chart-width, 
          'height': $ex:chart-bar-height * count($data) },
      ex:bars($data)
    ])
};

declare %unit:test function ex:test-bar-chart()
{
    unit:assert-equals(
        ex:bar-chart($ex:chart-data),
        <svg width="420" height="120" class="chart">
          <g transform="translate(0,0)">
            <rect fill="steelblue" width="40" height="19"/>
            <text fill="white" font="10px sans-serif" dy=".35em" text-anchor="end" x="36" y="10">4</text>
          </g>
          <g transform="translate(0,20)">
            <rect fill="steelblue" width="80" height="19"/>
            <text fill="white" font="10px sans-serif" dy=".35em" text-anchor="end" x="76" y="10">8</text>
          </g>
          <g transform="translate(0,40)">
            <rect fill="steelblue" width="150" height="19"/>
            <text fill="white" font="10px sans-serif" dy=".35em" text-anchor="end" x="146" y="10">15</text>
          </g>
          <g transform="translate(0,60)">
            <rect fill="steelblue" width="160" height="19"/>
            <text fill="white" font="10px sans-serif" dy=".35em" text-anchor="end" x="156" y="10">16</text>
          </g>
          <g transform="translate(0,80)">
            <rect fill="steelblue" width="230" height="19"/>
            <text fill="white" font="10px sans-serif" dy=".35em" text-anchor="end" x="226" y="10">23</text>
          </g>
          <g transform="translate(0,100)">
            <rect fill="steelblue" width="420" height="19"/>
            <text fill="white" font="10px sans-serif" dy=".35em" text-anchor="end" x="416" y="10">42</text>
          </g>
        </svg>,
        'Generate bar chart'
    )
};