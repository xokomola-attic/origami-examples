xquery version "3.1";

module namespace x = 'http://xokomola.com/xquery/origami/scrape';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../origami/origami.xqm'; 

declare variable $x:ua := 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36';
declare variable $x:cache as xs:string := x:ensure-dir(file:base-dir() || '.cache');

declare function x:ensure-dir($path as xs:string)
as xs:string
{
    let $dir := 
        if (not(file:exists($path))) then
            (file:create-dir($path), $path)[1]
        else
            if (file:is-dir($path)) then
                $path
            else
                error(concat('Cannot create directory: ', $path))
    return
        $dir
};

declare function x:get-html($uri)
{
    if (starts-with($uri,'http:')) then
        x:cache($uri, x:fetch#1)
    else
        o:read-html($uri)
};

declare function x:fetch($uri)
{
    let $sleep := prof:sleep(200)
    let $response :=
        http:send-request(
            <http:request method="get" 
                override-media-type="application/octet-stream" 
                href="{ $uri }">
                <http:header name="User-Agent" value="{ $x:ua }"/>
                <http:header name="Accept" value="text/html"/>
                <http:header name="Accept-Language" value="en-US,en;q=0.8"/>
            </http:request>
        )
    let $binary := $response[2]
    return try {
        html:parse($binary)
    } catch * {
        'Conversion to XML failed: ' || $err:description
    }
};

declare function x:cache($uri, $fetch-fn)
{
    let $cache-entry := concat($x:cache,'/', xs:hexBinary(hash:md5($uri)), '.html')
    return
        if (file:is-file($cache-entry)) then
            doc(trace($cache-entry,'CACHE HIT: '))/*
        else 
            let $html := $fetch-fn($uri)
            let $store := file:write(trace($cache-entry, 'CACHE MISS: '), $html)
            return
                $html      
};
