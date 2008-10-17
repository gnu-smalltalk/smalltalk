"======================================================================
|
|   FileSegment Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2007,2008
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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



Object subclass: FileSegment [
    | file startPos size |
    
    <category: 'Language-Implementation'>
    <comment: 'My instances represent sections of files.  I am primarily used by the
compiler to record source code locations.  I am not a part of the normal
Smalltalk-80 kernel; I am specific to the GNU Smalltalk implementation.'>

    FileSegment class >> relocate [
	"Remove the kernel path from all paths that start with it.  Needed to
	 support $(DESTDIR) and relocatable installation."

	<category: 'installing'>
	| map startPath startPathString |
	map := IdentityDictionary new.
	startPath := Directory kernel asString.
	self allInstancesDo: [:each | each relocateFrom: startPath map: map].
	Directory kernel = Directory systemKernel ifTrue: [KernelFilePath := nil].
    ]

    FileSegment class >> on: aFile startingAt: startPos for: sizeInteger [
	"Create a new FileSegment referring to the contents of the given file,
	 from the startPos-th byte and for sizeInteger bytes.  Note that
	 FileSegments should always be created with full paths because
	 relative paths are interpreted to be relative to the kernel
	 directory."

	<category: 'basic'>
	^self new 
	    setFile: aFile
	    start: startPos
	    size: sizeInteger
    ]

    copyFrom: from to: to [
	"Answer a String containing the given subsegment of the file.  As for
	 streams, from and to are 0-based."

	<category: 'basic'>
	(to between: 0 and: size - 1) 
	    ifFalse: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: to
		    mustBeBetween: 0
		    and: size - 1].
	(from between: 0 and: to) 
	    ifFalse: 
		[(from = to) + 1 ifTrue: [^self species new].
		^SystemExceptions.ArgumentOutOfRange 
		    signalOn: from
		    mustBeBetween: 0
		    and: to + 1].
	^self 
	    withFileDo: [:fileStream | fileStream copyFrom: startPos + from to: startPos + to]
    ]

    asString [
	"Answer a String containing the required segment of the file"

	<category: 'basic'>
	^self 
	    withFileDo: [:fileStream | fileStream copyFrom: startPos to: startPos + size - 1]
    ]

    relocateFrom: startPath map: map [
	"If the path starts with startPath, remove that part of the path.
	 map is a Dictionary that is used so that equal filenames stay equal,
	 without increasing the amount of memory that the image uses."

	<category: 'basic'>
	file := map at: self fileName
		    ifAbsent: 
			[(self fileName startsWith: startPath) 
			    ifTrue: 
				[map at: self fileName
				    put: (file copyFrom: startPath size + 2)]
			    ifFalse: [file]]
    ]

    withFileDo: aBlock [
	"Evaluate aBlock passing it the FileStream in which the segment
	 identified by the receiver is stored"

	<category: 'basic'>
	^self file withReadStreamDo: aBlock
    ]

    file [
	"Answer the File object for the file containing the segment"

	<category: 'basic'>
	| f |
	f := file asFile.
	f isRelative ifTrue: [ f := Directory kernel / file ].
	^f
    ]

    printedFileName [
	"Answer a printed representation of the file containing the segment.
	 While introducing some ambiguity, this representation is compact
	 eliminates the path for kernel files, and produces a relative path
	 from the current working directory for other files."

	<category: 'printing'>
	| f |
	f := file asFile.
	f isRelative
	    ifTrue: [ ^f stripPath asString ].
	f isFileSystemPath
	    ifFalse: [ ^'%1/%2' % { f archive displayString copyAfterLast: $/. f name } ].
	^(f pathFrom: Directory working) asString
    ]

    fileName [
	"Answer the name of the file containing the segment"

	<category: 'basic'>
	^file asString
    ]

    filePos [
	"Answer the position in the file where the segment starts"

	<category: 'basic'>
	^startPos
    ]

    size [
	"Answer the length of the segment"

	<category: 'basic'>
	^size
    ]

    = aFileSegment [
	"Answer whether the receiver and aFileSegment are equal."

	<category: 'equality'>
	(aFileSegment isKindOf: FileSegment) ifFalse: [^false].
	self == aFileSegment ifTrue: [^true].
	^self fileName = aFileSegment fileName 
	    and: [startPos = aFileSegment filePos and: [size = aFileSegment size]]
    ]

    hash [
	"Answer an hash value for the receiver."

	<category: 'equality'>
	^self fileName hash bitXor: startPos + size
    ]

    species [
	<category: 'private'>
	^String
    ]

    getFile [
	<category: 'private'>
	^file
    ]

    setFile: aFileName start: startingPos size: sizeInteger [
	<category: 'private'>
	file := aFileName.
	startPos := startingPos.
	size := sizeInteger
    ]
]

