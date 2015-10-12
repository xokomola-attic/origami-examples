xquery version "3.1";

(:~ Origami data-templates, temporary placeholder for demand-driven stuff :)

module namespace dt = 'http://xokomola.com/xquery/origami/dt';

import module namespace μ = 'http://xokomola.com/xquery/origami/μ' at 'mu.xqm';

declare function dt:templates($templates)
{
    let $templates := dt:compile-templates($templates)
    return
        function($query as array(*), $opts as map(*)) {
            dt:query($query, $opts, $templates)
        }
};

declare %private function dt:query($query, $opts, $templates)
{
    let $template-name := array:head($query)
    let $template := $templates($template-name)
    let $template-handler := μ:element($template)
    let $template-atts := μ:attributes($template)
    let $query-children := μ:children($query)
    let $current :=
        typeswitch ($template-handler)
        case map(*) return $template-handler
        case array(*) return $template-handler
        case function(*) 
        return $template-handler($query, [])
        default return $template-handler
    for $this in μ:from-xml($current)
    return
        if (empty($query-children)) then
            [$this, $template-atts]
        else
            fold-left(
                $query-children,
                [$this, $template-atts],
                function ($result, $item) { 
                    array:append($result, dt:query($item, $opts, $templates)) 
                }
            )
};

declare function dt:compile-templates($templates)
{
    $templates
};

declare function dt:apply()
{
    μ:apply#2
};

declare function dt:apply($nodes)
{
    dt:apply($nodes, [])
};

declare function dt:apply($nodes, $context)
{
    μ:apply($nodes)($context)
};

declare function dt:template($template, $body)
{
  ['template']  
};

declare function dt:copy($nodes, $ctx)
{
  $nodes
};

declare function dt:value($nodes, $ctx)
{
    string($nodes)
};

declare function dt:atts($attributes)
{
    function($node) {
        map:merge((
            for $attribute in $attributes
            let $attribute := $attribute($node)
            return
                map:entry(node-name($attribute), string($attribute))
        ))
    }
};