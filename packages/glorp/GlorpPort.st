nil subclass: ProtoObject [
    
    <comment: nil>
    <category: 'Glorp-Expressions'>

    ProtoObject class >> LICENSE [
	<category: 'LICENSE'>
	^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'
    ]

    doesNotUnderstand: aMessage [
	<category: 'doesNotUnderstand:'>
	3 error: 'dNU on ProtoObject. This should never happen'
    ]

    instVarAt: index [
	"Answer with a fixed variable in an object.  The numbering of the variables
	 corresponds to the named instance variables.  Fail if the index is not an
	 Integer or is not the index of a fixed variable."

	"Access beyond fixed variables."

	<category: 'fundamental primitives'>
	<primitive: VMPrimitives.VMpr_Object_instVarAt>
	^self basicAt: index - self class instSize
    ]

    instVarAt: anInteger put: anObject [
	"Store a value into a fixed variable in the receiver.  The numbering of
	 the variables corresponds to the named instance variables.  Fail if
	 the index is not an Integer or is not the index of a fixed variable.
	 Answer with the value stored as the result.  (Using this message
	 violates the principle that each object has sovereign control over the
	 storing of values into its instance variables.)."

	"Access beyond fixed fields"

	<category: 'fundamental primitives'>
	<primitive: VMPrimitives.VMpr_Object_instVarAtPut>
	^self basicAt: anInteger - self class instSize put: anObject
    ]

    performMethod: method arguments: args [
	"Evaluate the first argument, a CompiledMethod, with the receiver as
	 receiver.  The other argument is the list of arguments of the method.
	 The number of arguments expected by the method must match the size of the
	 Array."

	<category: 'fundamental primitives'>
	<primitive: VMPrimitives.VMpr_Object_performWithArguments>
	
    ]

    performMethod: method with: arg1 [
	"Evaluate the first argument, a CompiledMethod, with the receiver as
	 receiver.  The other argument is the argument of the method. The method
	 must be expecting one argument."

	<category: 'fundamental primitives'>
	<primitive: VMPrimitives.VMpr_Object_perform>
	
    ]
]



Object extend [

    isBlock [
	<category: 'glorp'>
	^false
    ]

]



BlockClosure extend [

    asGlorpExpression [
	<category: 'glorp'>
	^self asGlorpExpressionOn: Glorp.GlorpHelper glorpBaseExpressionClass new
    ]

    asGlorpExpressionForDescriptor: aDescriptor [
	<category: 'glorp'>
	| base |
	base := Glorp.GlorpHelper glorpBaseExpressionClass new.
	base descriptor: aDescriptor.
	^self asGlorpExpressionOn: base
    ]

    asGlorpExpressionOn: anExpression [
	<category: 'glorp'>
	^(self value: Glorp.GlorpHelper glorpMessageArchiverClass new) 
	    asGlorpExpressionOn: anExpression
    ]

    isBlock [
	<category: 'glorp'>
	^true
    ]

]



Number extend [

    glorpPrintSQLOn: aStream [
	"Some Smalltalk have this unpleasant habit of appending characters to
	 anything float-like that's not actually an instance of Float, which
	 happens way down in the guts of the printing, so it's hard to avoid.
	 This seems to be the only reasonable way to work around it without
	 resorting to inefficient and non-portable print policies"

	<category: 'printing'>
	| basic foundLetter each |
	basic := self printString.
	foundLetter := false.
	1 to: basic size
	    do: 
		[:i | 
		each := basic at: i.
		(foundLetter := foundLetter or: [each isLetter]) 
		    ifFalse: [aStream nextPut: each]]
    ]

]



DateTime extend [

    glorpPrintSQLOn: stream [
	"Print the date as yyyy-mm-dd"

	<category: 'glorp'>
	stream
	    nextPut: $';
	    print: self year;
	    nextPut: $-;
	    next: (self monthIndex < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self monthIndex;
	    nextPut: $-;
	    next: (self day < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self day;
	    space;
	    next: (self hour < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self hour;
	    nextPut: $-;
	    next: (self minute < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self minute;
	    nextPut: $-;
	    next: (self second < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self second;
	    nextPut: $'
    ]

]



Collection extend [

    writeStream [
	<category: 'streams'>
	^Glorp.AddingWriteStream on: self
    ]

]

