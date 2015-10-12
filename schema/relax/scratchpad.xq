import module namespace ex = "http://xokomola.com/ns/xml/validation/json/ex" at "examples.xqm";

ex:to-xdm('schema-net-address.json')


(:
ex:to-xml('schema-net-address.json')
:)

(: 
ex:validate('schema-net-address.json', 'schema-net-address.rnc')
:)

(:
ex:xml-to-json(map { 'a': [1,2,3] })
:)

(:
json:serialize([1,2,3])
:)

(:
json:serialize(<foo><p>Hello</p><p>World</p></foo>, map { 'format': 'jsonml' })
:)

(:
json:serialize(<foo></foo>)
:)

(:
json:serialize(<json type="object"><p>Hello</p><p>World</p></json>)
:)
