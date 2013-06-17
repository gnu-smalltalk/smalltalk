"======================================================================
|
| Command class definition
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

Object subclass: Command [

    Command class >> execute [
	<category: 'instance creation'>

	^ self new
	    executeIfValid
    ]

    Command class >> target: anObject [
        <category: 'instance creation'>

	^ self new
	    target: anObject;
	    yourself
    ]

    Command class >> executeOn: anObject [
	<category: 'instance creation'>
    
	^ (self on: anObject)
		    executeIfValid
    ]

    Command class >> on: aGtkBrowser [
        <category: 'instance creation'>

        ^ self new
	    target: aGtkBrowser;
            yourself
    ]

    | target error |
    
    target: anObject [
	<category: 'accessing'>

	target := anObject
    ]

    execute [
	<category: 'command'>

	self subclassResponisibility 
    ]

    valid [
	<category: 'command'>

	^ true
    ]

    preconditionFailed: aString [
        <category: 'checking'>

        error := aString.
        ^ false
    ]

    error [
        <category: 'checking'>

        ^ error
    ]

    executeIfValid [
	<category: 'command'>

        self valid ifFalse: [ ^ self ].
        ^ self
            execute;
            yourself
    ]

    item [
        <category: 'accessing'>

	self subclassResponsibility 
    ]

    accel [
        <category: 'accessing'>

	^ nil
    ]

    tooltip [
	<category: 'accessing'>

	^ ''
    ]

    stockIcon [
	<category: 'accessing'>

	^ ''
    ]

    buildMenuItem [
        <category: 'build'>

        ^ (GTK.GtkMenuItem newWithLabel: self item)
                show;
                connectSignal: 'activate' to: self selector: #executeIfValid;
                yourself
    ]

    buildToolItem [
        <category: 'build'>

	^ (GTK.GtkToolButton newFromStock: self stockIcon label: self item)
                                connectSignal: 'clicked' to: self selector: #executeIfValid;
                                setTooltipText: self tooltip;
                                yourself
    ]

    setState: aGtkMenuItem [
        <category: 'build'>

	aGtkMenuItem setSensitive: self valid
    ]
]

