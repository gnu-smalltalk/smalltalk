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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Object subclass: #ContentHandler
	  instanceVariableNames: 'stream'
	  classVariableNames: 'FileExtensionMap FileTypeMap'
	  poolDictionaries: ''
	  category: 'NetClients-MIME'
!

ContentHandler class instanceVariableNames: 'validTypes'!

!ContentHandler class methodsFor: 'checking files'!

contentTypeFor: aFileName ifAbsent: aBlock
    "Guess a MIME content type for the given file name and answer it.
     If no interesting value could be found, evaluate aBlock"
    | posi |
    posi := aFileName findLast: [ :each | each = $. ].
    posi = 0 ifTrue: [ ^aBlock value ].

    ^FileExtensionMap
	at: (aFileName copyFrom: posi + 1 to: aFileName size)
	ifAbsent: aBlock
!


contentTypeFor: aFileName
    "Guess a MIME content type for the given file name and answer it"
    ^self
	contentTypeFor: aFileName
	ifAbsent: [ 'application/octet-stream' ]
!

guessContentTypeFor: aPositionableStream ifAbsent: aBlock
    "Guess a MIME content type for the given file name and answer it.
     If no interesting value could be found, evaluate aBlock"

     | str ba text |
     str := aPositionableStream nextAvailable: 12.
     ba := str asByteArray.

     FileTypeMap do: [ :each |
	| ok |
	ok := true.
	(each at: 1) doWithIndex: [ :ch :index |
	    (ch isSymbol or: [ index >= str size ]) ifFalse: [
		ch isInteger
		    ifTrue:  [ ok := ok and: [ ((ba  at: index) = ch) ] ]
		    ifFalse: [ ok := ok and: [ ((str at: index) = ch) ] ]
	    ]
	].
	ok ifTrue: [ ^each at: 2 ]
    ].

    str := str, (aPositionableStream nextAvailable: 200).
    text := str allSatisfy: [:each | each value <= 127 ].
    ^text
	ifTrue: [ 'text/plain' ]
	ifFalse: aBlock!

guessContentTypeFor: aPositionableStream
    "Guess a MIME content type for the given file contents and answer it."
    ^self
	guessContentTypeFor: aPositionableStream
	ifAbsent: [ 'application/octet-stream' ]
!

classFor: mimeType
    "Answer a subclass of the receiver (or the receiver itself if none
     could be found) that can handle the mimeType content type (a String)."
    self withAllSubclassesDo: [ :each |
	(each validTypes includes: mimeType) ifTrue: [ ^each ]
    ].
    ^self
! !

!ContentHandler class methodsFor: 'accessing'!

defaultFileExtensionMap
    "Answer a default extension->mime type map"
    ^#(	('aif' 'audio/x-aiff')
	('ai' 'application/postscript')
	('aifc' 'audio/aiff')
	('aiff' 'audio/x-aiff')
	('au' 'audio/basic')
	('avi' 'video/x-msvideo')
	('bmp' 'image/bmp')
	('cdf' 'application/x-cdf')
	('cer' 'application/x-x509-ca-cert')
	('crt' 'application/x-x509-ca-cert')
	('css' 'text/css')
	('dcr' 'application/x-director')
	('der' 'application/x-x509-ca-cert')
	('dir' 'application/x-director')
	('dll' 'application/x-msdownload')
	('doc' 'application/msword')
	('dot' 'application/msword')
	('dxr' 'application/x-director')
	('eml' 'message/rfc822')
	('eps' 'application/postscript')
	('exe' 'application/x-msdownload')
	('fif' 'application/fractals')
	('gif' 'image/gif')
	('gz' 'application/x-gzip')
	('hqx' 'application/mac-binhex40')
	('htm' 'text/html')
	('html' 'text/html')
	('htt' 'text/webviewhtml')
	('ins' 'application/x-internet-signup')
	('isp' 'application/x-internet-signup')
	('ivf' 'video/x-ivf')
	('jfif' 'image/pjpeg')
	('jpe' 'image/jpeg')
	('jpeg' 'image/jpeg')
	('jpg' 'image/jpeg')
	('latex' 'application/x-latex')
	('m1v' 'video/mpeg')
	('man' 'application/x-troff-man')
	('mht' 'message/rfc822')
	('mhtml' 'message/rfc882')
	('mid' 'audio/mid')
	('mov' 'movie/quicktime')
	('mov' 'video/quicktime')
	('mp2' 'video/mpeg')
	('mpa' 'video/mpeg')
	('mpe' 'movie/mpeg')
	('mpeg' 'movie/mpeg')
	('mpg' 'video/mpeg')
	('nws' 'message/rfc822')
	('p7c' 'application/pkcs7-mime')
	('pdf' 'application/pdf')
	('pot' 'application/vnd.ms-powerpoint')
	('ppa' 'application/vnd.ms-powerpoint')
	('pps' 'application/vnd.ms-powerpoint')
	('ppt' 'application/vnd.ms-powerpoint')
	('ps' 'application/postscript')
	('pwz' 'application/vnd.ms-powerpoint')
	('qt' 'video/quicktime')
	('rmi' 'audio/mid')
	('rtf' 'application/msword')
	('sgm' 'text/sgml')
	('sgml' 'text/sgml')
	('sit' 'application/x-stuffit')
	('snd' 'audio/basic')
	('spl' 'application/futuresplash')
	('st' 'text/plain')			"Of course!"
	('swf' 'application/x-shockwave-flash')
	('tar' 'application/x-tar')
	('tgz' 'application/x-compressed')
	('tif' 'image/tiff')
	('tiff' 'image/tiff')
	('txt' 'text/plain')
	('wav' 'audio/wav')
	('wiz' 'application/msword')
	('xbm' 'image/x-xbitmap')
	('xml' 'text/xml')
	('xls' 'application/vnd.ms-excel')
	('z' 'application/x-compress')
	('zip' 'application/x-zip-compressed'))
!

defaultFileTypeMap
    "Answer a default file contents->mime type map. Each element is
     an array; the first element of the array is matched against the
     data passed to #guessContentTypeFor:. A character or integer is
     matched against a single byte, while if a Symbol is found, the
     corresponding byte in the data stream is not compared against
     anything"
    ^#(
	('MZ'				      'application/x-msdownload')
	(($P  $K  3   4)		      'application/x-zip-compressed')
	('%PDF'				      'application/pdf')
	('%!PS'				      'application/postscript')
	('.snd'				      'audio/basic')
	('dns.'				      'audio/basic')
	('MThd'				      'audio/mid')
	(($R $I $F $F #- #- #- #- $R $M $I $D) 'audio/mid')
	(($R $I $F $F #- #- #- #- $W $A $V $E) 'audio/x-wav')
	('<!DOCTYPE H'			      'text/html')
	('<!--'				      'text/html')
	('<html'			      'text/html')
	('<HTML'			      'text/html')
	('<?x'	 			      'text/xml')
	('<!'	 			      'text/sgml')
	('GIF8'				      'image/gif')
	('#def'				      'image/x-bitmap')
	('! XPM2'			      'image/x-pixmap')
	('/* XPM'			      'image/x-pixmap')
	(($I  $I  42   0)		      'image/tiff')
	(($M  $M   0  42)		      'image/tiff')
	((137 $P  $N  $G  13  10 26 10)	      'image/png')
	('BM'				      'image/bmp')
	([255 216 255 224]		      'image/jpeg')
	([255 216 255 232]		      'image/jpg')
    )
!

contentType: type hasExtension: ext 
    "Associate the given MIME content type to the `ext' extension (without
     leading dots)."
    ^FileExtensionMap at: ext put: type
!

contentType: type hasMagicData: data
    "Associate the given MIME content type to the magic data in `data'. Data
     is an ArrayedCollection (usually an Array, ByteArray, or String) whose
     contents are matched against the data passed to #guessContentTypeFor:. A
     character or integer is matched against a single byte, while if a Symbol
     is found, the corresponding byte in the data stream is not compared against
     anything.  Of course a Symbol can only occur if data is an Array."
    ^FileTypeMap add: (Array with: data with: type)
!

initialize
    "Initialize the default file extension and magic data maps"
    FileExtensionMap := Dictionary new.
    FileTypeMap := self defaultFileTypeMap asOrderedCollection.
    self defaultFileExtensionMap do: [ :each |
	FileExtensionMap at: (each at: 1) put: (each at: 2)
    ].

    ContentHandler registerContentTypes: #(
	'application/octet-stream'
	'application/x-unknown'
	'text/english'
	'text/plain')
!

validTypes
    "Answer some MIME types that instances the receiver can interpret"
    ^validTypes isNil
	ifTrue: [ #() ]
	ifFalse: [ validTypes ]
!

registerContentType: contentType
    "Register the receiver to be used to parse entities of the given MIME type.
     contentTypes must be a String."
    validTypes isNil ifTrue: [ validTypes := OrderedCollection new ].
    validTypes add: contentType
!

registerContentTypes: contentTypes
    "Register the receiver to be used to parse entities of the given MIME
     types.  contentTypes must be a collection of Strings."
    validTypes isNil ifTrue: [ validTypes := OrderedCollection new ].
    validTypes addAll: contentTypes
! !

!ContentHandler class methodsFor: 'instance creation'!

on: stream
    "Answer an instance of the receiver to be used to interpret data in the
     given stream"
    ^self new initialize: stream
! !

!ContentHandler methodsFor: 'retrieving contents'!

contents
    "By default, answer the whole contents of the stream without interpreting
     anything; subclasses however might want to return a more interesting
     object, failing if the data is somehow incorrect."
    ^stream contents
! !

!ContentHandler methodsFor: 'private'!

initialize: aStream
    stream := aStream
! !

ContentHandler initialize!
