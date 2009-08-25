"======================================================================
|
|   SandstoneDb.SDFileStoreTest class definition
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



SDActiveRecordTest subclass: SDFileStoreTest [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>

    SDFileStoreTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    defaultStore [
	<category: 'defaults'>
	^SDFileStore new
    ]

    testDeleteFailedCommits [
	<category: 'running'>
	kid save.
	((store dirForClass: kid class atId: kid id) at: kid id , '.obj.new') touch.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists.
	store deleteFailedCommitsForClass: kid class.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self deny: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists
    ]

    testDeleteOldVersions [
	<category: 'running'>
	| id |
	kid save.
	kid save.
	id := kid id.
	kid delete.
	self 
	    assert: ((store dirForClass: kid class atId: id) 
		    filesMatching: id , '\.*') isEmpty
    ]

    testFinishPartialCommits [
	<category: 'running'>
	kid save.
	((store dirForClass: kid class atId: kid id) at: kid id , '.obj')
	    renameTo: ((store dirForClass: kid class atId: kid id) at: kid id , '.obj.new') name.
	self deny: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists.
	store finishPartialCommitsForClass: kid class.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self deny: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists
    ]

    testLoadMissingFile [
	<category: 'running'>
	kid save.
	((store dirForClass: kid class atId: kid id) at: kid id, '.obj') remove. 
	self should: [store loadClass: kid class atId: kid id] raise: SDLoadError
    ]

    testLoadTime [
	<category: 'running'>
	| commitTime people lookupTime loadTime |
	people := (1 to: 100) collect: [:it | SDPersonMock testPerson].
	commitTime := Time millisecondsToRun: [people do: [:each | each save]].
	lookupTime := Time millisecondsToRun: [people do: [:each | SDPersonMock atId: each id]].
	loadTime := Time millisecondsToRun:
	[SDActiveRecord resetStoreForLoad.
	SDActiveRecord warmUpAllClasses].
	"Transcript
	    show: commitTime printString;
	    cr;
	    show: loadTime printString;
	    cr;
	    cr."
	self assert: commitTime < (4*1000) "seconds"
    ]

    testSaveMissingFile [
	<category: 'running'>
	self assert: kid isNew.
	kid save.
	self deny: kid isNew.
	((store dirForClass: kid class atId: kid id) at: kid id , '.obj') remove.
	kid save.
	self deny: kid isNew
    ]

    testStorageDir [
	"Active records id's must find a proper subdirectory entry in the defined structure"

	<category: 'running'>
	| ids legalNames |
	legalNames := (0 to: 9) collect: [:e | e printString].
	ids := Set new: 1000.
	1000 timesRepeat: [ids add: UUID new printString].
	ids add: 'abaoblwgnaydxokccorveamoq'.
	ids do: 
		[:anId | 
		self assert: (legalNames 
			includes: (store dirForClass: SDPersonMock atId: anId) stripPath)]
    ]
]

