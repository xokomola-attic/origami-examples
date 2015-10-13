# Micro-XML examples

- Use some Hiccup examples 
- Just use mu to show the value of Micro-XML
- Example a forms library to write forms more easily
- Or SVG or DITA or XLIFF
- Production example: XML content API (Social Networker)

## components.xqm [TODO]

An incomplete experiment of rendering UI using a React/Reagent approach.

Intended to be used in a client, may be somewhat userful with Saxon-CE but not in itself. It's main use is seeing how components could be added to mu. [fn, args] to be executed later. Or in an SVG context or schema. These components are parts in the mu data structures. render#1 could be implemented maybe via the walk pattern. Not sure what it's relationship with apply# Another insight is that embedding functions on attributes could make the template structure react to message e.g. send on on-click to an element causes an effect and could result in a different "DOM" or mu-doc. Reactive documents in a render loop. The DOM analogy begs for having a DOM selection mechanism for mu.

## html5.xqm [TODO]

Add some functions so it's easier to create HTML5 using Micro-XML.

# Hiccup

https://clojurebridge.github.io/community-docs/docs/web-applications/hiccup/
http://www.rkn.io/2014/03/13/clojure-cookbook-hiccup/
https://github.com/weavejester/hiccup/wiki/Forms
https://github.com/davidsantiago/hickory
