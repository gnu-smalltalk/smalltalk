"======================================================================
|
|   Iconv module unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Stephen Compall
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



TestCase subclass: IconvTest [
    
    <comment: nil>
    <category: 'Examples-Useful'>

    testStringNumberOfCharacters [
	<category: 'test'>
	self assert: ($<16r0438> asString: 'UTF-8') numberOfCharacters = 1.
	self assert: ($<16rFFFE> asString: 'UTF-8') numberOfCharacters = 1.
	self 
	    assert: ((UnicodeString new: 10) atAllPut: $<16r0438>) asString 
		    numberOfCharacters = 10
    ]

    testUnicodeStringNumberOfCharacters [
	<category: 'test'>
	self assert: $<16r0438> asUnicodeString numberOfCharacters = 1.
	self assert: $<16rFFFE> asUnicodeString numberOfCharacters = 1.
	self 
	    assert: ((UnicodeString new: 10) atAllPut: $<16r0438>) numberOfCharacters 
		    = 10
    ]

    testUnicodeCharAsStringColon [
	<category: 'test'>
	self assert: ($<16r0438> asString: 'UTF-8') = #[208 184] asString.
	self assert: ($<16rFFFE> asString: 'UTF-8') = #[239 191 190] asString.
	self assert: ($<16r0438> asString: 'KOI8-R') first value = 201.
	self assert: ($<16r0438> asString: 'KOI8-R') first class = Character.
	self deny: ($<16r0438> asString: 'KOI8-R') first = $<16r00C9>
    ]

    testEncodedStringSize [
	<category: 'test'>
	| str |
	str := EncodedString fromString: (String with: (Character value: 233))
		    encoding: 'KOI8-R'.
	self assert: str size = 1.
	str := EncodedString fromString: #[216 0 220 0] asString
		    encoding: 'UTF-16BE'.
	self assert: str size = 4
    ]

    testEncodedStringNumberOfCharacters [
	<category: 'test'>
	| str |
	str := EncodedString fromString: (String with: (Character value: 233))
		    encoding: 'KOI8-R'.
	self assert: str numberOfCharacters = 1.
	str := EncodedString fromString: #[216 0 220 0] asString
		    encoding: 'UTF-16BE'.
	self assert: str numberOfCharacters = 1.

	"Test that the BOM is skipped for both big- and little-endian UTF-16."
	str := EncodedString fromString: (String new: 2) encoding: 'UTF-16'.
	str valueAt: 1 put: 254; valueAt: 2 put: 255.
	self assert: str numberOfCharacters = 0.
	str valueAt: 1 put: 255; valueAt: 2 put: 254.
	self assert: str numberOfCharacters = 0
    ]

    testEncodedStringAsUnicodeString [
	<category: 'test'>
	| str |
	str := EncodedString fromString: (String with: (Character value: 233))
		    encoding: 'KOI8-R'.
	self assert: str asUnicodeString first = $<16r0418>
    ]

    testCharAsStringColon [
	<category: 'test'>
	| ch |
	ch := Character value: 233.
	self assert: (ch asString: 'KOI8-R') encoding = 'KOI8-R'.
	self deny: (ch asString: 'KOI8-R') = (ch asString: 'ISO-8859-1')
    ]

    testCharAsUnicodeStringColon [
	<category: 'test'>
	| ch |
	ch := Character value: 233.
	self assert: (ch asUnicodeString: 'KOI8-R') first = $<16r0418>
    ]

    testStringAsUnicodeStringColon [
	<category: 'test'>
	| str |
	str := (Character value: 233) asString.
	self assert: (str asUnicodeString: 'KOI8-R') first = $<16r0418>.
	self assert: (str asUnicodeString: 'ISO-8859-1') first = $<16r00E9>.
	str := #[239 191 190] asString.
	self assert: (str asUnicodeString: 'UTF-8') first = $<16rFFFE>.
	str := #[208 184] asString.
	self assert: (str asUnicodeString: 'UTF-8') first = $<16r0438>.
	self assert: ('' asUnicodeString: 'UTF-8') isEmpty
    ]

    testByteArrayAsUnicodeStringColon [
	<category: 'test'>
	| str |
	str := #[233].
	self assert: (str asUnicodeString: 'KOI8-R') first = $<16r0418>.
	self assert: (str asUnicodeString: 'ISO-8859-1') first = $<16r00E9>.
	str := #[239 191 190].
	self assert: (str asUnicodeString: 'UTF-8') first = $<16rFFFE>.
	str := #[208 184].
	self assert: (str asUnicodeString: 'UTF-8') first = $<16r0438>.
	self assert: (#[] asUnicodeString: 'UTF-8') isEmpty
    ]

    testFromUTF7 [
	<category: 'test'>
	| str |
	self assert: ('+-' asUnicodeString: 'UTF-7') first = $+.
	self assert: ('+BBg-' asUnicodeString: 'UTF-7') first = $<16r0418>.
	self assert: ('+BBgEOA-' asUnicodeString: 'UTF-7') second = $<16r0438>.
	self assert: ('+BBgEOAQZ-' asUnicodeString: 'UTF-7') third = $<16r0419>.
	self assert: ('+2//f/w-' asUnicodeString: 'UTF-7') size = 1.
	self assert: ('+2//f/w-' asUnicodeString: 'UTF-7') first = $<16r10FFFF>.
	self assert: ('+BDjb/9//-' asUnicodeString: 'UTF-7') size = 2.
	self assert: ('+BDjb/9//-' asUnicodeString: 'UTF-7') last = $<16r10FFFF>.
	self assert: ('+BDgEGNv/3/8-' asUnicodeString: 'UTF-7') size = 3.
	self 
	    assert: ('+BDgEGNv/3/8-' asUnicodeString: 'UTF-7') last = $<16r10FFFF>.

	"Test exiting Base64 mode with a non-Base64 character."
	str := 'A+ImIDkQ.' asUnicodeString: 'UTF-7'.
	self assert: str size = 4.
	self assert: str first = $A.
	self assert: str second = $<16r2262>.
	self assert: str third = $<16r0391>.
	self assert: str last = $..

	"Test handling of optional direct characters."
	self shouldnt: ['#' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['\' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['~' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['+BBgA' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['+BBg\' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError
    ]

    testToUTF7 [
	<category: 'test'>
	| str |
	self assert: ((UnicodeString with: $+) asString: 'UTF-7') asString = '+-'.
	str := UnicodeString with: $<16r0418>.
	self assert: (str asString: 'UTF-7') encoding = 'UTF-7'.
	self assert: (str asString: 'UTF-7') asString = '+BBg-'.
	self assert: ((str copyWith: $.) asString: 'UTF-7') asString = '+BBg.'.
	self assert: ((str copyWith: $-) asString: 'UTF-7') asString = '+BBg--'.
	self assert: ((str copyWith: $A) asString: 'UTF-7') asString = '+BBg-A'.
	str := str copyWith: $<16r0438>.
	self assert: (str asString: 'UTF-7') asString = '+BBgEOA-'.
	str := str copyWith: $<16r0419>.
	self assert: (str asString: 'UTF-7') asString = '+BBgEOAQZ-'.
	str := UnicodeString with: $<16r10FFFE>.
	self assert: (str asString: 'UTF-7') asString = '+2//f/g-'.
	str := (UnicodeString with: $<16r0438>), str.
	self assert: (str asString: 'UTF-7') asString = '+BDjb/9/+-'.
	str := (UnicodeString with: $<16r0438>), str.
	self assert: (str asString: 'UTF-7') asString = '+BDgEONv/3/4-'.

	"Test that, if there are no bits left to emit, we exit base64 immediately."
	str := UnicodeString with: $<12376> with: $<12435> with: $\ with: $u.
	self assert: (str asString: 'UTF-7') asString = '+MFgwkwBc-u'
    ]

    testRoundTrip [
	<category: 'test'>
	| s |
	s := String new: 1 withAll: $x.
	self assert: (s asUnicodeString asString: 'UTF-8') = s.
	s := String new: 1024 withAll: $x.
	self assert: (s asUnicodeString asString: 'UTF-8') = s.
	s := String new: 1025 withAll: $x.
	self assert: (s asUnicodeString asString: 'UTF-8') = s.
	s := UnicodeString new: 1 withAll: $x.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1024 withAll: $x.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1025 withAll: $x.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1025 withAll: $<16r4000>.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1025 withAll: $<16r4000>.
	self assert: (s asString: 'UTF-8') asUnicodeString = s
    ]

    testExceptions [
	<category: 'test'>
	| b |
	self should: [ #[228] asUnicodeString ] raise: IncompleteSequenceError.
	self should: [ #[128] asUnicodeString ] raise: InvalidSequenceError.
	self should: [ #[228 128] asUnicodeString ] raise: IncompleteSequenceError.

	"On some OSes we return IncompleteSequenceError for the following."
	"self should: [ #[228 228] asUnicodeString ] raise: InvalidSequenceError."

	b := ByteArray new: 1026.
	b atAll: (1 to: 1026 by: 3) put: 228.
	b atAll: (2 to: 1026 by: 3) put: 128.
	b atAll: (3 to: 1026 by: 3) put: 128.
	self shouldnt: [ b asUnicodeString ] raise: IncompleteSequenceError.

	b := b copyFrom: 1 to: 1025.
	self should: [ b asUnicodeString ] raise: IncompleteSequenceError.

	b at: 1025 put: 228.
	"On some OSes we return IncompleteSequenceError for the following."
	"self should: [ b asUnicodeString ] raise: InvalidSequenceError."

	b := b copyFrom: 1 to: 1024.
	self should: [ b asUnicodeString ] raise: IncompleteSequenceError.
    ]
]

