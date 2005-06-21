"======================================================================
|
|   Lisp interpreter written in Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Written by Aoki Atsushi and Nishihara Satoshi.
| Modified by Paolo Bonzini (removed GUI and compiler for subset of Smalltalk).
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

SequenceableCollection subclass:  #LispList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Lisp'!

LispList subclass:  #LispCons
	instanceVariableNames: 'head tail '
	classVariableNames: 'VerticalLevel HorizontalLevel '
	poolDictionaries: ''
	category: 'Examples-Lisp'!

LispList subclass:  #LispNil
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Lisp'!

Object subclass:  #LispScanner
	instanceVariableNames: 'source mark token tokenType failBlock '
	classVariableNames: 'ScanningTable '
	poolDictionaries: ''
	category: 'Examples-Lisp'!

LispScanner subclass:  #LispParser
	instanceVariableNames: 'prevMark prevToken prevTokenType '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Lisp'!

Object subclass:  #LispTable
	instanceVariableNames: 'properties '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Lisp'!

Object subclass:  #LispInterpreter
	instanceVariableNames: 'lispTable bindStack failBlock textValue textCollector '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Lisp'!



!LispList class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispList class methodsFor: 'instance creation'!

cell
    ^self subclassResponsibility!

head: headObject 
    ^self subclassResponsibility!

head: headObject tail: tailObject 
    ^self subclassResponsibility!

list: anArray 
    "LispCons list: #(1 2 3 4)"

    | size list |
    size := anArray size.
    list := self null.
    size
	to: 1
	by: -1
	do: [:i | list := self head: (anArray at: i)
			tail: list].
    ^list!

new: anInteger 
    "LispCons new: 5"

    | newList |
    newList := self null.
    anInteger timesRepeat: [newList := self head: self null tail: newList].
    ^newList!

null
    ^self subclassResponsibility!

with: anObject 
    "LispCons with: 1"

    ^self head: anObject!

with: firstObject with: secondObject 
    "LispCons with: 1 with: 2"

    ^self head: firstObject tail: (self with: secondObject)!

with: firstObject with: secondObject with: thirdObject 
    "LispCons with: 1 with: 2 with: 3"

    ^self head: firstObject tail: (self with: secondObject with: thirdObject)!

with: firstObject with: secondObject with: thirdObject with: fourthObject 
    "LispCons with: 1 with: 2 with: 3 with: 4"

    ^self head: firstObject tail: (self
	    with: secondObject
	    with: thirdObject
	    with: fourthObject)! !

!LispList methodsFor: 'accessing'!

at: indexInteger put: anObject 
    ^self subscriptOutOfBoundsError: indexInteger!

size
    | tally |
    tally := 0.
    self do: [:each | tally := tally + 1].
    ^tally! !

!LispList methodsFor: 'private'!

subscriptOutOfBoundsError: index 
    ^self error: 'subscript out of bounds: ' , index printString! !

!LispList methodsFor: 'testing'!

isCons
    ^self null not!

null
    ^false! !



!LispCons class methodsFor: 'class initialization'!

initialize
    "LispCons initialize."

    HorizontalLevel := VerticalLevel := nil! !

!LispCons class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispCons class methodsFor: 'examples'!

example1
    "LispCons example1."

    | list |
    list := LispCons list: #(1 2 3 4 5 6 7 8 9 10 ).
    Transcript nl; show: list printString.
    ^list!

example2
    "LispCons example2."

    | null list |
    null := LispCons null.
    list := LispCons list: #(1 2 ).
    list := LispCons head: list tail: null.
    list := LispCons head: list tail: null.
    Transcript nl; show: list printString.
    ^list!

example3
    "LispCons example3."

    | x y z |
    x := LispCons list: #(1 2 3 ).
    y := LispCons list: #(4 5 6 ).
    z := LispCons list: #(1 2 3 4 5 6 ).
    Transcript nl; show: '(setq x ''(1 2 3)) => ' , x printString.
    Transcript nl; show: '(setq y ''(4 5 6)) => ' , y printString.
    Transcript nl; show: '(setq z ''(1 2 3 4 5 6)) => ' , z printString.
    Transcript nl; show: '(append x y) => ' , (x append: y) printString.
    Transcript nl; show: '(length z) => ' , z length printString.
    Transcript nl; show: '(member 3 z) => ' , (z member: 3) printString.
    Transcript nl; show: '(nth 4 z) => ' , (z nth: 4) printString.
    ^z!

example4
    "LispCons example4."

    | list |
    list := LispCons list: #(1 2 ).
    list := LispCons head: list tail: (LispCons list: #(3 4 )).
    list := LispCons head: list tail: (LispCons list: #(5 6 )).
    Transcript nl; show: list saveString.
    ^list!

example5
    "LispCons example5."

    | list |
    list := LispCons loadFrom: '
	    (PetriNet Aoki
		(Place p1 p2 p3 p4 p5)
		(Transition t1 t2 t3 t4 t5)
		(InputFunction
		    (t1 p1 p2 p3 p4 p5)
		    (t2 . p4)
		    (t3 . p5))
		(OutputFunction
		    (t1 p1 p2 p3 p4 p5)
		    (t2 . p4)
		    (t3 . p5))
		(Marking {#(1 2 3 4 5)})))'.
    Transcript nl; show: list saveString.
    ^list!

example6
    "LispCons example6."

    | list |
    list := LispCons loadFrom: '(aaa bbb ccc)'.
    Transcript nl; show: list saveString.
    ^list!

example7
    "LispCons example7."

    | list |
    list := LispCons loadFrom: ' `(`(1 2 `3) . `4 ) '.
    Transcript nl; show: list saveString.
    ^list! !

!LispCons class methodsFor: 'instance creation'!

cell
    ^super new head: self null tail: self null!

head: headObject 
    ^super new head: headObject tail: self null!

head: headObject tail: tailObject 
    ^super new head: headObject tail: tailObject!

list: anArray 
    | size list |
    size := anArray size.
    list := self null.
    size
	to: 1
	by: -1
	do: [:i | list := self head: (anArray at: i)
			tail: list].
    ^list!

loadFrom: aStream 
    "by nishis, 1998/04/19 07:51"

    | list |
    list := LispParser parse: aStream.
    ^list!

new
    ^self cell!

null
    ^LispNil null! !

!LispCons class methodsFor: 'level accessing'!

horizontalLevel
    HorizontalLevel isNil ifTrue: [HorizontalLevel := 50].
    ^HorizontalLevel!

horizontalLevel: anInteger 
    HorizontalLevel := anInteger!

verticalLevel
    VerticalLevel isNil ifTrue: [VerticalLevel := 10].
    ^VerticalLevel!

verticalLevel: anInteger 
    VerticalLevel := anInteger! !

!LispCons class methodsFor: 'utilities'!

classHierarchy: aClass 
    "LispCons classHierarchy: Number."

    | theClass list |
    aClass isMeta
	ifTrue: [theClass := aClass soleInstance]
	ifFalse: [theClass := aClass].
    list := self subclassHierarchy: theClass.
    (theClass allSuperclasses select: [:each | each isMeta not])
	do: [:each | list := self head: each name tail: (self head: list tail: self null)].
    ^list!

subclassHierarchy: aClass 
    "LispCons subclassHierarchy: Number."

    | theClass list collection sub |
    aClass isMeta
	ifTrue: [theClass := aClass soleInstance]
	ifFalse: [theClass := aClass].
    list := self null.
    theClass subclasses isEmpty
	ifFalse: 
	    [collection := SortedCollection sortBlock: [:x :y | x name > y name].
	    collection addAll: (theClass subclasses select: [:each | each isMeta not]).
	    collection
		do: 
		    [:each | 
		    sub := self subclassHierarchy: each.
		    list := self head: sub tail: list]].
    ^self head: theClass name tail: list!

superclassHierarchy: aClass 
    "LispCons superclassHierarchy: Number."

    | theClass list |
    aClass isMeta
	ifTrue: [theClass := aClass soleInstance]
	ifFalse: [theClass := aClass].
    list := self head: theClass name tail: self null.
    (theClass allSuperclasses select: [:each | each isMeta not])
	do: [:each | list := self head: each name tail: (self head: list tail: self null)].
    ^list! !

!LispCons methodsFor: 'accessing'!

at: indexInteger
    | count |
    count := 1.
    self
	mapcdr: 
	    [:cdr | 
	    indexInteger = count ifTrue: [^cdr head].
	    count := count + 1].
    ^self subscriptOutOfBoundsError: indexInteger!

at: indexInteger put: anObject 
    | count |
    count := 1.
    self
	mapcdr: 
	    [:cdr | 
	    indexInteger = count ifTrue: [^cdr head: anObject].
	    count := count + 1].
    ^self subscriptOutOfBoundsError: indexInteger!

head
    ^head!

head: anObject 
    ^head := anObject!

head: headObject tail: tailObject 
    self head: headObject.
    self tail: tailObject!

tail
    ^tail!

tail: anObject 
    ^tail := anObject! !

!LispCons methodsFor: 'adding'!

add: newObject 
    ^self nconc: (self class head: newObject tail: self class null)! !

!LispCons methodsFor: 'enumerating'!

collect: aBlock 
    | list result |
    list := self.
    result := self class null.
    [list isKindOf: self class]
	whileTrue: 
	    [result := self class head: (aBlock value: list head)
			tail: result.
	    list := list tail].
    ^result reverse!

do: aBlock 
    | list |
    list := self.
    [list isKindOf: self class]
	whileTrue: 
	    [aBlock value: list head.
	    list := list tail]! !

!LispCons methodsFor: 'functions'!

append: list 
    (tail isKindOf: self class)
	ifFalse: [^self class head: head tail: list].
    ^self class head: head tail: (tail append: list)!

last
    | list |
    list := self class head: nil tail: self.
    self do: [:each | list := list tail].
    ^list!

length
    | count |
    count := 0.
    self do: [:each | count := count + 1].
    ^count!

mapcdr: aBlock 
    | list |
    list := self.
    [list isKindOf: self class]
	whileTrue: 
	    [aBlock value: list.
	    list := list tail]!

member: anObject 
    | list |
    list := self.
    self do: 
	[:each | 
	each = anObject ifTrue: [^list].
	list := list tail].
    ^self species null!

memq: anObject 
    | list |
    list := self.
    self do: 
	[:each | 
	each == anObject ifTrue: [^list].
	list := list tail].
    ^self species null!

nconc: list 
    self last rplacd: list!

nth: nth 
    | count list |
    nth <= 0 ifTrue: [^self species null].
    count := 1.
    list := self.
    list do: 
	[:each | 
	count >= nth ifTrue: [^each].
	count := count + 1].
    ^self species null!

reverse
    | list |
    list := self class null.
    self do: [:each | list := self class head: each tail: list].
    ^list!

rplaca: anObject 
    self head: anObject!

rplacd: anObject 
    self tail: anObject! !

!LispCons methodsFor: 'pretty printing'!

ppOn: aStream 
    self
	ppOn: aStream
	list: self
	position: 0.
    aStream nl!

ppOn: aStream list: list position: position 
    (list isKindOf: self class)
	ifFalse: [^self ppOn: aStream object: list].
    (list head isKindOf: self class) not
	ifTrue: 
	    [aStream nextPutAll: '('.
	    self ppOn: aStream object: list head.
	    (list tail isKindOf: LispList)
		ifTrue: [self
			ppOn: aStream
			tail: list tail
			position: position + 1]
		ifFalse: 
		    [aStream nextPutAll: ' . '.
		    self ppOn: aStream object: list tail].
	    aStream nextPutAll: ')']
	ifFalse: 
	    [aStream nextPutAll: '('.
	    self
		ppOn: aStream
		list: list head
		position: position + 1.
	    (list tail isKindOf: self class)
		ifTrue: [(list tail head isKindOf: self class)
			ifTrue: 
			    [aStream nl.
			    self ppOn: aStream spaceAndTab: position.
			    self
				ppOn: aStream
				tail: list tail
				position: position]
			ifFalse: 
			    [self ppOn: aStream space: 1.
			    self
				ppOn: aStream
				tail: list tail
				position: position + 1]]
		ifFalse: [(list tail isKindOf: LispList)
			ifFalse: 
			    [aStream nextPutAll: ' . '.
			    self ppOn: aStream object: list tail]].
	    aStream nextPutAll: ')']!

ppOn: aStream object: anObject 
    (anObject isKindOf: Symbol)
	ifTrue: [^aStream nextPutAll: anObject asString].
    (anObject isKindOf: String)
	ifTrue: 
	    [aStream nextPutAll: '"'.
	    anObject
		do: 
		    [:char | 
		    char = $" ifTrue: [aStream nextPut: $"].
		    aStream nextPut: char].
	    ^aStream nextPutAll: '"'].
    (anObject isKindOf: Number)
	ifTrue: [^anObject storeOn: aStream].
    (anObject isMemberOf: LispNil)
	ifTrue: [^aStream nextPutAll: 'nil'].
    aStream nextPutAll: '{'.
    aStream nextPutAll: (anObject printString contractTo: 80).
    aStream nextPutAll: '}'!

ppOn: aStream space: anInteger 
    anInteger timesRepeat: [aStream nextPut: Character space]!

ppOn: aStream spaceAndTab: anInteger 
    | tabs spaces |
    tabs := anInteger // self tabStop.
    spaces := anInteger \\ self tabStop.
    tabs * (self tabStop // 4) timesRepeat: [aStream tab].
    spaces timesRepeat: [aStream space]!

ppOn: aStream tail: list position: position 
    list null ifTrue: [^self].
    (list tail isKindOf: LispList)
	ifTrue: [list tail null
		ifTrue: 
		    [self ppOn: aStream space: 1.
		    self
			ppOn: aStream
			list: list head
			position: position + 1]
		ifFalse: 
		    [self ppOn: aStream space: 1.
		    self
			ppOn: aStream
			list: list head
			position: position + 1.
		    aStream nl.
		    self ppOn: aStream spaceAndTab: position.
		    self
			ppOn: aStream
			tail: list tail
			position: position]]
	ifFalse: 
	    [self ppOn: aStream space: 1.
	    self
		ppOn: aStream
		list: list head
		position: position + 1.
	    aStream nextPutAll: ' . '.
	    self ppOn: aStream object: list tail]!

ppString
    | stream |
    stream := WriteStream on: (String new: 20).
    self ppOn: stream.
    ^stream contents! !

!LispCons methodsFor: 'printing'!

printOn: aStream 
    self printOn: aStream level: 0!

printOn: aStream level: level 
    | verticalLevel |
    verticalLevel := self class verticalLevel.
    (verticalLevel ~= 0 and: [level >= verticalLevel])
	ifTrue: 
	    [aStream nextPutAll: '( ... )'.
	    ^self].
    self null ifTrue: [^super printOn: aStream].
    aStream nextPutAll: '('.
    (head isKindOf: self class)
	ifTrue: [head printOn: aStream level: level + 1]
	ifFalse: [self printOn: aStream object: head].
    (tail isKindOf: LispList)
	ifTrue: [self
		printOn: aStream
		tail: tail
		level: level]
	ifFalse: 
	    [aStream nextPutAll: ' . '.
	    self printOn: aStream object: tail.
	    ^aStream nextPutAll: ')']!

printOn: aStream object: anObject 
    (anObject isKindOf: Symbol)
	ifTrue: [^aStream nextPutAll: anObject asString].
    (anObject isKindOf: String)
	ifTrue: 
	    [aStream nextPutAll: '"'.
	    anObject
		do: 
		    [:char | 
		    char = $" ifTrue: [aStream nextPut: $"].
		    aStream nextPut: char].
	    ^aStream nextPutAll: '"'].
    (anObject isKindOf: Number)
	ifTrue: [^anObject storeOn: aStream].
    (anObject isMemberOf: LispNil)
	ifTrue: [^aStream nextPutAll: 'nil'].
    aStream nextPutAll: '{'.
    aStream nextPutAll: (anObject printString contractTo: 80).
    aStream nextPutAll: '}'!

printOn: aStream tail: cdr level: level 
    | tailPart count horizontalLevel |
    cdr null ifTrue: [^aStream nextPutAll: ')'].
    tailPart := cdr.
    count := 1.
    horizontalLevel := self class horizontalLevel.
    tailPart do: 
	[:each | 
	(horizontalLevel ~= 0 and: [count >= horizontalLevel])
	    ifTrue: 
		[aStream nextPutAll: ' ... )'.
		^self].
	aStream nextPutAll: ' '.
	(each isKindOf: self class)
	    ifTrue: [tailPart head printOn: aStream level: level + 1]
	    ifFalse: [self printOn: aStream object: each].
	tailPart := tailPart tail.
	count := count + 1].
    (tailPart isKindOf: LispList)
	ifTrue: [aStream nextPutAll: ')']
	ifFalse: 
	    [aStream nextPutAll: ' . '.
	    self printOn: aStream object: tailPart.
	    aStream nextPutAll: ')']! !

!LispCons methodsFor: 'private'!

tabStop
    ^8! !

!LispCons methodsFor: 'saving'!

saveOn: aStream 
    self
	saveOn: aStream
	list: self
	position: 0.
    aStream nl!

saveOn: aStream list: list position: position 
    | location length |
    (list isKindOf: self class)
	ifFalse: [^self saveOn: aStream object: list].
    (list head isKindOf: self class) not
	ifTrue: 
	    [aStream nextPutAll: '('.
	    location := aStream position.
	    self saveOn: aStream object: list head.
	    (list tail isKindOf: LispList)
		ifTrue: 
		    [length := aStream position - location min: 40.
		    length := 0.
		    self
			saveOn: aStream
			tail: list tail
			position: position + 1 + length]
		ifFalse: 
		    [aStream nextPutAll: ' . '.
		    self saveOn: aStream object: list tail].
	    aStream nextPutAll: ')']
	ifFalse: 
	    [aStream nextPutAll: '('.
	    self
		saveOn: aStream
		list: list head
		position: position + 1.
	    (list tail isKindOf: self class)
		ifTrue: [(list tail head isKindOf: self class)
			ifTrue: 
			    [aStream nl.
			    self saveOn: aStream spaceAndTab: position.
			    self
				saveOn: aStream
				tail: list tail
				position: position]
			ifFalse: 
			    [self saveOn: aStream space: 1.
			    self
				saveOn: aStream
				tail: list tail
				position: position + 1]]
		ifFalse: [(list tail isKindOf: LispList)
			ifFalse: 
			    [aStream nextPutAll: ' . '.
			    self saveOn: aStream object: list tail]].
	    aStream nextPutAll: ')']!

saveOn: aStream object: anObject 
    | string |
    (anObject isKindOf: Symbol)
	ifTrue: [^aStream nextPutAll: anObject asString].
    (anObject isKindOf: String)
	ifTrue: 
	    [aStream nextPutAll: '"'.
	    anObject
		do: 
		    [:char | 
		    char = $" ifTrue: [aStream nextPut: $"].
		    aStream nextPut: char].
	    ^aStream nextPutAll: '"'].
    (anObject isKindOf: Integer)
	ifTrue: [^anObject storeOn: aStream].
    (anObject isKindOf: Float)
	ifTrue: [^anObject storeOn: aStream].
    "(anObject isKindOf: Double)
	ifTrue: [^anObject storeOn: aStream]."
    (anObject isMemberOf: LispNil)
	ifTrue: [^aStream nextPutAll: 'nil'].
    aStream nextPutAll: '{'.
    ((anObject isKindOf: Point)
	or: [anObject isKindOf: Rectangle])
	ifTrue: [string := anObject printString]
	ifFalse: [string := anObject storeString].
    aStream nextPutAll: string.
    aStream nextPutAll: '}'!

saveOn: aStream space: anInteger 
    anInteger timesRepeat: [aStream nextPut: Character space]!

saveOn: aStream spaceAndTab: anInteger 
    | tabs spaces |
    tabs := anInteger // self tabStop.
    spaces := anInteger \\ self tabStop.
    tabs timesRepeat: [aStream tab].
    spaces timesRepeat: [aStream space]!

saveOn: aStream tail: list position: position 
    list null ifTrue: [^self].
    (list tail isKindOf: LispList)
	ifTrue: [list tail null
		ifTrue: 
		    [self saveOn: aStream space: 1.
		    self
			saveOn: aStream
			list: list head
			position: position + 1]
		ifFalse: 
		    [self saveOn: aStream space: 1.
		    self
			saveOn: aStream
			list: list head
			position: position + 1.
		    aStream nl.
		    self saveOn: aStream spaceAndTab: position.
		    self
			saveOn: aStream
			tail: list tail
			position: position]]
	ifFalse: 
	    [self saveOn: aStream space: 1.
	    self
		saveOn: aStream
		list: list head
		position: position + 1.
	    aStream nextPutAll: ' . '.
	    self saveOn: aStream object: list tail]!

saveString
    | stream |
    stream := WriteStream on: (String new: 20).
    self saveOn: stream.
    ^stream contents! !

!LispCons methodsFor: 'testing'!

= anObject 
    (anObject isKindOf: self class)
	ifFalse: [^false].
    self head = anObject head ifTrue: [^self tail = anObject tail].
    ^false! !


LispCons initialize!

LispNil class instanceVariableNames: 'null '!

!LispNil class methodsFor: 'class initialization'!

initialize
    "LispNil initialize."

    self null! !

!LispNil class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispNil class methodsFor: 'instance creation'!

cell
    ^LispCons cell!

head: headObject 
    ^self shouldNotImplement!

head: headObject tail: tailObject 
    ^self shouldNotImplement!

new
    ^self null!

null
    null isNil ifTrue: [null := super new].
    ^null! !

!LispNil methodsFor: 'accessing'!

head
    ^self!

tail
    ^self! !

!LispNil methodsFor: 'adding'!

add: newObject 
    ^self shouldNotImplement! !

!LispNil methodsFor: 'enumerating'!

do: aBlock 
    ^self! !

!LispNil methodsFor: 'functions'!

append: list 
    ^list!

length
    ^0!

mapcdr: aBlock 
    ^self!

member: anObject 
    ^self!

nconc: list 
    ^list!

nth: nth 
    ^self!

reverse
    ^self! !

!LispNil methodsFor: 'pretty printing'!

ppOn: aStream 
    aStream nextPutAll: 'nil'.
    aStream nl!

ppString
    ^'nil\' withCRs! !

!LispNil methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'nil'! !

!LispNil methodsFor: 'saving'!

saveOn: aStream 
    aStream nextPutAll: 'nil'!

saveString
    ^'nil'! !

!LispNil methodsFor: 'testing'!

null
    ^true! !


LispNil initialize!

!LispScanner class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispScanner class methodsFor: 'initialize-release'!

initialize
    | newTable |
    newTable := Array new: 256 withAll: #xBinary.
    newTable atAll: #(9 10 11 12 13 32) put: #xDelimiter.
    newTable atAll: ($0 asInteger to: $9 asInteger) put: #xDigit.
    newTable atAll: ($A asInteger to: $Z asInteger) put: #xSymbol.
    newTable atAll: ($a asInteger to: $z asInteger) put: #xSymbol.
    128 to: 256 do: [:i | newTable at: i put: #xSymbol].
    newTable at: $' asInteger put: #quote.
    newTable at: $" asInteger put: #xDoubleQuote.
    newTable at: ${ asInteger put: #xBrace.
    newTable at: $+ asInteger put: #xSign.
    newTable at: $- asInteger put: #xSign.
    newTable at: $< asInteger put: #xSymbol.
    newTable at: $> asInteger put: #xSymbol.
    newTable at: $= asInteger put: #xSymbol.
    newTable at: $~ asInteger put: #xSymbol.
    newTable at: $* asInteger put: #xSymbol.
    newTable at: $/ asInteger put: #xSymbol.
    newTable at: $_ asInteger put: #xSymbol.
    newTable at: $: asInteger put: #xSymbol.
    newTable at: $, asInteger put: #xSymbol.
    newTable at: $\ asInteger put: #xSymbol.
    newTable at: $% asInteger put: #xComment.
    newTable at: $( asInteger put: #leftParenthesis.
    newTable at: $) asInteger put: #rightParenthesis.
    newTable at: $[ asInteger put: #leftParenthesis.
    newTable at: $] asInteger put: #rightParenthesis.
    newTable at: $. asInteger put: #period.
    newTable at: $` asInteger put: #quote.
    newTable at: $! asInteger put: #eof.
    ScanningTable := newTable! !

!LispScanner class methodsFor: 'instance creation'!

new
    ^(super new) initScanner; yourself! !

!LispScanner methodsFor: 'initialize-release'!

initScanner
    failBlock := 
	[:errorMessage || label string |
	    label := errorMessage , ' near ' , (token printString contractTo: 10).
	    string := source upToEnd.
	    string isEmpty
		ifTrue: [string := '--> end of file']
		ifFalse: [string := '--> ' , (string contractTo: 30)].
	    self error: 'scan error   ', label, Character nl asString, string].
    !

on: inputStream 
    source := inputStream.
    mark := source position! !

!LispScanner methodsFor: 'private'!

nextChar
    | char |
    source atEnd ifTrue: [ ^$! ].
    char := source next.
    char = Character cr
	ifTrue: 
	    [char := Character nl. source peekFor: char].
    ^char!

peekChar
    | char |
    char := source peek.
    char = Character cr ifTrue: [char := Character nl].
    char isNil ifTrue: [char := $! ].
    ^char!

unNextChar
    source skip: -1! !

!LispScanner methodsFor: 'reading'!

numberFrom: aStream 
    ^Number readFrom: aStream!

objectFrom: aStream 
    "POSSIBLE PORTABILITY PROBLEM HERE!"
    | buffer char |
    buffer := WriteStream on: (String new: 20).
    char := aStream next.
    
    [char := aStream next.
    char = $}]
	whileFalse: 
	    [char == nil ifTrue: [^failBlock value: 'Syntax error unmatched ${'].
	    buffer nextPut: char].
    ^Behavior
	evaluate: buffer contents
	to: nil
	ifError: []!

stringFrom: aStream 
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
			char = $" ifFalse: [^String fromString: buffer contents]].
		buffer nextPut: aStream next]].
    string := aStream upToEnd.
    string size > 100 ifTrue: [string := string copyFrom: 1 to: 100].
    ^failBlock value: 'Syntax error unmatched $'''!

symbolFrom: aStream 
    | buffer char type |
    buffer := WriteStream on: (String new: 20).
    char := aStream peek.
    [char notNil and: [(type := self tableAt: char) == #xSymbol or: [type == #xDigit or: [type == #xSign]]]]
	whileTrue: 
	    [buffer nextPut: aStream next.
	    char := aStream peek].
    buffer contents = 'nil' ifTrue: [^LispNil null].
    ^Symbol intern: buffer contents! !

!LispScanner methodsFor: 'scanning'!

multiChar: type 
    self perform: type!

nextToken
    | char |
    mark := source position.
    char := self peekChar.
    tokenType := self tableAt: char.
    [tokenType == #xDelimiter]
	whileTrue: 
	    [self nextChar.
	    char := self peekChar.
	    tokenType := self tableAt: char].
    (tokenType at: 1) = $x
	ifTrue: [self multiChar: tokenType]
	ifFalse: [self singleChar: tokenType].
    ^token!

singleChar: type 
    self nextChar.
    token := type!

tableAt: char
    | index |
    index := char asInteger.
    ^index = 0
	ifFalse: [ScanningTable at: index]
	ifTrue: [#xBinary]!

unNextToken
    source position: mark! !

!LispScanner methodsFor: 'x'!

xBinary
    ^failBlock value: 'Syntax error ' , source peek printString!

xBrace
    tokenType := #object.
    token := self objectFrom: source!

xComment
    | char |
    [(char := self nextChar) = Character nl]
	whileFalse: [char == nil ifTrue: [^self nextToken]].
    ^self nextToken!

xDigit
    tokenType := #number.
    token := self numberFrom: source!

xDoubleQuote
    tokenType := #string.
    token := self stringFrom: source!

xSign
    | char sign |
    sign := self nextChar.
    char := self peekChar.
    char isDigit
	ifTrue: 
	    [tokenType := #number.
	    token := self numberFrom: source.
	    sign == $- ifTrue: [token := token negated]]
	ifFalse: 
	    [self unNextChar.
	    tokenType := #symbol.
	    token := self symbolFrom: source]!

xSymbol
    tokenType := #symbol.
    token := self symbolFrom: source! !


LispScanner initialize!

!LispParser class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispParser class methodsFor: 'examples'!

example1
    "LispParser example1."

    | list |
    list := LispParser parse: '(1 2 3 4 (5 6 7 8 9) 10)'.
    ^list!

example2
    "LispParser example2."

    | list |
    list := LispParser parse: '
	    (10 (1 2)
	     20 (3 4 . 100)
	     30 (5 6) . 200)
    '.
    ^list!

example3
    "LispParser example3."

    | list |
    list := LispParser parse: '
	    (PetriNet Aoki
		(Place
		    (p1 . {100@100})
		    (p2 . {200@200})
		    (p3 . {300@300})
		    (p4 . {400@400})
		    (p5 . {500@500}))
		(Transition
		    (t1 . {100@100})
		    (t2 . {200@200})
		    (t3 . {300@300})
		    (t4 . {400@400})
		    (t5 . {500@500}))
		(InputFunction
		    (t1 p1 p2 p3 p4 p5)
		    (t2 . p4)
		    (t3 . p5))
		(OutputFunction
		    (t1 p1 p2 p3 p4 p5)
		    (t2 . p4)
		    (t3 . p5))
		(Marking {#(1 2 3 4 5)}))'.
    Transcript nl; show: list saveString.
    list := LispParser parse: list saveString.
    ^list!

example4
    "LispParser example4."

    | list |
    list := LispParser parse: '(1 2 3 4 (5 6 7 ~ 8 9) 10)'.
    ^list!

example5
    "LispParser example5."

    | list |
    list := LispParser parse: '(1 2 3 4 (5 6 7 {100@100 8 9) 10)'.    "error"
    ^list!

example6
    "LispParser example6."

    | list |
    list := LispParser parse: '(1 2 3 4 (5 6 7 ''aaaaa 8 9) 10)'.
    ^list!

example7
    "LispParser example7."

    | list |
    list := LispParser parse: ' `(`(1 2 `3) . `4) '.    "`(`(1 2 `3) . `4) -> (quote ((quote (1 2 (quote 3))) quote 4))"
    ^list! !

!LispParser class methodsFor: 'private'!

makeStream: aStream 

    ^(aStream respondsTo: #next) "HACK"
	ifTrue: [aStream]
	ifFalse: [ReadStream on: aStream asString].! !

!LispParser class methodsFor: 'utilities'!

parse: aStream 
    ^self new parse: (self makeStream: aStream)!

parse: aStream ifFail: aBlock 
    ^self new parse: (self makeStream: aStream)
	ifFail: aBlock! !

!LispParser methodsFor: 'parsing'!

parse: sourceStream 
    | label string |
    ^self parse: sourceStream
	ifFail: 
	    [:errorMessage | 
	    label := errorMessage , ' near ' , (token printString contractTo: 20).
	    string := source upToEnd.
	    string isEmpty
		ifTrue: [string := '--> end of file']
		ifFalse: [string := '--> ' , (string contractTo: 30)].
	    self error: 'parse error   ', label, Character nl asString, string.
	    ^LispNil null]!

parse: sourceStream ifFail: aBlock 
    | result |
    self init: sourceStream ifFail: aBlock.
    result := self scan.
    ^result! !

!LispParser methodsFor: 'private'!

init: sourceStream ifFail: aBlock 
    super on: sourceStream.
    failBlock := aBlock! !

!LispParser methodsFor: 'scan and parse'!

scan
    source atEnd ifTrue: [^LispCons null].
    ^self scanList!

scanList
    | expression |
    self nextToken.
    tokenType == #eof ifTrue: [^LispCons null].
    tokenType == #number ifTrue: [^token].
    tokenType == #string ifTrue: [^token].
    tokenType == #object ifTrue: [^token].
    tokenType == #symbol ifTrue: [^token].
    tokenType == #quote
	ifTrue: 
	    [expression := LispCons head: self scanList tail: LispCons null.
	    ^LispCons head: #quote tail: expression].
    tokenType == #leftParenthesis ifTrue: [^self scanListAux].
    ^failBlock value: 'Syntax error'!

scanListAux
    | cdr |
    self nextToken.
    tokenType == #eof ifTrue: [^LispCons null].
    tokenType == #rightParenthesis ifTrue: [^LispCons null].
    tokenType == #leftParenthesis ifTrue: [^LispCons head: self scanListAux tail: self scanListAux].
    tokenType == #number ifTrue: [^LispCons head: token tail: self scanListAux].
    tokenType == #string ifTrue: [^LispCons head: token tail: self scanListAux].
    tokenType == #object ifTrue: [^LispCons head: token tail: self scanListAux].
    tokenType == #symbol ifTrue: [^LispCons head: token tail: self scanListAux].
    tokenType == #period
	ifTrue: 
	    [cdr := self scanList.
	    self nextToken.
	    tokenType == #rightParenthesis
		ifTrue: [^cdr]
		ifFalse: [^failBlock value: 'Syntax error']].
    tokenType == #quote
	ifTrue: 
	    [cdr := LispCons head: self scanList tail: LispCons null.
	    cdr := LispCons head: #quote tail: cdr.
	    ^LispCons head: cdr tail: self scanListAux].
    self unNextToken.
    ^failBlock value: 'Syntax error'! !

!LispParser methodsFor: 'scanning'!

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



!LispTable class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispTable class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!LispTable methodsFor: 'accessing'!

at: symbol 
    ^self getprop: symbol key: #apval!

at: symbol put: value 
    self intern: symbol.
    ^self
	putprop: symbol
	key: #apval
	value: value!

identifiers
    ^properties keys asSortedCollection! !

!LispTable methodsFor: 'adding'!

add: symbol 
    self intern: symbol! !

!LispTable methodsFor: 'initialize-release'!

initialize
    properties := Dictionary new! !

!LispTable methodsFor: 'private'!

errorSymbolNotFound
    self error: 'symbol not found'!

intern: symbol 
    (properties includesKey: symbol)
	ifFalse: [properties at: symbol put: Dictionary new].
    ^symbol! !

!LispTable methodsFor: 'property access'!

getprop: identifier key: key 
    | property |
    property := properties at: identifier ifAbsent: [^self errorSymbolNotFound].
    ^property at: key ifAbsent: [^nil]!

putprop: identifier key: key value: value 
    | property |
    property := properties at: identifier ifAbsent: [^self errorSymbolNotFound].
    ^property at: key put: value!

remprop: identifier key: key 
    | property |
    property := properties at: identifier ifAbsent: [^self errorSymbolNotFound].
    ^property removeKey: key ifAbsent: [^nil]! !

!LispTable methodsFor: 'removing'!

remove: symbol
    ^properties removeKey: symbol ifAbsent: [^nil]! !



!LispInterpreter class methodsFor: 'copyright'!

copyright
    ^'Copyright (C) 1995-1998 AOKI Atsushi, All Rights Reserved.'!

system
    ^'Goodies'!

version
    ^'003'! !

!LispInterpreter class methodsFor: 'examples'!

example01
    "LispInterpreter example01."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    nil

    '.
    ^aList!

example02
    "LispInterpreter example02."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    123

    '.
    ^aList!

example03
    "LispInterpreter example03."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    "abc"

    '.
    ^aList!

example04
    "LispInterpreter example04."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (cons 3 4)

    '.
    ^aList!

example05
    "LispInterpreter example05."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (quote (3 4))

    '.
    ^aList!

example06
    "LispInterpreter example06."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (car (quote (3 4)))

    '.
    ^aList!

example07
    "LispInterpreter example07."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (cdr (quote (3 4)))

    '.
    ^aList!

example08
    "LispInterpreter example08."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (cons (car `(1 2 3)) `(3 4))

    '.
    ^aList!

example09
    "LispInterpreter example09."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (+ 1 2 3 4 5 6 7 8 9 10)

    '.
    ^aList!

example10
    "LispInterpreter example10."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (progn
	(setq x 100)
	(setq y 200 z 300)
	(+ x y z))

    '.
    ^aList!

example11
    "LispInterpreter example11."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (progn
	(defun plus (x y) (+ x y))
	(plus 3 4))

    '.
    ^aList!

example12
    "LispInterpreter example12."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (progn
	(defun concat (x y) 
	    (cond
		((atom x) y)
		(t (cons
			(car x)
			(concat (cdr x) y)))))
	(concat `(1 2 3) `(4 5)))

    '.
    ^aList!

example13
    "LispInterpreter example13."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (progn
	(defun plus nlambda (x) (plus1 x))
	(defun plus1 lambda (x)
	    (cond
		((null x) 0)
		(t (+ (car x) (plus1 (cdr x))))))
	(plus 1 2 3 4 5 6 7 8 9 10))

    '.
    ^aList!

example14
    "LispInterpreter example14."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    ((lambda (x y) (cons x (cons y nil))) 3 4)

    '.
    ^aList!

example15
    "LispInterpreter example15."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    ((nlambda (x) x) 1 2 3 4 5 6 7 8 9 10)

    '.
    ^aList!

example16
    "LispInterpreter example16."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (progn
	(setq x 100)
	(setq y 200)
	(do
	    (x y)
	    (setq x 10000)
	    (setq y 20000)
	    (send {Transcript} `nl)
	    (send {Transcript} `show: (send x `printString))
	    (send {Transcript} `nl)
	    (send {Transcript} `show: (send y `printString)))
	(send {Transcript} `nl)
	(send {Transcript} `show: (send x `printString))
	(send {Transcript} `nl)
	(send {Transcript} `show: (send y `printString)))

    '.
    ^aList!

example17
    "LispInterpreter example17."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (do
	(count)
	(setq count 1)
	(while
	    (<= count 100)
	    do
	    (send {Transcript} `nl)
	    (send {Transcript} `show: (send count `printString))
	    (setq count (+ count 1))))

    '.
    ^aList!

example18
    "LispInterpreter example18."

    | aList |
    aList := LispInterpreter evaluateFrom: '

    (do
	(count)
	(setq count 1)
	(repeat
	    (send {Transcript} `nl)
	    (send {Transcript} `show: (send count `printString))
	    (setq count (+ count 1))
	    until
	    (<= count 100)))

    '.
    ^aList! !

!LispInterpreter class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!LispInterpreter class methodsFor: 'printing'!

printString: anObject 
    "LispInterpreter printString: 'string'."
    "LispInterpreter printString: #symbol."
    "LispInterpreter printString: 123."
    "LispInterpreter printString: 123.456."
    "LispInterpreter printString: 123.456e7."
    "LispInterpreter printString: LispNil null."
    "LispInterpreter printString: nil."

    | aStream |
    aStream := WriteStream on: (String new: 32).
    (anObject isKindOf: LispCons)
	ifTrue: [anObject printOn: aStream level: 0]
	ifFalse: [LispCons new printOn: aStream object: anObject].
    ^aStream contents! !

!LispInterpreter class methodsFor: 'public access'!

evaluate: sExpression 
    ^self new evaluateTopLevel: sExpression ifFail: [:errorMessage | self error: errorMessage]!

evaluate: sExpression ifFail: aBlock 
    ^self new evaluateTopLevel: sExpression ifFail: aBlock!

evaluateFrom: aStream 
    ^self new evaluateTopLevel: (LispParser parse: aStream)
	ifFail: [:errorMessage | self error: errorMessage]!

evaluateFrom: aStream ifFail: aBlock 
    ^self new evaluateTopLevel: (LispCons parse: aStream ifFail: aBlock)
	ifFail: aBlock! !

!LispInterpreter methodsFor: 'accessing'!

textCollector
    ^textCollector!

textCollector: anObject
    textCollector := anObject! !

!LispInterpreter methodsFor: 'error handling'!

fatal: message 
    bindStack reverseDo: [:assoc | assoc key notNil ifTrue: [assoc value notNil
		ifTrue: [self
			putprop: assoc key
			key: #apval
			value: assoc value]
		ifFalse: [self remprop: assoc key key: #apval]]].
    ^failBlock value: '*** Error: ' , message! !

!LispInterpreter methodsFor: 'evaluating'!

evaluate: sExpression 
    | apval |
    (sExpression isKindOf: LispList)
	ifTrue: [^self listEvaluate: sExpression].
    (sExpression isKindOf: Symbol)
	ifTrue: 
	    [sExpression = #t ifTrue: [^#t].
	    lispTable intern: sExpression.
	    apval := lispTable getprop: sExpression key: #apval.
	    apval isNil ifTrue: [^self fatal: (self printString: sExpression)
			, ' is unbound atom'].
	    ^apval].
    ^sExpression!

evaluateTopLevel: sExpression 
    ^self evaluateTopLevel: sExpression ifFail:
	[:errorMessage | 
	Transcript show: errorMessage; nl.
	LispNil null]!

evaluateTopLevel: sExpression ifFail: aBlock 
    failBlock := aBlock.
    ^self evaluate: sExpression!

listEvaluate: sExpression 
    | funcName arguList funcBody |
    sExpression null ifTrue: [^sExpression].
    funcName := sExpression head.
    arguList := sExpression tail.
    (funcName isKindOf: LispCons)
	ifTrue: 
	    [funcBody := funcName.
	    funcBody head = #lambda
		ifTrue: 
		    [funcBody := LispCons head: #lambda tail: funcBody.
		    ^self exprEval: funcBody arguList: arguList].
	    funcBody head = #nlambda
		ifTrue: 
		    [funcBody := LispCons head: #nlambda tail: funcBody.
		    ^self fexprEval: funcBody arguList: arguList].
	    ^self fatal: 'unexpected function ' , (self printString: funcBody)].
    (funcName isKindOf: Symbol)
	ifFalse: [^self fatal: 'null function ' , (self printString: funcName)].
    funcBody := self getprop: funcName key: #fexpr.
    funcBody = LispNil null ifFalse: [^self fexprEval: funcBody arguList: arguList].
    funcBody := self getprop: funcName key: #expr.
    funcBody = LispNil null ifFalse: [^self exprEval: funcBody arguList: arguList].
    funcBody := self getprop: funcName key: #fsubr.
    funcBody = LispNil null ifFalse: [^self fsubrEval: funcBody arguList: arguList].
    funcBody := self getprop: funcName key: #subr.
    funcBody = LispNil null ifFalse: [^self subrEval: funcBody arguList: arguList].
    ^self fatal: 'undefined function ' , (self printString: funcName)! !

!LispInterpreter methodsFor: 'fsubr functions'!

fsubrAdd: arguList 
    | v a |
    v := LispNil null.
    arguList
	do: 
	    [:each | 
	    a := self evaluate: each.
	    (a isKindOf: Number)
		ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a) , ' for +'].
	    v = LispNil null
		ifTrue: [v := a]
		ifFalse: [v := v + a]].
    ^v!

fsubrCond: arguList 
    | result |
    arguList do: [:each | (self evaluate: each head)
	    ~= LispNil null
	    ifTrue: 
		[result := LispNil null.
		(each tail isKindOf: LispCons)
		    ifTrue: [each tail do: [:expr | result := self evaluate: expr]].
		^result]].
    ^LispNil null!

fsubrDefun: arguList 
    | funcName funcType |
    funcName := arguList head.
    (funcName isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected function name ' , (self printString: funcName) , ' for defun'].
    funcType := arguList tail head.
    funcType = #lambda
	ifTrue: 
	    [self
		putprop: funcName
		key: #expr
		value: arguList.
	    ^funcName].
    funcType = #nlambda
	ifTrue: 
	    [self
		putprop: funcName
		key: #fexpr
		value: arguList.
	    ^funcName].
    self
	putprop: funcName
	key: #expr
	value: (LispCons head: funcName tail: (LispCons head: #lambda tail: arguList tail)).
    ^funcName!

fsubrDiv: arguList 
    | v a |
    v := LispNil null.
    arguList
	do: 
	    [:each | 
	    a := self evaluate: each.
	    (a isKindOf: Number)
		ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a) , ' for /'].
	    v = LispNil null
		ifTrue: [v := a]
		ifFalse: [v := v / a]].
    ^v!

fsubrDo: arguList 
    | locals executions result |
    locals := arguList head.
    executions := arguList tail.
    self bindMark.
    locals do: [:lvar | self bind: lvar value: LispNil null].
    result := LispNil null.
    executions do: [:each | result := self evaluate: each].
    self unbind.
    ^result!

fsubrIdiv: arguList 
    | v a |
    v := LispNil null.
    arguList
	do: 
	    [:each | 
	    a := self evaluate: each.
	    (a isKindOf: Number)
		ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a) , ' for //'].
	    v = LispNil null
		ifTrue: [v := a]
		ifFalse: [v := v // a]].
    ^v!

fsubrIf: arguList 
    | predicate then list truePart falsePart bool result |
    predicate := arguList head.
    then := arguList tail head.
    list := arguList tail tail.
    truePart := LispNil null.
    falsePart := LispNil null.
    bool := true.
    list do: [:each | each = #else
	    ifTrue: [bool := false]
	    ifFalse: [bool
		    ifTrue: [truePart := LispCons head: each tail: truePart]
		    ifFalse: [falsePart := LispCons head: each tail: falsePart]]].
    then = #then ifFalse: [^self fatal: 'unexpected format for if'].
    truePart := truePart reverse.
    falsePart := falsePart reverse.
    result := LispNil null.
    (self evaluate: predicate)
	= LispNil null
	ifTrue: [falsePart do: [:each | result := self evaluate: each]]
	ifFalse: [truePart do: [:each | result := self evaluate: each]].
    ^result!

fsubrMlt: arguList 
    | v a |
    v := LispNil null.
    arguList
	do: 
	    [:each | 
	    a := self evaluate: each.
	    (a isKindOf: Number)
		ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a) , ' for *'].
	    v = LispNil null
		ifTrue: [v := a]
		ifFalse: [v := v * a]].
    ^v!

fsubrMod: arguList 
    | v a |
    v := LispNil null.
    arguList
	do: 
	    [:each | 
	    a := self evaluate: each.
	    (a isKindOf: Number)
		ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a) , ' for \\'].
	    v = LispNil null
		ifTrue: [v := a]
		ifFalse: [v := v \\ a]].
    ^v!

fsubrProgn: arguList 
    | result |
    result := LispNil null.
    arguList do: [:each | result := self evaluate: each].
    ^result!

fsubrQuote: arguList
    ^arguList head!

fsubrRepeat: arguList 
    | reverse predicate until executions result |
    reverse := arguList reverse.
    predicate := reverse head.
    until := reverse tail head.
    executions := reverse tail tail reverse.
    until = #until ifFalse: [^self fatal: 'unexpected format for repeat'].
    result := LispNil null.
    executions do: [:each | result := self evaluate: each].
    [(self evaluate: predicate)
	= LispNil null]
	whileFalse: [executions do: [:each | result := self evaluate: each]].
    ^result!

fsubrSend: arguList 
    | list receiver selector arguments result |
    list := arguList.
    receiver := self evaluate: list head.
    list := list tail.
    selector := self evaluate: list head.
    (selector isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected selector ' , (self printString: selector) , ' for send'].
    list := list tail.
    arguments := OrderedCollection new.
    [list isKindOf: LispCons]
	whileTrue: 
	    [arguments add: (self evaluate: list head).
	    list := list tail].
    result := receiver perform: selector withArguments: arguments asArray.
    ^result!

fsubrSetq: arguList 
    | list a1 a2 |
    list := arguList.
    a2 := LispNil null.
    [list isKindOf: LispCons]
	whileTrue: 
	    [a1 := list head.
	    (a1 isKindOf: Symbol)
		ifFalse: [^self fatal: 'unexpected variable ' , (self printString: a1) , ' for setq'].
	    list := list tail.
	    a2 := self evaluate: list head.
	    self
		putprop: a1
		key: #apval
		value: a2.
	    list := list tail].
    ^a2!

fsubrSub: arguList 
    | v a |
    v := LispNil null.
    arguList
	do: 
	    [:each | 
	    a := self evaluate: each.
	    (a isKindOf: Number)
		ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a) , ' for -'].
	    v = LispNil null
		ifTrue: [v := a]
		ifFalse: [v := v - a]].
    ^v!

fsubrWhile: arguList 
    | predicate do executions result |
    predicate := arguList head.
    do := arguList tail head.
    executions := arguList tail tail.
    do = #do ifFalse: [^self fatal: 'unexpected format for while'].
    result := LispNil null.
    [(self evaluate: predicate)
	= LispNil null]
	whileFalse: [executions do: [:each | result := self evaluate: each]].
    ^result! !

!LispInterpreter methodsFor: 'func eval'!

exprEval: funcBody arguList: arguList 
    | expression funcName lvarList lvar result |
    expression := funcBody.
    funcName := expression head.
    expression := expression tail.
    expression := expression tail.
    lvarList := expression head.
    expression := expression tail.
    arguList length ~= lvarList length ifTrue: [^self fatal: 'too few or many arguments ' , (self printString: arguList) , ' vs ' , (self printString: lvarList) , ' for ' , funcName].
    self bindMark.
    arguList
	do: 
	    [:each | 
	    lvar := lvarList head.
	    self bind: lvar value: (self evaluate: each).
	    lvarList := lvarList tail].
    expression do: [:each | result := self evaluate: each].
    self unbind.
    ^result!

fexprEval: funcBody arguList: arguList 
    | expression funcName lvarList lvar result |
    expression := funcBody.
    funcName := expression head.
    expression := expression tail.
    expression := expression tail.
    lvarList := expression head.
    expression := expression tail.
    lvarList length ~= 1 ifTrue: [^self fatal: 'too few or many arguments ' , (self printString: lvarList) , ' for ' , (self printString: funcName)].
    self bindMark.
    lvar := lvarList head.
    self bind: lvar value: arguList.
    expression do: [:each | result := self evaluate: each].
    self unbind.
    ^result!

fsubrEval: funcBody arguList: arguList 
    | messageSelector |
    messageSelector := funcBody tail head.
    ^self perform: messageSelector with: arguList!

subrEval: funcBody arguList: arguList 
    | funcName messageSelector arguCount arguBuffer list |
    funcName := funcBody head.
    messageSelector := funcBody tail head.
    arguCount := funcBody tail tail head.
    arguBuffer := OrderedCollection new.
    list := arguList.
    arguCount
	timesRepeat: 
	    [list null ifTrue: [^self fatal: 'too few arguments for ' , (self printString: funcName)].
	    arguBuffer add: (self evaluate: list head).
	    list := list tail].
    list null not ifTrue: [^self fatal: 'too many arguments for ' , (self printString: funcName)].
    arguBuffer isEmpty
	ifTrue: [^self perform: messageSelector]
	ifFalse: [^self perform: messageSelector with: arguBuffer asArray]! !

!LispInterpreter methodsFor: 'initialize-release'!

initialize
    lispTable := LispTable new.
    bindStack := OrderedCollection new.
    failBlock := [:errorMessage | self error: errorMessage].
    textCollector := Transcript.
    self initializeSubrFunctions.
    self initializeFsubrFunctions.
    self initializeExprFunctions.
    self initializeFexprFunctions!

initializeExprFunctions
    self evaluateTopLevel: (LispParser parse: '

    % Expr Functions
    (progn

	% ++
	(defun ++ lambda (x)
	    (+ x 1))

	% --
	(defun -- lambda (x)
	    (- x 1))

	% assoc
	(defun assoc lambda (x a)
	    (cond
		((null a) nil)
		((equal x (car (car a))) (car a))
		(t (assoc x (cdr a)))))

	% copy
	(defun copy lambda (x)
	    (cond
		((null x) nil)
		(t (cons (car x) (copy (cdr x))))))

	% mapc
	(defun mapc lambda (f x)
	    (cond
		((null x) nil)
		(t (progn
		    (eval (cons f (cons `(car x) nil)))
		    (mapc f (cdr x))))))

	% mapcar
	(defun mapcar lambda (f x)
	    (cond
		((null x) nil)
		(t (cons
		    (eval (cons f (cons `(car x) nil)))
		    (mapcar f (cdr x))))))
	    
	) % end

    ')!

initializeFexprFunctions
    self evaluateTopLevel: (LispParser parse: '

    % Expr Functions
    (progn

	% and
	(defun and nlambda (x)
	    (do    (list)
		(setq list x)
		(while
		    (if (null list) then nil else (eval (car list)))
		    do
		    (setq list (cdr list)))
		(if (null list) then t else nil)))

	% list
	(defun list nlambda (x)
	    (mapcar `eval x))

	% or
	(defun or nlambda (x)
	    (do    (list)
		(setq list x)
		(while
		    (if (null list) then nil else (not (eval (car list))))
		    do
		    (setq list (cdr list)))
		(if (null list) then nil else t)))

	) % end

    ')!

initializeFsubrFunctions
    self setFsubrFunc: #(#* #fsubrMlt:).
    self setFsubrFunc: #(#+ #fsubrAdd:).
    self setFsubrFunc: #(#- #fsubrSub:).
    self setFsubrFunc: #(#/ #fsubrDiv:).
    self setFsubrFunc: #(#// #fsubrIdiv:).
    self setFsubrFunc: #(#cond #fsubrCond:).
    self setFsubrFunc: #(#defun #fsubrDefun:).
    self setFsubrFunc: #(#do #fsubrDo:).
    self setFsubrFunc: #(#if #fsubrIf:).
    self setFsubrFunc: #(#progn #fsubrProgn:).
    self setFsubrFunc: #(#quote #fsubrQuote:).
    self setFsubrFunc: #(#repeat #fsubrRepeat:).
    self setFsubrFunc: #(#send #fsubrSend:).
    self setFsubrFunc: #(#setq #fsubrSetq:).
    self setFsubrFunc: #(#while #fsubrWhile:).
    self setFsubrFunc: #(#\\ #fsubrMod:).!

initializeSubrFunctions
    self setSubrFunc: #(#< #subrLt: 2).
    self setSubrFunc: #(#<= #subrLe: 2).
    self setSubrFunc: #(#= #subrEqual: 2).
    self setSubrFunc: #(#== #subrEq: 2).
    self setSubrFunc: #(#> #subrGt: 2).
    self setSubrFunc: #(#>= #subrGe: 2).
    self setSubrFunc: #(#append #subrAppend: 2).
    self setSubrFunc: #(#atom #subrAtom: 1).
    self setSubrFunc: #(#car #subrCar: 1).
    self setSubrFunc: #(#cdr #subrCdr: 1).
    self setSubrFunc: #(#cons #subrCons: 2).
    self setSubrFunc: #(#consp #subrConsp: 1).
    self setSubrFunc: #(#dtpr #subrConsp: 1).
    self setSubrFunc: #(#doublep #subrDoublep: 1).
    self setSubrFunc: #(#eq #subrEq: 2).
    self setSubrFunc: #(#equal #subrEqual: 2).
    self setSubrFunc: #(#eval #subrEval: 1).
    self setSubrFunc: #(#exprs #subrExprs 0).
    self setSubrFunc: #(#fexprs #subrFexprs 0).
    self setSubrFunc: #(#floatp #subrFloatp: 1).
    self setSubrFunc: #(#fsubrs #subrFsubrs 0).
    self setSubrFunc: #(#gc #subrGc 0).
    self setSubrFunc: #(#gensym #subrGensym 0).
    self setSubrFunc: #(#getprop #subrGetprop: 2).
    self setSubrFunc: #(#integerp #subrIntegerp: 1).
    self setSubrFunc: #(#last #subrLast: 1).
    self setSubrFunc: #(#length #subrLength: 1).
    self setSubrFunc: #(#listp #subrListp: 1).
    self setSubrFunc: #(#member #subrMember: 2).
    self setSubrFunc: #(#memq #subrMemq: 2).
    self setSubrFunc: #(#nconc #subrNconc: 2).
    self setSubrFunc: #(#neq #subrNeq: 2).
    self setSubrFunc: #(#nequal #subrNequal: 2).
    self setSubrFunc: #(#not #subrNull: 1).
    self setSubrFunc: #(#nth #subrNth: 2).
    self setSubrFunc: #(#null #subrNull: 1).
    self setSubrFunc: #(#numberp #subrNumberp: 1).
    self setSubrFunc: #(#oblist #subrOblist 0).
    self setSubrFunc: #(#pp #subrPp: 1).
    self setSubrFunc: #(#princ #subrPrinc: 1).
    self setSubrFunc: #(#print #subrPrint: 1).
    self setSubrFunc: #(#putprop #subrPutprop: 3).
    self setSubrFunc: #(#remprop #subrRemprop: 2).
    self setSubrFunc: #(#reverse #subrReverse: 1).
    self setSubrFunc: #(#rplaca #subrRplaca: 2).
    self setSubrFunc: #(#rplacd #subrRplacd: 2).
    self setSubrFunc: #(#stringp #subrStringp: 1).
    self setSubrFunc: #(#subrs #subrSubrs 0).
    self setSubrFunc: #(#symbolp #subrSymbolp: 1).
    self setSubrFunc: #(#terpri #subrTerpri 0).
    self setSubrFunc: #(#~= #subrNequal: 2).
    self setSubrFunc: #(#~~ #subrNeq: 2)! !

!LispInterpreter methodsFor: 'printing'!

printString: anObject 
    ^self class printString: anObject! !

!LispInterpreter methodsFor: 'private'!

setFsubrFunc: bodyArray 
    self
	putprop: (bodyArray at: 1) asSymbol
	key: #fsubr
	value: (LispCons list: bodyArray)!

setSubrFunc: bodyArray 
    self
	putprop: (bodyArray at: 1) asSymbol
	key: #subr
	value: (LispCons list: bodyArray)! !

!LispInterpreter methodsFor: 'property access'!

getprop: identifier key: key 
    | value |
    lispTable intern: identifier.
    value := lispTable getprop: identifier key: key.
    value isNil ifTrue: [^LispNil null].
    ^value!

putprop: identifier key: key value: value 
    lispTable intern: identifier.
    ^lispTable
	putprop: identifier
	key: key
	value: value!

remprop: identifier key: key 
    | value |
    lispTable intern: identifier.
    value := lispTable remprop: identifier key: key.
    value isNil ifTrue: [^LispNil null].
    ^value! !

!LispInterpreter methodsFor: 'shallow binding'!

bind: symbol value: value 
    | saveValue assoc |
    lispTable intern: symbol.
    saveValue := lispTable getprop: symbol key: #apval.
    assoc := Association key: symbol value: saveValue.
    bindStack addLast: assoc.
    self
	putprop: symbol
	key: #apval
	value: value!

bindMark
    | assoc |
    assoc := Association key: nil value: nil.
    bindStack addLast: assoc!

unbind
    | assoc |
    
    [assoc := bindStack removeLast.
    assoc key notNil]
	whileTrue: [assoc value notNil
		ifTrue: [self
			putprop: assoc key
			key: #apval
			value: assoc value]
		ifFalse: [self remprop: assoc key key: #apval]]! !

!LispInterpreter methodsFor: 'subr functions'!

subrAppend: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for append'].
    (a2 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for append'].
    ^a1 append: a2!

subrAtom: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: LispCons) ifFalse: [^#t].
    ^LispNil null!

subrCar: arguArray 
    | list |
    list := arguArray at: 1.
    (list isKindOf: LispCons)
	ifTrue: [^list head].
    (list isKindOf: LispNil)
	ifTrue: [^LispNil null].
    ^self fatal: 'unexpected argument ' , (self printString: list) , ' for car'!

subrCdr: arguArray 
    | list |
    list := arguArray at: 1.
    (list isKindOf: LispCons)
	ifTrue: [^list tail].
    (list isKindOf: LispNil)
	ifTrue: [^LispNil null].
    ^self fatal: 'unexpected argument ' , (self printString: list) , ' for cdr'!

subrCons: arguArray 
    ^LispCons head: (arguArray at: 1)
	tail: (arguArray at: 2)!

subrConsp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: LispCons)
	ifTrue: [^#t].
    ^LispNil null!

subrDoublep: arguArray 
    | a1 |
    ^self subrFloatp: arguArray
    "a1 := arguArray at: 1.
    (a1 isKindOf: Double)
	ifTrue: [^#t].
    ^LispNil null"!

subrEq: arguArray 
    | bool |
    (arguArray at: 1)
	== (arguArray at: 2)
	ifTrue: [bool := #t]
	ifFalse: [bool := LispNil null].
    ^bool!

subrEqual: arguArray 
    | bool |
    (arguArray at: 1)
	= (arguArray at: 2)
	ifTrue: [bool := #t]
	ifFalse: [bool := LispNil null].
    ^bool!

subrEval: arguArray 
    ^self evaluate: (arguArray at: 1)!

subrExprs
    | list |
    list := LispNil null.
    self subrOblist reverse do: [:id | (self getprop: id key: #expr)
	    = LispNil null ifFalse: [list := LispCons head: id tail: list]].
    ^list!

subrFexprs
    | list |
    list := LispNil null.
    self subrOblist reverse do: [:id | (self getprop: id key: #fexpr)
	    = LispNil null ifFalse: [list := LispCons head: id tail: list]].
    ^list!

subrFloatp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: Float)
	ifTrue: [^#t].
    ^LispNil null!

subrFsubrs
    | list |
    list := LispNil null.
    self subrOblist reverse do: [:id | (self getprop: id key: #fsubr)
	    = LispNil null ifFalse: [list := LispCons head: id tail: list]].
    ^list!

subrGc
    "ObjectMemory globalCompactingGC."
    Smalltalk compact.
    Transcript nl; show: 'garbage collecting'.
    ^#t!

subrGe: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for >='].
    (a2 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for >='].
    a1 >= a2 ifTrue: [^#t].
    ^LispNil null!

subrGensym
    | clock |
    (Delay forMilliseconds: 1) wait.
    clock := Time millisecondClockValue.
    ^('id' , clock printString) asSymbol!

subrGetprop: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for getprop'].
    (a2 isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for getprop'].
    ^self getprop: a1 key: a2!

subrGt: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for >'].
    (a2 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for >'].
    a1 > a2 ifTrue: [^#t].
    ^LispNil null!

subrIntegerp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: Integer)
	ifTrue: [^#t].
    ^LispNil null!

subrLast: arguArray 
    | list |
    list := arguArray at: 1.
    (list isKindOf: LispCons)
	ifTrue: [^list last].
    ^self fatal: 'unexpected argument ' , (self printString: list) , ' for last'!

subrLe: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for <='].
    (a2 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for <='].
    a1 <= a2 ifTrue: [^#t].
    ^LispNil null!

subrLength: arguArray 
    | list |
    list := arguArray at: 1.
    (list isKindOf: LispCons)
	ifTrue: [^list length].
    ^self fatal: 'unexpected argument ' , (self printString: list) , ' for length'!

subrListp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: LispList)
	ifTrue: [^#t].
    ^LispNil null!

subrLt: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for <'].
    (a2 isKindOf: LispList)
	ifTrue: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for <'].
    a1 < a2 ifTrue: [^#t].
    ^LispNil null!

subrMember: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a2 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for member'].
    ^a2 member: a1!

subrMemq: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a2 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for memq'].
    ^a2 memq: a1!

subrNconc: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for nconc'].
    a1 nconc: a2.
    ^a1!

subrNeq: arguArray 
    | bool |
    ((arguArray at: 1)
	== (arguArray at: 2)) not
	ifTrue: [bool := #t]
	ifFalse: [bool := LispNil null].
    ^bool!

subrNequal: arguArray 
    | bool |
    ((arguArray at: 1)
	= (arguArray at: 2)) not
	ifTrue: [bool := #t]
	ifFalse: [bool := LispNil null].
    ^bool!

subrNth: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: Number)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for nth'].
    (a2 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for nth'].
    ^a2 nth: a1!

subrNull: arguArray 
    ((arguArray at: 1)
	isMemberOf: LispNil)
	ifTrue: [^#t].
    ^LispNil null!

subrNumberp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: Number)
	ifTrue: [^#t].
    ^LispNil null!

subrOblist
    | list |
    list := LispNil null.
    lispTable identifiers reverseDo: [:each | list := LispCons head: each tail: list].
    ^list!

subrPp: arguArray 
    | a pretty |
    a := arguArray at: 1.
    pretty := a ppString.
    textCollector show: pretty.
    ^a!

subrPrinc: arguArray 
    | a |
    a := arguArray at: 1.
    (a isKindOf: String)
	ifTrue: [textCollector show: a]
	ifFalse: [textCollector show: (self printString: a)].
    ^a!

subrPrint: arguArray 
    | a |
    a := self subrPrinc: arguArray.
    textCollector nl.
    ^a!

subrPutprop: arguArray 
    | a1 a2 a3 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    a3 := arguArray at: 3.
    (a1 isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for putprop'].
    (a2 isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for putprop'].
    ^self
	putprop: a1
	key: a2
	value: a3!

subrRemprop: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for remprop'].
    (a2 isKindOf: Symbol)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for remprop'].
    ^self remprop: a1 key: a2!

subrReverse: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a1) , ' for reverse'].
    ^a1 reverse!

subrRplaca: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for rplaca'].
    a1 rplaca: a2.
    ^a1!

subrRplacd: arguArray 
    | a1 a2 |
    a1 := arguArray at: 1.
    a2 := arguArray at: 2.
    (a1 isKindOf: LispCons)
	ifFalse: [^self fatal: 'unexpected argument ' , (self printString: a2) , ' for rplacd'].
    a1 rplacd: a2.
    ^a1!

subrStringp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    ((a1 isKindOf: String)
	and: [(a1 isKindOf: Symbol) not])
	ifTrue: [^#t].
    ^LispNil null!

subrSubrs
    | list |
    list := LispNil null.
    self subrOblist reverse do: [:id | (self getprop: id key: #subr)
	    = LispNil null ifFalse: [list := LispCons head: id tail: list]].
    ^list!

subrSymbolp: arguArray 
    | a1 |
    a1 := arguArray at: 1.
    (a1 isKindOf: Symbol) ifTrue: [^#t].
    ^LispNil null!

subrTerpri
    textCollector nl.
    ^#t! !




