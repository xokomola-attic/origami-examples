xquery version "3.1";

(: Micro-XML HTML library :)

(: @see http://weavejester.github.io/hiccup :)

(: TODO: also add serialization functions to handle DOCTYPE, CDATA etc. :)
(: TODO: add Fold middleware :)
(: TODO: extra attributes args :)

module namespace h = 'http://xokomola.com/xquery/origami/html';

import module namespace o = 'http://xokomola.com/xquery/origami' 
    at '../../origami/origami.xqm'; 

declare private variable $h:default-lang := 'en';

declare function h:image($src as xs:string)
{
    ['img', map { 'src': $src }]
};

declare function h:image($src as xs:string, $alt as xs:string)
{
    ['img', map { 'src': $src, 'alt': $alt }]
};

(: TODO: CDATA section :)
declare function h:javascript-tag($script as xs:string)
{
    ['script', $script]
};

declare function h:link-to($url as xs:string, $content as item()*)
{
    ['a', map { 'href': $url }, $content]
};

declare function h:mail-to($email as xs:string)
{
    ['a', map { 'href': 'mailto' || $email }, $email]
};

declare function h:mail-to($email as xs:string, $content as item()*)
{
    ['a', map { 'href': 'mailto' || $email }, $content]
};

declare function h:ordered-list($items as item()*)
{
    ['ol', for $item in $items return ['li', $item]]
};

declare function h:unordered-list($items as item()*)
{
    ['ul', for $item in $items return ['li', $item]]
};

declare function h:html5($contents as item()*)
{
    h:html5($contents, map {})
};

declare function h:html5($contents as item()*, $options as map(*))
{
    ['html',
        $contents
    ]
};

declare function h:xhtml($contents as item()*, $options as map(*))
{
    ['html', 
        map { 
            'xmlns': 'http://www.w3.org/1999/xhtml', 
            'xml:lang': ($options?lang,$h:default-lang)[1], 
            'lang': ($options?lang,$h:default-lang)[1] 
        },
        $contents
    ]
};

declare function h:include-js($scripts as xs:string*)
{
    $scripts ! 
        ['script', 
            map { 'type': 'text/javascript', 'src': escape-html-uri(.)]
};

declare function h:include-css($styles as xs:string*)
{
    $styles ! 
        ['link', 
            map { 'type': 'text/css', 'src': escape-html-uri(.), 'rel': 'stylesheet']
};

(: TODO: with groups :)
declare %private function h:make-id($name as xs:string)
{
    $name
};

declare %private function h:input($type,$name,$value)
{
    ['input',
        map { 
            'type': $type, 
            'name': $name, 
            'id': h:make-id($name), 
            'value': $value 
        }
    ]
};

declare function h:text-field($name)
{
    h:text-field($name,())
};

declare function h:text-field($name, $value)
{
    h:input-field('text', $name, $value)
};

declare function h:text-area($name)
{
    h:text-area($name, ())
};

declare function h:text-area($name, $value)
{
    ['textarea', 
        map { 'name': $name, 'id': h:make-id($name) },
        $value
    ]
};

declare function h:email-field($name)
{
    h:email-field($name,())
};

declare function h:email-field($name, $value)
{
    h:input-field('email', $name, $value)
};


declare function h:file-upload($name)
{
    h:input-field('file', $name, ())
};

declare function h:form-to($method, $action, $body)
{
    let $method := upper-case($method)                
    let $action-uri := escape-html-uri($action)
    let $form :=
        if ($method = ('POST','GET')) then
            ['form', map { 'method': $method, 'action': $action-uri }]
        else
            ['form', map { 'method': 'POST', 'action': $action-uri },
                h:hidden-field('_method', $method)
            ]                
    return
        $form => o:insert-after($body)
};

declare function h:hidden-field($name)
{
    h:hidden-field($name, ())
};

declare function h:hidden-field($name, $value)
{
    h:input-field('hidden', $name, $value)
};

declare function h:label($name, $text)
{
    ['label', map { 'for': h:make-id($name) }, $text]
};

declare function h:password-field($name)
{
    h:password-field($name, ())
};

declare function h:password-field($name, $value)
{
    h:input-field('password', $name, $value)
};

declare function h:check-box($name)
{
    h:check-box($name, ())
};

declare function h:check-box($name, $checked)
{
    h:check-box($name, $checked, true())
};

declare function h:check-box($name, $checked, $value)
{
    ['input',
        map { 
            'type': 'checkbox',
            'name': $name,
            'id': h:make-id($name),
            'value': $value,
            'checked': $checked
        }
    ]
};

declare function h:radio-button($group)
{
    h:radio-button($group, ())
};

declare function h:radio-button($group, $checked)
{
    h:radio-button($group, $checked, true())
};

declare function h:radio-button($group, $checked, $value)
{
    ['input',
        map { 
            'type': 'radio',
            'name': $group,
            'id': h:make-id($group || '-' || $value),
            'value': $value,
            'checked': $checked
        }
    ]
};

declare function h:drop-down($name, $options)
{
    h:drop-down($name, $options, ())
};

declare function h:drop-down($name, $options, $selected)
{
    ['select', 
        map { 'name': $name, 'id': h:make-id($name) },
        h:select-options($options, $selected)
    ]
};

declare %private function h:select-options($options)
{
    h:select-options($options, ())
};

declare %private function h:select-options($options, $selected)
{
    for $option in $options
    return
        typeswitch($option)
        case array(*) return
            if (count($options?2) gt 1) then
                ['optgroup', 
                    map { 'label': $option?1 },
                    
                        h:select-options($options?2, $selected)
                ]
            else
                ['option', 
                    map { 
                        'value': $options?2,
                        'selected': $options?2 = $selected
                    }
                ]
        default return
            ['option',
                map { 'selected': $option = $selected }, 
                $option
            ]
};

declare function h:submit-button($text)
{
    ['input', map { 'type': 'submit', 'value': $text }]
};

declare function h:reset-button($text)
{
    ['input', map { 'type': 'reset', 'value': $text }]
};


