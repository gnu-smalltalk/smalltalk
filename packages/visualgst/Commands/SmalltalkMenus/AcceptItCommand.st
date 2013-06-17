"======================================================================
|
| AcceptItCommand class definition
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

Command subclass: AcceptItCommand [

    item [
        <category: 'menu item'>

        ^ 'Accept It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>S'
    ]

    stockIcon [

        ^ 'gtk-apply'
    ]

    acceptClassDefinitionOn: aNamespace [
        <category: 'class event'>

        Namespace current: aNamespace.
        "TODO: show errors as in AddMethodUndoCommand."
        target 
	    codeSaved;
	    clearUndo.
        STInST.STEvaluationDriver new
		    parseSmalltalkStream: (ReadStream on: target sourceCode) with: STInST.GSTFileInParser
    ]

    acceptClassDefinition [
        <category: 'class event'>

        ^ self acceptClassDefinitionOn: target state namespace
    ]

    execute [
	<category: 'command'>

        target state hasSelectedCategory ifFalse: [ ^ self acceptClassDefinition ].
        (SysAddMethodCommand
	    add: target sourceCode
	    classified: target state category 
	    in: target state classOrMeta
	    browser: target) executeIfValid
    ]
]

