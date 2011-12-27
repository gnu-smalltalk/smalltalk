"======================================================================
|
|   Virtual File System extfs-compatible handler
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



ArchiveFile subclass: ExternalArchiveFile [
    | command |
    
    <comment: 'ExternalArchiveFile
allows for easy implementation of archive files (for example,
transparent unzipping and untarring) with a single shell script.
It implements a protocol that that is compatible with the Midnight
Commander and with GNOME VFS.'>
    <category: 'Streams-Files'>

    ExternalArchiveFile class [
	| fileTypes |
	
    ]

    ExternalArchiveFile class >> update: aSymbol [
	aSymbol == #returnedFromSnapshot ifTrue: [ self release ].
    ]

    ExternalArchiveFile class >> release [
	fileTypes := nil
    ]

    ExternalArchiveFile class >> refreshFileSystemList [
	"Answer the virtual file systems that can be processed by this
	 subclass.  These are given by the names of the executable
	 files in the `vfs' subdirectory of the image directory (if
	 the image is not the global installed image), in the
	 `/usr/local/libexec/smalltalk/vfs' directory and in the
	 `.st/vfs' subdirectory of the home directory."

	<category: 'registering'>
	fileTypes := LookupTable new.
	[self fileSystemsIn: Directory libexec / 'vfs'] on: Error
	    do: [:ex | ex pass].
	[self fileSystemsIn: Directory userBase / 'vfs'] on: Error
	    do: [:ex | ex return].
	Smalltalk imageLocal 
	    ifTrue: 
		[[self fileSystemsIn: Directory image / 'vfs'] on: Error
		    do: [:ex | ex return]].
	^fileTypes keys asSet
    ]

    ExternalArchiveFile class >> fileSystemsIn: dir [
	"Registers the executable files in the given directory to be used
	 to resolve a virtual file system."

	<category: 'registering'>
	dir isDirectory ifFalse: [^self].
	dir do: 
		[:each | 
		each isExecutable
		    ifTrue: [fileTypes at: each stripPath put: each asString]]
    ]

    ExternalArchiveFile class >> commandFor: fileSystem [
	<category: 'registering'>
	fileTypes isNil ifTrue: [ self refreshFileSystemList ].
	^fileTypes at: fileSystem asString
    ]

    command: aString [
	<category: 'string'>

	command := aString
    ]

    createDirectory: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'members'>
	Smalltalk 
	    system: '%1 mkdir %2 %3'
	    withArguments: {command.
			self file name.
			dirName}
    ]

    full [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	self isAbsolute ifTrue: [ ^self ].
	^super full
	    command: command;
	    yourself
    ]

    member: anArchiveMember mode: bits [
	"Set the permission bits for the file in anArchiveMember."

	<category: 'ArchiveMember protocol'>
	self notYetImplemented
    ]

    extractMember: anArchiveMember into: file [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'ArchiveMember protocol'>
	Smalltalk 
	    system: '%1 copyout %2 %3 %4'
	    withArguments: {command.
			self file name.
			anArchiveMember name.
			file name}
    ]

    removeMember: anArchiveMember [
	"Remove the member represented by anArchiveMember."

	<category: 'ArchiveMember protocol'>
	| subcmd |
	subcmd := anArchiveMember isDirectory 
		    ifTrue: ['rmdir']
		    ifFalse: ['rm'].
	Smalltalk 
	    system: '%1 %2 %3 %4'
	    withArguments: {command.
			subcmd.
			self file name.
			anArchiveMember name}
    ]

    updateMember: anArchiveMember [
	"Update the member represented by anArchiveMember by
	 copying the file into which it was extracted back to the
	 archive."

	<category: 'ArchiveMember protocol'>
	Smalltalk 
	    system: '%1 copyin %2 %3 %4'
	    withArguments: {command.
			self file name.
			anArchiveMember name.
			anArchiveMember file name}
    ]

    command [
	"Return the script that is invoked by the receiver."

	<category: 'ArchiveMember protocol'>
	^self class fileTypes at: self fsName
    ]

    fileData [
	"Extract the directory listing from the archive"

	<category: 'ArchiveMember protocol'>
	^Generator on: 
		[:gen | 
		| pipe |
		pipe := FileStream popen: command , ' list ' , self file name
			    dir: FileStream read.
		pipe linesDo: 
			[:l | 
			| line mode size path date |
			line := l readStream.
			mode := line next: 10.
			line peek isSeparator ifFalse: [line skipTo: Character space].
			line skipSeparators.

			"Attributes, number of links, owner, group"
			3 timesRepeat: 
				[line skipTo: Character space.
				line skipSeparators].
			size := Number readFrom: line.	"File size"
			line skipSeparators.
			date := DateTime readFrom: line.	"Date"
			line skipSeparators.
			path := line upToAll: ' -> '.	"Path"
			gen yield: 
				{path.
				size.
				date.
				mode}].
		pipe close]
    ]
]


FilePath extend [
    archive: kind [
	"Return a FilePath for the receiver, interpreted as an archive file
	 of the given kind."
	<category: 'factory'>
	^(VFS.ExternalArchiveFile on: self)
	    command: (VFS.ExternalArchiveFile commandFor: kind);
	    yourself
    ]

    zip [
	"Return a FilePath for the receiver, interpreted as an archive file
	 of the given kind."
	<category: 'factory'>
	^self archive: 'uzip'
    ]
]
