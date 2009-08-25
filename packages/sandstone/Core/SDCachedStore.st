"======================================================================
|
|   SandstoneDb.SDCachedStore class definition
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



SDAbstractStore subclass: SDCachedStore [
    
    <comment: nil>
    <category: 'SandstoneDb-Core'>

    addCachedOfClass: aClass at: anId put: anObject [
	<category: 'actions'>
	
    ]

    cachedLoadOfClass: aClass from: anId [
	<category: 'actions'>
	self subclassResponsibility
    ]

    removeCachedOfClass: aClass from: anId [
	<category: 'actions'>
	
    ]

    familyForClass: aClass [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass [
	<category: 'delegated queries'>
	^self familyForClass: aClass
    ]

    forClass: aClass at: anId ifAbsent: aHandler [
	<category: 'delegated queries'>
	^(self familyForClass: aClass) at: anId ifAbsent: aHandler
    ]

    forClass: aClass detect: aBlock ifFound: aHandler [
	<category: 'delegated queries'>
	^((self forClass: aClass) detect: aBlock ifNone: [nil]) 
	    ifNotNilDo: aHandler
    ]

    forClass: aClass detect: aBlock ifNone: aHandler [
	<category: 'delegated queries'>
	^(self forClass: aClass) detect: aBlock ifNone: aHandler
    ]

    forClass: aClass do: aBlock [
	<category: 'delegated queries'>
	(self forClass: aClass) do: aBlock
    ]

    forClass: aClass findAll: aBlock [
	<category: 'delegated queries'>
	^(self forClass: aClass) select: aBlock
    ]
]

