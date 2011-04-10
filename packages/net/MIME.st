"======================================================================
|
|   MIME support
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000 Cincom, Inc.
| Copyright (c) 2009 Free Software Foundation
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



Namespace current: NetClients.MIME [

Object subclass: MessageElement [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MessageElement class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    MessageElement class >> fromLine: aString [
	"For compatibility with Swazoo"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    MessageElement class >> readFrom: aStream [
	"Each message element has responsibility to read itself from input stream. Reading usually involves parsing, so implementations of this method create an instance of lexical scanner and invoke a parser (see explanation for parse: method)"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    MessageElement class >> readFromClient: aStream [
	"This just parses a RFC821 message (with dots before each line)"

	<category: 'parsing'>
	^self readFrom: (RemoveDotStream on: aStream)
    ]

    MessageElement class >> scannerOn: aStream [
	<category: 'parsing'>
	^((aStream respondsTo: #isRFC822Scanner) 
	    and: [aStream respondsTo: #isRFC822Scanner]) 
		ifTrue: [aStream]
		ifFalse: [self scannerType on: aStream]
    ]

    MessageElement class >> scannerType [
	<category: 'parsing'>
	self subclassResponsibility
    ]

    canonicalValue [
	"Canonical value of an item represents its external representation as required by relevant protocols. Usually an element has to be converted to a cannonical representation before it can be sent over the network. This is a requirement of RFC822 and MIME. Canonical representation removes all whitespace between adjacent tokens"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    value [
	"Answers current value of the item. For structured elements (i.e. structured header fields) this value may be different for the source value read from source stream. For unstructured elements source and value are the same"

	<category: 'accessing'>
	^self source
    ]

    value: aValue [
	<category: 'accessing'>
	self source: aValue
    ]

    parse: scanner [
	"Each message element has responsibility to parse itself. The argument is an appropriate scanner. Scanners for RFC822, Mime and HTTP messages are stream wrappers, so they can be used to read and tokenize input stream"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    readFrom: aStream [
	"Each message element has responsibility to read itself from input stream. Reading usually involves parsing, so implementations of this method typically create an instance of lexical scanner and invoke a parser (see explanation for parse: method)"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    readFromClient: aStream [
	"This just parses a RFC821 message (with dots before each line)"

	<category: 'parsing'>
	^self readFrom: (RemoveDotStream on: aStream)
    ]

    scannerOn: aStream [
	"Each element should know what the underlying syntax is. For example, structured fields would mostly use MIME syntax and tokenize input streams into MIME 'tokens' while <address-spec> which is part of many standards, has to be tokenized using RFC822 syntax (using RFC822 'atoms')"

	<category: 'parsing'>
	^self class scannerOn: aStream
    ]

    printOn: aStream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    storeOn: aStream [
	<category: 'printing'>
	self printOn: aStream
    ]

    initialize [
	<category: 'private-initialize'>
	
    ]

    valueFrom: aString [
	"Swazoo compatibility"

	<category: 'private-initialize'>
	^self readFrom: aString readStream
    ]
]

]



Namespace current: NetClients.MIME [

Object subclass: SimpleScanner [
    | source hereChar token tokenType saveComments currentComment classificationMask sourceTrailStream lookahead |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    SimpleScanner class [
	| classificationTable |
	
    ]

    Lf := nil.
    AlphabeticMask := nil.
    EndOfLineMask := nil.
    CRLF := nil.
    NilMask := nil.
    CRLFMask := nil.
    WhiteSpaceMask := nil.
    Cr := nil.
    DigitMask := nil.

    SimpleScanner class >> classificationTable [
	<category: 'accessing'>
	^classificationTable isNil 
	    ifTrue: [self superclass classificationTable]
	    ifFalse: [classificationTable]
    ]

    SimpleScanner class >> classificationTable: aValue [
	<category: 'accessing'>
	classificationTable := aValue
    ]

    SimpleScanner class >> cr [
	<category: 'accessing'>
	^Cr
    ]

    SimpleScanner class >> crlf [
	<category: 'accessing'>
	^CRLF
    ]

    SimpleScanner class >> lf [
	<category: 'accessing'>
	^Lf
    ]

    SimpleScanner class >> whiteSpace [
	<category: 'character classification'>
	^String with: Character space with: Character tab
    ]

    SimpleScanner class >> initClassificationTable [
	<category: 'class initialization'>
	classificationTable := WordArray new: 256.
	self initClassificationTableWith: AlphabeticMask
	    when: [:c | ($a <= c and: [c <= $z]) or: [$A <= c and: [c <= $Z]]].
	self initClassificationTableWith: DigitMask
	    when: [:c | c >= $0 and: [c <= $9]].
	self initClassificationTableWith: WhiteSpaceMask
	    when: 
		[:c | 
		"space"

		"tab"

		#(32 9) includes: c asInteger].
	self initClassificationTableWith: CRLFMask
	    when: [:c | c == Character cr or: [c == Character nl]].
	"self initClassificationTableWith: EndOfLineMask
	    when: [:c | c == Character cr]"
    ]

    SimpleScanner class >> initClassificationTableWith: mask when: aBlock [
	"Set the mask in all entries of the classificationTable for which
	 aBlock answers true."

	<category: 'class initialization'>
	0 to: classificationTable size - 1
	    do: 
		[:i | 
		(aBlock value: (Character value: i)) 
		    ifTrue: 
			[classificationTable at: i + 1
			    put: ((classificationTable at: i + 1) bitOr: mask)]]
    ]

    SimpleScanner class >> initialize [
	"SimpleScanner initialize"

	<category: 'class initialization'>
	self
	    initializeConstants;
	    initClassificationTable
    ]

    SimpleScanner class >> initializeConstants [
	<category: 'class initialization'>
	AlphabeticMask := 1.
	DigitMask := 2.
	WhiteSpaceMask := 4.
	CRLFMask := 8.
	EndOfLineMask := 16.
	NilMask := 0.
	Cr := Character cr.
	Lf := Character nl.
	CRLF := Array with: Character cr with: Character nl
    ]

    SimpleScanner class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    SimpleScanner class >> on: stream [
	<category: 'instance creation'>
	^self new on: stream
    ]

    SimpleScanner class >> defaultTokenType [
	<category: 'printing'>
	self subclassResponsibility
    ]

    SimpleScanner class >> printToken: assocOrValue on: stream [
	<category: 'printing'>
	| tokenType token |
	(assocOrValue isKindOf: Association) 
	    ifTrue: 
		[tokenType := assocOrValue key.
		token := assocOrValue value]
	    ifFalse: 
		[tokenType := self defaultTokenType.
		token := assocOrValue].
	self 
	    printToken: token
	    tokenType: tokenType
	    on: stream
    ]

    SimpleScanner class >> printToken: value tokenType: aSymbol on: stream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    classificationMask [
	<category: 'accessing'>
	^classificationMask
    ]

    currentComment [
	<category: 'accessing'>
	^currentComment
    ]

    hereChar [
	<category: 'accessing'>
	^hereChar
    ]

    hereChar: char [
	<category: 'accessing'>
	hereChar := char.
	classificationMask := self classificationMaskFor: hereChar.
	lookahead := nil.
	^hereChar
    ]

    saveComments [
	<category: 'accessing'>
	^saveComments
    ]

    saveComments: aValue [
	<category: 'accessing'>
	saveComments := aValue
    ]

    token [
	<category: 'accessing'>
	^token
    ]

    tokenType [
	<category: 'accessing'>
	^tokenType
    ]

    expected: aString [
	"Notify that there is a problem at current token."

	<category: 'error handling'>
	^self notify: 'expected `%1''' % {aString}
    ]

    notify: string [
	"Subclasses may wish to override this"

	<category: 'error handling'>
	self error: string
    ]

    offEnd: aString [
	"Parser overrides this"

	<category: 'error handling'>
	^self notify: aString
    ]

    classificationMaskFor: charOrNil [
	<category: 'expression types'>
	^charOrNil isNil 
	    ifTrue: [NilMask]
	    ifFalse: [^self class classificationTable at: charOrNil asInteger + 1]
    ]

    matchCharacterType: mask [
	<category: 'expression types'>
	^self classificationMask anyMask: mask
    ]

    mustMatch: char [
	<category: 'expression types'>
	^self mustMatch: char notify: [self expected: (String with: char)]
    ]

    mustMatch: char notify: message [
	<category: 'expression types'>
	self skipWhiteSpace.
	self next == char ifFalse: [self notify: message]
    ]

    scanTokenMask: tokenMask [
	"Scan token based on character mask. Answers token's value. Stream is positioned before the character that terminated scan"

	<category: 'expression types'>
	^self scanWhile: [self matchCharacterType: tokenMask]
    ]

    scanUntil: aNiladicBlock [
	"Scan token using a block until match is found. At the end of scan the stream is positioned after the
	 matching character. Answers token value"

	<category: 'expression types'>
	| stream |
	stream := (String new: 40) writeStream.
	
	[self atEnd 
	    ifTrue: 
		[self hereChar: nil.
		^stream contents].
	self step.
	aNiladicBlock value] 
		whileFalse: [stream nextPut: hereChar].
	^stream contents
    ]

    scanWhile: aNiladicBlock [
	"Scan token using a block. At the end of scan the stream is positioned at the first character that does not match. hereChar is nil. Answers token value"

	<category: 'expression types'>
	| str |
	str := self scanUntil: [aNiladicBlock value not].
	hereChar notNil ifTrue: [self stepBack].
	^str
    ]

    step [
	<category: 'expression types'>
	^self next
    ]

    stepBack [
	<category: 'expression types'>
	lookahead isNil ifFalse: [self error: 'cannot step back twice'].
	self sourceTrailSkip: -1.
	lookahead := hereChar.
	hereChar := nil
    ]

    initialize [
	<category: 'initialize-release'>
	saveComments := true.
	self hereChar: nil
    ]

    on: inputStream [
	"Bind the input stream"

	<category: 'initialize-release'>
	self hereChar: nil.
	source := inputStream
    ]

    scan: inputStream [
	"Bind the input stream, fill the character buffers and first token buffer"

	<category: 'initialize-release'>
	self on: inputStream.
	^self nextToken
    ]

    skipWhiteSpace [
	"It is inefficient because intermediate stream is created. Perhaps refactoring scanWhile: can help"

	<category: 'multi-character scans'>
	self scanWhile: [self matchCharacterType: WhiteSpaceMask]
    ]

    printToken: assoc on: stream [
	<category: 'printing'>
	self class printToken: assoc on: stream
    ]

    printToken: value tokenType: aSymbol on: stream [
	<category: 'printing'>
	self class 
	    printToken: value
	    tokenType: aSymbol
	    on: stream
    ]

    resetToken [
	<category: 'private'>
	token := tokenType := nil
    ]

    sourceTrail [
	<category: 'source trail'>
	| res |
	sourceTrailStream notNil ifTrue: [res := sourceTrailStream contents].
	sourceTrailStream := nil.
	^res
    ]

    sourceTrailNextPut: char [
	<category: 'source trail'>
	(sourceTrailStream notNil and: [char notNil]) 
	    ifTrue: [sourceTrailStream nextPut: char]
    ]

    sourceTrailNextPutAll: string [
	<category: 'source trail'>
	(sourceTrailStream notNil and: [string notNil]) 
	    ifTrue: [sourceTrailStream nextPutAll: string]
    ]

    sourceTrailOff [
	<category: 'source trail'>
	sourceTrailStream := nil
    ]

    sourceTrailOn [
	<category: 'source trail'>
	sourceTrailStream := (String new: 64) writeStream
    ]

    sourceTrailSkip: integer [
	<category: 'source trail'>
	sourceTrailStream notNil ifTrue: [sourceTrailStream skip: integer]
    ]

    atEnd [
	<category: 'stream interface -- reading'>
	^lookahead isNil and: [source atEnd]
    ]

    contents [
	<category: 'stream interface -- reading'>
	| contents |
	contents := source contents lookahead notNil 
		    ifTrue: 
			[contents := (contents species with: lookahead) , contents.
			lookahead := nil].
	^contents
    ]

    next [
	<category: 'stream interface -- reading'>
	self hereChar: self peek.
	self sourceTrailNextPut: hereChar.
	lookahead := nil.
	^hereChar
    ]

    next: anInteger [
	"Answer the next anInteger elements of the receiver."

	<category: 'stream interface -- reading'>
	| newCollection res |
	newCollection := self species new: anInteger.
	res := self 
		    next: anInteger
		    into: newCollection
		    startingAt: 1.
	self sourceTrailNextPutAll: res.
	^res
    ]

    next: anInteger into: aSequenceableCollection startingAt: startIndex [
	"Store the next anInteger elements of the receiver into aSequenceableCollection
	 starting at startIndex in aSequenceableCollection. Answer aSequenceableCollection."

	<category: 'stream interface -- reading'>
	| index stopIndex |
	index := startIndex.
	stopIndex := index + anInteger.
	(lookahead notNil and: [anInteger > 0]) 
	    ifTrue: 
		[aSequenceableCollection at: index put: lookahead.
		index := index + 1.
		lookahead := nil].
	anInteger > 0 ifTrue: [self hereChar: nil].
	[index < stopIndex] whileTrue: 
		[aSequenceableCollection at: index put: source next.
		index := index + 1].
	^aSequenceableCollection
    ]

    nextLine [
	<category: 'stream interface -- reading'>
	| line |
	line := self scanUntil: [self matchCharacterType: CRLFMask].
	self scanWhile: [self matchCharacterType: CRLFMask].
	^line
    ]

    peek [
	"Answer what would be returned with a self next, without
	 changing position.  If the receiver is at the end, answer nil."

	<category: 'stream interface -- reading'>
	lookahead notNil ifTrue: [^lookahead].
	self atEnd ifTrue: [^nil].
	hereChar := nil.
	lookahead := source next.
	^lookahead
    ]

    peekFor: anObject [
	"Answer false and do not move the position if self next ~= anObject or if the
	 receiver is at the end. Answer true and increment position if self next = anObject."

	"This sets lookahead"

	<category: 'stream interface -- reading'>
	self peek isNil ifTrue: [^false].

	"peek for matching element"
	anObject = lookahead 
	    ifTrue: 
		[self next.
		^true].
	^false
    ]

    position [
	<category: 'stream interface -- reading'>
	^source position - (lookahead isNil ifTrue: [0] ifFalse: [1])
    ]

    position: anInt [
	<category: 'stream interface -- reading'>
	lookahead := nil.
	^source position: anInt
    ]

    skip: integer [
	<category: 'stream interface -- reading'>
	self sourceTrailSkip: integer.
	lookahead isNil 
	    ifFalse: 
		[lookahead := nil.
		source skip: integer - 1]
	    ifTrue: [source skip: integer]
    ]

    species [
	<category: 'stream interface -- reading'>
	^source species
    ]

    upTo: anObject [
	"Answer a subcollection from position to the occurrence (if any, exclusive) of anObject.
	 The stream is left positioned after anObject.
	 If anObject is not found answer everything."

	<category: 'stream interface -- reading'>
	| str |
	lookahead = anObject 
	    ifTrue: 
		[self sourceTrailNextPut: lookahead.
		lookahead := nil.
		^''].
	str := source upTo: anObject.
	lookahead isNil 
	    ifFalse: 
		[str := lookahead asString , str.
		lookahead := nil].
	self
	    sourceTrailNextPutAll: str;
	    sourceTrailNextPut: anObject.
	^str
    ]

    upToAll: pattern [
	<category: 'stream interface -- reading'>
	| str |
	lookahead isNil 
	    ifFalse: 
		[source skip: -1.
		lookahead := nil].
	str := source upToAll: pattern.
	self
	    sourceTrailNextPutAll: str;
	    sourceTrailNextPutAll: pattern.
	^str
    ]

    upToEnd [
	<category: 'stream interface -- reading'>
	| str |
	str := source upToEnd.
	lookahead isNil 
	    ifFalse: 
		[str := lookahead asString , str.
		lookahead := nil].
	self sourceTrailNextPutAll: str.
	^str
    ]

    testScanTokens [
	<category: 'sunit test helpers'>
	| s st |
	s := WriteStream on: (Array new: 16).
	st := WriteStream on: (Array new: 16).
	[tokenType = #doIt] whileFalse: 
		[s nextPut: token.
		st nextPut: tokenType.
		self nextToken].
	^Array with: s contents with: st contents
    ]

    testScanTokens: textOrString [
	"Answer with an Array which has been tokenized"

	<category: 'sunit test helpers'>
	self scan: (ReadStream on: textOrString asString).
	^self testScanTokens
    ]

    nextToken [
	<category: 'tokenization'>
	self subclassResponsibility
    ]

    nextTokenAsAssociation [
	"Read next token and and answer tokenType->token"

	<category: 'tokenization'>
	self nextToken.
	^tokenType -> token
    ]

    scanToken: aNiladicBlock delimitedBy: anArray notify: errorMessageString [
	"Scan next lexical token based on the criteria defined by NiladicBlock. The block is evaluated for every character read from input stream until it yields false. Stream is positioned before character that terminated scan"

	"Example: self scanToken: [ self scanQuotedChar; matchCharacterType: DomainTextMask ]
	 delimitedBy: '[]' notify: 'Malformed domain text'."

	<category: 'tokenization'>
	| string |
	self mustMatch: anArray first.
	string := self scanWhile: aNiladicBlock.
	self mustMatch: anArray last notify: errorMessageString.
	^string
    ]

    scanTokens: textOrString [
	"Answer with an Array which has been tokenized"

	<category: 'tokenization'>
	^self
	    on: (ReadStream on: textOrString asString);
	    tokenize
    ]

    tokenize [
	<category: 'tokenization'>
	| s |
	s := WriteStream on: (Array new: 16).
	
	[self nextToken.
	tokenType = #doIt] whileFalse: [s nextPut: token].
	^s contents
    ]

    tokenizeList: aBlock separatedBy: comparisonBlock [
	"list = token *( separator token)"

	<category: 'tokenization'>
	| stream block |
	stream := (Array new: 4) writeStream.
	block := [stream nextPut: aBlock value].
	block value.	"Evaluate for the first element"
	self tokenizeWhile: [comparisonBlock value] do: block.
	^stream contents
    ]

    tokenizeUntil: aBlock do: actionBlock [
	<category: 'tokenization'>
	
	[self skipWhiteSpace.
	self position.
	self nextToken.
	tokenType == #doIt or: aBlock] 
		whileFalse: [actionBlock value]
    ]

    tokenizeWhile: aBlock [
	<category: 'tokenization'>
	| s |
	s := WriteStream on: (Array new: 16).
	self tokenizeWhile: [aBlock value] do: [s nextPut: token].
	^s contents
    ]

    tokenizeWhile: aBlock do: actionBlock [
	<category: 'tokenization'>
	| pos |
	
	[self skipWhiteSpace.
	pos := self position.
	self nextToken.
	tokenType ~= #doIt & aBlock value	"#######"] 
		whileTrue: [actionBlock value].
	self position: pos	"Reset position to the beginning of the token that did not match"
    ]
]

]



Namespace current: NetClients.MIME [

MessageElement subclass: MimeEntity [
    | parent fields body |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MimeEntity class >> contentLengthFieldName [
	<category: 'constants'>
	^'content-length'
    ]

    MimeEntity class >> contentTypeFieldName [
	<category: 'constants'>
	^'content-type'
    ]

    MimeEntity class >> syntaxOfMultiPartMimeBodies [
	"From RFC 2046: Media Types                  November 1996
	 
	 The Content-Type field for multipart entities requires one parameter,
	 'boundary'. The boundary delimiter line is then defined as a line
	 consisting entirely of two hyphen characters ($-, decimal value 45)
	 followed by the boundary parameter value from the Content-Type header
	 field, optional linear whitespace, and a terminating CRLF.
	 
	 WARNING TO IMPLEMENTORS:  The grammar for parameters on the Content-
	 type field is such that it is often necessary to enclose the boundary
	 parameter values in quotes on the Content-type line.  This is not
	 always necessary, but never hurts. Implementors should be sure to
	 study the grammar carefully in order to avoid producing invalid
	 Content-type fields.  Thus, a typical 'multipart' Content-Type header
	 field might look like this:
	 
	 Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08j34c0p
	 
	 But the following is not valid:
	 
	 Content-Type: multipart/mixed; boundary=gc0pJq0M:08jU534c0p
	 
	 (because of the colon) and must instead be represented as
	 
	 Content-Type: multipart/mixed; boundary="

	"gc0pJq0M:08jU534c0p"

	"
	 
	 This Content-Type value indicates that the content consists of one or
	 more parts, each with a structure that is syntactically identical to
	 an RFC 822 message, except that the header area is allowed to be
	 completely empty, and that the parts are each preceded by the line
	 
	 --gc0pJq0M:08jU534c0p
	 
	 The boundary delimiter MUST occur at the beginning of a line, i.e.,
	 following a CRLF, and the initial CRLF is considered to be attached
	 to the boundary delimiter line rather than part of the preceding
	 part.  The boundary may be followed by zero or more characters of
	 linear whitespace. It is then terminated by either another CRLF and
	 the header fields for the next part, or by two CRLFs, in which case
	 there are no header fields for the next part.  If no Content-Type
	 field is present it is assumed to be 'message/rfc822' in a
	 'multipart/digest' and 'text/plain' otherwise.
	 
	 NOTE:  The CRLF preceding the boundary delimiter line is conceptually
	 attached to the boundary so that it is possible to have a part that
	 does not end with a CRLF (line  break).  Body parts that must be
	 considered to end with line breaks, therefore, must have two CRLFs
	 preceding the boundary delimiter line, the first of which is part of
	 the preceding body part, and the second of which is part of the
	 encapsulation boundary."

	<category: 'documentation'>
	
    ]

    MimeEntity class >> headerTypeFor: headerName [
	<category: 'parsing'>
	^HeaderField	"For now"
    ]

    MimeEntity class >> parser [
	<category: 'parsing'>
	^self scannerType new
    ]

    MimeEntity class >> parseFieldsFrom: stream [
	<category: 'parsing'>
	^self new parseFieldsFrom: (self parser on: stream)
    ]

    MimeEntity class >> readFrom: stream [
	<category: 'parsing'>
	^self new readFrom: (self parser on: stream)
    ]

    MimeEntity class >> readFrom: stream defaultType: type [
	<category: 'parsing'>
	^(self new)
	    fieldAt: 'content-type'
		put: (ContentTypeField fromLine: 'content-type: ' , type);
	    readFrom: (self parser on: stream);
	    yourself
    ]

    MimeEntity class >> readFrom: stream type: type [
	<category: 'parsing'>
	('message/*' match: type) ifTrue: [^self readFrom: stream].
	^(self new)
	    fieldAt: 'content-type'
		put: (ContentTypeField fromLine: 'content-type: ' , type);
	    parseBodyFrom: (self parser on: stream);
	    yourself
    ]

    MimeEntity class >> scannerType [
	<category: 'parsing'>
	^MimeScanner
    ]

    bcc [
	<category: 'accessing'>
	^self fieldAt: 'bcc'
    ]

    body [
	<category: 'accessing'>
	^body
    ]

    body: aValue [
	<category: 'accessing'>
	body := aValue
    ]

    boundary [
	<category: 'accessing'>
	^self contentTypeField boundary
    ]

    cc [
	<category: 'accessing'>
	^self fieldAt: 'cc'
    ]

    charset [
	<category: 'accessing'>
	^self contentTypeField charset
    ]

    contents [
	<category: 'accessing'>
	| handler |
	handler := ContentHandler classFor: self contentType.
	^(handler on: self body readStream) contents
    ]

    contentId [
	<category: 'accessing'>
	^(self fieldAt: 'content-id' ifAbsent: [^nil]) id
    ]

    contentType [
	<category: 'accessing'>
	^self contentTypeField contentType
    ]

    contentTypeField [
	<category: 'accessing'>
	^self fieldAt: 'content-type' ifAbsent: [self defaultContentTypeField]
    ]

    fields [
	<category: 'accessing'>
	^fields
    ]

    fields: aValue [
	<category: 'accessing'>
	fields := aValue
    ]

    from [
	<category: 'accessing'>
	^self fieldAt: 'from'
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aMimeEntity [
	<category: 'accessing'>
	parent := aMimeEntity
    ]

    recipients [
	<category: 'accessing'>
	| recipients |
	recipients := #().
	self to isNil ifFalse: [recipients := recipients , self to addresses].
	self cc isNil ifFalse: [recipients := recipients , self cc addresses].
	self bcc isNil ifFalse: [recipients := recipients , self bcc addresses].
	^recipients
    ]

    replyTo [
	<category: 'accessing'>
	^self fieldAt: 'reply-to'
    ]

    sender [
	<category: 'accessing'>
	^self fieldAt: 'sender' ifAbsent: [self fieldAt: 'from']
    ]

    subject [
	<category: 'accessing'>
	^self fieldAt: 'subject'
    ]

    subtype [
	<category: 'accessing'>
	^self contentTypeField subtype
    ]

    to [
	<category: 'accessing'>
	^self fieldAt: 'to'
    ]

    type [
	<category: 'accessing'>
	^self contentTypeField type
    ]

    addField: field [
	"This method will check if the field exists already; if yes, if it can be merged into the existing field and, if yes, merge it. Otherwise, add as a new field"

	"Implement field merge"

	<category: 'accessing fields and body parts'>
	^self fieldAt: field name put: field
    ]

    bodyPartAt: index [
	<category: 'accessing fields and body parts'>
	^self body at: index
    ]

    bodyPartNamed: id [
	<category: 'accessing fields and body parts'>
	^self isMultipart 
	    ifTrue: [self body detect: [:part | part contentId = id]]
	    ifFalse: [nil]
    ]

    fieldAt: aString [
	<category: 'accessing fields and body parts'>
	^self fieldAt: aString asLowercase ifAbsent: [nil]
    ]

    fieldAt: aString ifAbsent: aNiladicBlock [
	<category: 'accessing fields and body parts'>
	^self fields at: aString asLowercase ifAbsent: aNiladicBlock
    ]

    fieldAt: aString ifAbsentPut: aNiladicBlock [
	<category: 'accessing fields and body parts'>
	^self fields at: aString asLowercase ifAbsentPut: aNiladicBlock
    ]

    fieldAt: aString put: aHeaderField [
	<category: 'accessing fields and body parts'>
	^self fields at: aString asLowercase put: aHeaderField
    ]

    asByteArray [
	<category: 'converting'>
	
    ]

    asStream [
	<category: 'converting'>
	
    ]

    asString [
	<category: 'converting'>
	
    ]

    asStringOrByteArray [
	<category: 'converting'>
	
    ]

    defaultContentType [
	<category: 'defaults'>
	^self defaultContentTypeField contentType
    ]

    defaultContentTypeField [
	<category: 'defaults'>
	^ContentTypeField default
    ]

    initialize [
	<category: 'initialization'>
	fields := Dictionary new: 4
    ]

    defaultContentTypeForNestedEntities [
	<category: 'parsing'>
	^(self type = 'multipart' and: [self subtype = 'digest']) 
	    ifTrue: ['content-type: message/rfc822']
	    ifFalse: ['text/plain; charset=US-ASCII']
    ]

    fieldFactory [
	"Answers object that can map field name to field type (class). It may and will be subclassed"

	<category: 'parsing'>
	^HeaderField
    ]

    parseBodyFrom: rfc822Stream [
	<category: 'parsing'>
	self isMultipart 
	    ifTrue: [self parseMultipartBodyFrom: rfc822Stream]
	    ifFalse: [self parseSimpleBodyFrom: rfc822Stream]
    ]

    parseFieldFrom: stream [
	<category: 'parsing'>
	| field |
	field := self fieldFactory readFrom: stream.
	self addField: field
    ]

    parseFieldsFrom: rfc822Stream [
	<category: 'parsing'>
	[rfc822Stream atEndOfLine] 
		whileFalse: [self parseFieldFrom: rfc822Stream].
        rfc822Stream next; skipEndOfLine
    ]

    parseMultipartBodyFrom: rfc822Stream [
	"Parse multi-part body. See more in 'documentation' category on the class side"

	<category: 'parsing'>
	| boundary parts partArray |
	(boundary := self boundary) notNil 
	    ifTrue: 
		[parts := (Array new: 2) writeStream.	"Skip to the first boundary, ignore text in between"
		partArray := rfc822Stream scanToBoundary: boundary].
	
	[partArray isNil 
	    ifTrue: [^self error: 'Missing boundary in multi-part body'].
	partArray := rfc822Stream scanToBoundary: boundary.
	partArray notNil ifTrue: [parts nextPut: partArray first].
	partArray notNil and: [partArray last ~~ #last]] 
		whileTrue.
	self 
	    body: (parts contents collect: 
			[:part | 
			MimeEntity readFrom: part readStream
			    defaultType: self defaultContentTypeForNestedEntities])
    ]

    parseSimpleBodyFrom: rfc822Stream [
	<category: 'parsing'>
	| stream |
	stream := (String new: 256) writeStream.
	self parseSimpleBodyFrom: rfc822Stream onto: stream.
	self body: stream contents
    ]

    parseSimpleBodyFrom: rfc822Stream onto: stream [
	<category: 'parsing'>
	| inStream |
	inStream := RemoveDotStream on: rfc822Stream.
	[inStream atEnd] whileFalse: 
		[stream
		    nextPutAll: inStream nextLine;
		    nl]
    ]

    readFrom: rfc822Stream [
	<category: 'parsing'>
	self parseFieldsFrom: rfc822Stream.
	self parseBodyFrom: rfc822Stream
    ]

    skipSimpleBodyFrom: rfc822Stream onto: stream [
	<category: 'parsing'>
	| inStream |
	inStream := RemoveDotStream on: rfc822Stream.
	[inStream atEnd] whileFalse: [inStream nextLine]
    ]

    printBodyOn: aStream [
	<category: 'printing'>
	self body isNil ifTrue: [^self].
	self body class == Array 
	    ifFalse: 
		[aStream nextPutAll: self body.
		^self].
	aStream nextPutAll: 'This is a MIME message.

'.
	self body do: 
		[:each | 
		aStream
		    nextPutAll: '--';
		    nextPutAll: self boundary.
		each printOn: aStream].
	aStream
	    nextPutAll: '--';
	    nextPutAll: self boundary;
	    nextPutAll: '--'
    ]

    printBodyOnClient: aClient [
	<category: 'printing'>
	| out |
	out := PrependDotStream to: aClient.
	self printBodyOn: out.
	out flush
    ]

    printHeaderOn: aStream [
	<category: 'printing'>
	self fields do: 
		[:each | 
		aStream
		    print: each;
		    nl]
    ]

    printHeaderOnClient: aClient [
	<category: 'printing'>
	| out |
	out := PrependDotStream to: aClient.
	self printHeaderOn: out.
	out flush
    ]

    printMessageOn: aStream [
	<category: 'printing'>
	self printHeaderOn: aStream.
	aStream nl.
	self printBodyOn: aStream
    ]

    printMessageOnClient: aClient [
	<category: 'printing'>
	| out |
	out := PrependDotStream to: aClient.
	self printMessageOn: out.
	out flush
    ]

    printOn: aStream [
	<category: 'printing'>
	self printMessageOn: aStream
    ]

    hasBoundary [
	<category: 'testing'>
	^(self fieldAt: 'boundary') notNil
    ]

    isMultipart [
	<category: 'testing'>
	^self contentTypeField isMultipart
    ]
]

]



Namespace current: NetClients.MIME [

MessageElement subclass: NetworkEntityDescriptor [
    | alias comment |
    
    <category: 'NetClients-MIME'>
    <comment: 'I am an abstract superclass for RFC822 mailbox and group descriptors. Each of these can have an associated alias (name) and comment 

Instance Variables:
    alias    <?type?>  comment
    comment    <?type?>  comment
'>

    NetworkEntityDescriptor class >> scannerType [
	<category: 'parsing'>
	^NetworkAddressParser
    ]

    alias [
	<category: 'accessing'>
	^alias
    ]

    alias: aValue [
	<category: 'accessing'>
	alias := aValue
    ]

    comment [
	<category: 'accessing'>
	^comment
    ]

    comment: aValue [
	<category: 'accessing'>
	comment := aValue
    ]

    scannerType [
	<category: 'parsing'>
	^self class scannerType
    ]

    printAliasOn: stream [
	<category: 'priniting'>
	alias notNil ifTrue: [stream nextPutAll: alias]
    ]

    printCanonicalValueOn: stream [
	<category: 'priniting'>
	self subclassResponsibility
    ]

    printCommentOn: stream [
	<category: 'priniting'>
	comment notNil 
	    ifTrue: 
		[stream nextPut: $(.
		comment do: 
			[:char | 
			(RFC822Scanner isCommentChar: char) ifFalse: [stream nextPut: $\].
			stream nextPut: char].
		stream nextPut: $)]
    ]

    printOn: stream [
	<category: 'priniting'>
	self printCanonicalValueOn: stream.
	comment notNil ifTrue: [self printCommentOn: stream]
    ]
]

]



Namespace current: NetClients.MIME [

MessageElement subclass: HeaderField [
    | name source |
    
    <category: 'NetClients-MIME'>
    <comment: 'This is base class for all header fields. Each header field has a name and a value. Each field also has the following responsibility:
    Represent its value; being able to answer and receive a value.
    Read its value from a (positionable) stream (parsing). Field''s value is terminated by new line (subject to line folding). There is no requirement now that field''s value terminates ate the end of the stream.
    Write its contents on a stream (composition)

When reading itself from a stream, the field will store its source. When this field is written on a stream and there is source already available, this source will be written instead of parsed field''s value. The reasoning is that all standards strongly discourage making any alterations to the fields if a message is being forwarded, resent, proxied, etc. Parsing and subsequent composition can change many aspects of a field such as, replace multiple spaces with a single space, removing nonessential white spece altogether, changing the order of the values, etc. So if a source is available, it is trusted more than the parsed value for writing on a stream. This necessitates resetting source to nil when any of the field''s aspects is modified. All setters should send change notification so that it is done transparently

This class can be used to parse/compose all nonstructured fields. For unstructured fields field''s value and source are the same, so #value answers source. Specific subclasses add more specific processing for field''s value, so they override methods #value, #value:.

Message parsing: Each field is responsible for knowing its underlying grammar. This included both lexical and grammar rules. Therefore, each subclass implements methods #scannerType and #parserOn: <stream>. These answer scanner class and new instance of parser for a given source stream. Method parse: parses and sets field''s value.

A conventional way of creating new instance of a stream from source field is 
    HeaderField readFrom: stream

This reads field''s name, find an appropriate field class for this name, creates an instance of this field and lets it read/parse field''s value.

Instance Variables:
    name    <String>  comment
    source    <String>  comment
'>

    HeaderField class >> name: aname [
	"Answer new instance of field corresponding to field's name. For now, treat all fields as unstructured"

	<category: 'instance creation'>
	^((self fieldClassForName: aname) new)
	    name: aname;
	    yourself
    ]

    HeaderField class >> defaultFieldClass [
	<category: 'parsing'>
	^HeaderField
    ]

    HeaderField class >> fieldClassForName: fieldName [
	"For now we scan all subclasses. Later I plan to use registry which is somewhat more flexible, especially if different protocols can have different formats for the same field"

	<category: 'parsing'>
	| fname |
	fname := fieldName asLowercase.
	^HeaderField allSubclasses detect: 
		[:each | 
		(each fieldNames detect: [:candidate | candidate asLowercase = fname]
		    ifNone: [nil]) notNil]
	    ifNone: [self defaultFieldClass]
    ]

    HeaderField class >> fieldNames [
	<category: 'parsing'>
	^#()
    ]

    HeaderField class >> fromLine: aString [
	"For compatibility with Swazoo"

	<category: 'parsing'>
	| rfc822Stream |
	rfc822Stream := self scannerOn: aString readStream.
	^(self name: (self readFieldNameFrom: rfc822Stream))
	    readFrom: rfc822Stream;
	    yourself
    ]

    HeaderField class >> readFieldNameFrom: rfc822Stream [
	<category: 'parsing'>
	| fname |
	fname := rfc822Stream scanFieldName.
	rfc822Stream mustMatch: $: notify: 'Invalid Field (Missing colon)'.
	rfc822Stream skipWhiteSpace.
	^fname asLowercase
    ]

    HeaderField class >> readFrom: rfc822Stream [
	"Reads and parses message header contents from the message stream; answers an instance of message header. rfc822Stream is RFC822MessageParser; it extends stream interface by providing message scanning/parsing services. At this point the stream is positioned right after semicolon that delimits header name"

	<category: 'parsing'>
	^(self name: (self readFieldNameFrom: rfc822Stream)) 
	    readFrom: rfc822Stream
    ]

    HeaderField class >> scannerType [
	<category: 'parsing'>
	^MimeScanner
    ]

    canonicalFieldName [
	<category: 'accessing'>
	| s |
	s := name copy.
	s isEmpty ifTrue: [^s].
	s at: 1 put: s first asUppercase.	"Capitalize first letter"
	^s
    ]

    canonicalValue [
	"Override as necessary"

	<category: 'accessing'>
	^self value
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	^name := aString
    ]

    source [
	<category: 'accessing'>
	^source
    ]

    source: anObject [
	<category: 'accessing'>
	source := anObject
    ]

    value [
	<category: 'accessing'>
	^self source
    ]

    value: aValue [
	<category: 'accessing'>
	self source: aValue
    ]

    parse: rfc822Stream [
	"Generic parser for unstructured fields. Copy everything up to CRLF. Scanner handles end of line rules and answers cr when end of line is seen. Scanner also folds linear white space answering space character in place of <CRLF space+>"

	<category: 'parsing'>
	self value: rfc822Stream nextLine
    ]

    readFrom: aStream [
	<category: 'parsing'>
	self source: aStream scanText.
	^self parse: (self scannerOn: self source readStream)
    ]

    printOn: aStream [
	<category: 'printing'>
	self printOn: aStream indent: 0
    ]

    printOn: aStream indent: level [
	<category: 'printing'>
	aStream
	    tab: level;
	    nextPutAll: self canonicalFieldName;
	    nextPut: $:;
	    space.
	self printValueOn: aStream
    ]

    printStructureOn: aStream [
	"Unstructured fields just print their value on a stream"

	<category: 'printing'>
	self printValueOn: aStream
    ]

    printValueOn: aStream [
	<category: 'printing'>
	| val |
	(val := self value) notNil ifTrue: [val displayOn: aStream]
    ]

    valueFrom: aString [
	"Swazoo compatibility"

	<category: 'private-initialize'>
	^self readFrom: aString readStream
    ]
]

]



Namespace current: NetClients.MIME [

SimpleScanner subclass: MimeEncodedWordCoDec [
    
    <category: 'NetClients-MIME'>
    <comment: 'I am responsible for scanning tokens for the presence of MIME ''encoded words''. MIME uses encoded word to allow non-ascii characters to be used in message headers. Encoded words can occur inside MIME extension fields (ones starting with X-) as well as in field bodies. An encoded word may occur everywhere in the body in place of text'', ''word'', ''comment'' or ''phrase'' token. Encoded word specifies charset, encoding mechanism and encoded text itself'>

    MimeEncodedWordCoDec class >> decode: word [
	<category: 'parsing'>
	^self decode: word using: (self encodingParametersOf: word)
    ]

    MimeEncodedWordCoDec class >> decode: word using: arr [
	<category: 'parsing'>
	^arr notNil 
	    ifTrue: 
		[self 
		    decodeEncodedWord: (arr at: 3)
		    charset: arr first
		    encoding: (arr at: 2)]
	    ifFalse: [word]
    ]

    MimeEncodedWordCoDec class >> decodeComment: commentString [
	<category: 'parsing'>
	^self new decodeComment: commentString
    ]

    MimeEncodedWordCoDec class >> decodePhrase: words [
	"decode phrase word by word; concatenate decoded words and answer concatenated string"

	<category: 'parsing'>
	| output |
	output := (String new: words size) writeStream.
	self decodePhrase: words printOn: output.
	^output contents
    ]

    MimeEncodedWordCoDec class >> decodePhrase: words printOn: stream [
	<category: 'parsing'>
	| params lastParams lastWord |
	lastWord := nil.
	words do: 
		[:word | 
		lastParams := params.
		params := self encodingParametersOf: word.
		(lastWord notNil and: [params isNil or: [lastParams isNil]]) 
		    ifTrue: [stream space].
		stream nextPutAll: (lastWord := self decode: word using: params)]
    ]

    MimeEncodedWordCoDec class >> decodeText: text [
	<category: 'parsing'>
	^self new decodeText: text
    ]

    MimeEncodedWordCoDec class >> encodingParametersOf: word [
	<category: 'parsing'>
	| mark1 mark2 |
	^(word first == $= and: 
		[word last == $= and: 
			[(word at: 2) == $? and: 
				[(word at: word size - 1) == $? and: 
					[(mark1 := word 
						    nextIndexOf: $?
						    from: 3
						    to: word size - 2) > 0 
					    and: 
						[(mark2 := word 
							    nextIndexOf: $?
							    from: mark1 + 1
							    to: word size - 2) > (mark1 + 1)]]]]]) 
	    ifTrue: 
		[Array 
		    with: (word copyFrom: 3 to: mark1 - 1) asLowercase
		    with: (word copyFrom: mark1 + 1 to: mark2 - 1) asLowercase
		    with: (word copyFrom: mark2 + 1 to: word size - 2)]
	    ifFalse: [nil]
    ]

    MimeEncodedWordCoDec class >> decodeEncodedWord: contents charset: charset encoding: encodingString [
	<category: 'text processing'>
	| encoding |
	encoding := encodingString asLowercase.
	(#('b' 'base64') includes: encoding) 
	    ifTrue: 
		[^MimeScanner 
		    decodeBase64From: 1
		    to: contents size
		    in: contents].
	(#('q' 'quoted-printable') includes: encoding) 
	    ifTrue: 
		[^self 
		    decodeQuotedPrintableFrom: 1
		    to: contents size
		    in: contents].
	(#('uue' 'uuencode' 'x-uue' 'x-uuencode') includes: encoding) 
	    ifTrue: 
		[^self 
		    decodeUUEncodedFrom: 1
		    to: contents size
		    in: contents].
	^nil	"Failed to decode"
    ]

    MimeEncodedWordCoDec class >> decodeQuotedPrintableFrom: startIndex to: endIndex in: aString [
	"Decode aString from startIndex to endIndex in quoted-printable."

	<category: 'text processing'>
	| input output char n1 n2 |
	input := ReadStream 
		    on: aString
		    from: startIndex
		    to: endIndex.
	output := (String new: endIndex - startIndex) writeStream.
	[input atEnd] whileFalse: 
		[char := input next.
		$= == char 
		    ifTrue: 
			[('0123456789ABCDEF' includes: (n1 := input next)) 
			    ifTrue: 
				[n2 := input next.
				output nextPut: ((n1 digitValue bitShift: 4) + n2 digitValue) asCharacter]]
		    ifFalse: [output nextPut: char]].
	^output contents
    ]

    MimeEncodedWordCoDec class >> decodeUUEncodedFrom: startIndex to: farEndIndex in: aString [
	"decode aString from startIndex to farEndIndex as uuencode-encoded"

	<category: 'text processing'>
	| endIndex i nl space output data |
	endIndex := farEndIndex - 2.
	
	[endIndex <= startIndex or: 
		[(aString at: endIndex + 1) = $e 
		    and: [(aString at: endIndex + 2) = $n and: [(aString at: endIndex + 3) = $d]]]] 
		whileFalse: [endIndex := endIndex - 1].
	i := (aString 
		    findString: 'begin'
		    startingAt: startIndex
		    ignoreCase: true
		    useWildcards: false) first.
	i = 0 ifTrue: [i := startIndex].
	nl := Character nl.
	space := Character space asInteger.
	output := (data := String new: (endIndex - startIndex) * 3 // 4) 
		    writeStream.
	
	[[i < endIndex and: [(aString at: i) ~= nl]] whileTrue: [i := i + 1].
	i < endIndex] 
		whileTrue: 
		    [| count |
		    count := (aString at: (i := i + 1)) asInteger - space bitAnd: 63.
		    i := i + 1.
		    count = 0 
			ifTrue: [i := endIndex]
			ifFalse: 
			    [[count > 0] whileTrue: 
				    [| m n o p |
				    m := (aString at: i) asInteger - space bitAnd: 63.
				    n := (aString at: i + 1) asInteger - space bitAnd: 63.
				    o := (aString at: i + 2) asInteger - space bitAnd: 63.
				    p := (aString at: i + 3) asInteger - space bitAnd: 63.
				    count >= 1 
					ifTrue: 
					    [output nextPut: (Character value: (m bitShift: 2) + (n bitShift: -4)).
					    count >= 2 
						ifTrue: 
						    [output 
							nextPut: (Character value: ((n bitShift: 4) + (o bitShift: -2) bitAnd: 255)).
						    count >= 3 
							ifTrue: [output nextPut: (Character value: ((o bitShift: 6) + p bitAnd: 255))]]].
				    i := i + 4.
				    count := count - 3]]].
	^data copyFrom: 1 to: output position
    ]

    decode: word [
	<category: 'parsing'>
	^self class decode: word
    ]

    decodeComment: text [
	<category: 'parsing'>
	"First, quick check if we possibly have an encoded word"

	| output word params spaces lastParams lastWord |
	(text indexOfSubCollection: '=?' startingAt: 1) = 0 ifTrue: [^text].	"We suspect there might be an encoded word inside, do the legwork"
	self on: text readStream.
	output := (String new: text size) writeStream.
	spaces := String new.
	params := lastWord := nil.
	
	[lastParams := params.
	self atEnd] whileFalse: 
		    [word := self scanWhile: [(self matchCharacterType: WhiteSpaceMask) not].
		    params := self class encodingParametersOf: word.
		    (lastWord notNil and: [params isNil or: [lastParams isNil]]) 
			ifTrue: [output nextPutAll: spaces].
		    output nextPutAll: (lastWord := self class decode: word using: params).
		    spaces := self scanWhile: [self matchCharacterType: WhiteSpaceMask]].
	^output contents
    ]

    decodePhrase: words [
	<category: 'parsing'>
	^self class decodePhrase: words
    ]

    decodeText: text [
	"Decoding of text is similar to decoding of comment, but RFC2047 requires that an encoded word that appears in in *text token MUST be separated from any adjacent encoded word or text by a linear-white-space"

	<category: 'parsing'>
	"First, quick check if we possibly have an encoded word"

	| output word |
	(text indexOfSubCollection: '=?' startingAt: 1) = 0 ifTrue: [^text].	"We suspect there might be an encoded word inside, do the legwork"
	self on: text readStream.
	output := (String new: text size) writeStream.
	[self atEnd] whileFalse: 
		[word := self scanWhile: [(self matchCharacterType: WhiteSpaceMask) not].
		output
		    nextPutAll: (self decode: word);
		    nextPutAll: (self scanWhile: [self matchCharacterType: WhiteSpaceMask])].
	^output contents
    ]

    encodingParametersOf: word [
	<category: 'parsing'>
	^self class encodingParametersOf: word
    ]
]

]



Namespace current: NetClients.MIME [

SimpleScanner subclass: MailScanner [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MailScanner class >> printQuotedText: str on: stream [
	"Print word as either atom or quoted text"

	<category: 'printing'>
	(self shouldBeQuoted: str) 
	    ifTrue: 
		[stream
		    nextPut: $";
		    nextPutAll: str;
		    nextPut: $"]
	    ifFalse: [stream nextPutAll: str]
    ]

    MailScanner class >> printTokenList: list on: stream [
	<category: 'printing'>
	self 
	    printTokenList: list
	    on: stream
	    separatedBy: [stream space]
    ]

    MailScanner class >> printTokenList: list on: stream separatedBy: aBlock [
	<category: 'printing'>
	list do: [:assoc | self printToken: assoc on: stream] separatedBy: aBlock
    ]

    printAtom: atom on: stream [
	<category: 'printing'>
	self class printAtom: atom on: stream
    ]

    printQuotedText: qtext on: stream [
	<category: 'printing'>
	self class printQuotedText: qtext on: stream
    ]

    printText: qtext on: stream [
	<category: 'printing'>
	self class printText: qtext on: stream
    ]
]

]



Namespace current: NetClients.MIME [

NetworkEntityDescriptor subclass: NetworkAddressDescriptor [
    | domain localPart route |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    NetworkAddressDescriptor class >> readFrom: aString [
	<category: 'instance creation'>
	^self parser parse: aString
    ]

    NetworkAddressDescriptor class >> scannerType [
	<category: 'parsing'>
	^NetworkAddressParser
    ]

    NetworkAddressDescriptor class >> addressesFrom: stream [
	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp' readStream."

	"self addressesFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>' readStream."

	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' kyasu1, kyasu2, Kazuki Yasumatsu <kyasu3>, kyasu4 (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' foo bar, kyasu1, ,  Kazuki Yasumatsu <kyasu2> <kyasu3> (<foo> (foo bar), bar)' readStream."

	<category: 'utility'>
	^self scannerType addressesFrom: stream
    ]

    NetworkAddressDescriptor class >> addressFrom: aString [
	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp'."

	"self addressesFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>'."

	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)'."

	"self addressesFrom: ' kyasu1, kyasu2, Kazuki Yasumatsu <kyasu3>, kyasu4 (Kazuki Yasumatsu)'."

	"self addressesFrom: ' foo bar, kyasu1, ,  Kazuki Yasumatsu <kyasu2> <kyasu3> (<foo> (foo bar), bar)'."

	<category: 'utility'>
	^self scannerType addressFrom: aString
    ]

    addressSpecString [
	<category: 'accessing'>
	^self printStringSelector: #printAddressSpecOn:
    ]

    aliasString [
	<category: 'accessing'>
	^self printStringSelector: #printAliasOn:
    ]

    commentString [
	<category: 'accessing'>
	^self printStringSelector: #printCommentOn:
    ]

    domain [
	<category: 'accessing'>
	^domain
    ]

    domain: aValue [
	<category: 'accessing'>
	domain := aValue
    ]

    domainString [
	<category: 'accessing'>
	^self printStringSelector: #printDomainOn:
    ]

    localPart [
	<category: 'accessing'>
	^localPart
    ]

    localPart: aValue [
	<category: 'accessing'>
	localPart := aValue
    ]

    localPartString [
	<category: 'accessing'>
	^self printStringSelector: #printLocalPartOn:
    ]

    route [
	<category: 'accessing'>
	^route
    ]

    route: aValue [
	<category: 'accessing'>
	route := aValue
    ]

    routeString [
	<category: 'accessing'>
	^self printStringSelector: #printRouteOn:
    ]

    initialize [
	<category: 'initialization'>
	localPart := Array new
    ]

    printAddressSpecOn: stream [
	<category: 'printing'>
	self hasAddressSpec 
	    ifTrue: 
		[self printLocalPartOn: stream.
		stream nextPut: $@.
		self printDomainOn: stream]
    ]

    printCanonicalValueOn: stream [
	<category: 'printing'>
	alias notNil 
	    ifTrue: [self printRouteAddressOn: stream]
	    ifFalse: [self printAddressSpecOn: stream]
    ]

    printDomainOn: stream [
	<category: 'printing'>
	self scannerType printDomain: domain on: stream
    ]

    printLocalPartOn: stream [
	<category: 'printing'>
	localPart do: [:token | self scannerType printWord: token on: stream]
	    separatedBy: [stream nextPut: $.]
    ]

    printRouteAddressOn: stream [
	<category: 'printing'>
	self printAliasOn: stream.
	(route notNil or: [self hasAddressSpec]) 
	    ifTrue: 
		[stream nextPut: $<.
		self
		    printRouteOn: stream;
		    printAddressSpecOn: stream.
		stream nextPut: $>]
    ]

    printRouteOn: stream [
	<category: 'printing'>
	(route notNil and: [route notEmpty]) 
	    ifTrue: 
		[route do: 
			[:domainx | 
			stream
			    space;
			    nextPut: $@.
			self scannerType printDomain: domainx on: stream.
			stream nextPut: $:].
		stream space]
    ]

    printStringSelector: sel [
	<category: 'private'>
	| stream |
	stream := (String new: 40) writeStream.
	self perform: sel with: stream.
	^stream contents
    ]

    hasAddressSpec [
	<category: 'testing'>
	^localPart notNil 
	    and: [localPart isEmpty not and: [domain notNil and: [domain isEmpty not]]]
    ]
]

]



Namespace current: NetClients.MIME [

HeaderField subclass: StructuredHeaderField [
    | parameters |
    
    <category: 'NetClients-MIME'>
    <comment: 'I am used as a base for all structured fields as defined by RFC822, MIME and HTTP. Structured fields consist of words rather than text. Therefore, structured fields can be tokenized using lexical scanner.
I am designed to be compatible with Swazoo. Swazoo uses this class to store parameters, so I provide both storage and compatible methods to parse parameters. Parameters are modifiers for the primary value for a field. Syntax of parameters is as follows:
    parameters = *( <;> <key> <=> <value>)

In the future we may reconsiders if providing parameter storage here is a good idea because it seems that only a few field types can have parameters

Instance Variables:
    parameters    <Dictionary>  Contains parsed parameter values as associations
'>

    canonicalValue [
	"Canonical value removes all white space and comments from the source"

	<category: 'accessing'>
	^self tokenizedValueFrom: (self scannerOn: self source readStream)
    ]

    parameterAt: aString [
	<category: 'accessing'>
	^self parameterAt: aString ifAbsent: [nil]
    ]

    parameterAt: aString ifAbsent: aBlock [
	<category: 'accessing'>
	^parameters at: aString ifAbsent: aBlock
    ]

    parameterAt: aString ifAbsentPut: aBlock [
	<category: 'accessing'>
	^self parameters at: aString ifAbsentPut: aBlock
    ]

    parameterAt: aString put: aBlock [
	<category: 'accessing'>
	^self parameters at: aString put: aBlock
    ]

    parameters [
	<category: 'accessing'>
	^parameters
    ]

    parameters: aCollection [
	<category: 'accessing'>
	parameters := aCollection
    ]

    parametersDo: aMonadicBlock [
	"aBlock is a one-argument block which will be evaluated for each parameter. Argument is an
	 association (parameter name, parameter value)"

	<category: 'accessing'>
	^self parameters 
	    keysAndValuesDo: [:nm :val | aMonadicBlock value: nm -> val]
    ]

    printParameter: assoc on: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $;;
	    nextPutAll: assoc key;
	    nextPut: $=;
	    nextPutAll: assoc value
    ]

    printParametersOn: aStream [
	<category: 'printing'>
	self parametersDo: [:assoc | self printParameter: assoc on: aStream]
    ]

    printStructureOn: aStream [
	"Default implementation is the same as inherited. Subclasses can override it"

	<category: 'printing'>
	super printValueOn: aStream
    ]

    printValueOn: aStream [
	"The reasoning here is that if an instance was created by parsing input stream, it should be reconstructed verbatim rather than restored by us. We may alter the original in some ways and sometimes it may be undesirable"

	<category: 'printing'>
	self value notNil 
	    ifTrue: [super printValueOn: aStream]
	    ifFalse: [self printStructureOn: aStream]
    ]

    initialize [
	<category: 'private-initialize'>
	super initialize.
	parameters := Dictionary new
    ]

    readParametersFrom: rs [
	<category: 'private-utility'>
	| paramName paramValue |
	
	[rs
	    skipWhiteSpace;
	    atEnd] whileFalse: 
		    [rs mustMatch: $; notify: 'Invalid parameter'.
		    paramName := rs nextToken.
		    rs mustMatch: $= notify: 'Invalid parameter'.
		    paramValue := rs nextToken.
		    parameters at: paramName put: paramValue]
    ]

    tokenize: rfc822Stream [
	"Scan field value token by token. Answer an array of tokens"

	<category: 'private-utility'>
	| result token |
	result := (Array new: 2) writeStream.
	
	[rfc822Stream atEnd or: 
		[rfc822Stream peek == Character nl 
		    or: [(token := rfc822Stream nextToken) isNil]]] 
		whileFalse: [result nextPut: token].
	^result contents
    ]

    tokenizedValueFrom: rfc822Stream [
	"Scan field value token by token. Answer a string that is a concatenation of all elements in the array. One can view this as a canonicalized field value because this operation eliminates all white space and comments"

	<category: 'private-utility'>
	| result tokens |
	result := (String new: 20) writeStream.
	tokens := self tokenize: rfc822Stream.
	tokens do: 
		[:token | 
		token isString 
		    ifTrue: [result nextPutAll: token]
		    ifFalse: [result nextPut: token]].
	^result contents
    ]
]

]



Namespace current: NetClients.MIME [

NetworkEntityDescriptor subclass: MailGroupDescriptor [
    | addresses |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    addresses [
	<category: 'accessing'>
	^addresses
    ]

    addresses: anArray [
	<category: 'accessing'>
	addresses := anArray
    ]

    alias [
	<category: 'accessing'>
	^alias
    ]

    alias: aString [
	<category: 'accessing'>
	alias := aString
    ]

    initialize [
	<category: 'initialization'>
	addresses := Array new
    ]

    printCanonicalValueOn: stream [
	<category: 'printing'>
	self printAliasOn: stream.
	stream nextPut: $:.
	self addresses do: [:address | address printOn: stream]
	    separatedBy: [stream nextPut: $,].
	stream nextPut: $;
    ]
]

]



Namespace current: NetClients.MIME [

MailScanner subclass: RFC822Scanner [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    HeaderNameMask := nil.
    QuotedPairChar := nil.
    QuotedPairMask := nil.
    AtomMask := nil.
    QuotedTextMask := nil.
    CommentMask := nil.
    SimpleTimeZones := nil.
    DomainTextMask := nil.
    TextMask := nil.
    HeaderNameDelimiterChar := nil.
    TokenMask := nil.

    RFC822Scanner class >> specials [
	"Note that definition of this set varies from standard to standard, so this method needs to be overridden for specialized parsers"

	<category: 'character classification'>
	^'()<>@,;:\".[]'
    ]

    RFC822Scanner class >> tspecials [
	"tspecials in MIME and HTTP. It is derived from RCC822 specials with addition of </>, <?>, <=> and removal of <.>"

	<category: 'character classification'>
	^'()<>@,;:\"/[]?='
    ]

    RFC822Scanner class >> initClassificationTable [
	<category: 'class initialization'>
	super initClassificationTable.
	self initClassificationTableWith: HeaderNameMask
	    when: [:c | c > Character space and: [c ~~ $:]].
	self initClassificationTableWith: TextMask
	    when: [:c | c ~~ Character cr and: [c ~~ Character nl]].
	self initClassificationTableWith: AtomMask
	    when: [:c | c > Character space and: [(self specials includes: c) not]].
	self initClassificationTableWith: TokenMask
	    when: [:c | c > Character space and: [(self tspecials includes: c) not]].
	self initClassificationTableWith: QuotedTextMask
	    when: 
		[:c | 
		c ~~ $" and: [c ~~ $\ and: [c ~~ Character cr and: [c ~~ Character nl]]]].
	self initClassificationTableWith: DomainTextMask
	    when: 
		[:c | 
		('[]\' includes: c) not and: [c ~~ Character cr and: [c ~~ Character nl]]].
	self initClassificationTableWith: CommentMask
	    when: 
		[:c | 
		c ~~ $( and: 
			[c ~~ $) and: [c ~~ $\ and: [c ~~ Character cr and: [c ~~ Character nl]]]]]
    ]

    RFC822Scanner class >> initialize [
	"RFC822Scanner initialize"

	<category: 'class initialization'>
	self
	    initializeConstants;
	    initClassificationTable
    ]

    RFC822Scanner class >> initializeConstants [
	<category: 'class initialization'>
	AtomMask := 256.
	CommentMask := 512.
	DomainTextMask := 1024.
	HeaderNameMask := 2048.
	QuotedTextMask := 4096.
	TextMask := 8192.
	TokenMask := 16384.
	QuotedPairMask := (QuotedTextMask bitOr: CommentMask) 
		    bitOr: DomainTextMask.
	QuotedPairChar := $\.
	HeaderNameDelimiterChar := $:
    ]

    RFC822Scanner class >> dateAndTimeFrom: aString [
	"RFC822Scanner dateAndTimeFrom: '6 Dec 88 10:16:08 +0900 (Tuesday)'."

	"RFC822Scanner dateAndTimeFrom: '12 Dec 88 10:16:08 +0900 (Tuesday)'."

	"RFC822Scanner dateAndTimeFrom: 'Fri, 31 Mar 89 09:13:20 +0900'."

	"RFC822Scanner dateAndTimeFrom: 'Tue, 18 Apr 89 23:29:47 +0900'."

	"RFC822Scanner dateAndTimeFrom: 'Tue, 23 May 89 13:52:12 JST'."

	"RFC822Scanner dateAndTimeFrom: 'Thu, 1 Dec 88 17:13:27 jst'."

	"RFC822Scanner dateAndTimeFrom: 'Sat, 15 Jul 95 14:36:22 0900'."

	"RFC822Scanner dateAndTimeFrom: '2-Nov-86 10:43:42 PST'."

	"RFC822Scanner dateAndTimeFrom: 'Friday, 21-Jul-95 04:04:55 GMT'."

	"RFC822Scanner dateAndTimeFrom: 'Jul 10 11:06:40 1995'."

	"RFC822Scanner dateAndTimeFrom: 'Jul 10 11:06:40 JST 1995'."

	"RFC822Scanner dateAndTimeFrom: 'Mon Jul 10 11:06:40 1995'."

	"RFC822Scanner dateAndTimeFrom: 'Mon Jul 10 11:06:40 JST 1995'."

	"RFC822Scanner dateAndTimeFrom: '(6 December 1988 10:16:08 am )'."

	"RFC822Scanner dateAndTimeFrom: '(12 December 1988 10:16:08 am )'."

	"RFC822Scanner dateAndTimeFrom: ''."

	<category: 'from Network Clients'>
	| rfcString |
	aString size <= 10 
	    ifTrue: 
		["may be illegal format"

		^DateTime utcDateAndTimeNow].
	rfcString := self normalizeDateAndTimeString: aString.
	^self readRFC822DateAndTimeFrom: rfcString readStream
    ]

    RFC822Scanner class >> defaultTimeZoneDifference [
	<category: 'from Network Clients'>
	^DateTime now offset seconds
    ]

    RFC822Scanner class >> initializeTimeZones [
	"RFC822Scanner initializeTimeZones."

	"Install TimeZone constants."

	<category: 'from Network Clients'>
	SimpleTimeZones := Dictionary new.

	"Universal Time"
	SimpleTimeZones at: 'UT' put: 0.
	SimpleTimeZones at: 'GMT' put: 0.

	"For North America."
	SimpleTimeZones at: 'EST' put: -5.
	SimpleTimeZones at: 'EDT' put: -4.
	SimpleTimeZones at: 'CST' put: -6.
	SimpleTimeZones at: 'CDT' put: -5.
	SimpleTimeZones at: 'MST' put: -7.
	SimpleTimeZones at: 'MDT' put: -6.
	SimpleTimeZones at: 'PST' put: -8.
	SimpleTimeZones at: 'PDT' put: -7.

	"For Europe."
	SimpleTimeZones at: 'BST' put: 0.
	SimpleTimeZones at: 'WET' put: 0.
	SimpleTimeZones at: 'MET' put: 1.
	SimpleTimeZones at: 'EET' put: 2.

	"For Japan."
	SimpleTimeZones at: 'JST' put: 9
    ]

    RFC822Scanner class >> normalizeDateAndTimeString: aString [
	"RFC822 formats"

	"RFC822Scanner normalizeDateAndTimeString: '6 Dec 88 10:16:08 +0900 (Tuesday)'."

	"RFC822Scanner normalizeDateAndTimeString: 'Tue, 18 Apr 89 23:29:47 +0900'."

	"RFC822Scanner normalizeDateAndTimeString: 'Tue, 18 Apr 89 23:29:47 0900'."

	"RFC822Scanner normalizeDateAndTimeString: 'Tue, 23 May 89 13:52:12 JST'."

	"RFC822Scanner normalizeDateAndTimeString: '2-Nov-86 10:43:42 PST'."

	"Other formats"

	"RFC822Scanner normalizeDateAndTimeString: 'Jul 10 11:06:40 1995'."

	"RFC822Scanner normalizeDateAndTimeString: 'Jul 10 11:06:40 JST 1995'."

	"RFC822Scanner normalizeDateAndTimeString: 'Mon Jul 10 11:06:40 1995'."

	"RFC822Scanner normalizeDateAndTimeString: 'Mon Jul 10 11:06:40 JST 1995'."

	<category: 'from Network Clients'>
	| head tail read str1 str2 write |
	aString size < 6 ifTrue: [^aString].
	head := aString copyFrom: 1 to: aString size - 5.
	(head indexOf: $,) > 0 ifTrue: [^aString].
	tail := aString copyFrom: aString size - 4 to: aString size.
	read := tail readStream.
	(read next = Character space and: 
		[read next isDigit 
		    and: [read next isDigit and: [read next isDigit and: [read next isDigit]]]]) 
	    ifFalse: [^aString].
	read := head readStream.
	str1 := read upTo: Character space.
	str2 := read upTo: Character space.
	(str1 isEmpty or: [str2 isEmpty]) ifTrue: [^aString].
	str2 first isDigit 
	    ifFalse: 
		[str1 := str2.
		str2 := read upTo: Character space.
		(str2 isEmpty or: [str2 first isDigit not]) ifTrue: [^aString]].
	read atEnd ifTrue: [^aString].
	write := WriteStream on: (String new: 32).
	write
	    nextPutAll: str2;
	    nextPutAll: str1;
	    nextPutAll: (tail copyFrom: 4 to: 5);
	    space;
	    nextPutAll: read.
	^write contents
    ]

    RFC822Scanner class >> readDateFrom: aStream [
	"date    =  1*2DIGIT month 2DIGIT
	 month    =  'Jan'  /  'Feb' /  'Mar'  /  'Apr'
	 /  'May'  /  'Jun' /  'Jul'  /  'Aug'
	 /  'Sep'  /  'Oct' /  'Nov'  /  'Dec'"

	"RFC822Scanner readDateFrom: '01 Jan 95' readStream."

	"RFC822Scanner readDateFrom: '1 Jan 95' readStream."

	"RFC822Scanner readDateFrom: '23 Jan 95' readStream."

	"RFC822Scanner readDateFrom: '23-Jan-95' readStream."

	"RFC822Scanner readDateFrom: 'Jan 23 95' readStream."

	"RFC822Scanner readDateFrom: 'Jan 23 1995' readStream."

	<category: 'from Network Clients'>
	^Date readFrom: aStream
    ]

    RFC822Scanner class >> readRFC822DateAndTimeFrom: aStream [
	"date-time    =  [ day ',' ] date time
	 day            =  'Mon'  / 'Tue' /  'Wed'  / 'Thu'
	 /  'Fri'  / 'Sat' /  'Sun'"

	"RFC822Scanner readRFC822DateAndTimeFrom: '6 Dec 88 10:16:08 +0900 (Tuesday)' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '12 Dec 88 10:16:08 +0900 (Tuesday)' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Fri, 31 Mar 89 09:13:20 +0900' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Tue, 18 Apr 89 23:29:47 +0900' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Tue, 23 May 89 13:52:12 JST' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Thu, 1 Dec 88 17:13:27 jst' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '2-Nov-86 10:43:42 PST' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '(6 December 1988 10:16:08 am )' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '(12 December 1988 10:16:08 am )' readStream."

	<category: 'from Network Clients'>
	| char date time |
	[aStream atEnd or: 
		[char := aStream peek.
		char isDigit]] 
	    whileFalse: [aStream next].
	aStream atEnd ifTrue: [^DateTime utcDateAndTimeNow].
	date := self readDateFrom: aStream.
	aStream skipSeparators.
	time := self readTimeFrom: aStream.
	^Array with: date with: time
    ]

    RFC822Scanner class >> readTimeFrom: aStream [
	"time    =  hour zone
	 hour    =  2DIGIT ':' 2DIGIT [':' 2DIGIT]
	 zone    =  'UT'  / 'GMT'
	 /  'EST' / 'EDT'
	 /  'CST' / 'CDT'
	 /  'MST' / 'MDT'
	 /  'PST' / 'PDT'
	 /  1ALPHA
	 / ( ('+' / '-') 4DIGIT )"

	"RFC822Scanner readTimeFrom: '12:16:08 GMT' readStream."

	"RFC822Scanner readTimeFrom: '12:16:08 XXX' readStream."

	"RFC822Scanner readTimeFrom: '07:16:08 EST' readStream."

	"RFC822Scanner readTimeFrom: '07:16:08 -0500' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 JST' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 jst' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 +0900' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 0900' readStream."

	"RFC822Scanner readTimeFrom: '12:16:08 pm' readStream."

	"Smalltalk time"

	"RFC822Scanner readTimeFrom: '12:16' readStream."

	"No timezone"

	"RFC822Scanner readTimeFrom: '12:16:08' readStream."

	"No timezone"

	<category: 'from Network Clients'>
	| hour minute second write char timezone |
	hour := Integer readFrom: aStream.
	minute := 0.
	second := 0.
	(aStream peekFor: $:) 
	    ifTrue: 
		[minute := Integer readFrom: aStream.
		(aStream peekFor: $:) ifTrue: [second := Integer readFrom: aStream]].
	aStream skipSeparators.
	write := WriteStream on: (String new: 8).
	[aStream atEnd or: 
		[char := aStream next.
		char isSeparator]] 
	    whileFalse: [write nextPut: char].
	timezone := write contents asUppercase.
	(SimpleTimeZones at: timezone ifAbsent: [nil]) notNil 
	    ifTrue: [hour := hour - (SimpleTimeZones at: timezone)]
	    ifFalse: 
		[('+####' match: timezone) 
		    ifTrue: 
			[hour := hour - (timezone copyFrom: 2 to: 3) asNumber.
			minute := minute - (timezone copyFrom: 4 to: 5) asNumber]
		    ifFalse: 
			[('-####' match: timezone) 
			    ifTrue: 
				[hour := hour + (timezone copyFrom: 2 to: 3) asNumber.
				minute := minute + (timezone copyFrom: 4 to: 5) asNumber]
			    ifFalse: 
				['AM' = timezone 
				    ifTrue: 
					["Smalltalk time"

					hour = 12 ifTrue: [hour := 0]]
				    ifFalse: 
					['PM' = timezone 
					    ifTrue: 
						["Smalltalk time"

						hour = 12 ifTrue: [hour := 0].
						hour := hour + 12]
					    ifFalse: 
						["Using default time zone"

						hour := hour - (self defaultTimeZoneDifference // 3600)]]]]].
	^Time fromSeconds: 60 * (60 * hour + minute) + second
    ]

    RFC822Scanner class >> defaultTokenType [
	<category: 'printing'>
	^#word
    ]

    RFC822Scanner class >> nextPutComment: comment on: stream [
	<category: 'printing'>
	comment notNil 
	    ifTrue: 
		[stream nextPut: $(.
		comment do: 
			[:char | 
			(self isCommentChar: char) ifFalse: [stream nextPut: $\].
			stream nextPut: char].
		stream nextPut: $)]
    ]

    RFC822Scanner class >> printDomain: domainx on: stream [
	"Domainx is an array of domain segments"

	<category: 'printing'>
	domainx notNil 
	    ifTrue: 
		[domainx do: [:word | self printWord: word on: stream]
		    separatedBy: [stream nextPut: $.]]
    ]

    RFC822Scanner class >> printPhrase: phrase on: stream [
	<category: 'printing'>
	phrase do: [:word | stream nextPutAll: word] separatedBy: [stream space]
    ]

    RFC822Scanner class >> printWord: str on: stream [
	"Print word as either atom or quoted text"

	<category: 'printing'>
	(self shouldBeQuoted: str) 
	    ifTrue: 
		[stream
		    nextPut: $";
		    nextPutAll: str;
		    nextPut: $"]
	    ifFalse: [stream nextPutAll: str]
    ]

    RFC822Scanner class >> isAtomChar: char [
	<category: 'testing'>
	^((self classificationTable at: char asInteger + 1) bitAnd: AtomMask) ~= 0
    ]

    RFC822Scanner class >> isCommentChar: char [
	<category: 'testing'>
	^((self classificationTable at: char asInteger + 1) bitAnd: CommentMask) 
	    ~= 0
    ]

    RFC822Scanner class >> shouldBeQuoted: string [
	<category: 'testing'>
	^(string detect: [:char | (self isAtomChar: char) not] ifNone: [nil]) 
	    notNil
    ]

    phraseAsString: phrase [
	<category: 'converting'>
	| stream |
	stream := (String new: 40) writeStream.
	self class printPhrase: phrase on: stream.
	^stream contents
    ]

    scanAtom [
	"atom  =  1*<any CHAR except specials, SPACE and CTLs>"

	<category: 'multi-character scans'>
	token := self scanTokenMask: AtomMask.
	tokenType := #atom.
	^token
    ]

    scanComment [
	"collect comment"

	<category: 'multi-character scans'>
	| output |
	output := saveComments 
		    ifTrue: [(String new: 40) writeStream]
		    ifFalse: [nil].
	self scanCommentOn: output.
	output notNil 
	    ifTrue: 
		[currentComment isNil 
		    ifTrue: [currentComment := OrderedCollection with: output contents]
		    ifFalse: [currentComment add: output contents]].
	^token
    ]

    scanDomainText [
	"dtext = <any CHAR excluding <[>, <]>, <\> & CR, & including linear-white-space> ; => may be folded"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: 
			[self
			    scanQuotedChar;
			    matchCharacterType: DomainTextMask]
		    delimitedBy: '[]'
		    notify: 'Malformed domain literal'.
	tokenType := #domainText.
	^token
    ]

    atEndOfLine [
	<category: 'multi-character scans'>
        self peek.
	^(self classificationMaskFor: lookahead) anyMask: CRLFMask
    ]

    skipEndOfLine [
	<category: 'multi-character scans'>
	hereChar == Character nl 
	    ifFalse: 
		[(source peekFor: Character nl) 
		    ifFalse: [^false]
		    ifTrue: [self sourceTrailNextPut: Character nl]].
        ^true
    ]

    scanEndOfLine [
	"Note: this will work only for RFC822 but not for HTTP. Needs more design work"

	<category: 'multi-character scans'>
        "Called after #step, so no need to peek to set the CRLFMask."
	(self matchCharacterType: CRLFMask) ifFalse: [^false].
	self skipEndOfLine ifFalse: [^self].
	self shouldFoldLine 
	    ifTrue: 
		[self hereChar: Character space.
		^self].

	"Otherwise we have an end-of-line condition -- set appropriate masks"
	classificationMask := (classificationMask bitClear: WhiteSpaceMask) 
		    bitOr: EndOfLineMask
    ]

    scanFieldName [
	"RFC822, p.9: field-name = 1*<any CHAR excluding CTLs, SPACE and ':'>"

	<category: 'multi-character scans'>
	^self scanTokenMask: HeaderNameMask
    ]

    scanPhrase [
	"RFC822: phrase = 1*word ; Sequence of words. At the end of scan the scanner has read the first token after phrase"

	<category: 'multi-character scans'>
	^self tokenizeWhile: [#(#quotedText #atom) includes: tokenType]
    ]

    scanQuotedChar [
	"Scan possible quoted character. If the current char is $\, read in next character and make it a quoted
	 string character"

	<category: 'multi-character scans'>
	^hereChar == QuotedPairChar 
	    ifTrue: 
		[self step.
		classificationMask := QuotedPairMask.
		true]
	    ifFalse: [false]
    ]

    scanQuotedText [
	"quoted-string = <"

	"> *(qtext/quoted-pair) <"

	">; Regular qtext or quoted chars.
	 qtext    =  <any CHAR excepting <"

	">, <\> & CR, and including linear-white-space>  ; => may be folded"

	"We are positioned at the first double quote character"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: 
			[self
			    scanQuotedChar;
			    matchCharacterType: QuotedTextMask]
		    delimitedBy: '""'
		    notify: 'Unmatched quoted text'.
	tokenType := #quotedText.
	^token
    ]

    scanText [
	"RFC822: text = <Any CHAR, including bare CR & bare LF, but not including CRLF. This is a 'catchall' category and cannot be tokenized. Text is used only to read values of unstructured fields"

	<category: 'multi-character scans'>
	(self matchCharacterType: EndOfLineMask) ifTrue: [^String new].
	^self scanUntil: [self matchCharacterType: CRLFMask]
    ]

    scanWord [
	<category: 'multi-character scans'>
	self nextToken.
	(#(#quotedText #atom) includes: tokenType) 
	    ifFalse: [self error: 'Expecting word'].
	^token
    ]

    skipWhiteSpace [
	"It is inefficient because intermediate stream is created. Perhaps refactoring scanWhile: can help"

	<category: 'multi-character scans'>
	self scanWhile: 
		[hereChar == $( 
		    ifTrue: 
			[self
			    stepBack;
			    scanComment.
			true]
		    ifFalse: [self matchCharacterType: WhiteSpaceMask]]
    ]

    nextRFC822Token [
	<category: 'private'>
	| char |
	self skipWhiteSpace.
	char := self peek.
	char isNil 
	    ifTrue: 
		["end of input"

		tokenType := #doIt.
		^token := nil].
	char == $( 
	    ifTrue: 
		[^self
		    scanComment;
		    nextToken].
	char == $" ifTrue: [^self scanQuotedText].
	(self specials includes: char) 
	    ifTrue: 
		[tokenType := #special.	"Special character. Make it token value and set token type"
		^token := self next].
	(self matchCharacterType: AtomMask) ifTrue: [^self scanAtom].
	tokenType := #doIt.
	token := char.
	^token
    ]

    scanCommentOn: streamOrNil [
	"scan comment copying on specified stream"

	<category: 'private'>
	self step ~~ $( ifTrue: [self error: 'Unmatched comment'].	"Should never be the case"
	token := self scanUntil: 
			[((self
			    scanQuotedChar;
			    matchCharacterType: CommentMask) 
				ifTrue: 
				    [streamOrNil notNil ifTrue: [streamOrNil nextPut: hereChar].
				    true]
				ifFalse: 
				    [hereChar == $( 
					ifTrue: 
					    [streamOrNil notNil ifTrue: [streamOrNil space].
					    self
						stepBack;
						scanCommentOn: streamOrNil.
					    streamOrNil notNil ifTrue: [streamOrNil space].
					    true]
					ifFalse: [false]]) 
				not].
	hereChar ~~ $) ifTrue: [self error: 'Unmatched comment'].
	^token
    ]

    assertNoLookahead [
	"Fail if the parser has lookahead."

	<category: 'test'>

        lookahead isNil ifFalse: [ self error: 'unexpected parsing state' ]
    ]

    shouldFoldLine [
	"Answers true if next line is to be folded in, that is, if CRLF is followed by at least one white space"

	<category: 'private'>
	| char |
	self atEnd ifTrue: [^false].
	char := source peek.
	^((self classificationMaskFor: char) anyMask: WhiteSpaceMask) 
	    ifFalse: 
		[self resetToken; peek.
		false]
	    ifTrue: 
		[self sourceTrailNextPut: source next.
		true]
    ]

    step [
	<category: 'private'>
	super step.
	self scanEndOfLine.
	^hereChar
    ]

    isRFC822Scanner [
	<category: 'testing'>
	^true
    ]

    nextToken [
	<category: 'tokenization'>
	^self nextRFC822Token
    ]

    specials [
	"This method is provided to encapsulate lexical differences between RFC822 on one side, and MIME, HTTP on the other side. MIME definiton of 'tspecials' is the same as the RFC 822 definition of ''specials' with the addition of the three characters </>, <?>, and <=>, and the removal of <.>. To present uniform tokenization interface, this method is overridden in Mime scanner"

	<category: 'tokenization'>
	^self class specials
    ]
]

]



Namespace current: NetClients.MIME [

StructuredHeaderField subclass: ScalarField [
    | value |
    
    <category: 'NetClients-MIME'>
    <comment: 'I represent RFC822 structured header field that contains a single value. When parsing the field we would just sequentially read and concatenate all tokens. This will remove all ''noise'' such as white space and comments

Instance Variables:
    item    <String>  Parsed value of the item
'>

    ScalarField class >> fieldNames [
	<category: 'parsing'>
	^#('message-id' 'content-id' 'content-transfer-encoding' 'transfer-encoding' 'content-encoding')
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]

    parse: rfc822Stream [
	<category: 'parsing'>
	self value: (self tokenizedValueFrom: rfc822Stream)
    ]
]

]



Namespace current: NetClients.MIME [

RFC822Scanner subclass: MimeScanner [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MimeScanner class >> decodeBase64From: startIndex to: endIndex in: aString [
	"Decode aString from startIndex to endIndex in base64."

	<category: 'text processing'>
	| codeChars decoder index nl endChars end padding data sz i outSize |
	codeChars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
	decoder := (0 to: 255) 
		    collect: [:n | (codeChars indexOf: (n + 1) asCharacter) - 1].
	decoder replaceAll: -1 with: 0.
	index := startIndex.
	nl := Character nl.
	"There is padding at the end of a base64 message if the content is not a multiple of
	 3 bytes in length.  The padding is either two ='s to pad-out a trailing byte, 1 = to
	 pad out a trailing pair of bytes, or no padding.  Here we count the padding.  After
	 processing the message we cut-back by the amount of padding."
	end := endIndex min: (sz := aString size).
	endChars := codeChars , (String with: $=).
	
	[(endChars includes: (aString at: end)) 
	    and: [end = endIndex or: [(aString at: end + 1) = nl]]] 
		whileFalse: [end := end - 1].
	padding := 0.
	[(aString at: end - padding) == $=] whileTrue: 
		[padding := padding + 1].
	outSize := (end - startIndex + 1) * 3 // 4 - padding.
	data := String new: outSize.
	i := 1.
	[index <= end] whileTrue: 
		[| triple |
		triple := ((decoder at: (aString at: index) asInteger) bitShift: 18) 
			    + ((decoder at: (aString at: index + 1) asInteger) bitShift: 12) 
				+ ((decoder at: (aString at: index + 2) asInteger) bitShift: 6) 
				+ (decoder at: (aString at: index + 3) asInteger).
		padding := outSize - i.
		data at: i put: (Character value: (triple digitAt: 3)).
		padding > 0 ifTrue: [
			data at: i + 1 put: (Character value: (triple digitAt: 2))].
		padding > 1 ifTrue: [
			data at: i + 2 put: (Character value: (triple digitAt: 1))].

		i := i + 3.
		index := index + 4.
		[(index > sz or: [(aString at: index) = nl]) and: [index <= end]] 
		    whileTrue: [index := index + 1]].
	^data
    ]

    MimeScanner class >> decodeQuotedPrintableFrom: startIndex to: endIndex in: aString [
	"Decode aString from startIndex to endIndex in quoted-printable."

	<category: 'text processing'>
	| input output char n1 n2 |
	input := ReadStream 
		    on: aString
		    from: startIndex
		    to: endIndex.
	output := (String new: endIndex - startIndex) writeStream.
	[input atEnd] whileFalse: 
		[char := input next.
		$= == char 
		    ifTrue: 
			[('0123456789ABCDEF' includes: (n1 := input next)) 
			    ifTrue: 
				[n2 := input next.
				output nextPut: ((n1 digitValue bitShift: 4) + n2 digitValue) asCharacter]]
		    ifFalse: [output nextPut: char]].
	^output contents
    ]

    MimeScanner class >> decodeUUEncodedFrom: startIndex to: farEndIndex in: aString [
	"decode aString from startIndex to farEndIndex as uuencode-encoded"

	<category: 'text processing'>
	| endIndex i nl space output data |
	endIndex := farEndIndex - 2.
	
	[endIndex <= startIndex or: 
		[(aString at: endIndex + 1) = $e 
		    and: [(aString at: endIndex + 2) = $n and: [(aString at: endIndex + 3) = $d]]]] 
		whileFalse: [endIndex := endIndex - 1].
	i := (aString 
		    findString: 'begin'
		    startingAt: startIndex
		    ignoreCase: true
		    useWildcards: false) first.
	i = 0 ifTrue: [i := startIndex].
	nl := Character nl.
	space := Character space asInteger.
	output := (data := String new: (endIndex - startIndex) * 3 // 4) 
		    writeStream.
	
	[[i < endIndex and: [(aString at: i) ~= nl]] whileTrue: [i := i + 1].
	i < endIndex] 
		whileTrue: 
		    [| count |
		    count := (aString at: (i := i + 1)) asInteger - space bitAnd: 63.
		    i := i + 1.
		    count = 0 
			ifTrue: [i := endIndex]
			ifFalse: 
			    [[count > 0] whileTrue: 
				    [| m n o p |
				    m := (aString at: i) asInteger - space bitAnd: 63.
				    n := (aString at: i + 1) asInteger - space bitAnd: 63.
				    o := (aString at: i + 2) asInteger - space bitAnd: 63.
				    p := (aString at: i + 3) asInteger - space bitAnd: 63.
				    count >= 1 
					ifTrue: 
					    [output nextPut: (Character value: (m bitShift: 2) + (n bitShift: -4)).
					    count >= 2 
						ifTrue: 
						    [output 
							nextPut: (Character value: ((n bitShift: 4) + (o bitShift: -2) bitAnd: 255)).
						    count >= 3 
							ifTrue: [output nextPut: (Character value: ((o bitShift: 6) + p bitAnd: 255))]]].
				    i := i + 4.
				    count := count - 3]]].
	^data copyFrom: 1 to: output position
    ]

    scanText [
	"Parse text as defined in RFC822 grammar, then apply the rules of RFC2047 for encoded words in Text fields. An encoded word inside text field may appear immediately following a white space character"

	<category: 'multi-character scans'>
	| text |
	text := super scanText.
	^MimeEncodedWordCoDec decodeText: text
    ]

    scanToBoundary: boundary [
	"Scan for specified boundary (RFC2046, p5.1). Answer two-element array. First element is the scanned text from current position up to the beginning of the boundary. Second element is either #next or #last. #next means the boundary found is not the last one. #last means the boundary is the closing boundary for the multi-part body (that is, it looks like '--<boundary>--)"

	<category: 'multi-character scans'>
	| pattern string kind |
	pattern := (String with: Character nl) , '--' , boundary.
	string := self upToAll: pattern.
	kind := ((self peekFor: $-) and: [self peekFor: $-]) 
		    ifTrue: [#last]
		    ifFalse: [#next].
	self upTo: Character nl.
	^Array with: string with: kind
    ]

    scanToken [
	"MIME and HTTP: token  =  1*<any CHAR except tspecials, SPACE and CTLs>. That is, 'token' is analogous to RFC822 'atom' except set of Mime's set of tspecials characters includes three more characters as compared to set of 'specials' in RFC822"

	<category: 'multi-character scans'>
	token := self scanTokenMask: TokenMask.
	tokenType := #token.
	^token
    ]

    printPhrase: phrase on: stream [
	<category: 'printing'>
	MimeEncodedWordCoDec decodePhrase: phrase printOn: stream
    ]

    decodeCommentString: commentString [
	<category: 'private'>
	^MimeEncodedWordCoDec decodeComment: commentString
    ]

    nextMimeToken [
	<category: 'private'>
	| char |
	self skipWhiteSpace.
	char := self peek.
	char isNil 
	    ifTrue: 
		["end of input"

		tokenType := #doIt.
		^token := nil].
	char == $( 
	    ifTrue: 
		[^self
		    scanComment;
		    nextToken].
	char == $" ifTrue: [^self scanQuotedText].
	(self specials includes: char) 
	    ifTrue: 
		[tokenType := #special.	"Special character. Make it token value and set token type"
		^token := self next].
	(self matchCharacterType: TokenMask) ifTrue: [^self scanToken].
	tokenType := #doIt.
	token := char.
	^token
    ]

    scanCommentOn: streamOrNil [
	"scan comment copying on specified stream. Look for MIME 'encoded words' (RFC2047) and decoded them if identified"

	<category: 'private'>
	token := super scanCommentOn: streamOrNil.
	^self decodeCommentString: token
    ]

    nextToken [
	<category: 'tokenization'>
	^self nextMimeToken
    ]

    specials [
	"This method is provided to encapsulate lexical differences between RFC822 on one side, and MIME, HTTP on the other side. MIME definiton of 'tspecials' is the same as the RFC 822 definition of ''specials' with the addition of the three characters </>, <?>, and <=>, and the removal of <.>. To present uniform tokenization interface, this method is overridden in Mime scanner"

	<category: 'tokenization'>
	^self class tspecials
    ]
]

]



Namespace current: NetClients.MIME [

RFC822Scanner subclass: NetworkAddressParser [
    | descriptor |
    
    <category: 'NetClients-MIME'>
    <comment: 'This class parses mailbox and group addresses as well as address-spec as defined by RFC822 and MIME. Parsed results are placed in an instance of NetworkAddressDescriptor or MailGroupDescriptor. See utility methods.
RFC822 spec is word-based, so address is first tokenized, then parsed. MIME (RFC2045-2049) adds further interpretation to the address syntax. Once address is parsed, some parts of the address (namely ''phrase'' and ''comment'') can be further scanned for the presence of ''encoded words''. 
Note that MIME ''words'' are not the same as RFC822 ''words'', so the same expression may be tokenized differently in RFC822 and MIME. MIME states that mailbox and group addresses MUST be tokenized using RFC822 spec, then processed according to MIME rules. Therefore, we use #nextRFC822Token, not #nextToken like everybody else


Instance Variables:
    descriptor    <NetworkAddressDescriptor | MailGroupDescriptor>  comment
'>

    NetworkAddressParser class >> parse: string [
	<category: 'instance creation'>
	^self new parse: string
    ]

    NetworkAddressParser class >> addressesFrom: stream [
	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp' readStream."

	"self addressesFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>' readStream."

	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' kyasu1, kyasu2, Kazuki Yasumatsu <kyasu3>, kyasu4 (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' foo bar, kyasu1, ,  Kazuki Yasumatsu <kyasu2> <kyasu3> (<foo> (foo bar), bar)' readStream."

	<category: 'utility'>
	^(self on: stream) parseAddressesSeparatedBy: $,
    ]

    NetworkAddressParser class >> addressFrom: stream [
	"self addressFrom: 'kyasu@crl.fujixerox.co.jp'."

	"self addressFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>'."

	"self addressFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)'."

	<category: 'utility'>
	^(self on: stream) parseAddress
    ]

    descriptor [
	<category: 'accessing'>
	^descriptor
    ]

    descriptor: aValue [
	<category: 'accessing'>
	descriptor := aValue
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	descriptor := self newAddressDescriptor
    ]

    completeScanOfAddressSpecWith: partial [
	"addr-spec   =  local-part <@> domain        ; global address
	 local-part = word *(<.> word) ; uninterpreted, case-preserved
	 First local-part token was already scanned; we are now scanning *(<.> word) group and domain part.
	 Partial is an array of tokens already read"

	<category: 'private'>
	| stream pos |
	stream := partial readWriteStream.
	stream setToEnd.
	self descriptor localPart: (self scanLocalAddressPartTo: stream).
	pos := self position.
	self nextRFC822Token == $@ 
	    ifTrue: [self descriptor domain: self scanDomain]
	    ifFalse: [self position: pos]
    ]

    newAddressDescriptor [
	<category: 'private'>
	^NetworkAddressDescriptor new
    ]

    parseGroupSpecWith: phrase [
	"group = phrase <:> [#mailbox] <;>"

	<category: 'private'>
	| group mailboxes phrasex comment stream |
	mailboxes := self tokenizeList: [self parseAddress]
		    separatedBy: [token == $,].
	self nextRFC822Token == $; 
	    ifFalse: [^self notify: 'Group descriptor should be terminated by <:>'].
	group := MailGroupDescriptor new.

	"If phrase is non-empty, an alias was specified"
	phrasex := phrase isEmpty 
		    ifTrue: [nil]
		    ifFalse: [self phraseAsString: phrase].
	comment := currentComment isNil 
		    ifTrue: [nil]
		    ifFalse: 
			[stream := (String new: 40) writeStream.
			currentComment do: [:part | stream nextPutAll: part]
			    separatedBy: [stream space].
			stream contents].
	group
	    alias: phrasex;
	    addresses: mailboxes;
	    comment: comment.
	^group
    ]

    parseMailboxSpecWith: phrasex [
	"address     =  mailbox                      ; one addressee
	 /  group                        ; named list
	 group       =  phrase <:> [#mailbox] <;>
	 mailbox     =  addr-spec                    ; simple address
	 /  phrase route-addr            ; name & addr-spec
	 route-addr  =  <<> [route] addr-spec <>>
	 route       =  1#(<@> domain) <:>           ; path-relative"

	<category: 'private'>
	| phrase tok local stream comment |
	phrase := phrasex.
	tok := self nextRFC822Token.
	self descriptor: self newAddressDescriptor.

	"Variations of mailbox spec"
	tok = $< 
	    ifTrue: 
		["Phil Campbell<philc@acme.com>"

		self
		    stepBack;
		    scanRouteAndAddress]
	    ifFalse: 
		[('.@' includes: tok) 
		    ifTrue: 
			["These ones should have a non-empty local part to the left of delimiter"

			phrase isEmpty ifTrue: [self error: 'Invalid network address'].
			local := Array with: phrase last.
			phrase := phrase copyFrom: 1 to: phrase size - 1.	"Extract the part we already scanned"
			tok = $. 
			    ifTrue: 
				["phil.campbell.wise@acme.com>"

				self
				    stepBack;
				    completeScanOfAddressSpecWith: local].
			tok = $@ 
			    ifTrue: 
				["philc@acme.com>"

				self descriptor localPart: local.
				self descriptor domain: self scanDomain]]
		    ifFalse: [self stepBack]].
	"If phrase is non-empty, an alias was specified"
	phrase := phrase isEmpty 
		    ifTrue: [phrase := nil]
		    ifFalse: [self phraseAsString: phrase].
	self descriptor alias: phrase.
	comment := currentComment isNil 
		    ifTrue: [nil]
		    ifFalse: 
			[stream := (String new: 40) writeStream.
			currentComment do: [:part | stream nextPutAll: part]
			    separatedBy: [stream space].
			stream contents].
	self descriptor comment: comment.
	^self descriptor
    ]

    scanLocalAddressPartTo: stream [
	"local-part = word *(<.> word) ; uninterpreted, case-preserved
	 Part of local part may have been scanned already, it's in localPart of the descriptor"

	<category: 'private'>
	self tokenizeWhile: [token == $.] do: [stream nextPut: self scanWord].
	^stream contents
    ]

    tryScanSubdomain [
	<category: 'private'>
	self nextRFC822Token.
	tokenType = #atom ifTrue: [^true].
	token = $[ 
	    ifTrue: 
		[self
		    stepBack;
		    scanDomainText.
		^true].
	^false
    ]

    addressesFrom: stream [
	<category: 'public'>
	^(self on: stream) parseAddressesSeparatedBy: $,
    ]

    parse: aString [
	<category: 'public'>
	^self
	    on: aString readStream;
	    parseAddress
    ]

    parseAddress [
	"address     =  mailbox                      ; one addressee
	 /  group                        ; named list
	 group       =  phrase <:> [#mailbox] <;>
	 mailbox     =  addr-spec                    ; simple address
	 /  phrase route-addr            ; name & addr-spec
	 route-addr  =  <<> [route] addr-spec <>>
	 route       =  1#(<@> domain) <:>           ; path-relative"

	<category: 'public'>
	| phrase |
	phrase := self scanPhrase.
	^self nextRFC822Token = $: 
	    ifTrue: [self parseGroupSpecWith: phrase]
	    ifFalse: 
		[self
		    stepBack;
		    parseMailboxSpecWith: phrase]
    ]

    parseAddressesSeparatedBy: separatorChar [
	<category: 'public'>
	| addresses |
	addresses := self tokenizeList: [self parseAddress]
		    separatedBy: [token == separatorChar].
	^addresses
    ]

    scanDomain [
	"domain = sub-domain *(<.> sub-domain)"

	"Answers an array of domain seqments, from least significant to most significant"

	<category: 'public'>
	^self tokenizeList: 
		[self nextRFC822Token.
		tokenType = #atom 
		    ifTrue: [token]
		    ifFalse: 
			[token = $[ 
			    ifTrue: 
				[self
				    stepBack;
				    scanDomainText]
			    ifFalse: [^self notify: 'Invalid domain specification']]]
	    separatedBy: [token == $.]
    ]

    scanLocalAddress [
	"local-part = word *(<.> word) ; uninterpreted, case-preserved"

	<category: 'public'>
	^self tokenizeList: 
		[self nextRFC822Token.
		(#(#quotedText #atom) includes: tokenType) 
		    ifFalse: [^self notify: 'Local part can only include words'].
		token]
	    separatedBy: [token == $.]
    ]

    scanRoute [
	"route = 1#(<@> domain) <:> ; path-relative"

	<category: 'public'>
	| stream |
	stream := (Array new: 2) writeStream.
	[self nextRFC822Token == $@] whileTrue: 
		[stream nextPut: self scanDomain.
		self nextToken = $: ifFalse: [self error: 'Invalid route spec']].
	stream size = 0 ifTrue: [self error: 'Invalid route spec'].
	^stream contents
    ]

    scanRouteAndAddress [
	"route-addr  =  <<> [route] addr-spec <>>"

	<category: 'public'>
	self mustMatch: $< notify: 'Invalid route address spec'.
	self nextRFC822Token == $@ 
	    ifTrue: 
		[self stepBack.
		self descriptor route: self scanRoute].
	self completeScanOfAddressSpecWith: (Array with: token).
	self mustMatch: $> notify: 'Invalid route address spec'
    ]
]

]



Namespace current: NetClients.MIME [

StructuredHeaderField subclass: ContentTypeField [
    | type subtype |
    
    <category: 'NetClients-MIME'>
    <comment: 'This class represents MIME and HTTP Content-type header field. Format and semantics of this field are defined in the following documents:
    RFC2045: MIME, Part One: Format of Internet Message Bodies (ftp.uu.net/inet/rfc/rfc2045.Z)
    RFC2046: MIME, Part Two: Media Types (ftp.uu.net/inet/rfc/rfc2046.Z)
    RFC2068: Hyptertext Transfer Protocol -- HTTP/1.1 (ftp.uu.net/inet/rfc/rfc2068.Z)
As well as some other supplementary documents such as RFC2110 (ftp.uu.net/inet/rfc/rfc2110.Z)

The purpose of this field is to describe the data containing in the message body fully enough that the receiving side can pick an appropriate mechanism to handle the data in an appropriate manner. The value of this field is called a media type.

The value of media type consists of media type and subtype identifiers as well as auxiliary information required for certain media types. Auxiliary information is parsed and stored as field parameters. Utility methods are provided to simplify access to the most common parameters such as charset.

Currently defined top level media types are as follows:

    text, image, audio, video, multipart

Default is
    text/plain; charset=us-ascii

Instance Variables:
    type    <String>  Top level media type
    subtype    <String>  Media subtype
'>

    ContentTypeField class >> default [
	<category: 'defaults'>
	^self fromLine: 'content-type: text/plain; charset=us-ascii'
    ]

    ContentTypeField class >> defaultCharset [
	<category: 'defaults'>
	^'us-ascii'
    ]

    ContentTypeField class >> defaultContentType [
	<category: 'defaults'>
	^'text/plain'
    ]

    ContentTypeField class >> urlEncoded [
	<category: 'defaults'>
	^self 
	    fromLine: 'content-type: application/x-www-form-urlencoded; charset=us-ascii'
    ]

    ContentTypeField class >> fieldNames [
	<category: 'parsing'>
	^#('content-type')
    ]

    boundary [
	<category: 'accessing'>
	^self parameterAt: 'boundary'
    ]

    boundary: aString [
	<category: 'accessing'>
	^self parameterAt: 'boundary' put: aString
    ]

    charset [
	<category: 'accessing'>
	^(self parameterAt: 'charset' ifAbsent: [^self class defaultCharset]) 
	    asLowercase
    ]

    contentType [
	<category: 'accessing'>
	^type , '/' , subtype
    ]

    subtype [
	<category: 'accessing'>
	^subtype
    ]

    subtype: aString [
	<category: 'accessing'>
	subtype := aString
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    type: aString [
	<category: 'accessing'>
	type := aString
    ]

    multipartType [
	<category: 'constants'>
	^'multipart'
    ]

    parse: rfc822Stream [
	"RFC2045: content := <Content-Type> <:> type </> subtype *(<;> parameter)"

	<category: 'parsing'>
	type := rfc822Stream nextToken asLowercase.
	rfc822Stream mustMatch: $/
	    notify: 'Content type must be specified as type/subtype'.
	subtype := rfc822Stream nextToken asLowercase.
	self readParametersFrom: rfc822Stream
    ]

    printStructureOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self contentType.
	self printParametersOn: aStream
    ]

    isMultipart [
	<category: 'testing'>
	^type = 'multipart'
    ]
]

]



Namespace current: NetClients.MIME [

ScalarField subclass: VersionField [
    | majorVersion minorVersion |
    
    <category: 'NetClients-MIME'>
    <comment: 'I represent version fields such as MIME or HTTP version field. My value has a form <major version><.><minor version>. Value of this field is its version strung; methods are provided to read (or construct version from) its constituent parts


Instance Variables:
    majorVersion    <String>    comment
    minorVersion    <String>  comment
'>

    VersionField class >> fieldNames [
	<category: 'parsing'>
	^#('mime-version' 'http-version')
    ]

    majorVersion [
	<category: 'accessing'>
	^majorVersion
    ]

    majorVersion: number [
	<category: 'accessing'>
	majorVersion := number
    ]

    minorVersion [
	<category: 'accessing'>
	^minorVersion
    ]

    minorVersion: number [
	<category: 'accessing'>
	minorVersion := number
    ]

    value [
	<category: 'accessing'>
	^self version
    ]

    value: string [
	<category: 'accessing'>
	self version: string
    ]

    version [
	<category: 'accessing'>
	^majorVersion , '.' , minorVersion
    ]

    version: string [
	<category: 'accessing'>
	| arr |
	arr := string subStrings: $..
	arr size < 2 
	    ifTrue: 
		[self 
		    notify: 'Version should be specified as <major version>.<minor version>'].
	self majorVersion: arr first.
	self minorVersion: arr last
    ]
]

]



Namespace current: NetClients.MIME [

ScalarField subclass: SingleMailboxField [
    
    <category: 'NetClients-MIME'>
    <comment: 'This class is used to represent RFC822 fields whose value is a single mailbox or network address. Value of this field is its mailbox descriptor. Examples of single mailbox field are ''Sender:'' and ''Resent-Sender''. Note that the absolute majority of address fields may contain multiple addresses and, therefore, are instantiated as MailBoxListFields.'>

    SingleMailboxField class >> fieldNames [
	<category: 'parsing'>
	^#('sender' 'resent-sender')
    ]

    address [
	<category: 'accessing'>
	^self value
    ]

    address: address [
	<category: 'accessing'>
	self value: address
    ]

    addresses [
	<category: 'accessing'>
	^{self address}
    ]

    addresses: aCollection [
	<category: 'accessing'>
	aCollection size = 1 
	    ifFalse: [self error: 'can only contain a single address'].
	aCollection do: [:theOnlyAddress | self value: theOnlyAddress]
    ]

    parse: rfc822Stream [
	"HeaderField fromLine: 'Sender :        Phil Campbell (The great) <philc@yahoo.com>'"

	<category: 'parsing'>
	self value: (NetworkAddressDescriptor addressFrom: rfc822Stream)
    ]
]

]



Namespace current: NetClients.MIME [

ScalarField subclass: MailboxListField [
    
    <category: 'NetClients-MIME'>
    <comment: 'I am used to represent most of RFC822 address fields. My value is a sequenceable collection of mailbox or mail group descriptors. Examples of this field are ''From'', ''To'', ''Cc'', ''Bcc'', etc'>

    MailboxListField class >> fieldNames [
	<category: 'parsing'>
	^#('from' 'to' 'reply-to' 'cc' 'bcc' 'resent-reply-to' 'resent-from' 'resent-to' 'resent-cc' 'resent-bcc')
    ]

    addAddress: address [
	<category: 'accessing'>
	^self addAddresses: (Array with: address)
    ]

    addAddresses: aCollection [
	<category: 'accessing'>
	self value addAll: aCollection
    ]

    address [
	<category: 'accessing'>
	self value first
    ]

    address: address [
	<category: 'accessing'>
	self value isEmpty ifTrue: [self value: (OrderedCollection new: 1)].
	self value at: 1 put: address
    ]

    addresses [
	<category: 'accessing'>
	^self value
    ]

    addresses: aCollection [
	<category: 'accessing'>
	self value: aCollection
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	value := OrderedCollection new
    ]

    parse: rfc822Stream [
	"HeaderField fromLine: 'To       :  George Jones <Group@Some-Reg.An-Org>,
	 Al.Neuman@MAD.Publisher'"

	<category: 'parsing'>
	self value: (NetworkAddressDescriptor addressesFrom: rfc822Stream)
    ]

    printValueOn: aStream [
	<category: 'printing'>
	| val |
	(val := self value) notNil 
	    ifTrue: 
		[val do: [:each | each printOn: aStream]
		    separatedBy: 
			[aStream
			    nextPutAll: ', ';
			    nl;
			    tab]]
    ]
]

]



Namespace current: NetClients.MIME [
    SimpleScanner initialize.
    RFC822Scanner initialize
]

