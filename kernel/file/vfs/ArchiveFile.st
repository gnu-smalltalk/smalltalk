"======================================================================
|
|   Virtual File System layer definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2005, 2007, 2008, 2009 Free Software Foundation, Inc.
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



Namespace current: VFS [

FileWrapper subclass: ArchiveFile [
    | tmpFiles topLevelFiles allFiles extractedFiles |
    
    <category: 'Streams-Files'>
    <comment: 'ArchiveFile handles
virtual filesystems that have a directory structure of
their own.  The directories and files in the archive are
instances of ArchiveMember, but the functionality
resides entirely in ArchiveFile because the members
will still ask the archive to get directory information
on them, to extract them to a real file, and so on.'>

    displayOn: aStream [
	"Print a representation of the file identified by the receiver."
	super displayOn: aStream.
	aStream nextPut: $#.
	self class printOn: aStream
    ]

    isDirectory [
	"Answer true.  The archive can always be considered as a directory."

	<category: 'querying'>
	^true
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'querying'>
	^self isReadable
    ]

    at: aName [
	"Answer a FilePath for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	| handler data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: aName ifAbsent: [^nil].
	handler := data at: 5 ifAbsent: [nil].
	handler isNil ifFalse: [^handler].
	tmpFiles isNil 
	    ifTrue: 
		[tmpFiles := LookupTable new.
		FileWrapper addDependent: self.
		self addToBeFinalized].
	^tmpFiles at: aName
	    ifAbsentPut: 
		[(TmpFileArchiveMember new)
		    name: aName;
		    archive: self]
    ]

    nameAt: aString [
        "Answer a FilePath for a file named `aName' residing in the directory
         represented by the receiver."

        <category: 'directory operations'>
        ^aString
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'directory operations'>
	topLevelFiles isNil ifTrue: [self refresh].
	topLevelFiles do: aBlock
    ]

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	<category: 'directory operations'>
	tmpFiles isNil 
	    ifFalse: 
		[tmpFiles do: [:each | each release].
		tmpFiles := nil].
	extractedFiles isNil 
	    ifFalse: 
		[extractedFiles do: [:each | self primUnlink: each].
		extractedFiles := nil].
	super release
    ]

    fillMember: anArchiveMember [
	"Extract the information on anArchiveMember.  Answer
	 false if it actually does not exist in the archive; otherwise,
	 answer true after having told anArchiveMember about them
	 by sending #size:stCtime:stMtime:stAtime:isDirectory: to it."

	<category: 'ArchiveMember protocol'>
	| data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: anArchiveMember name ifAbsent: [nil].
	data isNil ifTrue: [^false].
	anArchiveMember fillFrom: data.
	^true
    ]

    member: anArchiveMember do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by
	 anArchiveMember, passing its name."

	<category: 'ArchiveMember protocol'>
	| data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: anArchiveMember name ifAbsent: [nil].
	data isNil ifTrue: [^SystemExceptions.FileError signal: 'File not found'].
	(data at: 1) isNil 
	    ifTrue: [^SystemExceptions.FileError signal: 'Not a directory'].
	(data at: 1) do: aBlock
    ]

    refresh [
	"Extract the directory listing from the archive"

	<category: 'ArchiveMember protocol'>
	| pipe line parentPath name current currentPath directoryTree directory |
	super refresh.
	current := currentPath := nil.
	allFiles := LookupTable new.
	directoryTree := LookupTable new.
	self fileData do: 
		[:data | 
		| path size date mode member |
		mode := self convertMode: (data at: 4).
		data at: 4 put: mode.
		path := data at: 1.
		path last = $/ ifTrue: [path := path copyFrom: 1 to: path size - 1].

		"Look up the tree for the directory in which the file resides.
		 We keep a simple 1-element cache."
		parentPath := File pathFor: path.
		name := File stripPathFrom: path.
		parentPath = currentPath 
		    ifFalse: 
			[currentPath := parentPath.
			current := self findDirectory: path into: directoryTree].

		"Create an item in the tree for directories, and
		 add an association to the allFiles SortedCollection"
		directory := (mode bitAnd: 8r170000) = 8r40000 
			    ifTrue: [current at: name put: LookupTable new]
			    ifFalse: [current at: name put: nil].
		data at: 1 put: directory.
		allFiles at: path put: data.
		member := data at: 5 ifAbsent: [nil].
		member notNil ifTrue: [member fillFrom: data]].

	"Leave the LookupTables to be garbage collected, we are now interested
	 in the file names only."
	topLevelFiles := directoryTree keys asArray.
	allFiles
	    do: [:data | (data at: 1) isNil ifFalse: [data at: 1 put: (data at: 1) keys asArray]]
    ]

    member: anArchiveMember mode: bits [
	"Set the permission bits for the file in anArchiveMember."

	<category: 'ArchiveMember protocol'>
	self subclassResponsibility
    ]

    removeMember: anArchiveMember [
	"Remove the member represented by anArchiveMember."

	<category: 'ArchiveMember protocol'>
	self subclassResponsibility
    ]

    updateMember: anArchiveMember [
	"Update the member represented by anArchiveMember by
	 copying the file into which it was extracted back to the
	 archive."

	<category: 'ArchiveMember protocol'>
	self subclassResponsibility
    ]

    extractMember: anArchiveMember [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'TmpFileArchiveMember protocol'>
	extractedFiles isNil ifTrue: [extractedFiles := IdentityDictionary new].
	^extractedFiles at: anArchiveMember
	    ifAbsentPut: 
		[| temp |
		temp := FileStream openTemporaryFile: Directory temporary , '/vfs'.
		self extractMember: anArchiveMember into: temp.
		File name: temp name]
    ]

    extractMember: anArchiveMember into: file [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'TmpFileArchiveMember protocol'>
	self subclassResponsibility
    ]

    convertMode: mode [
	"Convert the mode from a string, character or boolean to an octal number."

	<category: 'private'>
	mode isNumber ifTrue: [^mode].
	mode isString ifTrue: [^self convertModeString: mode].
	mode isCharacter ifTrue: [^self convertMode: mode == $d].
	^mode ifTrue: [8r40755] ifFalse: [8r644]
    ]

    convertModeString: modeString [
	"Convert the mode from a string to an octal number."

	<category: 'private'>
	| mode |
	mode := 0.
	(modeString at: 1) = $l ifTrue: [mode := 8r120000].
	(modeString at: 1) = $d ifTrue: [mode := 8r40000].
	(modeString at: 4) asLowercase = $s ifTrue: [mode := mode + 8r4000].
	(modeString at: 7) asLowercase = $s ifTrue: [mode := mode + 8r2000].
	(modeString at: 10) asLowercase = $t ifTrue: [mode := mode + 8r1000].
	modeString 
	    from: 2
	    to: 10
	    keysAndValuesDo: [:i :ch | ch isLowercase ifTrue: [mode := mode setBit: 11 - i]].
	^mode
    ]

    findDirectory: path into: tree [
	"Look up into tree (which is a tree of Dictionaries) the directory
	 that is the parent of the file named `path'."

	<category: 'private'>
	| current last |
	current := tree.
	last := 1.
	path keysAndValuesDo: 
		[:i :each | 
		| element |
		each = $/ 
		    ifTrue: 
			[last = i 
			    ifFalse: 
				[element := path copyFrom: last to: i - 1.
				current := current at: element
					    ifAbsentPut: 
						["The list command might output files but not
						 directories.  No problem, we create them along
						 the way."

						| directory |
						directory := LookupTable new.
						allFiles at: (path copyFrom: 1 to: i - 1)
						    put: 
							{directory. 0.
							self creationTime.
							self mode bitOr: 8r40111}.
						directory]].
			last := i + 1]].
	^current
    ]
]

]
