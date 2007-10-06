"======================================================================
|
|   Abstract ContentHandler class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: ContentHandler [
    | stream |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    ContentHandler class [
	| validTypes |
	
    ]

    FileExtensionMap := nil.
    FileTypeMap := nil.

    ContentHandler class >> contentTypeFor: aFileName ifAbsent: aBlock [
	"Guess a MIME content type for the given file name and answer it.
	 If no interesting value could be found, evaluate aBlock"

	<category: 'checking files'>
	| posi |
	posi := aFileName findLast: [:each | each = $.].
	posi = 0 ifTrue: [^aBlock value].
	^FileExtensionMap at: (aFileName copyFrom: posi + 1 to: aFileName size)
	    ifAbsent: aBlock
    ]

    ContentHandler class >> contentTypeFor: aFileName [
	"Guess a MIME content type for the given file name and answer it"

	<category: 'checking files'>
	^self contentTypeFor: aFileName ifAbsent: ['application/octet-stream']
    ]

    ContentHandler class >> guessContentTypeFor: aPositionableStream ifAbsent: aBlock [
	"Guess a MIME content type for the given file name and answer it.
	 If no interesting value could be found, evaluate aBlock"

	<category: 'checking files'>
	| str ba text |
	str := aPositionableStream nextAvailable: 12.
	ba := str asByteArray.
	FileTypeMap do: 
		[:each | 
		| ok |
		ok := true.
		(each at: 1) doWithIndex: 
			[:ch :index | 
			(ch isSymbol or: [index >= str size]) 
			    ifFalse: 
				[ch isInteger 
				    ifTrue: [ok := ok and: [(ba at: index) = ch]]
				    ifFalse: [ok := ok and: [(str at: index) = ch]]]].
		ok ifTrue: [^each at: 2]].
	str := str , (aPositionableStream nextAvailable: 200).
	text := str allSatisfy: [:each | each value <= 127].
	^text ifTrue: ['text/plain'] ifFalse: aBlock
    ]

    ContentHandler class >> guessContentTypeFor: aPositionableStream [
	"Guess a MIME content type for the given file contents and answer it."

	<category: 'checking files'>
	^self guessContentTypeFor: aPositionableStream
	    ifAbsent: ['application/octet-stream']
    ]

    ContentHandler class >> classFor: mimeType [
	"Answer a subclass of the receiver (or the receiver itself if none
	 could be found) that can handle the mimeType content type (a String)."

	<category: 'checking files'>
	self 
	    withAllSubclassesDo: [:each | (each validTypes includes: mimeType) ifTrue: [^each]].
	^self
    ]

    ContentHandler class >> defaultFileExtensionMap [
	"Answer a default extension->mime type map"

	<category: 'accessing'>
	^#(#('aif' 'audio/x-aiff') #('ai' 'application/postscript') #('aifc' 'audio/aiff') #('aiff' 'audio/x-aiff') #('au' 'audio/basic') #('avi' 'video/x-msvideo') #('bmp' 'image/bmp') #('cdf' 'application/x-cdf') #('cer' 'application/x-x509-ca-cert') #('crt' 'application/x-x509-ca-cert') #('css' 'text/css') #('dcr' 'application/x-director') #('der' 'application/x-x509-ca-cert') #('dir' 'application/x-director') #('dll' 'application/x-msdownload') #('doc' 'application/msword') #('dot' 'application/msword') #('dxr' 'application/x-director') #('eml' 'message/rfc822') #('eps' 'application/postscript') #('exe' 'application/x-msdownload') #('fif' 'application/fractals') #('gif' 'image/gif') #('gz' 'application/x-gzip') #('hqx' 'application/mac-binhex40') #('htm' 'text/html') #('html' 'text/html') #('htt' 'text/webviewhtml') #('ins' 'application/x-internet-signup') #('isp' 'application/x-internet-signup') #('ivf' 'video/x-ivf') #('jfif' 'image/pjpeg') #('jpe' 'image/jpeg') #('jpeg' 'image/jpeg') #('jpg' 'image/jpeg') #('latex' 'application/x-latex') #('m1v' 'video/mpeg') #('man' 'application/x-troff-man') #('mht' 'message/rfc822') #('mhtml' 'message/rfc882') #('mid' 'audio/mid') #('mov' 'movie/quicktime') #('mov' 'video/quicktime') #('mp2' 'video/mpeg') #('mpa' 'video/mpeg') #('mpe' 'movie/mpeg') #('mpeg' 'movie/mpeg') #('mpg' 'video/mpeg') #('nws' 'message/rfc822') #('p7c' 'application/pkcs7-mime') #('png' 'image/png') #('pdf' 'application/pdf') #('pot' 'application/vnd.ms-powerpoint') #('ppa' 'application/vnd.ms-powerpoint') #('pps' 'application/vnd.ms-powerpoint') #('ppt' 'application/vnd.ms-powerpoint') #('ps' 'application/postscript') #('pwz' 'application/vnd.ms-powerpoint') #('qt' 'video/quicktime') #('rmi' 'audio/mid') #('rtf' 'application/msword') #('sgm' 'text/sgml') #('sgml' 'text/sgml') #('sit' 'application/x-stuffit') #('snd' 'audio/basic') #('spl' 'application/futuresplash') #('st' 'text/plain') #('swf' 'application/x-shockwave-flash') #('svg' 'image/svg+xml') #('tar' 'application/x-tar') #('tgz' 'application/x-compressed') #('tif' 'image/tiff') #('tiff' 'image/tiff') #('txt' 'text/plain') #('wav' 'audio/wav') #('wiz' 'application/msword') #('xbm' 'image/x-xbitmap') #('xml' 'text/xml') #('xls' 'application/vnd.ms-excel') #('z' 'application/x-compress') #('zip' 'application/x-zip-compressed'))	"Of course!"
    ]

    ContentHandler class >> defaultFileTypeMap [
	"Answer a default file contents->mime type map. Each element is
	 an array; the first element of the array is matched against the
	 data passed to #guessContentTypeFor:. A character or integer is
	 matched against a single byte, while if a Symbol is found, the
	 corresponding byte in the data stream is not compared against
	 anything"

	<category: 'accessing'>
	^#(#('MZ' 'application/x-msdownload') #(#($P $K 3 4) 'application/x-zip-compressed') #('%PDF' 'application/pdf') #('%!PS' 'application/postscript') #('.snd' 'audio/basic') #('dns.' 'audio/basic') #('MThd' 'audio/mid') #(#($R $I $F $F #- #- #- #- $R $M $I $D) 'audio/mid') #(#($R $I $F $F #- #- #- #- $W $A $V $E) 'audio/x-wav') #('<!DOCTYPE H' 'text/html') #('<!--' 'text/html') #('<html' 'text/html') #('<HTML' 'text/html') #('<?x' 'text/xml') #('<!' 'text/sgml') #('GIF8' 'image/gif') #('#def' 'image/x-bitmap') #('! XPM2' 'image/x-pixmap') #('/* XPM' 'image/x-pixmap') #(#($I $I 42 0) 'image/tiff') #(#($M $M 0 42) 'image/tiff') #(#(137 $P $N $G 13 10 26 10) 'image/png') #('BM' 'image/bmp') #(#[255 216 255 224] 'image/jpeg') #(#[255 216 255 232] 'image/jpg'))
    ]

    ContentHandler class >> contentType: type hasExtension: ext [
	"Associate the given MIME content type to the `ext' extension (without
	 leading dots)."

	<category: 'accessing'>
	^FileExtensionMap at: ext put: type
    ]

    ContentHandler class >> contentType: type hasMagicData: data [
	"Associate the given MIME content type to the magic data in `data'. Data
	 is an ArrayedCollection (usually an Array, ByteArray, or String) whose
	 contents are matched against the data passed to #guessContentTypeFor:. A
	 character or integer is matched against a single byte, while if a Symbol
	 is found, the corresponding byte in the data stream is not compared against
	 anything.  Of course a Symbol can only occur if data is an Array."

	<category: 'accessing'>
	^FileTypeMap add: (Array with: data with: type)
    ]

    ContentHandler class >> initialize [
	"Initialize the default file extension and magic data maps"

	<category: 'accessing'>
	FileExtensionMap := Dictionary new.
	FileTypeMap := self defaultFileTypeMap asOrderedCollection.
	self defaultFileExtensionMap 
	    do: [:each | FileExtensionMap at: (each at: 1) put: (each at: 2)].
	ContentHandler 
	    registerContentTypes: #('application/octet-stream' 'application/x-unknown' 'text/english' 'text/plain')
    ]

    ContentHandler class >> validTypes [
	"Answer some MIME types that instances the receiver can interpret"

	<category: 'accessing'>
	^validTypes isNil ifTrue: [#()] ifFalse: [validTypes]
    ]

    ContentHandler class >> registerContentType: contentType [
	"Register the receiver to be used to parse entities of the given MIME type.
	 contentTypes must be a String."

	<category: 'accessing'>
	validTypes isNil ifTrue: [validTypes := OrderedCollection new].
	validTypes add: contentType
    ]

    ContentHandler class >> registerContentTypes: contentTypes [
	"Register the receiver to be used to parse entities of the given MIME
	 types.  contentTypes must be a collection of Strings."

	<category: 'accessing'>
	validTypes isNil ifTrue: [validTypes := OrderedCollection new].
	validTypes addAll: contentTypes
    ]

    ContentHandler class >> on: stream [
	"Answer an instance of the receiver to be used to interpret data in the
	 given stream"

	<category: 'instance creation'>
	^self new initialize: stream
    ]

    contents [
	"By default, answer the whole contents of the stream without interpreting
	 anything; subclasses however might want to return a more interesting
	 object, failing if the data is somehow incorrect."

	<category: 'retrieving contents'>
	^stream contents
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream
    ]
]



Eval [
    ContentHandler initialize
]

