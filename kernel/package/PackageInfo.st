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

