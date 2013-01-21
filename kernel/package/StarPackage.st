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

