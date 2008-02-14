"=====================================================================
|
|   Generic database interface - FieldConverter class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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
 ======================================================================
"


Object subclass: FieldConverter [
    
    <category: 'DBI'>
    <comment: nil>

    FieldConverter class [
	| uniqueInstance |
	uniqueInstance [
	    <category: 'instance creation'>
	    uniqueInstance isNil
		ifTrue: [ uniqueInstance := self basicNew initialize ].
	    ^uniqueInstance
	]

	new [
	    <category: 'instance creation'>
	    self error: 'use uniqueInstance instead'
	]
    ]

    | converterSelectors |

    writeBoolean: aBoolean on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        aBoolean printOn: aStream.
	aStream nextPut: $'.
    ]

    writeQuotedDate: aDate on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        self writeDate: aDate on: aStream.
	aStream nextPut: $'.
    ]

    writeQuotedTime: aDate on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        self writeTime: aDate on: aStream.
	aStream nextPut: $'.
    ]

    writeDate: aDate on: aStream [
        <category: 'converting-smalltalk'>
        aDate printOn: aStream.
    ]

    writeFloat: aFloat on: aStream [
        <category: 'converting-smalltalk'>
        | readStream character |
	aStream nextPut: $'.
        readStream := ReadStream on: aFloat asFloat printString.

        [character := readStream next.
        character isNil] whileFalse:
                    [(character = $d
                        or: [ character = $e
                        or: [ character = $q ]])
                            ifTrue:
                                [character := readStream next.
                                character isNil ifTrue: [^self].
                                aStream nextPut: $e.
                                character = $- ifFalse: [aStream nextPut: $+]].
                    aStream nextPut: character].
	aStream nextPut: $'.
    ]

    writeDateTime: aDateTime on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        self writeDate: aDateTime asDate on: aStream.
        aStream nextPut: $ .
        self writeTime: aDateTime asTime on: aStream.
	aStream nextPut: $'.
    ]

    writeInteger: anInteger on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        anInteger printOn: aStream.
	aStream nextPut: $'.
    ]

    writeTime: aTime on: aStream [
        <category: 'converting-smalltalk'>
        aTime printOn: aStream.
    ]

    printString: aValue [
        <category: 'actions'>
        | writeStream |
        writeStream := WriteStream on: String new.
        self print: aValue on: writeStream.
        ^writeStream contents
    ]

    print: aValue on: aStream [
        <category: 'actions'>
        | aSelector |
	aValue isNil ifTrue: [ aStream nextPutAll: 'NULL'. ^self ].
        aSelector := converterSelectors at: aValue class
                    ifAbsent: [ #defaultConvert:on: ].
        self
            perform: aSelector
            with: aValue
            with: aStream.
    ]

    defaultConvert: aValue on: aStream [
        | writeStream readStream ch |
	aStream nextPut: $'.
	aValue isString
	    ifTrue: [ readStream := aValue readStream ]
	    ifFalse: [
		writeStream := WriteStream on: String new.
		aValue displayOn: writeStream.
		readStream := writeStream readStream ].

	[ readStream atEnd ] whileFalse: [
	    ch := readStream next.
	    ch = $' ifTrue: [ aStream nextPut: $' ].
	    ch = $\ ifTrue: [ aStream nextPut: $\ ].
	    aStream nextPut: ch
	].
	aStream nextPut: $'.
    ]

    buildConversionMap [
        <category: 'private-initialize'>
        converterSelectors := IdentityDictionary new.
        converterSelectors
            at: Boolean put: #writeBoolean:on:;
            at: FloatD put: #writeFloat:on:;
            at: FloatE put: #writeFloat:on:;
            at: FloatQ put: #writeFloat:on:;
            at: Fraction put: #writeFloat:on:;
            at: Integer put: #writeInteger:on:;
            at: Date put: #writeQuotedDate:on:;
            at: DateTime put: #writeDateTime:on:;
            at: Time put: #writeQuotedTime:on:
    ]

    initialize [
        <category: 'private-initialize'>
	self buildConversionMap
    ]
]
