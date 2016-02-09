# lua-jsonpath

Query Lua data structures with JsonPath expressions. Robust and safe JsonPath engine for Lua.

This library implements Stefan Goessner's [JsonPath syntax](http://goessner.net/articles/JsonPath/) in Lua. Lua JsonPath is compatible with David Chester's [Javascript implementation](https://github.com/dchester/jsonpath).

The JsonPath Lua library was written from scratch by Frank Edelhaeuser. It's a pure Lua implementation based on a PEG grammer handled by Roberto Ierusalimschy's fabulous [LPeg pattern-matching library](http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html).

Some of this README and a subset of test cases were adopted from David Chester's [Javascript implementation](https://github.com/dchester/jsonpath) which is based on Stefan Goessner's [original work](http://goessner.net/articles/JsonPath/).


## Query Example

```lua
local cities = {
    { name = 'London', population = 8615246 },
    { name = 'Berlin', population = 3517424 },
    { name = 'Madrid', population = 3165235 },
    { name = 'Rome',   population = 2870528 }
}

local jp = require('jsonpath')
local names = jp.query(cities, '$..name')
-- { 'London', 'Berlin', 'Madrid', 'Rome' }
```


## Install

```
$ luarocks install lua-jsonpath
```


## JsonPath Syntax

Here are syntax and examples adapted from [Stefan Goessner's original post](http://goessner.net/articles/JsonPath/) introducing JsonPath in 2007.

JsonPath            | Description
--------------------|------------
`$`                 | The root object/element
`@`                 | The current object/element
`.`                 | Child member operator
`..`                | Recursive descendant operator; JsonPath borrows this syntax from E4X
`*`                 | Wildcard matching all objects/elements regardless their names
`[]`                | Subscript operator
`[,]`               | Union operator for alternate names or array indices as a set
`[start:end:step]`  | Array slice operator borrowed from ES4 / Python
`?()`               | Applies a filter (script) expression via static evaluation
`()`                | Script expression via static evaluation 

Given this sample data set, see example expressions below:

```lua
{ 
    store = {
        bicycle = {
            color = 'red',
            price = 19.95
        },
        book = {
            { 
                category = 'reference',
                author = 'Nigel Rees',
                title = 'Sayings of the Century',
                price = 8.95
            }, { 
                category = 'fiction',
                author = 'Evelyn Waugh',
                title = 'Sword of Honour',
                price = 12.99
            }, { 
                category = 'fiction',
                author = 'Herman Melville',
                title = 'Moby Dick',
                isbn = '0-553-21311-3',
                price = 8.99
            }, { 
                category = 'fiction',
                author = 'J. R. R. Tolkien',
                title = 'The Lord of the Rings',
                isbn = '0-395-19395-8',
                price = 22.99
            }
        }
    }
}
```

Example JsonPath expressions:

JsonPath                        | Description
--------------------------------|------------
`$.store.book[*].author`        | The authors of all books in the store
`$..author`                     | All authors
`$.store.*`                     | All things in store, which are some books and a red bicycle
`$.store..price`                | The price of everything in the store
`$..book[2]`                    | The third book via array subscript
`$..book[(@.length-1)]`         | The third book via script subscript
`$..book[-1:]`                  | The last book in order
`$..book[-2:]`                  | The last two books in order
`$..book[-2:-1]`                | The second to last book in order
`$..book[0,1]`                  | The first two books via subscript union
`$..book[:2]`                   | The first two books via subscript array slice
`$..book[?(@.isbn)]`            | Filter all books with ISBN number
`$..book[?(@.price<10)]`        | Filter all books cheaper than 10
`$..book[?(@.price==8.95)]`     | Filter all books that cost 8.95
`$..book[?(@.price<30 && @.category=="fiction")]` | Filter all fiction books cheaper than 30
`$..*`                          | All members of Lua structure


#### Indices

Lua JsonPath uses zero-based array indices, as does Javascript and the JSON notation. This decision has been made to be compatible with the original JsonPath implementation, even though Lua normally uses one-based indices. This convention only applies to JsonPath specifications. The Lua objects processed and returned by this library still use one-based indices.


## Methods

#### jp.query(obj, pathExpression[, count])

Find elements in `obj` matching `pathExpression`.  Returns an array of elements that satisfy the provided JsonPath expression, or an empty array if none were matched.  Returns only first `count` elements if specified.

```lua
local authors = jp.query(data, '$..author')
-- { 'Nigel Rees', 'Evelyn Waugh', 'Herman Melville', 'J. R. R. Tolkien' }
```


#### jp.value(obj, pathExpression)

Returns the value of the first element matching `pathExpression`.

```lua
local author = jp.value(data, '$..author')
-- 'Nigel Rees'
```


#### jp.paths(obj, pathExpression[, count])

Find paths to elements in `obj` matching `pathExpression`.  Returns an array of element paths that satisfy the provided JsonPath expression. Each path is itself an array of keys representing the location within `obj` of the matching element.  Returns only first `count` paths if specified.


```lua
local paths = jp.paths(data, '$..author')
-- {
--   {'$', 'store', 'book', 0, 'author' },
--   {'$', 'store', 'book', 1, 'author' },
--   {'$', 'store', 'book', 2, 'author' },
--   {'$', 'store', 'book', 3, 'author' }
-- }
```


#### jp.nodes(obj, pathExpression[, count])

Find elements and their corresponding paths in `obj` matching `pathExpression`.  Returns an array of node objects where each node has a `path` containing an array of keys representing the location within `obj`, and a `value` pointing to the matched element.  Returns only first `count` nodes if specified.

```lua
local nodes = jp.nodes(data, '$..author')
-- {
--   { path = {'$', 'store', 'book', 0, 'author'}, value = 'Nigel Rees' },
--   { path = {'$', 'store', 'book', 1, 'author'}, value = 'Evelyn Waugh' },
--   { path = {'$', 'store', 'book', 2, 'author'}, value = 'Herman Melville' },
--   { path = {'$', 'store', 'book', 3, 'author'}, value = 'J. R. R. Tolkien' }
-- }
```


#### jp.parse(pathExpression)

Parse the provided JsonPath expression into path components and their associated operations.

```lua
local path = jp.parse('$..author')
-- {
--    '$',
--    '..',
--    'author'
-- }
```


#### jp.grammer()

Provides the lua-jsonpath LPEG grammer for embedding in higher level LPEG grammers.

The abstract syntax tree matched for JsonPath elementes in a higher level LPEG grammer can then be supplied to `jp.nodes()`, `jp.paths()` or `jp.query()` instead of the string `pathExpression`.

```lua
local lpeg = require('lpeg')
local assignment = lpeg.C(lpeg.R'az') * lpeg.P'=' * lpeg.P'"' * jp.grammer() * lpeg.P'"'
local var, ast = assignment:match('x="$..author"')
-- var = 'x'
local results = jp.query(data, ast)
-- { 'Nigel Rees', 'Evelyn Waugh', 'Herman Melville', 'J. R. R. Tolkien' }
```


## Differences from Stefan Goessner's Original Implementation

This implementation aims to be compatible with Stefan Goessner's original implementation with a few notable exceptions described below.

#### Evaluating Script Expressions

Script expressions (i.e, `(...)` and `?(...)`) are statically evaluated rather than using the underlying script engine directly.  That means both that the scope is limited to the instance variable (`@`), and only simple expressions (with no side effects) will be valid.  So for example, `?(@.length>10)` will be just fine to match arrays with more than ten elements, but `?(os.exit())` will not get evaluated since `os` would yield a `ReferenceError`.

#### Grammar

This project uses a formal PEG [grammar] to parse JsonPath expressions, an attempt at reverse-engineering the intent of the original implementation, which parses via a series of creative regular expressions.  The original regex approach can sometimes be forgiving for better or for worse (e.g., `$['store]` => `$['store']`), and in other cases, can be just plain wrong (e.g. `[` => `$`). 

#### Other Minor Differences

As a result of using a real parser and static evaluation, there are some arguable bugs in the original library that have not been carried through here:

- strings in subscripts may now be double-quoted
- final `step` arguments in slice operators may now be negative
- script expressions may now contain `.` and `@` characters not referring to instance variables
- subscripts no longer act as character slices on string elements
- non-ascii non-word characters are no-longer valid in member identifier names; use quoted subscript strings instead (e.g., `$['$']` instead of `$.$`)
- unions now yield real unions with no duplicates rather than concatenated results


## Differences from David Chester's Javascript Implementation

#### Grammar

This implementation aims to be fully compatible with David Chester's Javascript implementation. All applicable test cases were ported from David Chester's project to Lua, and they all pass.

#### API Methods

Some of David Chester's API methods are not implemented in Lua JsonPath:

- `jp.parent(obj, pathExpression)`
- `jp.apply(obj, pathExpression, fn)`
- `jp.stringify(path)`

The `jp.value` API method does not support the third argument (`newValue`).

The `jp.grammer` API method was added in Lua JsonPath. The `jp.query`, `jp.value`, `jp.paths`, `jp.nodes` functions accept abstract syntax trees returned by `lpeg.match` for Lua JsonPath expressions matched using `jp.grammer`. This is for embedding Lua JsonPath into higher level grammers.


## License

*The MIT License*

Copyright (c) 2016 Frank Edelhaeuser

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
