"======================================================================
|
| MenuBuilder class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

Object subclass: MenuBuilder [

    | commands target |

    MenuBuilder class >> on: aGtkBrowser [
        <category: 'menu-building'>

        ^ self new 
	    target: aGtkBrowser; 
	    connect;
	    yourself
    ]

    MenuBuilder class >> browserBuildOn: aGtkBrowser [
        <category: 'menu-building'>

        ^ (self on: aGtkBrowser) asMenuItems
    ]

    MenuBuilder class >> buildToolbarOn: aGtkBrowser [
        <category: 'menu-building'>

        ^ (self on: aGtkBrowser) asToolItems
    ]

    asPopupMenu [

        | menu |
        menu := GTK.GtkMenu new.
        self appendTo: menu.
        ^ menu
    ]

    asMenuItems [

        ^ commands collect: [ :each | | item accelPath |
            item := each buildMenuItem.
            each accel isNil ifFalse: [
                accelPath := target accelPath, '/', each class name.
                target accelGroup append: {{each accel. accelPath}}.
                item setAccelPath: accelPath ].
            item ]
    ]

    asToolItems [

        ^ commands collect: [ :each | self target appendToolItem: each buildToolItem ]
    ]

    appendTo: aGtkMenu [

        commands do: [ :each | | item |
            item := each buildMenuItem.
            each setState: item.
            aGtkMenu append: item ]
    ]

    target [

        ^ target
    ]

    target: anObject [

        target := anObject.
    ]

    connect [

        commands := self class menus collect: [ :each | each on: self target ]
    ]
]

