"======================================================================
|
|   Test string operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2007, 2008  Free Software Foundation.
| Written by Steve Byrne
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

String extend [
    strTest [
        | str |
        str := self copy.
        str at: 1 put: $Q.
        ^str
    ]
]

Eval [ 'foo' ]

Eval [ 'foo on you' ]

Eval [ 'foo on
multiple line string
you'
]

Eval [ 'test embedded quote marks, can''t I do this?' ]

Eval [ 'FUBAR' at: 3 ]

Eval [ 'quem' copy at: 1 put: $Q ]

Eval [ 'quem' strTest ]

"This was a bug introduced in 2.3.6."
Eval [
   'abc' readStream do: [ :each | (each->'' readStream next) printNl ]
]

Eval [
'should be false ' print.       ('###' match: 'quem') printNl.
'should be false ' print.       ('###' match: 'bo') printNl.
'should be true  ' print.	('* string' match: 'any string') printNl.
'should be true  ' print.	('*.st' match: 'filename.st') printNl.
'should be true  ' print.	('foo.*' match: 'foo.bar') printNl.
'should be true  ' print.	('foo.*' match: 'foo.') printNl.
'should be true  ' print.	('*' match: 'foo.') printNl.
'should be true  ' print.	('*' match: '') printNl.
'should be true  ' print.	('***' match: '') printNl.
'should be true  ' print.	('*.st' match: '.st') printNl.
'should be true  ' print.	('*#*' match: '.st') printNl.
'should be true  ' print.	('*#*' match: '.s') printNl.
'should be true  ' print.	('*#*' match: 's') printNl.
'should be false ' print.	('*.st' match: '.s') printNl.
'should be false ' print.	('*#*' match: '') printNl
]

String extend [
    formatAs: format [
	| input |
        input := self readStream.
	^format collect: [ :ch |
	    ch = $#
		ifTrue: [
		    input atEnd
			ifTrue: [ Character space ]
			ifFalse: [ input next ] ]
		ifFalse: [ ch ] ]
    ]
]

Eval [ '8101234567' formatAs: '(###)###-####' ]
Eval [ '5431234567' formatAs: '###-###-####' ]
Eval [ '496449294' formatAs: '###-##-####' ]
Eval [ '12345' formatAs: '$###.##' ]
Eval [ 'SR2859591' formatAs: 'Publication number ####-####-#' ]
Eval [ '388350028456431097' formatAs: 'Card Number #### ###### #### Expires ##/##' ]
Eval [ '543' formatAs: '###-###-####' ]
Eval [ '' formatAs: '###-###-####' ]
Eval [ '1234' formatAs: '' ]

"Have fun with regexes that can match the empty string."
Eval [ 'abc' copyReplacingAllRegex: 'x*' with: 'x' ]		"xaxbxcx"
Eval [ 'f' copyReplacingAllRegex: 'o*$' with: 'x' ]		"fx"
Eval [ 'fo' copyReplacingAllRegex: 'o*$' with: 'x' ]		"fx"
Eval [ 'foo' copyReplacingAllRegex: 'o*$' with: 'x' ]		"fx"
Eval [ 'ba' copyReplacingAllRegex: 'a*' with: 'x' ]		"xbx"
Eval [ 'baa' copyReplacingAllRegex: 'a*' with: 'x' ]		"xbx"
Eval [ 'baaa' copyReplacingAllRegex: 'a*' with: 'x' ]		"xbx"
Eval [ 'bc' copyReplacingAllRegex: 'a*' with: 'x' ]		"xbxcx"
Eval [ 'bac' copyReplacingAllRegex: 'a*' with: 'x' ]		"xbxcx"

Eval [ ('abc def ' tokenize: ' ') printString ]			"(abc def)"
Eval [ (' abc def ' tokenize: ' ') printString ]		"('' abc def)"
Eval [ ('abc' tokenize: 'x*') printString ]			"(a b c)"
Eval [ ('axxx' tokenize: 'x*') printString ]			"(a)"
Eval [ ('ax' tokenize: 'x*') printString ]			"(a)"
Eval [ ('a' tokenize: 'x*') printString ]			"(a)"

Eval [ ('abc' allOccurrencesOfRegex: 'x*') size ]		"4"
Eval [ ('axbc' allOccurrencesOfRegex: 'x*') size ]
Eval [ ('axbxc' allOccurrencesOfRegex: 'x*') size ]
Eval [ ('axbxcx' allOccurrencesOfRegex: 'x*') size ]
Eval [ ('xaxbxcx' allOccurrencesOfRegex: 'x*') size ]
Eval [ ('xaxbxxcx' allOccurrencesOfRegex: 'x*') size ]
Eval [ ('f' allOccurrencesOfRegex: 'o*\Z') size ]		"1"
Eval [ ('fo' allOccurrencesOfRegex: 'o*\Z') size ]

"Some basic number parsing tests"
Eval [ '10' asNumber ]                                         "10"
Eval [ '10.0' asNumber ]                                       "10.0"
Eval [ '10.0e0' asNumber ]                                     "10.0"
Eval [ '10.0e1' asNumber ]                                     "100.0"
Eval [ '10.0e+1' asNumber ]                                    "100.0"
Eval [ '10.0e-1' asNumber ]                                    "1.0"
Eval [ '1e0' asNumber ]                                        "1"
Eval [ '1e-0' asNumber ]                                       "1"
Eval [ '1e-1' asNumber ]                                       "0.1"
Eval [ '1e+0' asNumber ]                                       "1"
Eval [ '1e+1' asNumber ]                                       "10"

"This returns 0xFFFD"
Eval [ (ByteArray new: 4 withAll: 255) changeClassTo: UnicodeString; first ]

Eval [ 'abc%1' % {'def'} ]
Eval [ 'abc%1' % {true} ]
Eval [ 'abc%<def|ghi>1' % {true} ]
Eval [ 'abc%<def|ghi>1' % {false} ]
Eval [ 'abc%(string)' % (Dictionary from: {'string' -> 'def'}) ]
Eval [ 'abc%(string)' % (Dictionary from: {'string' -> true}) ]
Eval [ 'abc%<def|ghi>(string)' % (Dictionary from: {'string' -> true}) ]
Eval [ 'abc%<def|ghi>(string)' % (Dictionary from: {'string' -> false}) ]

Eval [ 'abc%%1' % {'def'} ]
Eval [ 'abc%%%1' % {'def'} ]
