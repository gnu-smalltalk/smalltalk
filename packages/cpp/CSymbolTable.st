"======================================================================
|
|   C symbol table implementation, part of the C header parser.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"need to have an instance which is the symbol table.

need push scope, pop scope.

need symbol, with symbol kind (variable, function, type).

need separate struct/union tag space
need separate enum tag space

need lookup by name, and some kind of typeof operation

??? Should this be the keeper of whether its a variable or not?


"

Object subclass: #CSymbolScope
       instanceVariableNames: 'symbols structTags enumTags'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CSymbolScope class methodsFor: 'instance creation'!

new
    ^super new init
! !


!CSymbolScope methodsFor: 'accessing'!

at: aName
    | definition | 
    ^symbols at: aName ifAbsent: [ nil ].
!


at: aName put: aDefinition
    ^symbols at: aName put: aDefinition
!

atStruct: aName
    ^structTags at: aName ifAbsent: [ nil ].
!

atStruct: aName put: aDefinition
    ^structTags at: aName put: aDefinition
!

atEnum: aName
    ^enumTags at: aName ifAbsent: [ nil ].
!

atEnum: aName put: aDefinition
    ^enumTags at: aName put: aDefinition
! !


!CSymbolScope methodsFor: 'private'!

init
    symbols _ Dictionary new.
    structTags _ Dictionary new.
    enumTags _ Dictionary new.
! !




Object subclass: #CSymbolTable
       instanceVariableNames: 'scopeStack'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CSymbolTable class methodsFor: 'instance creation'!

new
    ^super new init
! !


!CSymbolTable methodsFor: 'scope control'!

saveScope
    ^scopeStack addFirst: CSymbolScope new
!

restoreScope
    ^scopeStack removeFirst.
! !

"!!! to be correct, there should be a scope type object which holds
 the symbols, etc, so lookup just tries looking up in each scope
 in the stack.  However, I am lazy."

!CSymbolTable methodsFor: 'accessing'!

at: aName
    | definition | 
    scopeStack do: 
	[ :scope | definition _ scope at: aName.
		   definition notNil ifTrue: [ ^definition ]. ].
    "!!! issue an error message?"
    ^nil
!

at: aName put: aDefinition
    ^scopeStack first at: aName put: aDefinition
!

atStruct: aName
    | definition |
    scopeStack do: 
	[ :scope | definition _ scope atStruct: aName.
		   definition notNil ifTrue: [ ^definition ]. ].
    "!!! issue an error message?"
    ^nil
!

atStruct: aName put: aDefinition
    ^scopeStack first atStruct: aName put: aDefinition
!

atEnum: aName
    | definition |
    scopeStack do: 
	[ :scope | definition _ scope atEnum: aName.
		   definition notNil ifTrue: [ ^definition ]. ].
    "!!! issue an error message?"
    ^nil
!

atEnum: aName put: aDefinition
    ^scopeStack first atEnum: aName put: aDefinition
! !


!CSymbolTable methodsFor: 'private'!

init
    scopeStack _ OrderedCollection new.
    scopeStack add: CSymbolScope new. 
! !

