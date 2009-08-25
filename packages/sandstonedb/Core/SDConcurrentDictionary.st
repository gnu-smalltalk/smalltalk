"======================================================================
|
|   SandstoneDb.SDConcurrentDictionary class definition
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


"PORTING : GST doesn't seem to have Monitors. Use RecursionLock instead..."


Object subclass: SDConcurrentDictionary [
    | lock dictionary |
    
    <category: 'SandstoneDb-Core'>
    <comment: 'A SDConcurrentDictionary is just a dictionary wrapper so I can
    wrap a critical around mutating methods I need in ActiveRecord'>

    SDConcurrentDictionary class >> on: aDictionary [
	<category: 'instance creation'>
	^(self new)
	    dictionary: aDictionary;
	    yourself
    ]

   SDConcurrentDictionary class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
   ]

    , aCollection [
	<category: 'copying'>
	^lock critical: [self class on: dictionary , aCollection]
    ]

    at: aKey [
	<category: 'accessing'>
	^dictionary at: aKey
    ]

    at: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	lock critical: [^dictionary at: aKey ifAbsent: aBlock]
    ]

    at: aKey ifAbsentPut: aBlock [
	<category: 'accessing'>
	lock critical: [^dictionary at: aKey ifAbsentPut: aBlock]
    ]

    at: aKey put: aValue [
	<category: 'accessing'>
	lock critical: [^dictionary at: aKey put: aValue]
    ]

    dictionary [
	<category: 'accessing'>
	^dictionary
    ]

    dictionary: anObject [
	<category: 'accessing'>
	dictionary := anObject
    ]

    keys [
	<category: 'accessing'>
	^dictionary keys
    ]

    keysAndValuesDo: aBlock [
	<category: 'accessing'>
	^dictionary keysAndValuesDo: aBlock
    ]

    values [
	<category: 'accessing'>
	^dictionary values
    ]

    includesKey: aKey [
	<category: 'testing'>
	^dictionary includesKey: aKey
    ]

    initialize [
	<category: 'initialization'>
	"I'm using a Monitor rather than a Semaphor here because I need to support
	 reentrant operations by the same process, a Semaphor is too low level"
	lock := RecursionLock new
    ]

    removeAll [
	<category: 'removing'>
	^lock critical: [self keys copy do: [:e | self removeKey: e]]
    ]

    removeKey: aKey [
	<category: 'removing'>
	^lock critical: [dictionary removeKey: aKey]
    ]

    removeKey: aKey ifAbsent: aBlock [
	<category: 'removing'>
	^lock critical: [dictionary removeKey: aKey ifAbsent: aBlock]
    ]
]

