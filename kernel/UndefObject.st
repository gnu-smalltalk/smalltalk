"======================================================================
|
|   UndefinedObject (nil) Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

Object subclass: #UndefinedObject
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

UndefinedObject comment:
'I have the questionable distinction of being a class with only one
instance, which is the object "nil".' !



!UndefinedObject methodsFor: 'basic'!

copy
    ^self
!

shallowCopy
    ^self
!

deepCopy
    ^self
!

!UndefinedObject methodsFor: 'testing'!

isNil
    "Answer whether the receiver is the undefined object nil. Always
     answer true."
    ^true
!

notNil
    "Answer whether the receiver is not the undefined object nil. Always
     answer false."
    ^false
!

ifNil: nilBlock
    "Evaluate nilBlock if the receiver is nil, else answer nil"
    ^nilBlock value
!

ifNil: nilBlock ifNotNil: notNilBlock
    "Evaluate nilBlock if the receiver is nil, else evaluate
     notNilBlock, passing the receiver."
    ^nilBlock value
!

ifNotNil: notNilBlock
    "Evaluate notNilBlock if the receiver is not nil, passing the receiver.
     Else answer nil"
    ^nil
!

ifNotNil: notNilBlock ifNil: nilBlock
    "Evaluate nilBlock if the receiver is nil, else evaluate
     notNilBlock, passing the receiver."
    ^nilBlock value
! !


!UndefinedObject methodsFor: 'dependents access'!

addDependent: ignored 
    "Fail, nil does not support dependents."
    self shouldNotImplement
!

release
    "Ignore this call, nil does not support dependents."
! !


!UndefinedObject methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream."
    aStream nextPutAll: 'nil'
! !



!UndefinedObject methodsFor: 'storing'!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream."
    self printOn: aStream

! !


!UndefinedObject methodsFor: 'class creation - alternative'!

subclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	subclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

subclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	subclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
!

variableSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	variableSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

variableSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	variableSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
!

variableByteSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	variableByteSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

variableByteSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	variableByteSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
!

variableWordSubclass: classNameString instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^self
	variableWordSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category'
!

variableWordSubclass: classNameString classInstanceVariableNames: stringClassInstVarNames instanceVariableNames: stringInstVarNames classVariableNames: stringOfClassVarNames poolDictionaries: stringOfPoolNames
    "Don't use this, it is only present to file in from IBM Smalltalk"
    ^(self
	variableWordSubclass: classNameString
	instanceVariableNames: stringInstVarNames
	classVariableNames: stringOfClassVarNames
	poolDictionaries: stringOfPoolNames
	category: 'no category')
	classInstanceVariableNames: stringClassInstVarNames;
	yourself
! !


!UndefinedObject methodsFor: 'class creation'!

removeSubclass: aClass
	"Ignored -- necessary to support disjoint class hierarchies"!

subclass: classNameString
    instanceVariableNames: stringInstVarNames
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryNameString
    "Define a fixed subclass of the receiver with the given name, instance
     variables, class variables, pool dictionaries and category. If the
     class is already defined, if necessary, recompile everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	  environment: Namespace current
	  subclassOf: self
	  instanceVariableNames: stringInstVarNames
	  variable: false
	  words: false
	  pointers: true
	  classVariableNames: stringOfClassVarNames
	  poolDictionaries: stringOfPoolNames
	  category: categoryNameString
!

variableSubclass: classNameString
    instanceVariableNames: stringInstVarNames
    classVariableNames: stringOfClassVarNames
    poolDictionaries: stringOfPoolNames
    category: categoryNameString
    "Define a variable pointer subclass of the receiver with the given
     name, instance variables, class variables, pool dictionaries and
     category. If the class is already defined, if necessary, recompile
     everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	  environment: Namespace current
	  subclassOf: self
	  instanceVariableNames: stringInstVarNames
	  variable: true
	  words: false
	  pointers: true
	  classVariableNames: stringOfClassVarNames
	  poolDictionaries: stringOfPoolNames
	    category: categoryNameString
!

variableWordSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    "Define a word variable subclass of the receiver with the given
     name, instance variables, class variables, pool dictionaries and
     category. If the class is already defined, if necessary, recompile
     everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    variable: true
	    words: true
	    pointers: false
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
!

variableByteSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    "Define a byte variable subclass of the receiver with the given
     name, instance variables, class variables, pool dictionaries
     and category. If the class is already defined, if necessary,
     recompile everything needed."

    | meta |
    KernelInitialized ifFalse: [
	^(Smalltalk at: classNameString) category: categoryNameString
    ].

    meta := self metaclassFor: classNameString.
    ^meta name: classNameString
	    environment: Namespace current
	    subclassOf: self
	    instanceVariableNames: stringInstVarNames
	    variable: true
	    words: false
	    pointers: false
	    classVariableNames: stringOfClassVarNames
	    poolDictionaries: stringOfPoolNames
	    category: categoryNameString
!

metaclassFor: classNameString
    "Create a Metaclass object for the given class name. The metaclass
     is a subclass of Class"
    | className class |
    className := classNameString asSymbol.
    class := Namespace current hereAt: className ifAbsent: [ nil ].

    ^(class isNil or: [ class isClass not ])
        ifTrue: [ Metaclass subclassOf: Class ]
        ifFalse: [ class class ]
! !


!UndefinedObject methodsFor: 'private'!

mutate: instVarMap startAt: start newClass: class
    "Private - Do nothing, this is here in case the WeakArray garbage
     collects an object that is to be mutated."
! !
