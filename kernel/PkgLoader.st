"======================================================================
|
|   PackageLoader Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2005 Free Software Foundation, Inc.
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


Object subclass: #Package
	instanceVariableNames: 'name prerequisites builtFiles files fileIns directory libraries modules callouts '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-Packaging'
!

Package comment:
'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'!


Object subclass: #PackageLoader
	instanceVariableNames: ''
	classVariableNames: 'Packages LoadDate IgnoreCallouts'
	poolDictionaries: ''
	category: 'Language-Packaging'
!

PackageLoader comment: 
'I am not part of a standard Smalltalk system. I provide methods for
retrieving package information from an XML file and to load packages
into a Smalltalk image, correctly handling dependencies.'!


!Package methodsFor: 'accessing'!

printXmlOn: aStream collection: aCollection tag: aString
    "Private - Print aCollection on aStream as a sequence of aString
     tags."
    aCollection do: [ :each |
	aStream
	    nextPutAll: '  <'; nextPutAll: aString; nextPut: $>;
	    nextPutAll: each;
	    nextPutAll: '</'; nextPutAll: aString; nextPut: $>;
	    nl
    ]!

printOn: aStream
    "Print a representation of the receiver on aStream (it happens
     to be XML."

    aStream nextPutAll: '
<package>
  <name>'; nextPutAll: self name; nextPutAll: '</name>'; nl.

    self
	printXmlOn: aStream
	collection: self prerequisites asSortedCollection
	tag: 'prereq'.

    self
	printXmlOn: aStream
	collection: self callouts asSortedCollection
	tag: 'callout'.

    self
	printXmlOn: aStream
	collection: self fileIns
	tag: 'filein'.

    self
	printXmlOn: aStream
	collection: self libraries asSortedCollection
	tag: 'library'.

    self
	printXmlOn: aStream
	collection: self modules asSortedCollection
	tag: 'module'.

    self
	printXmlOn: aStream
	collection: { self directory }
	tag: 'directory'.

    files := self files copy addAll: self builtFiles; yourself.
    files size > 1 ifTrue: [ aStream nl ].
    self
	printXmlOn: aStream
	collection: self files
	tag: 'file'.

    self
	printXmlOn: aStream
	collection: self builtFiles
	tag: 'built-file'.

    aStream nextPutAll: '</package>'; nl!

name
    "Answer the name of the package."
    ^name!

name: aString
    "Set to aString the name of the package."
    name := aString!

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

allFiles
    "Answer an OrderedCollection of all the files, both built and
     distributed, that are part of the package."
    ^self files, self builtFiles!

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

callouts
    "Answer a (modifiable) Set of call-outs that are required to load
     the package.  Their presence is checked after the libraries and
     modules are loaded so that you can do a kind of versioning."
    callouts isNil ifTrue: [ callouts := Set new ].
    ^callouts!

baseDirs: baseDirs
    "Resolve the names in the package according to the base directories
     in baseDirs, which depend on where the packages.xml is found:
     the three possible places are 1) the system kernel directory's parent
     directory, 2) the local kernel directory's parent directory, 3) the
     local image directory (in order of decreasing priority).

     For a packages.xml found in the system kernel directory's parent
     directory, all three directories are searched.  For a packages.xml
     found in the local kernel directory's parent directory, only
     directories 2 and 3 are searched.  For a packages.xml directory in
     the local image directory, instead, only directory 3 is searched."

    | found |
    files := self findBaseDirs: baseDirs for: self files.
    fileIns := self findBaseDirs: baseDirs for: self fileIns.
    builtFiles := self findBaseDirs: baseDirs for: self builtFiles.

    found := nil.
    baseDirs
        do: [ :dir || name |
            name := Directory append: self directory to: dir.
            (Directory exists: name) ifTrue: [ found := name ] ].
    directory := found.

    ^files notNil & fileIns notNil & builtFiles notNil & directory notNil
!

findBaseDirs: baseDirs for: aCollection
    "Resolve the names in aCollection according to the base directories
     in baseDirs, and return the collection with the full filenames, or
     nil if no directory was found for one or more file in aCollection."
    ^aCollection collect: [ :fileName || name |
        name := self findBaseDirs: baseDirs forFile: fileName.
        name isNil ifTrue: [ ^nil ] ifFalse: [ name ]]
!

findBaseDirs: baseDirs forFile: fileName
    "Try appending 'self directory' and fileName to each of the directory
     in baseDirs, and return the path to the first tried filename that exists.
     Return nil if no directory is found that contains the file."
    | name |
    baseDirs do: [ :dir |
       name := Directory append: self directory to: dir.
       name := Directory append: fileName to: name.
       (File exists: name) ifTrue: [ ^name ] ].
    ^nil
!


directory
    "Answer the base directory from which to load the package."
    ^directory!

directory: dir
    "Set the base directory from which to load the package to dir."
    directory := dir! !

!PackageLoader class methodsFor: 'accessing'!

directoryFor: package
    "Answer a complete path to the given package's files"
    self refreshDependencies.
    ^(Packages at: package asString) directory.
!

builtFilesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     machine-generated files (relative to the directory answered by
     #directoryFor:)"
    self refreshDependencies.
    ^(Packages at: package asString) builtFiles.
!

filesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     files (relative to the directory answered by #directoryFor:)"
    self refreshDependencies.
    ^(Packages at: package asString) files.
!

fileInsFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     file-ins (relative to the directory answered by #directoryFor:)"
    self refreshDependencies.
    ^(Packages at: package asString) fileIns.
!

calloutsFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     required callouts (relative to the directory answered by #directoryFor:)"
    self refreshDependencies.
    ^(Packages at: package asString) callouts.
!

librariesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     libraries (relative to the directory answered by #directoryFor:)"
    self refreshDependencies.
    ^(Packages at: package asString) libraries.
!

modulesFor: package
    "Answer a Set of Strings containing the filenames of the given package's
     modules (relative to the directory answered by #directoryFor:)"
    self refreshDependencies.
    ^(Packages at: package asString) modules.
!

prerequisitesFor: package
    "Answer a Set of Strings containing the prerequisites for the given package"
    self refreshDependencies.
    ^(Packages at: package asString) prerequisites.
!

ignoreCallouts
    "Answer whether unavailable C callouts must generate errors or not."
    ^IgnoreCallouts
!

ignoreCallouts: aBoolean
    "Set whether unavailable C callouts must generate errors or not."
    IgnoreCallouts := aBoolean
!

flush
    "Set to reload the `packages.xml' file the next time it is needed."
    LoadDate := nil
!

refreshDependencies
    "Reload the `packages.xml' file in the image and kernel directories.
     The three possible places are 1) the system kernel directory's parent
     directory, 2) the local kernel directory's parent directory, 3) the
     local image directory (in order of decreasing priority).

     For a packages.xml found in the system kernel directory's parent
     directory, all three directories are searched.  For a packages.xml
     found in the local kernel directory's parent directory, only
     directories 2 and 3 are searched.  For a packages.xml directory in
     the local image directory, instead, only directory 3 is searched."
    | state |
    LoadDate isNil ifFalse: [
	self stillValid ifTrue: [ ^self ]
    ].

    LoadDate := Date dateAndTimeNow.
    Packages := LookupTable new.
    self
	processPackageFile: self systemPackageFileName
	baseDirectories: {
	    Directory systemKernel, '/..'. Directory kernel, '/..'.
	    Directory image }.
    self
	processPackageFile: self packageFileName
	baseDirectories: { Directory kernel, '/..'. Directory image }.
    self
	processPackageFile: self localPackageFileName
	baseDirectories: { Directory image }.
! !


!PackageLoader class methodsFor: 'loading'!

extractDependenciesFor: packagesList onError: aBlock
    "Answer an OrderedCollection containing all the packages which you
     have to load to enable the packages in packagesList, in an appropriate
     order. For example

     PackageLoader extractDependenciesFor: #('BloxTestSuite' 'Blox' 'Browser')

     on a newly built image will evaluate to an OrderedCollection containing
     'Kernel', 'Blox', 'BloxTestSuite' and 'Browser'. Note that
     Blox has been moved before BloxTestSuite.
     Pass an error message to aBlock if one or more packages need
     prerequisites which are not available."

    | toBeLoaded oldDep newDep |
    toBeLoaded := packagesList asOrderedCollection.
    oldDep := packagesList.
    [   newDep := Set new.
	oldDep do: [ :each |
	    (Smalltalk hasFeatures: each asSymbol) ifFalse: [
		(self isLoadable: each)
		    ifFalse: [ ^aBlock value: 'package not available: ', each ].
		newDep addAll: (self prerequisitesFor: each)
	    ]
	].

	"I don't think there will never be lots of packages in newDep (say
	 (more than 5), so I think it is acceptable to remove duplicates
	 this naive way.
	 Note that we remove duplicates from toBeLoaded so that prerequisites
	 are always loaded *before*."
	toBeLoaded removeAll: newDep ifAbsent: [ :doesNotMatter | ].
	newDep isEmpty
    ]   whileFalse: [
	toBeLoaded addAllFirst: newDep.
	
	"Proceed recursively with the prerequisites for newDep"
	oldDep := newDep.
    ].

    ^toBeLoaded
!

fileInPackage: package
    "File in the given package into GNU Smalltalk."
    self fileInPackages: {package}
!

fileInPackages: packagesList
    "File in all the packages in packagesList into GNU Smalltalk."
    | toBeLoaded |
    toBeLoaded := self
	extractDependenciesFor: packagesList
	onError: [ :errorMessage | ^self error: errorMessage ].
	
    toBeLoaded do: [ :each | self primFileInPackage: each ]
! !


!PackageLoader class methodsFor: 'testing'!

canLoad: package
    "Answer whether all the needed pre-requisites for package are available."
    self
	extractDependenciesFor: {package}
	onError: [ :errorMessage | ^false ].
    ^true
! !


!PackageLoader class methodsFor: 'private'!

hasCallout: feature
    "Private - Answer whether the given callout is present in GNU Smalltalk"
    ^IgnoreCallouts or: [ CFunctionDescriptor isFunction: feature]
!

isLoadable: feature
    "Private - Answer whether the packages file includes an entry for `feature'"
    self refreshDependencies.
    ^Packages includesKey: feature asString
!

primFileInPackage: package
    "Private - File in the given package without paying attention at
     dependencies and C callout availability"
    | dir |
    (Smalltalk hasFeatures: package asSymbol) ifTrue: [ ^self ].

    Transcript
	nextPutAll: 'Loading package ', package;
	nl.

    dir := Directory working.
    Directory working: (self directoryFor: package).
    (self librariesFor: package) do: [ :each | DLD addLibrary: each ].
    (self modulesFor: package) do: [ :each | DLD addModule: each ].

    (self calloutsFor: package) do: [ :func |
	(self hasCallout: func)
	    ifTrue: [ ^self error: 'C callout not available: ', func ]
    ].

    (self fileInsFor: package) do: [ :each | FileStream fileIn: each ].
    Directory working: dir.

    Smalltalk addFeature: package asSymbol
! !


!PackageLoader class methodsFor: 'private - packages file'!

systemPackageFileName
    ^Directory systemKernel, '/../packages.xml'
!

packageFileName
    ^Directory kernel, '/../packages.xml'
!

localPackageFileName
    ^Directory image, '/packages.xml'
!

printXmlOn: aStream
    "Print the XML source code for the information that the PackageLoader
     holds on aStream."
    | before |
    before := '<packages>'.
    Packages keys asSortedCollection do: [ :each |
	aStream nextPutAll: before; print: aStream.
	before := ''.
    ].
    aStream nextPutAll: '</packages>'!

rebuildPackageFile
    "Recreate the XML file from the information that the PackageLoader
     holds.  This is a dangerous method, also because the PackageLoader
     does not know about disabled packages."
    | file |
    [
	file := FileStream
	    open: Directory image, '/packages.xml'
	    mode: FileStream write.

	file nextPutAll: '<!-- GNU Smalltalk packages description file -->'.
	file nl; nl.
        self printXmlOn: file
    ] ensure: [ file close ]
!

processPackageFile: fileName baseDirectories: baseDirs
    "Private - Process the XML source in the packages file, creating
     Package objects along the way."

    | cdata file stack ch tag package |
    file := [ FileStream open: fileName mode: FileStream read ]
	on: Error
	do: [ :ex | ex return: nil ].

    file isNil ifTrue: [ ^self ].
    stack := OrderedCollection new.
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
		file close.
		^self error: 'error in packages file: unmatched end tag ', tag
	    ].

	    "I tried to put these from the most common to the least common"

	    tag = 'file' ifTrue: [ package files add: cdata ] ifFalse: [
	    tag = 'filein' ifTrue: [ package fileIns add: cdata ] ifFalse: [
	    tag = 'prereq' ifTrue: [ package prerequisites add: cdata ] ifFalse: [
	    tag = 'module' ifTrue: [ package modules add: cdata ] ifFalse: [
	    tag = 'directory' ifTrue: [ package directory: cdata ] ifFalse: [
	    tag = 'name' ifTrue: [ package name: cdata ] ifFalse: [
	    tag = 'library' ifTrue: [ package libraries add: cdata ] ifFalse: [
	    tag = 'package' ifTrue: [
		(package baseDirs: baseDirs)
		    ifTrue: [ Packages at: package name put: package ]] ifFalse: [
	    tag = 'built-file' ifTrue: [ package builtFiles add: cdata ] ifFalse: [
	    tag = 'callout' ifTrue: [ package callouts add: cdata ]]]]]]]]]].
	    cdata := nil.
	].
	ch isAlphaNumeric ifTrue: [
	    stack addLast: (tag := file upTo: $>).
	    tag = 'package' ifTrue: [ package := Package new ].
	    tag = 'disabled-package' ifTrue: [ package := Package new ].
	    cdata := nil
	].
    ].
    file close.
    stack isEmpty ifFalse: [
	self error: 'error in packages file: unmatched start tags', stack asArray printString
    ].
!

stillValid
    ^{ self packageFileName. self localPackageFileName. self systemPackageFileName } 
	allSatisfy: [ :name || file |
	    file := File name: name.
	    file exists not or: [ file lastModifyTime < LoadDate ]
	]
! !

PackageLoader ignoreCallouts: false!
