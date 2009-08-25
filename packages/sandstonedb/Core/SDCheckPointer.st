"======================================================================
|
|   SandstoneDb.SDCheckPointer class definition
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



Object subclass: SDCheckPointer [
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I run as a background process to ensure the database is loaded
    and periodically save the image when enough active records are found to be
    newer than the image.  This is essentially just like flushing the contents
    of a transaction log to the main database file.'>

    SDCheckPointer class >> update: aspect [
	"SDCheckPointer will act as the single agent to ensure all active record
	 subclasses are correctly initialized on start up."

	"self initialize"
	<category: 'initialization'>

	aspect == #returnFromSnapshot ifTrue: [
	    self startUp: true].
	aspect == #aboutToQuit ifTrue: [
	    self shutDown: true]
    ] 

    SDCheckPointer class >> shutDown: isDown [
	<category: 'system startup'>
	isDown 
	    ifTrue: 
		[SDActiveRecord store ensureDown.
		SDActiveRecord allSubclassesDo: [:each | each coolDown]]
    ]

    SDCheckPointer class >> startUp: isStarting [
	"Had problems reusing images from templated sites or existing sites
	 and accidently mixing old data or another db into this images data.
	 I want to ensure that any time an image starts up fresh from disk it
	 always reloads all the data; setting a fresh store on startup will
	 ensure this happens."

	<category: 'system startup'>
	SDActiveRecord store 
	    ifNil: [SDActiveRecord setStore: SDActiveRecord defaultStore]
	    ifNotNil: 
		[isStarting 
		    ifTrue: [SDActiveRecord resetStoreForLoad]].

	"Load records on a priority just higher than Seaside so db is loaded
	before requests start coming in, don't want users seeing missing data."
	
	[isStarting 
	    ifTrue: [SDActiveRecord warmUpAllClasses]] 
	    forkAt: Processor userBackgroundPriority + 1
	    "named: 'Loading sandstone'"
    ]
]

Eval [
    ObjectMemory addDependent: SDCheckPointer
]
