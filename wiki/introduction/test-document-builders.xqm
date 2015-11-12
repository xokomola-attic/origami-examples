xquery version "3.1";

(:~
 : Document Builder tests
 :)
module namespace test = 'http://xokomola.com/xquery/origami/tests';


import module namespace ex = 'http://xokomola.com/xquery/origami/examples'
    at 'document-builders.xqm'; 

declare %unit:test function test:extract-table() 
{
    unit:assert-equals(
        ex:extract-table(),
        <table>
            <tr class="odd" x="foo">
                <th>hello <b>world</b>!</th>
                <th>foobar</th>
            </tr>
            <tr class="even" y="bar">
                <td>bla <b>bla</b></td>
                <td>foobar</td>
            </tr>
        </table>
        ,
        'Extract the table as-is'
    )
};

declare %unit:test function test:extract-table-sans-attributes() 
{
    unit:assert-equals(
        ex:extract-table-sans-attributes(),
        <table>
            <tr>
                <th>hello <b>world</b>!</th>
                <th>foobar</th>
            </tr>
            <tr>
                <td>bla <b>bla</b></td>
                <td>foobar</td>
            </tr>
        </table>
        ,
        'Extract the table without attributes'
    )
};

declare %unit:test function test:extract-table-no-inline() 
{
    unit:assert-equals(
        ex:extract-table-no-inline(),
        <table>
            <tr>
                <th>hello world!</th>
                <th>foobar</th>
            </tr>
            <tr>
                <td>bla bla</td>
                <td>foobar</td>
            </tr>
        </table>
        ,
        'Extract the table without attributes'
    )
};
