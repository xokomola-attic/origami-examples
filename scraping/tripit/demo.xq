import module namespace o = 'http://xokomola.com/xquery/origami'
    at '../../../origami/origami.xqm';

import module namespace x = 'http://xokomola.com/xquery/origami/scrape' 
    at '../scrape.xqm'; 

import module namespace trip = 'http://xokomola.com/xquery/origami/examples'
    at 'restaurants.xqm';

(: $trip:urls-xslt :)
(: $trip:urls-rules :)

(: trip:urls($trip:local) :)
(: trip:cache() :)

(: look at how many different ways to write the phone number! :)
(: o:xml(trip:scrape())//phone :)
(: o:xml(trip:restaurant($trip:localr)) :)

(: o:xml(trip:scrape()) :)
            
(: o:ns(x:get-html(file:base-dir() || "../nyt/ny-times.html")) :)
