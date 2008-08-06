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



Eval [
    I18N addSubspace: #Encoders
]



Error subclass: InvalidSequenceError [
    
    <category: 'i18n-Character sets'>
    <comment: 'I am raised if an invalid sequence is found while converting a
string from a charset to another'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'invalid input sequence'
    ]
]



Error subclass: IncompleteSequenceError [
    
    <category: 'i18n-Character sets'>
    <comment: 'I am raised if an invalid sequence is found while converting a
string from a charset to another.  In particular, I am raised
if the input stream ends abruptly in the middle of a multi-byte
sequence.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'incomplete input sequence'
    ]
]



SystemExceptions.SystemExceptions.InvalidArgument subclass: InvalidCharsetError [
    
    <category: 'i18n-Character sets'>
    <comment: 'I am raised if the user tries to encode from or to an unknown
encoding'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'unknown encoding specified'
    ]
]



CharacterArray subclass: EncodedString [
    | string encoding |
    
    <category: 'i18n-Character sets'>
    <comment: 'An EncodedString, like a String, is a sequence of bytes representing
a specific encoding of a UnicodeString.  Unlike a String, however,
the encoding name is known, rather than detected, irrelevant or
assumed to be the system default.'>

    EncodedString class >> fromString: aString [
	<category: 'instance creation'>
	| str |
	str := aString asString.
	str encoding = str class defaultEncoding ifTrue: [ ^str ].
	^self fromString: str encoding: str encoding
    ]

    EncodedString class >> fromString: aString encoding: encoding [
	<category: 'instance creation'>
	| str |
	str := aString isString 
		    ifTrue: [aString]
		    ifFalse: [aString asString: encoding].
	str encoding = encoding ifTrue: [ ^str ].
	^(self basicNew)
	    setString: aString;
	    encoding: encoding
    ]

    EncodedString class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    EncodedString class >> new: size [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    EncodedString class >> isUnicode [
	"Answer false; the receiver stores bytes (i.e. an encoded
	 form), not characters."

	<category: 'accessing'>
	^false
    ]

    asString [
	<category: 'accessing'>
	^string
    ]

    asUnicodeString [
	<category: 'accessing'>
	^string asUnicodeString: encoding
    ]

    at: anIndex [
	<category: 'accessing'>
	^string at: anIndex
    ]

    at: anIndex put: anObject [
	<category: 'accessing'>
	^string at: anIndex put: anObject
    ]

    do: aBlock [
	<category: 'accessing'>
	string do: aBlock
    ]

    encoding [
	<category: 'accessing'>
	encoding = 'UTF-32' ifTrue: [^string utf32Encoding ].
	encoding = 'UTF-16' ifTrue: [^string utf16Encoding ].
	^encoding
    ]

    hash [
	<category: 'accessing'>
	^string hash bitXor: encoding hash
    ]

    species [
	<category: 'accessing'>
	^EncodedStringFactory encoding: self encoding
    ]

    size [
	<category: 'accessing'>
	^string size
    ]

    utf16Encoding [
	<category: 'accessing'>
	^string utf16Encoding
    ]

    utf32Encoding [
	<category: 'accessing'>
	^string utf32Encoding
    ]

    valueAt: anIndex [
	<category: 'accessing'>
	^string valueAt: anIndex
    ]

    valueAt: anIndex put: anObject [
	<category: 'accessing'>
	^string valueAt: anIndex put: anObject
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #printOn:, this method does not display the encoding and
	 enclosing quotes."

	<category: 'printing'>
	string displayOn: aStream
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: encoding;
	    nextPut: $[.
	(string asUnicodeString: encoding) asString printOn: aStream.
	aStream nextPut: $]
    ]

    copy [
	<category: 'copying'>
	^self class fromString: string copy encoding: self encoding
    ]

    copyEmpty [
	<category: 'copying'>
	^self class fromString: (string copyEmpty: string size)
	    encoding: self encoding
    ]

    copyEmpty: size [
	<category: 'copying'>
	^self class fromString: (string copyEmpty: size) encoding: self encoding
    ]

    setString: aString [
	<category: 'initializing'>
	string := aString
    ]

    encoding: aString [
	<category: 'initializing'>
	encoding := aString
    ]
]



Object subclass: EncodedStringFactory [
    | encoding |
    
    <category: 'i18n-Character sets'>
    <comment: 'An EncodedStringFactory is used (in place of class objects) so that
Encoders can return EncodedString objects with the correct encoding.'>

    EncodedStringFactory class >> encoding: aString [
	"Answer a new EncodedStringFactory, creating strings with the
	 given encoding."

	<category: 'instance creation'>
	^self new encoding: aString
    ]

    fromString: aString [
	"Answer an EncodedString based on aString and in the encoding
	 represented by the receiver."

	<category: 'instance creation'>
	^EncodedString fromString: aString encoding: self encoding
    ]

    new [
	"Answer a new, empty EncodedString using the encoding
	 represented by the receiver."

	<category: 'instance creation'>
	^EncodedString fromString: String new encoding: self encoding
    ]

    new: size [
	"Answer a new EncodedString of the given size, using the encoding
	 represented by the receiver."

	<category: 'instance creation'>
	^EncodedString fromString: (String new: size) encoding: self encoding
    ]

    isUnicode [
	"Answer false; the receiver stores bytes (i.e. an encoded
	 form), not characters."

	<category: 'accessing'>
	^false
    ]

    encoding [
	"Answer the encoding used for the created Strings."

	<category: 'instance creation'>
	^encoding
    ]

    encoding: aString [
	"Set the encoding used for the created Strings."

	<category: 'instance creation'>
	encoding := aString
    ]
]



Stream subclass: Encoder [
    | origin from to factory |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is the superclass of streams that take an origin
and encode it to another character set.  The subclasses are
are for internal use unless you are writing support for your own
encodings.'>

    Encoder class >> on: aStringOrStream from: fromEncoding to: toEncoding [
	"Answer a new encoder that translates from fromEncoding
	 to toEncoding.  The encodings are guaranteed to be
	 those for which the encoder was registered."

	<category: 'instance creation'>
	^self basicNew 
	    initializeFrom: fromEncoding
	    to: toEncoding
	    origin: aStringOrStream
    ]

    atEnd [
	"Return whether the receiver can produce another character in
	 the receiver; by default, this is true if there is another
	 character in the origin."

	<category: 'stream operations'>
	^self atEndOfInput
    ]

    next [
	"Return the next character in the receiver; by default,
	 this is the next character in the origin."

	<category: 'stream operations'>
	^self nextInput
    ]

    atEndOfInput [
	"Return whether there is another character in the origin.  This
	 method is for private use by encoders, calling it outside won't
	 corrupt the internal state of the encoder but the result
	 probably won't be meaningful (depending on the innards of the
	 encoder)."

	<category: 'stream operations'>
	^origin atEnd
    ]

    peekInput [
	"Return the next character in the origin without advancing it."

	<category: 'stream operations'>
	^origin peek
    ]

    nextInput [
	"Return the next character in the origin.  This method is for
	 private use by encoders, calling it outside may corrupt the
	 internal state of the encoder."

	<category: 'stream operations'>
	^origin next
    ]

    nextInputAvailable: n into: aCollection startingAt: pos [
	"Place up to N characters from the origin in aCollection.  This method is for
	 private use by encoders, calling it outside may corrupt the
	 internal state of the encoder."

	<category: 'stream operations'>
	^origin nextAvailable: n into: aCollection startingAt: pos
    ]

    species [
	"We answer a string of Characters encoded in our destination
	 encoding."

	<category: 'stream operations'>
	factory isNil 
	    ifTrue: 
		[factory := to = String defaultEncoding 
			    ifTrue: [String]
			    ifFalse: [EncodedStringFactory encoding: to]].
	^factory
    ]

    initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream [
	<category: 'private - initialization'>
	from := fromEncoding.
	to := toEncoding.
	origin := (aStringOrStream isKindOf: Stream) 
		    ifFalse: [aStringOrStream readStream]
		    ifTrue: [aStringOrStream].
	self flush
    ]
]



Stream subclass: EncodedStream [
    
    <import: Encoders>
    <category: 'i18n-Character sets'>
    <comment: 'This class is a factory for subclasses of Encoder.  Encoders
act as parts of a pipe, hence this class provides methods that
construct an appropriate pipe.'>

    EncodersRegistry := nil.

    EncodedStream class >> initialize [
	"Initialize the registry of the encoders to include the standard
	 encoders contained in the library."

	<category: 'initializing'>
	EncodersRegistry := #().
    ]

    EncodedStream class >> registerEncoderFor: arrayOfAliases toUTF32: toUTF32Class fromUTF32: fromUTF32Class [
	"Register the two classes that will respectively convert from the
	 charsets in arrayOfAliases to UTF-32 and vice versa.
	 
	 The former class is a stream that accepts characters and returns
	 (via #next) integers representing UTF-32 character codes, while
	 the latter accepts UTF-32 character codes and converts them to
	 characters.  For an example see respectively FromUTF7 and ToUTF7
	 (I admit it is not a trivial example)."

	<category: 'initializing'>
	EncodersRegistry := EncodersRegistry copyWith: 
			{arrayOfAliases.
			toUTF32Class.
			fromUTF32Class}
    ]

    EncodedStream class >> bigEndianPivot [
	"When only one of the sides is implemented in Smalltalk
	 and the other is obtained via iconv, we use UTF-32 to
	 marshal data from Smalltalk to iconv; answer whether we
	 should encode UTF-32 characters as big-endian."

	<category: 'private - triangulating'>
	^Memory bigEndian
    ]

    EncodedStream class >> pivotEncoding [
	"When only one of the sides is implemented in Smalltalk
	 and the other is obtained via iconv, we need a common
	 pivot encoding to marshal data from Smalltalk to iconv.
	 Answer the iconv name of this encoding."

	<category: 'private - triangulating'>
	^self bigEndianPivot ifTrue: ['UTF-32BE'] ifFalse: ['UTF-32LE']
    ]

    EncodedStream class >> split: input to: encoding [
	"Answer a pipe with the given input stream (which produces
	 UTF-32 character codes as integers) and whose output is
	 a series of Characters in the required pivot encoding"

	<category: 'private - triangulating'>
	^(encoding = 'UCS-4BE' or: [encoding = 'UTF-32BE']) 
	    ifTrue: 
		[SplitUTF32BE 
		    on: input
		    from: 'UTF-32'
		    to: encoding]
	    ifFalse: 
		[SplitUTF32LE 
		    on: input
		    from: 'UTF-32'
		    to: encoding]
    ]

    EncodedStream class >> compose: input from: encoding [
	"Answer a pipe with the given input stream (which produces
	 Characters in the required pivot encoding) and whose output
	 is a series of integer UTF-32 character codes."

	<category: 'private - triangulating'>
	^(encoding = 'UCS-4BE' or: [encoding = 'UTF-32BE']) 
	    ifTrue: 
		[ComposeUTF32BE 
		    on: input
		    from: encoding
		    to: 'UTF-32']
	    ifFalse: 
		[ComposeUTF32LE 
		    on: input
		    from: encoding
		    to: 'UTF-32']
    ]

    EncodedStream class >> encoding: anUnicodeString [
	"Answer a pipe of encoders that converts anUnicodeString to default
	 encoding for strings (the current locale's default charset if none
	 is specified)."

	<category: 'instance creation'>
	^self encoding: anUnicodeString as: String defaultEncoding
    ]

    EncodedStream class >> encoding: aStringOrStream as: toEncoding [
	"Answer a pipe of encoders that converts anUnicodeString (which contains
	 to the supplied encoding (which can be an ASCII String or Symbol)."

	<category: 'instance creation'>
	"Adopt an uniform naming"

	| pivot to encoderTo pipe |
	to := toEncoding asString.
	(to = 'UTF-32' or: [to = 'UCS-4']) ifTrue: [to := 'UTF-32BE'].
	(to = 'UTF-16' or: [to = 'UCS-2']) ifTrue: [to := 'UTF-16BE'].

	"If converting to the pivot encoding, we're done."
	pivot := ((to startsWith: 'UCS-4') or: [to startsWith: 'UTF-32']) 
		    ifTrue: [to]
		    ifFalse: [self pivotEncoding].
	encoderTo := Iconv.
	EncodersRegistry 
	    do: [:each | ((each at: 1) includes: to) ifTrue: [encoderTo := each at: 3]].
	pipe := aStringOrStream.

	"Split UTF-32 character codes into bytes if needed by iconv."
	encoderTo == Iconv ifTrue: [pipe := self split: pipe to: pivot].

	"If not converting to the pivot encoding, we need one more step."
	to = pivot 
	    ifFalse: 
		[pipe := encoderTo 
			    on: pipe
			    from: pivot
			    to: toEncoding].
	^pipe
    ]

    EncodedStream class >> unicodeOn: aStringOrStream [
	"Answer a pipe of encoders that converts aStringOrStream (which can
	 be a string or another stream) from its encoding (or the current
	 locale's default charset, if the encoding cannot be determined)
	 to integers representing Unicode character codes."

	<category: 'instance creation'>
	^self unicodeOn: aStringOrStream encoding: aStringOrStream encoding
    ]

    EncodedStream class >> unicodeOn: aStringOrStream encoding: fromEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) from the supplied
	 encoding (which can be an ASCII String or Symbol) to
	 integers representing Unicode character codes."

	<category: 'instance creation'>
	"Adopt an uniform naming"

	| from pivot encoderFrom pipe |
	from := fromEncoding asString.
	(from = 'UTF-32' or: [from = 'UCS-4']) 
	    ifTrue: [from := aStringOrStream utf32Encoding].
	(from = 'UTF-16' or: [from = 'UCS-2']) 
	    ifTrue: [from := aStringOrStream utf16Encoding].
	pivot := 'UTF-32'.
	((from startsWith: 'UCS-4') or: [from startsWith: 'UTF-32']) 
	    ifTrue: [pivot := from].
	pivot = 'UTF-32' ifTrue: [pivot := self pivotEncoding].
	encoderFrom := Iconv.
	EncodersRegistry 
	    do: [:each | ((each at: 1) includes: from) ifTrue: [encoderFrom := each at: 2]].
	pipe := aStringOrStream.

	"If not converting from the pivot encoding, we need one more step."
	from = pivot 
	    ifFalse: 
		[pipe := encoderFrom 
			    on: pipe
			    from: fromEncoding
			    to: pivot].

	"Compose iconv-produced bytes into UTF-32 character codes if needed."
	encoderFrom == Iconv ifTrue: [pipe := self compose: pipe from: pivot].

	"Skip the BOM, if present."
	pipe peekFor: $<16rFEFF>.
	^pipe
    ]

    EncodedStream class >> on: aStringOrStream from: fromEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) from the given
	 encoding to the default locale's default charset."

	<category: 'instance creation'>
	^self 
	    on: aStringOrStream
	    from: fromEncoding
	    to: String defaultEncoding
    ]

    EncodedStream class >> on: aStringOrStream to: toEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) from the default
	 locale's default charset to the given encoding."

	<category: 'instance creation'>
	^self 
	    on: aStringOrStream
	    from: aStringOrStream encoding
	    to: toEncoding
    ]

    EncodedStream class >> on: aStringOrStream from: fromEncoding to: toEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) between the
	 two supplied encodings (which can be ASCII Strings or
	 Symbols)"

	<category: 'instance creation'>
	"Adopt an uniform naming"

	| from pivot to encoderFrom encoderTo pipe |
	from := fromEncoding asString.
	to := toEncoding asString.
	(from = 'UTF-32' or: [from = 'UCS-4']) 
	    ifTrue: [from := aStringOrStream utf32Encoding].
	(from = 'UTF-16' or: [from = 'UCS-2']) 
	    ifTrue: [from := aStringOrStream utf16Encoding].
	(to = 'UTF-32' or: [to = 'UCS-4']) ifTrue: [to := 'UTF-32BE'].
	(to = 'UTF-16' or: [to = 'UCS-2']) ifTrue: [to := 'UTF-16BE'].
	pivot := 'UTF-32'.
	((from startsWith: 'UCS-4') or: [from startsWith: 'UTF-32']) 
	    ifTrue: [pivot := from].
	((to startsWith: 'UCS-4') or: [to startsWith: 'UTF-32']) 
	    ifTrue: [pivot := to].
	pivot = 'UTF-32' ifTrue: [pivot := self pivotEncoding].
	encoderFrom := encoderTo := Iconv.
	EncodersRegistry do: 
		[:each | 
		((each at: 1) includes: to) ifTrue: [encoderTo := each at: 3].
		((each at: 1) includes: from) ifTrue: [encoderFrom := each at: 2]].

	"Let iconv do the triangulation if possible"
	(encoderFrom == Iconv and: [encoderTo == Iconv]) 
	    ifTrue: 
		[^Iconv 
		    on: aStringOrStream
		    from: fromEncoding
		    to: toEncoding].

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
	    ifFalse: 
		["Convert to our intermediate representation and split to
		 bytes if needed."

		pipe := encoderFrom 
			    on: pipe
			    from: fromEncoding
			    to: pivot.
		encoderTo == Iconv 
		    ifTrue: 
			[pipe := self split: pipe to: pivot.

			"Check if we already reached the destination format."
			to = pivot ifTrue: [^pipe]]].

	"Compose iconv-produced bytes into UTF-32 character codes if needed."
	encoderFrom == Iconv ifTrue: [pipe := self compose: pipe from: pivot].
	^encoderTo 
	    on: pipe
	    from: pivot
	    to: toEncoding
    ]
]



Namespace current: I18N.Encoders [

Encoder subclass: FromUTF32 [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is a superclass for classes that convert from UTF-32
characters (encoded as 32-bit Integers) to bytes in another
encoding (encoded as Characters).'>
]

]



Namespace current: I18N.Encoders [

Encoder subclass: ToUTF32 [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is a superclass for classes that convert from bytes
(encoded as Characters) to UTF-32 characters (encoded as 32-bit
Integers to simplify the code and to avoid endianness conversions).'>

    species [
	"We answer a UnicodeString of Unicode characters encoded as UTF-32."

	<category: 'stream operation'>
	^UnicodeString
    ]
]

]



Namespace current: I18N.Encoders [

ToUTF32 subclass: ComposeUTF32LE [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to provide UTF-32 characters encoded as
32-bit integers for a descendent of FromUTF32, when the starting
encoding is little-endian.'>

    next [
	"Answer a 32-bit integer obtained by reading four 8-bit character
	 codes in little-endian order and putting them together"

	<category: 'stream operation'>
	^(self nextInput asInteger + (self nextInput asInteger bitShift: 8) 
	    + (self nextInput asInteger bitShift: 16) 
		+ (self nextInput asInteger bitShift: 24)) asCharacter
    ]
]

]



Namespace current: I18N.Encoders [

ToUTF32 subclass: ComposeUTF32BE [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to provide UTF-32 characters encoded as
32-bit integers for a descendent of FromUTF32, when the starting
encoding is big-endian.'>

    next [
	"Answer a 32-bit integer obtained by reading four 8-bit character
	 codes in big-endian order and putting them together"

	"This code attempts to create as few large integers as possible"

	<category: 'stream operation'>
	^((((((self nextInput asInteger bitShift: 8) 
	    bitOr: self nextInput asInteger) bitShift: 8) 
	    bitOr: self nextInput asInteger) bitShift: 8) 
	    bitOr: self nextInput asInteger) asCharacter
    ]
]

]



Namespace current: I18N.Encoders [

FromUTF32 subclass: SplitUTF32LE [
    | wch |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to split into four 8-bit characters
the 32-bit UTF-32 integers coming from a descendent of ToUTF32, when
the destination encoding is little-endian.'>

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'stream operation'>
	^wch == 1 and: [self atEndOfInput]
    ]

    next [
	"Answer an 8-bit Character obtained by converting each 32-bit
	 Integer found in the origin to the four bytes that make it up,
	 and ordering them from the least significant to the most
	 significant."

	<category: 'stream operation'>
	| answer |
	wch == 1 
	    ifTrue: 
		["Answer the LSB.  This code will create as few LargeIntegers
		 as possible by setting the mark bit only after the LSB has
		 been extracted."

		wch := answer := self nextInput codePoint.
		wch := (wch bitShift: -8) + 16777216.
		^Character value: (answer bitAnd: 255)].

	"Answer any other byte"
	answer := wch bitAnd: 255.
	wch := wch bitShift: -8.
	^Character value: answer
    ]

    flush [
	"Flush any remaining bytes in the last 32-bit character read from
	 the input"

	<category: 'stream operation'>
	wch := 1
    ]
]

]



Namespace current: I18N.Encoders [

FromUTF32 subclass: SplitUTF32BE [
    | count wch |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to split into four 8-bit characters
the 32-bit UTF-32 integers coming from a descendent of ToUTF32, when
the destination encoding is big-endian.'>

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'stream operation'>
	^count == 0 and: [self atEndOfInput]
    ]

    next [
	"Answer an 8-bit Character obtained by converting each 32-bit
	 Integer found in the origin to the four bytes that make it up,
	 and ordering them from the most significant to the least
	 significant."

	<category: 'stream operation'>
	| answer |
	count == 0 
	    ifTrue: 
		["Answer the MSB.  This code will create as few LargeIntegers
		 as possible by discarding the bits we answer and operating
		 on SmallIntegers once only bits 0..23 remain."

		wch := answer := self nextInput codePoint.
		wch := wch bitAnd: 16777215.
		count := 3.
		^Character value: (answer bitShift: -24)].

	"Answer any other byte.  We keep things so that the byte we answer
	 is always in bits 16..23 when we arrive here."
	answer := wch bitShift: -16.
	wch := wch bitAnd: 65535.
	wch := wch bitShift: 8.
	count := count - 1.
	^Character value: answer
    ]

    flush [
	"Flush any remaining bytes in the last 32-bit character read from
	 the input"

	<category: 'stream operation'>
	count := 0
    ]
]

]



Namespace current: I18N.Encoders [

Encoder subclass: Iconv [
    | iconvHandle readBuffer readPos readEnd recodedBuffer recodedPos recodedEnd |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used to delegate the actual character set conversion
to the C library''s iconv function.  Most conversions use iconv as
the only step in the conversions, sometimes the structure is 
ToUTF32+SplitUTF32xx+Iconv or Iconv+ComposeUTF32xx+FromUTF32, rarely
Iconv is skipped altogether and only Smalltalk converters are used.'>

    Iconv class >> initialize [
	<category: 'private - living across snapshots'>
	ObjectMemory addDependent: self
    ]

    Iconv class >> update: aspect [
	<category: 'private - living across snapshots'>
	aspect == #aboutToSnapshot
	    ifTrue: [self allInstancesDo: [:each | each release]]
    ]

    iconvOpen: to from: from [
	<category: 'C call-outs'>
	<cCall: 'iconv_open' returning: #cObject args: #(#string #string)>
	
    ]

    iconvClose: handle [
	<category: 'C call-outs'>
	<cCall: 'iconv_close' returning: #void args: #(#cObject)>
	
    ]

    iconvOn: handle from: readBuffer at: readPos size: readCount to: writeBuffer size: writeCount state: bytesLeft [
	<category: 'C call-outs'>
	<cCall: 'iconvWrapper' returning: #boolean
	args: #(#cObject #smalltalk #int #int #smalltalk #int #smalltalk)>
	
    ]

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'stream operation'>
	^self atEndOfBuffer and: [self convertMore]
    ]

    next [
	"Answer the next character that the receiver can produce."

	<category: 'stream operation'>
	| answer |
	(self atEndOfBuffer and: [self convertMore])
	    ifTrue: [^self pastEnd].
	answer := recodedBuffer at: recodedPos.
	recodedPos := recodedPos + 1.
	^answer
    ]

    nextAvailable: anInteger putAllOn: aStream [
	"Copy up to anInteger bytes from the next buffer's worth of data
	 from the receiver to aStream."

	<category: 'stream operation'>
	| n |
	(self atEndOfBuffer and: [self convertMore])
	    ifTrue: [^self pastEnd].
	n := anInteger min: recodedEnd - recodedPos + 1.
	aStream
	    next: n
	    putAll: recodedBuffer
	    startingAt: recodedPos.
	recodedPos := recodedPos + n.
	^n
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
	"Store up to anInteger bytes from the next buffer's worth of data
	 from the receiver onto aCollection."

	<category: 'stream operation'>
	| n |
	(self atEndOfBuffer and: [self convertMore])
	    ifTrue: [^self pastEnd].
	n := anInteger min: recodedEnd - recodedPos + 1.
	aCollection
	    replaceFrom: pos to: pos + n - 1
	    with: recodedBuffer
	    startingAt: recodedPos.
	recodedPos := recodedPos + n.
	^n
    ]

    release [
	<category: 'private - living across snapshots'>
	self
	    removeToBeFinalized;
	    finalize
    ]

    finalize [
	<category: 'private - living across snapshots'>
	iconvHandle isNil ifTrue: [^self].
	self iconvClose: iconvHandle.
	iconvHandle := nil
    ]

    iconvOpen [
	<category: 'private - living across snapshots'>
	iconvHandle isNil ifFalse: [self release].
	iconvHandle := self iconvOpen: to from: from.
	iconvHandle address = 4294967295 
	    ifTrue: [^InvalidCharsetError signal: 
			{from.
			to}].
	self addToBeFinalized.
    ]

    atEndOfBuffer [
	"Answer whether we ate all the characters that iconv had
	 converted to the destination encoding."

	<category: 'private - conversion'>
	^recodedPos > recodedEnd
    ]

    refill [
	"Make it so that iconv will always have a decent number of
	 characters to convert, by keeping the number of used
	 bytes in the read buffer above bufferSize-refillThreshold"

	<category: 'private - conversion'>
	| data |
	readPos > self refillThreshold 
	    ifTrue: 
		[readBuffer 
		    replaceFrom: 1
		    to: readEnd - readPos + 1
		    with: readBuffer
		    startingAt: readPos.
		readEnd := readEnd - readPos + 1.
		readPos := 1].

	readEnd := readEnd + (self
	    nextInputAvailable: self bufferSize - readEnd
	    into: readBuffer
	    startingAt: readEnd + 1).
    ]

    initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream [
	<category: 'private - conversion'>
	super 
	    initializeFrom: fromEncoding
	    to: toEncoding
	    origin: aStringOrStream.
	readPos := 1.
	readEnd := 0.
	recodedPos := 1.
	recodedEnd := 0
    ]

    bufferSize [
	"Answer the size of the buffers we pass to iconv"

	<category: 'private - conversion'>
	^1024
    ]

    refillThreshold [
	"Answer the threshold for readPos (the first unused
	 byte in the input buffer), above which we read
	 more characters from the input."

	<category: 'private - conversion'>
	^1000
    ]

    initBuffers [
	"Initialize the input and output buffer for icode"

	<category: 'private - conversion'>
	readBuffer := String new: self bufferSize.
	recodedBuffer := String new: self bufferSize
    ]

    convertMore [
	<category: 'private - conversion'>
	| oldReadPos bytesLeft fine |
	recodedBuffer isNil ifTrue: [self initBuffers].
	readBuffer isNil ifTrue: [^true].
	iconvHandle isNil ifTrue: [self iconvOpen].
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
	oldReadPos := readPos.
	readPos := readEnd + 1 - (bytesLeft at: 1).
	recodedEnd := self bufferSize - (bytesLeft at: 2).
	recodedPos := 1.
	fine ifFalse: [InvalidSequenceError signal. ^true].
	readPos > readEnd ifFalse: [
	    readPos = oldReadPos ifTrue: [ IncompleteSequenceError signal ].
	    ^readPos = oldReadPos ].
	self atEndOfInput ifFalse: [^false].

	"At end of input, check whether the last character was complete."
	readBuffer := nil.
	^recodedEnd = 0
    ]
]

]

"Now add some extensions to the system classes"



Namespace current: I18N [
    (String classPool includesKey: #DefaultEncoding) 
	ifFalse: [String addClassVarName: #DefaultEncoding]
]



String class extend [

    defaultDefaultEncoding [
	"Answer the encoding that is used in case the user specifies none."

	<category: 'converting'>
	^'UTF-8'
    ]

    defaultEncoding [
	"Answer the default encoding that is used for transcoding."

	<category: 'converting'>
	DefaultEncoding isNil ifTrue: [^self defaultDefaultEncoding].
	^DefaultEncoding
    ]

    defaultEncoding: aString [
	"Answer the default locale's default charset"

	<category: 'converting'>
	DefaultEncoding := aString
    ]

]



CharacterArray extend [

    asString: aString [
	"Return a String with the contents of the receiver, converted
	 into the aString locale character set."

	<category: 'multibyte encodings'>
	^(I18N.EncodedStream 
	    on: self
	    from: self encoding
	    to: aString) contents
    ]

    asUnicodeString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'multibyte encodings'>
	^(I18N.EncodedStream unicodeOn: self) contents
    ]

    numberOfCharacters [
	"Answer the number of Unicode characters in the receiver, interpreting it
	 as the default locale character set."

	<category: 'multibyte encodings'>
	^self asUnicodeString numberOfCharacters
    ]

]



String extend [

    numberOfCharacters: aString [
	"Answer the number of Unicode characters in the receiver, interpreting it
	 in the character encoding aString."

	<category: 'multibyte encodings'>
	^(self asUnicodeString: aString) numberOfCharacters
    ]

    asUnicodeString: aString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'multibyte encodings'>
	^(I18N.EncodedStream unicodeOn: self encoding: aString) contents
    ]

    encoding [
	"Answer the encoding of the receiver, assuming it is in the
	 default locale's default charset"

	<category: 'converting'>
	| encoding |
	(self size >= 4 and: 
		[(self valueAt: 1) = 0 and: 
			[(self valueAt: 2) = 0 
			    and: [(self valueAt: 3) = 254 and: [(self valueAt: 4) = 255]]]]) 
	    ifTrue: [^'UTF-32BE'].
	(self size >= 4 and: 
		[(self valueAt: 4) = 0 and: 
			[(self valueAt: 3) = 0 
			    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]]]) 
	    ifTrue: [^'UTF-32LE'].
	(self size >= 2 
	    and: [(self valueAt: 1) = 254 and: [(self valueAt: 2) = 255]]) 
		ifTrue: [^'UTF-16BE'].
	(self size >= 2 
	    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]) 
		ifTrue: [^'UTF-16LE'].
	(self size >= 3 and: 
		[(self valueAt: 1) = 239 
		    and: [(self valueAt: 2) = 187 and: [(self valueAt: 3) = 191]]]) 
	    ifTrue: [^'UTF-8'].
	encoding := self class defaultEncoding.
	encoding asString = 'UTF-16' ifTrue: [^self utf16Encoding].
	encoding asString = 'UTF-32' ifTrue: [^self utf32Encoding].
	^encoding
    ]

    utf32Encoding [
	"Assuming the receiver is encoded as UTF-16 with a proper
	 endianness marker, answer the correct encoding of the receiver."

	<category: 'converting'>
	(self size >= 4 and: 
		[(self valueAt: 4) = 0 and: 
			[(self valueAt: 3) = 0 
			    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]]]) 
	    ifTrue: [^'UTF-32LE'].
	^'UTF-32BE'
    ]

    utf16Encoding [
	"Assuming the receiver is encoded as UTF-16 with a proper
	 endianness marker, answer the correct encoding of the receiver."

	<category: 'converting'>
	(self size >= 2 
	    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]) 
		ifTrue: [^'UTF-16LE'].
	^'UTF-16BE'
    ]

]



UnicodeCharacter extend [

    asString [
	"Return a String with the contents of the receiver, converted
	 into the default locale character set."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: (UnicodeString with: self)) contents
    ]

    asString: encoding [
	"Return a String with the contents of the receiver, converted
	 into the requested encoding."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: (UnicodeString with: self) as: encoding) 
	    contents
    ]

    asUnicodeString [
	"Return a UnicodeString with the contents of the receiver, converted
	 from the default locale character set.  Raise an exception if the
	 receiver is not a valid 1-byte character in the given character set."

	<category: 'converting'>
	^UnicodeString with: self
    ]

    asUnicodeString: encoding [
	<category: 'converting'>
	self shouldNotImplement
    ]

]



Character extend [

    asString: encoding [
	"Return a String with the contents of the receiver, interpreted
	 into the requested encoding."

	<category: 'converting'>
	^I18N.EncodedString fromString: (String with: self) encoding: encoding
    ]

    asString [
	"Return a String with the contents of the receiver, converted
	 into the default locale character set."

	<category: 'converting'>
	^String with: self
    ]

    asUnicodeString [
	"Return a UnicodeString with the contents of the receiver, converted
	 from the default locale character set.  Raise an exception if the
	 receiver is not a valid 1-byte character in the given character set."

	<category: 'converting'>
	^(String with: self) asUnicodeString
    ]

    asUnicodeString: encoding [
	"Return a UnicodeString with the contents of the receiver, converted
	 from the given character set.  Raise an exception if the receiver
	 is not a valid 1-byte character in the given character set."

	<category: 'converting'>
	^(String with: self) asUnicodeString: encoding
    ]

]



UnicodeCharacter extend [

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #printOn:, this method does not display a leading dollar."

	<category: 'printing'>
	aStream isUnicode 
	    ifTrue: [aStream nextPut: self]
	    ifFalse: [aStream nextPutAll: self asString]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream nextPut: $$.
	self displayOn: aStream
    ]

]



ByteArray extend [

    asString: aString [
	"Return a String with the contents of the receiver, interpreted
	 as the locale character set given by aString."

	<category: 'converting'>
	^self asString asUnicodeString
    ]

    asUnicodeString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'converting'>
	^self asString asUnicodeString
    ]

    asUnicodeString: aString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'converting'>
	^self asString asUnicodeString: aString
    ]

]



UnicodeString extend [

    asString [
	"Return a String with the contents of the receiver, converted
	 into the default locale character set."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: self) contents
    ]

    asString: aString [
	"Return a String with the contents of the receiver, converted
	 into the aString locale character set."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: self as: aString) contents
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #displayOn:, this method does not include quotes."

	<category: 'converting'>
	aStream isUnicode 
	    ifTrue: [aStream nextPutAll: self]
	    ifFalse: [self asString displayOn: aStream]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'converting'>
	aStream isUnicode 
	    ifTrue: 
		[aStream nextPut: $'.
		aStream nextPutAll: (self copyReplaceAll: '''' with: '''''').
		aStream nextPut: $']
	    ifFalse: [self asString printOn: aStream]
    ]

]



PositionableStream extend [

    encoding [
	"Answer the encoding of the underlying collection"

	<category: 'converting'>
	^collection encoding
    ]

    utf16Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-16"

	<category: 'converting'>
	^collection utf16Encoding
    ]

    utf32Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-32"

	<category: 'converting'>
	^collection utf32Encoding
    ]

]



Stream extend [

    utf16Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-16"

	<category: 'converting'>
	^'UTF-16BE'
    ]

    utf32Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-32"

	<category: 'converting'>
	^'UTF-32BE'
    ]

]



FileDescriptor extend [

    encoding [
	"Answer the encoding that is used when storing Unicode characters."

	<category: 'converting'>
	^self species defaultEncoding
    ]

    utf16Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-16.
	 Return big-endian UTF-16 since that's the default."

	<category: 'converting'>
	^'UTF-16BE'
    ]

    utf32Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-32.
	 Return big-endian UTF-32 since that's the default."

	<category: 'converting'>
	^'UTF-32BE'
    ]

]



Namespace current: I18N [
    Encoders.Iconv initialize.
    EncodedStream initialize
]

