"======================================================================
|
|   Java run-time support.  Extensions for base classes & JavaMetaobjects.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

!JavaTranslatedExceptionHandlerTable methodsFor: 'finding exception handlers'!

value: context value: signal
    | pc low high mid first item |
    signal class == JavaException ifFalse: [ ^nil ].

    pc := context ip.
    low := 1.
    high := self size.

    "Do a binary search on the table to find a possible
     handler"
    [mid := (low + high) // 2.
    low > high ifTrue: [^nil].
    item := self at: mid.
    item includes: pc] whileFalse: 
	[item startpc < pc ifTrue: [low := mid + 1] ifFalse: [high := mid - 1]].

    "Go back to find the first one"
    first := mid.
    [ first > 1 and: [ (self at: first - 1) includes: pc ] ]
	whileTrue: [ first := first - 1 ].

    "Between the two, we can skip a range check"
    [
	item := self at: first.
	(item type isNil or: [ signal tag isKindOf: item type ])
	    ifTrue: [
		context at: self exceptionTemp put: signal tag.
		signal foundJavaHandler: item in: context.
		^#found ].

	first < mid
    ] whileTrue: [
	first := first + 1
    ].

    "Then we also have to check if the pc is ok."
    [
	first = self size ifTrue: [ ^nil ].
	first := first + 1.
	item := self at: first.
	(item includes: pc) ifFalse: [ ^nil ].
	(item type isNil or: [ signal tag isKindOf: item type ])
	    ifTrue: [
		context at: self exceptionTemp put: signal tag.
		signal foundJavaHandler: item in: context.
		^#found ].
    ] repeat.
! !

!JavaClass methodsFor: 'translation'!

install
    | theNamespace theSuperclass |
    self isLoaded ifFalse: [ self load ].

    theNamespace := self package asSmalltalkPackage.
    theSuperclass := self extends isNil 
    	ifTrue: [JavaObject]
    	ifFalse: 
    	    ["Try to reuse the namespace we found for this class, as
	      superclasses often reside in the same package as subclasses."
    	    self extends
    		asSmalltalkClassWithPackage: self package
    		associatedToNamespace: theNamespace].

    "Transcript show: 'Installing '; show: self fullName; nl."
    ^theSuperclass createSubclass: self into: theNamespace! !

!JavaClass methodsFor: 'translation'!

asSmalltalkClassWithPackage: knownPackage associatedToNamespace: smalltalkPackage
    | ourSmalltalkPackage smalltalkClass |
    ourSmalltalkPackage := package == knownPackage
        ifTrue: [ smalltalkPackage ]
        ifFalse: [ package asSmalltalkPackage ].

    smalltalkClass := ourSmalltalkPackage
	hereAt: self name asSymbol
	ifAbsent: [ nil ].

    smalltalkClass isNil ifTrue: [
	smalltalkClass := self install ].

    ^smalltalkClass!

asSmalltalkClass
    | smalltalkPackage smalltalkClass |
    smalltalkPackage := package asSmalltalkPackage.
    smalltalkClass := smalltalkPackage
	hereAt: self name asSymbol
	ifAbsent: [ nil ].

    smalltalkClass isNil ifTrue: [
	smalltalkClass := self install ].

    ^smalltalkClass! !

!JavaPackage methodsFor: 'translation'!

asSmalltalkPackage
    | containerSmalltalkPackage |
    self == Root ifTrue: [ ^Java ].

    containerSmalltalkPackage := self container asSmalltalkPackage.
    ^containerSmalltalkPackage
        at: self name asSymbol
        ifAbsent: [
            containerSmalltalkPackage addSubspace: self name asSymbol.
            containerSmalltalkPackage at: self name asSymbol ]
! !


!JavaStringPrototype methodsFor: 'bootstrap'!

convertToJavaLangString
    self makeReadOnly: false.
    ^self become: self stringValue asJavaString
! !

!String methodsFor: 'java'!

asJavaString
    ^Java.java.lang.String new
        perform: #'<init>([C)V' with: self
! !


!Number methodsFor: 'java conversion'!

javaCmpL: anInteger
    self = anInteger ifTrue: [ ^0 ].
    ^self > anInteger ifTrue: [ 1 ] ifFalse: [ -1 ]!

javaCmpG: anInteger
    self = anInteger ifTrue: [ ^0 ].
    ^self < anInteger ifTrue: [ -1 ] ifFalse: [ 1 ]!

javaAsByte
    | i |
    i := self asInteger bitAnd: 255.
    ^i < 128 ifTrue: [ i ] ifFalse: [ i - 256 ]!

javaAsShort
    | i |
    i := self asInteger bitAnd: 65535.
    ^i < 32768 ifTrue: [ i ] ifFalse: [ i - 65536 ]!

javaAsInt
    | i j |
    j := self asInteger.
    j size <= 4 ifTrue: [ ^j ].
    i := (j at: 4) < 128
	ifTrue: [ LargePositiveInteger new: 4 ]
	ifFalse: [ LargeNegativeInteger new: 4 ].

    i at: 1 put: (j at: 1).
    i at: 2 put: (j at: 2).
    i at: 3 put: (j at: 3).
    i at: 4 put: (j at: 4).
    ^i!

javaAsLong
    | i j |
    j := self asInteger.
    j size <= 8 ifTrue: [ ^j ].
    i := (j at: 8) < 128
	ifTrue: [ LargePositiveInteger new: 8 ]
	ifFalse: [ LargeNegativeInteger new: 8 ].

    i at: 1 put: (j at: 1).
    i at: 2 put: (j at: 2).
    i at: 3 put: (j at: 3).
    i at: 4 put: (j at: 4).
    i at: 5 put: (j at: 5).
    i at: 6 put: (j at: 6).
    i at: 7 put: (j at: 7).
    i at: 8 put: (j at: 8).
    ^i!

!Integer methodsFor: 'java arithmetic'!

javaCmp: anInteger
    self = anInteger ifTrue: [ ^0 ].
    ^self < anInteger ifTrue: [ -1 ] ifFalse: [ 1 ]!

javaAsByte
    | i |
    i := self bitAnd: 255.
    ^i < 128 ifTrue: [ i ] ifFalse: [ i - 256 ]!

javaAsShort
    | i |
    i := self bitAnd: 65535.
    ^i < 32768 ifTrue: [ i ] ifFalse: [ i - 65536 ]!

javaAsInt
    | i |
    i := (self at: 4) < 128
	ifTrue: [ LargePositiveInteger new: 4 ]
	ifFalse: [ LargeNegativeInteger new: 4 ].

    i at: 1 put: (self at: 1).
    i at: 2 put: (self at: 2).
    i at: 3 put: (self at: 3).
    i at: 4 put: (self at: 4).
    ^i!

javaAsLong
    | i |
    self size <= 8 ifTrue: [ ^self ].
    i := (self at: 8) < 128
	ifTrue: [ LargePositiveInteger new: 8 ]
	ifFalse: [ LargeNegativeInteger new: 8 ].

    i at: 1 put: (self at: 1).
    i at: 2 put: (self at: 2).
    i at: 3 put: (self at: 3).
    i at: 4 put: (self at: 4).
    i at: 5 put: (self at: 5).
    i at: 6 put: (self at: 6).
    i at: 7 put: (self at: 7).
    i at: 8 put: (self at: 8).
    ^i!

javaIushr: shift
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: 0 - shift)
    	bitAnd: (16rFFFF_FFFF bitShift: 0 - shift)!

javaLushr: shift
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: 0 - shift)
    	bitAnd: (16rFFFF_FFFF_FFFF_FFFF bitShift: 0 - shift)!

!SmallInteger methodsFor: 'java arithmetic'!

javaAsInt
    ^self!

javaAsLong
    ^self!

javaIushr: shift
    "Optimize the common case where we can avoid creating a
     LargeInteger."
    shift >= 2 ifTrue: [
        ^(self bitShift: 0 - shift)
    	    bitAnd: (16r3FFF_FFFF bitShift: 2 - shift) ].
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: -1) bitAnd: 16r7FFF_FFFF!

javaLushr: shift
    "Optimize the case where we can avoid creating a LargeInteger."
    shift >= 34 ifTrue: [
        ^(self bitShift: 0 - shift)
    	    bitAnd: (16r3FFF_FFFF bitShift: 34 - shift) ].
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: 0 - shift)
    	bitAnd: (16rFFFF_FFFF_FFFF_FFFF bitShift: 0 - shift)! !

!UndefinedObject methodsFor: 'JavaObject interoperability'!

checkCast: anObject
!

instanceOf: aClass
    ^0
! !

!Object class methodsFor: 'java arrays'!

javaNewArray: size
    <primitive: VMpr_Behavior_basicNewColon>
    size < 0 ifTrue: [
	^Java.gnu.smalltalk.JavaVM throw: Java.java.lang.NegativeArraySizeException ].
    self primitiveFailed!

!JavaType methodsFor: 'java arrays'!

javaMultiNewArray: sizes from: index
    | array size |
    (size := sizes at: index) < 0 ifTrue: [
	^JavaVM throw: Java.java.lang.NegativeArraySizeException ].

    array := self arrayClass new: size.
    index < sizes size ifTrue: [
	1 to: size do: [ :i |
	    array
		at: i
		put: (self subType javaMultiNewArray: sizes from: index + 1)]].
    ^array
! !
