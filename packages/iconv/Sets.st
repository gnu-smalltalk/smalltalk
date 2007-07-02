"======================================================================
|
|   Base encodings including Unicode (ISO10646)
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2005, 2006 Free Software Foundation, Inc.
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

CharacterArray subclass: #EncodedString
       instanceVariableNames: 'string encoding'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

EncodedString comment:
'An EncodedString, like a String, is a sequence of bytes representing
a specific encoding of a UnicodeString.  Unlike a String, however,
the encoding name is known, rather than detected, irrelevant or
assumed to be the system default.'!

Object subclass: #EncodedStringFactory
       instanceVariableNames: 'encoding'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

EncodedStringFactory comment:
'An EncodedStringFactory is used (in place of class objects) so that
Encoders can return EncodedString objects with the correct encoding.'!

Stream subclass: #Encoder
       instanceVariableNames: 'origin from to factory'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

Encoder comment:
'This class is the superclass of streams that take an origin
and encode it to another character set.  The subclasses are
are for internal use unless you are writing support for your own
encodings.'!

Stream subclass: #EncodedStream
       instanceVariableNames: ''
       classVariableNames: 'EncodersRegistry'
       poolDictionaries: 'Encoders'
       category: 'i18n-Character sets'!

EncodedStream comment:
'This class is a factory for subclasses of Encoder.  Encoders
act as parts of a pipe, hence this class provides methods that
construct an appropriate pipe.'!

Namespace current: Smalltalk.I18N.Encoders!

Encoder subclass: #FromUTF32
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

FromUTF32 comment:
'This class is a superclass for classes that convert from UTF-32
characters (encoded as 32-bit Integers) to bytes in another
encoding (encoded as Characters).'!

Encoder subclass: #ToUTF32
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

ToUTF32 comment:
'This class is a superclass for classes that convert from bytes
(encoded as Characters) to UTF-32 characters (encoded as 32-bit
Integers to simplify the code and to avoid endianness conversions).'!

ToUTF32 subclass: #ComposeUTF32LE
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

ComposeUTF32LE comment:
'This class is used internally to provide UTF-32 characters encoded as
32-bit integers for a descendent of FromUTF32, when the starting
encoding is little-endian.'!

ToUTF32 subclass: #ComposeUTF32BE
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

ComposeUTF32BE comment:
'This class is used internally to provide UTF-32 characters encoded as
32-bit integers for a descendent of FromUTF32, when the starting
encoding is big-endian.'!

FromUTF32 subclass: #SplitUTF32LE
       instanceVariableNames: 'wch'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

SplitUTF32LE comment:
'This class is used internally to split into four 8-bit characters
the 32-bit UTF-32 integers coming from a descendent of ToUTF32, when
the destination encoding is little-endian.'!

FromUTF32 subclass: #SplitUTF32BE
       instanceVariableNames: 'count wch'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

SplitUTF32BE comment:
'This class is used internally to split into four 8-bit characters
the 32-bit UTF-32 integers coming from a descendent of ToUTF32, when
the destination encoding is big-endian.'!

Encoder subclass: #Iconv
       instanceVariableNames: 'iconvHandle readBuffer readPos readEnd
			       recodedBuffer recodedPos recodedEnd'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'i18n-Character sets'!

Iconv comment:
'This class is used to delegate the actual character set conversion
to the C library''s iconv function.  Most conversions use iconv as
the only step in the conversions, sometimes the structure is 
ToUTF32+SplitUTF32xx+Iconv or Iconv+ComposeUTF32xx+FromUTF32, rarely
Iconv is skipped altogether and only Smalltalk converters are used.'!

FromUTF32 subclass: #ToUTF7
	instanceVariableNames: 'left value lookahead'
	classVariableNames: 'Base64Characters DirectCharacters ToBase64'
	poolDictionaries: ''
	category: 'i18n-Encodings'!

ToUTF7 comment:
'This class implements a converter that transliterates UTF-32
characters (encoded as 32-bit Integers) to UTF-7 encoded
characters.'!

ToUTF32 subclass: #FromUTF7
	instanceVariableNames: 'shift wch lookahead'
	classVariableNames: 'DirectCharacters FromBase64'
	poolDictionaries: ''
	category: 'i18n-Encodings'!

ToUTF7 comment:
'This class implements a converter that transliterates UTF-7
encoded characters to UTF-32 values (encoded as 32-bit Integers).'!

Namespace current: Smalltalk.I18N!


!EncodedStringFactory class methodsFor: 'instance creation'!

encoding: aString
    "Answer a new EncodedStringFactory, creating strings with the
     given encoding."
    ^self new encoding: aString!

!EncodedStringFactory methodsFor: 'instance creation'!

fromString: aString
    "Answer an EncodedString based on aString and in the encoding
     represented by the receiver."
    ^EncodedString fromString: aString encoding: self encoding!

new
    "Answer a new, empty EncodedString using the encoding
     represented by the receiver."
    ^EncodedString fromString: String new encoding: self encoding!

new: size
    "Answer a new EncodedString of the given size, using the encoding
     represented by the receiver."
    ^EncodedString fromString: (String new: size) encoding: self encoding! !

!EncodedStringFactory methodsFor: 'instance creation'!

encoding
    "Answer the encoding used for the created Strings."
    ^encoding!

encoding: aString
    "Set the encoding used for the created Strings."
    encoding := aString! !

!EncodedString class methodsFor: 'instance creation'!

fromString: aString
    | str |
    str := aString asString.
    ^self fromString: str encoding: str encoding!

fromString: aString encoding: encoding
    | str |
    str := aString isString
	ifTrue: [ aString ]
	ifFalse: [ aString asString: encoding ].
    ^self basicNew setString: aString; encoding: encoding!

new
    self shouldNotImplement!

new: size
    self shouldNotImplement! !


!EncodedString methodsFor: 'accessing'!

asString
    ^string!

asUnicodeString
    ^(string asUnicodeString: encoding)!

at: anIndex
    ^string at: anIndex!

at: anIndex put: anObject
    ^string at: anIndex put: anObject!

do: aBlock
    string do: aBlock!

encoding
    ^encoding!

hash
    ^string hash bitXor: encoding hash!

species
    ^EncodedStringFactory encoding: self encoding!

size
    ^string size!

utf16Encoding
    ^string utf16Encoding!

utf32Encoding
    ^string utf32Encoding!

valueAt: anIndex
    ^string valueAt: anIndex!

valueAt: anIndex put: anObject
    ^string valueAt: anIndex put: anObject! !

!EncodedString methodsFor: 'printing'!

displayOn: aStream
    "Print a representation of the receiver on aStream. Unlike
     #printOn:, this method does not display the encoding and
     enclosing quotes."
    string displayOn: aStream!

printOn: aStream
    "Print a representation of the receiver on aStream."
    aStream nextPutAll: encoding; nextPut: $[.
    (string asUnicodeString: encoding) asString printOn: aStream.
    aStream nextPut: $]!

!EncodedString methodsFor: 'copying'!

copy
    ^self class
	fromString: string copy
	encoding: self encoding!

copyEmpty
    ^self class
	fromString: (string copyEmpty: string size)
	encoding: self encoding!

copyEmpty: size
    ^self class
	fromString: (string copyEmpty: size)
	encoding: self encoding! !

!EncodedString methodsFor: 'initializing'!

setString: aString
    string := aString!

encoding: aString
    aString = 'UTF-32' ifTrue: [ encoding := string utf32Encoding. ^self ].
    aString = 'UTF-16' ifTrue: [ encoding := string utf16Encoding. ^self ].
    encoding := aString! !


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

peekInput
    "Return the next character in the origin without advancing it."
    ^origin peek
!

nextInput
    "Return the next character in the origin.  This method is for
     private use by encoders, calling it outside may corrupt the
     internal state of the encoder."
    ^origin next
!

species
    "We answer a string of Characters encoded in our destination
     encoding."
    factory isNil
	ifTrue: [
	    factory := to = String defaultEncoding
		ifTrue: [ String ]
		ifFalse: [ EncodedStringFactory encoding: to ] ].
    ^factory
! !

!Encoder methodsFor: 'private - initialization'!

initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream
    from := fromEncoding.
    to := toEncoding.
    origin := (aStringOrStream isKindOf: Stream)
	ifFalse: [ aStringOrStream readStream ]
	ifTrue: [ aStringOrStream ].

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

registerEncoderFor: arrayOfAliases toUTF32: toUTF32Class fromUTF32: fromUTF32Class
    "Register the two classes that will respectively convert from the
     charsets in arrayOfAliases to UTF-32 and vice versa.

     The former class is a stream that accepts characters and returns
     (via #next) integers representing UTF-32 character codes, while
     the latter accepts UTF-32 character codes and converts them to
     characters.  For an example see respectively FromUTF7 and ToUTF7
     (I admit it is not a trivial example)."

    EncodersRegistry := EncodersRegistry copyWith:
	{ arrayOfAliases. toUTF32Class. fromUTF32Class }
! !

!EncodedStream class methodsFor: 'private - triangulating'!

bigEndianPivot
    "When only one of the sides is implemented in Smalltalk
     and the other is obtained via iconv, we use UTF-32 to
     marshal data from Smalltalk to iconv; answer whether we
     should encode UTF-32 characters as big-endian."
    ^Memory bigEndian
!

pivotEncoding
    "When only one of the sides is implemented in Smalltalk
     and the other is obtained via iconv, we need a common
     pivot encoding to marshal data from Smalltalk to iconv.
     Answer the iconv name of this encoding."
    ^self bigEndianPivot ifTrue: [ 'UTF-32BE' ] ifFalse: [ 'UTF-32LE' ]
!

split: input to: encoding
    "Answer a pipe with the given input stream (which produces
     UTF-32 character codes as integers) and whose output is
     a series of Characters in the required pivot encoding"
    ^(encoding = 'UCS-4BE' or: [ encoding = 'UTF-32BE' ])
	ifTrue: [ SplitUTF32BE on: input from: 'UTF-32' to: encoding ]
	ifFalse: [ SplitUTF32LE on: input from: 'UTF-32' to: encoding ].
!

compose: input from: encoding
    "Answer a pipe with the given input stream (which produces
     Characters in the required pivot encoding) and whose output
     is a series of integer UTF-32 character codes."
    ^(encoding = 'UCS-4BE' or: [ encoding = 'UTF-32BE' ])
	ifTrue: [ ComposeUTF32BE on: input from: encoding to: 'UTF-32' ]
	ifFalse: [ ComposeUTF32LE on: input from: encoding to: 'UTF-32' ].
! !

!EncodedStream class methodsFor: 'instance creation'!

encoding: anUnicodeString
    "Answer a pipe of encoders that converts anUnicodeString to default
     encoding for strings (the current locale's default charset if none
     is specified)."
    ^self
	encoding: anUnicodeString
	as: String defaultEncoding
!

encoding: aStringOrStream as: toEncoding
    "Answer a pipe of encoders that converts anUnicodeString (which contains
     to the supplied encoding (which can be an ASCII String or Symbol)."
    | pivot to encoderTo pipe |

    "Adopt an uniform naming"
    to := toEncoding asString.
    (to = 'UTF-32' or: [ to = 'UCS-4' ]) ifTrue: [ to := 'UTF-32BE' ].
    (to = 'UTF-16' or: [ to = 'UCS-2' ]) ifTrue: [ to := 'UTF-16BE' ].

    "If converting to the pivot encoding, we're done."
    pivot := ((to startsWith: 'UCS-4') or: [ to startsWith: 'UTF-32' ])
	ifTrue: [ to ]
	ifFalse: [ self pivotEncoding ].

    encoderTo := Iconv.
    EncodersRegistry do: [ :each |
	((each at: 1) includes: to)
	    ifTrue: [ encoderTo := each at: 3 ]
    ].

    pipe := aStringOrStream.

    "Split UTF-32 character codes into bytes if needed by iconv."
    encoderTo == Iconv ifTrue: [ pipe := self split: pipe to: pivot ].

    "If not converting to the pivot encoding, we need one more step."
    to = pivot ifFalse: [
        pipe := encoderTo on: pipe from: pivot to: toEncoding ].
    ^pipe
!

unicodeOn: aStringOrStream
    "Answer a pipe of encoders that converts aStringOrStream (which can
     be a string or another stream) from its encoding (or the current
     locale's default charset, if the encoding cannot be determined)
     to integers representing Unicode character codes."
    ^self
	unicodeOn: aStringOrStream
	encoding: aStringOrStream encoding
!

unicodeOn: aStringOrStream encoding: fromEncoding
    "Answer a pipe of encoders that converts aStringOrStream
     (which can be a string or another stream) from the supplied
     encoding (which can be an ASCII String or Symbol) to
     integers representing Unicode character codes."
    | from pivot encoderFrom pipe |

    "Adopt an uniform naming"
    from := fromEncoding asString.
    (from = 'UTF-32' or: [ from = 'UCS-4' ])
	ifTrue: [ from := aStringOrStream utf32Encoding ].
    (from = 'UTF-16' or: [ from = 'UCS-2' ])
	ifTrue: [ from := aStringOrStream utf16Encoding ].

    pivot := 'UTF-32'.
    ((from startsWith: 'UCS-4') or: [ from startsWith: 'UTF-32' ])
	ifTrue: [ pivot := from ].
    pivot = 'UTF-32' ifTrue: [ pivot := self pivotEncoding ].

    encoderFrom := Iconv.
    EncodersRegistry do: [ :each |
	((each at: 1) includes: from)
	    ifTrue: [ encoderFrom := each at: 2 ]
    ].

    pipe := aStringOrStream.

    "If not converting from the pivot encoding, we need one more step."
    from = pivot ifFalse: [
        pipe := encoderFrom on: pipe from: fromEncoding to: pivot ].

    "Compose iconv-produced bytes into UTF-32 character codes if needed."
    encoderFrom == Iconv ifTrue: [ pipe := self compose: pipe from: pivot ].
    ^pipe
!

on: aStringOrStream from: fromEncoding
    "Answer a pipe of encoders that converts aStringOrStream
     (which can be a string or another stream) from the given
     encoding to the default locale's default charset."
    ^self
	on: aStringOrStream
	from: fromEncoding
	to: String defaultEncoding
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
    (from = 'UTF-32' or: [ from = 'UCS-4' ])
	ifTrue: [ from := aStringOrStream utf32Encoding ].
    (from = 'UTF-16' or: [ from = 'UCS-2' ])
	ifTrue: [ from := aStringOrStream utf16Encoding ].

    (to = 'UTF-32' or: [ to = 'UCS-4' ]) ifTrue: [ to := 'UTF-32BE' ].
    (to = 'UTF-16' or: [ to = 'UCS-2' ]) ifTrue: [ to := 'UTF-32BE' ].

    pivot := 'UTF-32'.
    ((from startsWith: 'UCS-4') or: [ from startsWith: 'UTF-32' ])
	ifTrue: [ pivot := from ].
    ((to startsWith: 'UCS-4') or: [ to startsWith: 'UTF-32' ])
	ifTrue: [ pivot := to ].
    pivot = 'UTF-32' ifTrue: [ pivot := self pivotEncoding ].

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
     if the source is UTF-32, or the target is UTF-32), while iconv
     expects raw bytes.  So we add an intermediate layer if
     a mixed Smalltalk+iconv conversion is done: it converts
     character codes --> bytes (SplitUTF32xx, used if iconv will
     convert from UTF-32) or bytes --> character code (ComposeUTF32xx,
     used if iconv will convert to UTF-32).

     There are five different cases (remember that at least one converter
     is not iconv, so `both use iconv' and `from = pivot = to' are banned):
	from = pivot    --> Compose + encoderTo
	pivot = to      --> encoderFrom + Split
	to uses iconv   --> encoderFrom + Split + iconv (from ~= pivot)
	from uses iconv --> iconv + Compose + encoderTo (to ~= pivot)
	none uses iconv --> encoderFrom + encoderTo (implies neither = pivot)"

    pipe := aStringOrStream.
    from = pivot
	ifFalse: [
	    "Convert to our intermediate representation and split to
	     bytes if needed."

	    pipe := encoderFrom on: pipe from: fromEncoding to: pivot.
	    encoderTo == Iconv ifTrue: [
		pipe := self split: pipe to: pivot.

		"Check if we already reached the destination format."
		to = pivot ifTrue: [ ^pipe ].
	    ].
	].

    "Compose iconv-produced bytes into UTF-32 character codes if needed."
    encoderFrom == Iconv ifTrue: [
	pipe := self compose: pipe from: pivot
    ].

    ^encoderTo on: pipe from: pivot to: toEncoding.
! !


Namespace current: Smalltalk.I18N.Encoders!

!ToUTF32 methodsFor: 'stream operation'!

species
    "We answer a UnicodeString of Unicode characters encoded as UTF-32."
    ^UnicodeString
! !


!ComposeUTF32LE methodsFor: 'stream operation'!

next
    "Answer a 32-bit integer obtained by reading four 8-bit character
     codes in little-endian order and putting them together"
    ^(self nextInput asInteger +
      (self nextInput asInteger bitShift: 8) +
      (self nextInput asInteger bitShift: 16) +
      (self nextInput asInteger bitShift: 24)) asCharacter
! !

!ComposeUTF32BE methodsFor: 'stream operation'!

next
    "Answer a 32-bit integer obtained by reading four 8-bit character
     codes in big-endian order and putting them together"

    "This code attempts to create as few large integers as possible"
    ^((((((self nextInput asInteger bitShift: 8) bitOr:
           self nextInput asInteger) bitShift: 8) bitOr:
           self nextInput asInteger) bitShift: 8) bitOr:
           self nextInput asInteger) asCharacter
! !


!SplitUTF32LE methodsFor: 'stream operation'!

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
	wch := answer := self nextInput codePoint.
	wch := (wch bitShift: -8) + 16r1000000.
	^Character value: (answer bitAnd: 255)
    ].

    "Answer any other byte"
    answer := wch bitAnd: 255.
    wch := wch bitShift: -8.
    ^Character value: answer
!

flush
    "Flush any remaining bytes in the last 32-bit character read from
     the input"
    wch := 1
! !

!SplitUTF32BE methodsFor: 'stream operation'!

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
	wch := answer := self nextInput codePoint.
	wch := wch bitAnd: 16rFFFFFF.
	count := 3.
	^Character value: (answer bitShift: -24)
    ].

    "Answer any other byte.  We keep things so that the byte we answer
     is always in bits 16..23 when we arrive here."
    answer := wch bitShift: -16.
    wch := wch bitAnd: 16rFFFF.
    wch := wch bitShift: 8.
    count := count - 1.
    ^Character value: answer
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
    "Initialize the tables used by the UTF-32-to-UTF-7 converter"

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

isBase64: anInteger
    | d |
    ^anInteger < 128 and: [
	d := Base64Characters at: (anInteger // 8) + 1.
	((d bitShift: (0 - (anInteger \\ 8))) bitAnd: 1) == 1
    ]
!

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
	ch := self nextInput codePoint.
        (self isDirect: ch) ifTrue: [ ^ch asCharacter ].

	ch = 43
	    ifTrue: [ left := -2. lookahead := $-. ^$+ ].

	ch < 65536
	    ifTrue: [ left := 16. value := ch. ^$+ ].

	ch >= 16r110000
	     ifTrue: [ InvalidSequenceError signal ].

	"Convert to a surrogate pair"
	ch := ch - 16r10000.
	left := 32.
	value := (((ch bitAnd: 16r3FF) + 16rD800) bitShift: 16) +
		 ((ch bitShift: -10) + 16rDC00).
	^$+
    ].

    left < 0 ifTrue: [
	"if at end of input output -.  otherwise:
	 left = -2 ---> output the lookahead character and go to 0
	 left = -1 ---> if there's a lookahead output it; if -, go to -2
			without advancing in the input.; otherwise go to 0"

	lookahead isNil
	    ifTrue: [
		left := 0.
		self atEndOfInput ifTrue: [ ^$- ] ]
	    ifFalse: [
	        ch := lookahead.
	        ^(left = -1 and: [ self isBase64: ch ])
		    ifTrue: [ left := -2. $- ]
		    ifFalse: [ lookahead := nil. left := 0. ch asCharacter ]]].

    left < 6 ifTrue: [
	"Pump another character into the Base64 encoder"

	(self atEndOfInput or: [
	    self isDirect: (ch := self nextInput codePoint) ])
	    ifTrue: [
		"Terminate the stream by left-aligning the last byte"
		value := value bitShift: 6 - (left \\ 6).
		left := left + 6 - (left \\ 6).

		lookahead := ch ]
	    ifFalse: [
		ch < 65536
		    ifTrue: [
		        left := left + 16.
		        value := (value bitShift: 16) + ch ]
		    ifFalse: [
			ch >= 16r110000
			    ifTrue: [ InvalidSequenceError signal ].

			"Convert to a surrogate pair"
			ch := ch - 16r10000.
			left := left + 32.
			value := (value bitShift: 32) + 
			     (((ch bitAnd: 16rFFF) + 16rD800) bitShift: 16) +
			     ((ch bitShift: -10) + 16rDC00) ] ] ].

    "Take 6 bits out of the Base-64 encoded stream"
    left := left - 6.
    ch := value bitShift: 0 - left.
    value := value bitXor: (ch bitShift: left).

    "Exit base64 if at end of input or next char is direct."
    left = 0 ifTrue: [ left := -1 ].
    ^self toBase64Char: ch
! !


!FromUTF7 class methodsFor: 'initialization'!

initialize
    "Initialize the tables used by the UTF-7-to-UTF-32 converter"

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
    "Answer whether the receiver can produce another UTF-32 32-bit
     encoded integer"
    ^lookahead isNil
!

next
    "Answer the next character that the receiver can produce."
    | ch |
    lookahead isNil ifTrue: [ SystemExceptions.EndOfStream signal: self. ^nil ].
    ch := lookahead.
    self getNext.
    ^ch
!

flush
    "Flush any remaining state left in the encoder by the last character
     (this is because UTF-7 encodes 6 bits at a time, so it takes three
     characters before it can provide a single 16-bit character and
     up to six characters before it can provide a full UTF-32 character)."
    shift := -6.
    wch := 0.
    self getNext.
! !

!FromUTF7 methodsFor: 'private - converting'!

getNext
    [
        self atEndOfInput ifTrue: [
	    (shift = -6 or: [ shift = 10 ]) ifFalse: [
		shift := -6. wch := 0.
		InvalidSequenceError signal ].
	    lookahead := nil.
	    ^self ].
	(lookahead := self readNext) isNil
    ] whileTrue!

readNext
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

    | ch value wc1 |
    ch := self nextInput value.
    shift = -6 ifTrue: [
        (self isDirect: ch) ifTrue: [ ^Character codePoint: ch ].
	ch == 43 "plus" ifFalse: [ InvalidSequenceError signal ].

	ch := self nextInput value.
	ch == 45 "minus" ifTrue: [ ^$+ ].

	"Else switch into base64 mode"
	shift := 10.
    ].

    ((ch between: 43 and: 122) and: [
	(value := self fromBase64Char: ch) < 99 ])
	ifFalse: [
	    "Terminate base64 encoding.
	     If accumulated data is nonzero, the input is invalid.
	     Also, partial UTF-16 characters are invalid."
	    (shift <= 4 or: [ wch > 0 ]) ifTrue: [
		shift := -6. wch := 0.
		InvalidSequenceError signal ].

	    shift := -6.

	    "Discard a -"
	    ch = 45 "minus" ifTrue: [ ^nil ].
            (self isDirect: ch) ifFalse: [ InvalidSequenceError signal ].
	    ^Character codePoint: ch
	].

    shift > 0 ifTrue: [
        "Concatenate the base64 integer value to the accumulator"
        wch := wch + (value bitShift: shift).
        shift := shift - 6.
        ^nil ].

    wc1 := wch + (value bitShift: shift).
    wch := (value bitShift: shift + 16) bitAnd: 16rFC00.
    shift := shift + 10.

    wc1 < 16rD800 ifTrue: [
        ^Character codePoint: wc1 ].
    wc1 < 16rDC00 ifTrue: [
        "Read a High Surrogate. D7C0 = D800 - (16r10000 bitShift: -6)"
	wch := wch + (wc1 - 16rD7C0 bitShift: 16).
	^nil ].
    wc1 < 16rE000 ifTrue: [
        ^InvalidSequenceError signal ].
    wc1 <= 16rFFFF ifTrue: [
        ^Character codePoint: wc1 ].

    "After an High Surrogate, verify that the next character
     is indeed a Low Surrogate"
    ((wc1 bitAnd: 65535) between: 16rDC00 and: 16rDFFF) ifFalse: [
        ^InvalidSequenceError signal ].
    wc1 := ((wc1 bitAnd: 16r7FF0000) bitShift: -6) + (wc1 bitAnd: 16r3FF).
    ^Character codePoint: wc1! !



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

(String classPool includesKey: #DefaultEncoding)
    ifFalse: [ String addClassVarName: #DefaultEncoding ]!

!String class methodsFor: 'converting'!

defaultDefaultEncoding
    "Answer the encoding that is used in case the user specifies none."
    ^'UTF-8'
!

defaultEncoding
    "Answer the default encoding that is used for transcoding."
    DefaultEncoding isNil ifTrue: [ ^self defaultDefaultEncoding ].
    ^DefaultEncoding
!

defaultEncoding: aString
    "Answer the default locale's default charset"
    DefaultEncoding := aString
! !


!CharacterArray methodsFor: 'multibyte encodings'!

numberOfCharacters
    "Answer the number of Unicode characters in the receiver, interpreting it
     as the default locale character set."
    ^self asUnicodeString numberOfCharacters!

!String methodsFor: 'multibyte encodings'!

asUnicodeString
    "Return an UnicodeString with the contents of the receiver, interpreted
     as the default locale character set."
    ^(I18N.EncodedStream unicodeOn: self) contents!

numberOfCharacters: aString
    "Answer the number of Unicode characters in the receiver, interpreting it
     in the character encoding aString."
    ^(self asUnicodeString: aString) numberOfCharacters!

asUnicodeString: aString
    "Return an UnicodeString with the contents of the receiver, interpreted
     as the default locale character set."
    ^(I18N.EncodedStream unicodeOn: self encoding: aString) contents! !

!String methodsFor: 'converting'!

encoding
    "Answer the encoding of the receiver, assuming it is in the
     default locale's default charset"

    | encoding |
    (self size >= 4 and: [ (self valueAt: 1) = 0 and: [ (self valueAt: 2) = 0 and: [
    	(self valueAt: 3) = 254 and: [
    	(self valueAt: 4) = 255 ]]]]) ifTrue: [ ^'UTF-32BE' ].
    (self size >= 4 and: [ (self valueAt: 4) = 0 and: [ (self valueAt: 3) = 0 and: [
    	(self valueAt: 2) = 254 and: [
    	(self valueAt: 1) = 255 ]]]]) ifTrue: [ ^'UTF-32LE' ].
    (self size >= 2 and: [
    	(self valueAt: 1) = 254 and: [
    	(self valueAt: 2) = 255 ]]) ifTrue: [ ^'UTF-16BE' ].
    (self size >= 2 and: [
    	(self valueAt: 2) = 254 and: [
    	(self valueAt: 1) = 255 ]]) ifTrue: [ ^'UTF-16LE' ].
    (self size >= 3 and: [ (self valueAt: 1) = 16rEF and: [
    	(self valueAt: 2) = 16rBB and: [
    	(self valueAt: 3) = 16rBF ]]]) ifTrue: [ ^'UTF-8' ].

    encoding := self class defaultEncoding.
    encoding asString = 'UTF-16' ifTrue: [ ^self utf16Encoding ].
    encoding asString = 'UTF-32' ifTrue: [ ^self utf32Encoding ].
    ^encoding!

utf32Encoding
    "Assuming the receiver is encoded as UTF-16 with a proper
     endianness marker, answer the correct encoding of the receiver."

    (self size >= 4 and: [ (self valueAt: 4) = 0 and: [ (self valueAt: 3) = 0 and: [
    	(self valueAt: 2) = 254 and: [
    	(self valueAt: 1) = 255 ]]]]) ifTrue: [ ^'UTF-32LE' ].
    ^'UTF-32BE'
!

utf16Encoding
    "Assuming the receiver is encoded as UTF-16 with a proper
     endianness marker, answer the correct encoding of the receiver."

    (self size >= 2 and: [
    	(self valueAt: 2) = 254 and: [
    	(self valueAt: 1) = 255 ]]) ifTrue: [ ^'UTF-16LE' ].
    ^'UTF-16BE'
! !


!UnicodeCharacter methodsFor: 'converting'!

asString
    "Return a String with the contents of the receiver, converted
     into the default locale character set."
    ^(I18N.EncodedStream encoding: (UnicodeString with: self)) contents!

asString: encoding
    "Return a String with the contents of the receiver, converted
     into the requested encoding."
    ^(I18N.EncodedStream
	encoding: (UnicodeString with: self)
	as: encoding) contents!

asUnicodeString
    "Return a UnicodeString with the contents of the receiver, converted
     from the default locale character set.  Raise an exception if the
     receiver is not a valid 1-byte character in the given character set."
     ^(UnicodeString with: self)!

asUnicodeString: encoding
    self shouldNotImplement!


!Character methodsFor: 'converting'!

asString: encoding
    "Return a String with the contents of the receiver, interpreted
     into the requested encoding."
    ^I18N.EncodedString fromString: (String with: self) encoding: encoding!

asString
    "Return a String with the contents of the receiver, converted
     into the default locale character set."
    ^String with: self!

asUnicodeString
    "Return a UnicodeString with the contents of the receiver, converted
     from the default locale character set.  Raise an exception if the
     receiver is not a valid 1-byte character in the given character set."
     ^(String with: self) asUnicodeString!

asUnicodeString: encoding
    "Return a UnicodeString with the contents of the receiver, converted
     from the given character set.  Raise an exception if the receiver
     is not a valid 1-byte character in the given character set."
     ^(String with: self) asUnicodeString: encoding!


!UnicodeCharacter methodsFor: 'printing'!

displayOn: aStream
    "Print a representation of the receiver on aStream. Unlike
     #printOn:, this method does not display a leading dollar."
    aStream isUnicode
	ifTrue: [ aStream nextPut: self ]
	ifFalse: [ aStream nextPutAll: self asString ]!

printOn: aStream
    "Print a representation of the receiver on aStream."
    aStream nextPut: $$.
    self displayOn: aStream!


!ByteArray methodsFor: 'converting'!

asUnicodeString
    "Return an UnicodeString with the contents of the receiver, interpreted
     as the default locale character set."
    ^self asString asUnicodeString
!

asUnicodeString: aString
    "Return an UnicodeString with the contents of the receiver, interpreted
     as the default locale character set."
    ^self asString asUnicodeString: aString! !
! !


!UnicodeString methodsFor: 'converting'!

asString
    "Return a String with the contents of the receiver, converted
     into the default locale character set."
    ^(I18N.EncodedStream encoding: self) contents!

asString: aString
    "Return a String with the contents of the receiver, converted
     into the aString locale character set."
    ^(I18N.EncodedStream encoding: self as: aString) contents!

displayOn: aStream
    "Print a representation of the receiver on aStream. Unlike
     #displayOn:, this method does not include quotes."
    aStream isUnicode
	ifTrue: [ aStream nextPutAll: self ]
	ifFalse: [ self asString displayOn: aStream ]!

printOn: aStream
    "Print a representation of the receiver on aStream."
    aStream isUnicode
	ifTrue: [
	    aStream nextPut: $'.
	    aStream nextPutAll: (self copyReplaceAll: '''' with: '''''').
	    aStream nextPut: $' ]
	ifFalse: [
	    self asString printOn: aStream ]!


!PositionableStream methodsFor: 'converting'!

encoding
    "Answer the encoding of the underlying collection"
    ^collection encoding!

utf16Encoding
    "Answer the encoding of the underlying collection, assuming it's UTF-16"
    ^collection utf16Encoding!

utf32Encoding
    "Answer the encoding of the underlying collection, assuming it's UTF-32"
    ^collection utf32Encoding! !

!Stream methodsFor: 'converting'!

utf16Encoding
    "Answer the encoding of the underlying collection, assuming it's UTF-16"
    ^'UTF-16BE'!

utf32Encoding
    "Answer the encoding of the underlying collection, assuming it's UTF-32"
    ^'UTF-32BE'! !

Encoders.ToUTF7 initialize!
Encoders.FromUTF7 initialize!
EncodedStream initialize!
