"======================================================================
|
|   Object Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1990,1991,1992,94,95,99,2000,2001,2002,2003
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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

nil subclass: #Object
       instanceVariableNames: ''
       classVariableNames: 'Dependencies FinalizableObjects'
       poolDictionaries: ''
       category: 'Language-Implementation'
!

Object comment: 
'I am the root of the Smalltalk class system. 
All classes in the system are subclasses of me.' !


!Object class methodsFor: 'initialization'!

update: aspect
    "Do any global tasks for the ObjectMemory events."
    aspect == #returnFromSnapshot ifFalse: [ ^self ].

    ContextPart checkPresenceOfJIT.
    FinalizableObjects := nil
!

dependencies
    "Answer a dictionary that associates an object with its dependents."

    ^Dependencies!

dependencies: anObject
    "Use anObject as the dictionary that associates an object with its dependents."

    Dependencies := anObject!

finalizableObjects
    "Answer a set of finalizable objects."

    FinalizableObjects isNil ifTrue: [ FinalizableObjects := Set new ].
    ^FinalizableObjects!

initialize
    "Initialize the Dependencies dictionary to be an IdentityDictionary.  In a later
     phase of the bootstrap process this is changed to be a WeakKeyIdentityDictionary."

    self == Object ifFalse: [ ^self ].
    self dependencies: IdentityDictionary new.
    ObjectMemory addDependent: self
! !


!Object methodsFor: 'relational operators'!

~= anObject
    "Answer whether the receiver and anObject are not equal"
    ^(self = anObject) == false
!

~~ anObject
    "Answer whether the receiver and anObject are not the same object"
    ^(self == anObject) == false 
! !



!Object methodsFor: 'testing functionality'!

isKindOf: aClass
    "Answer whether the receiver's class is aClass or
     a subclass of aClass"
    ^self class == aClass or:
    	[ self class inheritsFrom: aClass ]
!

isMemberOf: aClass
    "Returns true if the receiver is an instance of the class 'aClass'"
    ^self class == aClass
!

respondsTo: aSymbol
    "Returns true if the receiver understands the given selector"
    ^self class canUnderstand: aSymbol
!

isNil
    "Answer whether the receiver is nil"
    ^false
!

notNil
    "Answer whether the receiver is not nil"
    ^true
!

ifNil: nilBlock
    "Evaluate nilBlock if the receiver is nil, else answer self"
    ^self
!

ifNil: nilBlock ifNotNil: notNilBlock
    "Evaluate nilBlock if the receiver is nil, else evaluate
     notNilBlock, passing the receiver."
    ^notNilBlock value: self
!

ifNotNil: notNilBlock
    "Evaluate notNiilBlock if the receiver is not nil, passing the receiver.
     Else answer nil."
    ^notNilBlock value: self
!

ifNotNil: notNilBlock ifNil: nilBlock
    "Evaluate nilBlock if the receiver is nil, else evaluate
     notNilBlock, passing the receiver."
    ^notNilBlock value: self
!

isString
    ^false
!

isCharacterArray
    ^false
!

isSymbol
    ^false
!

isCharacter
    ^false
!

isNumber
    ^false
!

isFloat
    ^false
!

isInteger
    ^false
!

isSmallInteger
    ^false
!

isNamespace
    ^false
!

isClass
    ^false
!

isArray
    ^false
!

isBehavior
    ^false
!

isMeta
    "Same as isMetaclass"
    ^self isMetaclass
!

isMetaClass
    "Same as isMetaclass"
    ^self isMetaclass
!

isMetaclass
    ^false
! !


!Object methodsFor: 'copying'!

copy
    "Returns a shallow copy of the receiver (the instance variables are
     not copied). The shallow copy receives the message postCopy and the
     result of postCopy is passed back."
    ^self shallowCopy postCopy
!

postCopy
    "Performs any changes required to do on a copied object. This is the
     place where one could, for example, put code to replace objects with
     copies of the objects"
    ^self
!

deepCopy
    "Returns a deep copy of the receiver (the instance variables are
     copies of the receiver's instance variables)"
    | class aCopy num |
    class := self class.
    aCopy := self shallowCopy.
    class isPointers
    	ifTrue: [ num := class instSize + self basicSize ]
	ifFalse: [ num := class instSize ].

    " copy the instance variables (if any) "
    1 to: num do: [ :i |
    	aCopy instVarAt: i put: (self instVarAt: i) copy.
    ].
    ^aCopy
! !



!Object methodsFor: 'class type methods'!

species
    "This method has no unique definition. Generally speaking, methods which
     always return the same type usually don't use #class, but #species.
     For example, a PositionableStream's species is the class of the collection
     on which it is streaming (used by upTo:, upToAll:, upToEnd). Stream uses
     species for obtaining the class of next:'s return value, Collection uses
     it in its #copyEmpty: message, which in turn is used by all collection-re-
     turning methods. An Interval's species is Array (used by collect:, select:,
     reject:, etc.)."
    ^self class
!

yourself
    "Answer the receiver"
    ^self
! !



!Object methodsFor: 'dependents access'!

addDependent: anObject
    "Add anObject to the set of the receiver's dependents. Important:
     if an object has dependents, it won't be garbage collected."

    ^(Dependencies at: self ifAbsentPut: [ OrderedCollection new ])
	add: anObject
!

removeDependent: anObject
    "Remove anObject to the set of the receiver's dependents. No problem
     if anObject is not in the set of the receiver's dependents."
    | dependencies |
    dependencies := Dependencies at: self ifAbsent: [ ^anObject ].
    dependencies remove: anObject ifAbsent: [].
    dependencies size < 1 ifTrue: [ self release ].
    ^anObject
!

dependents
    "Answer a collection of the receiver's dependents."
    | dependencies |
    dependencies := Dependencies at: self ifAbsent: [ ^OrderedCollection new ].
    ^dependencies asOrderedCollection
!

release
    "Remove all of the receiver's dependents from the set and allow the
     receiver to be garbage collected."

    Dependencies removeKey: self ifAbsent: [ ]
! !


!Object methodsFor: 'finalization'!

addToBeFinalized
    "Arrange things so that #finalize is sent to the object when the garbage
     collector finds out there are only weak references to it."

    self class finalizableObjects
	add: ((HomedAssociation key: self value: nil environment: FinalizableObjects)
	    makeEphemeron;
	    yourself)
!

removeToBeFinalized
    "Unregister the object, so that #finalize is no longer sent to the object
     when the garbage collector finds out there are only weak references to it."

    self class finalizableObjects
	remove: (HomedAssociation key: self value: nil environment: self class finalizableObjects)
        ifAbsent: []
!

mourn
    "This method is sent by the VM to weak and ephemeron objects when one of
     their fields is found out to be garbage collectable (this means, for weak
     objects, that there are no references to it from non-weak objects, and
     for ephemeron objects, that the only paths to the first instance variable
     pass through other instance variables of the same ephemeron).  The default
     behavior is to do nothing."
!

finalize
    "Do nothing by default"
! !


!Object methodsFor: 'change and update'!

changed
    "Send update: for each of the receiver's dependents, passing them the
     receiver"
    self changed: self
!

changed: aParameter
    "Send update: for each of the receiver's dependents, passing them
     aParameter"
    | dependencies |
    dependencies := Object dependencies at: self ifAbsent: [ nil ].
    dependencies notNil ifTrue:
    	[ dependencies do:
	    [ :dependent | dependent update: aParameter ] ]
!

update: aParameter
    "Default behavior is to do nothing. Called by #changed and #changed:"
!

broadcast: aSymbol
    "Send the unary message aSymbol to each of the receiver's dependents"
    | dependencies |
    dependencies := Object dependencies at: self ifAbsent: [ nil ].
    dependencies notNil ifTrue:
    	[ dependencies do:
	    [ :dependent | dependent perform: aSymbol ] ]
!

broadcast: aSymbol with: anObject
    "Send the message aSymbol to each of the receiver's dependents, passing
     anObject"
    | dependencies |
    dependencies := Object dependencies at: self ifAbsent: [ nil ].
    dependencies notNil ifTrue:
    	[ dependencies do:
	    [ :dependent | dependent perform: aSymbol with: anObject ] ]
!

broadcast: aSymbol with: arg1 with: arg2
    "Send the message aSymbol to each of the receiver's dependents, passing
     arg1 and arg2 as parameters"
    | dependencies |
    dependencies := Object dependencies at: self ifAbsent: [ nil ].
    dependencies notNil ifTrue:
    	[ dependencies do:
	    [ :dependent | dependent perform: aSymbol with: arg1 with: arg2 ] ]
!

broadcast: aSymbol withBlock: aBlock
    "Send the message aSymbol to each of the receiver's dependents, passing
     the result of evaluating aBlock with each dependent as the parameter"
    | dependencies |
    dependencies := Object dependencies at: self ifAbsent: [ nil ].
    dependencies notNil ifTrue:
    	[ dependencies do:
	    [ :dependent | dependent
		perform: aSymbol
		with: (aBlock value: dependent) ] ]
!

broadcast: aSymbol withArguments: anArray
    "Send the message aSymbol to each of the receiver's dependents, passing
     the parameters in anArray"
    | dependencies |
    dependencies := Object dependencies at: self ifAbsent: [ nil ].
    dependencies notNil ifTrue:
    	[ dependencies do:
	    [ :dependent | dependent perform: aSymbol withArguments: anArray ] ]
! !



!Object methodsFor: 'syntax shortcuts'!

-> anObject
    "Creates a new instance of Association with the receiver being the key
     and the argument becoming the value"
    ^Association key: self value: anObject
! !




!Object methodsFor: 'printing'!

displayString
    "Answer a String representing the receiver. For most objects
     this is simply its #printString, but for strings and characters,
     superfluous dollars or extra pair of quotes are stripped."
    | stream |
    stream := WriteStream on: String new.
    self displayOn: stream.
    ^stream contents
!

displayOn: aStream
    "Print a represention of the receiver on aStream. For most objects
     this is simply its #printOn: representation, but for strings and
     characters, superfluous dollars or extra pair of quotes are stripped."
    self printOn: aStream
!

display
    "Print a represention of the receiver on the Transcript (stdout the GUI
     is not active). For most objects this is simply its #print
     representation, but for strings and characters, superfluous dollars
     or extra pair of quotes are stripped."
    Transcript show: self displayString
!

displayNl
    "Print a represention of the receiver, then put a new line on
     the Transcript (stdout the GUI is not active). For most objects this
     is simply its #printNl representation, but for strings and
     characters, superfluous dollars or extra pair of quotes are stripped."
    Transcript showCr: self displayString
!

printString
    "Answer a String representing the receiver"
    | stream |
    stream := WriteStream on: String new.
    self printOn: stream.
    ^stream contents
!

printOn: aStream
    "Print a represention of the receiver on aStream"
    aStream nextPutAll: self class article; space;
	    nextPutAll: self class name
!

basicPrintOn: aStream
    "Print a represention of the receiver on aStream"
    aStream nextPutAll: self class article; space;
	    nextPutAll: self class name
!

print
    "Print a represention of the receiver on the Transcript (stdout the GUI
     is not active)"
    Transcript show: self printString
!

printNl
    "Print a represention of the receiver on stdout, put a new line
     the Transcript (stdout the GUI is not active)"
    Transcript showCr: self printString
!

basicPrintNl
    "Print a basic representation of the receiver, followed by a new line."
    stdout flush.
    self basicPrint.
    stdout nextPutAllFlush: Character nl
! !



!Object methodsFor: 'storing'!

storeString
    "Answer a String of Smalltalk code compiling to the receiver"
    | stream |
    stream := WriteStream on: String new.
    self storeOn: stream.
    ^stream contents
!

storeOn: aStream
    "Put Smalltalk code compiling to the receiver on aStream"
    | class hasSemi |
    class := self class.
    aStream nextPut: $(.
    aStream nextPutAll: self classNameString.
    hasSemi := false.
    class isVariable
    	ifTrue: [ aStream nextPutAll: ' basicNew: '.
	    	  self basicSize printOn: aStream ]
    	ifFalse: [ aStream nextPutAll: ' basicNew' ].
    1 to: class instSize do:
    	[ :i | aStream nextPutAll: ' instVarAt: '.
	       i printOn: aStream.
	       aStream nextPutAll: ' put: '.
	       (self instVarAt: i) storeOn: aStream.
	       aStream nextPut: $;.
	       hasSemi := true ].
    class isVariable ifTrue: 
    	[ 1 to: self validSize do:
	    [ :i | aStream nextPutAll: ' basicAt: '.
	    	   i printOn: aStream.
		   aStream nextPutAll: ' put: '.
		   (self basicAt: i) storeOn: aStream.
		   aStream nextPut: $;.
		   hasSemi := true ] ].
    hasSemi ifTrue: [ aStream nextPutAll: ' yourself' ].
    aStream nextPut: $)
!

store
    "Put a String of Smalltalk code compiling to the receiver on
     the Transcript (stdout the GUI is not active)"
    Transcript show: self storeString
!

storeNl
    "Put a String of Smalltalk code compiling to the receiver, followed by
     a new line, on the Transcript (stdout the GUI is not active)"
    Transcript showCr: self storeString
! !


!Object methodsFor: 'saving and loading'!

binaryRepresentationObject
    "This method must be implemented if PluggableProxies are used with
     the receiver's class.  The default implementation raises an exception."
    (ObjectDumper proxyClassFor: self) == PluggableProxy
	ifTrue: [ self subclassResponsibility ]
	ifFalse: [ self shouldNotImplement ]
!

postLoad
    "Called after loading an object; must restore it to the state before
     `preStore' was called.  Do nothing by default"
!

postStore
    "Called after an object is dumped; must restore it to the state before
     `preStore' was called.  Call #postLoad by default"
    self postLoad.
!

preStore
    "Called before dumping an object; it must *change* it (it must not answer
    a new object) if necessary.  Do nothing by default"
!

reconstructOriginalObject
    "Used if an instance of the receiver's class is returned as the
     #binaryRepresentationObject of another object.  The default implementation
     raises an exception."
    self subclassResponsibility
! !



!Object methodsFor: 'debugging'!

breakpoint: context return: return
    "Called back by the system. Must return the value passed through the
     second parameter"

    context method removeBreakpointAt: context ip.
    ^return
!

inspect
    "Print all the instance variables of the receiver on the Transcript"
    | class instVars instVal |
    class := self class.
    instVars := class allInstVarNames.
    Transcript nextPutAll: 'An instance of '.
    class printNl.
    1 to: instVars size do:
    	[ :i | Transcript nextPutAll: '  ';
		   nextPutAll: (instVars at: i);
		   nextPutAll: ': '.
	       (self instVarAt: i)  printNl ].

    1 to: self validSize do:
	[ :i | Transcript nextPutAll: '  [';
	       print: i;
	       nextPutAll: ']: ';
	       print: (self basicAt: i);
	       nl ] 
!

validSize
    "Answer how many elements in the receiver should be inspected"
    ^self basicSize
! !



!Object methodsFor: 'private'!

classNameString
    "Answer the name of the receiver's class"
    | name |
    name := self class name.
    name isNil
    	ifTrue: [ name := self name , ' class' ].

    ^name

!

mutate: instVarMap startAt: start newClass: class
    "Private - Mutate object to a new class representation. instVarMap
     maps between old instVarAt: indices and new instVarAt:put: indices.
     start is the first instance variable to change."

    | aCopy mappedValue end adjustment |
    
    adjustment := self class instSize - class instSize.

    aCopy := self class isVariable
	ifTrue: [ class basicNew: self basicSize ]
	ifFalse: [ class basicNew ].

    end := instVarMap size + start - 1.

    "Copy the instance variables, if any"
    1 to: start - 1 do: [ :i |
	aCopy instVarAt: i put: (self instVarAt: i)
    ].
				 
    "Copy old instance variables to their new positions using instVarMap"
    start to: end do: [ :i |
	mappedValue := instVarMap at: i - start + 1. 
	mappedValue notNil ifTrue: [
	    aCopy instVarAt: i put: (self instVarAt: mappedValue)
	]
    ].
    end + 1 to: class instSize do: [ :i |
	aCopy instVarAt: i put: (self instVarAt: i + adjustment)
    ].

    "Copy the indexed variables, if any."
    1 to: self basicSize do: [ :i |
	aCopy basicAt: i put: (self basicAt: i).
    ].
    ^self become: aCopy
! !
