"======================================================================
|
|   ValueAdaptor hierarchy Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: ValueAdaptor [
    
    <category: 'Language-Data types'>
    <comment: 'My subclasses are used to access data from different objects with a consistent
protocol. However, I''m an abstract class.'>

    ValueAdaptor class >> new [
	"We don't know enough of subclasses to have a shared implementation of new"

	<category: 'creating instances'>
	self shouldNotImplement
    ]

    printOn: aStream [
	"Print a representation of the receiver"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $(;
	    print: self value;
	    nextPut: $)
    ]

    value: anObject [
	"Set the value of the receiver. Must be implemented by ValueAdaptor's
	 subclasses"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    value [
	"Retrive the value of the receiver. Must be implemented by ValueAdaptor's
	 subclasses"

	<category: 'accessing'>
	self subclassResponsibility
    ]
]



ValueAdaptor subclass: NullValueHolder [
    
    <category: 'Language-Data types'>
    <comment: 'I pretend to store my value in a variable, but I don''t actually.
You can use the only instance of my class (returned by `ValueHolder null'')
if you''re not interested in a value that is returned as described in
ValueHolder''s comment.'>

    NullValueHolder class [
	| uniqueInstance |
	
    ]

    NullValueHolder class >> new [
	"Not used -- use `ValueHolder null' instead"

	<category: 'creating instances'>
	^self shouldNotImplement
    ]

    NullValueHolder class >> uniqueInstance [
	"Answer the sole instance of NullValueHolder"

	<category: 'creating instances'>
	^uniqueInstance isNil 
	    ifTrue: [uniqueInstance := self basicNew]
	    ifFalse: [uniqueInstance]
    ]

    value: anObject [
	"Set the value of the receiver. Do nothing, discard the value"

	<category: 'accessing'>
	
    ]

    value [
	"Retrive the value of the receiver. Always answer nil"

	<category: 'accessing'>
	^nil
    ]
]



ValueAdaptor subclass: ValueHolder [
    | value |
    
    <category: 'Language-Data types'>
    <comment: 'I store my value in a variable. For example, you can use me to pass
numbers by reference. Just instance me before calling a method and ask for
my value after that method. There are a lot of other creative uses for
my intances, though.'>

    ValueHolder class >> new [
	"Create a ValueHolder whose starting value is nil"

	<category: 'creating instances'>
	^self basicNew initialize
    ]

    ValueHolder class >> null [
	"Answer the sole instance of NullValueHolder"

	<category: 'creating instances'>
	^NullValueHolder uniqueInstance
    ]

    ValueHolder class >> with: anObject [
	"Create a ValueHolder whose starting value is anObject"

	<category: 'creating instances'>
	^self new value: anObject
    ]

    value: anObject [
	"Set the value of the receiver."

	<category: 'accessing'>
	value := anObject
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	^value
    ]

    initialize [
	"Private - set the initial value of the receiver"

	<category: 'initializing'>
	value := nil
    ]
]



Object extend [

    asValue [
	"Answer a ValueHolder whose initial value is the receiver."

	<category: 'conversion'>
	^ValueHolder with: self
    ]

]



ValueHolder subclass: Promise [
    | sema error |
    
    <category: 'Language-Data types'>
    <comment: 'I store my value in a variable, and know whether I have been
initialized or not.  If you ask for my value and I have not been
initialized, I suspend the process until a value has been assigned.'>

    Promise class >> for: aBlock [
	"Invoke aBlock at an indeterminate time in an indeterminate
	 process before answering its value from #value sent to my
	 result."
	<category: 'creating instances'>
	| p |
	p := Promise new.
	[[ p value: aBlock value ]
	    on: Error
	    do: [ :ex | p errorValue: ex. ex return ]] fork.
	^p
    ]

    Promise class >> null [
	<category: 'creating instances'>
	self shouldNotImplement
    ]

    hasError [
	"Answer whether calling #value will raise an exception."

	<category: 'accessing'>
	^error notNil
    ]

    hasValue [
	"Answer whether we already have a value (or calling #value will
	 raise an error)."

	<category: 'accessing'>
	^sema isNil
    ]

    value: anObject [
	"Set the value of the receiver."

	<category: 'accessing'>

	super value: anObject.
	[sema notifyAll. sema := nil] valueWithoutPreemption
    ]

    errorValue: anException [
	"Private - Raise anException whenever #value is called."

	error := anException.
	[sema notifyAll. sema := nil] valueWithoutPreemption
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	
	"This is guaranteed to execute atomically by the VM!"
	sema == nil ifFalse: [sema wait].

	^error isNil
	    ifTrue: [ super value ]
	    ifFalse: [ error copy signal ]
    ]

    printOn: aStream [
	"Print a representation of the receiver"

	<category: 'printing'>
	aStream print: self class.
	self hasValue ifFalse: [ aStream nextPutAll: '(???)' ].
	self hasError ifTrue: [ aStream nextPutAll: '(Error!)' ].

	aStream
	    nextPut: $(;
	    print: self value;
	    nextPut: $)
    ]

    initialize [
	"Private - set the initial state of the receiver"

	<category: 'initializing'>
	super initialize.
	sema := Semaphore new
    ]
]



ValueAdaptor subclass: PluggableAdaptor [
    | getBlock putBlock |
    
    <category: 'Language-Data types'>
    <comment: 'I mediate between complex get/set behavior and the #value/#value:
protocol used by ValueAdaptors. The get/set behavior can be implemented
by two blocks, or can be delegated to another object with messages 
such as #someProperty to get and #someProperty: to set.'>

    PluggableAdaptor class >> getBlock: getBlock putBlock: putBlock [
	"Answer a PluggableAdaptor using the given blocks to implement
	 #value and #value:"

	<category: 'creating instances'>
	^self basicNew getBlock: getBlock putBlock: putBlock
    ]

    PluggableAdaptor class >> on: anObject getSelector: getSelector putSelector: putSelector [
	"Answer a PluggableAdaptor using anObject's getSelector message to
	 implement #value, and anObject's putSelector message to implement
	 #value:"

	<category: 'creating instances'>
	^self basicNew getBlock: [anObject perform: getSelector]
	    putBlock: [:value | anObject perform: putSelector with: value]
    ]

    PluggableAdaptor class >> on: anObject aspect: aSymbol [
	"Answer a PluggableAdaptor using anObject's aSymbol message to
	 implement #value, and anObject's aSymbol: message (aSymbol
	 followed by a colon) to implement #value:"

	<category: 'creating instances'>
	^self 
	    on: anObject
	    getSelector: aSymbol
	    putSelector: (aSymbol , ':') asSymbol
    ]

    PluggableAdaptor class >> on: anObject index: anIndex [
	"Answer a PluggableAdaptor using anObject's #at: and #at:put:
	 message to implement #value and #value:; the first parameter
	 of #at: and #at:put: is anIndex"

	<category: 'creating instances'>
	^self getBlock: [anObject at: anIndex]
	    putBlock: [:value | anObject at: anIndex put: value]
    ]

    PluggableAdaptor class >> on: aDictionary key: aKey [
	"Same as #on:index:. Provided for clarity and completeness."

	<category: 'creating instances'>
	^self on: aDictionary index: aKey
    ]

    value: anObject [
	"Set the value of the receiver."

	<category: 'accessing'>
	putBlock value: anObject
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	^getBlock value
    ]

    getBlock: get putBlock: put [
	<category: 'private'>
	getBlock := get.
	putBlock := put.
	^self
    ]
]



PluggableAdaptor subclass: DelayedAdaptor [
    | value delayed |
    
    <category: 'Language-Data types'>
    <comment: 'I can be used where many expensive updates must be performed. My
instances buffer the last value that was set, and only actually set the
value when the #trigger message is sent. Apart from this, I''m equivalent
to PluggableAdaptor.'>

    trigger [
	"Really set the value of the receiver."

	<category: 'accessing'>
	delayed 
	    ifTrue: 
		[delayed := false.
		super value: value]
    ]

    value: anObject [
	"Set the value of the receiver - actually, the value is cached and
	 is not set until the #trigger method is sent."

	<category: 'accessing'>
	value := anObject.
	delayed := true
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	^delayed ifTrue: [value] ifFalse: [getBlock value]
    ]

    getBlock: get putBlock: put [
	<category: 'private'>
	delayed := false.
	^super getBlock: get putBlock: put
    ]
]

