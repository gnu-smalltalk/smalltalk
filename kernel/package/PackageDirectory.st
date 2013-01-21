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

