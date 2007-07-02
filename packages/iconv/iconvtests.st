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

TestCase subclass: #IconvTest
         instanceVariableNames: ''
         classVariableNames: ''
         poolDictionaries: ''
         category: 'Examples-Useful'!

!IconvTest methodsFor: 'test'!

testStringNumberOfCharacters
    self assert: ($<16r438> asString: 'UTF-8') numberOfCharacters = 1.
    self assert: ($<16rFFFE> asString: 'UTF-8') numberOfCharacters = 1.
    self assert: ((UnicodeString new: 10) atAllPut: $<16r438>) asString
		 numberOfCharacters = 10!

testUnicodeStringNumberOfCharacters
    self assert: $<16r438> asUnicodeString numberOfCharacters = 1.
    self assert: $<16rFFFE> asUnicodeString numberOfCharacters = 1.
    self assert: ((UnicodeString new: 10) atAllPut: $<16r438>)
		 numberOfCharacters = 10!

testUnicodeCharAsStringColon
    self assert: ($<16r438> asString: 'UTF-8') = #[208 184] asString.
    self assert: ($<16rFFFE> asString: 'UTF-8') = #[239 191 190] asString.
    self assert: ($<16r438> asString: 'KOI8-R') first value = 201.
    self assert: ($<16r438> asString: 'KOI8-R') first class = Character.
    self deny: ($<16r438> asString: 'KOI8-R') first = $<201>!

testEncodedStringSize
    | str |
    str := EncodedString
		fromString: (String with: (Character value: 233))
		encoding: 'KOI8-R'.
    self assert: str size = 1.
    str := EncodedString
		fromString: #[16rD8 0 16rDC 0] asString
		encoding: 'UTF-16BE'.
    self assert: str size = 4!

testEncodedStringNumberOfCharacters
    | str |
    str := EncodedString
		fromString: (String with: (Character value: 233))
		encoding: 'KOI8-R'.
    self assert: str numberOfCharacters = 1.
    str := EncodedString
		fromString: #[16rD8 0 16rDC 0] asString
		encoding: 'UTF-16BE'.
    self assert: str numberOfCharacters = 1!

testEncodedStringAsUnicodeString
    | str |
    str := EncodedString
		fromString: (String with: (Character value: 233))
		encoding: 'KOI8-R'.
    self assert: str asUnicodeString first = $<16r418>!

testCharAsStringColon
    | ch |
    ch := Character value: 233.
    self assert: (ch asString: 'KOI8-R') encoding = 'KOI8-R'.
    self deny: (ch asString: 'KOI8-R') = (ch asString: 'ISO-8859-1')!

testCharAsUnicodeStringColon
    | ch |
    ch := Character value: 233.
    self assert: (ch asUnicodeString: 'KOI8-R') first = $<16r418>!

testStringAsUnicodeStringColon
    | str |
    str := (Character value: 233) asString.
    self assert: (str asUnicodeString: 'KOI8-R') first = $<16r418>.
    self assert: (str asUnicodeString: 'ISO-8859-1') first = $<233>.
    str := #[239 191 190] asString.
    self assert: (str asUnicodeString: 'UTF-8') first = $<16rFFFE>.
    str := #[208 184] asString.
    self assert: (str asUnicodeString: 'UTF-8') first = $<16r438>!

testByteArrayAsUnicodeStringColon
    | str |
    str := #[233].
    self assert: (str asUnicodeString: 'KOI8-R') first = $<16r418>.
    self assert: (str asUnicodeString: 'ISO-8859-1') first = $<233>.
    str := #[239 191 190].
    self assert: (str asUnicodeString: 'UTF-8') first = $<16rFFFE>.
    str := #[208 184].
    self assert: (str asUnicodeString: 'UTF-8') first = $<16r438>!

testFromUTF7
    | str |
    self assert: ('+-' asUnicodeString: 'UTF-7') first = $+.
    self assert: ('+BBg-' asUnicodeString: 'UTF-7') first = $<16r418>.
    self assert: ('+BBgEOA-' asUnicodeString: 'UTF-7') second = $<16r438>.
    self assert: ('+BBgEOAQZ-' asUnicodeString: 'UTF-7') third = $<16r419>.
    self assert: ('+2//f/w-' asUnicodeString: 'UTF-7') size = 1.
    self assert: ('+2//f/w-' asUnicodeString: 'UTF-7') first = $<16r10FFFF>.
    self assert: ('+BDjb/9//-' asUnicodeString: 'UTF-7') size = 2.
    self assert: ('+BDjb/9//-' asUnicodeString: 'UTF-7') last = $<16r10FFFF>.
    self assert: ('+BDgEGNv/3/8-' asUnicodeString: 'UTF-7') size = 3.
    self assert: ('+BDgEGNv/3/8-' asUnicodeString: 'UTF-7') last = $<16r10FFFF>.

    "Test exiting Base64 mode with a non-Base64 character."
    str := 'A+ImIDkQ.' asUnicodeString: 'UTF-7'.
    self assert: str size = 4.
    self assert: str first = $A.
    self assert: str second = $<16r2262>.
    self assert: str third = $<16r391>.
    self assert: str last = $. .

    "Test handling of optional direct characters."
    self shouldnt: [ '#' asUnicodeString: 'UTF-7' ] raise: InvalidSequenceError.
    self should: [ '\' asUnicodeString: 'UTF-7' ] raise: InvalidSequenceError.
    self should: [ '~' asUnicodeString: 'UTF-7' ] raise: InvalidSequenceError.
    self should: [ '+BBg\' asUnicodeString: 'UTF-7' ] raise: InvalidSequenceError!

testToUTF7
    | str |
    self assert: ((UnicodeString with: $+) asString: 'UTF-7') asString = '+-'.
    str := UnicodeString with: $<16r418>.
    self assert: (str asString: 'UTF-7') encoding = 'UTF-7'.
    self assert: (str asString: 'UTF-7') asString = '+BBg-'.
    str := str copyWith: $<16r438>.
    self assert: (str asString: 'UTF-7') asString = '+BBgEOA-'.
    str := str copyWith: $<16r419>.
    self assert: (str asString: 'UTF-7') asString = '+BBgEOAQZ-'.
    str := UnicodeString with: $<16r10FFFF>.
    self assert: (str asString: 'UTF-7') asString = '+2//f/w-'.
!

 !
