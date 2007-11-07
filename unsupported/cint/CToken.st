"======================================================================
|
|   C lexical token classes.
|   Usable separately as well.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
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

"
|     Change Log
| ============================================================================
| Author       Date       Change 
|
"

Object subclass: #CToken
       instanceVariableNames: 'location'
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

| name value class |
#(  (#DotTok '.')
    (#ColonTok ':')
    (#OpenParenTok '(')
    (#CloseParenTok ')')
    (#SemiTok ';')
    (#QuestionTok '?')
    (#OpenBracketTok '[')
    (#CloseBracketTok ']')
    (#OpenBraceTok '{')
    (#CloseBraceTok '}')
    (#DotDotDotTok '...')
    (#WhitespaceTok ' ')
) do: [ :classNameValue | name _ classNameValue at: 1.
			  value _ classNameValue at: 2.
			  class _ CToken subclass: name
						   instanceVariableNames: ''
						   classVariableNames: 'value'
						   poolDictionaries: ''
						   category: 'Compiler'.
			  class class compile: '
value: aValue [
    value _ aValue
]'.

			  class  compile: '
value [
    ^value
]'.
			  class class compile: '
value [
    ^value
]'.
			  class  compile: '
valueString [
    ^value
]'.
			  class value: value
			  ]
!

#(  #IntegerTok
    #FloatTok
    #StringoidTok
    #CommentTok
    #IdentifierTok
) do: [ :className | CValueToken subclass: className
			   instanceVariableNames: ''
			   classVariableNames: ''
			   poolDictionaries: ''
			   category: 'Compiler' ]
!


!StringoidTok methodsFor: 'interpretation'!

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



StringoidTok subclass: #StringTok
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!StringTok methodsFor: 'interpretation'!

delimiterChar
    ^$"
! !


StringoidTok subclass: #CharLiteralTok
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CharLiteralTok methodsFor: 'interpretation'!

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



!IntegerTok methodsFor: 'accessing'!

valueString
    ^value printString
! !

!FloatTok methodsFor: 'accessing'!

valueString
    ^value printString
! !


Object subclass: #Keyword
       instanceVariableNames: 'value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

Keyword comment:
'I exist only to provide unique instances which correspond to C keywords.
.' !

!Keyword class methodsFor: 'instance creation'!

value: aName
    ^self new init: aName
! !

!Keyword methodsFor: 'accessing'!

value
    ^value
! !

!Keyword methodsFor: 'private'!

init: aName
    value _ aName.
!

printOn: aStream
    aStream nextPutAll: 'Keyword:'.
    value printOn: aStream
! !



Smalltalk at: #CKeywords put: Dictionary new!

CKeywords at: #AutoKey put: (Keyword value: 'auto').
CKeywords at: #BreakKey put: (Keyword value: 'break').
CKeywords at: #CaseKey put: (Keyword value: 'case').
CKeywords at: #CharKey put: (Keyword value: 'char').
CKeywords at: #ConstKey put: (Keyword value: 'const').
CKeywords at: #ContinueKey put: (Keyword value: 'continue').
CKeywords at: #DefaultKey put: (Keyword value: 'default').
CKeywords at: #DoKey put: (Keyword value: 'do').
CKeywords at: #DoubleKey put: (Keyword value: 'double').
CKeywords at: #ElseKey put: (Keyword value: 'else').
CKeywords at: #EnumKey put: (Keyword value: 'enum').
CKeywords at: #ExternKey put: (Keyword value: 'extern')!

CKeywords at: #FloatKey put: (Keyword value: 'float').
CKeywords at: #ForKey put: (Keyword value: 'for').
CKeywords at: #GotoKey put: (Keyword value: 'goto').
CKeywords at: #IfKey put: (Keyword value: 'if').
CKeywords at: #IntKey put: (Keyword value: 'int').
CKeywords at: #LongKey put: (Keyword value: 'long').
CKeywords at: #RegisterKey put: (Keyword value: 'register').
CKeywords at: #ReturnKey put: (Keyword value: 'return').
CKeywords at: #ShortKey put: (Keyword value: 'short').
CKeywords at: #SignedKey put: (Keyword value: 'signed').
CKeywords at: #SizeofKey put: (Keyword value: 'sizeof').
CKeywords at: #StaticKey put: (Keyword value: 'static').
CKeywords at: #StructKey put: (Keyword value: 'struct').
CKeywords at: #SwitchKey put: (Keyword value: 'switch').
CKeywords at: #TypedefKey put: (Keyword value: 'typedef').
CKeywords at: #UnionKey put: (Keyword value: 'union').
CKeywords at: #UnsignedKey put: (Keyword value: 'unsigned').
CKeywords at: #VoidKey put: (Keyword value: 'void').
CKeywords at: #VolatileKey put: (Keyword value: 'volatile').
CKeywords at: #WhileKey put: (Keyword value: 'while')!


CKeywords at: #IfdefKey put: (Keyword value: 'ifdef').
CKeywords at: #DefinedKey put: (Keyword value: 'defined').
CKeywords at: #ElifKey put: (Keyword value: 'elif').
CKeywords at: #EndifKey put: (Keyword value: 'endif').
CKeywords at: #IfndefKey put: (Keyword value: 'ifndef').
!

