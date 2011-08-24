"======================================================================
|
|   ObjectDumper Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2006, 2008, 2009
| Free Software Foundation, Inc.
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



Object subclass: DumperProxy [
    
    <category: 'Streams-Files'>
    <comment: 'I am an helper class for ObjectDumper. When an
object cannot be saved in the standard way, you can register a subclass of me
to provide special means to save that object.'>

    DumperProxy class >> loadFrom: anObjectDumper [
	"Reload a proxy stored in anObjectDumper and reconstruct the object"

	<category: 'accessing'>
	^anObjectDumper load object
    ]

    DumperProxy class >> acceptUsageForClass: aClass [
	"The receiver was asked to be used as a proxy for the class aClass.
	 Answer whether the registration is fine.  By default, answer true"

	<category: 'accessing'>
	^true
    ]

    DumperProxy class >> on: anObject [
	"Answer a proxy to be used to save anObject. This method
	 MUST be overridden and anObject must NOT be stored in the
	 object's instance variables unless you override #dumpTo:,
	 because that would result in an infinite loop!"

	<category: 'instance creation'>
	self subclassResponsibility
    ]

    dumpTo: anObjectDumper [
	"Dump the proxy to anObjectDumper -- the #loadFrom: class method
	 will reconstruct the original object."

	<category: 'saving and restoring'>
	anObjectDumper dump: self
    ]

    object [
	"Reconstruct the object stored in the proxy and answer it"

	<category: 'saving and restoring'>
	self subclassResponsibility
    ]
]



DumperProxy subclass: AlternativeObjectProxy [
    | object |
    
    <category: 'Streams-Files'>
    <comment: 'I am a proxy that uses the same ObjectDumper
to store an object which is not the object to be dumped, but from which the
dumped object can be reconstructed.  I am an abstract class, using me would
result in infinite loops because by default I try to store the same object
again and again.  See the method comments for more information'>

    AlternativeObjectProxy class >> acceptUsageForClass: aClass [
	"The receiver was asked to be used as a proxy for the class aClass.
	 Answer whether the registration is fine.  By default, answer true
	 except if AlternativeObjectProxy itself is being used."

	<category: 'instance creation'>
	^self ~~ AlternativeObjectProxy
    ]

    AlternativeObjectProxy class >> on: anObject [
	"Answer a proxy to be used to save anObject. IMPORTANT: this method
	 MUST be overridden so that the overridden version sends #on: to super
	 passing an object that is NOT the same as anObject (alternatively,
	 you can override #dumpTo:, which is what NullProxy does), because that
	 would result in an infinite loop!  This also means that
	 AlternativeObjectProxy must never be used directly -- only as
	 a superclass."

	<category: 'instance creation'>
	^self new object: anObject
    ]

    object [
	"Reconstruct the object stored in the proxy and answer it.  A
	 subclass will usually override this"

	<category: 'accessing'>
	^object
    ]

    primObject [
	"Reconstruct the object stored in the proxy and answer it.  This
	 method must not be overridden"

	<category: 'accessing'>
	^object
    ]

    object: theObject [
	"Set the object to be dumped to theObject.  This should not be
	 overridden."

	<category: 'accessing'>
	object := theObject
    ]
]



AlternativeObjectProxy subclass: NullProxy [
    
    <category: 'Streams-Files'>
    <comment: 'I am a proxy that does no special processing on the object
to be saved. I can be used to disable proxies for particular subclasses.  My
subclasses add to the stored information, but share the fact that the format
is about the same as that of #dump: without a proxy.'>

    NullProxy class >> loadFrom: anObjectDumper [
	"Reload the object stored in anObjectDumper"

	<category: 'instance creation'>
	^anObjectDumper load
    ]

    dumpTo: anObjectDumper [
	"Dump the object stored in the proxy to anObjectDumper"

	<category: 'accessing'>
	anObjectDumper dumpContentsOf: self object
    ]
]



AlternativeObjectProxy subclass: PluggableProxy [
    
    <category: 'Streams-Files'>
    <comment: 'I am a proxy that stores a different object
and, upon load, sends #reconstructOriginalObject to that object (which
can be a DirectedMessage, in which case the message is sent).  The
object to be stored is retrieved by sending #binaryRepresentationObject to
the object.'>

    PluggableProxy class >> on: anObject [
	"Answer a proxy to be used to save anObject.  The proxy
	 stores a different object obtained by sending to anObject
	 the #binaryRepresentationObject message (embedded
	 between #preStore and #postStore as usual)."

	<category: 'accessing'>
	anObject preStore.
	^[super on: anObject binaryRepresentationObject] 
	    ensure: [anObject postStore]
    ]

    object [
	"Reconstruct the object stored in the proxy and answer it;
	 the binaryRepresentationObject is sent the
	 #reconstructOriginalObject message, and the resulting
	 object is sent the #postLoad message."

	<category: 'saving and restoring'>
	^(super object reconstructOriginalObject)
	    postLoad;
	    yourself
    ]
]



NullProxy subclass: VersionableObjectProxy [
    
    <category: 'Streams-Files'>
    <comment: 'I am a proxy that stores additional
information to allow different versions of an object''s representations
to be handled by the program.  VersionableObjectProxies are backwards
compatible, that is you can support versioning even if you did not use
a VersionableObjectProxy for that class when the object was originarily
dumped.  VersionableObjectProxy does not support classes that changed
shape across different versions.  See the method comments for more
information.'>

    VersionableObjectProxy class >> loadFrom: anObjectDumper [
	"Retrieve the object.  If the version number doesn't match the
	 #binaryRepresentationVersion answered by the class, call the class'
	 #convertFromVersion:withFixedVariables:instanceVariables:for: method.
	 The stored version number will be the first parameter to that method
	 (or nil if the stored object did not employ a VersionableObjectProxy),
	 the remaining parameters will be respectively the fixed instance
	 variables, the indexed instance variables (or nil if the class is
	 fixed), and the ObjectDumper itself.
	 If no VersionableObjectProxy, the class is sent #nonVersionedInstSize
	 to retrieve the number of fixed instance variables stored for the
	 non-versioned object."

	<category: 'saving and restoring'>
	| version object instSize index |
	version := anObjectDumper nextLong.
	version := version >= 0 
		    ifTrue: 
			["The version was actually an object index."
			instSize := nil.
			index := version.
			nil]
		    ifFalse: 
			[instSize := anObjectDumper nextUlong.
			index := anObjectDumper nextLong.
			-1 - version].
	^anObjectDumper loadFromVersion: version fixedSize: instSize index: index
    ]

    dumpTo: anObjectDumper [
	"Save the object with extra versioning information."

	<category: 'saving and restoring'>
	anObjectDumper
	    nextPutLong: -1 - self object class binaryRepresentationVersion;
	    nextPutLong: self object class instSize.
	super dumpTo: anObjectDumper
    ]
]



AlternativeObjectProxy subclass: SingletonProxy [
    
    <category: 'Streams-Files'>
    <comment: 'I am a proxy that stores the class of an
object rather than the object itself, and pretends that a registered
instance (which most likely is a singleton instance of the stored class)
was stored instead.'>

    SingletonProxy class [
	| singletons |
	
    ]

    SingletonProxy class >> singletons [
	<category: 'private'>
	^singletons isNil 
	    ifTrue: [singletons := IdentityDictionary new]
	    ifFalse: [singletons]
    ]

    SingletonProxy class >> acceptUsageForClass: aClass [
	"The receiver was asked to be used as a proxy for the class aClass.
	 The registration is fine if the class is actually a singleton."

	<category: 'accessing'>
	| singleton |
	singleton := aClass someInstance.
	singleton nextInstance isNil ifFalse: [^false].
	self singletons at: aClass put: singleton.
	^true
    ]

    SingletonProxy class >> on: anObject [
	"Answer a proxy to be used to save anObject.  The proxy
	 stores the class and restores the object by looking into
	 a dictionary of class -> singleton objects."

	<category: 'instance creation'>
	(self singletons includesKey: anObject class) 
	    ifTrue: [^super on: anObject class].
	self error: 'class not registered within SingletonProxy'
    ]

    object [
	"Reconstruct the object stored in the proxy and answer it;
	 the binaryRepresentationObject is sent the
	 #reconstructOriginalObject message, and the resulting
	 object is sent the #postLoad message."

	<category: 'saving and restoring'>
	^self class singletons at: super object
	    ifAbsent: [self error: 'class not registered within SingletonProxy']
    ]
]



Eval [
    ObjectDumper
	initialize;
	registerProxyClass: PluggableProxy for: CompiledMethod;
	registerProxyClass: PluggableProxy for: CompiledBlock;
	registerProxyClass: SingletonProxy for: Processor class
]
