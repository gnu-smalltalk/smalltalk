"======================================================================
|
|   Maps a line stream into a series of C (and C preprocessor) tokens
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


StreamWrapper subclass: #LineTokenStream
       instanceVariableNames: 'lineStream lookahead '
       classVariableNames: 'LexMethods LexExtra ReservedIds COperatorDict'
       poolDictionaries: 'CKeywords CToks'
       category: nil
!

LineTokenStream comment:
'I expect to read from a Stream of lines, and tokenize the characters that I 
find there.  I yield individual tokens via my #next method or, via #nextLine,
collections of tokens which correspond to those input lines' !


!LineTokenStream class methodsFor: 'initialization'!

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
    	  ($( $( #oneCharTok: #OpenParen)
    	  ($) $) #oneCharTok: #CloseParen)
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
    "ReservedIds at: 'defined' put: DefinedKey."
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
	  "The assignment guys are also binary operators"
	  '*='
	  '/='
	  '+='
	  '-='
	  '>>='
	  '<<='
	  '&='
	  '^='
	  '|='
	  '%='
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


!LineTokenStream class methodsFor: 'instance creation'!

on: aString
    ^self onStream: (ReadStream on: aString) lines
!

onStream: aStream
    ^self new setStream: aStream lines
! !



!LineTokenStream methodsFor: 'basic'!

nextLine
    | tok result |
    result _ (Array new: 5) writeStream.

    "cases:
     we start on a line boundary (we guarantee that to ourselves)
     1) empty line
     2) only blanks on the line
     3) mixed stuff on the line

     nextToken yields white-uncompressed stream of tokens.
     
     on empty line, we yield an empty collection
     on line with blanks, we yield a collection containing a single white tok
     we compress out other white tokens into a single white token
     "

    lookahead notNil
	ifTrue: [ result nextPut: lookahead. lookahead := nil ].

    "collect and return a line of tokens"
    [ lineStream atEnd ]
	whileFalse: [
	   tok := self nextToken.
	   tok isNil ifFalse: [ result nextPut: tok ] ].

    ^result contents
!

next
    | result |
    lookahead isNil ifTrue: [ self peek ].
    result := lookahead.
    lookahead := nil.
    ^result
!

atEnd
    ^self peek isNil
!

peek
    [ lookahead isNil ] whileTrue: [
      lineStream atEnd ifTrue: [
          stream atEnd ifTrue: [ ^nil ].
	  self advanceLine ].

      lookahead _ self nextToken.
    ].
    ^lookahead
! !


!LineTokenStream methodsFor: 'token parsing'!

peekChar
    | ch |
    [
	lineStream atEnd ifTrue: [ ^Character nl ].
	ch := lineStream next.
	ch = $\ and: [ lineStream atEnd ] ]
	    whileTrue: [ self advanceLine ].
    lineStream putBack: ch.
    ^ch
!

nextChar
    | ch |
    [
	lineStream atEnd ifTrue: [ self advanceLine. ^Character nl ].
	ch := lineStream next.
	ch = $\ and: [ lineStream atEnd ] ]
	    whileTrue: [ self advanceLine ].
    ^ch
!

advanceLine
    lineStream _ PushBackStream on: (ReadStream on: stream next).
!

nextToken
    | ch |
    ch _ self nextChar.
    ^self perform: (LexMethods at: ch asciiValue) with: ch.
!

ignoreTok: aChar
    '[[[ IGNORING ]]]' printNl.
    aChar printNl.
    lineStream printNl.
    lineStream do: [ :ch | ch printNl ].
    stream next printNl.
    ^CCharacterToken value: '3'
!

whiteTok: aChar
    ^nil
!

charLitTok: aChar
    "Called with aChar == '"
    | ch value |
    value _ self parseStringoid: $'.
    ^CCharacterToken value: value.
!			     

idTok: aChar
    lineStream putBack: aChar.
    ^self parseIdent
!

stringTok: aChar
    | value |
    value _ self parseStringoid: $".
    ^CStringToken value: value

!

parseStringoid: delimitingChar
    | bs ch quoted |

    bs := WriteStream on: (String new: 10).
    [ ch := self nextChar.
      ch = delimitingChar ] whileFalse: [
      
      bs nextPut: ch.
      ch == $\ ifTrue: [
	  ch := self peekChar.
	  ch isNil ifFalse: [
	      self nextChar. "gobble the quoted guy"
	      bs nextPut: ch
	  ]
      ]
    ].
    ^bs contents 
!

oneCharTok: aChar
    ^CToks at: ((LexExtra at: (aChar asciiValue)), 'Tok') asSymbol
!

floatTok: aChar
    "got '.', either have a floating point number, or a structure member"
    | ch | 
    ch _ self peekChar.
    (self isDigit: ch base: 10) 
	ifTrue: [ "### revisit this "
		  ^CFloatToken value: (self parseFrac: 0.0) ].
    ch == $.			"seen .., could be ...?"
	ifFalse: [ ^DotTok ].
    self nextChar.		"eat it"
    ch _ self peekChar.
    ch == $.			"do we have '...'?"
	ifTrue: [ ^DotDotDotTok ].
	
    "nope, false alarm.  put things back the way they were."
    lineStream putBack: ch.
    lineStream putBack: $. .

    ^DotTok
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
    ch _ self peekChar.

    (aChar == $/ and: [ ch == $* ])
	ifTrue: [ ^self parseComment ].

    bs _ WriteStream on: (String new: 2).
    bs nextPut: aChar.
    self handleNormalOperators: bs firstChar: aChar secondChar: ch.
    "should be allowed to peek more than once, shouldn't I?"
    ch _ self peekChar.
    opStr _ bs contents.
    ch == $=
	ifTrue: [ (self isAssignable: opStr) 
		      ifTrue: [ "gobble assignment operator"
				bs nextPut: self nextChar.
				opStr _ bs contents ].
		  ].
    
    "now look up the operator and return "
   COperatorDict at: bs contents
		 ifAbsent: [ 'could not find' print. bs contents printNl ].
    ^(COperatorDict at: bs contents) value: opStr.
!


handleNormalOperators: bs firstChar: aChar secondChar: ch
    (self isDoublable: aChar)
	ifTrue: [ ch == aChar
		      ifTrue: [ self nextChar.
				^bs nextPut: aChar ] ].
    self handleTwoCharCases: bs firstChar: aChar secondChar: ch. 
!


isDoublable: aChar
    ^'+-<>|&#=' includes: aChar
!

handleTwoCharCases: bs firstChar: aChar secondChar: ch 
    (aChar == $- and: [ ch == $> ]) ifTrue: [ ^bs nextPut: self nextChar ].
    (aChar == $> and: [ ch == $= ]) ifTrue: [ ^bs nextPut: self nextChar ].
    (aChar == $< and: [ ch == $= ]) ifTrue: [ ^bs nextPut: self nextChar ].
    (aChar == $! and: [ ch == $= ]) ifTrue: [ ^bs nextPut: self nextChar ].
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
    lineStream putBack: ch.
    ch == $0 
	ifTrue: 
	     [ self nextChar. "gobble char"
	       lineStream atEnd
		   ifTrue: [ ^CIntegerToken value: 0 ].

	       ch _ self peekChar.
	       (ch == $x) | (ch == $X)
		   ifTrue: [ self nextChar.
			     ^self parseHexConstant ].
	       (self isDigit: ch base: 8)
		   ifTrue: [ ^self parseOctalConstant ].
	       "restore the flow"
	       ch _ aChar.
	       lineStream putBack: aChar ].
    
    
    
    num _ self parseDigits: ch base: 10.
    ch _ self peekChar.
    ch == $.
	ifTrue: [ self nextChar. "gobble '.'"
		  ^CFloatToken value: (self parseFrac: num) ].
		  
    (ch == $e) | (ch == $E)
	ifTrue: [ self nextChar. "gobble 'e'"
		  ^CFloatToken value: (self parseExponent: num) ].
					 
    "must have been an integer"
	     
    self gobbleIntegerSuffix.


    ^CIntegerToken value: num truncated.
! !




!LineTokenStream methodsFor: 'utility methods'!

parseComment
    "Scanner is at /*<> ... "
    | ch ch2 |
    ch _ self nextChar.
      
    [ ch isNil ifTrue: [ ^nil ].
      ch2 _ self nextChar.
      (ch == $* and: [ ch2 == $/ ]) ifTrue: [ ^nil ].
      ch _ ch2.
    ] repeat.
!

isSpecial: ch
    ^'%&*+,-/<=>?@\|~' includes: ch
! 

parseHexConstant
    "scanner at 0x<>..."
    | num ch |
    ch _ self peekChar.
    num _ self parseDigits: ch base: 16.
    self gobbleIntegerSuffix.
    ^CIntegerToken value: num truncated.
!


parseOctalConstant
    "scanner at 0<>..."
    | num ch |
    ch _ self peekChar.
    num _ self parseDigits: ch base: 8.
    self gobbleIntegerSuffix.
    ^CIntegerToken value: num truncated.
!

gobbleIntegerSuffix
    | ch |
    "scanner at <digits><>...  may be [luLU][luLU]"
    ch _ self peekChar.
    (ch == $l) | (ch == $L) | (ch == $U) | (ch == $u)
	ifTrue: [ self nextChar.  "ignore it"
		  ch _ self peekChar.
		  (ch == $l) | (ch == $L) | (ch == $U) | (ch == $u)
		      ifTrue: [ self nextChar.  "ignore it" ].
		  ].
    
!


parseFrac: aNumber
    "Scanner at ';;;;.<>;;;'"
    | ch scale num |

    num _ aNumber.
    scale _ 1.0.
    [ ch _ self peekChar. self isDigit: ch base: 10 ] whileTrue:
	[ num _ num * 10.0 + ch digitValue.
	  self nextChar. 
	  scale _ scale / 10.0 .
	  ].

    num _ num * scale.

    (ch == $e) | (ch == $E)
	ifTrue: 
	    [ self nextChar.	"gobble the 'e' "
	      num _ self parseExponent: num ]
	ifFalse: 
	    [ self gobbleFloatSuffix ].
    ^num
!

parseExponent: aNumber
    "scanner at ....e<>..."
    | ch isNegative exponent | 
    
    ch _ self peekChar.
    ch == $-
	ifTrue: [ self nextChar.	"gobble it"
		  isNegative _ true. ]
	ifFalse: [ isNegative _ false. ].
    
    exponent _ self parseDigits: ch base: 10.
    self gobbleFloatSuffix.
    ^aNumber raisedToInteger: (exponent truncated)
!

gobbleFloatSuffix
    | ch |
    ch _ self peekChar.
    (ch == $f) | (ch == $F) | (ch == $l) | (ch == $L)
	ifTrue: [ self nextChar. ]
! 

parseDigits: ch base: base
    | c num |
    "assumes ch is peeked"
    c _ ch.
    num _ 0.0.			"accumulate FP in case we're really getting FP"
    [ c notNil and: [ self isDigit: c base: base ] ] whileTrue:
	[ num _ num * base + c asUppercase digitValue.
	  self nextChar. 
	  c _ self peekChar ].
    ^num
!


isDigit: aChar base: base
    ^aChar class == Character
	and: [ 
	       ((aChar between: $0 and: $9)
		    | (aChar between: $A and: $F) 
		    | (aChar between: $a and: $f) )
		   and: [ aChar asUppercase digitValue < base ] ]
! !



!LineTokenStream methodsFor: 'stream stack hacking'!

pushStream: aStream
    "Del-e-ga-tion 
       -- a Milton Bradley game"
    stream pushStream: aStream
! !


!LineTokenStream methodsFor: 'private'!

parseIdent
    | s ch id reservedId |
    s _ WriteStream on: (String new: 1).
    [ lineStream atEnd not
	  and: [ ch _ self peekChar.
		 ch isLetter or: [ ch isDigit or: [ ch == $_ ] ] ] ]
	whileTrue: [ s nextPut: ch.
		     self nextChar ].
    id _ s contents.
    reservedId _ self isReserved: id.
    reservedId notNil
	ifTrue: [ ^reservedId ]
	ifFalse: [ ^CIdentifierToken value: id ]
! 

isReserved: aString
    ^ReservedIds at: aString ifAbsent: [ nil ]
! !


!LineTokenStream methodsFor: 'private'!

setStream: aStream
    super init: aStream.
    self advanceLine
! !



LineTokenStream initialize!


"
| s str |
 
     s _ FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'.
     s _ LineTokenStream onStream: s.
    s printNl.
    s do: [ :line | line printNl. ].
!

     s _ FileStream open: 'xl.h' mode: 'r'.

"
