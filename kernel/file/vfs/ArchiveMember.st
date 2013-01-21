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

FilePath subclass: ArchiveMember [
    | archive name mode size stCtime stMtime stAtime |
    
    <category: 'Streams-Files'>
    <comment: 'TmpFileArchiveMember is a handler
class for members of archive files that creates temporary files when
extracting files from an archive.'>

    = aFile [
	"Answer whether the receiver represents the same file as the receiver."

	<category: 'basic'>
	^self class == aFile class and: [ self archive = aFile archive
	    and: [ self name = aFile name ] ]
    ]

    hash [
	"Answer a hash value for the receiver."

	<category: 'basic'>
	^self archive hash bitXor: self name hash
    ]

    archive: anArchiveFile [
	"Set the archive of which the receiver is a member."

	<category: 'initializing'>
	archive := anArchiveFile
    ]

    full [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	^self archive full at: self name
    ]

    fillFrom: data [
	"Called back by the receiver's archive when the ArchiveMember
	 asks for file information."

	<category: 'initializing'>
	self 
	    size: (data at: 2)
	    stMtime: (data at: 3)
	    mode: (data at: 4)
    ]

    size: bytes stMtime: mtime mode: modeBits [
	"Set the file information for the receiver."

	<category: 'initializing'>
	size := bytes.
	stCtime := self archive lastModifyTime.
	stMtime := mtime.
	stAtime := self archive lastAccessTime.
	mode := modeBits
    ]

    size: bytes stCtime: ctime stMtime: mtime stAtime: atime mode: modeBits [
	"Set the file information for the receiver."

	<category: 'initializing'>
	size := bytes.
	stCtime := ctime.
	stMtime := mtime.
	stAtime := atime.
	mode := modeBits
    ]

    asString [
	"Answer the name of the file identified by the receiver as answered by
	 File>>#name."

	<category: 'accessing'>
	^self name
    ]

    displayOn: aStream [
	"Print a representation of the file identified by the receiver."
	self archive displayOn: aStream.
	aStream nextPut: $/.
	super displayOn: aStream
    ]

    isAbsolute [
        "Answer whether the receiver identifies an absolute path."

	^self archive isAbsolute
    ]

    name [
	"Answer the receiver's file name."

	<category: 'accessing'>
	^name
    ]

    name: aName [
	"Set the receiver's file name to aName."

	<category: 'accessing'>
	name := aName
    ]

    archive [
	"Answer the archive of which the receiver is a member."

	<category: 'accessing'>
	^archive
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	size isNil ifTrue: [self refresh].
	^size
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	stAtime isNil ifTrue: [self refresh].
	^stAtime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	stCtime isNil ifTrue: [self refresh].
	^stCtime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	stCtime isNil ifTrue: [self refresh].
	^stCtime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	stMtime isNil ifTrue: [self refresh].
	^stMtime
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	self archive fillMember: self
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	^self archive fillMember: self
    ]

    mode [
	"Answer the octal permissions for the file."

	<category: 'testing'>
	size isNil ifTrue: [self refresh].
	^mode bitAnd: 4095
    ]

    mode: mode [
	"Set the octal permissions for the file to be `mode'."

	<category: 'testing'>
	self archive member: self mode: (mode bitAnd: 4095)
    ]

    isSymbolicLink [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a symbolic link."

	<category: 'testing'>
	size isNil ifTrue: [self refresh].
	^(mode bitAnd: 8r170000) = 8r120000
    ]

    isDirectory [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a directory."

	<category: 'testing'>
	size isNil ifTrue: [self refresh].
	^(mode bitAnd: 8r170000) = 8r40000
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	^true
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	^true
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	^false
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does exist
	 and is accessible"

	<category: 'testing'>
	^true
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    update: aspect [
	"Private - Update the in-archive version of the file before closing."

	<category: 'file operations'>
	aspect == #beforeClosing 
	    ifTrue: [self archive updateMember: self] aspect == #afterClosing
	    ifTrue: 
		[self archive refresh.
		self refresh]
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'file operations'>
	self archive removeMember: self.
	File checkError
    ]

    renameTo: newFileName [
	"Rename the file with the given path name oldFileName to newFileName"

	<category: 'file operations'>
	self notYetImplemented
    ]

    at: aName [
	"Answer a FilePath for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	^self archive at: (File append: aName to: self name)
    ]

    , aName [
	"Answer an object of the same kind as the receiver, whose name
	 is suffixed with aName."

	^self archive at: (self name, aName)
    ]

    createDirectory: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'directory operations'>
	self archive createDirectory: (File append: dirName to: self name)
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'directory operations'>
	self archive member: self do: aBlock
    ]
]

]

