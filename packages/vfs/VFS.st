"======================================================================
|
|   Virtual File System extfs-compatible handler
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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

ArchiveFileHandler subclass: #ExternalArchiveFileHandler
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ExternalArchiveFileHandler class
	instanceVariableNames: 'fileTypes'!

ExternalArchiveFileHandler comment: 'ExternalArchiveFileHandler
allows for easy implementation of archive files (for example,
transparent unzipping and untarring) with a single shell script.
It implements a protocol that that is compatible with the Midnight
Commander and with GNOME VFS.'!

!ExternalArchiveFileHandler class methodsFor: 'registering'!

priority
    ^-5!

fileSystems
    "Answer the virtual file systems that can be processed by this subclass.
     These are given by the names of the executable files in the `vfs'
     subdirectory of the image directory, of the parent of the kernel
     directory and (if the image is not the global installed image)
     of the `.st' directory in the home directory."
    fileTypes := LookupTable new. 
    [ self fileSystemsIn: Directory libexec, '/vfs' ]
	on: Error do: [ :ex | ex return ].
    [ self fileSystemsIn: Directory userBase, '/vfs' ]
	on: Error do: [ :ex | ex return ].
    Smalltalk imageLocal ifTrue: [
        [ self fileSystemsIn: Directory image, '/vfs' ]
	    on: Error do: [ :ex | ex return ] ].
	
    ^fileTypes keys asSet!

fileSystemsIn: path
    "Registers the executable files in the given directory to be used
     to resolve a virtual file system."
    | dir |
    dir := RealFileHandler for: path.
    dir exists ifFalse: [ ^self ].
    dir do: [ :each |
	(File isExecutable: path, '/', each)
	    ifTrue: [ fileTypes at: each put: path, '/', each ]
    ]!

fileTypes
    ^fileTypes!

release
    "Avoid that paths stay in the image file"
    fileTypes := nil.
    super release! !

!ExternalArchiveFileHandler methodsFor: 'members'!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."

    Smalltalk system: ('%1 mkdir %2 %3' % { self command. self realFileName. dirName })! !


!ExternalArchiveFileHandler methodsFor: 'ArchiveMemberHandler protocol'!

extractMember: anArchiveMemberHandler into: file
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."

    Smalltalk system: ('%1 copyout %2 %3 %4'
	% { self command. self realFileName. anArchiveMemberHandler name. file name })!

removeMember: anArchiveMemberHandler
    "Remove the member represented by anArchiveMemberHandler."

    | subcmd |
    subcmd := anArchiveMemberHandler isDirectory
	ifTrue: [ 'rmdir' ]
	ifFalse: [ 'rm' ].

    Smalltalk system: ('%1 %2 %3 %4'
	% { self command. subcmd. self realFileName. anArchiveMemberHandler name. })!

updateMember: anArchiveMemberHandler
    "Update the member represented by anArchiveMemberHandler by
     copying the file into which it was extracted back to the
     archive."

    Smalltalk system: ('%1 copyin %2 %3 %4'
	% { self command. self realFileName. anArchiveMemberHandler name.
	    anArchiveMemberHandler realFileName })!

command
    "Return the script that is invoked by the receiver."
    ^self class fileTypes at: self fsName!

files
    "Extract the directory listing from the archive"

    ^Generator on: [ :gen || pipe |
        pipe := FileStream
	    popen: self command, ' list ', self realFileName
	    dir: FileStream read.

        pipe linesDo: [ :l || line isDir size path date |
	    line := l readStream.
	    isDir := line next = $d.
	    "Attributes, number of links, owner, group"
	    4 timesRepeat: [
		line skipTo: Character space.
	        line skipSeparators ].

	    size := Number readFrom: line.		"File size"
	    line skipSeparators.
	    date := DateTime readFrom: line.		"Date"
	    line skipSeparators.
	    path := line upToAll: ' -> '.		"Path"

            gen yield: { path. size. date. isDir } ].

        pipe close ]! !

ExternalArchiveFileHandler register!
