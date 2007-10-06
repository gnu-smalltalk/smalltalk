"======================================================================
|
|   Virtual File System layer definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2005, 2007 Free Software Foundation, Inc.
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

Object subclass: VFSHandler [
    
    <category: 'Streams-Files'>
    <comment: 'VFSHandler is the abstract class for
implementations of File and Directory.  These classes only
delegate to the appropriate handler, which is in charge of
actually accessing or ``molding'''' the filesystem.'>

    Registry := nil.

    VFSHandler class >> for: fileName [
	"Answer the (real or virtual) file handler for the file named fileName"

	<category: 'instance creation'>
	| pos1 fsName pos2 subPath file result |
	file := fileName.
	pos1 := file indexOf: $#.
	pos1 = 0 ifTrue: [^RealFileHandler new name: file].
	result := RealFileHandler new name: (file copyFrom: 1 to: pos1 - 1).
	
	["Extract the file name and path, and resolve the first virtual
	 file path (for example abc#uzip/def in abc#uzip/def#ugz)"

	fsName := file copyFrom: pos1 + 1
		    to: (file 
			    indexOf: $/
			    startingAt: pos1
			    ifAbsent: [file size + 1]) - 1.
	pos2 := file 
		    indexOf: $#
		    startingAt: pos1 + 1
		    ifAbsent: [file size + 1].
	subPath := pos1 + fsName size + 2 >= pos2 
		    ifTrue: [nil]
		    ifFalse: [file copyFrom: pos1 + fsName size + 2 to: pos2 - 1].
	pos2 > file size] 
		whileFalse: 
		    [result := self 
				vfsFor: result
				name: fsName
				subPath: (file copyFrom: pos1 + fsName size + 2 to: pos2 - 1).
		    file := file copyFrom: pos2.
		    pos1 := 1].

	"Resolve the last virtual file path"
	^self 
	    vfsFor: result
	    name: fsName
	    subPath: subPath
    ]

    VFSHandler class >> initialize [
	"Register the receiver with ObjectMemory"

	<category: 'initializing'>
	ObjectMemory addDependent: self.
	self update: #returnFromSnapshot
    ]

    VFSHandler class >> update: aspect [
	"Private - Remove the files before quitting, and register the virtual
	 filesystems specified by the subclasses upon image load."

	<category: 'initializing'>
	(aspect == #returnFromSnapshot or: [aspect == #finishedSnapshot]) 
	    ifTrue: [Registry := nil].
	(aspect == #aboutToQuit or: [aspect == #aboutToSnapshot]) 
	    ifTrue: [self allSubclassesDo: [:each | each release]].
	aspect == #aboutToQuit 
	    ifTrue: 
		[self broadcast: #release.
		self release]
    ]

    VFSHandler class >> priority [
	"Answer the priority for this class (higher number = higher priority) in
	 case multiple classes implement the same file system.  The default is 0."

	<category: 'initializing'>
	^0
    ]

    VFSHandler class >> fileSystems [
	"Answer the virtual file systems that can be processed by this subclass.
	 The default is to answer an empty array, but subclasses can override
	 this.  If you do so, you should override #vfsFor:name:subPath: as well
	 or you risk infinite loops."

	<category: 'initializing'>
	^#()
    ]

    VFSHandler class >> register: fileSystem forClass: vfsHandlerClass [
	"Register the given file system to be handled by an instance of
	 vfsHandlerClass.  This is automatically called if the class overrides
	 #fileSystems."

	<category: 'initializing'>
	((Registry includesKey: fileSystem) not 
	    or: [(Registry at: fileSystem) priority < vfsHandlerClass priority]) 
		ifTrue: [Registry at: fileSystem put: vfsHandlerClass]
    ]

    VFSHandler class >> register [
	<category: 'private'>
	Registry isNil ifTrue: [VFSHandler registerAll].
	self fileSystems do: [:fs | VFSHandler register: fs forClass: self]
    ]

    VFSHandler class >> registerAll [
	"Register all file systems under the VFSHandler hierarchy."

	<category: 'private'>
	Registry isNil ifTrue: [Registry := LookupTable new].
	self allSubclassesDo: [:each | each register]
    ]

    VFSHandler class >> vfsFor: parent name: fsName subPath: subPath [
	"Create an instance of a subclass of the receiver, implementing the virtual
	 file `subPath' inside the `fileName' archive.  fsName is the virtual
	 filesystem name and is used to determine the subclass to be instantiated."

	<category: 'private'>
	| handler handlerClass |
	Registry isNil ifTrue: [self registerAll].
	handlerClass := Registry at: fsName.
	handler := handlerClass vfsFor: parent name: fsName.
	^subPath isNil ifTrue: [handler] ifFalse: [handler at: subPath]
    ]

    lstatOn: fileName into: statStruct [
	<category: 'C call-outs'>
	<cCall: 'lstat' returning: #int args: #(#string #cObject)>
	
    ]

    statOn: fileName into: statStruct [
	<category: 'C call-outs'>
	<cCall: 'stat' returning: #int args: #(#string #cObject)>
	
    ]

    openDir: dirName [
	<category: 'C call-outs'>
	<cCall: 'opendir' returning: #cObject args: #(#string)>
	
    ]

    closeDir: dirObject [
	<category: 'C call-outs'>
	<cCall: 'closedir' returning: #int args: #(#cObject)>
	
    ]

    primChmod: name mode: mode [
	<category: 'C call-outs'>
	<cCall: 'chmod' returning: #int args: #(#string #int)>
	
    ]

    primIsReadable: name [
	<category: 'C call-outs'>
	<cCall: 'fileIsReadable' returning: #boolean args: #(#string)>
	
    ]

    primIsWriteable: name [
	<category: 'C call-outs'>
	<cCall: 'fileIsWriteable' returning: #boolean args: #(#string)>
	
    ]

    primIsExecutable: name [
	<category: 'C call-outs'>
	<cCall: 'fileIsExecutable' returning: #boolean args: #(#string)>
	
    ]

    primSymlink: srcName as: destName [
	<category: 'C call-outs'>
	<cCall: 'symlink' returning: #void args: #(#string #string)>
	
    ]

    primUnlink: fileName [
	<category: 'C call-outs'>
	<cCall: 'unlink' returning: #void args: #(#string)>
	
    ]

    primRename: oldFileName to: newFileName [
	<category: 'C call-outs'>
	<cCall: 'rename' returning: #void args: #(#string #string)>
	
    ]

    primRemoveDir: fileName [
	<category: 'C call-outs'>
	<cCall: 'rmdir' returning: #void args: #(#string)>
	
    ]

    primCreateDir: dirName mode: mode [
	<category: 'C call-outs'>
	<cCall: 'mkdir' returning: #void args: #(#string #int)>
	
    ]

    extractDirentName: dirent [
	<category: 'C call-outs'>
	<cCall: 'extractDirentName' returning: #string args: #(#cObject)>
	
    ]

    readDir: dirObject [
	<category: 'C call-outs'>
	<cCall: 'readdir' returning: #cObject args: #(#cObject)>
	
    ]

    rewindDir: dirObject [
	<category: 'C call-outs'>
	<cCall: 'rewinddir' returning: #void args: #(#cObject)>
	
    ]

    finalize [
	"Upon finalization, we remove the file that was temporarily holding the file
	 contents"

	<category: 'releasing'>
	self release
    ]

    fullName [
	"Answer the name of the file identified by the receiver as answered by
	 File>>#name."

	<category: 'accessing'>
	^self name
    ]

    name [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    realFileName [
	"Answer the real file name which holds the file contents,
	 or nil if it does not apply."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	^true
    ]

    isSymbolicLink [
	"Answer whether the file is a symbolic link."

	<category: 'testing'>
	^false
    ]

    isDirectory [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a directory."

	<category: 'testing'>
	^false
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	self subclassResponsibility
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	self subclassResponsibility
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	self subclassResponsibility
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'testing'>
	^self isExecutable
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Set the receiver's timestamps to be accessDateTime and modifyDateTime.
	 If your file system does not support distinct access and modification
	 times, you should discard accessDateTime."

	<category: 'file operations'>
	self subclassResponsibility
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    open: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^self 
	    open: FileStream
	    mode: mode
	    ifFail: aBlock
    ]

    openDescriptor: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^self 
	    open: FileDescriptor
	    mode: mode
	    ifFail: aBlock
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    symlinkFrom: srcName [
	"Create the receiver as a symlink from the relative path srcName"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    renameTo: newFileName [
	"Rename the file with the given path name oldFileName to newFileName"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    at: aName [
	"Answer a VFSHandler for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	^VFSHandler for: (Directory append: aName to: self name)
    ]

    createDir: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'directory operations'>
	self subclassResponsibility
    ]

    do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name. aBlock should not return."

	<category: 'directory operations'>
	self subclassResponsibility
    ]
]

]



Namespace current: VFS [

VFSHandler subclass: RealFileHandler [
    | name stat isSymbolicLink |
    
    <category: 'Streams-Files'>
    <comment: 'RealFileHandler is an handler for
files that are on disk, as well as for virtual files that end
up being on disk when they are opened for the first time.'>

    Epoch := nil.

    RealFileHandler class >> setTimeFor: file atime: atimeSeconds mtime: mtimeSeconds [
	<category: 'C call-outs'>
	<cCall: 'utime' returning: #int args: #(#string #long #long)>
	
    ]

    RealFileHandler class >> working [
	<category: 'C call-outs'>
	<cCall: 'getCurDirName' returning: #stringOut args: #()>
	
    ]

    RealFileHandler class >> initialize [
	"Initialize the receiver's class variables"

	<category: 'initialization'>
	Epoch := DateTime 
		    year: 2000
		    day: 1
		    hour: 0
		    minute: 0
		    second: 0
    ]

    name [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	^name
    ]

    realFileName [
	"Answer the real file name for the file identified by the receiver"

	<category: 'accessing'>
	^name
    ]

    name: aName [
	"Private - Initialize the receiver's instance variables"

	<category: 'accessing'>
	name := File fullNameFor: aName
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	^self stat stSize value
    ]

    mode [
	"Answer the octal permissions for the file."

	<category: 'accessing'>
	^self stat stMode value bitAnd: 4095
    ]

    mode: mode [
	"Set the octal permissions for the file to be `mode'."

	<category: 'accessing'>
	self primChmod: self name mode: (mode bitAnd: 4095).
	File checkError
    ]

    isDirectory [
	"Answer whether the file is a directory."

	<category: 'accessing'>
	^(self stat stMode value bitAnd: 61440) = 16384
    ]

    isSymbolicLink [
	"Answer whether the file is a symbolic link."

	<category: 'accessing'>
	isSymbolicLink isNil ifTrue: [self refresh].
	^isSymbolicLink
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	^self getDateAndTime: self stat stAtime value
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	^self getDateAndTime: self stat stCtime value
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	^self getDateAndTime: self stat stCtime value
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	^self getDateAndTime: self stat stMtime value
    ]

    finalize [
	"Free the statistics for the receiver"

	<category: 'accessing'>
	| statVar |
	statVar := stat.
	stat := nil.
	statVar free
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	stat isNil 
	    ifTrue: 
		[stat := CStatStruct new.
		self addToBeFinalized].
	self lstatOn: self realFileName into: stat.
	File checkError.
	isSymbolicLink := (stat stMode value bitAnd: 61440) = 40960.	"S_IFLNK"
	isSymbolicLink 
	    ifTrue: 
		[self statOn: self realFileName into: stat.
		File errno]
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	stat isNil 
	    ifTrue: 
		[stat := CStatStruct new.
		self addToBeFinalized].
	self lstatOn: self realFileName into: stat.
	File errno == 0 ifFalse: [^false].
	isSymbolicLink := (stat stMode value bitAnd: 61440) = 40960.	"S_IFLNK"
	isSymbolicLink ifTrue: [self statOn: self realFileName into: stat].
	^true
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	^self primIsReadable: self realFileName
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	^self primIsWriteable: self realFileName
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	^self primIsExecutable: self realFileName
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Set the receiver's timestamps to be accessDateTime and modifyDateTime."

	<category: 'file operations'>
	self class 
	    setTimeFor: self realFileName
	    atime: (self secondsFromDateTime: accessDateTime)
	    mtime: (self secondsFromDateTime: modifyDateTime).
	File checkError
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^class 
	    fopen: self realFileName
	    mode: mode
	    ifFail: aBlock
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'file operations'>
	self isDirectory 
	    ifTrue: [self primRemoveDir: self realFileName]
	    ifFalse: [self primUnlink: self realFileName].
	File checkError
    ]

    symlinkFrom: srcName [
	"Create the receiver as a symlink from path destName"

	<category: 'file operations'>
	self primSymlink: srcName as: self realFileName.
	File checkError
    ]

    renameTo: newFileName [
	"Rename the file with the given path name to newFileName"

	<category: 'file operations'>
	self primRename: self realFileName to: newFileName.
	File checkError
    ]

    secondsFromDateTime: aDateTime [
	"Private - Convert a time expressed in seconds from 1/1/2000 to
	 an array of two Smalltalk Date and Time objects"

	<category: 'private'>
	^aDateTime asSeconds - Epoch asSeconds 
	    - (aDateTime offset asSeconds - Epoch offset asSeconds)
    ]

    getDateAndTime: time [
	"Private - Convert a time expressed in seconds from 1/1/2000 to
	 a Smalltalk DateTime object."

	<category: 'private'>
	^Epoch + (Duration seconds: time) 
	    offset: (Duration seconds: Time timezoneBias)
    ]

    stat [
	"Private - Answer the receiver's statistics' C struct"

	<category: 'private'>
	stat isNil ifTrue: [self refresh].
	^stat
    ]

    createDir: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'directory operations'>
	self primCreateDir: (Directory append: dirName to: self realFileName)
	    mode: 511.
	File checkError
    ]

    do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name. aBlock should not return."

	<category: 'directory operations'>
	| dir entry |
	dir := self openDir: self realFileName.
	File checkError.
	
	[entry := self readDir: dir.
	File checkError.
	entry notNil] 
		whileTrue: [aBlock value: (self extractDirentName: entry)].
	self closeDir: dir
    ]
]

]



Namespace current: VFS [

VFSHandler subclass: FileHandlerWrapper [
    | parent fsName |
    
    <category: 'Streams-Files'>
    <comment: 'DecodedFileHandler handles
virtual filesystems that take a file that is on-disk, run a
command on it, and then read from the result.'>

    FileHandlerWrapper class [
	| activePaths |
	
    ]

    FileHandlerWrapper class >> vfsFor: parent name: fsName [
	"Create an instance of this class representing the contents of the given
	 file, under the virtual filesystem fsName."

	<category: 'instance creation'>
	^self activePaths at: fsName -> parent name
	    ifAbsentPut: [self new parent: parent fsName: fsName]
    ]

    FileHandlerWrapper class >> activePaths [
	"Answer a dictionary that stores the currently opened archive file
	 members, to avoid extracting members multiple times.  Might be
	 worthwhile to push it to the superclass."

	<category: 'private'>
	activePaths isNil ifTrue: [activePaths := WeakValueLookupTable new].
	^activePaths
    ]

    FileHandlerWrapper class >> release [
	<category: 'private'>
	activePaths := nil.
	super release
    ]

    fsName [
	<category: 'private'>
	^fsName
    ]

    name [
	<category: 'accessing'>
	^self parent name , '#' , self fsName
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    realFileName [
	<category: 'accessing'>
	^self parent realFileName
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	^self parent size
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'delegation'>
	^self parent lastAccessTime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'delegation'>
	^self parent lastChangeTime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'delegation'>
	^self parent creationTime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'delegation'>
	^self parent lastModifyTime
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'delegation'>
	^self parent isReadable
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'delegation'>
	^self parent isWritable
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'delegation'>
	^self parent isExecutable
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'delegation'>
	^self parent 
	    open: class
	    mode: mode
	    ifFail: aBlock
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'delegation'>
	self parent remove
    ]

    parent: containerFileHandler fsName: aString [
	<category: 'private'>
	parent := containerFileHandler.
	fsName := aString
    ]
]

]



Namespace current: VFS [

FileHandlerWrapper subclass: DecodedFileHandler [
    | realFileName |
    
    <category: 'Streams-Files'>
    <comment: nil>

    DecodedFileHandler class [
	| fileTypes |
	
    ]

    DecodedFileHandler class >> priority [
	"Answer the priority for this class (higher number = higher priority) in
	 case multiple classes implement the same file system."

	<category: 'registering'>
	^-10
    ]

    DecodedFileHandler class >> fileTypes [
	"Return the valid virtual filesystems and the associated
	 filter commands."

	<category: 'registering'>
	fileTypes isNil ifTrue: [fileTypes := self defaultFileTypes].
	^fileTypes
    ]

    DecodedFileHandler class >> defaultFileTypes [
	"Return the default virtual filesystems and the associated
	 filter commands."

	<category: 'registering'>
	^(LookupTable new)
	    at: 'Z' put: 'compress -cf %1 > %2';
	    at: 'uZ' put: 'zcat -f %1 > %2';
	    at: 'gz' put: 'gzip -cf %1 > %2';
	    at: 'ugz' put: 'gzip -cdf %1 > %2';
	    at: 'bz2' put: 'bzip2 -c %1 > %2';
	    at: 'ubz2' put: 'bzip2 -cd %1 > %2';
	    at: 'tar' put: 'tar chof %2 %1';
	    at: 'tgz' put: 'tar chof - %1 | gzip -cf > %2';
	    at: 'nop' put: 'cat %1 > %2';
	    at: 'strings' put: 'strings %1 > %2';
	    yourself
    ]

    DecodedFileHandler class >> fileSystems [
	"Answer the virtual file systems that can be processed by this subclass.
	 These are #gz (gzip a file), #ugz (uncompress a gzipped file),
	 #Z (compress a file via Unix compress), #uZ (uncompress a compressed
	 file), #bz2 (compress a file via bzip2), #ubz2 (uncompress a file via
	 bzip2), #tar (make a tar archive out of a directory), #tgz (make a
	 gzipped tar archive out of a directory), #nop (do nothing, used for
	 testing) and #strings (use the `strings' utility to extract printable
	 strings from a file)."

	<category: 'registering'>
	^self fileTypes keys
    ]

    at: aName [
	<category: 'files'>
	SystemExceptions.FileError signal: 'not a tree-shaped filesystem'
    ]

    parent: containerFileHandler fsName: aString [
	"Private - Initialize a new object storing the contents of the
	 virtualFileName file into temporaryFileName."

	<category: 'files'>
	| temp command pipe file |
	super parent: containerFileHandler fsName: aString.
	command := self class fileTypes at: fsName.
	temp := FileStream openTemporaryFile: Directory temporary , '/vfs'.

	"Go through a pipe if the file is completely virtual."
	self parent realFileName isNil 
	    ifTrue: 
		[pipe := FileStream popen: command % 
					{'-'.
					temp name}
			    dir: FileStream write.
		file := parent open: FileStream read
			    ifFail: [self error: 'cannot open input file'].
		pipe nextPutAll: file.
		file close.
		pipe close]
	    ifFalse: 
		[Smalltalk system: command % 
				{parent realFileName.
				temp name}].
	realFileName := temp name.
	temp close.
	VFSHandler addDependent: self.
	self addToBeFinalized
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'files'>
	^class 
	    fopen: self realFileName
	    mode: mode
	    ifFail: aBlock
    ]

    realFileName [
	"Answer the real file name which holds the file contents,
	 or nil if it does not apply."

	<category: 'files'>
	^realFileName
    ]

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	"Remove the file that was temporarily holding the file contents"

	<category: 'files'>
	realFileName isNil ifTrue: [^self].
	self primUnlink: realFileName.
	realFileName := nil.
	super release
    ]
]

]



Namespace current: VFS [

FileHandlerWrapper subclass: ArchiveFileHandler [
    | tmpFileHandlers topLevelFiles allFiles extractedFiles |
    
    <category: 'Streams-Files'>
    <comment: 'ArchiveFileHandler handles
virtual filesystems that have a directory structure of
their own.  The directories and files in the archive are
instances of ArchiveMemberHandler, but the functionality
resides entirely in ArchiveFileHandler because the members
will still ask the archive to get directory information
on them, to extract them to a real file, and so on.'>

    isDirectory [
	"Answer true.  The archive can always be considered as a directory."

	<category: 'querying'>
	^true
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'querying'>
	^true
    ]

    at: aName [
	"Answer a VFSHandler for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	| handler data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: aName ifAbsent: [nil].
	handler := data at: 5 ifAbsent: [nil].
	handler isNil ifFalse: [^handler].
	tmpFileHandlers isNil 
	    ifTrue: 
		[tmpFileHandlers := LookupTable new.
		VFSHandler addDependent: self.
		self addToBeFinalized].
	^tmpFileHandlers at: aName
	    ifAbsentPut: 
		[(TmpFileArchiveMemberHandler new)
		    name: aName;
		    parent: self]
    ]

    do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'directory operations'>
	topLevelFiles do: aBlock
    ]

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	<category: 'directory operations'>
	tmpFileHandlers isNil 
	    ifFalse: 
		[tmpFileHandlers do: [:each | each release].
		tmpFileHandlers := nil].
	extractedFiles isNil 
	    ifFalse: 
		[extractedFiles do: [:each | self primUnlink: each].
		extractedFiles := nil].
	super release
    ]

    fillMember: anArchiveMemberHandler [
	"Extract the information on anArchiveMemberHandler.  Answer
	 false if it actually does not exist in the archive; otherwise,
	 answer true after having told anArchiveMemberHandler about them
	 by sending #size:stCtime:stMtime:stAtime:isDirectory: to it."

	<category: 'ArchiveMemberHandler protocol'>
	| data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: anArchiveMemberHandler name ifAbsent: [nil].
	data isNil ifTrue: [^false].
	anArchiveMemberHandler fillFrom: data.
	^true
    ]

    member: anArchiveMemberHandler do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by
	 anArchiveMemberHandler, passing its name."

	<category: 'ArchiveMemberHandler protocol'>
	| data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: anArchiveMemberHandler name ifAbsent: [nil].
	data isNil ifTrue: [^SystemExceptions.FileError signal: 'File not found'].
	(data at: 1) isNil 
	    ifTrue: [^SystemExceptions.FileError signal: 'Not a directory'].
	(data at: 1) do: aBlock
    ]

    refresh [
	"Extract the directory listing from the archive"

	<category: 'ArchiveMemberHandler protocol'>
	| pipe line parentPath name current currentPath directoryTree directory |
	super refresh.
	current := currentPath := nil.
	allFiles := LookupTable new.
	directoryTree := LookupTable new.
	self files do: 
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
		directory := (mode bitAnd: 61440) = 16384 
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

    member: anArchiveMemberHandler mode: bits [
	"Set the permission bits for the file in anArchiveMemberHandler."

	<category: 'ArchiveMemberHandler protocol'>
	self subclassResponsibility
    ]

    removeMember: anArchiveMemberHandler [
	"Remove the member represented by anArchiveMemberHandler."

	<category: 'ArchiveMemberHandler protocol'>
	self subclassResponsibility
    ]

    updateMember: anArchiveMemberHandler [
	"Update the member represented by anArchiveMemberHandler by
	 copying the file into which it was extracted back to the
	 archive."

	<category: 'ArchiveMemberHandler protocol'>
	self subclassResponsibility
    ]

    extractMember: anArchiveMemberHandler [
	"Extract the contents of anArchiveMemberHandler into a file
	 that resides on disk, and answer the name of the file."

	<category: 'TmpFileArchiveMemberHandler protocol'>
	extractedFiles isNil ifTrue: [extractedFiles := IdentityDictionary new].
	^extractedFiles at: anArchiveMemberHandler
	    ifAbsentPut: 
		[| temp |
		temp := FileStream openTemporaryFile: Directory temporary , '/vfs'.
		self extractMember: anArchiveMemberHandler into: temp.
		File fullNameFor: temp name]
    ]

    extractMember: anArchiveMemberHandler into: file [
	"Extract the contents of anArchiveMemberHandler into a file
	 that resides on disk, and answer the name of the file."

	<category: 'TmpFileArchiveMemberHandler protocol'>
	self subclassResponsibility
    ]

    convertMode: mode [
	"Convert the mode from a string, character or boolean to an octal number."

	<category: 'private'>
	mode isNumber ifTrue: [^mode].
	mode isString ifTrue: [^self convertModeString: mode].
	mode isCharacter ifTrue: [^self convertMode: mode == $d].
	^mode ifTrue: [16877] ifFalse: [420]
    ]

    convertModeString: modeString [
	"Convert the mode from a string to an octal number."

	<category: 'private'>
	| mode |
	mode := 0.
	(modeString at: 1) = $l ifTrue: [mode := 40960].
	(modeString at: 1) = $d ifTrue: [mode := 16384].
	(modeString at: 4) asLowercase = $s ifTrue: [mode := mode + 2048].
	(modeString at: 7) asLowercase = $s ifTrue: [mode := mode + 1024].
	(modeString at: 10) asLowercase = $t ifTrue: [mode := mode + 512].
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
							{0.
							self creationTime.
							directory}.
						directory]].
			last := i + 1]].
	^current
    ]
]

]



Namespace current: VFS [

VFSHandler subclass: ArchiveMemberHandler [
    | parent name mode size stCtime stMtime stAtime |
    
    <category: 'Streams-Files'>
    <comment: 'TmpFileArchiveMemberHandler is a handler
class for members of archive files that creates temporary files when
extracting files from an archive.'>

    parent: anArchiveFileHandler [
	"Set the archive of which the receiver is a member."

	<category: 'initializing'>
	parent := anArchiveFileHandler
    ]

    fillFrom: data [
	"Called back by the receiver's parent when the ArchiveMemberHandler
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
	stCtime := self parent lastModifyTime.
	stMtime := mtime.
	stAtime := self parent lastAccessTime.
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

    realFileName [
	<category: 'accessing'>
	^nil
    ]

    fullName [
	"Answer the name of the file identified by the receiver as answered by
	 File>>#name."

	<category: 'accessing'>
	^Directory append: self name to: self parent name
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

    parent [
	"Answer the archive of which the receiver is a member."

	<category: 'accessing'>
	^parent
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
	self parent fillMember: self
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	^self parent fillMember: self
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
	self parent member: self mode: (mode bitAnd: 4095)
    ]

    isDirectory [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a directory."

	<category: 'testing'>
	size isNil ifTrue: [self refresh].
	^(mode bitAnd: 61440) = 16384
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
	    ifTrue: [self parent updateMember: self] aspect == #afterClosing
	    ifTrue: 
		[self parent refresh.
		self refresh]
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'file operations'>
	self parent removeMember: self.
	File checkError
    ]

    renameTo: newFileName [
	"Rename the file with the given path name oldFileName to newFileName"

	<category: 'file operations'>
	self notYetImplemented
    ]

    at: aName [
	"Answer a VFSHandler for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	^self parent at: (Directory append: aName to: self name)
    ]

    createDir: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'directory operations'>
	self parent createDir: (Directory append: dirName to: self name)
    ]

    do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'directory operations'>
	self parent member: self do: aBlock
    ]
]

]



Namespace current: VFS [

ArchiveMemberHandler subclass: TmpFileArchiveMemberHandler [
    | realFileName |
    
    <category: 'Streams-Files'>
    <comment: nil>

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	"Remove the file that was temporarily holding the file contents"

	<category: 'finalization'>
	realFileName isNil ifTrue: [^self].
	self primUnlink: realFileName.
	realFileName := nil.
	super release
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'directory operations'>
	| fileStream |
	self realFileName isNil ifTrue: [^aBlock value].
	fileStream := class 
		    fopen: self realFileName
		    mode: mode
		    ifFail: [^aBlock value].
	mode == FileStream read ifFalse: [fileStream addDependent: self].
	fileStream setName: self fullName.
	^fileStream
    ]

    realFileName [
	"Answer the real file name which holds the file contents,
	 or nil if it does not apply."

	<category: 'directory operations'>
	realFileName isNil ifFalse: [^realFileName].
	self exists ifFalse: [^nil].
	realFileName := self parent extractMember: self.
	^realFileName
    ]
]

]



Namespace current: VFS [

CStruct subclass: CStatStruct [
    
    <category: 'Streams-Files'>
    <comment: nil>
    <declaration: #(#(#stMode #uShort ) #(#stSize #long ) #(#stAtime #long ) #(#stMtime #long ) #(#stCtime #long ) )>
]

]



Eval [
    VFS.RealFileHandler initialize.
    VFS.DecodedFileHandler initialize.
    VFS.VFSHandler initialize
]

