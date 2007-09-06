"======================================================================
|
|   LC_COLLATE support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2007 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

LocaleData subclass: #LcCollate
    instanceVariableNames: 'nrules rules hashSize hashLayers table tableEL undefined extra extraEL'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Collation'!

LcCollate comment: 
'This object is a factory of CollationKey objects; they are obtained by
sending either #? or #collationKeyFor:, with a String as the only argument.

The #? binary message allows for easily typed idioms:

    (aLocale ? string1 < string2) ifTrue: [ ... ]
    
which could be interpreted as "hey, aLocale, tell me if string1 is < string2!"
'!

Magnitude subclass: #LcCollationKey
    instanceVariableNames: 'string locale'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Collation'!

LcCollationKey comment: 
'An LcCollationKey knows how to compare strings according to a specific
locale, and can precompile strings to allow for very fast comparisons (as
fast as traditional non-localized string comparisons).'!

Array variableSubclass: #LcCollationWeightsSet
    instanceVariableNames: 'pass this weight ignoreMask run last idx idxLast delta'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Collation'!

LcCollationWeightsSet comment: 
'An LcCollationWeightsSet is an internal class that represents the
preliminary translation of a string to be compared and the current
position in the translation.'!

Object subclass: #LcCollationWeight
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Collation'!

LcCollationWeight comment:
'LcCollationWeight is just a helper class which stores the values used
by the collator itself; LcCollationWeight is an abstract factory class,
whose class methods create instances of the subclasses.

There are two of them: LcCollationSingleWeight uses single elements
of a locale''s collate-table, while LcCollationMultipleWeights uses multiple
adjiacent elements of a locale''s collate-extra table, and is used a) where
invalid double-byte characters are used, and b) where collation elements
are encountered (e.g. `oe'' in German).'!

Object subclass: #LcCollationSingleWeight
    instanceVariableNames: 'index'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Collation'!

Object subclass: #LcCollationMultipleWeights
    instanceVariableNames: 'number first'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Collation'!

!LcCollate class methodsFor: 'accessing'!

category
    "Answer the C category (and environment variable) corresponding
     to the functionality implemented by this class"
    ^#'LC_COLLATE'!

bigEndianID
    "Answer the id of the data file read by this class if in big-endian
     format"
    ^#[16r96 16r06 16r17 16rDD]!

littleEndianID
    "Answer the id of the data file read by this class if in little-endian
     format"
    ^#[16rDD 16r17 16r06 16r96]! !

!LcCollate methodsFor: 'reading'!

bePosix
    "Set the data for the POSIX locale's collating rules"
    nrules := 0!

readDataFrom: f
    "Read the data for the locale described by the `f' FileStream."
    | totSize |
    nrules := self readWordFrom: f.
    rules := self readWordArrayFrom: f size: nrules.
    hashSize := self readWordFrom: f.
    hashLayers := self readWordFrom: f.
    totSize := hashSize * hashLayers * (nrules + 1).
    table := self
	bigEndianFirst: [ self readWordArrayFrom: f size: totSize ]
	on: f.

    undefined := self readWordFrom: f.

    extra := self
	bigEndianFirst: [ self readWordArrayFrom: f size: (self guessSize: f) / 4 ]
	on: f.
	
    undefined := LcCollationWeight multipleWeights: undefined locale: self.
! !

!LcCollate methodsFor: 'creating CollationKeys'!

collationKeyFor: aString
    "Answer a precompiled collation key for aString, used to do fast
     locale-exact comparisons at the expense of a fixed initial cost."
    ^(self ? aString) precompile; yourself!

? aString
    "Answer a collation key for aString, used to do locale-exact
     comparisons"
    self readData.
    ^LcCollationKey
	on: aString
	for: self! !

!LcCollate methodsFor: 'private - accessing'!

table
    ^table!

extra
    ^extra!

nrules
    ^nrules!

sortPosition: pass
    ^((rules at: pass) bitAnd: 4) > 0!

sortBackward: pass
    ^((rules at: pass) bitAnd: 2) > 0!

sortForward: pass
    ^((rules at: pass) bitAnd: 1) > 0! !

!LcCollate methodsFor: 'private - collation'!

is: st1 lessThan: st2
    | s1 s2 i1 i2 w1 w2 result |
    nrules = 0 ifTrue: [ ^(st1 compareTo: st2) < 0 ].

    s1 := self getWeightsFor: (self charset on: st1).
    s2 := self getWeightsFor: (self charset on: st2).

    nrules timesRepeat: [
	s1 nextPass: self.
	s2 nextPass: self.
	[   i1 := s1 ignoredWeightsFor: self.
	    i2 := s2 ignoredWeightsFor: self.

	    "Rules are:
		- the first coming at the end of the string is less
		- if the sortPosition flag is set, the one with less
		  ignored characters is less; if it is clear, however,
		  LcCollationWeightsSet>>#ignoredWeightsFor: always
		  returns -1.
		- if weights don't match, the one with the least weight
		  is less"

	    i1 isNil
		ifTrue: [
		    i2 isNil ifFalse: [ ^true ].
		    true
		]
		ifFalse: [
		    i2 isNil ifTrue: [ ^false ].
		    i1 = i2 ifFalse: [ ^i1 < i2 ].
		    s1 weight = s2 weight ifFalse: [ ^s1 weight < s2 weight ].
		    false
		]
	] whileFalse.
    ].
    ^false!

computeXformOf: st
    | dest s i |
    nrules = 0 ifTrue: [ ^st ].
    s := self getWeightsFor: (self charset on: st).
    dest := WriteStream on: (ByteArray new: st size * 2).

    nrules timesRepeat: [
	s nextPass: self.
	[   i := s ignoredWeightsFor: self.
	    i isNil
	] whileFalse: [
	    i >= 0
		ifTrue: [ self utfNextPut: i + 1 on: dest ]
		ifFalse: [ self utfNextPut: s weight on: dest ].
	].
	dest nextPut: 0
    ].
    ^dest skip: -1; truncate; contents!

getWeightFor: aStream value: startSlot
    | slot item a delta idx |
    item := table at: startSlot + 2.
    item = self forwardChar ifFalse: [
	"The elements starting at `table at: startSlot + 2' form the
	 collation weights for the character."
	aStream skip: 1.
	^LcCollationWeight singleWeight: startSlot + 2
    ].

    idx := aStream position.
    slot := (table at: startSlot + 3) + 1.
    delta := 0.
    [
	a := extra at: slot + 2 + delta.
	delta := delta + 1.
	a = 0
    ] whileFalse: [
	(aStream atEnd not and: [ a = aStream next ])
	    ifFalse: [
	        "Failed comparison, try the next prefix.  There
		 might be no multi-character collation element that
		 starts with ch, but in the end there will always
		 be the single character ch -- so a match is
		 guaranteed."
		aStream position: idx.
		delta := 0.
		slot := slot + (extra at: slot)
	    ]
    ].

    "We found a prefix, because all the characters of the
     collation element have been used."
    ^LcCollationWeight multipleWeights: slot + delta + 1 locale: self!

getMBWeightFor: aStream
    | levelSize level ch slot idx |
    level := hashLayers - 1.
    levelSize := hashSize * (nrules + 1).
    idx := aStream position.
    ch := aStream next.
    slot := (ch \\ hashSize) * (nrules + 1) + 1.

    [ (table at: slot) = ch ] whileFalse: [
	level := level - 1.
	(level = 0 or: [ (table at: slot + 1) = 0 ])
	    ifTrue: [ ^undefined ]
	    ifFalse: [ slot := slot + levelSize ]
    ].

    aStream position: idx.

    "The last argument to #getWeightFor: is 0-based!!"
    ^self getWeightFor: aStream value: slot - 1!

getWeightsFor: aStream
    "Note: code for the preliminary translation into weights is extremely
     hairy, as it is just a conversion of the glibc implementations of
     locale/weight.h; luckily object-orientation did a good job in
     simplifying and extracting the common code in strcoll and strxfrm."

    | weights w |
    weights := WriteStream on: (LcCollationWeightsSet new: aStream size).

    [ aStream atEnd ] whileFalse: [
	w := self charset isSingleByte
	    ifTrue: [
		"No need to trace multibyte characters..."
		self
		    getWeightFor: aStream
		    value: aStream next * (nrules + 1)
	    ]
	    ifFalse: [
		"Do the full job - there might be collisions"
		self getMBWeightFor: aStream.
	    ].
	
	weights nextPut: w
    ].
    ^weights contents!

forwardChar
    "As found in the table"
    ^-3!

utfNextPut: v on: aStream
    | value c1 c2 c3 c4 c5 c6 |
    value := v.
    value < 16r80 ifTrue: [ ^aStream nextPut: value ].

    c1 := 16r80 + (value bitAnd: 63).
    value := value bitShift: -6.
    value < 16r20
	ifTrue: [ c2 := 16rC0 + value ]
	ifFalse: [
	    c2 := 16r80 + (value bitAnd: 63).
	    value := value bitShift: -6.
	    value < 16r10
		ifTrue: [ c3 := 16rE0 + value ]
		ifFalse: [
		    c3 := 16r80 + (value bitAnd: 63).
		    value := value bitShift: -6.
		    value < 16r08
			ifTrue: [ c4 := 16rF0 + value ]
			ifFalse: [
			    c4 := 16r80 + (value bitAnd: 63).
			    value := value bitShift: -6.
			    value < 16r04
				ifTrue: [ c5 := 16rF8 + value ]
				ifFalse: [
				    c5 := 16r80 + (value bitAnd: 63).
				    c6 := 16rFC + (value bitShift: -6)
				]
			]
		]
	].

    c6 isNil ifFalse: [ aStream nextPut: c6 ].
    c5 isNil ifFalse: [ aStream nextPut: c5 ].
    c4 isNil ifFalse: [ aStream nextPut: c4 ].
    c3 isNil ifFalse: [ aStream nextPut: c3 ].
    aStream nextPut: c2.
    aStream nextPut: c1! !

!LcCollationWeightsSet methodsFor: 'iteration'!

nextPass: aLocale
    | sortPosition sortBackward |
    pass := pass isNil ifTrue: [ 1 ] ifFalse: [ pass + 1 ].

    ignoreMask := (aLocale sortPosition: pass)
	ifTrue: [ 0 ]	 "ignored weights OR 0 = ignored weights, so they count"
	ifFalse: [ -1 ]. "ignored weights OR -1 = -1, so they're meaningless"

    (aLocale sortBackward: pass)
	ifTrue: [ last := 1. run := self size. delta := -1 ]
	ifFalse: [ run := 1. last := self size. delta := 1 ].

    self newRun!

ignoredWeightsFor: aLocale
    | ignore |
    ignore := 0.
    run - delta = last ifTrue: [ ^nil ].

    [   weight := this pass: pass at: idx for: aLocale.
	weight = self ignoreChar
    ] whileTrue: [
	ignore := ignore + 1.
	idx = idxLast
	    ifFalse: [ idx := idx + delta ]
	    ifTrue: [
		run := run + delta.
		run - delta = last ifTrue: [ ^-1 ].
		self newRun
	    ].
    ].

    idx = idxLast
	ifFalse: [ idx := idx + delta ]
	ifTrue: [
	    run := run + delta.
	    run - delta = last ifFalse: [ self newRun ].
	].

    weight < 0 ifTrue: [ weight := self ellipsisChar ].
    ^ignore bitOr: ignoreMask!

ignoreChar
    "As found in the table"
    ^-1!

ellipsisChar
    ^16rFFFFFFFE!

weight
    ^weight! !


!LcCollationWeightsSet methodsFor: 'private'!

newRun
    this := self at: run.
    delta > 0
	ifTrue: [ idx := 1. idxLast := this numberAtPass: pass ]
	ifFalse: [ idxLast := 1. idx := this numberAtPass: pass ]! !

!LcCollationWeight class methodsFor: 'instance creation'!

singleWeight: slot
    ^LcCollationSingleWeight new index: slot!

multipleWeights: slot locale: aLocale
    ^LcCollationMultipleWeights new
	passes: aLocale nrules
	index: slot
	for: aLocale! !

!LcCollationWeight methodsFor: 'accessing'!

numberAtPass: cnt
    self subclassResponsibility!

pass: cnt at: n for: aLocale
    self subclassResponsibility! !

!LcCollationSingleWeight class methodsFor: 'accessing'!

index: firstIndex
    ^self new index: firstIndex! !

!LcCollationSingleWeight methodsFor: 'accessing'!

index: firstIndex
    "Decrement to account for pass number starting at 1"
    index := firstIndex - 1!

numberAtPass: cnt
    ^1!

pass: cnt at: n for: aLocale
    ^aLocale table at: index + cnt! !

!LcCollationMultipleWeights methodsFor: 'accessing'!

numberAtPass: cnt
    ^number at: cnt!

passes: n index: slot for: aLocale
    | idx numValues extra |
    number := Array new: n.
    first := Array new: n.

    idx := slot + 1.
    extra := aLocale extra.
    1 to: n do: [ :cnt |
	numValues := extra at: idx.
	number at: cnt put: numValues.

	"Don't increment to account for indices starting at 1"
	first at: cnt put: idx.
	idx := idx + numValues + 1.
    ]!

pass: cnt at: n for: aLocale
    ^aLocale extra at: (first at: cnt) + n! !

!LcCollationKey class methodsFor: 'instance creation'!

new
    self shouldNotImplement!

on: aString for: aLocale
    "Answer a new collation key for aString, that compares according
     to the aLocale locale."
    ^self basicNew
	initialize: aString
	locale: aLocale! !

!LcCollationKey methodsFor: 'comparison'!

< anObject
    "Answer whether the receiver collates before anObject, which
     can be a string or another LcCollationKey.  If a precompiled
     representation of the receiver is available, anObject is
     precompiled as well and the comparison is done on the
     fast representation; otherwise a direct comparison is made."
    | collationKey c1 xform1 c2 xform2 |
    collationKey := self isPrecompiled
	ifTrue: [
	    anObject isString
		ifTrue: [ self locale ? anObject ]
		ifFalse: [ anObject ].
	]
	ifFalse: [
	    anObject isString
		ifTrue: [ ^locale is: string lessThan: anObject ].

	    anObject.
	].

    "Answer whether the receiver's xform is less than anotherXform."
    xform1 := self xform.
    xform2 := collationKey xform.
    1 to: (xform1 size min: xform2 size) do: [ :i |
	c1 := xform1 at: i.
	c2 := xform2 at: i.
	c1 = c2 ifFalse: [ ^c1 < c2 ].
    ].
    ^xform1 size < xform2 size!

= anObject
    "Answer whether the receiver and anObject collect the same
     (for example StraBe and Strasse in the German locale)"
    | collationKey |
    collationKey := anObject isString
	ifTrue: [ self locale ? anObject ]
	ifFalse: [ anObject ].

    ^self xform = collationKey xform!

hash
    "Answer an hash value for the receiver"
    ^self xform hash!

!LcCollationKey methodsFor: 'accessing'!

isPrecompiled
    "Answer whether a precompiled representation of the string
     is already available."
    ^string isString not!

locale
    "Answer the locale in which the comparison is to be done"
    ^locale!

precompile
    "Compute a precompiled representation of the string which
     the receiver refers to." 
    self xform! !

!LcCollationKey methodsFor: 'private'!

xform
    self isPrecompiled ifTrue: [ ^string ].
    ^string := locale computeXformOf: string!

initialize: aString locale: aLocale
    string := aString.
    locale := aLocale! !
