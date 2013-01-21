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

FilePath subclass: FileWrapper [
    | file |
    
    <category: 'Streams-Files'>
    <comment: 'FileWrapper gives information for
virtual files that refer to a real file on disk.'>

    FileWrapper class >> initialize [
	"Register the receiver with ObjectMemory"

	<category: 'initializing'>
	ObjectMemory addDependent: self.
    ]

    FileWrapper class >> update: aspect [
	"Private - Remove the files before quitting, and register the virtual
	 filesystems specified by the subclasses upon image load."

	<category: 'initializing'>
	aspect == #aboutToQuit ifTrue: [self broadcast: #release]
    ]

    FileWrapper class >> on: file [
	"Create an instance of this class representing the contents of the given
	 file, under the virtual filesystem fsName."

	<category: 'instance creation'>
	^self new file: file
    ]

    = aFile [
	"Answer whether the receiver represents the same file as the receiver."

	<category: 'basic'>
	^self class == aFile class and: [ self file = aFile file ]
    ]

    hash [
	"Answer a hash value for the receiver."

	<category: 'basic'>
	^self file hash
    ]

    asString [
	"Answer the string representation of the receiver's path."
	<category: 'accessing'>
	^self file asString
    ]

    name [
	"Answer the full path to the receiver."
	<category: 'accessing'>
	^self file name
    ]

    isAbsolute [
        "Answer whether the receiver identifies an absolute path."

	^self file isAbsolute
    ]

    full [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	self isAbsolute ifTrue: [ ^self ].
	^self class on: self file full
    ]

    mode [
	"Answer the permission bits for the file identified by the receiver"

	<category: 'delegation'>
	^self file mode
    ]

    mode: anInteger [
	"Answer the permission bits for the file identified by the receiver"

	<category: 'delegation'>
	self file mode: anInteger
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	^self file size
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'delegation'>
	^self file lastAccessTime
    ]

    exists [
        "Answer whether a file with the name contained in the receiver
	 does exist."

        <category: 'testing'>
        ^self file exists
    ]

    isAbsolute [
        "Answer whether the receiver identifies an absolute path."

        <category: 'testing'>
        ^self file isAbsolute
    ]

    isReadable [
        "Answer whether a file with the name contained in the receiver does exist
         and is readable"

        <category: 'testing'>
        ^self file isReadable
    ]

    isWriteable [
        "Answer whether a file with the name contained in the receiver does exist
         and is writeable"

        <category: 'testing'>
        ^self file isWriteable
    ]

    isExecutable [
        "Answer whether a file with the name contained in the receiver does exist
         and is executable"

        <category: 'testing'>
        ^self file isExecutable
    ]

    isAccessible [
        "Answer whether a directory with the name contained in the receiver does
         exist and can be accessed"

        <category: 'testing'>
        ^self file isAccessible
    ]

    isDirectory [
        "Answer whether a file with the name contained in the receiver
	 does exist identifies a directory."

        <category: 'testing'>
        ^self file isDirectory
    ]

    isSymbolicLink [
        "Answer whether a file with the name contained in the receiver
	 does exist and identifies a symbolic link."

        <category: 'testing'>
        ^self file isSymbolicLink
    ]

    owner: ownerString group: groupString [
	"Set the receiver's owner and group to be ownerString and groupString."

        <category: 'accessing'>
        self file owner: ownerString group: groupString
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
        "Update the timestamps of the file corresponding to the receiver, to be
         accessDateTime and modifyDateTime."

        <category: 'accessing'>
        self file lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'delegation'>
	^self file lastChangeTime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'delegation'>
	^self file creationTime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'delegation'>
	^self file lastModifyTime
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'delegation'>
	^self file isReadable
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'delegation'>
	^self file isWritable
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'delegation'>
	^self file isExecutable
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'delegation'>
	^self file 
	    open: class
	    mode: mode
	    ifFail: aBlock
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'delegation'>
	self file remove
    ]

    symlinkAs: destName [
        "Create destName as a symbolic link of the receiver.  The appropriate
         relative path is computed automatically."

        <category: 'file operations'>
        ^self file symlinkAs: destName
    ]

    pathFrom: dirName [
        "Compute the relative path from the directory dirName to the receiver"

        <category: 'file operations'>
        ^self file pathFrom: dirName
    ]

    symlinkFrom: srcName [
        "Create the receiver as a symbolic link from srcName (relative to the
         path of the receiver)."

        <category: 'file operations'>
        ^self file symlinkFrom: srcName
    ]

    renameTo: newName [
        "Rename the file identified by the receiver to newName"

        <category: 'file operations'>
        ^self file renameTo: newName
    ]

    pathTo: destName [
        "Compute the relative path from the receiver to destName."

        <category: 'accessing'>
        ^self file pathTo: destName
    ]

    at: aName [
        "Answer a File or Directory object as appropriate for a file named
         'aName' in the directory represented by the receiver."

        <category: 'accessing'>
        ^self class on: (self file at: aName)
    ]

    namesDo: aBlock [
        "Evaluate aBlock once for each file in the directory represented by the
         receiver, passing its name."

        <category: 'enumerating'>
        self file namesDo: aBlock
    ]

    file [
	<category: 'private'>
	^file
    ]

    file: aFilePath [
	<category: 'private'>
	file := aFilePath.
    ]
]

]
