"======================================================================
|
|   Base encodings including Unicode (ISO10646)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2005 Free Software Foundation, Inc.
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

I18N addSubspace: #Encoders!

Error subclass: #InvalidSequenceError
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

InvalidSequenceError comment:
'I am raised if an invalid sequence is found while converting a
string from a charset to another'!

Error subclass: #IncompleteSequenceError
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

IncompleteSequenceError comment:
'I am raised if an invalid sequence is found while converting a
string from a charset to another.  In particular, I am raised
if the input stream ends abruptly in the middle of a multi-byte
sequence.'!

SystemExceptions.InvalidArgument subclass: #InvalidCharsetError
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

InvalidCharsetError comment:
'I am raised if the user tries to encode from or to an unknown
encoding'!

Stream subclass: #Encoder
       instanceVariableNames: 'origin'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

Encoder comment:
'This class is the superclass of streams that take an origin
and encode it to another character set.  Most of the subclasses
are for internal use, the one you really want to use is probably
EncodedStream.'!

Encoder subclass: #EncodedStream
       instanceVariableNames: ''
       classVariableNames: 'EncodersRegistry'
       poolDictionaries: 'Encoders'
       category: 'i18n-Character sets'!

EncodedStream comment:
'This class is a factory for subclasses of Encoder.  The Encoder
is in practice a pipe, so the purpose of this class is simply to
construct an appropriate pipe.'!

Namespace current: Smalltalk.I18N.Encoders!

Encoder subclass: #FromUCS4
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

FromUCS4 comment:
'This class is a superclass for classes that convert from UCS4
characters (encoded as 32-bit Integers) to bytes in another
encoding (encoded as Characters).'!

Encoder subclass: #ToUCS4
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

ToUCS4 comment:
'This class is a superclass for classes that convert from bytes
(encoded as Characters) to UCS4 characters (encoded as 32-bit
Integers to simplify the code and to avoid endianness conversions).'!

ToUCS4 subclass: #ComposeUCS4LE
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

ComposeUCS4LE comment:
'This class is used internally to provide UCS4 characters encoded as
32-bit integers for a descendent of FromUCS4, when the starting
encoding is little-endian.'!

ToUCS4 subclass: #ComposeUCS4BE
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

ComposeUCS4BE comment:
'This class is used internally to provide UCS4 characters encoded as
32-bit integers for a descendent of FromUCS4, when the starting
encoding is big-endian.'!

FromUCS4 subclass: #SplitUCS4LE
       instanceVariableNames: 'wch'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

SplitUCS4LE comment:
'This class is used internally to split into four 8-bit characters
the 32-bit UCS4 integers coming from a descendent of ToUCS4, when
the destination encoding is little-endian.'!

FromUCS4 subclass: #SplitUCS4BE
       instanceVariableNames: 'count wch'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

SplitUCS4BE comment:
'This class is used internally to split into four 8-bit characters
the 32-bit UCS4 integers coming from a descendent of ToUCS4, when
the destination encoding is big-endian.'!

Encoder subclass: #Iconv
       instanceVariableNames: 'from to iconvHandle readBuffer readPos readEnd
			       recodedBuffer recodedPos recodedEnd'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

Iconv comment:
'This class is used to delegate the actual character set conversion
to the C library''s iconv function.  Most conversions use iconv as
the only step in the conversions, sometimes the structure is 
ToUCS4+SplitUCS4xx+Iconv or Iconv+ComposeUCS4xx+FromUCS4, rarely
Iconv is skipped altogether and only Smalltalk converters are used.'!

FromUCS4 subclass: #ToUTF7
	instanceVariableNames: 'left value lookahead'
	classVariableNames: 'Base64Characters DirectCharacters ToBase64'
	poolDictionaries: ''
	category: 'i18n-Encodings'!

ToUTF7 comment:
'This class implements a converter that transliterates UCS4
characters (encoded as 32-bit Integers) to UTF-7 encoded
characters.'!

ToUCS4 subclass: #FromUTF7
	instanceVariableNames: 'shift wch lookahead'
	classVariableNames: 'DirectCharacters FromBase64'
	poolDictionaries: ''
	category: 'i18n-Encodings'!

ToUTF7 comment:
'This class implements a converter that transliterates UTF-7
encoded characters to UCS4 values (encoded as 32-bit Integers).'!

Namespace current: Smalltalk.I18N!

!Encoder class methodsFor: 'instance creation'!

on: aStringOrStream from: fromEncoding to: toEncoding
    "Answer a new encoder that translates from fromEncoding
     to toEncoding.  The encodings are guaranteed to be
     those for which the encoder was registered."
    ^self basicNew
	initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream
! !

!Encoder methodsFor: 'stream operations'!

atEnd
    "Return whether the receiver can produce another character in
     the receiver; by default, this is true if there is another
     character in the origin."
    ^self atEndOfInput
!

next
    "Return the next character in the receiver; by default,
     this is the next character in the origin."
    ^self nextInput
!

atEndOfInput
    "Return whether there is another character in the origin.  This
     method is for private use by encoders, calling it outside won't
     corrupt the internal state of the encoder but the result 
     probably won't be meaningful (depending on the innards of the 
     encoder)."
    ^origin atEnd
!

nextInput
    "Return the next character in the origin.  This method is for
     private use by encoders, calling it outside may corrupt the
     internal state of the encoder."
    ^origin next
!

species
    "Answer the kind of data that is answered, which is the same kind
     of data that the origin answers"
    ^origin species! !

!Encoder methodsFor: 'private - initialization'!

initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream
    origin := aStringOrStream isString
	ifTrue: [ aStringOrStream readStream ]
	ifFalse: [ aStringOrStream ].

    self flush
! !

!EncodedStream class methodsFor: 'initializing'!

initialize
    "Initialize the registry of the encoders to include the standard
     encoders contained in the library."
    EncodersRegistry := {
	{ #('UTF7' 'UTF-7'). FromUTF7. ToUTF7 }.
    }
!

registerEncoderFor: arrayOfAliases toUCS4: toUCS4Class fromUCS4: fromUCS4Class
    "Register the two classes that will respectively convert from the
     charsets in arrayOfAliases to UCS4 and vice versa.

     The former class is a stream that accepts characters and returns
     (via #next) integers representing UCS-4 character codes, while
     the latter accepts UCS-4 character codes and converts them to
     characters.  For an example see respectively FromUTF7 and ToUTF7
     (I admit it is not a trivial example)."

    EncodersRegistry := EncodersRegistry copyWith:
	{ arrayOfAliases. toUCS4Class. fromUCS4Class }
! !

!EncodedStream class methodsFor: 'private - triangulating'!

bigEndianPivot
    "When only one of the sides is implemented in Smalltalk
     and the other is obtained via iconv, we use UCS-4 to
     marshal data from Smalltalk to iconv; answer whether we
     should encode UCS-4 characters as big-endian."
    ^Memory bigEndian
!

pivotEncoding
    "When only one of the sides is implemented in Smalltalk
     and the other is obtained via iconv, we need a common
     pivot encoding to marshal data from Smalltalk to iconv.
     Answer the iconv name of this encoding."
    ^self bigEndianPivot ifTrue: [ 'UCS-4BE' ] ifFalse: [ 'UCS-4LE' ]
!

split: input
    "Answer a pipe with the given input stream (which produces
     UCS-4 character codes as integers) and whose output is
     a series of Characters in the required pivot encoding"
    ^self bigEndianPivot
	ifTrue: [ SplitUCS4BE on: input from: 'words' to: 'UCS4-BE' ]
	ifFalse: [ SplitUCS4LE on: input from: 'words' to: 'UCS4-LE' ].
!

compose: input
    "Answer a pipe with the given input stream (which produces
     Characters in the required pivot encoding) and whose output
     is a series of integer UCS-4 character codes."
    ^self bigEndianPivot
	ifTrue: [ ComposeUCS4BE on: input from: 'UCS4-BE' to: 'words' ]
	ifFalse: [ ComposeUCS4LE on: input from: 'UCS4-LE' to: 'words' ].
! !

!EncodedStream class methodsFor: 'instance creation'!

on: aStringOrStream from: fromEncoding
    "Answer a pipe of encoders that converts aStringOrStream
     (which can be a string or another stream) from the given
     encoding to the default locale's default charset."
    ^self
	on: aStringOrStream
	from: fromEncoding
	to: Locale default charset
!

on: aStringOrStream to: toEncoding
    "Answer a pipe of encoders that converts aStringOrStream
     (which can be a string or another stream) from the default
     locale's default charset to the given encoding."
    ^self
	on: aStringOrStream
	from: aStringOrStream encoding
	to: toEncoding
!

on: aStringOrStream from: fromEncoding to: toEncoding
    "Answer a pipe of encoders that converts aStringOrStream
     (which can be a string or another stream) between the
     two supplied encodings (which can be ASCII Strings or
     Symbols)"
    | from pivot to encoderFrom encoderTo pipe |

    "Adopt an uniform naming"
    from := fromEncoding asString.
    to := toEncoding asString.
    from = 'UCS-4' ifTrue: [ from := 'UCS-4BE' ].
    to = 'UCS-4' ifTrue: [ to := 'UCS-4BE' ].

    encoderFrom := encoderTo := Iconv.
    EncodersRegistry do: [ :each |
	((each at: 1) includes: to)
	    ifTrue: [ encoderTo := each at: 3 ].
	((each at: 1) includes: from)
	    ifTrue: [ encoderFrom := each at: 2 ]
    ].

    "Let iconv do the triangulation if possible"
    (encoderFrom == Iconv and: [ encoderTo == Iconv ]) ifTrue: [
	^Iconv on: aStringOrStream from: fromEncoding to: toEncoding ].

    "Else answer a `pipe' that takes care of triangulating.
     There is an additional complication: Smalltalk encoders
     read or provide a stream of character codes (respectively
     if the source is UCS-4, or the target is UCS-4), while iconv
     expects raw bytes.  So we add an intermediate layer if
     a mixed Smalltalk+iconv conversion is done: it converts
     character codes --> bytes (SplitUCS4xx, used if iconv will
     convert from UCS-4) or bytes --> character code (ComposeUCS4xx,
     used if iconv will convert to UCS-4).

     There are five different cases (remember that at least one converter
     is not iconv, so `both use iconv' and `from = pivot = to' are banned):
	from = pivot    --> Compose + non-iconv
	pivot = to      --> non-iconv + Split
	to uses iconv   --> non-iconv + Split + iconv (implies from ~= pivot)
	from uses iconv --> iconv + Compose + non-iconv (implies to ~= pivot)
	none uses iconv --> non-iconv + non-iconv (implies neither = pivot)"

    pivot := self pivotEncoding.
    pipe := aStringOrStream.
    from = pivot
	ifFalse: [
	    "Convert to our intermediate representation and split to
	     bytes if needed."

	    pipe := encoderFrom on: pipe from: fromEncoding to: pivot.
	    encoderTo == Iconv ifTrue: [
		pipe := self split: pipe.

		"Check if we already reached the destination format."
		to = pivot ifTrue: [ ^pipe ].
	    ].
	].

    "Compose iconv-produced bytes into UCS-4 character codes if needed."
    encoderFrom == Iconv ifTrue: [
	pipe := self compose: pipe
    ].

    ^encoderTo on: pipe from: pivot to: toEncoding.
! !

Namespace current: Smalltalk.I18N.Encoders!

!FromUCS4 methodsFor: 'stream operation'!

species
    "We answer a string of Characters encoded in our destination
     encoding."
    ^String
! !

!ToUCS4 methodsFor: 'stream operation'!

species
    "We answer a WordArray of UCS4 characters encoded as a series of
     32-bit Integers."
    ^WordArray
! !

!ComposeUCS4LE methodsFor: 'stream operation'!

next
    "Answer a 32-bit integer obtained by reading four 8-bit character
     codes in little-endian order and putting them together"
    ^self nextInput asInteger +
     (self nextInput asInteger bitShift: 8) +
     (self nextInput asInteger bitShift: 16) +
     (self nextInput asInteger bitShift: 24)
! !

!ComposeUCS4BE methodsFor: 'stream operation'!

next
    "Answer a 32-bit integer obtained by reading four 8-bit character
     codes in big-endian order and putting them together"

    "This code attempts to create as few large integers as possible"
    ^(((((self nextInput asInteger bitShift: 8) bitOr:
          self nextInput asInteger) bitShift: 8) bitOr:
          self nextInput asInteger) bitShift: 8) bitOr:
          self nextInput asInteger     
! !

!SplitUCS4LE methodsFor: 'stream operation'!

atEnd
    "Answer whether the receiver can produce more characters"
    ^wch == 1 and: [ self atEndOfInput ]
!

next
    "Answer an 8-bit Character obtained by converting each 32-bit
     Integer found in the origin to the four bytes that make it up,
     and ordering them from the least significant to the most
     significant."

    | answer |
    wch == 1 ifTrue: [
	"Answer the LSB.  This code will create as few LargeIntegers
         as possible by setting the mark bit only after the LSB has
         been extracted."
	wch := answer := self nextInput.
	wch := (wch bitShift: -8) + 16r1000000.
	^(answer bitAnd: 255) asCharacter
    ].

    "Answer any other byte"
    answer := wch bitAnd: 255.
    wch := wch bitShift: -8.
    ^answer asCharacter
!

flush
    "Flush any remaining bytes in the last 32-bit character read from
     the input"
    wch := 1
! !

!SplitUCS4BE methodsFor: 'stream operation'!

atEnd
    "Answer whether the receiver can produce more characters"
    ^count == 0 and: [ self atEndOfInput ]
!

next
    "Answer an 8-bit Character obtained by converting each 32-bit
     Integer found in the origin to the four bytes that make it up,
     and ordering them from the most significant to the least
     significant."

    | answer |
    count == 0 ifTrue: [
	"Answer the MSB.  This code will create as few LargeIntegers
         as possible by discarding the bits we answer and operating
         on SmallIntegers once only bits 0..23 remain."
	wch := answer := self nextInput.
	wch := wch bitAnd: 16rFFFFFF.
	count := 3.
	^(answer bitShift: -24) asCharacter
    ].

    "Answer any other byte.  We keep things so that the byte we answer
     is always in bits 16..23 when we arrive here."
    answer := wch bitShift: -16.
    wch := wch bitAnd: 16rFFFF.
    wch := wch bitShift: 8.
    count := count - 1.
    ^answer asCharacter
!

flush
    "Flush any remaining bytes in the last 32-bit character read from
     the input"
    count := 0
! !

!Iconv methodsFor: 'C call-outs'!

iconvOpen: to from: from
    <cCall: 'iconv_open' returning: #cObject args: #(#string #string)>!

iconvClose: handle
    <cCall: 'iconv_close' returning: #void args: #(#cObject)>!

iconvOn: handle from: readBuffer at: readPos
    size: readCount to: writeBuffer size: writeCount state: bytesLeft
    <cCall: 'iconvWrapper' returning: #boolean
	args: #(#cObject #smalltalk #int #int #smalltalk #int #smalltalk)>! !

!Iconv methodsFor: 'stream operation'!

atEnd
    "Answer whether the receiver can produce more characters"
    ^self atEndOfBuffer and: [ self convertMore ]
!

next
    "Answer the next character that the receiver can produce."
    | answer |
    self atEndOfBuffer ifTrue: [
	self convertMore ifTrue: [ SystemExceptions.EndOfStream signalOn: self. ^nil ]
    ].
    answer := recodedBuffer at: recodedPos.
    recodedPos := recodedPos + 1.
    ^answer
!

species
    "We answer a string of Characters encoded in our destination
     encoding."
    ^String
! !

!Iconv methodsFor: 'private - living across snapshots'!

update: aspect
    aspect == #aboutToSnapshot ifTrue: [ self release ].
!

release
    self removeToBeFinalized; finalize
!

finalize
    iconvHandle isNil ifTrue: [ ^self ].
    self iconvClose: iconvHandle.
    iconvHandle := nil.
!

iconvOpen
    iconvHandle isNil ifFalse: [ self release ].
    iconvHandle := self iconvOpen: to from: from.
    iconvHandle address = 16rFFFFFFFF
	ifTrue: [ ^InvalidCharsetError signal: { from. to } ].
    self addToBeFinalized.
    ObjectMemory addDependent: self
! !

!Iconv methodsFor: 'private - conversion'!

atEndOfBuffer
    "Answer whether we ate all the characters that iconv had
     converted to the destination encoding."
    ^recodedPos > recodedEnd
!

refill
    "Make it so that iconv will always have a decent number of
     characters to convert, by keeping the number of used
     bytes in the read buffer above bufferSize-refillThreshold"
    readPos > self refillThreshold ifTrue: [ 
	readBuffer
	    replaceFrom: 1
	    to: readEnd - readPos
	    with: readBuffer
	    startingAt: readPos.

	readEnd := readEnd - readPos.
	readPos := 1
    ].

    [ readEnd >= self bufferSize or: [ self atEndOfInput ] ]
	whileFalse: [
	    readEnd := readEnd + 1.
	    readBuffer at: readEnd put: self nextInput.
	].
!

initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream
    super initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream.
    from := fromEncoding.
    to := toEncoding.
    readPos := 1.
    readEnd := 0.
    recodedPos := 1.
    recodedEnd := 0.
!

bufferSize
    "Answer the size of the buffers we pass to iconv"
    ^1024
!

refillThreshold
    "Answer the threshold for readPos (the first unused
     byte in the input buffer), above which we read
     more characters from the input."
    ^1000
!

initBuffers
    "Initialize the input and output buffer for icode"
    readBuffer := String new: self bufferSize.
    recodedBuffer := String new: self bufferSize.
!

convertMore
    | bytesLeft fine |
    recodedBuffer isNil ifTrue: [ self initBuffers ].
    readBuffer isNil ifTrue: [ ^true ].
    iconvHandle isNil ifTrue: [ self iconvOpen ].

    self refill.

    bytesLeft := Array new: 2.
    fine := self
	iconvOn: iconvHandle
	from: readBuffer
	at: readPos
	size: readEnd - readPos + 1
	to: recodedBuffer
	size: self bufferSize
	state: bytesLeft.

    readPos := self bufferSize - (bytesLeft at: 1).
    recodedEnd := self bufferSize - (bytesLeft at: 2).
    recodedPos := 1.

    fine ifFalse: [
	 InvalidSequenceError signal.
	 ^false ].

    self atEndOfInput ifFalse: [ ^true ].
    readPos > readEnd
	ifTrue: [ readBuffer := nil ]
	ifFalse: [ IncompleteSequenceError signal ].

    ^false
! !

!ToUTF7 class methodsFor: 'initialization'!

initialize
    "Initialize the tables used by the UCS4-to-UTF7 converter"

    Base64Characters := #[
        16r00 16r00 16r00 16r00 16r00 16rA8 16rFF 16r03
        16rFE 16rFF 16rFF 16r07 16rFE 16rFF 16rFF 16r07
    ].

    "Table of direct characters"
    DirectCharacters := #[
        16r00 16r26 16r00 16r00 16r81 16rF3 16rFF 16r87
        16rFE 16rFF 16rFF 16r07 16rFE 16rFF 16rFF 16r07
    ].

    ToBase64 :=
	'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
! !

!ToUTF7 methodsFor: 'private'!

isDirect: anInteger
    | d |
    ^anInteger < 128 and: [
	d := DirectCharacters at: (anInteger // 8) + 1.
	((d bitShift: (0 - (anInteger \\ 8))) bitAnd: 1) == 1
    ]
!

toBase64Char: anInteger
    ^ToBase64 at: anInteger + 1
! !

!ToUTF7 methodsFor: 'conversion'!

atEnd
    "Answer whether the receiver can produce more characters"
    ^left == 0 and: [ self atEndOfInput ]
!

flush
    "Flush any remaining bytes in the last 32-bit character read from
     the input"
    left := 0.
!

next
    "Answer the next character that the receiver can produce."
    | ch |
    left = 0 ifTrue: [
	"Base64 encoding inactive"
	ch := self nextInput.
        (self isDirect: ch) ifTrue: [ ^ch asCharacter ].

	ch = 43
	    ifTrue: [ left := -2. lookahead := $-. ^$+ ].

	ch < 65536
	    ifTrue: [ left := 16. value := ch. ^$+ ].

	ch > 16r110000
	     ifTrue: [ InvalidSequenceError signal ].

	"Convert to a surrogate pair"
	ch := ch - 16r10000.
	left := 32.
	value := (((ch bitAnd: 16rFFF) + 16rD800) bitShift: 16) +
		 ((ch bitShift: -10) + 16rDC00).

	^$+
    ].

    left < 0 ifTrue: [
	"left = -2 ---> output the lookahead character and go to 0
	 left = -1 ---> if there's a lookahead output - and go to -2,
			if at end of input output - and stop,
			else reactivate base64"

	left = -2 ifTrue: [
	    left := 0.
	    ch := lookahead asCharacter.
	    lookahead := nil.
	    ^ch
	].
	lookahead isNil ifFalse: [
	    left := -2.
	    ^$-
	].

	left := 0.
	self atEndOfInput ifTrue: [ ^$- ].
    ].

    left < 6 ifTrue: [
	"Pump another character into the Base64 encoder"
        "TODO:  should deactivate base64 encoding"

	(self atEndOfInput or: [
	    self isDirect: (ch := self nextInput) ])
	    ifTrue: [
		"Terminate the stream by left-aligning the last byte"
		value := value bitShift: 6 - (left \\ 6).
		left := left + 6 - (left \\ 6).

		lookahead := ch.
	    ]
	    ifFalse: [
		ch < 65536
		    ifTrue: [
		        left := left + 16.
		        value := (value bitShift: 16) + ch
		    ]
		    ifFalse: [
			ch > 16r110000
			    ifTrue: [ InvalidSequenceError signal ].

			"Convert to a surrogate pair"
			ch := ch - 16r10000.
			left := left + 32.
			value := (value bitShift: 32) + 
			     (((ch bitAnd: 16rFFF) + 16rD800) bitShift: 16) +
			     ((ch bitShift: -10) + 16rDC00).
		    ]
	    ]
    ].

    "Take 6 bits out of the Base-64 encoded stream"
    left := left - 6.
    ch := value bitShift: 0 - left.
    value := value bitXor: (ch bitShift: left).

    left = 0 ifTrue: [ left := -1 ].
    ^self toBase64Char: ch
! !

!FromUTF7 class methodsFor: 'initialization'!

initialize
    "Initialize the tables used by the UTF7-to-UCS4 converter"

    FromBase64 := #[
	62 99 99 99 63
	52 53 54 55 56 57 58 59 60 61 99 99 99 99 99 99 99
	00 01 02 03 04 05 06 07 08 09 10 11 12
	13 14 15 16 17 18 19 20 21 22 23 24 25 99 99 99 99 99 99
	26 27 28 29 30 31 32 33 34 35 36 37 38
	39 40 41 42 43 44 45 46 47 48 49 50 51
     ].

    DirectCharacters := #[
        16r00 16r26 16r00 16r00 16rFF 16rF7 16rFF 16rFF
        16rFF 16rFF 16rFF 16rEF 16rFF 16rFF 16rFF 16r3F
        16r00 16r00 16r00 16r00 16r00 16r00 16r00 16r00
        16r00 16r00 16r00 16r00 16r00 16r00 16r00 16r00
    ].
!

!FromUTF7 methodsFor: 'private'!

isDirect: anInteger
    | d |
    ^anInteger < 128 and: [
	d := DirectCharacters at: anInteger // 8 + 1.
	((d bitShift: (0 - (anInteger \\ 8))) bitAnd: 1) == 1
    ]
!

fromBase64Char: aCharacter
    ^FromBase64 at: aCharacter - 42
! !

!FromUTF7 methodsFor: 'converting'!

atEnd
    "Answer whether the receiver can produce another UCS4 32-bit
     encoded integer"
    ^lookahead isNil
!

next
    "Answer the next character that the receiver can produce."
    | ch |
    "The decoder will always decode a character ahead, because when we
     are to read only a minus, we might already be at the end of the
     stream! Here is a simple example: +AFs- which decodes to [
	 We read + and switch to base-64 --> shift = 32
	 We read A and put it into the accumulator --> shift = 26
	 We read F and put it into the accumulator --> shift = 20
	 We read s and put it into the accumulator --> shift = 14

     We then decode the [ and return it.  Now we are not
     #atEndOfInput yet, but there are no more characters to
     give away!  Since we are not sure that the source supports
     #peek, our only other option would be to implement peeking
     for it and check for $- now.  This would have an overhead
     proportional to the number of input characters (to check
     whether we have already peeked the next characters), while
     our choice's overhead is proportional to the number of output
     characters, which is always less in UTF-7."

    lookahead isNil ifTrue: [ SystemExceptions.EndOfStream signal: self. ^nil ].
    ch := lookahead.
    lookahead := self getNext.
    ^ch
!

flush
    "Flush any remaining state left in the encoder by the last character
     (this is because UTF-7 encodes 6 bits at a time, so it takes three
     characters before it can provide a single 16-bit character and
     up to six characters before it can provide a full UCS-4 character)."
    shift := 0.
    lookahead := self getNext.
! !

!FromUTF7 methodsFor: 'private - converting'!

getNext
    | ch value wc1 |
    self atEndOfInput ifTrue: [ ^nil ].
    ch := self nextInput value.
    shift = 0 ifTrue: [
        (self isDirect: ch) ifTrue: [ ^ch ].
	ch == 43 "plus" ifFalse: [ InvalidSequenceError signal ].

	ch := self nextInput value.
	ch == 45 "minus" ifTrue: [ ^43 ].

	"Else switch into base64 mode"
	shift := 32.
	wch := 0.
    ].

    ((ch between: 43 and: 122) and: [
	(value := self fromBase64Char: ch) < 99 ])
	ifFalse: [
	    "Terminate base64 encoding.
	     If accumulated data is nonzero, the input is invalid.
	     Also, partial UTF-16 characters are invalid."
	    (shift <= 26 or: [ wch > 0 ]) ifTrue: [
		shift := 0.
		InvalidSequenceError signal ].

	    shift := 0.
	    ch = 45 "minus" ifFalse: [ ^ch ].

	    "Discard the -"
	    ^self getNext
	].

    "Concatenate the base64 integer value to the accumulator"
    shift > 6 ifTrue: [
	shift := shift - 6.
	wch := wch + (value bitShift: shift).
	shift > 16 ifTrue: [ ^self getNext ].

	(shift between: 11 and: 16) ifTrue: [
	    "Completed an UTF-16 character.  When we see a High
	     Surrogate, we must wait for the following Low Surrogate."
	    wc1 := wch bitShift: -16.

	    (wc1 between: 16rD800 and: 16rDBFF) ifFalse: [
		wch := (wch bitAnd: 65535) bitShift: 16.
		shift := shift + 16.
		^wc1
	    ].
	].

	(shift between: 5 and: 10) ifTrue: [
	    "After an High Surrogate, verify that the next character
	     is indeed a Low Surrogate"
	    wc1 := wch bitAnd: 65535.
	    (wc1 between: 16rDC00 and: 16rDFFF) ifFalse: [
		shift := 0.
		InvalidSequenceError signal ]
	].
    ].

    "Completed an UTF-16 surrogate pair"

    "35FDC00 = -0xD800 << 10 - 0xDC00 + 0x10000"
    wc1 := wch bitShift: -16.
    wch := (wch bitAnd: 65535) + (value bitShift: shift - 6).
    wc1 := (wc1 bitShift: 10) + wch - 16r35FDC00.

    wch := ((value bitShift: shift) bitAnd: 16r3F) bitShift: 26.
    ^wc1
! !


Namespace current: I18N!

!InvalidSequenceError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'invalid input sequence'! !

!IncompleteSequenceError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'incomplete input sequence'! !

!InvalidCharsetError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'unknown encoding specified'! !


"Now add some extensions to the system classes"

(CharacterArray classPool includesKey: #DefaultEncoding)
    ifFalse: [ CharacterArray addClassVarName: #DefaultEncoding ]!

!CharacterArray class methodsFor: 'converting'!

defaultEncoding
    "Answer the default locale's default charset"
    DefaultEncoding isNil
	ifTrue: [ DefaultEncoding := Locale default charset ].

    ^DefaultEncoding
!

defaultEncoding: aString
    "Answer the default locale's default charset"
    DefaultEncoding := aString
! !

!CharacterArray methodsFor: 'converting'!

encoding
    "Answer the encoding of the receiver, assuming it is in the
     default locale's default charset"

    ^self class defaultEncoding asString = 'UTF-16'
	ifTrue: [ self utf16Encoding ]
	ifFalse: [ self class defaultEncoding ]
!

utf16Encoding
    "Assuming the receiver is encoded as UTF-16 with a proper
     endianness marker, answer the correct encoding of the receiver."

    | b1 b2 bigEndian |
    b1 := self at: 1.		"Low byte"
    b2 := self at: 2.		"High byte"

    "If we read FFFE, it is big-endian; if we read FEFF, it is little-endian"
    bigEndian := b1 * b2 = 16rFD02
	ifTrue: [ b1 = 255 ]
	ifFalse: [ Memory bigEndian ].

    ^bigEndian ifTrue: [ 'UTF-16BE' ] ifFalse: [ 'UTF-16LE' ]
! !

!PositionableStream methodsFor: 'converting'!

encoding
    "Answer the encoding of the underlying collection"
    ^collection encoding
! !

Encoders.ToUTF7 initialize!
Encoders.FromUTF7 initialize!
EncodedStream initialize!
