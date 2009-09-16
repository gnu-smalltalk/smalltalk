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
| THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
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

    isEndDocument [
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

    isStartDocument [
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



SAXEvent subclass: SAXEndDocument [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndDocument [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	
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
	^attrArray
    ]

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    attributesArray: anObject [
	<category: 'accessing'>
	attrArray := anObject.
	attributes := LookupTable new.
	attrArray do: [ :each | attributes at: each key name put: each value ].

    ]

    attributes: anObject [
	<category: 'accessing'>
	attributes := anObject.
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



SAXEvent subclass: SAXText [
    | text |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    SAXText class >> text: aString [
	<category: 'instance creation'>
	^self new text: aString
    ]

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

    text [
	<category: 'accessing'>
	^text
    ]

    text: aString [
	<category: 'accessing'>
	text := aString
    ]
]
