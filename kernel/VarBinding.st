"======================================================================
|
|   VariableBinding Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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


HomedAssociation subclass: #VariableBinding
	  instanceVariableNames: ''
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Language-Data types'
!

VariableBinding comment: 
'My instances represent a mapping between a key in a namespace and
its value.  I print different than a normal Association, and know
about my parent namespace, otherwise my behavior is the same.'!
	      


!VariableBinding methodsFor: 'testing'!

isDefined
    "Answer true if this VariableBinding lives outside the
     Undeclared dictionary"
    ^self environment ~~ Undeclared
! !



!VariableBinding methodsFor: 'printing'!

path
    "Print a dotted path that compiles to the receiver's value"
    ^self environment storeString, '.', self key
!

printOn: aStream
    "Put on aStream a representation of the receiver"

    aStream
	nextPut: ${;
        nextPutAll: self environment name;
        nextPut: $.;
        nextPutAll: self key;
        nextPut: $}
! !



!VariableBinding methodsFor: 'storing'!

isLiteralObject
    "Answer whether the receiver is expressible as a Smalltalk literal."
    ^true
!

storeLiteralOn: aStream
    "Store on aStream some Smalltalk code which compiles to the receiver"
    self storeOn: aStream
!

storeOn: aStream
    "Put on aStream some Smalltalk code compiling to the receiver"

    aStream
	nextPutAll: '#{';
        nextPutAll: (self environment nameIn: Smalltalk);
        nextPut: $.;
        nextPutAll: self key;
        nextPut: $}.
! !



!VariableBinding methodsFor: 'saving and loading'!

binaryRepresentationObject
    "This method is implemented to allow for a PluggableProxy to be used
     with VariableBindings.  Answer a DirectedMessage which sends #at:
     to the environment that holds the receiver."
    ^DirectedMessage
        selector: #at:
        arguments: (Array with: self key)
        receiver: self environment
! !

