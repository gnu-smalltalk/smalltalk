"======================================================================
|
|   C lexical analyzer, part of the C header parser.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

"
|     Change Log
| ============================================================================
| Author       Date       Change 
|
"

"C Token parser"

FileStream fileIn: 'CToken.st' ifMissing: #CToken !

Object subclass: #CTok
       instanceVariableNames: 'stream tokenBuffer'
       classVariableNames: 'LexMethods LexExtra ReservedIds COperatorDict'
       poolDictionaries: 'CKeywords'
       category: ''
!

!CTok class methodsFor: 'initialization'!

initialize
    LexMethods _ Array new: 128.
    LexExtra _ Array new: 128.
    LexMethods atAllPut: #ignoreTok:.
    LexMethods at: (Character tab asciiValue) put: #whiteTok:.
    LexMethods at: (Character nl asciiValue) put: #whiteTok:.
    LexMethods at: (Character newPage asciiValue) put: #whiteTok:.
    LexMethods at: (Character cr asciiValue) put: #whiteTok:.
    #(
      ($  $  #whiteTok:)
	  ($! $! #opTok:)
    	  ($" $" #stringTok:)
	  ($# $# #opTok:)
    	  ($' $' #charLitTok:)
    	  ($% $& #opTok:)
    	  ($( $( #oneCharTok: OpenParen)
    	  ($) $) #oneCharTok: CloseParen)
    	  ($* $- #opTok:)
    	  ($. $. #floatTok:)
    	  ($/ $/ #opTok:)
    	  ($0 $9 #numberTok:)
	  ($: $: #oneCharTok: #Colon) "may make this an operator"
    	  ($; $; #oneCharTok: #Semi)
	  ($< $> #opTok:)
	  ($? $? #oneCharTok: #Question) "may make this an operator"
	  "@ is illegal"
	  ($A $Z #idTok:)
    	  ($[ $[ #oneCharTok: #OpenBracket)
	  ($\ $\ #quoteTok:)
    	  ($] $] #oneCharTok: #CloseBracket)
    	  ($^ $^ #opTok: )
    	  ($_ $_ #idTok:)
	  ($a $z #idTok:)
	  (${ ${ #oneCharTok: #OpenBrace)
	  ($| $| #opTok:)
	  ($} $} #oneCharTok: #CloseBrace)
	  ($~ $~ #opTok:)
	  )
	do: [ :range | self initRange: range ].
    self initKeywords.

    self initCOperators.
!

initKeywords
    ReservedIds _ Dictionary new.
    self initKeywords1.
    self initKeywords2.
    self initPreprocessorKeywords
!

initKeywords1
    ReservedIds at: 'auto' put: AutoKey.
    ReservedIds at: 'break' put: BreakKey.
    ReservedIds at: 'case' put: CaseKey.
    ReservedIds at: 'char' put: CharKey.
    ReservedIds at: 'const' put: ConstKey.
    ReservedIds at: 'continue' put: ContinueKey.
    ReservedIds at: 'default' put: DefaultKey.
    ReservedIds at: 'do' put: DoKey.
    ReservedIds at: 'double' put: DoubleKey.
    ReservedIds at: 'else' put: ElseKey.
    ReservedIds at: 'enum' put: EnumKey.
    ReservedIds at: 'extern' put: ExternKey.
    ReservedIds at: 'float' put: FloatKey.
    ReservedIds at: 'for' put: ForKey.
    ReservedIds at: 'goto' put: GotoKey.
    ReservedIds at: 'if' put: IfKey.
    ReservedIds at: 'int' put: IntKey.
!

initKeywords2
    ReservedIds at: 'long' put: LongKey.
    ReservedIds at: 'register' put: RegisterKey.
    ReservedIds at: 'return' put: ReturnKey.
    ReservedIds at: 'short' put: ShortKey.
    ReservedIds at: 'signed' put: SignedKey.
    ReservedIds at: 'sizeof' put: SizeofKey.
    ReservedIds at: 'static' put: StaticKey.
    ReservedIds at: 'struct' put: StructKey.
    ReservedIds at: 'switch' put: SwitchKey.
    ReservedIds at: 'typedef' put: TypedefKey.
    ReservedIds at: 'union' put: UnionKey.
    ReservedIds at: 'unsigned' put: UnsignedKey.
    ReservedIds at: 'void' put: VoidKey.
    ReservedIds at: 'volatile' put: VolatileKey.
    ReservedIds at: 'while' put: WhileKey.
!

initPreprocessorKeywords
    ReservedIds at: 'ifdef' put: IfdefKey.
    ReservedIds at: 'defined' put: DefinedKey.
    ReservedIds at: 'elif' put: ElifKey.
    ReservedIds at: 'endif' put: EndifKey.
    ReservedIds at: 'ifndef' put: IfndefKey.

!

initCOperators
    COperatorDict _ Dictionary new.

    #(
	  '+'
	  '-'
	  '*'
	  '&'
	  '#' 
	  '\' "only passes through tokenizer as a macro argument"
      ) do: [ :op | COperatorDict at: op put: COperatorToken ].

    #('~'
	  '!'
	  '++'
	  '--'
      ) do: [ :op | COperatorDict at: op put: CUnaryOperatorToken ].
    #(
      '.'
	  '->'
	  '/'
	  '%'
	  '^'
	  ','
	  '|'
	  '||'
	  '&&'
	  '>'
	  '<'
	  '>>'
	  '<<'
	  '>='
	  '<='
	  '=='
	  '!='
	  '='
	  '##'
      ) do: [ :op | COperatorDict at: op put: CBinaryOperatorToken ].
!

initRange: aRange
    | method |
    method _ aRange at: 3.
    (aRange at: 1) asciiValue to: (aRange at: 2) asciiValue do:
	[ :ch | LexMethods at: ch put: method.
    	    	aRange size = 4 ifTrue: 
		    [ LexExtra at: ch put: (aRange at: 4) ]
		]
! !


!CTok class methodsFor: 'instance creation'!

on: fileName
    ^self new init: fileName
! !

!CTok methodsFor: 'hacking'!

next
    | ch tok |
    tokenBuffer notNil
	ifTrue: [ tok _ tokenBuffer.
		  tokenBuffer _ nil.
		  ^tok ].
	
    [ stream atEnd ifTrue: [ ^nil ].
      ch _ stream next.
      tok _ self perform: (LexMethods at: ch asciiValue) with: ch.
      tok isNil ] whileTrue: [ ].
    ^tok
!

peek
    tokenBuffer isNil
	ifTrue: [ tokenBuffer _ self next ].
    ^tokenBuffer
!

atEnd
    ^stream atEnd
!

close
    stream close
! !

!CTok methodsFor: 'token parsing'!

whiteTok: aChar
    "Gobble the char and return nothing"
    ^nil
!

charLitTok: aChar
    "Called with aChar == '"
    | ch value |
    ch _ stream next.
    ch == $\
	ifTrue: [ value _ self parseEscapedChar ]
	ifFalse: [ value _ ch ].
    ^CharLiteralTok value: value
!			     

idTok: aChar
    stream putBack: aChar.
    ^self parseIdent
!

stringTok: aChar
    | bs ch |    
    bs _ WriteStream on: (String new: 10).
    [ ch _ stream next.
      ch ~= $" ]
	whileTrue: [ ch == $\ ifTrue: [ ch _ self parseEscapedChar ]. 
		     bs nextPut: ch ].
    ^StringTok value: bs contents 
!

oneCharTok: aChar
    ^(Smalltalk at: ((LexExtra at: (aChar asciiValue)), 'Tok') asSymbol)
	new
!

floatTok: aChar
    "got '.', either have a floating point number, or a structure member"
    | ch | 
    ch _ stream peek.
    (self isDigit: ch base: 10) 
	ifTrue: [ "### revisit this "
		  ^FloatTok value: (self parseFrac: 0.0) ]
	ifFalse: [ ^DotTok ]
!

"
unary operators
& ~ ! * - + ++ -- 

pure unary operators
~ ! ++ -- 

doubled operators
+-<>|&#=

binary operators 
-> . % ^ , + - * / & | == != >> << > < <= >= = 


assignment ops
*/%+->><<&^|
"


opTok: aChar
    | bs ch cont opStr |
    bs _ WriteStream on: (String new: 2).
    ch _ stream peek.
    bs nextPut: aChar.

    (self isDoublable: aChar)
	ifTrue: [ ch == aChar
		      ifTrue: [ stream next. "gobble the second char"
				bs nextPut: aChar ] ] 
	ifFalse: [ self handleTwoCharCases: bs firstChar: aChar secondChar: ch ].

    "should be allowed to peek more than once, shouldn't I?"
    ch _ stream peek.
    opStr _ bs contents.
    ch == $=
	ifTrue: [ (self isAssignable: opStr) 
		      ifTrue: [ "gobble assignment operator"
				bs nextPut: stream next.
				opStr _ bs contents ].
		  ].
    
    "now look up the operator and return "
    ^(COperatorDict at: bs contents) value: opStr.
!

isDoublable: aChar
    ^'+-<>|&#=' includes: aChar
!

handleTwoCharCases: bs firstChar: aChar secondChar: ch 
    (aChar == $- and: [ ch == $> ]) ifTrue: [ ^bs nextPut: stream next ].
    (aChar == $> and: [ ch == $= ]) ifTrue: [ ^bs nextPut: stream next ].
    (aChar == $< and: [ ch == $= ]) ifTrue: [ ^bs nextPut: stream next ].
    (aChar == $! and: [ ch == $= ]) ifTrue: [ ^bs nextPut: stream next ].
!

isAssignable: opStr
    ^#('*' '/' '+' '-' '>>' '<<' '&' '^' '|' '%') includes: opStr
!

numberTok: aChar
    | mantissaParsed isNegative dotSeen base exponent scale ch num 
      floatExponent |
    mantissaParsed _ isNegative _ dotSeen _ false.
    
    "note: no sign handling here"

    "integers are:
	  <digits>
	  0<octal_digits>
	  0x<hex_digits either case>
	  0X<hex_digits either case>
	  <whatever>[uUlL]
	  <whatever>[uUlL][uUlL]"
    "float are:
	  <mant_digits>.<frac_digits>e<sign><exponent><suffix>
	  mant_digits or frac_digits can be missing, but not both.
	  '.' or 'e' can be missing, but not both.
	  suffix is either empty or [lLfF]"
	  

    "first char:
       if 0, is next char x or X?
	    if so, parse remainder as hex integer and return
	    else parse remainder as octal integer and return
       assume integer.  parse some digits
       stopped at e or E?
	   if so, parse exponent and possible suffix and return
       stopped at .?
	   if so, know its a float. do the parseFrac thing as above

	   parseFrac: needs the accumulated decimal value
	      starts at char after .
	      parses digits
	      stopped at e or E?
		  if so, parse exponent and return
	      stopped at lLFf?
		  discard it, compute value and return

	   parseExponent mant_part, frac_part
	      start after e
		  is char -?
		     accumulate sign and keep going
		  parse decimal digits
		  stopped at lLfF?
		     discard it, compute value and return
	    "
		
	 
    ch _ aChar.
    stream putBack: ch.
    ch == $0 
	ifTrue: 
	     [ stream next. "gobble char"
	       ch _ stream peek.
	       (ch == $x) | (ch == $X)
		   ifTrue: [ stream next.
			     ^self parseHexConstant ].
	       (self isDigit: ch base: 8)
		   ifTrue: [ ^self parseOctalConstant ].
	       "restore the flow"
	       stream putBack: aChar ].
    
    
    
    num _ self parseDigits: ch base: 10.
    ch _ stream peek.
    ch == $.
	ifTrue: [ stream next. "gobble '.'"
		  ^FloatTok value: (self parseFrac: num) ].
		  
    (ch == $e) | (ch == $E)
	ifTrue: [ stream next. "gobble 'e'"
		  ^FloatTok value: (self parseExponent: num) ].
					 
    "must have been an integer"
	     
    self gobbleIntegerSuffix.


    ^IntegerTok value: num truncated.
! !

!CTok methodsFor: 'utility methods'!

parseEscapedChar
    "called right after \ in a string or a character literal"
    | ch num count | 
    ch _ stream next.
    ch == $b ifTrue: [ ^Character value: 8 ].
    ch == $n ifTrue: [ ^Character value: 10 ].
    ch == $r ifTrue: [ ^Character value: 13 ].
    ch == $f ifTrue: [ ^Character value: 12 ].
    ch == $t ifTrue: [ ^Character value: 9 ].
    ch == $v ifTrue: [ ^Character value: 11 ].
    " this should probably go away "
    ch == (Character nl) ifTrue: [ ch _ stream next.
				   ch == $\
				       ifTrue: [ ^self parseEscapedChar ]
				       ifFalse: [ ^ch ]
				   ].
    ch == $\ ifTrue: [ ^$\ ].
    ch == $' ifTrue: [ ^$' ].
    ch == $" ifTrue: [ ^$" ].
    ch == $x ifTrue: [ "have \xhhh"
		       ch _ stream next.
		       num _ 0.	
		       count _ 0.
		       [ (self isDigit: ch base: 16) and:
			     [ count < 3 ] 
			   ] whileTrue:
			   [ num _ num * 16 + ch digitValue.
			     stream next. 
			     ch _ stream peek.
			     count _ count + 1
			     ].
		       ^Character value: num ].
    (self isDigit: ch base: 8)
	ifTrue: [ "have \ooo"
		  num _ 0.	
		  count _ 0.
		  [ (self isDigit: ch base: 8) and:
			[ count < 3 ] 
			] whileTrue:
			    [ num _ num * 8 + ch digitValue.
			      stream next. 
			      ch _ stream peek.
			      count _ count + 1 ].
		  ^Character value: num ].
    self error: 'Illegal quoted character'
!
    

parseComment
    "Scanner is at /*<> ... "
    | bs ch |
    bs _ WriteStream on: (String new: 10).
    bs nextPutAll: '/*'.	"preload"
    [ ch _ stream next.
      ch == $* 
	  ifTrue: [ stream peek == $/ 
			ifTrue: [ stream next. false ]
			ifFalse: [ true ] ]
	  ifFalse: [ true ] ]
	whileTrue: [ bs nextPut: ch ].
    "^CommentTok value: bs contents"
    ^nil "ignore comments for now "
!

isSpecial: ch
    ^'%&*+,-/<=>?@\|~' includes: ch
! 

parseHexConstant
    "scanner at 0x<>..."
    | num ch |
    ch _ stream peek.
    num _ self parseDigits: ch base: 16.
    self gobbleIntegerSuffix.
    ^IntegerTok value: num truncated.
!


parseOctalConstant
    "scanner at 0<>..."
    | num ch |
    ch _ stream peek.
    num _ self parseDigits: ch base: 8.
    self gobbleIntegerSuffix.
    ^IntegerTok value: num truncated.
!

gobbleIntegerSuffix
    | ch |
    "scanner at <digits><>...  may be [luLU][luLU]"
    ch _ stream peek.
    (ch == $l) | (ch == $L) | (ch == $U) | (ch == $u)
	ifTrue: [ stream next.  "ignore it"
    
		  ch _ stream peek.
		  (ch == $l) | (ch == $L) | (ch == $U) | (ch == $u)
		      ifTrue: [ stream next.  "ignore it" ].
		  ].
    
!


parseFrac: aNumber
    "Scanner at ';;;;.<>;;;'"
    | ch scale num |

    num _ aNumber.
    scale _ 1.0.
    [ ch _ stream peek. self isDigit: ch base: 10 ] whileTrue:
	[ num _ num * 10.0 + ch digitValue.
	  stream next. 
	  scale _ scale / 10.0 .
	  ].

    num _ num * scale.

    (ch == $e) | (ch == $E)
	ifTrue: 
	    [ stream next.	"gobble the 'e' "
	      num _ self parseExponent: num ]
	ifFalse: 
	    [ self gobbleFloatSuffix ].
    ^num
!

parseExponent: aNumber
    "scanner at ....e<>..."
    | ch isNegative exponent | 
    
    ch _ stream peek.
    ch == $-
	ifTrue: [ stream next.	"gobble it"
		  isNegative _ true. ]
	ifFalse: [ isNegative _ false. ].
    
    exponent _ self parseDigits: ch base: 10.
    self gobbleFloatSuffix.
    ^aNumber raisedToInteger: (exponent truncated)
!

gobbleFloatSuffix
    | ch |
    ch _ stream peek.
    (ch == $f) | (ch == $F) | (ch == $l) | (ch == $L)
	ifTrue: [ stream next. ]
! 

parseDigits: ch base: base
    | c num |
    "assumes ch is peeked"
    c _ ch.
    num _ 0.0.			"accumulate FP in case we're really getting FP"
    [ self isDigit: c base: base ] whileTrue:
	[ num _ num * base + c digitValue.
	  stream next. 
	  c _ stream peek ].
    ^num
!


isDigit: aChar base: base
    ^((aChar between: $0 and: $9)
	| (aChar between: $A and: $f) 
	| (aChar between: $a and: $f) )
	and: [ aChar digitValue < base ]
!

resetRecording
    stream resetRecording
!

recording
    ^stream recording
!

close				"probably a better name exists for this"
    stream close

! !


!CTok methodsFor: 'private'!

init: aFileName
    stream _ PushBackStream on: (FileStream open: aFileName mode: 'r')
!

parseIdent
    | s ch id reservedId |
    s _ WriteStream on: (String new: 1).
    [ ch _ stream peek.
      ch isLetter or: [ ch isDigit or: [ ch == $_ ] ] ]
	whileTrue: [ s nextPut: ch.
		     stream next ].
    id _ s contents.
    "can check here once we have id for it being a macro.  Ifso, we 
     push the macro (substituted) onto the stream stack, and return
     nil.  Note that pushing a value onto the stream stack implies
     that any pushed back values are also pushed onto the stream stack."
    (self isMacro: id)
	ifTrue: [ self expandMacro: id.  ^nil ].
    reservedId _ self isReserved: id.
    reservedId notNil
	ifTrue: [ ^reservedId ]
	ifFalse: [ ^IdentifierTok value: id ]
! 

isReserved: aString
    ^ReservedIds at: aString ifAbsent: [ nil ]
!

isMacro: aString
    "for now"
    ^false
!

expandMacro: aString
    self notYetImplemented 
! !

CTok initialize!

"


| f tok |
    f _ CTok on: 'x.c'.
    [ tok _ f next.
      tok notNil ] whileTrue: [ tok inspect ]
!

"

