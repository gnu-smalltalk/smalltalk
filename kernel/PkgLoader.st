"======================================================================
|
|   PackageLoader Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2004,2005,2007
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

Namespace current: Kernel!

Notification subclass: #PackageSkip
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

Exception subclass: #PackageNotAvailable
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

Object subclass: #PackageGroup
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageGroup comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

PackageGroup subclass: #PackageDirectories
	instanceVariableNames: 'dirs'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageDirectories comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

PackageGroup subclass: #PackageDirectory
	instanceVariableNames: 'packages fileName baseDirectories'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageDirectory comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

Object subclass: #PackageInfo
	instanceVariableNames: 'name '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageInfo comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

PackageInfo subclass: #StarPackage
	instanceVariableNames: 'fileName loadedPackage '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageInfo comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

Namespace current: Smalltalk!

Kernel.PackageInfo subclass: #Package
	instanceVariableNames: 'features prerequisites builtFiles files fileIns relativeDirectory baseDirectories libraries modules callouts namespace sunitScripts test'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

Package comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

Namespace current: Kernel!

Package subclass: #DisabledPackage
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

DisabledPackage comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!

Namespace current: Smalltalk!

Namespace current: Kernel!

Smalltalk.Package subclass: #TestPackage
		  instanceVariableNames: 'owner'
		  classVariableNames: ''
		  poolDictionaries: ''
		  category: 'Language-Packaging'
!

TestPackage comment:
'I am not part of a standard Smalltalk system.  I am an unnamed
subpackage of a regular package, representing an SUnit test suite for
that package.

    owner
	The Package I provide tests for; initialized by the owner.'!

Namespace current: Smalltalk!

Object subclass: #PackageLoader
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageLoader class
	instanceVariableNames: 'root loadDate ignoreCallouts'!

PackageLoader comment: 
'I am not part of a standard Smalltalk system. I provide methods for
retrieving package information from an XML file and to load packages
into a Smalltalk image, correctly handling dependencies.'!


!Kernel.PackageGroup methodsFor: 'printing'!

printOn: aStream
    "Print the XML source code for the information that the PackageLoader
     holds on aStream."
    aStream nextPutAll: '<packages>'; nl.
    self
	do: [ :each |
	    aStream space: 2.
	    each printOn: aStream indent: 2.
	    aStream nl ]
	separatedBy: [ aStream nl ].
    aStream nextPutAll: '</packages>'
! !

!Kernel.PackageGroup methodsFor: 'accessing'!

at: aString
    ^self at: aString ifAbsent: [ self error: 'package not found' ]
!

at: aString ifAbsent: aBlock
    self subclassResponsibility
!

do: aBlock
    self keys do: [ :each | aBlock value: (self at: each) ]
!

do: aBlock separatedBy: sepBlock
    self keys
	do: [ :each | aBlock value: (self at: each) ]
	separatedBy: sepBlock
!

keys
    self subclassResponsibility
!

includesKey: aString
    self subclassResponsibility
!

extractDependenciesFor: packagesList ifMissing: aBlock
    "Answer an OrderedCollection containing all the packages which you
     have to load to enable the packages in packagesList, in an appropriate
     order. For example

     PackageLoader extractDependenciesFor: #('BloxTestSuite' 'Blox' 'Browser')

     on a newly built image will evaluate to an OrderedCollection containing
     'Kernel', 'Blox', 'BloxTestSuite' and 'Browser'. Note that
     Blox has been moved before BloxTestSuite.
     Pass an error message to aBlock if one or more packages need
     prerequisites which are not available."

    | toBeLoaded featuresFound dependencies allPrereq allFeatures |
    toBeLoaded := packagesList asOrderedCollection.
    toBeLoaded := toBeLoaded collect: [ :each | each asString ].
    featuresFound := Set withAll: Smalltalk.Features.
    featuresFound := featuresFound collect: [ :each | each asString ].
    dependencies := packagesList collect: [ :each | each asString ].
    [
	allPrereq := Set new.
	allFeatures := Set new.
	dependencies do: [ :name || package |
	    (featuresFound includes: name) ifFalse: [
		package := self at: name ifAbsent: [ ^aBlock value: name ].
		allPrereq addAll: package prerequisites.
		allFeatures addAll: package features
	    ]
	].

	"I don't think there will never be lots of packages in newDep (say
	 more than 5), so I think it is acceptable to remove duplicates
	 this naive way.  Note that we remove duplicates from toBeLoaded
	 so that prerequisites are always loaded *before*."
	toBeLoaded removeAll: allPrereq ifAbsent: [ :doesNotMatter | ].
	toBeLoaded removeAll: allFeatures ifAbsent: [ :doesNotMatter | ].

	allPrereq removeAll: allFeatures ifAbsent: [ :doesNotMatter | ].
	featuresFound addAll: allFeatures.
	toBeLoaded addAllFirst: allPrereq.

	"Proceed recursively with the prerequisites for allPrereq"
	dependencies := allPrereq.
	dependencies notEmpty
    ] whileTrue.

    ^toBeLoaded
!


!Kernel.PackageDirectories class methodsFor: 'instance creation'!

new
    ^super new initialize
! !

!Kernel.PackageDirectories methodsFor: 'copying'!

postCopy
    dirs := dirs copy
! !

!Kernel.PackageDirectories methodsFor: 'accessing'!

add: aDirectory
    ^dirs add: aDirectory
!

at: aString ifAbsent: aBlock
    dirs do: [ :each || package |
	package := each at: aString ifAbsent: [ nil ].
	package isNil ifFalse: [ ^package ] ].
    ^aBlock value
!

keys
    | keys |
    keys := Set new.
    dirs do: [ :each | keys addAll: each keys ].
    ^keys
!

includesKey: aString
    ^dirs anySatisfy: [ :each | each includesKey: aString ]
!

shouldReload: loadDate
    ^dirs anySatisfy: [ :each | each shouldReload: loadDate ]
!

refresh
    dirs do: [ :each | each refresh ]
! !

!Kernel.PackageDirectories methodsFor: 'initializing'!

initialize
    dirs := OrderedCollection new
! !


!Kernel.PackageDirectory class methodsFor: 'accessing'!

new
    self shouldNotImplement
!

on: aString baseDirectories: anArray
    ^super new
	fileName: aString;
	baseDirectories: anArray
! !

!Kernel.PackageDirectory methodsFor: 'accessing'!

fileName
    ^fileName
!

fileName: aString
    fileName := aString
!

baseDirectories
    ^baseDirectories
!

baseDirectories: anArray
    baseDirectories := anArray
!

at: aString ifAbsent: aBlock
    packages isNil ifTrue: [ ^aBlock value ].
    ^packages at: aString asString ifAbsent: aBlock
!

keys
    ^packages isNil ifTrue: [ #() ] ifFalse: [ packages keys ]
!

includesKey: aString
    ^packages includesKey: aString
! !

!Kernel.PackageDirectory methodsFor: 'refreshing'!

shouldReload: loadDate
    | file |
    file := File name: fileName.
    file exists ifFalse: [ packages := LookupTable new. ^false ].
    ^file lastModifyTime > loadDate
!

refresh
    "Private - Process the XML source in the packages file, creating
     Package objects along the way."

    packages := LookupTable new.
    self refreshPackageList.
    self refreshStarList
!

refreshPackageList
    | file allDirs |
    allDirs := Smalltalk imageLocal
	ifTrue: [ { Directory image }, baseDirectories ]
	ifFalse: [ baseDirectories ].

    allDirs isEmpty ifTrue: [ ^self ].

    file := [ FileStream open: fileName mode: FileStream read ]
	on: Error
	do: [ :ex | ^self ].

    [
        [ self parse: file baseDirectories: allDirs ]
	    on: PackageNotAvailable
	    do: [ :ex | ex resignalAs: PackageSkip new ] ]
        ensure: [ file close ].

    packages := packages reject: [ :each | each isDisabled ]
!

refreshStarList
    | dir |
    dir := Directory name: (File pathFor: fileName).
    dir exists ifFalse: [ ^self].

    dir
	namesMatching: '*.star'
	do: [ :starName |
	    | package |
	    package := Kernel.StarPackage fileName: starName.
	    packages at: package name put: package ]
!

parse: file baseDirectories: baseDirs
    | open ch cdata tag package |
    open := false.
    [ cdata := cdata isNil
	ifTrue: [ file upTo: $< ]
	ifFalse: [ cdata, (file upTo: $<) ].
	file atEnd ] whileFalse: [

	cdata trimSeparators isEmpty ifFalse: [
	    ^self error: 'unexpected character data' ].

	ch := file peek.
	ch == $! ifTrue: [ file skipTo: $> ].
	ch == $/ ifTrue: [
	    file next.
	    ^(tag := file upTo: $>) = 'packages'
		ifTrue: [ packages ]
		ifFalse: [ ^self error: 'unmatched end tag ', tag ] ].

	ch isAlphaNumeric ifTrue: [
	    open
		ifFalse: [
		    tag := file upTo: $>.
		    tag = 'packages' ifFalse: [
			^self error: 'expected packages tag' ].
	            tag = 'package' ifTrue: [
			package := Package new parse: file tag: 'package' ].
		    open := true ]
		ifTrue: [
		    file skip: -1.
		    package := Package parse: file ].

	    package notNil ifTrue: [
	        package name isNil ifTrue: [
	            ^self error: 'missing package name in ', fileName ].

		[
		    package baseDirectories: baseDirs.
		    packages at: package name put: package ]
			on: PackageSkip
			do: [ :ex | ex return ] ].
	    package := nil ] ]
! !



!Kernel.PackageInfo methodsFor: 'accessing'!

fileIn
    "File in the given package and its dependencies."
    self name isNil
	ifTrue: [
	    "Other packages cannot be dependent on this one."
	    PackageLoader fileInPackages: self prerequisites.
	    self primFileIn ]
	ifFalse: [
	    PackageLoader fileInPackage: self name ]!

printXmlOn: aStream collection: aCollection tag: aString indent: indent
    "Private - Print aCollection on aStream as a sequence of aString
     tags."
    aCollection do: [ :each |
        aStream
            nextPutAll: '  <'; nextPutAll: aString; nextPut: $>;
            nextPutAll: each;
            nextPutAll: '</'; nextPutAll: aString; nextPut: $>;
            nl; space: indent
    ]!

printOn: aStream
    self printOn: aStream indent: 0
!

printOn: aStream indent: indent
    self printOn: aStream tag: 'package' indent: indent
!

printOn: aStream tag: tag indent: indent
    "Print a representation of the receiver on aStream (it happens
     to be XML."

    aStream
	nextPut: $<;
	nextPutAll: tag;
	nextPut: $>;
	nl; space: indent.

    self name isNil ifFalse: [
	aStream
	    nextPutAll: '  <name>';
	    nextPutAll: self name;
	    nextPutAll: '</name>';
	    nl; space: indent.
    ].

    self namespace isNil ifFalse: [
	aStream
	    nextPutAll: '  <namespace>';
	    nextPutAll: self namespace;
	    nextPutAll: '</namespace>';
	    nl; space: indent.
    ].

    self test isNil ifFalse: [
	aStream space: 2.
	self test printOn: aStream tag: 'test' indent: indent + 2.
	aStream nl; space: indent ].

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
	collection: self fileIns
	tag: 'filein'
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
	ifFalse: [
	    aStream
	        nextPutAll: '  <directory>';
	        nextPutAll: self relativeDirectory;
	        nextPutAll: '</directory>';
	        nl; space: indent ].

    self files size + self builtFiles size > 1
	ifTrue: [ aStream nl; space: indent  ].

    self
	printXmlOn: aStream
	collection: self files
	tag: 'file'
	indent: indent.
    self
	printXmlOn: aStream
	collection: self builtFiles
	tag: 'built-file'
	indent: indent.
    aStream nextPutAll: '</'; nextPutAll: tag; nextPut: $>!

name
    "Answer the name of the package."
    ^name!

name: aString
    "Set to aString the name of the package."
    name := aString!

namespace
    "Answer the namespace in which the package is loaded."
    self subclassResponsibility!

features
    "Answer a (modifiable) Set of features provided by the package."
    self subclassResponsibility!

prerequisites
    "Answer a (modifiable) Set of prerequisites."
    self subclassResponsibility!

builtFiles
    "Answer a (modifiable) OrderedCollection of files that are part of
     the package but are not distributed."
    self subclassResponsibility!

files
    "Answer a (modifiable) OrderedCollection of files that are part of
     the package."
    self subclassResponsibility!

allFiles
    "Answer an OrderedCollection of all the files, both built and
     distributed, that are part of the package."
    ^self files, self builtFiles!

fileIns
    "Answer a (modifiable) OrderedCollections of files that are to be
     filed-in to load the package.  This is usually a subset of
     `files' and `builtFiles'."
    self subclassResponsibility!

libraries
    "Answer a (modifiable) Set of shared library names
     that are required to load the package."
    self subclassResponsibility!

modules
    "Answer a (modifiable) Set of modules that are
     required to load the package."
    self subclassResponsibility!

sunitScript
    "Answer a String containing a SUnit script that
     describes the package's test suite."
    self sunitScripts isEmpty ifTrue: [ ^'' ].
    ^self sunitScripts fold: [ :a :b | a, ' ', b ]!

sunitScripts
    "Answer a (modifiable) OrderedCollection of SUnit scripts that
     compose the package's test suite."
    self subclassResponsibility!

callouts
    "Answer a (modifiable) Set of call-outs that are required to load
     the package.  Their presence is checked after the libraries and
     modules are loaded so that you can do a kind of versioning."
    self subclassResponsibility!

relativeDirectory
    "Answer the directory from which to load the package, relative to the package
     file."
    self subclassResponsibility!

directory
    "Answer the base directory from which to load the package."
    self subclassResponsibility!
! !


!Kernel.StarPackage class methodsFor: 'accessing'!

fileName: fileName
    ^self new
	fileName: fileName;
	name: (File stripPathFrom: (File stripExtensionFrom: fileName));
	yourself
! !

!Kernel.StarPackage methodsFor: 'accessing'!

test
    "Answer the test subpackage for this package."
    ^self loadedPackage test!

namespace
    "Answer the namespace in which the package is loaded."
    ^self loadedPackage namespace!

features
    "Answer a (modifiable) Set of features provided by the package."
    ^self loadedPackage features!

prerequisites
    "Answer a (modifiable) Set of prerequisites."
    ^self loadedPackage prerequisites!

builtFiles
    "Answer a (modifiable) OrderedCollection of files that are part of
     the package but are not distributed."
    ^self loadedPackage builtFiles!

files
    "Answer a (modifiable) OrderedCollection of files that are part of
     the package."
    ^self loadedPackage files!

fileIns
    "Answer a (modifiable) OrderedCollections of files that are to be
     filed-in to load the package.  This is usually a subset of
     `files' and `builtFiles'."
    ^self loadedPackage fileIns!

libraries
    "Answer a (modifiable) Set of shared library names
     that are required to load the package."
    ^self loadedPackage libraries!

modules
    "Answer a (modifiable) Set of modules that are
     required to load the package."
    ^self loadedPackage modules!

sunitScripts
    "Answer a (modifiable) OrderedCollection of SUnit scripts that
     compose the package's test suite."
    ^self loadedPackage sunitScripts!

callouts
    "Answer a (modifiable) Set of call-outs that are required to load
     the package.  Their presence is checked after the libraries and
     modules are loaded so that you can do a kind of versioning."
    ^self loadedPackage callouts!

relativeDirectory
    ^'.'!

directory
    ^fileName, '#uzip'!

fileName
    ^fileName!

fileName: aString
    fileName := aString!

primFileIn
    self loadedPackage primFileIn!

loadedPackage
    | file package |
    loadedPackage isNil ifFalse: [ ^loadedPackage ].

    file := FileStream open: fileName, '#uzip/package.xml' mode: FileStream read.
    [ package := Package parse: file ]
	ensure: [ file close ].
    package isNil ifTrue: [
	^self error: 'invalid disabled-package tag inside a star file' ].

    package relativeDirectory: self relativeDirectory.
    package baseDirectories: { self directory }.
    package name isNil
	ifTrue: [ package name: self name ]
	ifFalse: [
	    package name = self name
		ifFalse: [ self error: 'invalid package name in package.xml' ] ].

    loadedPackage := package.
    ^loadedPackage
! !


!Package class methodsFor: 'instance creation'!

parse: file
    | ch tag |
    [
	(file upTo: $<) trimSeparators isEmpty ifFalse: [
	    self error: 'unexpected cdata' ].
	file atEnd ifTrue: [
	    self error: 'expected start tag' ].

	ch := file peek.
	ch == $! ifTrue: [ file skipTo: $> ].
	ch == $/ ifTrue: [ self error: 'unexpected end tag ' ].

	ch isAlphaNumeric ifTrue: [
	    tag := file upTo: $>.
	    tag = 'package'
		ifTrue: [ ^Package new parse: file tag: tag ].
	    tag = 'disabled-package'
		ifTrue: [ ^DisabledPackage new parse: file tag: tag ].
        ]
    ] repeat
! !

!Package methodsFor: 'accessing'!

isDisabled
    ^false
!

test
    "Answer the test sub-package."
    ^test!

test: aPackage
    "Set the test sub-package to be aPackage."
    aPackage test isNil
	ifFalse: [ self error: 'test packages must not be nested' ].
    aPackage name isNil
	ifFalse: [ self error: 'test package must not have names' ].

    aPackage prerequisites add: 'SUnit'; add: self name.
    aPackage owner: self.
    test := aPackage!

namespace
    "Answer the namespace in which the package is loaded."
    ^namespace!

namespace: aString
    "Set to aString the namespace in which the package is loaded."
    namespace := aString!

features
    "Answer a (modifiable) Set of features provided by the package."
    features isNil ifTrue: [ features := Set new ].
    ^features!

prerequisites
    "Answer a (modifiable) Set of prerequisites."
    prerequisites isNil ifTrue: [ prerequisites := Set new ].
    ^prerequisites!

builtFiles
    "Answer a (modifiable) OrderedCollection of files that are part of
     the package but are not distributed."
    builtFiles isNil ifTrue: [ builtFiles := OrderedCollection new ].
    ^builtFiles!

files
    "Answer a (modifiable) OrderedCollection of files that are part of
     the package."
    files isNil ifTrue: [ files := OrderedCollection new ].
    ^files!

fileIns
    "Answer a (modifiable) OrderedCollections of files that are to be
     filed-in to load the package.  This is usually a subset of
     `files' and `builtFiles'."
    fileIns isNil ifTrue: [ fileIns := OrderedCollection new ].
    ^fileIns!

libraries
    "Answer a (modifiable) Set of shared library names
     that are required to load the package."
    libraries isNil ifTrue: [ libraries := Set new ].
    ^libraries!

modules
    "Answer a (modifiable) Set of modules that are
     required to load the package."
    modules isNil ifTrue: [ modules := Set new ].
    ^modules!

sunitScripts
    "Answer a (modifiable) OrderedCollection of SUnit scripts that
     compose the package's test suite."
    sunitScripts isNil ifTrue: [ sunitScripts := OrderedCollection new ].
    ^sunitScripts!

callouts
    "Answer a (modifiable) Set of call-outs that are required to load
     the package.  Their presence is checked after the libraries and
     modules are loaded so that you can do a kind of versioning."
    callouts isNil ifTrue: [ callouts := Set new ].
    ^callouts!

baseDirectories
    ^baseDirectories
!

baseDirectories: aCollection
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

    baseDirectories := aCollection.
    self findPathsFor: self files.
    "self findPathsFor: self fileIns."
    "self findPathsFor: self builtFiles."
    self directory.

    self test notNil ifTrue: [ self test baseDirectories: aCollection ].
!

findPathsFor: aCollection
    "Resolve the names in aCollection according to the base directories
     in baseDirectories, and return the collection with the full filenames, or
     nil if no directory was found for one or more file in aCollection."
    ^aCollection collect: [ :fileName || name |
        name := self findPathFor: fileName ]
!

findPathFor: fileName
    "Try appending 'self directory' and fileName to each of the directory
     in baseDirectories, and return the path to the first tried filename that
     exists.  Return nil if no directory is found that contains the file."
    | name |
    baseDirectories do: [ :dir |
	name := dir.
	self relativeDirectory isNil ifFalse: [
            name := Directory append: self relativeDirectory to: dir ].
        name := Directory append: fileName to: name.
        (File exists: name) ifTrue: [ ^name ] ].

    "TODO: should put the name and baseDirectories into the exception."
    "name printNl.  baseDirectories printNl."
    PackageNotAvailable signal: self
!


directory
    "Answer the base directory from which to load the package."

    self relativeDirectory isNil ifTrue: [ ^nil ].

    self baseDirectories
	do: [ :dir || name |
            name := Directory append: self relativeDirectory to: dir.
            (Directory exists: name) ifTrue: [ ^name ] ].

    PackageNotAvailable signal: self!

relativeDirectory
    "Answer the directory, relative to the packages file, from which to load
     the package."
    ^relativeDirectory!

relativeDirectory: dir
    "Set the directory, relative to the packages file, from which to load
     the package, to dir."
    relativeDirectory := dir!

createNamespace
    "Private - Create the path of namespaces indicated by our
     namespace field in dot notation, and answer the final namespace"
    | ns |
    ns := Smalltalk.
    self namespace isNil ifTrue: [ ^ns ].
    (self namespace subStrings: $.) do: [ :each || key |
	key := each asSymbol.
	(ns includesKey: key) ifFalse: [ ns addSubspace: key ].
	ns := ns at: key
    ].
    ^ns!

loaded
    ^self name notNil and: [ Smalltalk hasFeatures: self name ]!

primFileIn
    "Private - File in the given package without paying attention at
     dependencies and C callout availability"

    | dir namespace |
    self loaded ifTrue: [ ^self ].

    dir := Directory working.
    namespace := Namespace current.
    [
        | loadedFiles |
        Namespace current: self createNamespace.
        self directory isNil ifFalse: [ Directory working: self directory ].
        self libraries do: [ :each | DLD addLibrary: each ].
        self modules do: [ :each | DLD addModule: each ].

        PackageLoader ignoreCallouts ifFalse: [
            self callouts do: [ :func |
                (CFunctionDescriptor isFunction: func)
	             ifFalse: [ ^self error: 'C callout not available: ', func ]]].

        loadedFiles := self findPathsFor: self fileIns.
	loadedFiles do: [ :each | FileStream fileIn: each ].
        self name isNil ifFalse: [ Smalltalk addFeature: self name ].
        self features do: [ :each | Smalltalk addFeature: each ].
    ] ensure: [
        Directory working: dir.
        Namespace current: namespace.
    ]
!

parse: file tag: openingTag
    | stack cdata ch tag testPackage |
    stack := OrderedCollection new.
    stack addLast: openingTag.
    [
	[ cdata := cdata isNil
	    ifTrue: [ file upTo: $< ]
	    ifFalse: [ cdata, (file upTo: $<) ].

	    file atEnd ] whileFalse: [
	    ch := file peek.
	    ch == $! ifTrue: [ file skipTo: $> ].
	    ch == $/ ifTrue: [
	        tag := stack removeLast.
	        file next.
	        (file upTo: $>) = tag ifFalse: [
		    ^self error: 'error in packages file: unmatched end tag ', tag
	        ].

	        "I tried to put these from the most common to the least common"
	        tag = 'file' ifTrue: [ self files add: cdata ] ifFalse: [
	        tag = 'filein' ifTrue: [ self fileIns add: cdata ] ifFalse: [
	        tag = 'prereq' ifTrue: [ self prerequisites add: cdata ] ifFalse: [
	        tag = 'provides' ifTrue: [ self features add: cdata ] ifFalse: [
	        tag = 'module' ifTrue: [ self modules add: cdata ] ifFalse: [
	        tag = 'directory' ifTrue: [ self relativeDirectory: cdata ] ifFalse: [
	        tag = 'name' ifTrue: [ self name: cdata ] ifFalse: [
	        tag = 'namespace' ifTrue: [ self namespace: cdata ] ifFalse: [
	        tag = 'library' ifTrue: [ self libraries add: cdata ] ifFalse: [
	        tag = 'built-file' ifTrue: [ self builtFiles add: cdata ] ifFalse: [
	        tag = 'sunit' ifTrue: [ self sunitScripts add: cdata ] ifFalse: [
	        tag = 'callout' ifTrue: [ self callouts add: cdata ] ifFalse: [
	        tag = openingTag ifTrue: [ ^self ] ifFalse: [
		    self error: 'invalid tag ', tag ]]]]]]]]]]]]].
	        cdata := nil.
	    ].
	    ch isAlphaNumeric ifTrue: [
	        tag := file upTo: $>.
		tag = 'test'
		    ifTrue: [ self test: (TestPackage new parse: file tag: tag) ]
	            ifFalse: [ stack addLast: tag ].

		cdata trimSeparators isEmpty ifFalse: [
		    ^self error: 'unexpected character data' ].

	        cdata := nil
	    ].
        ].
    ] ensure: [
        stack isEmpty ifFalse: [
	    self error: 'error in packages file: unmatched start tags',
		stack asArray printString ]
    ]
! !

!Kernel.DisabledPackage methodsFor: 'accessing'!

printOn: aStream indent: indent
    self printOn: aStream tag: 'disabled-package' indent: indent
!

isDisabled
    ^true
! !


!Kernel.TestPackage methodsFor: 'accessing'!

owner: aPackage
    "Set the Package I test."
    owner := aPackage.
!

relativeDirectory
    "Answer the base directory from which to load the package."
    ^super relativeDirectory ifNil: [owner relativeDirectory]
!

namespace
    "Answer the namespace in which the package is loaded."
    ^super namespace ifNil: [owner namespace]
!

baseDirectories
    "Answer the namespace in which the package is loaded."
    ^super baseDirectories ifNil: [owner baseDirectories]
! !


!PackageLoader class methodsFor: 'accessing'!

packageAt: package
    "Answer a Package object for the given package"
    self refresh.
    ^root at: package asString
!

directoryFor: package
    "Answer a complete path to the given package's files"
    ^(self packageAt: package) directory
!

builtFilesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     machine-generated files (relative to the directory answered by
     #directoryFor:)"
    ^(self packageAt: package) builtFiles
!

filesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     files (relative to the directory answered by #directoryFor:)"
    ^(self packageAt: package) files
!

fileInsFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     file-ins (relative to the directory answered by #directoryFor:)"
    ^(self packageAt: package) fileIns
!

sunitScriptFor: package
    "Answer a Strings containing a SUnit script that describes the package's
     test suite."
    ^(self packageAt: package) sunitScript
!

calloutsFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     required callouts (relative to the directory answered by #directoryFor:)"
    ^(self packageAt: package) callouts
!

librariesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     libraries (relative to the directory answered by #directoryFor:)"
    ^(self packageAt: package) libraries
!

modulesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     modules (relative to the directory answered by #directoryFor:)"
    ^(self packageAt: package) modules
!

featuresFor: package
    "Answer a Set of Strings containing the features provided by the given
     package."
    ^(self packageAt: package) features
!

prerequisitesFor: package
    "Answer a Set of Strings containing the prerequisites for the given package"
    ^(self packageAt: package) prerequisites
!

ignoreCallouts
    "Answer whether unavailable C callouts must generate errors or not."
    ignoreCallouts isNil ifTrue: [ ignoreCallouts := false ].
    ^ignoreCallouts
!

ignoreCallouts: aBoolean
    "Set whether unavailable C callouts must generate errors or not."
    ignoreCallouts := aBoolean
!

flush
    "Set to reload the `packages.xml' file the next time it is needed."
    loadDate := nil.
    root := nil
!

refresh
    "Reload the `packages.xml' file in the image and kernel directories.
     The three possible places are 1) the kernel directory's parent
     directory, 2) the `.st' subdirectory of the user's home directory, 3) the
     local image directory (in order of decreasing priority).

     For a packages.xml found in the kernel directory's parent
     directory, all three directories are searched.  For a packages.xml
     found in the `.st' subdirectory, only directories 2 and 3 are
     searched.  For a packages.xml directory in the local image directory,
     finally, only directory 3 is searched."
    | state |
    loadDate isNil ifFalse: [
	(root shouldReload: loadDate) ifFalse: [ ^self ]
    ].

    loadDate := Date dateAndTimeNow.
    root := Kernel.PackageDirectories new.
    root add: (Kernel.PackageDirectory
		  on: self packageFileName 
		  baseDirectories: { Directory userBase.  Directory kernel, '/..' }).
    root add: (Kernel.PackageDirectory
		  on: self userPackageFileName 
		  baseDirectories: { Directory userBase.  }).
    root add: (Kernel.PackageDirectory
		  on: self localPackageFileName 
		  baseDirectories: #()).
    root refresh
! !


!PackageLoader class methodsFor: 'loading'!

fileInPackage: package
    "File in the given package into GNU Smalltalk."
    self fileInPackages: {package}
!

fileInPackages: packagesList
    "File in all the packages in packagesList into GNU Smalltalk."
    | toBeLoaded |
    self refresh.
    toBeLoaded := root
	extractDependenciesFor: packagesList
	ifMissing: [ :name | ^self error: 'package not available: ', name ].
	
    toBeLoaded do: [ :each |
        OutputVerbosity > 0 ifTrue: [
            Transcript nextPutAll: 'Loading package ', each; nl ].
	(self packageAt: each) primFileIn ]
! !


!PackageLoader class methodsFor: 'testing'!

canLoad: package
    "Answer whether all the needed pre-requisites for package are available."
    self
	extractDependenciesFor: {package}
	ifMissing: [ :name | ^false ].
    ^true
! !


!PackageLoader class methodsFor: 'private'!

isLoadable: feature
    "Private - Answer whether the packages file includes an entry for `feature'"
    self refresh.
    ^root includesKey: feature asString
! !


!PackageLoader class methodsFor: 'private - packages file'!

packageFileName
    ^Directory kernel, '/../packages.xml'
!

userPackageFileName
    ^Directory userBase, '/packages.xml'
!

localPackageFileName
    ^Directory image, '/packages.xml'
!

rebuildPackageFile
    "Recreate the XML file from the information that the PackageLoader
     holds.  This is a dangerous method, also because the PackageLoader
     does not know about disabled packages."
    | file |
    self refresh.
    file := FileStream
	open: Directory image, '/packages.xml'
	mode: FileStream write.

    [
	file nextPutAll: '<!-- GNU Smalltalk packages description file -->'.
	file nl; nl.
        root printOn: file
    ] ensure: [ file close ]
! !

