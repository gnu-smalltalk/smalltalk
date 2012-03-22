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


Namespace current: Kernel [

VFS.FileWrapper subclass: RecursiveFileWrapper [
    <category: 'Streams-Files'>

     do: aBlock [
	"Same as the wrapped #do:, but reuses the file object for efficiency."

	<category: 'enumerating'>
	aBlock value: self file.
        self file namesDo: 
                [:name |
                | f |
		(#('.' '..') includes: name) ifFalse: [
		    f := self at: name. 
		    aBlock value: f file.
		    (f isDirectory and: [f isSymbolicLink not])
                        ifTrue: [f do: aBlock]]]
     ]

     namesDo: aBlock prefixLength: anInteger [
	"Same as the wrapped #namesDo:, but navigates the entire directory
	 tree recursively.  Since the objects created by #at: also contain the
	 path to the receiver, anInteger is used to trim it."

	<category: 'private'>
        self file namesDo: 
                [:name |
                | f |
		(#('.' '..') includes: name) ifFalse: [
		    f := self at: name. 
                    aBlock value: (f asString copyFrom: anInteger).
		    (f isDirectory and: [f isSymbolicLink not])
                        ifTrue: [f
			    namesDo: aBlock
			    prefixLength: anInteger ]]]
     ]

     namesDo: aBlock [
	"Same as the wrapped #namesDo:, but navigates the entire directory
	 tree recursively."

	<category: 'enumerating'>
        | n base |
	aBlock value: '.'.
        base := self asString.
        n := base last = Directory pathSeparator
            ifTrue: [ base size + 1 ]
            ifFalse: [ base size + 2 ].
        self namesDo: aBlock prefixLength: n
     ]

     remove [
	"Removes the entire directory tree recursively."

	<category: 'file operations'>
	self isDirectory ifTrue: [
            self file namesDo: 
                [:name |
                | f |
                f := self at: name. 
                f isDirectory 
                    ifTrue:
                        [((#('.' '..') includes: name) or: [f isSymbolicLink])
                            ifFalse: [f all remove]]
		    ifFalse: [f remove]]].
	super remove
     ]

    isFileSystemPath [
	"Answer whether the receiver corresponds to a real filesystem path."

	<category: 'testing'>
	^self file isFileSystemPath
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Update the timestamps of all files in the tree to be
	 accessDateTime and modifyDateTime."

        <category: 'accessing'>
	self isDirectory ifFalse: [
	    ^super lastAccessTime: accessDateTime lastModifyTime: modifyDateTime ].
        self do: [ :each |
	    each lastAccessTime: accessDateTime lastModifyTime: modifyDateTime ]
    ]

    owner: ownerString group: groupString [
	"Set the owner and group for all files and directories in the tree."

        <category: 'accessing'>
	self isDirectory ifFalse: [
	    ^super owner: ownerString group: groupString ].
	"These special calls cache the uid and gid to avoid repeated lookups."
	[
	    File setOwnerFor: nil owner: ownerString group: groupString.
            self do: [ :each | each owner: ownerString group: groupString ]
	] ensure: [ File setOwnerFor: nil owner: nil group: nil ]
    ]

    mode: anInteger [
	"Set the mode to be anInteger for all files in the tree.  Directory
	 modes are left unchanged."

        <category: 'accessing'>
	self isDirectory ifFalse: [ ^super mode: anInteger ].

	self do: [ :each | each isDirectory ifFalse: [ each mode: anInteger ] ]
    ]

    fileMode: fMode directoryMode: dMode [
	"Set the mode to be fMode for all files in the tree, and dMode for
	 all directories in the tree."

        <category: 'accessing'>
	self isDirectory ifFalse: [ ^super mode: fMode ].

	super mode: dMode.
	self isDirectory ifTrue: [
	    self do: [ :each |
		each mode: (each isDirectory
				ifTrue: [ dMode ]
				ifFalse: [ fMode ]) ] ]
    ]
]

]

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



Namespace current: VFS [

ArchiveMember subclass: TmpFileArchiveMember [
    | file |
    
    <category: 'Streams-Files'>
    <comment: nil>

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	"Remove the file that was temporarily holding the file contents"

	<category: 'finalization'>
	self extracted ifTrue: [ file remove. file := nil ].
	super release
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'directory operations'>
	| fileStream |
	self file isNil ifTrue: [^aBlock value].
	fileStream := file open: class mode: mode ifFail: [^aBlock value].
	mode == FileStream read ifFalse: [fileStream addDependent: self].
	fileStream setFile: self.
	^fileStream
    ]

    extracted [
	"Answer whether the file has already been extracted to disk."
	^file notNil
    ]

    file [
	"Answer the real file name which holds the file contents,
	 or nil if it does not apply."

	<category: 'directory operations'>
	file isNil ifFalse: [^file].
	self exists ifFalse: [^nil].
	file := self archive extractMember: self.
	^file
    ]
]

]


