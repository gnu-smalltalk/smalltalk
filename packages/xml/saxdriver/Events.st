"======================================================================
|
|   SAX event objects
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2009, Antony Blakey
| All rights reserved.
| 
| Redistribution and use in source and binary forms, with or without
| modification, are permitted provided that the following conditions
| are met:
|     * Redistributions of source code must retain the above copyright
|       notice, this list of conditions and the following disclaimer.
|     * Redistributions in binary form must reproduce the above copyright
|       notice, this list of conditions and the following disclaimer in the
|       documentation and/or other materials provided with the distribution.
|     * Neither the name of Antony Blakey nor the names of its contributors
|       may be used to endorse or promote products derived derived from
|       this software without specific prior written permission.
| 
| THIS SOFTWARE IS PROVIDED 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES,
| INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
| AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
| ANTONY BLAKEY BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
| SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
| TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
| PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
| LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
| SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|
 ======================================================================"


Object subclass: SAXEvent [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isComment [
	<category: 'testing'>
	^false
    ]

    isEndCdataSection [
	<category: 'testing'>
	^false
    ]

    isEndDoctypeDecl [
	<category: 'testing'>
	^false
    ]

    isEndDocument [
	<category: 'testing'>
	^false
    ]

    isEndDocumentFragment [
	<category: 'testing'>
	^false
    ]

    isNotationDecl [
	<category: 'testing'>
	^false
    ]

    isSkippedEntity [
	<category: 'testing'>
	^false
    ]

    isUnparsedEntityDecl [
	<category: 'testing'>
	^false
    ]

    isEndPrefixMapping [
	<category: 'testing'>
	^false
    ]

    isEndTag [
	<category: 'testing'>
	^false
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing'>
	^false
    ]

    isPI [
	<category: 'testing'>
	^false
    ]

    isPI: aString [
	<category: 'testing'>
	^false
    ]

    isProcessingInstruction [
	<category: 'testing'>
	^false
    ]

    isProcessingInstruction: aString [
	<category: 'testing'>
	^false
    ]

    isStartCdataSection [
	<category: 'testing'>
	^false
    ]

    isStartDoctypeDecl [
	<category: 'testing'>
	^false
    ]

    isStartDoctypeDecl: aString [
	<category: 'testing'>
	^false
    ]

    isStartDocument [
	<category: 'testing'>
	^false
    ]

    isStartDocumentFragment [
	<category: 'testing'>
	^false
    ]

    isStartTag [
	<category: 'testing'>
	^false
    ]

    isStartTag: aStringOrNodeTag [
	<category: 'testing'>
	^false
    ]

    isText [
	<category: 'testing'>
	^false
    ]
]



SAXEvent subclass: SAXEndCdataSection [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndCdataSection [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	
	serializer endCdataSection
    ]
]



SAXEvent subclass: SAXEndDoctypeDecl [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndDoctypeDecl [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	
	serializer endDoctypeDecl
    ]
]



SAXEvent subclass: SAXEndDocumentFragment [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndDocumentFragment [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	
	serializer endDocumentFragment
    ]
]



SAXEvent subclass: SAXEndDocument [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndDocument [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	
	serializer endDocument
    ]
]



SAXEvent subclass: SAXStartCdataSection [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isStartCdataSection [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer startCdataSection
    ]
]



SAXEvent subclass: SAXStartDocumentFragment [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isStartDocumentFragment [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer startDocumentFragment
    ]
]



SAXEvent subclass: SAXStartDocument [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isStartDocument [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer startDocument
    ]
]



SAXEvent subclass: SAXTagEvent [
    | tag |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXTagEvent class >> tag: tag [
	<category: 'instance creation'>
	^self new tag: tag
    ]

    is: tagName [
	<category: 'accessing'>
	^tag isLike: tagName
    ]

    name [
	<category: 'accessing'>
	^tag name
    ]

    namespace [
	<category: 'accessing'>
	^tag namespace
    ]

    qualifier [
	<category: 'accessing'>
	^tag qualifier
    ]

    tag [
	<category: 'accessing'>
	^tag
    ]

    tag: aNodeTag [
	<category: 'accessing'>
	tag := aNodeTag
    ]

    type [
	<category: 'accessing'>
	^tag type
    ]
]



SAXTagEvent subclass: SAXEndTag [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndTag [
	<category: 'testing'>
	^true
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing'>
	^tag isLike: aStringOrNodeTag
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' </';
	    nextPutAll: tag asString;
	    nextPutAll: '>'
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    endElement: tag namespace
	    localName: tag type
	    qName: tag asString
    ]
]



SAXTagEvent subclass: SAXStartTag [
    | attributes attrArray |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXStartTag class >> tag: tag attributesArray: a [
	<category: 'instance creation'>
	^(super tag: tag) attributesArray: a
    ]

    SAXStartTag class >> tag: tag attributes: a [
	<category: 'instance creation'>
	^(super tag: tag) attributes: a
    ]

    at: attName [
	<category: 'accessing'>
	^self at: attName
	    ifNone: 
		[SAXStructureException 
		    raiseSignal: 'Expected attribute ' , attName , ' is missing']
    ]

    at: attName ifFound: aFoundBlock ifNone: aBlock [
	<category: 'accessing'>
	attributes at: attName ifPresent: [ :value | ^aFoundBlock value: value].
	^aBlock value
    ]

    at: attName ifNone: aBlock [
	<category: 'accessing'>
	^attributes at: attName asString ifAbsent: [aBlock value]
    ]

    attributesArray [
	<category: 'accessing'>
	attrArray isNil ifTrue: [ ^self computeAttributesArray ].
	^attrArray
    ]

    attributesArray: anObject [
	<category: 'accessing'>
	attrArray := anObject.
	attributes := nil.
    ]

    attributes [
	<category: 'accessing'>
	attributes isNil ifTrue: [ ^self computeAttributes ].
	^attributes
    ]

    attributes: anObject [
	<category: 'accessing'>
	attributes := anObject.
	attrArray := nil.
    ]

    computeAttributes [
	<category: 'private'>
	attributes := LookupTable new.
	attrArray do: [ :each | attributes at: each key name put: each value ].

    ]

    computeAttributesArray [
	<category: 'private'>
	attrArray := OrderedCollection new.
	attributes keysAndValuesDo: [ :key :value |
	    attrArray add: (Attribute name: key value: value) ].
    ]

    isStartTag [
	<category: 'testing'>
	^true
    ]

    isStartTag: aStringOrNodeTag [
	<category: 'testing'>
	^tag isLike: aStringOrNodeTag
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' <';
	    nextPutAll: tag asString;
	    nextPutAll: '>'
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    startElement: tag namespace
	    localName: tag type
	    qName: tag asString
	    attributes: attrArray
    ]
]



SAXEvent subclass: SAXProcessingInstruction [
    | target data |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXProcessingInstruction class >> target: targetString data: dataString [
	<category: 'instance creation'>
	^self new target: targetString; data: dataString
    ]

    data [
	<category: 'accessing'>
	^data
    ]

    data: aString [
	<category: 'accessing'>
	data := aString
    ]

    isPI [
	<category: 'testing'>
	^true
    ]

    isPI: aString [
	<category: 'testing'>
	^target = aString
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    processingInstruction: target
	    data: data
    ]

    target [
	<category: 'accessing'>
	^target
    ]

    target: aString [
	<category: 'accessing'>
	target := aString
    ]
]



SAXEvent subclass: SAXStringEvent [
    | text from to textPart |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXStringEvent class >> text: aString [
	<category: 'instance creation'>
	^self new text: aString
    ]

    SAXStringEvent class >> text: aString from: start to: stop [
	<category: 'instance creation'>
	^self new text: aString from: start to: stop
    ]

    isText [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    characters: text
	    from: from
	    to: to
    ]

    text [
	<category: 'accessing'>
	textPart isNil ifTrue: [textPart := text copyFrom: from to: to].
	^textPart
    ]

    text: aString [
	<category: 'accessing'>
	text := textPart := aString.
	from := 1.
	to := text size.
    ]

    text: aString from: start to: stop [
	<category: 'accessing'>
	text := aString.
	from := start.
	to := stop.
	textPart := nil
    ]
]



SAXStringEvent subclass: SAXText [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isText [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    characters: text
	    from: 1
	    to: text size
    ]
]



SAXStringEvent subclass: SAXComment [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isComment [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    comment: text
	    from: 1
	    to: text size
    ]
]



SAXEvent subclass: SAXStartPrefixMapping [
    | prefix uri |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXStartPrefixMapping class >> prefix: aString uri: uriString [
	<category: 'instance creation'>
	^self new prefix: aString; uri: uriString
    ]

    isStartPrefixMapping [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    startPrefixMapping: prefix
	    uri: uri
    ]

    prefix [
	<category: 'accessing'>
	^prefix
    ]

    prefix: aString [
	<category: 'accessing'>
	prefix := aString.
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]

    uri: aString [
	<category: 'accessing'>
	uri := aString.
    ]
]



SAXEvent subclass: SAXEndPrefixMapping [
    | prefix |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXEndPrefixMapping class >> prefix: aString [
	<category: 'instance creation'>
	^self new prefix: aString
    ]

    isEndPrefixMapping [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    endPrefixMapping: prefix
    ]

    prefix [
	<category: 'accessing'>
	^prefix
    ]

    prefix: aString [
	<category: 'accessing'>
	prefix := aString.
    ]
]



SAXEvent subclass: SAXExternalDecl [
    | publicID systemID |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isNotationDecl [
	<category: 'testing'>
	^true
    ]

    publicID [
        <category: 'accessing'>
        ^publicID
    ]

    publicID: aString [
        <category: 'accessing'>
        publicID := aString
    ]

    systemID [
        <category: 'accessing'>
        ^systemID
    ]

    systemID: aString [
        <category: 'accessing'>
        systemID := aString
    ]

]



SAXExternalDecl subclass: SAXStartDoctypeDecl [
    | name hasInternalSubset |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXStartDoctypeDecl class >> name: aString publicID: pidString systemID: sidString hasInternalSubset: aBoolean [
	<category: 'instance creation'>
	^self new
	    name: aString;
	    publicID: pidString;
	    systemID: sidString;
	    hasInternalSubset: aBoolean
    ]

    isStartDoctypeDecl: aString [
	<category: 'testing'>
	^name isLike: aString
    ]

    isStartDoctypeDecl [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    startDoctypeDecl: name
	    publicID: publicID
	    systemID: systemID
	    hasInternalSubset: hasInternalSubset
    ]

    hasInternalSubset [
        <category: 'accessing'>
        ^hasInternalSubset
    ]

    hasInternalSubset: aBoolean [
        <category: 'accessing'>
        hasInternalSubset := aBoolean
    ]

    name [
        <category: 'accessing'>
        ^name
    ]

    name: aString [
        <category: 'accessing'>
        name := aString
    ]

]



SAXEvent subclass: SAXSkippedEntity [
    | name |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXSkippedEntity class >> name: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    isSkippedEntity [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    skippedEntity: name
    ]

    name [
        <category: 'accessing'>
        ^name
    ]

    name: aString [
        <category: 'accessing'>
        name := aString
    ]

]



SAXExternalDecl subclass: SAXNotationDecl [
    | name |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXNotationDecl class >> name: aString publicID: pidString systemID: sidString [
	<category: 'instance creation'>
	^self new name: aString; publicID: pidString; systemID: sidString
    ]

    isNotationDecl [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    notationDecl: name
	    publicID: publicID
	    systemID: systemID
    ]

    name [
        <category: 'accessing'>
        ^name
    ]

    name: aString [
        <category: 'accessing'>
        name := aString
    ]

]



SAXExternalDecl subclass: SAXUnparsedEntityDecl [
    | name notationName |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXUnparsedEntityDecl class >> name: aString publicID: pidString systemID: sidString notationName: notation [
	<category: 'instance creation'>
	^self new name: aString; publicID: pidString; systemID: sidString; notationName: notation
    ]

    isUnparsedEntityDecl [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    unparsedEntityDecl: name
	    publicID: publicID
	    systemID: systemID
	    notationName: notationName
    ]

    name [
        <category: 'accessing'>
        ^name
    ]

    name: aString [
        <category: 'accessing'>
        name := aString
    ]

    notationName [
        <category: 'accessing'>
        ^notationName
    ]

    notationName: aString [
        <category: 'accessing'>
        notationName := aString
    ]

]
