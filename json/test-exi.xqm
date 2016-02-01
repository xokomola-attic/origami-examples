xquery version '3.1';

module namespace test = 'http://xokomola.com/xquery/origami/examples/test/exi';

import module namespace j = 'https://www.w3.org/2015/EXI/json'
    at 'exi.xqm';

declare function test:typed($xdm)
{
    j:xml(j:doc($xdm, map { 'type-info': true() }))
};

declare %unit:test function test:typed-xml()
{
    unit:assert-equals(
        test:typed(2),
        <j:number type="xs:integer">2</j:number>
    ),

    unit:assert-equals(
        test:typed(xs:integer(2)),
        <j:number type="xs:integer">2</j:number>
    ),

    unit:assert-equals(
        test:typed(2.4),
        <j:number type="xs:decimal">2.4</j:number>
    ),

    unit:assert-equals(
        test:typed(xs:double(2.4)),
        <j:number type="xs:double">2.4</j:number>
    ),

    unit:assert-equals(
        test:typed(xs:positiveInteger(2)),
        <j:number type="xs:positiveInteger">2</j:number>
    ),

    unit:assert-equals(
        test:typed(xs:int(2)),
        <j:number type="xs:int">2</j:number>
    ),

    unit:assert-equals(
        test:typed(()),
        <j:null/>
    ),

    unit:assert-equals(
        test:typed(true()),
        <j:boolean type="xs:boolean">true</j:boolean>
    ),

    unit:assert-equals(
        test:typed(false()),
        <j:boolean type="xs:boolean">false</j:boolean>
    ),

    unit:assert-equals(
        test:typed(xs:date('2016-01-30')),
        <j:other type="xs:date">2016-01-30</j:other>
    ),

    unit:assert-equals(
        test:typed(xs:token('x')),
        <j:string type="xs:token">x</j:string>
    ),
    
    unit:assert-equals(
        test:typed([ xs:token('x') ]),
        <j:array><j:string type="xs:token">x</j:string></j:array>
    )

};

declare %unit:test function test:xdm()
{
    unit:assert-equals(
        j:xdm(<j:array/>),
        []
    ),
    
    unit:assert-equals(
        j:xdm(<j:map/>),
        map {}
    ),

    unit:assert-equals(
        j:xdm(<j:null/>),
        ()
    ),

    unit:assert-equals(
        j:xdm(<j:string/>),
        ''
    ),

    unit:assert-equals(
        j:xdm(<j:string>foo</j:string>),
        'foo'
    ),

    unit:assert-equals(
        j:xdm(<j:number>1</j:number>),
        xs:integer(1)
    ),

    unit:assert-equals(
        j:xdm(<j:number>1.2</j:number>),
        xs:double(1.2)
    ),

    unit:assert-equals(
        j:xdm(<j:boolean>true</j:boolean>),
        true()
    ),

    unit:assert-equals(
        j:xdm(<j:boolean>false</j:boolean>),
        false()
    )

    (: this will fail because j:other without @type makes a string :)
    (:
    unit:assert-equals(
        j:xdm(<j:other>2016-01-30</j:other>),
        xs:date('2016-01-30')
    )
    :)

};

declare %unit:test function test:typed-xdm()
{
    unit:assert-equals(
        j:xdm(<j:other type="xs:date">2016-01-30</j:other>),
        xs:date('2016-01-30')
    ),
    
    unit:assert-equals(
        j:xdm(<j:number type="xs:positiveInteger">4</j:number>),
        xs:positiveInteger(4)
    )
    
};

(:
 : Appendix D: example 1 (http://www.w3.org/TR/exi-for-json)
 :
 : <map xmlns="https://www.w3.org/2015/EXI/json">
 :   <array key="keyArrayStrings">
 :     <string>s1</string>
 :     <string>s2</string>
 :   </array>
 :   <number key="keyNumber">123</number>
 : </map>
 :)
declare %unit:test function test:from-xdm-w3c-1()
{
    let $xml := 
        j:xml(j:doc(
            map {
                'keyNumber': 123,
                'keyArrayStrings': ['s1', 's2']
            }
        ))
    return (
        unit:assert($xml/self::j:map),
        unit:assert($xml/j:array/@key = 'keyArrayStrings'),
        unit:assert($xml/j:array/j:string[1] = 's1'),
        unit:assert($xml/j:array/j:string[2] = 's2'),
        unit:assert($xml/j:number/@key = 'keyNumber'),
        unit:assert($xml/j:number = 123)
    )        
};

(:
 : Appendix D: example 2 (http://www.w3.org/TR/exi-for-json)
 :
 :  <map xmlns="https://www.w3.org/2015/EXI/json">
 :      <map key="glossary">
 :          <string key="title">example glossary</string>
 :          <map key="GlossDiv">
 :              <string key="title">S</string>
 :              <map key="GlossList">
 :                  <map key="GlossEntry">
 :                      <string key="ID">SGML</string>
 :                      <string key="SortAs">SGML</string>
 :                      <string key="GlossTerm">Standard
 :                         Generalized Markup Language</string>
 :                      <string key="Acronym">SGML</string>
 :                      <string key="Abbrev">ISO 8879:1986</string>
 :                      <map key="GlossDef">
 :                          <string key="para">A meta-markup
 :                              language, used to create markup languages
 :                              such as DocBook. </string>
 :                          <array key="GlossSeeAlso">
 :                              <string>GML</string>
 :                              <string>XML</string>
 :                          </array>
 :                      </map>
 :                      <string key="GlossSee">markup</string>
 :                  </map>
 :              </map>
 :          </map>
 :      </map>
 :  </map>
 :)
declare %unit:test function test:from-xdm-w3c-2()
{
    let $xml := 
        j:xml(j:doc(
            map {
              'glossary': map {
                'title': 'example glossary',
                'GlossDiv': map {
                  'title': 'S',
                  'GlossList': map {
                    'GlossEntry': map {
                      'ID': 'SGML',
                      'SortAs': 'SGML',
                      'GlossTerm': 'Standard Generalized Markup Language',
                      'Acronym': 'SGML',
                      'Abbrev': 'ISO 8879:1986',
                      'GlossDef': map {
                        'para': 'A meta-markup language,
                          used to create markup languages such as DocBook.',
                        'GlossSeeAlso': [
                          'GML',
                          'XML'
                        ]
                      },
                      'GlossSee': 'markup'
                    }
                  }
                }
              }
            }
        ))
    return (
        unit:assert($xml/self::j:map),
        unit:assert($xml/j:map/@key = 'glossary'),
        unit:assert($xml/j:map/j:map/@key = 'GlossDiv'),
        unit:assert($xml/j:map/j:map/j:map/@key = 'GlossList'),
        unit:assert($xml/j:map/j:map/j:map/j:map/@key = 'GlossEntry'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:string/@key = 'Abbrev'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:string/@key = 'Acronym'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:string/@key = 'GlossSee'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:string/@key = 'SortAs'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:string/@key = 'GlossTerm'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:string/@key = 'ID'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:map/@key = 'GlossDef'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:map/j:string/@key = 'para'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:map/j:array/@key = 'GlossSeeAlso'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:map/j:array/j:string = 'GML'),
        unit:assert($xml/j:map/j:map/j:map/j:map/j:map/j:array/j:string = 'XML'),
        unit:assert($xml/j:map/j:string/@key = 'title')
    )        
};
