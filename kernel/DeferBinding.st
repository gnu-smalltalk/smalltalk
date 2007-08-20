"======================================================================
|
|   DeferredVariableBinding Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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


LookupKey subclass: #DeferredVariableBinding
	  instanceVariableNames: 'class defaultDictionary association'
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Language-Data types'
!

DeferredVariableBinding comment: 
'I represent a binding to a variable that is not tied to a particular
dictionary until the first access.  Then, lookup rules for global variables
in the scope of a given class are used.'!



!DeferredVariableBinding class methodsFor: 'basic'!

key: aSymbol class: aClass defaultDictionary: aDictionary
    ^(self key: aSymbol)
        class: aClass;
        defaultDictionary: aDictionary;
	yourself! !

!DeferredVariableBinding methodsFor: 'basic'!

value
    "Answer a new instance of the receiver with the given key and value"
    association isNil ifTrue: [ association := self resolveBinding ].
    ^association value
!

value: anObject
    "Answer a new instance of the receiver with the given key and value"
    association isNil ifTrue: [ association := self resolveBinding ].
    association value: anObject
! !



!DeferredVariableBinding methodsFor: 'private'!

class: aClass
    class := aClass!

defaultDictionary: aDictionary
    defaultDictionary := aDictionary!

resolveBinding
    "Look for a pool dictionary of class that includes the key.  If not found,
     add the variable to the defaultDictionary.  If already bound, reuse the
     bound that was found on the previous lookup."

    | assoc |

    "See if a previous access has created the binding."
    assoc := defaultDictionary associationAt: self key ifAbsent: [ nil ].
    assoc isNil ifFalse: [ ^assoc ].

    "Look for the binding in the class environment."
    class withAllSuperclassesDo: [ :env || pools |
        assoc := env environment associationAt: self key ifAbsent: [ nil ].
        assoc isNil ifFalse: [ ^assoc ].

	pools := env sharedPoolDictionaries.
	pools isNil ifFalse: [
	    pools do: [ :each |
	        assoc := each associationAt: self key ifAbsent: [ nil ].
	        assoc isNil ifFalse: [ ^assoc ] ] ] ].

    "Create it as a temporary."
    defaultDictionary at: self key ifAbsentPut: [ nil ].
    ^defaultDictionary associationAt: self key
! !




!DeferredVariableBinding methodsFor: 'storing'!

storeOn: aStream
    "Put on aStream some Smalltalk code compiling to the receiver"
    aStream nextPut: $#.
    aStream nextPut: ${.
    aStream nextPutAll: self key.
    aStream nextPut: $}
! !
