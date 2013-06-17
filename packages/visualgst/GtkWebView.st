"======================================================================
|
| GtkWebView class definition
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

GTK.GtkWidget subclass: GtkWebView [

    WebKitAvailable := nil.

    GtkWebView class >> initialize [
        <category: 'initialize'>

        DLD addLibrary: 'libwebkit-1.0'.
        DLD addLibrary: 'libwebkitgtk-1.0'.
        ObjectMemory addDependent: self.
    ]

    GtkWebView class >> update: aSymbol [
        <category: 'initialize'>

        aSymbol == #returnFromSnapshot ifTrue: [ WebKitAvailable := nil ].
    ]

    GtkWebView class >> hasWebkit [
        <category: 'testing'>

        ^ WebKitAvailable ifNil: [
            WebKitAvailable :=
                CFunctionDescriptor isFunction: 'webkit_web_view_new' ]
    ]

    GtkWebView class >> new [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_new' returning: #{GtkWebView} args: #( )>
    ]

    openUrl: aString [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_open' returning: #void args: #( #self #string )>
    ]
]

Eval [
    GtkWebView initialize
]
