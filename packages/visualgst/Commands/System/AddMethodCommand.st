"======================================================================
|
| SysAddMethodCommand class definition
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

Command subclass: SysAddMethodCommand [

    | selector method category classOrMeta oldCompiledMethod browserWidget compiledMethod |

    SysAddMethodCommand class >> add: aString classified: aCategory in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aString classified: aCategory in: aClass;
	    yourself
    ]

    SysAddMethodCommand class >> add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'instance creation'>

        ^ (self new)
            add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget;
            yourself
    ]

    compileError: aString line: anInteger [
	<category: 'error printing'>

	browserWidget isNil ifFalse: [ GtkLauncher compileError: aString line: anInteger ].
	^ self preconditionFailed: aString
    ]

    compileError: aString pos: pos [
	<category: 'error printing'>

	^ self compileError: aString line: nil
    ]

    add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'initialize'>

	self add: aString classified: aCategory in: aClass.
	browserWidget := aGtkBrowserWidget.
    ]

    add: aString classified: aCategory in: aClass [
	<category: 'initialize'>

	method := aString.
        category := (#('still unclassified' '*') includes: (aCategory))
					    ifTrue: [ nil ]
					    ifFalse: [ aCategory ].
	classOrMeta := aClass
    ]

    description [
	<category: 'accessing'>

	^ 'Add a method'
    ]

    valid [
        <category: 'checking'>

	| parser node |
        parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | self compileError: string pos: pos. ^false ];
                    initializeParserWith: method type: #'on:errorBlock:';
                    yourself.

	selector := parser parseMethod selector.
	oldCompiledMethod := classOrMeta methodDictionary ifNotNil: [ classOrMeta methodDictionary at: selector ifAbsent: [ nil ] ].
	" TODO: use compile:classified:ifError: if there is no category "
	compiledMethod := classOrMeta
				compile: method
				ifError: [ :fname :lineNo :errorString |
				    self compileError: errorString line: lineNo.
                                    ^ false ].
	^ true
    ]

    execute [
	<category: 'events'>

	browserWidget ifNotNil: [ browserWidget codeSaved ].

	oldCompiledMethod ifNotNil: [ classOrMeta methodDictionary removeMethod: oldCompiledMethod ].
	classOrMeta methodDictionary insertMethod: compiledMethod.

	browserWidget ifNotNil: [ classOrMeta isClass 
						    ifTrue: [ browserWidget selectAnInstanceMethod: compiledMethod selector ]
						    ifFalse: [ browserWidget selectAClassMethod: compiledMethod selector ] ]
    ]

    displayError [
        <Category: 'error'>

    ]
]

