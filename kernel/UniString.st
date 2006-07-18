"======================================================================
|
|   UnicodeString Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
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


CharacterArray variable: #utf32 subclass: #UnicodeString
		  instanceVariableNames: ''
		  classVariableNames: ''
		  poolDictionaries: ''
		  category: 'Language-Data types'
!

UnicodeString comment: 
'My instances represent Unicode string data types.  Data is stored
as 4-byte UTF-32 characters' !


!UnicodeString methodsFor: 'converting'!

asString
    "Returns the string corresponding to the receiver.  Without the
     Iconv package, unrecognized Unicode characters become $?
     characters.  When it is loaded, an appropriate single- or
     multi-byte encoding could be used."
    | s each |
    s := String new: self size.
    1 to: self size do: [ :i |
	each := self basicAt: i.
	s at: i put: ((each value between: 0 and: 127)
			ifTrue: [ each asCharacter ]
			ifFalse: [ $? ]) ].
    ^s
!

asSymbol
    "Returns the symbol corresponding to the receiver"
    ^self asString asSymbol
!

asUnicodeString
    "But I already am a UnicodeString!  Really!"
    ^self
! !

!UnicodeString methodsFor: 'converting'!

displayOn: aStream
    "Print a representation of the receiver on aStream"
    self do: [ :char | char displayOn: aStream ].
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPut: $'.
    self do: [ :char | char == $' ifTrue: [ aStream nextPut: char ].
                  char displayOn: aStream ].
    aStream nextPut: $'
! !

!UnicodeString methodsFor: 'multibyte encodings'!

numberOfCharacters
    "Answer the number of Unicode characters in the receiver.  This is
     the same as #size for UnicodeString."
    ^self size! !

