"======================================================================
|
|   Prolog interpreter written in Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Written by Aoki Atsushi and Nishihara Satoshi.
| Modified by Paolo Bonzini (removed GUI).
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

Object subclass: #PrologEntity
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologEntity subclass: #PrologList
	instanceVariableNames: 'carPart cdrPart '
	classVariableNames: 'PrologDotPairPrintHorizontalLevel PrologDotPairPrintVerticalLevel '
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologList subclass: #PrologBody
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologList subclass: #PrologClause
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologClause subclass: #PrologResolveClause
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologList subclass: #PrologDefinition
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologEntity subclass: #PrologObject
	instanceVariableNames: 'source object '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

Object subclass: #PrologScanner
	instanceVariableNames: 'source mark token tokenType endChar '
	classVariableNames: 'EndChar ScanningTable'
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologScanner subclass: #PrologParser
	instanceVariableNames: 'prevMark prevToken prevTokenType failBlock '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologEntity subclass: #PrologString
	instanceVariableNames: 'string '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologList subclass: #PrologStructure
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologString subclass: #PrologSymbol
	instanceVariableNames: ''
	classVariableNames: 'PrologCut PrologFail PrologSelf PrologSend PrologSymbolTable PrologTrue PrologVar '
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologList subclass: #PrologTerms
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Prolog'!

PrologString subclass: #PrologVariable
	instanceVariableNames: ''
	classVariableNames: 'PrologVariableCounter PrologVariableTable '
	poolDictionaries: ''
	category: 'Examples-Prolog'!

Object subclass: #PrologInterpreter
	instanceVariableNames: 'systemPredicates userPredicates status definition question questionEnv clause clauseEnv queue queueEnv envCounter valueEnv unbindList cutBack backTrack resolveAction definitionStack tracePredicates traceCounter textValue textCollector verbose listValue predicate '
	classVariableNames: 'SystemPredicates '
	poolDictionaries: ''
	category: 'Examples-Prolog'!



!Object methodsFor: 'prolog'!

car
    self == nil ifTrue: [^nil].
    self error: 'send message car to atom'!

cdr
    self == nil ifTrue: [^nil].
    self error: 'send message cdr to atom'!

cons: anObject 
    ^PrologList car: self cdr: anObject!

consp
    ^false!

isPrologEntity
    self == nil ifTrue: [^true].
    ^self isKindOf: Number!

isPrologVariable
    ^false!

printPrologOn: aStream 
    self == nil
	ifTrue: 
	    [aStream nextPutAll: '[]'.
	    ^self].
    (self isKindOf: Number)
	ifTrue: 
	    [self printOn: aStream.
	    ^self].
    aStream nextPut: ${.
    self printOn: aStream.
    aStream nextPut: $}!

printPrologOn: aStream level: anInteger 
    self printPrologOn: aStream!

printPrologString
    | aStream |
    aStream := WriteStream on: (String new: 20).
    self printPrologOn: aStream.
    ^aStream contents! !


!PrologEntity class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologEntity methodsFor: 'testing'!

isPrologEntity
    ^true! !



!PrologList class methodsFor: 'class initialization'!

initialize
    "PrologList initialize"

    PrologDotPairPrintVerticalLevel := 10.
    PrologDotPairPrintHorizontalLevel := 100! !

!PrologList class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologList class methodsFor: 'instance creation'!

car: carObject cdr: cdrObject 
    ^super new car: carObject cdr: cdrObject!

list: anArray
    | size list |
    size := anArray size.
    list := nil.
    size
	to: 1
	by: -1
	do: [:i | list := self car: (anArray at: i) cdr: list].
    ^list! !

!PrologList methodsFor: 'accessing'!

car
    ^carPart!

car: carObject 
    carPart := carObject!

cdr
    ^cdrPart!

cdr: cdrObject 
    cdrPart := cdrObject!

nth: anInteger 
    | count list |
    anInteger <= 0 ifTrue: [^self].
    count := 1.
    list := self.
    [list consp]
	whileTrue: 
	    [count >= anInteger ifTrue: [^list car].
	    count := count + 1.
	    list := list cdr].
    ^nil! !

!PrologList methodsFor: 'converting'!

asPrologList
    | list new tail |
    new := self car cons: nil.
    tail := new.
    list := self cdr.
    [list consp]
	whileTrue: 
	    [tail cdr: (list car cons: nil).
	    tail := tail cdr.
	    list := list cdr].
    tail cdr: list.
    ^new! !

!PrologList methodsFor: 'enumerating'!

do: aBlock
    | list |
    list := self.
    [list consp] whileTrue: [
	aBlock value: list car.
	list := list cdr]! !

!PrologList methodsFor: 'functions'!

append: aPrologDotPair 
    (cdrPart consp)
	ifFalse: [^carPart cons: aPrologDotPair].
    ^carPart cons: (cdrPart append: aPrologDotPair)!

arity
    ^2!

assoc: anObject 
    | list assoc |
    list := self.
    [list consp]
	whileTrue: 
	    [assoc := list car.
	    anObject = assoc car ifTrue: [^assoc].
	    list := list cdr].
    ^nil!

functor
    ^PrologSymbol fromString: '.'!

length
    | list count |
    list := self.
    count := 0.
    [list consp]
	whileTrue: 
	    [count := count + 1.
	    list := list cdr].
    ^count!

member: anObject 
    | list |
    list := self.
    [list consp]
	whileTrue: 
	    [anObject = list car ifTrue: [^list].
	    list := list cdr].
    ^nil!

nconc: aPrologDotPair 
    | list |
    list := self.
    [list consp]
	whileTrue: [(list cdr consp)
		ifTrue: [list := list cdr]
		ifFalse: 
		    [list cdr: aPrologDotPair.
		    ^self]].
    ^aPrologDotPair!

reverse
    | list revlist mark |
    list := self.
    revlist := nil.
    [list consp]
	whileTrue: 
	    [revlist == nil
		ifTrue: [revlist := mark := list car cons: revlist]
		ifFalse: [revlist := list car cons: revlist].
	    list := list cdr].
    mark cdr: list.
    ^revlist!

structureList
    "disassemble prolog structure of myself into a list."
    ^self functor cons: ((self car) cons: ((self cdr) cons: nil))! !

!PrologList methodsFor: 'printing'!

prettyPrintPrologOn: aStream 
    | head body list |
    head := self car.
    body := self cdr.
    head printPrologOn: aStream.
    body ~~ nil
	ifTrue: 
	    [aStream nextPutAll: ' :- '.
	    list := body.
	    aStream nl; tab.
	    [list cdr consp]
		whileTrue: 
		    [list ~~ body
			ifTrue: 
			    [aStream nextPutAll: ', '.
			    aStream nl; tab].
		    list car printPrologOn: aStream.
		    list := list cdr].
	    list ~~ self
		ifTrue: 
		    [aStream nextPutAll: ', '.
		    aStream nl; tab].
	    list car printPrologOn: aStream].
    aStream nextPut: $.!

prettyPrintPrologString
    | aStream |
    aStream := WriteStream on: (String new: 20).
    self prettyPrintPrologOn: aStream.
    ^aStream contents!

printOn: aStream 
    aStream nextPutAll: self class printString.
    aStream nextPutAll: '('.
    aStream nextPutAll: self printPrologString.
    aStream nextPutAll: ')'!

printPrologOn: aStream 
    self printPrologOn: aStream level: 1!

printPrologOn: aStream cdr: tail level: anInteger 
    | d count |
    d := tail.
    count := 1.
    [d consp]
	whileTrue: 
	    [count >= PrologDotPairPrintHorizontalLevel
		ifTrue: 
		    [aStream nextPutAll: ' ... ]'.
		    ^self].
	    aStream nextPut: $,.
	    d car consp
		ifTrue: [d car printPrologOn: aStream level: anInteger + 1]
		ifFalse: [d car printPrologOn: aStream].
	    "d car printPrologOn: aStream level: anInteger + 1."
	    count := count + 1.
	    d := d cdr].
    d isNil
	ifTrue: [aStream nextPut: $]]
	ifFalse: 
	    [aStream nextPut: $|.
	    d printPrologOn: aStream.
	    aStream nextPut: $]]!

printPrologOn: aStream level: anInteger 
    anInteger > PrologDotPairPrintVerticalLevel
	ifTrue: 
	    [aStream nextPutAll: ' ... '.
	    ^self].
    aStream nextPutAll: '['.
    carPart consp
	ifTrue: [carPart printPrologOn: aStream level: anInteger + 1]
	ifFalse: [carPart printPrologOn: aStream].
    self
	printPrologOn: aStream
	cdr: cdrPart
	level: anInteger! !

!PrologList methodsFor: 'private'!

car: carObject cdr: cdrObject 
    carPart := carObject.
    cdrPart := cdrObject! !

!PrologList methodsFor: 'testing'!

= anObject 
    anObject consp ifFalse: [^false].
    self car = anObject car ifTrue: [^self cdr = anObject cdr].
    ^false!

consp
    ^true! !


PrologList initialize!

!PrologBody class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologBody class methodsFor: 'instance creation'!

fromList: aPrologDotPair 
    aPrologDotPair consp ifFalse: [^aPrologDotPair].
    ^super new fromList: aPrologDotPair!

fromReverseList: aPrologDotPair 
    aPrologDotPair consp ifFalse: [^aPrologDotPair].
    ^super new fromReverseList: aPrologDotPair!

structure: aPrologStructure next: link 
    ^super new structure: aPrologStructure next: link! !

!PrologBody methodsFor: 'printing'!

prettyPrintPrologOn: aStream 
    | list |
    list := self.
    aStream nl; tab.
    [list cdr consp]
	whileTrue: 
	    [list ~~ self
		ifTrue: 
		    [aStream nextPutAll: ', '.
		    aStream nl; tab].
	    list car printPrologOn: aStream.
	    list := list cdr].
    list ~~ self
	ifTrue: 
	    [aStream nextPutAll: ', '.
	    aStream nl; tab].
    list car printPrologOn: aStream!

printPrologOn: aStream 
    | list |
    list := self.
    [list cdr consp]
	whileTrue: 
	    [list ~~ self ifTrue: [aStream nextPutAll: ', '].
	    list car printPrologOn: aStream.
	    list := list cdr].
    list ~~ self ifTrue: [aStream nextPutAll: ', '].
    list car printPrologOn: aStream!

printPrologOn: aStream level: anInteger
    self printPrologOn: aStream! !

!PrologBody methodsFor: 'private'!

fromList: aPrologDotPair 
    ^self fromReverseList: aPrologDotPair reverse!

fromReverseList: aPrologDotPair 
    | list body mark |
    list := aPrologDotPair.
    body := nil.
    [list consp]
	whileTrue: 
	    [body == nil
		ifTrue: [body := mark := self class structure: list car next: body]
		ifFalse: [body := self class structure: list car next: body].
	    list := list cdr].
    mark cdr: list.
    ^body!

structure: aPrologStructure next: link 
    carPart := aPrologStructure.
    cdrPart := link! !



!PrologClause class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologClause class methodsFor: 'instance creation'!

head: aPrologStructure body: aPrologBody 
    ^super new head: aPrologStructure body: aPrologBody! !

!PrologClause methodsFor: 'accessing'!

body
    ^cdrPart!

body: aPrologBody 
    cdrPart := aPrologBody!

head
    ^carPart!

head: aPrologStructure 
    carPart := aPrologStructure! !

!PrologClause methodsFor: 'printing'!

prettyPrintPrologOn: aStream 
    | head body |
    head := self head.
    body := self body.
    head printPrologOn: aStream.
    body ~~ nil
	ifTrue: 
	    [aStream nextPutAll: ' :- '.
	    body prettyPrintPrologOn: aStream].
    aStream nextPut: $.!

prettyPrintPrologString
    | aStream |
    aStream := WriteStream on: (String new: 20).
    self prettyPrintPrologOn: aStream.
    ^aStream contents!

printPrologOn: aStream 
    | head body |
    head := self head.
    body := self body.
    aStream nextPut: $(.
    head printPrologOn: aStream.
    body == nil
	ifFalse: 
	    [aStream nextPutAll: ', '.
	    body printPrologOn: aStream].
    aStream nextPut: $)!

printPrologOn: aStream level: anInteger
    self printPrologOn: aStream! !

!PrologClause methodsFor: 'private'!

head: aPrologStructure body: aPrologBody 
    self head: aPrologStructure.
    self body: aPrologBody! !


!PrologClause methodsFor: 'polymorphism'!

isResolveClause
    ^false! !

!PrologResolveClause methodsFor: 'polymorphism'!

printPrologOn: aStream 
    | head body |
    head := self head.
    body := self body.
    aStream nextPutAll: '?- '.
    head printPrologOn: aStream.
    body ~~ nil
	ifTrue: 
	    [aStream nextPutAll: ', '.
	    body printPrologOn: aStream].
    aStream nextPut: $.!

isResolveClause
    ^true! !

!PrologDefinition class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologDefinition class methodsFor: 'instance creation'!

clause: aPrologClause next: link 
    ^super new clause: aPrologClause next: link!

fromList: aPrologDotPair 
    aPrologDotPair consp ifFalse: [^aPrologDotPair].
    ^super new fromList: aPrologDotPair!

fromReverseList: aPrologDotPair 
    aPrologDotPair consp ifFalse: [^aPrologDotPair].
    ^super new fromReverseList: aPrologDotPair! !

!PrologDefinition methodsFor: 'private'!

clause: aPrologClause next: link 
    carPart := aPrologClause.
    cdrPart := link!

fromList: aPrologDotPair 
    ^self fromReverseList: aPrologDotPair reverse!

fromReverseList: aPrologDotPair 
    | list definition |
    list := aPrologDotPair.
    definition := nil.
    [list consp]
	whileTrue: 
	    [definition := self class clause: list car next: definition.
	    list := list cdr].
    ^definition! !



!PrologObject class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologObject class methodsFor: 'instance creation'!

readFrom: aStream 
    | buffer char |
    buffer := WriteStream on: (String new: 20).
    
    [char := aStream next.
    char = $}]
	whileFalse: 
	    [char == nil ifTrue: [self error:
		    'Syntax error near ${ unmatched $}\-- end of file --' withCRs].
	    buffer nextPut: char].
    ^buffer contents!

source: aString object: anObject 
    ^super new source: aString object: anObject! !

!PrologObject methodsFor: 'accessing'!

object
    ^object!

object: anObject
    object := anObject!

source
    ^source!

source: aString
    source := aString! !

!PrologObject methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: self class printString.
    aStream nextPutAll: '('.
    aStream nextPutAll: self object printString.
    aStream nextPutAll: ')'!

printPrologOn: aStream 
    aStream nextPut: ${.
    aStream nextPutAll: self source.
    aStream nextPut: $}!

printPrologOn: aStream level: anInteger
    self printPrologOn: aStream! !

!PrologObject methodsFor: 'private'!

source: aString object: anObject 
    self source: aString.
    self object: anObject! !

!PrologObject methodsFor: 'testing'!

= anObject 
    anObject class = self class ifFalse: [^false].
    ^self object = anObject object! !



!PrologScanner class methodsFor: 'class initialization'!

initialize
    "PrologScanner initialize"

    | newTable |
    newTable := Array new: 256 withAll: #xBinary.
    newTable atAll: #(9 10 12 13 32 ) put: #xDelimiter.
    newTable atAll: ($0 asInteger to: $9 asInteger) put: #xDigit.
    newTable atAll: ($A asInteger to: $Z asInteger) put: #xVariable.
    newTable at: $~ asInteger put: #xVariable.
    newTable atAll: ($a asInteger to: $z asInteger) put: #xSymbol.
    128 to: 256 do: [:i | newTable at: i put: #xSymbol].
    #($! $: $* $/ $\ $> $< $= $_) do: [:each | newTable at: each asInteger put: #xSymbol].
    newTable at: $^ asInteger put: #eof.
    newTable at: $" asInteger put: #xDoubleQuote.
    newTable at: $$ asInteger put: #xDollar.
    newTable at: $' asInteger put: #xSingleQuote.
    newTable at: $( asInteger put: #leftParenthesis.
    newTable at: $) asInteger put: #rightParenthesis.
    newTable at: $. asInteger put: #period.
    newTable at: $: asInteger put: #xColon.
    newTable at: $? asInteger put: #xColon.
    newTable at: $; asInteger put: #semicolon.
    newTable at: $[ asInteger put: #leftBracket.
    newTable at: $] asInteger put: #rightBracket.
    newTable at: ${ asInteger put: #leftBrace.
    newTable at: $} asInteger put: #rightBrace.
    newTable at: $, asInteger put: #comma.
    newTable at: $| asInteger put: #verticalBar.
    newTable at: $+ asInteger put: #xSign.
    newTable at: $- asInteger put: #xSign.
    newTable at: $% asInteger put: #xComment.
    ScanningTable := newTable.
    EndChar := $^! !

!PrologScanner class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologScanner class methodsFor: 'instance creation'!

new
    ^super new initScanner! !

!PrologScanner methodsFor: 'accessing'!

tableAt: char
    | index |
    index := char asInteger.
    ^index = 0
	ifFalse: [ScanningTable at: index]
	ifTrue: [#xDelimiter]! !

!PrologScanner methodsFor: 'error handling'!

error: labelString with: contentsString
    "(PrologScanner new) error: 'error!' with: 'show must go on'."

    | handler |
    self error: contentsString! !

!PrologScanner methodsFor: 'initialize-release'!

initScanner
    endChar := EndChar!

on: inputStream 
    source := inputStream.
    mark := source position! !

!PrologScanner methodsFor: 'private'!

nextChar
    | char |
    source atEnd ifTrue: [ ^endChar ].
    char := source next.
    char = Character cr
	ifTrue: 
	    [char := Character nl. source peekFor: char].
    ^char!

peekChar
    | char |
    char := source peek.
    char = Character cr ifTrue: [char := Character nl].
    char == nil ifTrue: [char := endChar].
    ^char!

unNextChar
    source skip: -1! !

!PrologScanner methodsFor: 'scanning'!

multiChar: type 
    self perform: type!

nextToken
    | char |
    mark := source position.
    char := self peekChar.
    tokenType := self tableAt: char asInteger.
    [tokenType == #xDelimiter]
	whileTrue: 
	    [self nextChar.
	    char := self peekChar.
	    tokenType := self tableAt: char asInteger].
    (tokenType at: 1) = $x
	ifTrue:[self multiChar: tokenType]
	ifFalse:[self singleChar: tokenType].
    ^token!

singleChar: type 
    self nextChar.
    token := type.
    tokenType == #leftBrace ifFalse: [^self].
    tokenType := #object.
    token := PrologObject readFrom: source!

unNextToken
    source position: mark!

xBinary
    self error: 'Syntax error ' , source peek printString , '\' withCRs , source upToEnd!

xColon
    | char |
    source next.
    char := source peek.
    char = $-
	ifTrue: 
	    [tokenType := #neck.
	    self singleChar: tokenType]
	ifFalse: 
	    [self unNextToken.
	    tokenType := #symbol.
	    token := PrologSymbol readFrom: source]!

xComment
    | char |
    [(char := self nextChar) = Character nl]
	whileFalse: [char == endChar
		ifTrue: 
		    [tokenType := #eof.
		    ^self]].
    self nextToken!

xDigit
    tokenType := #number.
    token := Number readFrom: source!

xDollar
    self xBinary!

xDoubleQuote
    tokenType := #string.
    token := PrologString readFrom: source!

xSign
    | char sign |
    sign := self nextChar.
    char := self peekChar.
    char isDigit
	ifTrue: 
	    [tokenType := #number.
	    token := Number readFrom: source.
	    sign == $- ifTrue: [token := token negated]]
	ifFalse: 
	    [self unNextChar.
	    tokenType := #symbol.
	    token := PrologSymbol readFrom: source]!

xSingleQuote
    tokenType := #symbol.
    token := PrologSymbol readFrom: source!

xSymbol
    tokenType := #symbol.
    token := PrologSymbol readFrom: source!

xVariable
    tokenType := #variable.
    token := PrologVariable readFrom: source! !


PrologScanner initialize!

!PrologParser class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologParser methodsFor: 'parsing'!

parse: sourceStream 
    | label string |
    ^self parse: sourceStream
	ifFail: 
	    [:errorMessage | 
	    label := errorMessage , ' near ' , token printString.
	    string := source upToEnd.
	    string size > 100 ifTrue: [string := string copyFrom: 1 to: 100].
	    self error: label with: (string = ''
			ifTrue: ['-- end of file --']
			ifFalse: ['--> ' , string])]!

parse: sourceStream ifFail: aBlock
    | result |
    self init: sourceStream ifFail: aBlock.
    result := self scan.
    ^result! !

!PrologParser methodsFor: 'private'!

compileAndEvaluate: string 
    ^Behavior
	evaluate: string
	ifError: []!

init: sourceStream ifFail: aBlock 
    super on: sourceStream.
    failBlock := aBlock.
    PrologVariable setZero! !

!PrologParser methodsFor: 'scan'!

scan
    source atEnd ifTrue: [^#eof].
    self nextToken.
    tokenType == #eof ifTrue: [^#eof].
    tokenType == #neck ifTrue: [^self scanClause: PrologResolveClause]. "resolve clause"
    self unNextToken.
    ^self scanClause: PrologClause!

scanBody
    | list |
    list := nil.
    [tokenType ~~ #eof]
	whileTrue: 
	    [list := self scanStructure cons: list.
	    self nextToken.
	    tokenType == #rightParenthesis ifTrue: [^PrologBody fromReverseList: list].
	    tokenType == #period ifTrue: [^PrologBody fromReverseList: list].
	    tokenType ~~ #comma ifTrue: [failBlock value: 'Syntax error']].
    failBlock value: 'Unexpected eof'!

scanClause: class
    | head |
    head := self scanStructure.
    self nextToken.
    tokenType == #neck ifTrue: [^class head: head body: self scanBody].
    tokenType == #comma ifTrue: [^class head: head body: self scanBody].
    tokenType == #period ifTrue: [^class head: head body: nil].
    tokenType == #rightParenthesis ifTrue: [^class head: head body: nil].
    self unNextToken.
    failBlock value: 'Syntax error'!

scanExpression
    | symbol |
    self nextToken.
    (tokenType == #eof or: [tokenType == #period])
	ifTrue: [^nil].
    tokenType == #number ifTrue: [^token].
    tokenType == #string ifTrue: [^token].
    tokenType == #object ifTrue: [^PrologObject source: token object: (self compileAndEvaluate: token)].
    tokenType == #leftBracket ifTrue: [^self scanList].
    tokenType == #leftParenthesis ifTrue: [^self scanClause: PrologClause].
    (tokenType == #symbol or: [tokenType == #variable])
	ifTrue: 
	    [symbol := token.
	    self nextToken.
	    tokenType == #leftParenthesis
		ifTrue: 
		    [self unNextToken.
		    self unNextToken.
		    ^self scanStructure]
		ifFalse: 
		    [self unNextToken.
		    ^symbol]].
    self unNextToken.
    failBlock value: 'Syntax error'!

scanList
    | expression |
    self nextToken.
    tokenType == #comma ifTrue: [self nextToken].
    tokenType == #neck ifTrue: [self nextToken].
    tokenType == #rightBracket ifTrue: [^nil].
    tokenType == #leftBracket ifTrue: [^self scanList cons: self scanList].
    tokenType == #verticalBar
	ifTrue: 
	    [expression := self scanExpression.
	    self nextToken.
	    tokenType == #rightBracket
		ifTrue: [^expression]
		ifFalse: [failBlock value: 'Syntax error']].
    self unNextToken.
    expression := self scanExpression.
    ^expression cons: self scanList!

scanStructure
    | functor terms |
    functor := self nextToken.
    (tokenType == #symbol or: [tokenType == #variable])
	ifTrue: 
	    [terms := self scanTerms.
	    ^PrologStructure functor: functor terms: terms].
    failBlock value: 'Syntax error'!

scanTerms
    | list |
    self nextToken.
    tokenType == #leftParenthesis
	ifTrue: 
	    [self nextToken.
	    (tokenType == #verticalBar or: [tokenType == #rightParenthesis])
		ifTrue:
		    [tokenType == #rightParenthesis
			ifTrue: [^nil].
		    list := self scanExpression.
		    self nextToken.
		    tokenType == #rightParenthesis
			ifTrue: [^list]
			ifFalse: [failBlock value: 'Syntax error']]
		ifFalse: [self unNextToken].
	    list := nil.
	    [tokenType ~~ #eof]
		whileTrue: 
		    [list := self scanExpression cons: list.
		    self nextToken.
		    token == #rightParenthesis ifTrue: [^PrologTerms fromReverseList: list].
		    tokenType == #verticalBar
			ifTrue:
			    [list := list reverse.
			    list := list nconc: self scanExpression.
			    self nextToken.
			    tokenType == #rightParenthesis
				ifTrue: [^PrologTerms fromList: list]
				ifFalse: [failBlock value: 'Syntax error']].
		    tokenType ~~ #comma ifTrue: [failBlock value: 'Syntax error']].
	    failBlock value: 'Unexpected eof']
	ifFalse: 
	    [self unNextToken.
	    ^nil]! !

!PrologParser methodsFor: 'scanning'!

nextToken
    prevMark := mark.
    prevToken := token.
    prevTokenType := tokenType.
    ^super nextToken!

unNextToken
    super unNextToken.
    mark := prevMark.
    token := prevToken.
    tokenType := prevTokenType! !



PrologString class instanceVariableNames: 'charMap '!

!PrologString class methodsFor: 'accessing'!

charMap: map
    charMap := map!

charMapAt: char
    | index |
    index := char asInteger.
    ^index = 0
	ifTrue: [false]
	ifFalse: [charMap at: index]! !

!PrologString class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologString class methodsFor: 'instance creation'!

fromString: aString 
    ^super new string: aString!

readFrom: aStream 
    | buffer char string |
    buffer := WriteStream on: (String new: 20).
    char := aStream next.
    char = $" ifTrue: [
	[char := aStream peek.
	char ~~ nil]
	    whileTrue: 
		[char = $"
		    ifTrue: 
			[aStream next.
			char := aStream peek.
			char = $" ifFalse: [^self fromString: buffer contents]].
		buffer nextPut: aStream next]].
    string := aStream upToEnd.
    string size > 100 ifTrue: [string := string copyFrom: 1 to: 100].
    self error: 'Syntax error near $" unmatched $"\' withCRs , (string = ''
		    ifTrue: ['-- end of file --']
		    ifFalse: ['--> ' , string])! !

!PrologString methodsFor: 'accessing'!

at: index
    ^string at: index!

at: index put: char
    ^string at: index put: char!

size
    ^string size!

string
    ^string!

string: aString
    string := aString! !

!PrologString methodsFor: 'comparing'!

< aPrologString 
    ^self string < aPrologString string!

<= aPrologString 
    ^self string <= aPrologString string!

> aPrologString 
    ^self string > aPrologString string!

>= aPrologString 
    ^self string >= aPrologString string!

hash
    ^self asString hash! !

!PrologString methodsFor: 'converting'!

asString
    ^self string! !

!PrologString methodsFor: 'enumerating'!

do: aBlock
    ^self asString do: aBlock! !

!PrologString methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: self class printString.
    aStream nextPutAll: '('.
    aStream nextPutAll: self asString.
    aStream nextPutAll: ')'!

printPrologOn: aStream 
    | i length x |
    aStream nextPut: $".
    i := 0.
    length := string size.
    [(i := i + 1) <= length]
	whileTrue: 
	    [aStream nextPut: (x := string at: i).
	    x == $" ifTrue: [aStream nextPut: x]].
    aStream nextPut: $"!

printPrologOn: aStream level: anInteger 
    self printPrologOn: aStream! !

!PrologString methodsFor: 'testing'!

= anObject 
    anObject class = self class ifFalse: [^false].
    ^self string = anObject string! !



!PrologStructure class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologStructure class methodsFor: 'instance creation'!

functor: aPrologSymbol terms: aPrologTerms 
    ^super new functor: aPrologSymbol terms: aPrologTerms! !

!PrologStructure methodsFor: 'accessing'!

arity
    ^self terms length!

functor
    ^carPart!

functor: aPrologSymbol 
    carPart := aPrologSymbol!

nthTerm: anInteger 
    ^cdrPart nth: anInteger!

terms
    ^cdrPart!

terms: aPrologTerms 
    cdrPart := aPrologTerms! !

!PrologStructure methodsFor: 'functions'!

structureList
    "disassemble prolog structure of myself into a list."
    ^(self functor) cons: self terms asPrologList! !

!PrologStructure methodsFor: 'printing'!

printPrologOn: aStream 
    | functor terms |
    functor := self functor.
    terms := self terms.
    functor printPrologOn: aStream.
    terms == nil
	ifFalse:
	    [(terms consp)
		ifTrue: [terms printPrologOn: aStream]
		ifFalse:
		    [aStream nextPutAll: '(|'.
		    terms printPrologOn: aStream.
		    aStream nextPut: $)]]!

printPrologOn: aStream level: anInteger
    self printPrologOn: aStream! !

!PrologStructure methodsFor: 'private'!

functor: aPrologSymbol terms: aPrologTerms 
    self functor: aPrologSymbol.
    self terms: aPrologTerms! !



!PrologSymbol class methodsFor: 'class initialization'!

initialize
    "PrologSymbol initialize"

    | newMap |
    newMap := Array new: 256 withAll: false.
    newMap atAll: ($0 asInteger to: $9 asInteger)
	put: true.
    newMap atAll: ($A asInteger to: $Z asInteger)
	put: true.
    newMap atAll: ($a asInteger to: $z asInteger)
	put: true.
    128 to: 256 do: [:i | newMap at: i put: true].
    #($+ $- $! $: $* $/ $\ $> $< $= $_) do: [:each | newMap at: each asInteger put: true].
    self charMap: newMap.

    PrologSymbolTable := Dictionary new.
    PrologCut := self install: '!'.
    PrologTrue := self install: 'true'.
    PrologFail := self install: 'fail'.
    PrologSend := self install: 'send'.
    PrologVar := self install: 'var'.
    PrologSelf := self install: 'self'! !

!PrologSymbol class methodsFor: 'constants'!

cut
    ^PrologCut! !

!PrologSymbol class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologSymbol class methodsFor: 'instance creation'!

install: aString 
    | symbol key |
    symbol := PrologSymbolTable at: aString ifAbsent: [nil].
    symbol == nil
	ifTrue: 
	    [key := self fromString: aString.
	    symbol := self fromString: aString.
	    PrologSymbolTable at: key put: symbol].
    ^symbol!

readFrom: aStream 
    | buffer char |
    buffer := WriteStream on: (String new: 20).
    char := aStream peek.
    char == $'
	ifTrue: 
	    [aStream next.
	    
	    [char := aStream peek.
	    char ~~ nil]
		whileTrue: 
		    [char = $'
			ifTrue: 
			    [aStream next.
			    char := aStream peek.
			    char = $' ifFalse: [^self install: buffer contents]].
		    buffer nextPut: aStream next].
	self error: 'Syntax error near $'' unmatched $''\-- end of file --' withCRs].
    (self expect: '=..' on: aStream)
	ifTrue: ["Non standard (or ad hoc) parsing patterns."
	    ^self install: '=..'].
    [char ~~ nil and: [self charMapAt: char]]
	whileTrue: 
	    [buffer nextPut: aStream next.
	    char := aStream peek].
    ^self install: buffer contents! !

!PrologSymbol class methodsFor: 'private'!

expect: aString on: aStream
    "If aStream contains aString at the current position, then return true and set the position of aStream to the next char of the string.
    else return false and rewind the position."

    | pos string |
    pos := aStream position.
    string := String new.
    aString size timesRepeat: [
	aStream atEnd ifFalse: [string := string , (String with: aStream next)]].
    aString = string
	ifTrue: [^true]
	ifFalse: [
	    aStream position: pos.
	    ^false]! !

!PrologSymbol methodsFor: 'accessing'!

arity
    ^0!

functor
    ^self! !

!PrologSymbol methodsFor: 'printing'!

printPrologOn: aStream 
    | flag firstChar i length x |
    flag := false.
    self do: [:each | (self class charMapAt: each)
	    ifFalse: [flag := true]].
    string isEmpty
	ifTrue: 
	    [aStream nextPutAll: ''''.
	    aStream nextPutAll: '''']
	ifFalse: 
	    [firstChar := string at: 1.
	    ((firstChar >= $A and: [firstChar <= $Z])
		or: [flag])
		ifTrue: 
		    [aStream nextPutAll: ''''.
		    i := 0.
		    length := string size.
		    [(i := i + 1) <= length]
			whileTrue: 
			    [aStream nextPut: (x := string at: i).
			    x == $' ifTrue: [aStream nextPut: x]].
		    aStream nextPutAll: '''']
		ifFalse: 
		    [i := 0.
		    length := string size.
		    [(i := i + 1) <= length]
			whileTrue: 
			    [aStream nextPut: (x := string at: i).
			    x == $' ifTrue: [aStream nextPut: x]]]]!

printPrologOn: aStream level: anInteger 
    self printPrologOn: aStream! !

!PrologSymbol methodsFor: 'testing'!

isBuiltInPredicate
    self isPrologCut ifTrue: [^true].
    self isPrologTrue ifTrue: [^true].
    self isPrologFail ifTrue: [^true].
    self isPrologSend ifTrue: [^true].
    self isPrologVar ifTrue: [^true].
    ^false!

isPrologCut
    ^self = PrologCut!

isPrologFail
    ^self = PrologFail!

isPrologSelf
    ^self = PrologSelf!

isPrologSend
    ^self = PrologSend!

isPrologTrue
    ^self = PrologTrue!

isPrologVar
    ^self = PrologVar! !


PrologSymbol initialize!

!PrologTerms class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologTerms class methodsFor: 'instance creation'!

fromList: aPrologDotPair 
    ^super new fromList: aPrologDotPair!

fromReverseList: aPrologDotPair 
    ^super new fromReverseList: aPrologDotPair!

term: term next: link 
    ^super new term: term next: link! !

!PrologTerms methodsFor: 'printing'!

printPrologOn: aStream 
    | list |
    aStream nextPut: $(.
    list := self.
    [list cdr consp]
	whileTrue: 
	    [list ~~ self ifTrue: [aStream nextPut: $,].
	    list car printPrologOn: aStream.
	    list := list cdr].
    list ~~ self ifTrue: [aStream nextPut: $,].
    list car printPrologOn: aStream.
    list cdr isNil
	ifTrue: [aStream nextPut: $)]
	ifFalse:
	    [aStream nextPut: $|.
	    list cdr printPrologOn: aStream.
	    aStream nextPut: $)]!

printPrologOn: aStream level: anInteger
    self printPrologOn: aStream! !

!PrologTerms methodsFor: 'private'!

fromList: aPrologDotPair 
    ^self fromReverseList: aPrologDotPair reverse!

fromReverseList: aPrologDotPair 
    | list terms mark |
    list := aPrologDotPair.
    terms := nil.
    [list consp]
	whileTrue: 
	    [terms == nil
		ifTrue: [terms := mark := self class term: list car next: terms]
		ifFalse: [terms := self class term: list car next: terms].
	    list := list cdr].
    mark cdr: list.
    ^terms!

term: anObject next: link 
    carPart := anObject.
    cdrPart := link! !



!PrologVariable class methodsFor: 'class initialization'!

initialize
    "PrologVariable initialize"

    | newMap |
    newMap := Array new: 256 withAll: false.
    newMap atAll: ($0 asInteger to: $9 asInteger)
	put: true.
    newMap atAll: ($A asInteger to: $Z asInteger)
	put: true.
    newMap atAll: ($a asInteger to: $z asInteger)
	put: true.
    newMap at: $~ asInteger put: true.
    self charMap: newMap.
    self setZero.
    PrologVariableTable := Dictionary new! !

!PrologVariable class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologVariable class methodsFor: 'instance creation'!

install: aString 
    | variable key |
    variable := PrologVariableTable at: aString ifAbsent: [nil].
    variable == nil
	ifTrue: 
	    [key := aString.
	    variable := self fromString: aString.
	    PrologVariableTable at: key put: variable].
    ^variable!

readFrom: aStream 
    | buffer char |
    buffer := WriteStream on: (String new: 20).
    char := aStream peek.
    (char ~~ nil and: [char = $~])
	ifTrue: 
	    [aStream next.
	    self countUp.
	    ^self install: '~' , PrologVariableCounter printString].
    [char ~~ nil and: [ self charMapAt: char]]
	whileTrue: 
	    [buffer nextPut: aStream next.
	    char := aStream peek].
    ^self install: buffer contents! !

!PrologVariable class methodsFor: 'private'!

countUp
    PrologVariableCounter := PrologVariableCounter + 1!

setZero
    PrologVariableCounter := 0! !

!PrologVariable methodsFor: 'printing'!

printPrologOn: aStream 
    (self asString at: 1)
	= $~
	ifTrue: [aStream nextPut: $~]
	ifFalse: [aStream nextPutAll: self asString]!

printPrologOn: aStream level: anInteger
    self printPrologOn: aStream! !

!PrologVariable methodsFor: 'testing'!

isPrologVariable
    ^true! !


PrologVariable initialize!

!PrologInterpreter class methodsFor: 'class initialization'!

flushOthers
    "PrologInterpreter flushOthers."

    self flushSystemPredicates!

flushSystemPredicates
    "PrologInterpreter flushSystemPredicates."

    SystemPredicates := nil! !

!PrologInterpreter class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!PrologInterpreter class methodsFor: 'examples'!

example01
    "PrologInterpreter example01."

    self example: '

    ?- remove.       % remove all predicates in PrologDataBase.
    likes(john,mary).    % assert fact.
    likes(john,wine).    % assert fact.
    likes(mary,wine).    % assert fact.
    likes(mary,john).    % assert fact.
    ?- likes(X,Y).	   % question goal.
    ?- likes(john,X), likes(mary,X). % question goal.

    '!

example02
    "PrologInterpreter example02."

    self example: '

    ?- remove.       % remove all predicates in PrologDataBase.
    on(hen,cat).
    on(cat,dog).
    on(dog,donkey).
    above(X,Y) :-
	on(X,Y).
    above(X,Y) :-
	on(X,Z), above(Z,Y).
    ?- on(X,dog).
    ?- above(X,dog).

    '!

example03
    "PrologInterpreter example03."

    self example: '

    ?- remove.    % remove all predicates in PrologDataBase.
    hanoi(N) :-    % This is Hanoi Tower Prolgram.
	move(N,left,right,center).
	move(0,X,Y,Z) :- !.
    move(N,A,B,C) :-
	-(N,1,M),
	move(M,A,C,B),
	inform(A,B),
	move(M,C,B,A).
    inform(X,Y) :-
	write([move,disc,from,X,to,Y]),
	nl.
    ?- hanoi(3).     % question goal.

    '!

example04
    "PrologInterpreter example04."

    | string prolog result |
    self example: '?- append(X,Y,[a,b,c,d]).'!

example05
    "PrologInterpreter example05."

    self example: '

    ?- send(123,+,[456],X).   % X := 123 + 456.

    '!

example06
    "PrologInterpreter example06."

    self example: '

    ?- is(X,+(3,4)).
    ?- is(X,F(3,4)).

    '!

example: string
    ^PrologInterpreter new
	textCollector: Transcript;
	refute: string action: 
	    [:answer | 
	    answer keys asSortedCollection
		do: 
		    [:s | 
		    Transcript show: s.
		    Transcript show: ' = '.
		    Transcript show: (answer at: s) printPrologString.
		    Transcript nl]. false]! !

!PrologInterpreter class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!PrologInterpreter class methodsFor: 'public access'!

refute: stringOrStream 
    ^self new refute: stringOrStream!

refute: stringOrStream action: aBlock 
    ^self new refute: stringOrStream action: aBlock! !

!PrologInterpreter methodsFor: 'accessing'!

textCollector
    ^textCollector!

textCollector: aTextCollector 
    textCollector := aTextCollector! !

!PrologInterpreter methodsFor: 'binding and unbinding'!

bind: x env: xEnv and: y env: yEnv 
    | list |
    list := (self fetchValue: y env: yEnv) cons: valueEnv.
    list := (x cons: list) cons: xEnv cdr. 
    xEnv cdr: list. 
    unbindList := xEnv cons: unbindList!

binding: x env: xEnv 
    | assocList |
    assocList := xEnv cdr.
    assocList == nil ifTrue: [^nil].
    ^assocList assoc: x!

fetchValue: x env: xEnv 
    | xx xxEnv assoc |
    xx := x.
    xxEnv := xEnv.
    [true]
	whileTrue: 
	    [valueEnv := xxEnv.
	    xx isPrologVariable
		ifTrue: 
		    [assoc := self binding: xx env: xxEnv.
		    assoc == nil ifTrue: [^xx].
		    assoc := assoc cdr.
		    xx := assoc car.
		    xxEnv := assoc cdr]
		ifFalse: [^xx]]!

noValue: x env: xEnv 
    | assoc |
    x isPrologVariable
	ifTrue: 
	    [assoc := self binding: x env: xEnv.
	    assoc == nil ifTrue: [^true].
	    assoc := assoc cdr.
	    ^self noValue: assoc car env: assoc cdr].
    ^false!

nullEnv
    envCounter := envCounter + 1.
    ^envCounter cons: nil!

unbindFrom: start to: end 
    | list env assocList |
    list := start.
    [list ~~ end]
	whileTrue: 
	    [env := list car.
	    assocList := env cdr.
	    assocList car cdr cdr: nil.
	    env cdr: assocList cdr.
	    list := list cdr]! !

!PrologInterpreter methodsFor: 'copying'!

shallowCopy
    super shallowCopy.
    textValue := nil.
    listValue := nil.
    predicate := nil! !

!PrologInterpreter methodsFor: 'initialize-release'!

initialize
    systemPredicates := Dictionary new.
    userPredicates := Dictionary new.
    tracePredicates := Dictionary new.
    textCollector := Transcript.
    verbose := false.
    self makeSystemPredicates! !

!PrologInterpreter methodsFor: 'kernel predicates'!

builtInCut
    backTrack := cutBack car.
    clause := clause cdr.
    status := #loop!

builtInFail
    status := #back!

builtInPredicate: functor 
    functor isPrologCut ifTrue: [^self builtInCut].
    functor isPrologTrue ifTrue: [^self builtInTrue].
    functor isPrologFail ifTrue: [^self builtInFail].
    functor isPrologSend ifTrue: [^self builtInSend].
    functor isPrologVar ifTrue: [^self builtInVar].
    self error: 'Unexpected built-in predicate'!

builtInSend
    | list receiverSymbol selectorSymbol argumentList unifyTerm result |
    list := self expression: clause car cdr env: clauseEnv.
    receiverSymbol := list car.
    list := list cdr.
    selectorSymbol := list car.
    list := list cdr.
    argumentList := list car.
    list := list cdr.
    list == nil
	ifTrue: [unifyTerm := nil]
	ifFalse: [list cdr == nil
		ifTrue: [unifyTerm := clause car cdr nth: 4]
		ifFalse: 
		    [status := #back.
		    ^self]].
    result := self
		receiver: receiverSymbol
		selector: selectorSymbol
		arguments: argumentList.
    result = PrologSymbol cut
	ifTrue: 
	    [self builtInCut.
	    status := #back.
	    ^self].
    unifyTerm isNil
	ifTrue: 
	    [result = false ifFalse: [result := true].
	    result
		ifTrue: 
		    [clause := clause cdr.
		    status := #loop.
		    ^self]
		ifFalse: 
		    [status := #back.
		    ^self]]
	ifFalse: [(self
		unify: unifyTerm
		env: clauseEnv
		and: result
		env: self nullEnv)
		ifTrue: 
		    [clause := clause cdr.
		    status := #loop.
		    ^self]
		ifFalse: 
		    [status := #back.
		    ^self]].
    ^self!

builtInTrue
    clause := clause cdr.
    status := #loop!

builtInVar
    | var |
    var := clause car cdr car.
    (self noValue: var env: clauseEnv)
	ifTrue: 
	    [clause := clause cdr.
	    status := #loop]
	ifFalse: [status := #back]!

call: aPrologStructure 
    | structure functor |
    aPrologStructure cdr == nil
	ifTrue: 
	    [self callVariable: aPrologStructure car.
	    ^self].
    structure := self expression: aPrologStructure env: clauseEnv.
    (self
	unify: aPrologStructure
	env: clauseEnv
	and: structure
	env: clauseEnv)
	ifFalse: [self error: 'Unexpected unify structure'].
    functor := structure car.
    functor isPrologVariable
	ifTrue: 
	    [status := #back.
	    ^self].
    clause := clause cdr.
    clause := structure cons: clause.
    status := #loop!

callVariable: aPrologVariable 
    | horn functor |
    horn := self expression: aPrologVariable env: clauseEnv.
    (self
	unify: aPrologVariable
	env: clauseEnv
	and: horn
	env: clauseEnv)
	ifFalse: [self error: 'Unexpected unify horn clause'].
    horn consp ifFalse: [horn := PrologStructure functor: horn terms: nil].
    horn car consp ifFalse: [horn := PrologClause head: horn body: nil].
    horn := PrologClause head: horn car body: (PrologBody fromList: horn cdr).
    functor := horn car car.
    functor isPrologVariable
	ifTrue: 
	    [status := #back.
	    ^self].
    clause := clause cdr.
    horn := horn reverse.
    [horn consp]
	whileTrue: 
	    [clause := horn car cons: clause.
	    horn := horn cdr].
    status := #loop!

receiver: receiverSymbol selector: selectorSymbol arguments: argumentList 
    | receiver size selector arguments list result index |
    ((receiverSymbol isKindOf: PrologSymbol)
	and: [receiverSymbol isPrologSelf])
	ifTrue: [receiver := self]
	ifFalse: [receiver := receiverSymbol].
    (receiver isKindOf: PrologObject)
	ifTrue: [receiver := receiver object].
    size := selectorSymbol size.
    selector := String new: size.
    1 to: size do: [:i | selector at: i put: (selectorSymbol at: i)].
    selector := selector asSymbol.
    list := argumentList.
    list == nil
	ifTrue: 
	    [arguments := Array new.
	    result := receiver perform: selector]
	ifFalse: 
	    [size := list length.
	    arguments := Array new: size.
	    1 to: size
		do: 
		    [:i | 
		    arguments at: i put: ((list car isKindOf: PrologObject)
			    ifTrue: [list car object]
			    ifFalse: [list car]).
		    list := list cdr].
	    result := receiver perform: selector withArguments: arguments].
    ((result = true or: [result = false])
	or: [result isPrologEntity])
	ifTrue: [result := result yourself]
	ifFalse: 
	    [list := PrologList car: receiverSymbol cdr: argumentList.
	    index := (Array with: receiver)
			, arguments findFirst: [:each | each = result].
	    index = 0
		ifTrue: [result := PrologObject source: result printString object: result]
		ifFalse: [result := list nth: index]].
    ^result! !

!PrologInterpreter methodsFor: 'outputting'!

outputAnswer: dict 
    | anArray string assoc associations |
    associations := OrderedCollection new.
    dict associationsDo: [:association | associations add: association].
    anArray := associations asSortedCollection.
    1 to: anArray size do: [:i | 
	assoc := anArray at: i.
	i = 1
	    ifTrue: [string := '']
	    ifFalse: [string := ',\' withCRs].
	string := string , assoc key.
	string := string , ' = '.
	string := string , assoc value printPrologString.
	string := string , ' '.
	textCollector show: string]!

outputTime: msec 
    | goal string |
    verbose
	ifTrue: 
	    [goal := envCounter - 1.
	    string := '<'.
	    string := string , msec printString , ' milliseconds, '.
	    string := string , goal printString , ' goals'.
	    string := string , '>\' withCRs.
	    textCollector show: string asText]!

outputVariables: aDictionary
    | bool |
    self outputAnswer: aDictionary.
    bool := self confirm: 'All right ?'.
    bool
	ifTrue: [textCollector nl]
	ifFalse: [textCollector show: ';\' withCRs].
    ^bool! !

!PrologInterpreter methodsFor: 'private'!

acceptWith: aText
    "force to regist aText as a contents."

    self contents: aText.
    textValue := aText.
    self changed: #clearUserEdits!

associations: aCollection
    "by nishis, 1998/04/12 07:34"

    | anOrderedCollection |
    anOrderedCollection := OrderedCollection new: aCollection size.
    aCollection associationsDo: [:association | anOrderedCollection add: association].
    ^ anOrderedCollection!

deallocateEnv: env
    | assocList assoc nextEnv |  
    assocList := env cdr.
    [assocList consp]
	whileTrue: 
	    [assoc := assocList car.
	    nextEnv := assoc cdr cdr.
	    assoc cdr cdr: nil.
	    nextEnv consp ifTrue: [self deallocateEnv: nextEnv].
	    assocList := assocList cdr]!

getCondition
    | condition |
    condition := Array new: 14.
    condition at: 1 put: status.
    condition at: 2 put: definition.
    condition at: 3 put: question.
    condition at: 4 put: questionEnv.
    condition at: 5 put: clause.
    condition at: 6 put: clauseEnv.
    condition at: 7 put: queue.
    condition at: 8 put: queueEnv.
    condition at: 9 put: valueEnv.
    condition at: 10 put: unbindList.
    condition at: 11 put: cutBack.
    condition at: 12 put: backTrack.
    condition at: 13 put: resolveAction.
    condition at: 14 put: definitionStack.
    ^condition!

makeSystemPredicates
    SystemPredicates isNil
	ifTrue: 
	    [self systemPredicatesNo0.
	    self systemPredicatesNo1.
	    self systemPredicatesNo2.
	    self systemPredicatesNo3.
	    self systemPredicatesNo4.
	    self systemPredicatesNo5.
	    self systemPredicatesNo6.
	    self systemPredicatesNo7.
	    self systemPredicatesNo8.
	    self systemPredicatesNo9.
	    SystemPredicates := systemPredicates]
	ifFalse: [systemPredicates := SystemPredicates]!

putCondition: condition 
    status := condition at: 1.
    definition := condition at: 2.
    question := condition at: 3.
    questionEnv := condition at: 4.
    clause := condition at: 5.
    clauseEnv := condition at: 6.
    queue := condition at: 7.
    queueEnv := condition at: 8.
    valueEnv := condition at: 9.
    unbindList := condition at: 10.
    cutBack := condition at: 11.
    backTrack := condition at: 12.
    resolveAction := condition at: 13.
    definitionStack := condition at: 14!

systemPredicatesNo0
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	! :- builtin.
	true :- builtin.
	fail :- builtin.
	var(X) :- builtin.
	send(X,Y,Z) :- bulitin.
	send(X,Y,Z,A) :- bulitin.
    ')!

systemPredicatesNo1
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	repeat.
	repeat :- repeat.
	nonvar(X) :- var(X), !, fail.
	nonvar(X).
	integer(X) :- send(self,integer:,[X]).
	float(X) :- send(self,float:,[X]).
	double(X) :- send(self,double:,[X]).
	fraction(X) :- send(self,fraction:,[X]).
	number(X) :- send(self,number:,[X]).
	symbol(X) :- send(self,symbol:,[X]).
	string(X) :- send(self,string:,[X]).
	list(X) :- send(self,list:,[X]).
	dotp(X) :- send(self,dotp:,[X]).
	atom(X) :- symbol(X).
	atom(X) :- nonvar(X), =(X,[]).
	atom(X) :- string(X).
	atomic(X) :- atom(X).
	atomic(X) :- number(X).
	structure(X) :- nonvar(X), not(atomic(X)).
    ')!

systemPredicatesNo2
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	==(X,Y) :- send(X,=,[Y]).
	\==(X,Y) :- ==(X,Y), !, fail.
	\==(X,Y).
	=(X,X).
	\=(X,Y) :- =(X,Y), !, fail.
	\=(X,Y).
	>(X,Y) :- send(X,>,[Y]).
	>=(X,Y) :- send(X,>=,[Y]).
	<(X,Y) :- send(X,<,[Y]).
	=<(X,Y) :- send(X,<=,[Y]).
    ')!

systemPredicatesNo3
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	+(X,Y,Z) :- send(X,+,[Y],Z).
	-(X,Y,Z) :- send(X,-,[Y],Z).
	*(X,Y,Z) :- send(X,*,[Y],Z).
	//(X,Y,Z) :- send(X,//,[Y],Z).
	/(X,Y,Z) :- send(X,/,[Y],Z).
	\\(X,Y,Z) :- send(X,\\,[Y],Z).
	is(Z,+(X,Y)) :- nonvar(Z), nonvar(X), nonvar(Y), send(X,+,[Y],Z).
	is(Z,+(X,Y)) :- var(Z), nonvar(X), nonvar(Y), send(X,+,[Y],Z).
	is(Z,+(X,Y)) :- var(X), nonvar(Y), nonvar(Z), send(Z,-,[Y],X).
	is(Z,+(X,Y)) :- var(Y), nonvar(Z), nonvar(X), send(Z,-,[X],Y).
	is(Z,-(X,Y)) :- nonvar(Z), nonvar(X), nonvar(Y), send(X,-,[Y],Z).
	is(Z,-(X,Y)) :- var(Z), nonvar(X), nonvar(Y), send(X,-,[Y],Z).
	is(Z,-(X,Y)) :- var(X), nonvar(Y), nonvar(Z), send(Z,+,[Y],X).
	is(Z,-(X,Y)) :- var(Y), nonvar(Z), nonvar(X), send(X,-,[Z],Y).
	is(Z,*(X,Y)) :- nonvar(Z), nonvar(X), nonvar(Y), send(X,*,[Y],Z).
	is(Z,*(X,Y)) :- var(Z), nonvar(X), nonvar(Y), send(X,*,[Y],Z).
	is(Z,*(X,Y)) :- var(X), nonvar(Y), nonvar(Z), send(Z,/,[Y],X).
	is(Z,*(X,Y)) :- var(Y), nonvar(Z), nonvar(X), send(Z,/,[X],Y).
	is(Z,/(X,Y)) :- nonvar(Z), nonvar(X), nonvar(Y), send(X,/,[Y],Z).
	is(Z,/(X,Y)) :- var(Z), nonvar(X), nonvar(Y), send(X,/,[Y],Z).
	is(Z,/(X,Y)) :- var(X), nonvar(Y), nonvar(Z), send(Z,*,[Y],X).
	is(Z,/(X,Y)) :- var(Y), nonvar(Z), nonvar(X), send(X,/,[Z],Y).
	is(X,Y) :- =(X,Y).
    ')!

systemPredicatesNo4
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	listing :- send(self,userListing,[]).
	listing(X) :- send(self,userListing:,[X]).
	systemListing :- send(self,systemListing,[]).
	systemListing(X) :- send(self,systemListing:,[X]).
	consult(X) :- nonvar(X), send(self,consultFile:,[X]).
	reconsult(X) :- nonvar(X), send(self,reconsultFile:,[X]).
	saving :- send(self,saving,[]).
	saving(X) :- send(self,saving:,[X]).
	userPredicates(X) :- send(self,userPredicates,[],X).
	systemPredicates(X) :- send(self,systemPredicates,[],X).
	predicates([X|Y]) :- userPredicates(X), systemPredicates(Y).
	functor(T,F,A) :- nonvar(T), !, send(self,functorArityOf:,[T],[F|A]).
	functor(T,F,A) :- number(F), !, =(0,A),=(T,F).
	functor(T,F,A) :- atom(F), =<(0,A), ''~addvar''([F],A,L), =..(T,L).
	''~addvar''(L,0,M) :- !, =(L,M).
	''~addvar''(L,NVars,M) :- -(NVars, 1, N), append(L,[FreeV],LV), ''~addvar''(LV,N,M).
	arg(Nth,S,T) :- integer(Nth), <(0,Nth), structure(S), =..(S,[F|L]), nth(L,Nth,T).
	=..(X,Y) :- send(self,univ:,[[''X''|''Y'']]).
	name(X,Y) :- atomic(X), list(Y), !, send(self,symToList:,[X],Y).
	name(X,Y) :- atomic(X), !, send(self,symToStr:,[X],Y).
	name(X,Y) :- var(X), !, nonvar(Y), send(self, strToSym:,[Y],X).
	remove :- send(self,remove,[]).
	remove(X) :- send(self,remove:,[X]).
	clause(X) :- send(self,clauseSet:,[X]), repeat, send(self,clause:,[X],X).
	asserta(X) :- send(self,asserta:,[X]).
	assert(X) :- send(self,assertz:,[X]).
	assertz(X) :- send(self,assertz:,[X]).
	retract(X) :- repeat, send(self,retract:,[X],X).
    ')!

systemPredicatesNo5
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	call(G) :- G.
	not(G) :- G, !, fail.
	not(G).
	or(X,Y) :- call(X).
	or(X,Y) :- call(Y).
	and(X,Y) :- call(X), call(Y).
    ')!

systemPredicatesNo6
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	write(X) :- send(self,write:,[X]).
	nl :- send(self,nl,[]).
	tab(X) :- number(X), send(self,tab:,[X]).
	clear :- send(self,clear,[]).
    ')!

systemPredicatesNo7
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	clock(X) :- send({Time},millisecondClockValue,[],X).
	verbose(X) :- send(self,verbose:,[X]).
	gc :- send(self,gc,[]).
	inspect(X) :- send(X,inspect,[]).
	spy(X) :- send(self,spy:,[X]).
	nospy(X) :- send(self,nospy:,[X]).
	trace :- send(self,trace,[]).
	notrace :- send(self,notrace,[]).
    ')!

systemPredicatesNo8
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	append([],X,X).
	append([A|X],Y,[A|Z]) :- append(X,Y,Z).
	member(X,[X|Y]).
	member(X,[Y|Z]) :- member(X,Z).
	reverse([],[]).
	reverse([H|T],L) :- reverse(T,Z), append(Z,[H],L).
	length(X,Y) :- send(self,length:,[X],Y).
	nth([X|Y],1,Z) :- !, =(X,Z).
	nth([X|Y],N,Z) :- -(N,1,PN), nth(Y,PN,Z).
	printlist(L) :- send(self,listPrint:,[L]).
	lispAppend(X,Y,Z) :- send(X,append:,[Y],Z).
	lispReverse(X,Y) :- send(X,reverse,[],Y).
	lispMember(X,Y) :- send(Y,member:,[X],A), \=(A,[]).
	lispMember(X,Y,Z) :- send(Y,member:,[X],Z).
	lispAssoc(X,Y) :- send(Y,assoc:,[X],A), \=(A,[]).
	lispAssoc(X,Y,Z) :- send(Y,assoc:,[X],Z).
	lispNconc(X,Y,Z) :- send(X,nconc:,[Y],Z).
    ')!

systemPredicatesNo9
    "PrologInterpreter flushSystemPredicates."

    self systemReconsult: (ReadStream on: '
	%
	%    User System Predicates
	%
    ')! !

!PrologInterpreter methodsFor: 'public accessing'!

refute: stringOrStream
    ^self refute: stringOrStream action: [:answer | ^answer]!

refute: stringOrStream action: aBlock 
    | stream |
    (stringOrStream isKindOf: Stream)
	ifTrue: [stream := ReadStream on: stringOrStream contents]
	ifFalse: [stream := ReadStream on: stringOrStream].
    ^self consult: stream action: aBlock! !

!PrologInterpreter methodsFor: 'representation'!

collectVariables
    | dict | 
    dict := Dictionary new.
    self collectVariables: question to: dict.
    ^dict!

collectVariables: x to: dict
    | key value |  
    (x isPrologVariable and: [(x at: 1) ~= $~])
	ifTrue:
	    [key := String fromString: x printPrologString.
	    (dict at: key ifAbsent: []) ~~ nil
		ifTrue: [^self]
		ifFalse: 
		    [value := self represent: x env: questionEnv.
		    dict at: key put: value]].
    (x consp)
	ifFalse: [^self].
    self collectVariables: x car to: dict.
    self collectVariables: x cdr to: dict!

expression: x env: xEnv 
    | assoc a d |
    x isPrologVariable
	ifTrue: 
	    [assoc := self binding: x env: xEnv.
	    assoc == nil ifTrue: [^x].
	    assoc := assoc cdr.
	    ^self expression: assoc car env: assoc cdr].
    (x consp) ifFalse: [^x].
    a := self expression: x car env: xEnv.
    d := self expression: x cdr env: xEnv.
    ^x class car: a cdr: d!

represent: x env: xEnv 
    | assoc a d |
    x isPrologVariable
	ifTrue: 
	    [assoc := self binding: x env: xEnv.
	    assoc == nil ifTrue: [^self variableRepresent: x env: xEnv].
	    assoc := assoc cdr.
	    ^self represent: assoc car env: assoc cdr].
    (x consp) ifFalse: [^x].
    a := self represent: x car env: xEnv.
    d := self represent: x cdr env: xEnv.
    ^x class car: a cdr: d!

variableRepresent: x env: xEnv 
    ^PrologVariable install: x string , xEnv car printString! !

!PrologInterpreter methodsFor: 'resolution'!

resolve: goal 
    ^self resolve: goal action: nil!

resolve: goal action: actionBlock
    question := clause := goal.
    actionBlock == nil
	ifTrue: [resolveAction := [:dict | self outputVariables: dict]]
	ifFalse: [resolveAction := actionBlock].
    
    self resolveInitialize.
    self resolveLoop.
    ^self resolveTerminate!

resolveInitialize
    status := #loop.
    envCounter := 0.
    questionEnv := clauseEnv := self nullEnv.
    queue := queueEnv := valueEnv := nil.
    unbindList := cutBack := backTrack := nil.
    definitionStack := nil.
    traceCounter := 0!

resolveLoop
    | totalTime time answer |
    totalTime := 0.
    time := Time millisecondClockValue.
    [true]
	whileTrue: 
	    [status == #loop ifTrue: [self loop].
	    status == #next ifTrue: [self next].
	    status == #back ifTrue: [self back].
	    status == #succ
		ifTrue: 
		    [time := Time millisecondClockValue - time.
		    self outputTime: (totalTime := totalTime + time).
		    answer := self collectVariables.
		    answer isEmpty ifTrue: [^true].
		    (resolveAction value: answer)
			ifTrue: [^true]
			ifFalse: 
			    [status := #back.
			    time := Time millisecondClockValue]].
	    status == #fail
		ifTrue: 
		    [time := Time millisecondClockValue - time.
		    self outputTime: (totalTime := totalTime + time).
		    ^false]]!

resolveTerminate
    self deallocateEnv: questionEnv.
    status == #succ
	ifTrue: 
	    [textCollector show: 'yes'.
	    textCollector nl.
	    ^true].
    status == #fail
	ifTrue: 
	    [textCollector show: 'no'.
	    textCollector nl.
	    ^false].
    self error: 'Unexpected status'! !

!PrologInterpreter methodsFor: 'resolve modules'!

back
    | array |
    backTrack == nil
	ifTrue: 
	    [status := #fail.
	    ^self].
    array := backTrack car.
    backTrack := backTrack cdr.
    clause := array at: 1.
    clauseEnv := array at: 2.
    queue := array at: 3.
    queueEnv := array at: 4.
    cutBack := array at: 5.
    definition := array at: 6.
    array := array at: 7.
    self unbindFrom: unbindList to: array.
    unbindList := array.
    status := #next!

loop
    | structure functor |
    clause == nil
	ifTrue: 
	    [queue == nil
		ifTrue: 
		    [status := #succ.
		    ^self].
	    clause := queue car.
	    clauseEnv := queueEnv car.
	    queue := queue cdr.
	    queueEnv := queueEnv cdr.
	    cutBack := cutBack cdr.
	    status := #loop.
	    ^self].
    structure := clause car.
    structure consp
	ifFalse: 
	    [structure := PrologStructure functor: structure terms: nil.
	    clause car: structure].
    functor := structure car.
    functor isPrologVariable
	ifTrue: 
	    [self call: clause car.
	    ^self].
    functor isBuiltInPredicate
	ifTrue: 
	    [self builtInPredicate: functor.
	    ^self].
    definition := userPredicates at: functor ifAbsent: [systemPredicates at: functor
		    ifAbsent: 
			[status := #back.
			^self]].
    status := #next!

next
    | definitionEnv saveBackTrack array |
    definitionEnv := self nullEnv.
    definition cdr == nil
	ifTrue: 
	    [(self
		unify: clause car cdr
		env: clauseEnv
		and: definition car car cdr
		env: definitionEnv)
		ifFalse: 
		    [status := #back.
		    ^self].
	    queue := clause cdr cons: queue.
	    queueEnv := clauseEnv cons: queueEnv.
	    clause := definition car cdr.
	    clauseEnv := definitionEnv.
	    cutBack := backTrack cons: cutBack.
	    status := #loop.
	    ^self].
    saveBackTrack := backTrack.
    array := Array new: 7.
    array at: 1 put: clause.
    array at: 2 put: clauseEnv.
    array at: 3 put: queue.
    array at: 4 put: queueEnv.
    array at: 5 put: cutBack.
    array at: 6 put: definition cdr.
    array at: 7 put: unbindList.
    backTrack := array cons: saveBackTrack.
    (self
	unify: clause car cdr
	env: clauseEnv
	and: definition car car cdr
	env: definitionEnv)
	ifFalse: 
	    [status := #back.
	    ^self].
    queue := clause cdr cons: queue.
    queueEnv := clauseEnv cons: queueEnv.
    clause := definition car cdr.
    clauseEnv := definitionEnv.
    cutBack := saveBackTrack cons: cutBack.
    status := #loop! !

!PrologInterpreter methodsFor: 'system predicates'!

asserta: aPrologClause 
    | horn def functor |
    horn := aPrologClause.
    horn consp ifFalse: [horn := PrologStructure functor: horn terms: nil].
    horn car consp ifFalse: [horn := PrologClause head: horn body: nil].
    horn := PrologClause head: horn car body: (PrologBody fromList: horn cdr).
    functor := horn car car.
    def := userPredicates at: functor ifAbsent: [nil].
    def == nil
	ifTrue: 
	    [def := PrologDefinition fromList: (horn cons: nil).
	    userPredicates at: functor put: def]
	ifFalse: 
	    [def := PrologDefinition fromList: (horn cons: def).
	    userPredicates at: functor put: def].
    ^true!

assertz: aPrologClause 
    | horn def functor |
    horn := aPrologClause.
    horn consp ifFalse: [horn := PrologStructure functor: horn terms: nil].
    horn car consp ifFalse: [horn := PrologClause head: horn body: nil].
    horn := PrologClause head: horn car body: (PrologBody fromList: horn cdr).
    functor := horn car car.
    def := userPredicates at: functor ifAbsent: [nil].
    def == nil
	ifTrue: 
	    [def := PrologDefinition fromList: (horn cons: nil).
	    userPredicates at: functor put: def]
	ifFalse: [def nconc: (PrologDefinition fromList: (horn cons: nil))].
    ^true!

clause: aPrologClause 
    | count horn def result |
    count := 0.
    horn := aPrologClause.
    horn consp
	ifFalse: 
	    [horn := PrologStructure functor: horn terms: nil.
	    count := count + 1].
    horn car consp
	ifFalse: 
	    [horn := PrologClause head: horn body: nil.
	    count := count + 1].
    horn := PrologClause head: horn car body: (PrologBody fromList: horn cdr).
    def := definitionStack car.
    [def consp]
	whileTrue: [(self
		unify: horn
		env: self nullEnv
		and: def car
		env: self nullEnv)
		ifTrue: 
		    [result := def car.
		    count timesRepeat: [result := result car].
		    def := def cdr.
		    definitionStack car: def.
		    ^result]
		ifFalse: 
		    [def := def cdr.
		    definitionStack car: def]].
    definitionStack := definitionStack cdr.
    ^PrologSymbol cut!

clear
    textCollector clear.
    ^true!

consultFile: fileName 
    | aFileStream |
    (fileName respondsTo: #asString)
	ifFalse: [^false].
    (File name: fileName asString) exists
	ifTrue: 
	    [textCollector show: '<consult from ' , fileName asString , '>\' withCRs.
	    aFileStream := FileStream open: fileName asString mode: FileStream read.
	    self consult: aFileStream action: nil.
	    aFileStream close.
	    ^true]
	ifFalse: [^false]!

dotp: x 
    ^x consp!

double: x
    ^x isKindOf: Float!

float: x
    ^x isKindOf: Float!

fraction: x
    ^x isKindOf: Fraction!

functorArityOf: aPrologStructure 
    aPrologStructure isNil ifTrue: [^nil cons: 0].
    (self number: aPrologStructure)
	ifTrue: [^aPrologStructure cons: 0].
    (aPrologStructure respondsTo: #functor)
	ifFalse: [^nil].
    ^aPrologStructure functor cons: aPrologStructure arity!

gc
    ObjectMemory compact.
    Transcript nl; show: 'garbage collecting: '.
    ^true!

integer: x
    ^x isKindOf: Integer!

length: aPrologDotPair 
    aPrologDotPair consp ifFalse: [^0].
    ^aPrologDotPair length!

list: x 
    x == nil ifTrue: [^true].
    ^self dotp: x!

listPrint: aPrologDotPair 
    | list |
    aPrologDotPair consp ifFalse: [^false].
    list := aPrologDotPair.
    [list consp]
	whileTrue: 
	    [textCollector show: list car printPrologString , ' '.
	    list := list cdr].
    ^true!

nl
    textCollector nl.
    ^true!

nospy: aPrologSymbol 
    | def |
    def := tracePredicates at: aPrologSymbol ifAbsent: [nil].
    def == nil ifTrue: [^false].
    userPredicates at: aPrologSymbol put: def.
    tracePredicates removeKey: aPrologSymbol.
    ^true!

notrace
    userPredicates associationsDo: [:assoc | self nospy: assoc key].
    ^true!

number: x
    ^x isKindOf: Number!

reconsultFile: fileName 
    | aFileStream |
    (fileName respondsTo: #asString)
	ifFalse: [^false].
    (File name: fileName asString) exists
	ifTrue: 
	    [textCollector show: '<reconsult from ' , fileName asString , '>\' withCRs.
	    aFileStream := FileStream open: fileName asString mode: FileStream read.
	    self reconsult: aFileStream action: nil.
	    aFileStream close.
	    ^true]
	ifFalse: [^false]!

remove
    userPredicates keys do: 
	[:aPrologSymbol | 
	userPredicates removeKey: aPrologSymbol ifAbsent: [].
	tracePredicates removeKey: aPrologSymbol ifAbsent: []].
    ^true!

remove: aPrologSymbol
    userPredicates removeKey: aPrologSymbol ifAbsent: [^false].
    tracePredicates removeKey: aPrologSymbol ifAbsent: [].
    ^true!

retract: aPrologClause 
    | count horn def functor prev result |
    count := 0.
    horn := aPrologClause.
    horn consp
	ifFalse: 
	    [horn := PrologStructure functor: horn terms: nil.
	    count := count + 1].
    horn car consp
	ifFalse: 
	    [horn := PrologClause head: horn body: nil.
	    count := count + 1].
    horn := PrologClause head: horn car body: (PrologBody fromList: horn cdr).
    functor := horn car car.
    prev := def := userPredicates at: functor ifAbsent: [^PrologSymbol cut].
    [def consp]
	whileTrue: [(self
		unify: horn
		env: self nullEnv
		and: def car
		env: self nullEnv)
		ifTrue: 
		    [result := def car.
		    count timesRepeat: [result := result car].
		    prev == def
			ifTrue: 
			    [def cdr isNil
				ifTrue: [userPredicates removeKey: functor ifAbsent: [nil]]
				ifFalse: [userPredicates at: functor put: def cdr].
			    ^result]
			ifFalse: 
			    [prev cdr: def cdr.
			    ^result]]
		ifFalse: 
		    [prev := def.
		    def := def cdr]].
    ^PrologSymbol cut!

saving
    self saveOn: self saveFileName.
    ^true!

saving: aPrologSymbol 
    | def |
    def := tracePredicates at: aPrologSymbol ifAbsent: [userPredicates at: aPrologSymbol ifAbsent: []].
    def == nil ifTrue: [^false].
    self saveOn: self saveFileName.
    ^true!

spy: aPrologSymbol 
    | def reverseClone tracedef |
    def := userPredicates at: aPrologSymbol ifAbsent: [nil].
    def == nil ifTrue: [^false].
    (tracePredicates at: aPrologSymbol ifAbsent: [nil]) isNil ifFalse: [^true].
    tracePredicates at: aPrologSymbol put: def.
    reverseClone := nil.
    [def consp]
	whileTrue: 
	    [reverseClone := def car cons: reverseClone.
	    def := def cdr].
    tracedef := nil.
    [reverseClone consp]
	whileTrue: 
	    [tracedef := (self traceFailClause: reverseClone car car)
			cons: tracedef.
	    tracedef := (self traceExitClause: reverseClone car)
			cons: tracedef.
	    reverseClone cdr consp
		ifTrue: [tracedef := (self traceRedoClause: reverseClone car car)
				cons: tracedef]
		ifFalse: [tracedef := (self traceCallClause: reverseClone car car)
				cons: tracedef].
	    reverseClone := reverseClone cdr].
    userPredicates at: aPrologSymbol put: (PrologDefinition fromList: tracedef).
    ^true!

string: x
    ^x class == PrologString!

strToSym: listOrString 
    | stream string token s |
    listOrString consp
	ifTrue: 
	    [s := WriteStream on: (String new: 16).
	    listOrString do: [:char | s nextPut: (Character value: char)].
	    string := s contents]
	ifFalse: [string := listOrString string].
    stream := ReadStream on: string.
    token := (PrologScanner new on: stream) nextToken.
    ((self number: token)
	and: [stream atEnd])
	ifTrue: [^token]
	ifFalse: [string = '[]'
		ifTrue: [^nil]
		ifFalse: [^PrologSymbol install: string]]!

symbol: x
    ^x class == PrologSymbol!

symToList: numOrSym 
    | pstring |
    pstring := self symToStr: numOrSym.
    ^PrologList list: pstring string asByteArray!

symToStr: numOrSym 
    numOrSym isNil ifTrue: [^PrologString fromString: '[]'].
    (self number: numOrSym)
	ifTrue: [^PrologString fromString: numOrSym printString].
    ^PrologString fromString: numOrSym string!

systemListing
    | predicateName |
    (self associations: systemPredicates) asSortedCollection
	do: 
	    [:assoc | 
	    predicateName := assoc key.
	    ((predicateName respondsTo: #asString)
		and: [predicateName string isEmpty not and: [predicateName string first = $~]])
		ifFalse: [self systemListing: predicateName]].
    ^true!

systemListing: aPrologSymbol
    | def |
    def := systemPredicates at: aPrologSymbol ifAbsent: [nil].
    def == nil ifTrue: [^false].
    [def consp]
	    whileTrue: 
		[textCollector show: def car prettyPrintPrologString , '\' withCRs.
		def := def cdr].
    ^true!

systemPredicates
    | collection list |
    collection := (self associations: systemPredicates) asSortedCollection.
    list := nil.
    collection reverseDo: [:each | ((each key respondsTo: #asString)
	    and: [each key string isEmpty not and: [each key string first = $~]])
	    ifTrue: ['not adding: invisible predicate' yourself]
	    ifFalse: [list := each key cons: list]].
    ^list!

tab: aNumber 
    | spaces |
    (aNumber isKindOf: Number)
	ifFalse: [^false].
    spaces := String new.
    aNumber asInteger timesRepeat: [spaces := spaces , ' '].
    textCollector show: spaces.
    ^true!

trace
    userPredicates associationsDo: [:assoc | self spy: assoc key].
    ^true!

univ: aPrologList 
    | termv listv termValue termEnv listVal listEnv functor functorEnv terms newterms newStruct car t list |
    termv := PrologVariable install: aPrologList car string.
    listv := PrologVariable install: aPrologList cdr string.
    termValue := self fetchValue: termv env: clauseEnv.
    termEnv := valueEnv.
    listVal := self fetchValue: listv env: clauseEnv.
    listEnv := valueEnv.
    termValue isPrologVariable
	ifTrue: 
	    ["construct a term from fixed length list."
	    listVal isPrologVariable ifTrue: [^false].
	    listVal consp ifFalse: [^false].
	    functor := self fetchValue: listVal car env: listEnv.
	    functorEnv := valueEnv.
	    terms := self fetchValue: listVal cdr env: listEnv.
	    listEnv := valueEnv.
	    (self number: functor)
		ifTrue: 
		    [terms isNil ifFalse: [^false].
		    self
			bind: termValue
			env: termEnv
			and: functor
			env: listEnv.
		    ^true].
	    functor consp ifTrue: ["It's a structure or a list"
		^false].
	    terms isNil
		ifTrue: 
		    [self
			bind: termValue
			env: termEnv
			and: functor
			env: functorEnv.
		    ^true].
	    terms consp ifFalse: ["Not a list, but an illegal dot pair."
		^false].
	    newterms := nil.
	    [terms isNil]
		whileFalse: 
		    [car := terms car.
		    terms := self fetchValue: terms cdr env: listEnv.
		    terms isPrologVariable ifTrue: ["The length of the list has not been fixed yet."
			^false].
		    t := PrologTerms car: car cdr: nil.
		    newterms isNil
			ifTrue: [newterms := t]
			ifFalse: [newterms := newterms nconc: t]].
	    newStruct := PrologStructure functor: functor terms: newterms.
	    ^self
		unify: termValue
		env: termEnv
		and: newStruct
		env: listEnv]
	ifFalse: 
	    ["disasemble a term into a list"
	    termValue consp
		ifTrue: ["It's a list or a structure."
		    list := termValue structureList]
		ifFalse: ["primitive data like symbol, number, nil, or string."
		    list := termValue cons: nil].
	    ^self
		unify: list
		env: termEnv
		and: listVal
		env: listEnv]!

userListing
    | predicateName |
    ((self associations: userPredicates) asSortedCollection)
	do: 
	    [:assoc | 
	    predicateName := assoc key.
	    self userListing: predicateName].
    ^true!

userListing: aPrologSymbol 
    | def |
    def := userPredicates at: aPrologSymbol ifAbsent: [nil].
    def == nil ifTrue: [^false].
    [def consp]
	whileTrue: 
	    [textCollector show: def car prettyPrintPrologString , '\' withCRs.
	    def := def cdr].
    ^true!

userPredicates
    | collection list |
    collection := (self associations: userPredicates) asSortedCollection.
    list := nil.
    collection reverseDo: [:each | ((each key respondsTo: #string)
	    and: [each key string isEmpty not and: [each key string first = $~]])
	    ifTrue: ['not adding: invisible predicate' yourself]
	    ifFalse: [list := each key cons: list]].
    ^list!

verbose: aPrologSymbol 
    aPrologSymbol isPrologTrue
	ifTrue: [verbose := true]
	ifFalse: [verbose := false].
    ^true!

write: anObject 
    (anObject respondsTo: #asString)
	ifTrue: [textCollector show: anObject asString]
	ifFalse: [textCollector show: anObject printPrologString].
    ^true! !

!PrologInterpreter methodsFor: 'system support'!

clauseSet: aPrologClause 
    | horn functor def |
    horn := aPrologClause.
    horn consp ifFalse: [horn := PrologStructure functor: horn terms: nil].
    horn car consp ifFalse: [horn := PrologClause head: horn body: nil].
    horn := PrologClause head: horn car body: (PrologBody fromList: horn cdr).
    functor := horn car car.
    def := userPredicates at: functor ifAbsent: [^false].
    definitionStack := def cons: definitionStack.
    ^true!

consult: readStream action: aBlock
    | condition parser node hornClause program functor stream result |
    condition := self getCondition.
    parser := PrologParser new.
    result := true.
    [node := parser parse: readStream.
    node == #eof]
	whileFalse: 
	    [hornClause := node.
	    node isResolveClause
		ifTrue: 
		    [stream := WriteStream on: (String new: 20).
		    hornClause printPrologOn: stream.
		    textCollector show: stream contents.
		    textCollector nl.
		    result := self resolve: hornClause action: aBlock]
		ifFalse: 
		    [functor := hornClause car car.
		    program := tracePredicates at: functor ifAbsent: [userPredicates at: functor ifAbsent: []].
		    program == nil
			ifTrue: 
			    [program := PrologDefinition fromList: (hornClause cons: nil).
			    userPredicates at: functor put: program]
			ifFalse: [program nconc: (hornClause cons: nil)]]].
    self putCondition: condition.
    ^result!

reconsult: readStream action: aBlock
    | condition newPredicates parser node hornClause program functor stream result |
    condition := self getCondition.
    newPredicates := Dictionary new.
    parser := PrologParser new.
    result := true.
    [node := parser parse: readStream.
    node == #eof]
	whileFalse: 
	    [hornClause := node.
	    node isResolveClause
		ifTrue: 
		    [stream := WriteStream on: (String new: 20).
		    hornClause printPrologOn: stream.
		    textCollector show: stream contents.
		    textCollector nl.
		    result := self resolve: hornClause action: aBlock]
		ifFalse: 
		    [functor := hornClause car car.
		    program := newPredicates at: functor ifAbsent: [].
		    program == nil
			ifTrue: 
			    [program := PrologDefinition fromList: (hornClause cons: nil).
			    newPredicates at: functor put: program]
			ifFalse: [program nconc: (hornClause cons: nil)].
		    userPredicates at: functor put: program]].
    newPredicates keys
	do: [:eachPredicate |
	    userPredicates at: eachPredicate put: (newPredicates at: eachPredicate).
	    tracePredicates removeKey: eachPredicate ifAbsent: []].
    self putCondition: condition.
    ^result!

saveFileName
    ^'prolog.db'!

saveOn: fileName 
    | aFileStream def |
    aFileStream := FileStream open: fileName asString mode: FileStream write.
    (self associations: userPredicates) asSortedCollection
	do: 
	    [:assoc | 
	    def := assoc value.
	    [def consp]
		whileTrue: 
		    [aFileStream nextPutAll: def car prettyPrintPrologString , '\' withCRs.
		    def := def cdr]].
    aFileStream close!

saveOn: fileName predicateName: aPrologSymbol 
    | aFileStream def |
    aFileStream := FileStream open: fileName asString mode: FileStream write.
    def := userPredicates at: aPrologSymbol ifAbsent: [].
    def == nil ifFalse: [[def consp]
	    whileTrue: 
		[aFileStream nextPutAll: def car prettyPrintPrologString , '\' withCRs.
		def := def cdr]].
    aFileStream close!

systemConsult: readStream 
    | condition parser node hornClause program functor |
    condition := self getCondition.
    parser := PrologParser new.
    [node := parser parse: readStream.
    node == #eof]
	whileFalse: 
	    [hornClause := node.
	    node isResolveClause
		ifTrue: [self resolve: hornClause]
		ifFalse: 
		    [functor := hornClause car car.
		    program := systemPredicates at: functor ifAbsent: [].
		    program == nil
			ifTrue: 
			    [program := PrologDefinition fromList: (hornClause cons: nil).
			    systemPredicates at: functor put: program]
			ifFalse: [program nconc: (hornClause cons: nil)]]].
    self putCondition: condition.
    ^true!

systemReconsult: readStream 
    | condition newPredicates parser node hornClause program functor |
    condition := self getCondition.
    newPredicates := Dictionary new.
    parser := PrologParser new.
    [node := parser parse: readStream.
    node == #eof]
	whileFalse: 
	    [hornClause := node.
	    node isResolveClause
		ifTrue: [self resolve: hornClause]
		ifFalse: 
		    [functor := hornClause car car.
		    program := newPredicates at: functor ifAbsent: [].
		    program == nil
			ifTrue: 
			    [program := PrologDefinition fromList: (hornClause cons: nil).
			    newPredicates at: functor put: program]
			ifFalse: [program nconc: (hornClause cons: nil)].
		    systemPredicates at: functor put: program]].
    newPredicates keys do: [:eachPredicate | systemPredicates at: eachPredicate put: (newPredicates at: eachPredicate)].
    self putCondition: condition.
    ^true!

trace: para head: head arguments: terms 
    | headString numberString structure arguString |
    headString := (self expression: head env: clauseEnv) printPrologString.
    para = 0
	ifTrue: 
	    [traceCounter := traceCounter + 1.
	    numberString := String new: traceCounter withAll: $|.
	    structure := PrologStructure functor: head car terms: terms.
	    arguString := (self expression: structure env: clauseEnv) printPrologString.
	    headString := headString , ' ~ ' , arguString.
	    textCollector show: numberString , ' CALL : ' , headString , '\' withCRs.
	    ^self].
    para = 1
	ifTrue: 
	    [traceCounter := traceCounter + 1.
	    numberString := String new: traceCounter withAll: $|.
	    structure := PrologStructure functor: head car terms: terms.
	    arguString := (self expression: structure env: clauseEnv) printPrologString.
	    headString := headString , ' ~ ' , arguString.
	    textCollector show: numberString , ' REDO : ' , headString , '\' withCRs.
	    ^self].
    para = 2
	ifTrue: 
	    [numberString := String new: traceCounter withAll: $|.
	    textCollector show: numberString , ' FAIL : ' , headString , '\' withCRs.
	    traceCounter := traceCounter - 1.
	    ^self].
    para = 3
	ifTrue: 
	    [numberString := String new: traceCounter withAll: $|.
	    textCollector show: numberString , ' EXIT : ' , headString , '\' withCRs.
	    ^self]!

traceCallClause: head
    ^self traceClause: head flag: 0!

traceClause: head flag: anInteger 
    | arguVar headStruct failStruct traceStruct |
    arguVar := PrologVariable install: 'Arguments'.
    headStruct := PrologStructure functor: head car terms: arguVar.
    failStruct := PrologStructure functor: (PrologSymbol install: 'fail')
		terms: nil.
    traceStruct := arguVar cons: nil.
    traceStruct := head cons: traceStruct.
    traceStruct := anInteger cons: traceStruct.
    traceStruct := traceStruct cons: nil.
    traceStruct := (PrologSymbol install: 'trace:head:arguments:')
		cons: traceStruct.
    traceStruct := (PrologSymbol install: 'self')
		cons: traceStruct.
    traceStruct := PrologTerms fromList: traceStruct.
    traceStruct := PrologStructure functor: (PrologSymbol install: 'send')
		terms: traceStruct.
    anInteger = 3 ifTrue: [^PrologClause head: headStruct body: (PrologBody fromList: (traceStruct cons: nil))].
    ^PrologClause head: headStruct body: (PrologBody fromList: (traceStruct cons: (failStruct cons: nil)))!

traceExitClause: exitClause
    | traceExitClause reverseClone| 
    traceExitClause := self traceExitClauseAux: exitClause car.
    traceExitClause := traceExitClause cdr.
    reverseClone := exitClause reverse.
    [reverseClone consp]
	whileTrue:
	    [traceExitClause := reverseClone car cons: traceExitClause.
	    reverseClone := reverseClone cdr].
    ^PrologClause head: traceExitClause car body: (PrologBody fromList: traceExitClause cdr)!

traceExitClauseAux: head
    ^self traceClause: head flag: 3!

traceFailClause: head
    ^self traceClause: head flag: 2!

traceRedoClause: head
    ^self traceClause: head flag: 1! !

!PrologInterpreter methodsFor: 'unification'!

unify: x env: xEnv and: y env: yEnv 
    | xx yy assoc |
    xx := x.
    yy := y.
    [true]
	whileTrue: 
	    [xEnv == yEnv ifTrue: [x = y ifTrue: [^true]].
	    xx isPrologVariable ifTrue: [(assoc := self binding: xx env: xEnv) ~~ nil
		    ifTrue: 
			[valueEnv := xEnv.
			assoc := assoc cdr.
			xx := self fetchValue: assoc car env: assoc cdr.
			^self
			    unify: xx
			    env: valueEnv
			    and: yy
			    env: yEnv]
		    ifFalse: 
			[yy isPrologVariable ifTrue: [(assoc := self binding: yy env: yEnv) ~~ nil
				ifTrue: 
				    [valueEnv := yEnv.
				    assoc := assoc cdr.
				    yy := self fetchValue: assoc car env: assoc cdr.
				    ^self
					unify: xx
					env: xEnv
					and: yy
					env: valueEnv]].
			self
			    bind: xx
			    env: xEnv
			    and: yy
			    env: yEnv.
			^true]].
	    yy isPrologVariable
		ifTrue: 
		    [(assoc := self binding: yy env: yEnv) ~~ nil
			ifTrue: 
			    [valueEnv := yEnv.
			    assoc := assoc cdr.
			    yy := self fetchValue: assoc car env: assoc cdr.
			    ^self
				unify: xx
				env: xEnv
				and: yy
				env: valueEnv].
		    self
			bind: yy
			env: yEnv
			and: xx
			env: xEnv.
		    ^true].
	    xx consp ifFalse: [^xx = yy].
	    yy consp ifFalse: [^yy = xx].
	    (self
		unify: xx car
		env: xEnv
		and: yy car
		env: yEnv)
		ifFalse: [^false].
	    xx := xx cdr.
	    yy := yy cdr]! !



