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

