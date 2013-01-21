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


Kernel.PackageInfo subclass: Package [
    | features prerequisites builtFiles files fileIns relativeDirectory
       baseDirectories libraries modules callouts url namespace sunitScripts
       startScript stopScript test version path |
    
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

       self path isEmpty ifFalse: [self error: 'unexpected <feature> inside <dir> tag'].
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

       self path isEmpty ifFalse: [self error: 'unexpected <prereq> inside <dir> tag'].
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

       self builtFiles add: self path, aString
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
        files add: self path, aString
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

        self fileIns add: self path, aString
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

       self path isEmpty ifFalse: [self error: 'unexpected <library> inside <dir> tag'].
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

       self path isEmpty ifFalse: [self error: 'unexpected <module> inside <dir> tag'].
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

       self path isEmpty ifFalse: [self error: 'unexpected <sunit> inside <dir> tag'].
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

       self path isEmpty ifFalse: [self error: 'unexpected <callout> inside <dir> tag'].
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

    path [

	^ path ifNil: [ path := '' ]
    ]

    path: aString [

	path := aString
    ]

    isInPath [

	^ self path ~= ''
    ]

    checkTagIfInPath: aString [

	self isInPath ifFalse: [ ^ self ].
	(aString = 'file' or: [ aString = 'filein' or: [ aString = 'built-file' ] ]) ifFalse: [ self error: 'invalid tag in a dir tag ', aString ]
    ]

    dir: file tag: aDictionary [
	| oldPath newPath |
        newPath := aDictionary
            at: 'name'
            ifAbsent: [ self error: 'name attribute is not present in a dir tag' ].
        newPath isEmpty
            ifTrue: [ self error: 'name attribute is empty' ].

	oldPath := self path.
        newPath := oldPath, newPath.
        (newPath notEmpty and: [newPath last isPathSeparator not])
            ifTrue: [ newPath := newPath, Directory pathSeparatorString].
	self path: newPath.
	self parse: file tag: 'dir'.
	self path: oldPath.
    ]

    parseAttributes: aString [

        | attribute args key value terminator ch |
        attribute := ReadStream on: aString.
        args := LookupTable new.
        [
            attribute atEnd ifTrue: [^args].
            attribute peek isSeparator ifFalse: [
                self error: 'expected separator'].
            [
                attribute next.
                attribute atEnd ifTrue: [^args].
                attribute peek isSeparator ] whileTrue.
            attribute peek isAlphaNumeric ifFalse: [
                self error: 'expected attribute'].

            key := String streamContents: [ :s |
                [
                    attribute atEnd ifTrue: [
                        self error: 'expected attribute'].
                    ch := attribute next. ch = $= ] whileFalse: [
                        ch isAlphaNumeric ifFalse: [
                            self error: 'invalid attribute name'].
                        s nextPut: ch ] ].

            terminator := attribute next.
            (terminator = $' or: [terminator = $"]) ifFalse: [
                self error: 'expected single or double quote'].

            value := String streamContents: [ :s |
                [
                    attribute atEnd ifTrue: [
                        self error: 'expected %1' % { terminator }].
                    ch := attribute next. ch = terminator ] whileFalse: [
                        s nextPut: ch ] ].
            args at: key put: value.
        ] repeat
    ]

    parse: file tag: openingTag [
	<category: 'private-initializing'>
	| stack cdata ch tag testPackage words |
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
                               ifFalse: [^self error: 'error in packages file: unmatched end tag ' , tag ].
                           tag = openingTag ifTrue: [ ^ self ].
			   self checkTagIfInPath: tag.
			   self perform: (self class tags at: tag ifAbsent: [ self error: 'invalid tag ', tag ]) with: cdata.
			   cdata := nil ].
                   ch isAlphaNumeric 
                       ifTrue: 
			    [tag := file upTo: $>.
			    words := tag substrings.
			    words first = 'dir' ifTrue: [
                                self
                                    dir: file
                                    tag: (self parseAttributes: (tag copyFrom: words first size + 1)) ]
				ifFalse: [
			            words first = 'test' 
				        ifTrue: [self test: (TestPackage new parse: file tag: tag)]
				        ifFalse: [stack addLast: tag] ].
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

