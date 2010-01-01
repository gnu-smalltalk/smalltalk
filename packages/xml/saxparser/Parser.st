"======================================================================
|
|   VisualWorks XML Framework - SAX Parser interface
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000, 2002 Cincom, Inc.
| Copyright (c) 2009 Free Software Foundation, Inc.
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


Object subclass: SAXParser [
    | sax validating flags |
    
    <category: 'XML-XML-SAX'>
    <comment: '
SAXParser represents the main XML processor in the VisualWorks
environment.

As an XML processor, an instance of SAXParser is typically created by
a Smalltalk application, and then used to scan and process an XML
document, providing the application with access to its content and
structure.

Class SAXParser tries to follow the guidelines laid out in the W3C XML
Version 1.0 specification.

Instance Variables:
    sax				<XML.SAXDriver>			the output
    validating	<Boolean>						if true then the parse validates the XML
    flags		<SmallInteger>				sundry boolean values that are not accessed often enough
    											to need separate instance variables.'>

    DefaultParserClass := nil.

    SAXParser class >> defaultParserClass [
	<category: 'instance creation'>
	^DefaultParserClass
    ]

    SAXParser class >> defaultParserClass: aClass [
	<category: 'instance creation'>
	DefaultParserClass := aClass.
    ]

    SAXParser class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    SAXParser class >> on: aDataSource [
	"The dataSource may be a URI, a Filename (or a String
	 which will be treated as a Filename), or an InputSource."

	<category: 'instance creation'>
	^self new on: aDataSource
    ]

    SAXParser class >> onFile: aFilename [
        <category: 'instance creation'>
        ^self on: (FileStream open: aFilename mode: FileStream read)
    ]

    SAXParser class >> onString: aString [
        <category: 'instance creation'>
        ^self on: aString readStream
    ]

    SAXParser class >> processDocumentInFilename: aFilename [
	<category: 'instance creation'>
	^self processDocumentInFilename: aFilename beforeScanDo: [:parser | ]
    ]

    SAXParser class >> processDocumentInFilename: aFilename beforeScanDo: aBlock [
	<category: 'instance creation'>
	| stream p |
	p := self onFile: aFilename.
	aBlock value: p.
	^p scanDocument
    ]

    SAXParser class >> processDocumentString: aString [
	<category: 'instance creation'>
	^self processDocumentString: aString beforeScanDo: [:parser | ]
    ]

    SAXParser class >> processDocumentString: aString beforeScanDo: aBlock [
	<category: 'instance creation'>
	| p |
	p := self onString: aString.
	aBlock value: p.
	^p scanDocument
    ]

    SAXParser class >> mapEncoding: anEncoding [
	<category: 'utilities'>
	^anEncoding asUppercase
    ]

    initialize [
	<category: 'initialize'>
	validating := true.
	self saxDriver: DOM_SAXDriver new.
	flags := 0.
	self processNamespaces: true.
    ]

    on: dataSource [
	"The dataSource may be a URI, a Filename (or a String
	 which will be treated as a Filename), or an InputSource."

	<category: 'initialize'>
	"Clear those flags that keep track of the
	 state of the parse, but retain those that
	 relate to options."
	flags := flags bitAnd: 65535 bitInvert.
    ]

    saxDriver: aSAXDriver [
	<category: 'initialize'>
	sax := aSAXDriver.
	sax setDocumentLocator: (Locator new parser: self)
    ]

    document [
	<category: 'accessing'>
	^sax document
    ]

    saxDriver [
	<category: 'accessing'>
	^sax
    ]

    validate: aBoolean [
	<category: 'accessing'>
	validating := aBoolean
    ]

    isValidating [
	<category: 'testing'>
	^validating
    ]

    scanDocument [
	<category: 'api'>
	self subclassResponsibility
    ]

    atEnd [
	<category: 'streaming'>
	self subclassResponsibility
    ]

    documentNode [
	<category: 'private'>
	^self document
    ]

    expected: string [
	<category: 'private'>
	self malformed: '%1 expected, but not found' % {string}
    ]

    expectedWhitespace [
	<category: 'private'>
	self malformed: 'White space expected but not found'
    ]

    invalid: aMessage [
	<category: 'private'>
	sax nonFatalError: (InvalidSignal new messageText: aMessage)
    ]

    malformed: aMessage [
	<category: 'private'>
	sax fatalError: (MalformedSignal new messageText: aMessage)
    ]

    warn: aMessage [
	<category: 'private'>
	sax warning: (WarningSignal new messageText: aMessage)
    ]

    declaredStandalone: aBoolean [
	<category: 'flags'>
	^aBoolean 
	    ifTrue: [flags := flags bitOr: 2]
	    ifFalse: [flags := flags bitAnd: 2 bitInvert]
    ]

    flagsComment [
	"The 'flags' instance variable is an integer used
	 as a bit vector of boolean values, either recording
	 state as processing occurs, or recording options
	 that control how the processor is used. The following
	 documents which bits have been assigned and for
	 which purpose.
	 
	 State bits [0..15]
	 1 -- document has standalone='yes' declaration
	 2 -- document has a DTD
	 3 -- document has an externalDTD
	 4 -- document uses parameter entity references to define part of the DTD
	 
	 Option bits [16..29]
	 16 -- do namespace attributes
	 17 -- pass namespace declarations on to the client
	 "

	<category: 'flags'>
	^self commentOnly
    ]

    hasDTD [
	<category: 'flags'>
	^(flags bitAnd: 4) = 4
    ]

    hasExternalDTD [
	<category: 'flags'>
	^(flags bitAnd: 8) = 8
    ]

    isDeclaredStandalone [
	<category: 'flags'>
	^(flags bitAnd: 2) = 2
    ]

    noteDTD [
	<category: 'flags'>
	flags := flags bitOr: 4
    ]

    noteExternalDTD [
	<category: 'flags'>
	flags := flags bitOr: 8
    ]

    notePEReference [
	<category: 'flags'>
	flags := flags bitOr: 16
    ]

    processNamespaces [
	<category: 'flags'>
	^(flags bitAnd: 65536) = 65536
    ]

    processNamespaces: aBoolean [
	<category: 'flags'>
	^aBoolean 
	    ifTrue: [flags := flags bitOr: 65536]
	    ifFalse: [flags := flags bitAnd: 65536 bitInvert]
    ]

    showNamespaceDeclarations [
	<category: 'flags'>
	^(flags bitAnd: 131072) = 131072
    ]

    showNamespaceDeclarations: aBoolean [
	<category: 'flags'>
	^aBoolean 
	    ifTrue: [flags := flags bitOr: 131072]
	    ifFalse: [flags := flags bitAnd: 131072 bitInvert]
    ]

    usesParameterEntities [
	<category: 'flags'>
	^(flags bitAnd: 16) = 16
    ]

    atFeature: aURIstring [
	<category: 'SAX accessing'>
	aURIstring = SAXValidate ifTrue: [^self isValidating].
	aURIstring = SAXNamespace ifTrue: [^self processNamespaces].
	aURIstring = SAXNamespacePrefixes 
	    ifTrue: [^self showNamespaceDeclarations].
	aURIstring = SAXExternalGeneralEntities 
	    ifTrue: [^SAXNotSupportedException signal].
	aURIstring = SAXExternalParameterEntities 
	    ifTrue: [^SAXNotSupportedException signal].
	SAXNotRecognizedException new signal
    ]

    atFeature: aURIstring put: aBoolean [
	<category: 'SAX accessing'>
	aURIstring = SAXValidate ifTrue: [^self validate: aBoolean].
	aURIstring = SAXNamespace ifTrue: [^self processNamespaces: aBoolean].
	aURIstring = SAXNamespacePrefixes 
	    ifTrue: [^self showNamespaceDeclarations: aBoolean].
	aURIstring = SAXExternalGeneralEntities 
	    ifTrue: [^SAXNotSupportedException signal].
	aURIstring = SAXExternalParameterEntities 
	    ifTrue: [^SAXNotSupportedException signal].
	SAXNotRecognizedException new signal
    ]

    atProperty: aURIstring [
	<category: 'SAX accessing'>
	SAXNotRecognizedException new signal
    ]

    atProperty: aURIstring put: anObject [
	<category: 'SAX accessing'>
	SAXNotRecognizedException new signal
    ]

    contentHandler [
	<category: 'SAX accessing'>
	^sax contentHandler
    ]

    contentHandler: aSAXDriver [
	<category: 'SAX accessing'>
	| newSax |
	newSax := sax class == SAXDispatcher 
		    ifTrue: [sax]
		    ifFalse: [SAXDispatcher new handlers: sax].
	newSax contentHandler: aSAXDriver.
	self saxDriver: newSax
    ]

    dtdHandler [
	<category: 'SAX accessing'>
	^sax dtdHandler
    ]

    dtdHandler: aSAXDriver [
	<category: 'SAX accessing'>
	| newSax |
	newSax := sax class == SAXDispatcher 
		    ifTrue: [sax]
		    ifFalse: [SAXDispatcher new handlers: sax].
	newSax dtdHandler: aSAXDriver.
	self saxDriver: newSax
    ]

    entityResolver [
	<category: 'SAX accessing'>
	^sax entityResolver
    ]

    entityResolver: aSAXDriver [
	<category: 'SAX accessing'>
	| newSax |
	newSax := sax class == SAXDispatcher 
		    ifTrue: [sax]
		    ifFalse: [SAXDispatcher new handlers: sax].
	newSax entityResolver: aSAXDriver.
	self saxDriver: newSax
    ]

    errorHandler [
	<category: 'SAX accessing'>
	^sax errorHandler
    ]

    errorHandler: aSAXDriver [
	<category: 'SAX accessing'>
	| newSax |
	newSax := sax class == SAXDispatcher 
		    ifTrue: [sax]
		    ifFalse: [SAXDispatcher new handlers: sax].
	newSax errorHandler: aSAXDriver.
	self saxDriver: newSax
    ]

    handlers: aSAXDriver [
	<category: 'SAX accessing'>
	self saxDriver: aSAXDriver
    ]

    parse: dataSource [
	<category: 'SAX accessing'>
	self on: dataSource.
	^self scanDocument
    ]

    parseElement [
	<category: 'SAX accessing'>
	self subclassResponsibility
    ]

    parseElement: dataSource [
	<category: 'SAX accessing'>
	self validate: false.
	self on: dataSource.
	^self parseElement
    ]

    parseElements [
	<category: 'SAX accessing'>
	self subclassResponsibility
    ]

    parseElements: dataSource [
	<category: 'SAX accessing'>
	self validate: false.
	self on: dataSource.
	^self parseElements
    ]
]



SAXException subclass: SAXNotRecognizedException [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>
]


Eval [
    XML
	at: #SAXExternalParameterEntities
	    put: 'http://xml.org/sax/features/external-parameter-entities';
	at: #SAXValidate put: 'http://xml.org/sax/features/validation';
	at: #SAXNamespacePrefixes
	    put: 'http://xml.org/sax/features/namespace-prefixes';
	at: #SAXNamespace put: 'http://xml.org/sax/features/namespaces';
	at: #XMLSignal put: XML.SAXException;
	at: #SAXExternalGeneralEntities
	    put: 'http://xml.org/sax/features/external-general-entities'.
]
