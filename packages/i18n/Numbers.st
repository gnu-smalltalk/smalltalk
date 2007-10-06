"======================================================================
|
|   LC_NUMERIC and LC_MONETARY support
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002 Free Software Foundation, Inc.
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



LcPrintFormats subclass: LcNumeric [
    | decimalPoint thousandsSep grouping |
    
    <comment: 'Sending either #?, #printString: or #print:on: converts a Number to
a String according to the rules that are used in the given locale.'>
    <category: 'i18n-Printing'>

    LcNumeric class >> category [
	"Answer the environment variable used to determine the default
	 locale"

	<category: 'accessing'>
	^#LC_NUMERIC
    ]

    LcNumeric class >> selector [
	"Answer the selector that accesses the receiver when sent to a Locale
	 object."

	<category: 'accessing'>
	^#numeric
    ]

    basicPrint: aNumber on: aStream [
	"Print aNumber on aStream according to the receiver's
	 formatting conventions, without currency signs or
	 anything like that.  This method must not be overridden."

	<category: 'printing'>
	| n nonLocalized stream decimal |
	nonLocalized := aNumber asBasicNumberType printString.
	decimal := nonLocalized indexOf: $. ifAbsent: [nonLocalized size + 1].
	stream := ReadWriteStream on: nonLocalized.
	stream
	    position: decimal;
	    truncate;
	    reset.
	self 
	    printIntegerPart: stream
	    size: decimal - 1
	    on: aStream.
	self 
	    printFractionalPart: nonLocalized
	    startingAt: decimal + 1
	    on: aStream
    ]

    print: aNumber on: aStream [
	"Print aNumber on aStream according to the receiver's
	 formatting conventions."

	<category: 'printing'>
	self basicPrint: aNumber on: aStream
    ]

    printIntegerPart: stream size: size on: aStream [
	<category: 'private'>
	| groupings left |
	(thousandsSep isEmpty or: [grouping isEmpty]) 
	    ifTrue: 
		[aStream nextPutAll: stream contents.
		^self].
	groupings := self computeGroupSizes: size.
	left := size.
	groupings reverseDo: 
		[:num | 
		left := left - num.
		num timesRepeat: [aStream nextPut: stream next].
		left > 0 ifTrue: [aStream nextPutAll: thousandsSep]]
    ]

    computeGroupSizes: size [
	<category: 'private'>
	| howMany foundZero n left |
	howMany := self computeNumberOfGroups: size.
	left := size.
	howMany = 0 ifTrue: [^Array with: size].
	^(1 to: howMany) collect: 
		[:index | 
		| next |
		index > grouping size ifFalse: [n := grouping at: index].
		n = 255 ifTrue: [n := left].
		left := left - n.
		left < 0 ifTrue: [left + n] ifFalse: [n]]
    ]

    computeNumberOfGroups: size [
	<category: 'private'>
	| left last n |
	left := size.
	n := 0.
	grouping isEmpty ifTrue: [^0].
	grouping do: 
		[:each | 
		n := n + 1.
		each >= 255 ifTrue: [^n].
		left < each ifTrue: [^n].
		left := left - each.
		last := each].
	^n + (left // last)
    ]

    printFractionalPart: string startingAt: decimal on: aStream [
	<category: 'private'>
	decimal > string size ifTrue: [^self].
	aStream nextPutAll: decimalPoint.
	aStream nextPutAll: (string copyFrom: decimal to: string size)
    ]
]



LcNumeric subclass: LcMonetary [
    | currencySymbol positiveSign negativeSign fracDigits pCsPrecedes pSepBySpace nCsPrecedes nSepBySpace pSignPosn nSignPosn |
    
    <comment: 'Sending either #?, #printString: or #print:on: converts a Number to
a String according to the rules that are mandated by ISO for printing
currency amounts in the current locale.'>
    <category: 'i18n-Printing'>

    LcMonetary class >> category [
	"Answer the environment variable used to determine the default
	 locale"

	<category: 'accessing'>
	^#LC_MONETARY
    ]

    LcMonetary class >> selector [
	"Answer the selector that accesses the receiver when sent to a Locale
	 object."

	<category: 'accessing'>
	^#monetary
    ]

    print: aNumber on: aStream [
	"Print aNumber on aStream according to the receiver's
	 formatting conventions.  Always print a currency sign
	 and don't force to print negative numbers by putting
	 parentheses around them."

	<category: 'printing'>
	self 
	    print: aNumber
	    on: aStream
	    currency: true
	    parentheses: false
    ]

    print: aNumber on: aStream currency: currency parentheses: p [
	"Print aNumber on aStream according to the receiver's
	 formatting conventions.  If currency is true, print a
	 currency sign, and if p is true force to print negative
	 numbers by putting parentheses around them.  If p is true,
	 for positive numbers spaces are put around the number
	 to keep them aligned."

	<category: 'printing'>
	| signChar signPos csPrecedes sepBySpace paren |
	paren := p.
	aNumber < 0 
	    ifTrue: 
		[csPrecedes := nCsPrecedes.
		sepBySpace := nSepBySpace.
		signPos := nSignPosn.
		signChar := negativeSign.
		signPos = 0 ifTrue: [paren := true].
		paren ifTrue: [signChar := '()']]
	    ifFalse: 
		[csPrecedes := pCsPrecedes.
		sepBySpace := pSepBySpace.
		signPos := pSignPosn.
		signChar := positiveSign.

		"Contrast paren = true with signPos = 0: the former
		 prints spaces, the latter prints nothing for positive
		 numbers!"
		paren ifTrue: [signChar := '  ']].

	"Set default values and tweak signPos if parentheses are needed"
	paren ifTrue: [signPos := 0].
	paren ifTrue: [aStream nextPut: (signChar at: 1)].
	signPos = 1 ifTrue: [aStream nextPutAll: signChar].
	csPrecedes 
	    ifTrue: 
		[signPos = 3 ifTrue: [aStream nextPutAll: signChar].
		currency 
		    ifTrue: 
			[aStream nextPutAll: currencySymbol.
			sepBySpace ifTrue: [aStream space]].
		signPos = 4 ifTrue: [aStream nextPutAll: signChar]].
	self basicPrint: aNumber abs on: aStream.
	csPrecedes 
	    ifFalse: 
		[signPos = 3 ifTrue: [aStream nextPutAll: signChar].
		currency 
		    ifTrue: 
			[sepBySpace ifTrue: [aStream space].
			aStream nextPutAll: currencySymbol].
		signPos = 4 ifTrue: [aStream nextPutAll: signChar]].
	signPos = 2 ifTrue: [aStream nextPutAll: signChar].
	paren ifTrue: [aStream nextPutAll: (signChar at: 2)]
    ]

    printFractionalPart: string startingAt: decimal on: aStream [
	<category: 'private'>
	| last zeros digits |
	fracDigits = 0 ifTrue: [^self].
	fracDigits = 127 ifTrue: [^self].
	last := decimal + fracDigits - 1.
	zeros := last - string size max: 0.
	aStream
	    nextPutAll: decimalPoint;
	    nextPutAll: (string copyFrom: decimal to: last - zeros);
	    next: zeros put: $0
    ]
]



LcMonetary subclass: LcMonetaryISO [
    
    <comment: nil>
    <category: 'i18n-Printing'>

    LcMonetaryISO class >> selector [
	"Answer the selector that accesses the receiver when sent to a Locale
	 object."

	<category: 'accessing'>
	^#monetaryIso
    ]
]



Number extend [

    asBasicNumberType [
	<category: 'coercion'>
	^self asFloat
    ]

]



Integer extend [

    asBasicNumberType [
	<category: 'coercion'>
	^self
    ]

]



Float extend [

    asBasicNumberType [
	<category: 'coercion'>
	^self
    ]

]

