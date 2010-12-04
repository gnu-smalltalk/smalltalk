"======================================================================
|
|   Base encodings including Unicode (ISO10646)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2005, 2006, 2007, 2008 Free Software Foundation, Inc.
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


Namespace current: I18N.Encoders [

FromUTF32 subclass: ToUTF7 [
    | left value lookahead |
    
    <category: 'i18n-Encodings'>
    <comment: 'This class implements a converter that transliterates UTF-7
encoded characters to UTF-32 values (encoded as 32-bit Integers).'>

    Base64Characters := nil.
    DirectCharacters := nil.
    ToBase64 := nil.

    ToUTF7 class >> initialize [
	"Initialize the tables used by the UTF-32-to-UTF-7 converter"

	<category: 'initialization'>
	Base64Characters := #[0 0 0 0 0 168 255 3 254 255 255 7 254 255 255 7].

	"Table of direct characters"
	DirectCharacters := #[0 38 0 0 129 243 255 135 254 255 255 7 254 255 255 7].
	ToBase64 := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    ]

    isBase64: anInteger [
	<category: 'private'>
	| d |
	^anInteger < 128 and: 
		[d := Base64Characters at: anInteger // 8 + 1.
		((d bitShift: 0 - (anInteger \\ 8)) bitAnd: 1) == 1]
    ]

    isDirect: anInteger [
	<category: 'private'>
	| d |
	^anInteger < 128 and: 
		[d := DirectCharacters at: anInteger // 8 + 1.
		((d bitShift: 0 - (anInteger \\ 8)) bitAnd: 1) == 1]
    ]

    toBase64Char: anInteger [
	<category: 'private'>
	^ToBase64 at: anInteger + 1
    ]

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'conversion'>
	^left == 0 and: [self atEndOfInput]
    ]

    flush [
	"Flush any remaining bytes in the last 32-bit character read from
	 the input"

	<category: 'conversion'>
	left := 0
    ]

    next [
	"Answer the next character that the receiver can produce."

	<category: 'conversion'>
	| ch next |
	left = 0 
	    ifTrue: 
		["Base64 encoding inactive"

		ch := self nextInput codePoint.
		(self isDirect: ch) ifTrue: [^ch asCharacter].
		ch = 43 
		    ifTrue: 
			[left := -256.
			lookahead := $-.
			^$+].
		ch < 65536 
		    ifTrue: 
			[left := 16.
			value := ch.
			^$+].
		"ch >= 1114112 ifTrue: [InvalidSequenceError signal]."

		"Convert to a surrogate pair.  First character is always $2.
                 Compare with the other surrogate pair case below."
		left := ##(26 bitOr: -256).
		lookahead := 50. "(self toBase64: 16r36) asInteger"
		value := ((ch bitAnd: 16r1FFFC00) bitShift: 6)
                            + (ch bitAnd: 16r3FF)
			    + ##(16rDC00 - 16r400000).
		^$+].
	left < 0 
	    ifTrue: 
		["if at end of input output -.  otherwise:
		 left = -256..-1 ---> output the lookahead character and go to
                 (left bitAnd: 255).
		 left = -512 ---> if there's no lookahead, output $-.  if there
                 is lookahead and $- needed, output $- and go to -256; if there
                 is lookahead but no $- needed, output lookahead and go to 0"

		lookahead isNil 
		    ifTrue: 
			[left := 0.
			self atEndOfInput ifTrue: [^$-]]
		    ifFalse: 
			[ch := lookahead.
			^(left = -512 and: [self isBase64: ch]) 
			    ifTrue: 
				[left := -256.
				$-]
			    ifFalse: 
				[lookahead := nil.
				left := left bitAnd: 255.
				ch asCharacter]]].
	left < 6 
	    ifTrue: 
		["Pump another character into the Base64 encoder"

		(self atEndOfInput or: [self isDirect: (ch := self nextInput codePoint)]) 
		    ifTrue: 
			[lookahead := ch.
			left = 0 ifTrue: [left := -256. ^$-].
			"Terminate the stream by left-aligning the last byte"
			value := value bitShift: 6 - left.
			left := 6]
		    ifFalse: 
			[ch < 65536 
			    ifTrue: 
				[left := left + 16.
				value := (value bitShift: 16) + ch]
			    ifFalse: 
				["ch >= 1114112 ifTrue: [InvalidSequenceError signal]."

                                "Inline the computation of the next base64
                                 character to avoid creating LargeIntegers.
                                 16r36 is the high 6 bits of 16rD800.  Bits
                                 that do not fit in `next' are placed in
                                 `value' below (with 16r18000000 bitAnd: ...)."
                                next := ((value bitShift: 6) + 16r36) bitShift: 0 - left.
                                "Here 16rD8000000 would be necessary, but we
                                 know left > 0 so the first two bits will never
                                 be used.  This avoids LargeInteger math."
                                value := (16r18000000 bitAnd: (16r3C00000 bitShift: left))
				         + ((ch bitAnd: 16r1FFC00) bitShift: 6)
                                         + (ch bitAnd: 16r3FF)
					 + ##(16rDC00 - 16r400000).

				left := left + 26.
                                ^self toBase64Char: next]]].

	"Take 6 bits out of the Base-64 encoded stream"
	left := left - 6.
	next := value bitShift: 0 - left.
	value := value bitXor: (next bitShift: left).

	"Exit base64 if at end of input or next char is direct."
	left = 0 ifTrue: [left := -512].
	^self toBase64Char: next
    ]
]

]



Namespace current: I18N.Encoders [

ToUTF32 subclass: FromUTF7 [
    | shift wch lookahead |
    
    <category: 'i18n-Encodings'>
    <comment: nil>

    DirectCharacters := nil.
    FromBase64 := nil.

    FromUTF7 class >> initialize [
	"Initialize the tables used by the UTF-7-to-UTF-32 converter"

	<category: 'initialization'>
	FromBase64 := #[62 99 99 99 63 52 53 54 55 56 57 58 59 60 61 99 99 99 99 99 99 99 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 99 99 99 99 99 99 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51].
	DirectCharacters := #[0 38 0 0 255 247 255 255 255 255 255 239 255 255 255 63 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    ]

    isDirect: anInteger [
	<category: 'private'>
	| d |
	^anInteger < 128 and: 
		[d := DirectCharacters at: anInteger // 8 + 1.
		((d bitShift: 0 - (anInteger \\ 8)) bitAnd: 1) == 1]
    ]

    fromBase64Char: aCharacter [
	<category: 'private'>
	^FromBase64 at: aCharacter - 42
    ]

    atEnd [
	"Answer whether the receiver can produce another UTF-32 32-bit
	 encoded integer"

	<category: 'converting'>
	^lookahead isNil
    ]

    next [
	"Answer the next character that the receiver can produce."

	<category: 'converting'>
	| ch |
	lookahead isNil 
	    ifTrue: 
		[SystemExceptions.EndOfStream signal: self.
		^nil].
	ch := lookahead.
	self getNext.
	^ch
    ]

    flush [
	"Flush any remaining state left in the encoder by the last character
	 (this is because UTF-7 encodes 6 bits at a time, so it takes three
	 characters before it can provide a single 16-bit character and
	 up to six characters before it can provide a full UTF-32 character)."

	<category: 'converting'>
	shift := -6.
	wch := 0.
	self getNext
    ]

    getNext [
	<category: 'private - converting'>
	
	[self atEndOfInput 
	    ifTrue: 
		[(shift = -6 or: [shift = 10]) 
		    ifFalse: 
			[shift := -6.
			wch := 0.
			InvalidSequenceError signal].
		lookahead := nil.
		^self].
	(lookahead := self readNext) isNil] 
		whileTrue
    ]

    readNext [
	"The decoder will always decode a character ahead, because when we
	 are to read only a minus, we might already be at the end of the
	 stream! Here is a simple example: +AFs- which decodes to [
	 We read + and switch to base-64 --> shift = 10
	 We read A and put it into the accumulator --> shift = 4
	 We read F and put it into the accumulator --> shift = -2 *next is last*
	 We read s and put it into the accumulator --> shift = 8
	 
	 We then decode the [ and return it.  Now we are not
	 #atEndOfInput yet, but there are no more characters to
	 give away!  Since we are not sure that the source supports
	 #peek, our only other option would be to implement peeking
	 for it and check for $- now.  This would have an overhead
	 proportional to the number of input characters (to check
	 whether we have already peeked the next characters), while
	 our choice's overhead is proportional to the number of output
	 characters, which is always less in UTF-7."

	<category: 'private - converting'>
	| ch value wc1 |
	ch := self nextInput value.
	shift = -6 
	    ifTrue: 
		[(self isDirect: ch) ifTrue: [^Character codePoint: ch].
		ch == 43 
		    ifFalse: 
			["plus"

			InvalidSequenceError signal].
		ch := self nextInput value.
		ch == 45 
		    ifTrue: 
			["minus"

			^$+].

		"Else switch into base64 mode"
		shift := 10].
	((ch between: 43 and: 122) and: [(value := self fromBase64Char: ch) < 99]) 
	    ifFalse: 
		["Terminate base64 encoding.
		 If accumulated data is nonzero, the input is invalid.
		 Also, partial UTF-16 characters are invalid."

		(shift <= 4 or: [wch > 0]) 
		    ifTrue: 
			[shift := -6.
			wch := 0.
			InvalidSequenceError signal].
		shift := -6.

		"Discard a -"
		ch = 45 
		    ifTrue: 
			["minus"

			^nil].
		(self isDirect: ch) ifFalse: [InvalidSequenceError signal].
		^Character codePoint: ch].
	shift > 0 
	    ifTrue: 
		["Concatenate the base64 integer value to the accumulator"

		wch := wch + (value bitShift: shift).
		shift := shift - 6.
		^nil].
	wc1 := wch + (value bitShift: shift).
	wch := (value bitShift: shift + 16) bitAnd: 16rFC00.
	shift := shift + 10.
	wc1 < 16rD800 ifTrue: [^Character codePoint: wc1].
	wc1 < 16rDC00 
	    ifTrue: 
		["After a High Surrogate, leave bits 20..10 of the Unicode
                  character being encoded in bits 26..16 of wch; the offset
                  wc1 - D7C0 = wc1 - D800 + (16r10000 bitShift: -10).  Then
                  wait for the Low Surrogate."

		wch := wch + ((wc1 - 16rD7C0) bitShift: 16).
		^nil].
	wc1 <= 16rDFFF ifTrue: [^InvalidSequenceError signal].
	wc1 <= 16rFFFF ifTrue: [^Character codePoint: wc1].

	"We have read the UTF-16 element after an High Surrogate.  Verify that
	 it is is indeed a Low Surrogate, and return the resulting character."
	((wc1 bitAnd: 16rFFFF) between: 16rDC00 and: 16rDFFF)
	    ifFalse: [^InvalidSequenceError signal].
	wc1 := ((wc1 bitAnd: 16r7FF0000) bitShift: -6) + (wc1 bitAnd: 16r3FF).
	^Character codePoint: wc1
    ]
]

]

Namespace current: I18N [
    Encoders.ToUTF7 initialize.
    Encoders.FromUTF7 initialize.
    EncodedStream
	registerEncoderFor: #('UTF7' 'UTF-7')
	toUTF32: Encoders.FromUTF7
	fromUTF32: Encoders.ToUTF7
]
