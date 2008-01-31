"======================================================================
|
|   C lexical token classes.
|   Usable separately as well.
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

Object subclass: #CToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries:''
       category: 'Compiler'
!



CToken comment:
'My instances are returned from the lexer stream.  If you ask them (nicely,
mind you) they will report their kind (a symbol, such as #Identifier) and
their value (such as ''foobar'').' !


!CToken methodsFor: 'printing'!

printOn: aStream
    "not done yet"
    super printOn: aStream
!

storeOn: aStream
    aStream 
	nextPutAll: self class name;
	nextPutAll: ' new '.
! !



CToken subclass: #CValueToken
      instanceVariableNames: 'value'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Compiler'
!

!CValueToken class methodsFor: 'instance creation'!

value: aValue
    ^self new init: aValue
! !

!CValueToken methodsFor: 'accessing'!

value
    ^value
!

= differentToken
    ^value = differentToken value
!

hash
    ^value hash
!

valueString
    ^value			"most are strings"
!

evaluate
    ^value
! !


!CValueToken methodsFor: 'printing'!

storeOn: aStream
    aStream nextPut: $(;
	nextPutAll: self class name; nextPutAll: ' value: '; store: value;
	nextPut: $).
! !


!CValueToken methodsFor: 'private'!

init: aValue
    value _ aValue
!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '::'.
    value printOn: aStream
! !


    
CValueToken subclass: #COperatorToken
	    instanceVariableNames: ''
	    classVariableNames: ''
	    poolDictionaries: ''
	    category: nil
!

!COperatorToken methodsFor: 'accessing'!

isBinary
    ^true
!

isUnary
    ^true
! !

COperatorToken subclass: #CBinaryOperatorToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CBinaryOperatorToken methodsFor: 'accessing'!

isUnary
    ^false
! !

"unary only"
COperatorToken subclass: #CUnaryOperatorToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CUnaryOperatorToken methodsFor: 'accessing'!

isBinary
    ^false
! !

CValueToken subclass: #CIdentifierToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!
CValueToken subclass: #CStringoidToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!
CValueToken subclass: #CFloatToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!
CValueToken subclass: #CIntegerToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!


!CStringoidToken methodsFor: 'interpretation'!

quotedStringValue
    "Returns the value as a string, with an extra level of C style quotes
     (backslash) present"
    | result valueStream delim |
    result _ WriteStream on: (String new: 4).
    valueStream _ ReadStream on: (self value).
    delim _ self delimiterChar.
    result nextPut: $\.
    result nextPut: delim.
    valueStream do: 
	[ :ch | (ch == self delimiterChar ) | (ch == $\)
		    ifTrue: [ result nextPut: $\ ].
		result nextPut: ch ].
    result nextPut: $\.
    result nextPut: delim.
    
    ^result contents
!

delimiterChar
    ^self subclassResponsibility
! !



CStringoidToken subclass: #CStringToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CStringToken methodsFor: 'interpretation'!

delimiterChar
    ^$"
! !


CStringoidToken subclass: #CCharacterToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CCharacterToken methodsFor: 'interpretation'!

quotedStringValue
    "Returns the value as a string, with an extra level of C style quotes
     (backslash) present"
    | result valueStream delim |
    result _ WriteStream on: (String new: 4).
    valueStream _ ReadStream on: (self value).
    delim _ self delimiterChar.
    result nextPut: $'.
    valueStream do: 
	[ :ch | ch == $\ ifTrue: [ result nextPut: ch ].
		result nextPut: ch ].
    result nextPut: $'.
    
    ^result contents
!

delimiterChar
    ^$'
! !



!CIntegerToken methodsFor: 'accessing'!

valueString
    ^value printString
! !

!CFloatToken methodsFor: 'accessing'!

valueString
    ^value printString
! !


Object subclass: #CKeyword
       instanceVariableNames: 'value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CKeyword comment:
'I exist only to provide unique instances which correspond to C keywords.
.' !

!CKeyword class methodsFor: 'instance creation'!

value: aName
    ^self new init: aName
! !

!CKeyword methodsFor: 'accessing'!

value
    ^value
! !

!CKeyword methodsFor: 'private'!

init: aName
    value _ aName.
!

printOn: aStream
    aStream nextPutAll: 'Keyword:'.
    value printOn: aStream
! !



Namespace current at: #CKeywords put: Dictionary new!

CKeywords at: #AutoKey put: (CKeyword value: 'auto').
CKeywords at: #BreakKey put: (CKeyword value: 'break').
CKeywords at: #CaseKey put: (CKeyword value: 'case').
CKeywords at: #CharKey put: (CKeyword value: 'char').
CKeywords at: #ConstKey put: (CKeyword value: 'const').
CKeywords at: #ContinueKey put: (CKeyword value: 'continue').
CKeywords at: #DefaultKey put: (CKeyword value: 'default').
CKeywords at: #DoKey put: (CKeyword value: 'do').
CKeywords at: #DoubleKey put: (CKeyword value: 'double').
CKeywords at: #ElseKey put: (CKeyword value: 'else').
CKeywords at: #EnumKey put: (CKeyword value: 'enum').
CKeywords at: #ExternKey put: (CKeyword value: 'extern')!

CKeywords at: #FloatKey put: (CKeyword value: 'float').
CKeywords at: #ForKey put: (CKeyword value: 'for').
CKeywords at: #GotoKey put: (CKeyword value: 'goto').
CKeywords at: #IfKey put: (CKeyword value: 'if').
CKeywords at: #IntKey put: (CKeyword value: 'int').
CKeywords at: #LongKey put: (CKeyword value: 'long').
CKeywords at: #RegisterKey put: (CKeyword value: 'register').
CKeywords at: #ReturnKey put: (CKeyword value: 'return').
CKeywords at: #ShortKey put: (CKeyword value: 'short').
CKeywords at: #SignedKey put: (CKeyword value: 'signed').
CKeywords at: #SizeofKey put: (CKeyword value: 'sizeof').
CKeywords at: #StaticKey put: (CKeyword value: 'static').
CKeywords at: #StructKey put: (CKeyword value: 'struct').
CKeywords at: #SwitchKey put: (CKeyword value: 'switch').
CKeywords at: #TypedefKey put: (CKeyword value: 'typedef').
CKeywords at: #UnionKey put: (CKeyword value: 'union').
CKeywords at: #UnsignedKey put: (CKeyword value: 'unsigned').
CKeywords at: #VoidKey put: (CKeyword value: 'void').
CKeywords at: #VolatileKey put: (CKeyword value: 'volatile').
CKeywords at: #WhileKey put: (CKeyword value: 'while')!

Namespace current at: #CPPKeywords put: Dictionary new!

CPPKeywords at: #IfdefKey put: (CKeyword value: 'ifdef').
CPPKeywords at: #DefinedKey put: (CKeyword value: 'defined').
CPPKeywords at: #ElifKey put: (CKeyword value: 'elif').
CPPKeywords at: #EndifKey put: (CKeyword value: 'endif').
CPPKeywords at: #IfndefKey put: (CKeyword value: 'ifndef').

Namespace current at: #CToks put: Dictionary new!

CToks at: #DotTok put: (CValueToken value: '.').
CToks at: #ColonTok put: (CValueToken value: ':').
CToks at: #OpenParenTok put: (CValueToken value: '(').
CToks at: #CloseParenTok put: (CValueToken value: ')').
CToks at: #SemiTok put: (CValueToken value: ';').
CToks at: #QuestionTok put: (CValueToken value: '?').
CToks at: #OpenBracketTok put: (CValueToken value: '[').
CToks at: #CloseBracketTok put: (CValueToken value: ']').
CToks at: #OpenBraceTok put: (CValueToken value: '{').
CToks at: #CloseBraceTok put: (CValueToken value: '}').
CToks at: #DotDotDotTok put: (CValueToken value: '...')!

