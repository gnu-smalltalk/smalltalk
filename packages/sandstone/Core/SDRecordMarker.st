"======================================================================
|
|   SandstoneDb.SDRecordMarker class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"




Object subclass: SDRecordMarker [
    | id className environment |
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I exist to mark a reference to another object in
    the serialized file, I''m replaced by a real object when I''m
    deserialized.  I''m basically a manually invoked proxy being
    used because getting a real proxy that inherits from ProtoObject
    to serialize seemed hurculean.'>

    asOriginalObject [
	"this needs to call cachedLoadFrom not findById in order to allow cycles in
	 the serialized graph this allows an object that references an unloaded object
	 during the loadAll to force it's load instead of failing"

	<category: 'converting'>
	| origClass |
	origClass := environment at: className.
	"I'm checking inheritsFrom: here so that any classes that used to be
	 activeRecords but aren't anymore that had serialized instances are
	 caught and return nil when resolved rather than blow up.  This happens
	 often during development when you're changing your model a lot"
	^(origClass inheritsFrom: SDActiveRecord) 
	    ifTrue: 
		[SDActiveRecord store cachedLoadOfClass: (environment at: className) from: id]
	    ifFalse: [nil]
    ]

    className [
	<category: 'accessing'>
	^className
    ]

    className: anObject [
	<category: 'accessing'>
	className := anObject
    ]

    environment [
	<category: 'accessing'>
	^environment
    ]

    environment: anObject [
	<category: 'accessing'>
	environment := anObject
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: anObject [
	<category: 'accessing'>
	id := anObject
    ]

    deservesSandstoneReferenceMark [
	<category: 'testing'>
	^false
    ]

    isSandstoneMarker [
	<category: 'testing'>
	^true
    ]
]

