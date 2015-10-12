xquery version "3.1";

module namespace ex = 'http://xokomola.com/ns/xml/validation/json/ex';

declare function ex:to-xdm($f)
{
    parse-json(ex:read-json($f))
};

declare function ex:to-xml($f)
{
    json:parse(ex:read-json($f))
};

declare function ex:validator($s)
{
    function($f) {
        validate:rng-info(ex:to-xml($f), $s, false())
    }
};

declare function ex:validate($f, $s)
{
    validate:rng-info(ex:to-xml($f), ex:schema($s), true())
};

declare function ex:schema($f)
{
    concat(file:base-dir(), $f)
};

declare function ex:read-json($f)
{
    file:read-text(concat(file:base-dir(), $f))
};

declare function ex:xml-to-json($nodes)
{
    serialize($nodes, map { 'method': 'json' })
};