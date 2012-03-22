"======================================================================
|
|   PackageLoader Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2004,2005,2007,2008,2009
| Free Software Foundation, Inc.
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
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Namespace current: Kernel [

Notification subclass: PackageSkip [
    
    <category: 'Language-Packaging'>
    <comment: nil>
]

]



Namespace current: SystemExceptions [

NotFound subclass: PackageNotAvailable [
    
    <category: 'Language-Packaging'>
    <comment: nil>

    PackageNotAvailable class >> signal: aString [
	"Signal an exception saying that the package named aString
	 can't be found."
	^super signalOn: aString what: 'package'
    ]

    PackageNotAvailable class >> signal: package reason: reason [
	"Signal an exception saying that be package named package
	 can't be found because the reason named reason."
	^super signalOn: package reason: reason
    ]

    isResumable [
        "Answer true.  Package unavailability is resumable, because the
	 package files might just lie elsewhere."

        <category: 'description'>
        ^true
    ]
]

]



Namespace current: Kernel [

Object subclass: PackageGroup [
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    printOn: aStream [
	"Print the XML source code for the information that the PackageLoader
	 holds on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: '<packages>';
	    nl.
	self do: 
		[:each | 
		aStream space: 2.
		each printOn: aStream indent: 2.
		aStream nl]
	    separatedBy: [aStream nl].
	aStream nextPutAll: '</packages>'
    ]

    at: aString [
	<category: 'accessing'>
	^self at: aString
	    ifAbsent: [SystemExceptions.PackageNotAvailable signal: aString]
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    do: aBlock [
	<category: 'accessing'>
	self keys do: [:each | aBlock value: (self at: each)]
    ]

    do: aBlock separatedBy: sepBlock [
	<category: 'accessing'>
	self keys do: [:each | aBlock value: (self at: each)] separatedBy: sepBlock
    ]

    keys [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    includesKey: aString [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    extractDependenciesFor: packagesList ifMissing: aBlock [
	"Answer an OrderedCollection containing all the packages which you
	 have to load to enable the packages in packagesList, in an appropriate
	 order. For example
	 
	 PackageLoader extractDependenciesFor: #('BloxTestSuite' 'Blox' 'Browser')
	 
	 on a newly built image will evaluate to an OrderedCollection containing
	 'Kernel', 'Blox', 'BloxTestSuite' and 'Browser'. Note that
	 Blox has been moved before BloxTestSuite.
	 Pass an error message to aBlock if one or more packages need
	 prerequisites which are not available."

	<category: 'accessing'>
	| toBeLoaded featuresFound dependencies allPrereq allFeatures |
	featuresFound := Set withAll: Smalltalk.Features.
	featuresFound := featuresFound collect: [:each | each asString].
	toBeLoaded := packagesList asOrderedCollection.
	toBeLoaded := toBeLoaded collect: [:each | each asString].
	toBeLoaded removeAll: featuresFound ifAbsent: [:doesNotMatter | ].
	dependencies := packagesList collect: [:each | each asString].
	
	[allPrereq := Set new.
	allFeatures := Set new.
	dependencies do: 
		[:name | 
		| package |
		(featuresFound includes: name) 
		    ifFalse: 
			[package := self at: name ifAbsent: [^aBlock value: name].
			allPrereq addAll: package prerequisites.
			allFeatures addAll: package features]].

	"I don't think there will never be lots of packages in newDep (say
	 more than 5), so I think it is acceptable to remove duplicates
	 this naive way.  Note that we remove duplicates from toBeLoaded
	 so that prerequisites are always loaded *before*."
	toBeLoaded removeAll: allPrereq ifAbsent: [:doesNotMatter | ].
	toBeLoaded removeAll: allFeatures ifAbsent: [:doesNotMatter | ].
	allPrereq removeAll: allFeatures ifAbsent: [:doesNotMatter | ].
	featuresFound addAll: allFeatures.
	toBeLoaded addAllFirst: allPrereq.

	"Proceed recursively with the prerequisites for allPrereq"
	dependencies := allPrereq.
	dependencies notEmpty] 
		whileTrue.
	^toBeLoaded
    ]

    refresh [
	<category: 'accessing'>
	self refresh: ##(Date 
		    newDay: 1
		    month: #jan
		    year: 1900)
    ]

    refresh: aLoadDate [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]

]



Namespace current: Kernel [

PackageGroup subclass: PackageDirectories [
    | dirs |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    PackageDirectories class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    postCopy [
	<category: 'copying'>
	dirs := dirs copy
    ]

    add: aDirectory [
	<category: 'accessing'>
	^dirs add: aDirectory
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>
	dirs do: 
		[:each | 
		| package |
		package := each at: aString ifAbsent: [nil].
		package isNil ifFalse: [^package]].
	^aBlock value
    ]

    keys [
	<category: 'accessing'>
	| keys |
	keys := Set new.
	dirs do: [:each | keys addAll: each keys].
	^keys
    ]

    includesKey: aString [
	<category: 'accessing'>
	^dirs anySatisfy: [:each | each includesKey: aString]
    ]

    refresh: aLoadDate [
	<category: 'accessing'>
	dirs do: [:each | each refresh: aLoadDate]
    ]

    initialize [
	<category: 'initializing'>
	dirs := OrderedCollection new
    ]
]

]



Namespace current: Kernel [

PackageGroup subclass: PackageContainer [
    | packages file |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    file [
	<category: 'accessing'>
	^file
    ]

    fileName [
	<category: 'accessing'>
	^self file name
    ]

    file: aFile [
	<category: 'accessing'>
	file := aFile
    ]

    packages [
	<category: 'accessing'>
	packages isNil ifTrue: [packages := LookupTable new].
	^packages
    ]

    packages: aDictionary [
	<category: 'accessing'>
	packages := aDictionary
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>
	^self packages at: aString asString ifAbsent: aBlock
    ]

    keys [
	<category: 'accessing'>
	^self packages keys
    ]

    includesKey: aString [
	<category: 'accessing'>
	^self packages includesKey: aString
    ]

    baseDirectoriesFor: aPackage [
	<category: 'refreshing'>
	self subclassResponsibility
    ]

    refresh: loadDate [
	"Private - Process the XML source in the packages file, creating
	 Package objects along the way."

	<category: 'refreshing'>
	self subclassResponsibility
    ]

    parse: file [
	<category: 'refreshing'>
	| open ch cdata tag package allPackages |
	open := false.
	allPackages := OrderedCollection new.
	
	[cdata := cdata isNil 
		    ifTrue: [file upTo: $<]
		    ifFalse: [cdata , (file upTo: $<)].
	file atEnd] 
		whileFalse: 
		    [cdata trimSeparators isEmpty 
			ifFalse: [^self error: 'unexpected character data'].
		    ch := file peek.
		    ch == $! ifTrue: [file skipTo: $>].
		    ch == $/ 
			ifTrue: 
			    [file next.
			    (tag := file upTo: $>) = 'packages' ifTrue: [^self].
			    ^self error: 'unmatched end tag ' , tag].
		    ch isAlphaNumeric 
			ifTrue: 
			    [open 
				ifFalse: 
				    [tag := file upTo: $>.
				    tag = 'package' 
					ifTrue: [package := Package new parse: file tag: 'package']
					ifFalse: 
					    [tag = 'packages' ifFalse: [^self error: 'expected packages tag'].
					    open := true]]
				ifTrue: 
				    [file skip: -1.
				    package := Package parse: file].
			    package notNil 
				ifTrue: 
				    [package name isNil 
					ifTrue: [^self error: 'missing package name in ' , self fileName].
				    
				    [self testPackageValidity: package.
				    self packages at: package name put: package.
				    allPackages add: package] 
					    on: PackageSkip
					    do: [:ex | ex return].
				    open ifFalse: [^allPackages]].
			    package := nil]].
	^allPackages
    ]

    testPackageValidity: package [
	package baseDirectories: (self baseDirectoriesFor: package).
    ]
]

]

Namespace current: Kernel [

PackageContainer subclass: PackageDirectory [
    | baseDirectories baseDirCache |

    <category: 'Language-Packaging'>

    PackageContainer class >> on: aFile baseDirectories: aBlock [
	<category: 'accessing'>
	^(super new)
	    file: aFile;
	    baseDirectories: aBlock
    ]

    baseDirectoriesFor: aPacakge [
	<category: 'accessing'>
	baseDirCache isNil ifTrue: [self refresh].
	^baseDirCache
    ]

    baseDirectories: aBlock [
	<category: 'accessing'>
	baseDirectories := aBlock
    ]

    refresh: loadDate [
	"Private - Process the XML source in the packages file, creating
	 Package objects along the way."

	| dir allDirs |
	dir := self file parent.
	allDirs := Smalltalk imageLocal 
		    ifTrue: [{Directory image} , baseDirectories value]
		    ifFalse: [baseDirectories value].
	((self file exists and: [self file lastModifyTime > loadDate]) or: 
		[(dir exists and: [dir lastModifyTime > loadDate]) 
		    or: [allDirs ~= baseDirCache]]) 
	    ifTrue: 
		[baseDirCache := allDirs.
		self refreshPackageList.
		self refreshStarList: dir]
    ]

    refreshPackageList [
	<category: 'refreshing'>
	baseDirCache isEmpty ifTrue: [^self].
	self file exists ifFalse: [^self].
       self file withReadStreamDo: [ :fileStream |
           [self parse: fileStream]
               on: SystemExceptions.PackageNotAvailable
               do: [:ex | ex resignalAs: PackageSkip new]].
 
       self packages: (self packages reject: [:each | each isDisabled])
    ]
    refreshStarList: dir [
	<category: 'refreshing'>
	dir exists ifFalse: [^self].
	dir filesMatching: '*.star'
	    do: 
		[:starFile | 
		| package |
		package := Kernel.StarPackage file: starFile.
		self packages at: package name put: package]
    ]
]

]



Namespace current: Kernel [

Object subclass: PackageInfo [
    | name |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    createNamespace [
	"Create the path of namespaces indicated by our namespace field in
	 dot notation, and answer the final namespace"

	<category: 'accessing'>
	| ns |
	ns := Smalltalk.
	self namespace isNil ifTrue: [^ns].
	(self namespace subStrings: $.) do: 
		[:each | 
		| key |
		key := each asSymbol.
		(ns includesKey: key) ifFalse: [ns addSubspace: key].
		ns := ns at: key].
	^ns
    ]

    fileIn [
	"File in the given package and its dependencies."

	<category: 'accessing'>
	self name isNil 
	    ifTrue: 
		["Other packages cannot be dependent on this one."

		PackageLoader fileInPackages: self prerequisites.
		self primFileIn]
	    ifFalse: [PackageLoader fileInPackage: self name]
    ]

    fullPathsOf: aCollection [
	"Resolve the names in aCollection according to the base directories
	 in baseDirectories, and return the collection with the FilePaths.
	 Raise a PackageNotAvailable exception if no directory was found for one
	 or more files in aCollection."

	<category: 'accessing'>
	^aCollection collect: 
		[:fileName | self fullPathOf: fileName]
    ]

    / fileName [
	"Resolve the file name according to the base directories in
	 baseDirectories, and return a FilePath for the full filename.
	 Raise a PackageNotAvailable exception if no directory was found
	 for fileName."

	<category: 'accessing'>
	^self fullPathOf: fileName
    ]

    fullPathOf: fileName [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    isDisabled [
	<category: 'accessing'>
	^false
    ]

    printXmlOn: aStream collection: aCollection tag: aString indent: indent [
	"Private - Print aCollection on aStream as a sequence of aString
	 tags."

	<category: 'accessing'>
	aCollection do: 
		[:each | 
		aStream
		    nextPutAll: '  <';
		    nextPutAll: aString;
		    nextPut: $>;
		    nextPutAll: each;
		    nextPutAll: '</';
		    nextPutAll: aString;
		    nextPut: $>;
		    nl;
		    space: indent]
    ]

    printOn: aStream [
	<category: 'accessing'>
	self printOn: aStream indent: 0
    ]

    printOn: aStream indent: indent [
	<category: 'accessing'>
	self 
	    printOn: aStream
	    tag: 'package'
	    indent: indent
    ]

    printOn: aStream tag: tag indent: indent [
	"Print a representation of the receiver on aStream (it happens
	 to be XML."

	<category: 'accessing'>
	aStream
	    nextPut: $<;
	    nextPutAll: tag;
	    nextPut: $>;
	    nl;
	    space: indent.
	self name isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '  <name>';
		    nextPutAll: self name;
		    nextPutAll: '</name>';
		    nl;
		    space: indent].
	self url isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '  <url>';
		    nextPutAll: self url;
		    nextPutAll: '</url>';
		    nl;
		    space: indent].
	self namespace isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '  <namespace>';
		    nextPutAll: self namespace;
		    nextPutAll: '</namespace>';
		    nl;
		    space: indent].
	self test isNil 
	    ifFalse: 
		[aStream space: 2.
		self test 
		    printOn: aStream
		    tag: 'test'
		    indent: indent + 2.
		aStream
		    nl;
		    space: indent].
	self 
	    printXmlOn: aStream
	    collection: self features asSortedCollection
	    tag: 'provides'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: self prerequisites asSortedCollection
	    tag: 'prereq'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: self sunitScripts
	    tag: 'sunit'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: self callouts asSortedCollection
	    tag: 'callout'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: self libraries asSortedCollection
	    tag: 'library'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: self modules asSortedCollection
	    tag: 'module'
	    indent: indent.
	self relativeDirectory isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '  <directory>';
		    nextPutAll: self relativeDirectory;
		    nextPutAll: '</directory>';
		    nl;
		    space: indent].
	self files size + self builtFiles size > 1 
	    ifTrue: 
		[aStream
		    nl;
		    space: indent].
	self 
	    printXmlOn: aStream
	    collection: self fileIns
	    tag: 'filein'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: (self files copy removeAll: self fileIns ifAbsent: []; yourself)
	    tag: 'file'
	    indent: indent.
	self 
	    printXmlOn: aStream
	    collection: self builtFiles
	    tag: 'built-file'
	    indent: indent.
	self startScript isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '  <start>';
		    nextPutAll: self startScript;
		    nextPutAll: '</start>';
		    nl;
		    space: indent].
	self stopScript isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '  <stop>';
		    nextPutAll: self stopScript;
		    nextPutAll: '</stop>';
		    nl;
		    space: indent].
	aStream
	    nextPutAll: '</';
	    nextPutAll: tag;
	    nextPut: $>
    ]

    name [
	"Answer the name of the package."

	<category: 'accessing'>
	^name
    ]

    name: aString [
	"Set to aString the name of the package."

	<category: 'accessing'>
	name := aString
    ]

    url [
	"Answer the URL at which the package repository can be found."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    namespace [
	"Answer the namespace in which the package is loaded."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    features [
	"Answer a (modifiable) Set of features provided by the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    prerequisites [
	"Answer a (modifiable) Set of prerequisites."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    builtFiles [
	"Answer a (modifiable) OrderedCollection of files that are part of
	 the package but are not distributed."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    files [
	"Answer a (modifiable) OrderedCollection of files that are part of
	 the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    allFiles [
	"Answer an OrderedCollection of all the files, both built and
	 distributed, that are part of the package."

	<category: 'accessing'>
	| result |
	result := self files , self builtFiles.
	self test isNil 
	    ifFalse: 
		[result := result , (self test allFiles: self test relativeDirectory)].
	^result
    ]

    allDistFiles [
	"Answer an OrderedCollection of all the files, both built and
	 distributed, that are part of the package."

	<category: 'accessing'>
	| result |
	result := self files.
	self test isNil 
	    ifFalse: 
		[result := result , (self test allDistFiles: self test relativeDirectory)].
	^result
    ]

    fileIns [
	"Answer a (modifiable) OrderedCollections of files that are to be
	 filed-in to load the package.  This is usually a subset of
	 `files' and `builtFiles'."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    libraries [
	"Answer a (modifiable) Set of shared library names
	 that are required to load the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    modules [
	"Answer a (modifiable) Set of modules that are
	 required to load the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    sunitScript [
	"Answer a String containing a SUnit script that
	 describes the package's test suite."

	<category: 'accessing'>
	self sunitScripts isEmpty ifTrue: [^''].
	^self sunitScripts fold: [:a :b | a , ' ' , b]
    ]

    sunitScripts [
	"Answer a (modifiable) OrderedCollection of SUnit scripts that
	 compose the package's test suite."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    startScript [
	"Answer the start script for the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    stopScript [
	"Answer the stop script for the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    callouts [
	"Answer a (modifiable) Set of call-outs that are required to load
	 the package.  Their presence is checked after the libraries and
	 modules are loaded so that you can do a kind of versioning."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    relativeDirectory [
	"Answer the directory from which to load the package, relative to the package
	 file."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    directory [
	"Answer the base directory from which to load the package."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    loaded [
	<category: 'accessing'>
	^self name notNil and: [Smalltalk hasFeatures: self name]
    ]

    start [
	"File in the receiver and evaluate its start script, passing nil
	 as the argument."

	<category: 'accessing'>
	self fileIn.
	self startScript isNil ifTrue: [ ^self ].
	('Eval [',
	    (self startScript % {'nil'}),
	']') readStream fileIn.
    ]

    start: anObject [
	"File in the receiver and evaluate its start script, passing anObject's
	 displayString as the argument."

	<category: 'accessing'>
	self fileIn.
	self startScript isNil ifTrue: [ ^self ].
	('Eval [',
	    (self startScript % { anObject displayString storeString }),
	']') readStream fileIn.
    ]

    stop [
	"Evaluate the stop script of the receiver, passing nil as the
	 argument."

	<category: 'accessing'>
	self loaded ifFalse: [ ^self ].
	self stopScript isNil ifTrue: [ ^self ].
	('Eval [',
	    (self stopScript % {'nil'}),
	']') readStream fileIn.
    ]

    stop: anObject [
	"Evaluate the stop script of the receiver, passing anObject's
	 displayString as the argument."

	<category: 'accessing'>
	self loaded ifFalse: [ ^self ].
	self stopScript isNil ifTrue: [ ^self ].
	('Eval [',
	    (self stopScript % { anObject displayString storeString }),
	']') readStream fileIn.
    ]

    allFiles: prefix [
	<category: 'private - subpackages'>
	prefix isNil ifTrue: [^self allFiles].
	^self allFiles collect: [:each | File append: each to: prefix]
    ]

    allDistFiles: prefix [
	<category: 'private - subpackages'>
	prefix isNil ifTrue: [^self allDistFiles].
	^self allDistFiles collect: [:each | File append: each to: prefix]
    ]
]

]



Namespace current: Kernel [

PackageInfo subclass: StarPackage [
    | file loadedPackage |
    
    <category: 'Language-Packaging'>
    <comment: nil>

    StarPackage class >> file: file [
	<category: 'accessing'>
	^(self new)
	    file: file;
	    name: (File stripPathFrom: (File stripExtensionFrom: file name));
	    yourself
    ]

    fullPathOf: fileName [
	"Try appending 'self directory' and fileName to each of the directory
	 in baseDirectories, and return the path to the first tried filename that
	 exists.  Raise a PackageNotAvailable exception if no directory is
	 found that contains the file."

	<category: 'accessing'>
	^self loadedPackage fullPathOf: fileName
    ]

    test [
	"Answer the test subpackage for this package."

	<category: 'accessing'>
	^self loadedPackage test
    ]

    url [
	"Answer the URL at which the package repository can be found."

	<category: 'accessing'>
	^self loadedPackage url
    ]

    namespace [
	"Answer the namespace in which the package is loaded."

	<category: 'accessing'>
	^self loadedPackage namespace
    ]

    features [
	"Answer a (modifiable) Set of features provided by the package."

	<category: 'accessing'>
	^self loadedPackage features
    ]

    prerequisites [
	"Answer a (modifiable) Set of prerequisites."

	<category: 'accessing'>
	^self loadedPackage prerequisites
    ]

    builtFiles [
	"Answer a (modifiable) OrderedCollection of files that are part of
	 the package but are not distributed."

	<category: 'accessing'>
	^self loadedPackage builtFiles
    ]

    files [
	"Answer a (modifiable) OrderedCollection of files that are part of
	 the package."

	<category: 'accessing'>
	^self loadedPackage files
    ]

    fileIns [
	"Answer a (modifiable) OrderedCollections of files that are to be
	 filed-in to load the package.  This is usually a subset of
	 `files' and `builtFiles'."

	<category: 'accessing'>
	^self loadedPackage fileIns
    ]

    libraries [
	"Answer a (modifiable) Set of shared library names
	 that are required to load the package."

	<category: 'accessing'>
	^self loadedPackage libraries
    ]

    modules [
	"Answer a (modifiable) Set of modules that are
	 required to load the package."

	<category: 'accessing'>
	^self loadedPackage modules
    ]

    startScript [
	"Answer the start script for the package."

	<category: 'accessing'>
	^self loadedPackage startScript
    ]

    stopScript [
	"Answer the stop script for the package."

	<category: 'accessing'>
	^self loadedPackage stopScript
    ]

    sunitScripts [
	"Answer a (modifiable) OrderedCollection of SUnit scripts that
	 compose the package's test suite."

	<category: 'accessing'>
	^self loadedPackage sunitScripts
    ]

    callouts [
	"Answer a (modifiable) Set of call-outs that are required to load
	 the package.  Their presence is checked after the libraries and
	 modules are loaded so that you can do a kind of versioning."

	<category: 'accessing'>
	^self loadedPackage callouts
    ]

    relativeDirectory [
	<category: 'accessing'>
	^nil
    ]

    directory [
	<category: 'accessing'>
	^(File name: self fileName) zip
    ]

    file [
	<category: 'accessing'>
	^file
    ]

    fileName [
	<category: 'accessing'>
	^self file name
    ]

    file: aFile [
	<category: 'accessing'>
	file := aFile
    ]

    primFileIn [
	<category: 'accessing'>
	self loadedPackage primFileIn
    ]

    loadedPackage [
	<category: 'accessing'>
	| file package |
	loadedPackage isNil ifFalse: [^loadedPackage].
	package := self file zip / 'package.xml'
		withReadStreamDo: [ :fileStream | Package parse: fileStream].
	package isNil 
	    ifTrue: [^self error: 'invalid disabled-package tag inside a star file'].
	package relativeDirectory: self relativeDirectory.
	package baseDirectories: {self directory}.
	package name isNil 
	    ifTrue: [package name: self name]
	    ifFalse: 
		[package name = self name 
		    ifFalse: [self error: 'invalid package name in package.xml']].
	loadedPackage := package.
	^loadedPackage
    ]
]

]






Namespace current: Kernel [

Object subclass: Version [
    | major minor patch |

    <category: 'Language-Packaging'>

    Version class >> fromString: aString [
	<category: 'instance creation'>

	| result |
	result := aString searchRegex: '^(\d+)\.(\d+)(?:\.(\d+))?' .
        result ifNotMatched: [
            self error: 'Bad version format ', aString, ' should be xx.yy(.zz)'.
            ^ nil ].

	^ self
            major: (result at: 1) asInteger
            minor: (result at: 2) asInteger
            patch: ((result at: 3) ifNil: [ 0 ]) asInteger
    ]

    Version class >> major: major minor: minor patch: patch [
	<category: 'instance creation'>

       ^ self new
               major: major minor: minor patch: patch
    ]

    major: major minor: minor patch: patch [
       <category: 'initialization'>

       self 
           major: major;
           minor: minor;
           patch: patch
    ]

    major [
       <category: 'accessing'>

       ^ major
    ]

    major: anInteger [
       <category: 'accessing'>

       major := anInteger
    ]

    minor [
       <category: 'accessing'>

       ^ minor
    ]

    minor: anInteger [
       <category: 'accessing'>

       minor := anInteger
    ]

    patch [
       <category: 'accessing'>

       ^ patch
    ]

    patch: anInteger [
       <category: 'accessing'>

       patch := anInteger
    ]
]
]


Kernel.PackageInfo subclass: Package [
    | features prerequisites builtFiles files fileIns relativeDirectory
       baseDirectories libraries modules callouts url namespace sunitScripts
       startScript stopScript test version |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    Package class [ | Tags | ]

    Package class >> tags [
       <category: 'accessing'>

       ^ Tags ifNil: [ Tags := Dictionary from: {      
                        'file' -> #addFile:.
                        'filein' -> #addFileIn:.
                       'prereq' -> #addPrerequisite:.
                        'provides' -> #addFeature:.
                        'module' -> #addModule:.
                        'directory' -> #relativeDirectory:.
                        'name' -> #name:.
                        'url' -> #url:.
                        'version' -> #parseVersion:.
                        'namespace' -> #namespace:.
                        'library' -> #addLibrary:.
                        'built-file' -> #addBuiltFile:.
                        'sunit' -> #addSunitScript:.
                        'start' -> #startScript:.
                        'stop' -> #stopScript:.
                        'callout' -> #addCallout: } ]
    ]

    Package class >> parse: file [
       "Answer a package from the XML description in file."
       <category: 'instance creation'>
	| ch tag |
	
	[(file upTo: $<) trimSeparators isEmpty 
	    ifFalse: [self error: 'unexpected cdata'].
	file atEnd ifTrue: [self error: 'expected start tag'].
	ch := file peek.
	ch == $! ifTrue: [file skipTo: $>].
	ch == $/ ifTrue: [self error: 'unexpected end tag '].
	ch isAlphaNumeric 
	    ifTrue: 
		[tag := file upTo: $>.
		tag = 'package' ifTrue: [^Package new parse: file tag: tag].
		tag = 'disabled-package' 
		    ifTrue: [^DisabledPackage new parse: file tag: tag]]] 
		repeat
    ]

    test [
	"Answer the test sub-package."

	<category: 'accessing'>
	^test
    ]

    test: aPackage [
	"Set the test sub-package to be aPackage."

	<category: 'accessing'>
	aPackage test isNil 
	    ifFalse: [self error: 'test packages must not be nested'].
	aPackage name isNil 
	    ifFalse: [self error: 'test package must not have names'].
	(aPackage prerequisites)
	    add: 'SUnit';
	    add: self name.
	aPackage owner: self.
	test := aPackage
    ]

    startScript [
	"Answer the start script for the package."

	<category: 'accessing'>
	^startScript
    ]

    startScript: aString [
	"Set the start script for the package to aString."

	<category: 'accessing'>
	startScript := aString
    ]

    stopScript [
	"Answer the start script for the package."

	<category: 'accessing'>
	^stopScript
    ]

    stopScript: aString [
	"Set the stop script for the package to aString."

	<category: 'accessing'>
	stopScript := aString
    ]

    url [
	"Answer the URL at which the package repository can be found."

	<category: 'accessing'>
	^url
    ]

    url: aString [
	"Set to aString the URL at which the package repository can be found."

	<category: 'accessing'>
	url := aString
    ]

    namespace [
	"Answer the namespace in which the package is loaded."

	<category: 'accessing'>
	^namespace
    ]

    namespace: aString [
	"Set to aString the namespace in which the package is loaded."

	<category: 'accessing'>
       namespace := aString
    ]

    addFeature: aString [
       <category: 'accessing'>

       self features add: aString
    ]

    features [
       "Answer a (modifiable) Set of features provided by the package."

	<category: 'accessing'>
	features isNil ifTrue: [features := Set new].
       ^features
    ]

    addPrerequisite: aString [
       <category: 'accessing'>

       self prerequisites add: aString
    ]

    prerequisites [
       "Answer a (modifiable) Set of prerequisites."

	<category: 'accessing'>
	prerequisites isNil ifTrue: [prerequisites := Set new].
       ^prerequisites
    ]

    addBuiltFile: aString [
       <category: 'accessing'>

       self builtFiles add: aString
    ]

    builtFiles [
       "Answer a (modifiable) OrderedCollection of files that are part of
        the package but are not distributed."
	<category: 'accessing'>
	builtFiles isNil ifTrue: [builtFiles := OrderedCollection new].
       ^builtFiles
    ]

    addFile: aString [
        <category: 'accessing'>

	files isNil ifTrue: [files := OrderedCollection new].
        files add: aString
    ]

    files [
        "Answer a (modifiable) OrderedCollection of files that are part of
         the package."
	<category: 'accessing'>
        | f |
        f := self fileIns copy.
        f removeAll: self builtFiles ifAbsent: [].
	files isNil ifFalse: [
            f removeAll: files ifAbsent: [].
            f addAll: files ].
        ^f
    ]

    addFileIn: aString [
        <category: 'accessing'>

        self fileIns add: aString
    ]

    fileIns [
       "Answer a (modifiable) OrderedCollections of files that are to be
        filed-in to load the package.  This is usually a subset of
	 `files' and `builtFiles'."

	<category: 'accessing'>
	fileIns isNil ifTrue: [fileIns := OrderedCollection new].
       ^fileIns
    ]

    addLibrary: aString [
       <category: 'accessing'>

       self libraries add: aString
    ]

    libraries [
       "Answer a (modifiable) Set of shared library names
        that are required to load the package."
	<category: 'accessing'>
	libraries isNil ifTrue: [libraries := Set new].
       ^libraries
    ]

    addModule: aString [
       <category: 'accessing'>

       self modules add: aString
    ]

    modules [
       "Answer a (modifiable) Set of modules that are
        required to load the package."
	<category: 'accessing'>
	modules isNil ifTrue: [modules := Set new].
       ^modules
    ]

    addSunitScript: aString [
       <category: 'accessing'>

       self sunitScripts add: aString
    ]

    sunitScripts [
       "Answer a (modifiable) OrderedCollection of SUnit scripts that
        compose the package's test suite."
	<category: 'accessing'>
	sunitScripts isNil ifTrue: [sunitScripts := OrderedCollection new].
       ^sunitScripts
    ]

    addCallout: aString [
       <category: 'accessing'>

       self callouts add: aString
    ]

    callouts [
       "Answer a (modifiable) Set of call-outs that are required to load
        the package.  Their presence is checked after the libraries and
	 modules are loaded so that you can do a kind of versioning."

	<category: 'accessing'>
	callouts isNil ifTrue: [callouts := Set new].
	^callouts
    ]

    baseDirectories [
	<category: 'accessing'>
	^baseDirectories
    ]

    baseDirectories: aCollection [
	"Check if it's possible to resolve the names in the package according to
	 the base directories in baseDirectories, which depend on where
	 the packages.xml is found: the three possible places are 1) the
	 system kernel directory's parent directory, 2) the local kernel
	 directory's parent directory, 3) the local image directory (in
	 order of decreasing priority).
	 
	 For a packages.xml found in the system kernel directory's parent
	 directory, all three directories are searched.  For a packages.xml
	 found in the local kernel directory's parent directory, only
	 directories 2 and 3 are searched.  For a packages.xml directory in
	 the local image directory, instead, only directory 3 is searched."

	<category: 'accessing'>
	baseDirectories := aCollection.
	self fullPathsOf: self files.
	"self fullPathsOf: self fileIns."
	"self fullPathsOf: self builtFiles."
	self directory.
	self test notNil ifTrue: [self test baseDirectories: aCollection]
    ]

    fullPathOf: fileName [
	"Try appending 'self directory' and fileName to each of the directory
	 in baseDirectories, and return the path to the first tried filename that
	 exists.  Raise a PackageNotAvailable exception if no directory is
	 found that contains the file."

	<category: 'accessing'>
	baseDirectories do: 
		[:baseDir || dir file |
		dir := baseDir.
		self relativeDirectory isNil 
		    ifFalse: [dir := dir / self relativeDirectory].
		file := dir / fileName.
		file exists ifTrue: [^file]].

	SystemExceptions.PackageNotAvailable signal: self name
	    reason: (fileName printString , ' does not exist in ' , baseDirectories printString)
    ]

    directory [
	"Answer the base directory from which to load the package."

	<category: 'accessing'>
	self relativeDirectory isNil ifTrue: [^nil].
	self baseDirectories do: 
		[:baseDir || dir |
		dir := baseDir / relativeDirectory.
		dir exists ifTrue: [^dir]].

	SystemExceptions.PackageNotAvailable signal: self name
    ]

    relativeDirectory [
	"Answer the directory, relative to the packages file, from which to load
	 the package."

	<category: 'accessing'>
	^relativeDirectory
    ]

    relativeDirectory: dir [
	"Set the directory, relative to the packages file, from which to load
	 the package, to dir."

	<category: 'accessing'>
       relativeDirectory := dir
    ]

    version [
       <category: 'accessing'>

       ^ version
    ]

    version: aVersion [
       <category: 'accessing'>

       version := aVersion
    ]

    parseVersion: aString [
	<category: 'version parsing'>

	self version: (Version fromString: aString)
    ]

    primFileIn [
       "Private - File in the given package without paying attention at
        dependencies and C callout availability"
	<category: 'accessing'>
	| dir namespace |
	self loaded ifTrue: [^self].
	dir := Directory working.
	namespace := Namespace current.
	
	[| loadedFiles |
	Namespace current: self createNamespace.
	self directory isNil ifFalse: [Directory working: self directory].
	self libraries do: [:each | DLD addLibrary: each].
	self modules do: [:each | DLD addModule: each].
	PackageLoader ignoreCallouts 
	    ifFalse: 
		[self callouts do: 
			[:func | 
			(CFunctionDescriptor isFunction: func) 
			    ifFalse: [^self error: 'C callout not available: ' , func]]].
	loadedFiles := self fullPathsOf: self fileIns.
	loadedFiles do: [:each | each fileIn].
	self name isNil ifFalse: [Smalltalk addFeature: self name].
	self features do: [:each | Smalltalk addFeature: each]] 
		ensure: 
		    [Directory working: dir.
		    Namespace current: namespace]
    ]

    parse: file tag: openingTag [
	<category: 'private-initializing'>
	| stack cdata ch tag testPackage |
	stack := OrderedCollection new.
	stack addLast: openingTag.
	
	[
	[cdata := cdata isNil 
		    ifTrue: [file upTo: $<]
		    ifFalse: [cdata , (file upTo: $<)].
	file atEnd] 
		whileFalse: 
		    [ch := file peek.
		    ch == $! ifTrue: [file skipTo: $>].
		    ch == $/ 
			ifTrue: 
			    [tag := stack removeLast.
			    file next.
                           (file upTo: $>) = tag 
                               ifFalse: [^self error: 'error in packages file: unmatched end tag ' , tag].

                           tag = openingTag ifTrue: [ ^ self ].
                           self perform: (self class tags at: tag ifAbsent: [ self error: 'invalid tag ', tag ]) with: cdata.
                           cdata := nil].
                   ch isAlphaNumeric 
                       ifTrue: 
			    [tag := file upTo: $>.
			    tag = 'test' 
				ifTrue: [self test: (TestPackage new parse: file tag: tag)]
				ifFalse: [stack addLast: tag].
			    cdata trimSeparators isEmpty 
				ifFalse: [^self error: 'unexpected character data'].
			    cdata := nil]]] 
		ensure: 
		    [stack isEmpty 
			ifFalse: 
			    [self error: 'error in packages file: unmatched start tags' 
					, stack asArray printString]]
    ]
]



Namespace current: Kernel [

Package subclass: DisabledPackage [
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    printOn: aStream indent: indent [
	<category: 'accessing'>
	self 
	    printOn: aStream
	    tag: 'disabled-package'
	    indent: indent
    ]

    isDisabled [
	<category: 'accessing'>
	^true
    ]
]

]



Namespace current: Kernel [

Smalltalk.Package subclass: TestPackage [
    | owner |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system.  I am an unnamed
subpackage of a regular package, representing an SUnit test suite for
that package.

    owner
	The Package I provide tests for; initialized by the owner.'>

    owner: aPackage [
	"Set the Package I test."

	<category: 'accessing'>
	owner := aPackage
    ]

    url [
	"Answer the URL at which the package repository can be found."

	<category: 'accessing'>
	^super url ifNil: [owner url]
    ]

    namespace [
	"Answer the namespace in which the package is loaded."

	<category: 'accessing'>
	^super namespace ifNil: [owner namespace]
    ]

    baseDirectories [
	"Answer the directories in which package files are sought."

	<category: 'accessing'>
	^super baseDirectories ifNil: 
		[owner baseDirectories 
		    collect: [:each | each / owner relativeDirectory]]
    ]
]

]



Object subclass: PackageLoader [
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I provide methods for
retrieving package information from an XML file and to load packages
into a Smalltalk image, correctly handling dependencies.'>

    PackageLoader class [
	| root loadDate ignoreCallouts |
	
    ]

    PackageLoader class >> packageAt: package ifAbsent: aBlock [
	"Answer a Package object for the given package"

	<category: 'accessing'>
	self refresh.
	^root at: package asString ifAbsent: aBlock
    ]

    PackageLoader class >> packageAt: package [
	"Answer a Package object for the given package"

	<category: 'accessing'>
	self refresh.
	^root at: package asString
    ]

    PackageLoader class >> directoryFor: package [
	"Answer a Directory object to the given package's files"

	<category: 'accessing'>
	^(self packageAt: package) directory
    ]

    PackageLoader class >> builtFilesFor: package [
	"Answer a Set of Strings containing the filenames of the given package's
	 machine-generated files (relative to the directory answered by
	 #directoryFor:)"

	<category: 'accessing'>
	^(self packageAt: package) builtFiles
    ]

    PackageLoader class >> filesFor: package [
	"Answer a Set of Strings containing the filenames of the given package's
	 files (relative to the directory answered by #directoryFor:)"

	<category: 'accessing'>
	^(self packageAt: package) files
    ]

    PackageLoader class >> fileInsFor: package [
	"Answer a Set of Strings containing the filenames of the given package's
	 file-ins (relative to the directory answered by #directoryFor:)"

	<category: 'accessing'>
	^(self packageAt: package) fileIns
    ]

    PackageLoader class >> sunitScriptFor: package [
	"Answer a Strings containing a SUnit script that describes the package's
	 test suite."

	<category: 'accessing'>
	^(self packageAt: package) sunitScript
    ]

    PackageLoader class >> calloutsFor: package [
	"Answer a Set of Strings containing the filenames of the given package's
	 required callouts (relative to the directory answered by #directoryFor:)"

	<category: 'accessing'>
	^(self packageAt: package) callouts
    ]

    PackageLoader class >> librariesFor: package [
	"Answer a Set of Strings containing the filenames of the given package's
	 libraries (relative to the directory answered by #directoryFor:)"

	<category: 'accessing'>
	^(self packageAt: package) libraries
    ]

    PackageLoader class >> modulesFor: package [
	"Answer a Set of Strings containing the filenames of the given package's
	 modules (relative to the directory answered by #directoryFor:)"

	<category: 'accessing'>
	^(self packageAt: package) modules
    ]

    PackageLoader class >> featuresFor: package [
	"Answer a Set of Strings containing the features provided by the given
	 package."

	<category: 'accessing'>
	^(self packageAt: package) features
    ]

    PackageLoader class >> prerequisitesFor: package [
	"Answer a Set of Strings containing the prerequisites for the given package"

	<category: 'accessing'>
	^(self packageAt: package) prerequisites
    ]

    PackageLoader class >> ignoreCallouts [
	"Answer whether unavailable C callouts must generate errors or not."

	<category: 'accessing'>
	ignoreCallouts isNil ifTrue: [ignoreCallouts := false].
	^ignoreCallouts
    ]

    PackageLoader class >> ignoreCallouts: aBoolean [
	"Set whether unavailable C callouts must generate errors or not."

	<category: 'accessing'>
	ignoreCallouts := aBoolean
    ]

    PackageLoader class >> flush [
	"Set to reload the `packages.xml' file the next time it is needed."

	<category: 'accessing'>
	root := nil.
	loadDate := ##(Date 
		    newDay: 1
		    month: #jan
		    year: 1900)
    ]

    PackageLoader class >> refresh [
	"Reload the `packages.xml' file in the image and kernel directories.
	 The three possible places are 1) the kernel directory's parent
	 directory, 2) the `.st' subdirectory of the user's home directory, 3) the
	 local image directory (in order of decreasing priority).
	 
	 For a packages.xml found in the kernel directory's parent
	 directory, all three directories are searched.  For a packages.xml
	 found in the `.st' subdirectory, only directories 2 and 3 are
	 searched.  For a packages.xml directory in the local image directory,
	 finally, only directory 3 is searched."

	<category: 'accessing'>
	| state |
	root isNil 
	    ifTrue: 
		[self flush.
		root := Kernel.PackageDirectories new.
		root add: (Kernel.PackageDirectory on: self packageFile
			    baseDirectories: [
				{Directory userBase.
				Directory kernel / '..'}]).
		root add: (Kernel.PackageDirectory on: self sitePackageFile
			    baseDirectories: [
				{Directory userBase.
				Directory kernel / '../site-packages'}]).
		root add: (Kernel.PackageDirectory on: self userPackageFile
			    baseDirectories: [{Directory userBase}]).
		root add: (Kernel.PackageDirectory on: self localPackageFile
			    baseDirectories: [#()])].
	root refresh: loadDate.
	loadDate := Date dateAndTimeNow
    ]

    PackageLoader class >> fileInPackage: package [
	"File in the given package into GNU Smalltalk."

	<category: 'loading'>
	self fileInPackages: {package}
    ]

    PackageLoader class >> fileInPackages: packagesList [
	"File in all the packages in packagesList into GNU Smalltalk."

	<category: 'loading'>
	| toBeLoaded |
	packagesList isEmpty ifTrue: [^self].
	self refresh.
	toBeLoaded := root extractDependenciesFor: packagesList
		    ifMissing: [:name | SystemExceptions.PackageNotAvailable signal: name].
	toBeLoaded do: 
		[:each | 
		OutputVerbosity > 0 
		    ifTrue: 
			[Transcript
			    nextPutAll: 'Loading package ' , each;
			    nl].
		(self packageAt: each) primFileIn]
    ]

    PackageLoader class >> canLoad: package [
	"Answer whether all the needed pre-requisites for package are available."

	<category: 'testing'>
	self extractDependenciesFor: {package} ifMissing: [:name | ^false].
	^true
    ]

    PackageLoader class >> isLoadable: feature [
	"Private - Answer whether the packages file includes an entry for `feature'"

	<category: 'private'>
	self refresh.
	^root includesKey: feature asString
    ]

    PackageLoader class >> packageFile [
	<category: 'private - packages file'>
	^Directory kernel / '../packages.xml'
    ]

    PackageLoader class >> sitePackageFile [
	<category: 'private - packages file'>
	^Directory kernel / '../site-packages/packages.xml'
    ]

    PackageLoader class >> userPackageFile [
	<category: 'private - packages file'>
	^Directory userBase / 'packages.xml'
    ]

    PackageLoader class >> localPackageFile [
	<category: 'private - packages file'>
	^Directory image / 'packages.xml'
    ]

    PackageLoader class >> rebuildPackageFile [
	"Recreate the XML file from the information that the PackageLoader
	 holds.  This is a dangerous method, also because the PackageLoader
	 does not know about disabled packages."

	<category: 'private - packages file'>
	| file |
	self refresh.
	Directory image / 'packages.xml' withWriteStreamDo: [ :file |
	    file nextPutAll: '<!-- GNU Smalltalk packages description file -->'.
	    file nl; nl.
	    root printOn: file] 
    ]
]

