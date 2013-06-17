"======================================================================
|
| GtkCompiledMethodInspectorView class definition
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

GtkObjectInspectorView subclass: GtkCompiledMethodInspectorView [

    GtkCompiledMethodInspectorView class [ | fields | ]

    GtkCompiledMethodInspectorView class >> fields [
	<category: 'accessing'>

	^ fields ifNil: [ fields := Dictionary from: {'Flags'->#flags. 
					    'Primitive Index'->#primitive.
					    'Number Of Arguments'->#arguments.
					    'Number Of Temporaries'->#temporaries.
					    'Number Of Literals'->#numLiterals.
					    'Needed Stack Slots'->#stack.
					    'Literals'->#literals.
					    'Byte Codes'->#byte.
					    'Source Code'->#source} ]
    ]

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self class fields keys do: aBlock
    ]

    selectedValue: anObject [
	<category: 'events'>

        ^ (self class fields includesKey: anObject)
	    ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ self perform: (self class fields at: anObject) ]
    ]

    flags [
	<category: 'event'>

	^ self object flags
    ]

    primitive [
	<category: 'event'>

	self object flags = 4 ifTrue: [ VMPrimitives keyAtValue: self object primitive ifAbsent: [ 'unknown' ] ].
	^ self object primitive 
    ]

    arguments [
	<category: 'event'>

	^ self object numArgs 
    ]

    temporaries [
	<category: 'event'>

	^ self object numTemps
    ]

    numLiterals [
	<category: 'event'>

	^ self object numLiterals
    ]

    stack [
	<category: 'event'>

	^ self object stackDepth
    ]

    literals [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	1 to: self numLiterals do: [ :i | 
		self object bytecodeIndex: i with: stream. 
		stream tab. 
		stream print: (self object literalAt: i) ].
	^ stream contents
    ]

    byte [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	self object numBytecodes > 0 ifTrue: [ self object printByteCodesOn: stream ].
	^ stream contents
    ]

    source [
	<category: 'event'>

	^ self object methodSourceString
    ]
]

