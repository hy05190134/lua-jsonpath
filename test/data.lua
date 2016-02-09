--[[

    Copyright (c) 2016 Frank Edelhaeuser

    This file is part of lua-jsonpath.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

]]--
return { 
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
