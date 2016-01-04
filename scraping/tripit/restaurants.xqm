xquery version "3.1";

module namespace trip = 'http://xokomola.com/xquery/origami/examples';

(: TODO: fetch other pages :)
(: TODO: plot restaurants on map :)

import module namespace x = 'http://xokomola.com/xquery/origami/scrape' 
    at '../scrape.xqm'; 

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../../origami/origami.xqm'; 

declare variable $trip:site := 'http://www.tripadvisor.com';
declare variable $trip:url := $trip:site || '/Restaurants-g188582-Eindhoven_North_Brabant_Province.html';

(: for debugging :)
declare variable $trip:local := doc(file:base-dir() || 'restaurants.html')/*;
declare variable $trip:localr := doc(file:base-dir() || 'restaurant.html')/*;

declare variable $trip:parse-urls := 
    ['html',(),
        ['h3[@class="title"]/a/@href']  
    ];

(: TODO: could use a function that transforms fragments of RDFa :)
declare function trip:address($n)
{
    o:prewalk($n, function($n) {
        if (o:attrs($n)?property) then
            [trace(o:attrs($n)?property,'X: '), o:children($n)]
        else
            o:children($n)
        }
    )
};

declare variable $trip:parse-restaurant := 
    ['html', (),
        ['div[@class="mapContainer"]/@data-name', 
            function($a) { ['name', o:text($a)] }],
        ['img[@property="ratingValue"]/@content', 
            function($a) { ['rating', o:text($a)] }],
        ['div[@class="mapContainer"]/@data-lat', 
            function($a) { ['lat', o:text($a)] }],
        ['div[@class="mapContainer"]/@data-lng', 
            function($a) { ['long', o:text($a)] }],
        ['div[@class="info_wrapper"]//span[@property="address"]', 
            trip:address#1],
        ['div[@class="info_wrapper"]//div[@class="contact_info"]//div[contains(@class, "phoneNumber")]', 
            function($a) { ['phone', o:text($a)] }]
    ];

declare variable $trip:urls := o:transformer($trip:parse-urls);
declare variable $trip:restaurant := o:transformer($trip:parse-restaurant);

(: for debugging :)
declare variable $trip:urls-rules := o:compile-rules($trip:parse-urls);
declare variable $trip:urls-xslt := o:compile-stylesheet($trip:urls-rules);

declare function trip:cache()
{
    <cache path="{ $x:cache }">{
        for $file in file:list($x:cache)
        return
            <file path="{ $file }"/>
    }</cache>
};

declare function trip:scrape()
{
    ['restaurants',
        for $url in trip:urls(x:get-html($trip:url))
        return
            trip:restaurant(x:get-html(concat($trip:site, $url)))
    ]
};

declare function trip:urls($html)
{
    o:apply($trip:urls($html))
};

declare function trip:restaurant($html)
{
    ['restaurant', o:apply($trip:restaurant($html))]
};
