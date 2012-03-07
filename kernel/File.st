"======================================================================
|
|   File Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2006,2007,2008,2009
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



FilePath subclass: File [
    | path stat isSymbolicLink |
    
    <category: 'Streams-Files'>
    <comment: 'I enable access to the properties of files that are on disk.'>

    Epoch := nil.

    File class >> initialize [
        "Initialize the receiver's class variables"

        <category: 'initialization'>
        Epoch := DateTime
                    year: 2000
                    day: 1
                    hour: 0
                    minute: 0
                    second: 0
    ]

    File class >> stringError: errno [
	"Answer C strerror's result for errno."
	<category: 'C functions'>
	<cCall: 'strerror' returning: #string args: #(#int)>
	
    ]

    File class >> errno [
	"Answer the current value of C errno."
	<category: 'C functions'>
	<cCall: 'errno' returning: #long args: #()>
	
    ]

    File class >> checkError [
	"Return whether an error had been reported or not.
	 If there had been one, raise an exception too"

	<category: 'file operations'>
	^self checkError: self errno
    ]

    File class >> checkError: errno [
	"The error with the C code `errno' has been reported.
	 If errno >= 1, raise an exception"

	<category: 'file operations'>
	errno < 1 ifTrue: [^false].
	SystemExceptions.FileError signal: (self stringError: errno).
	^true
    ]

    File class >> setTimeFor: fileName atime: atimeSec mtime: mtimeSec [
	<category: 'private-C call-outs'>
	<cCall: 'utime' returning: #int args: #(#string #int #int)>
	
    ]

    File class >> setOwnerFor: fileName owner: ownerString group: groupString [
	<category: 'private-C call-outs'>
	<cCall: 'chown' returning: #int args: #(#string #string #string)>
	
    ]

    File class >> path: aString [
	"Answer a new file with the given path.  The path is not validated until
	 some of the fields of the newly created objects are accessed"

	<category: 'instance creation'>
	^self basicNew init: aString
    ]

    File class >> name: aName [
	"Answer a new file with the given path.  The path is turned into
	 an absolute path."

	<category: 'instance creation'>
	^self path: (self fullNameFor: aName)
    ]

    File class >> touch: fileName [
	"Update the timestamp of the file with the given path name."

	<category: 'file operations'>
	(self path: fileName) touch
    ]

    File class >> symlink: srcName as: destName [
	"Create a symlink for the srcName file with the given path name"

	<category: 'file operations'>
	(self path: srcName) symlinkAs: destName
    ]

    File class >> symlink: destName from: srcName [
	"Create a symlink named destName file from the given path (relative to
	 destName)"

	<category: 'file operations'>
	(self path: destName) symlinkFrom: srcName
    ]

    File class >> remove: fileName [
	"Remove the file with the given path name"

	<category: 'file operations'>
	(self path: fileName) remove
    ]

    File class >> rename: oldFileName to: newFileName [
	"Rename the file with the given path name oldFileName to newFileName"

	<category: 'file operations'>
	(self path: oldFileName) renameTo: newFileName
    ]

    File class >> exists: fileName [
	"Answer whether a file with the given name exists"

	<category: 'testing'>
	^(self path: fileName) exists
    ]

    File class >> isReadable: fileName [
	"Answer whether a file with the given name exists and is readable"

	<category: 'testing'>
	^(self path: fileName) isReadable
    ]

    File class >> isWriteable: fileName [
	"Answer whether a file with the given name exists and is writeable"

	<category: 'testing'>
	^(self path: fileName) isWriteable
    ]

    File class >> isExecutable: fileName [
	"Answer whether a file with the given name exists and can be executed"

	<category: 'testing'>
	^(self path: fileName) isExecutable
    ]

    File class >> isAccessible: fileName [
	"Answer whether a directory with the given name exists and can be accessed"

	<category: 'testing'>
	^(self path: fileName) isAccessible
    ]

    File class >> executable [
	"Answer the full path to the executable being run."

	<category: 'reading system defaults'>
	^self path: ExecutableFileName
    ]

    File class >> image [
	"Answer the full path to the image being used."

	<category: 'reading system defaults'>
	^self path: ImageFileName
    ]

    = aFile [
	"Answer whether the receiver represents the same file as the receiver."

	<category: 'basic'>
	^self class == aFile class and: [ self asString = aFile asString ]
    ]

    hash [
	"Answer a hash value for the receiver."

	<category: 'basic'>
	^self asString hash
    ]

    lstatOn: fileName into: statStruct [
	<category: 'private-C call-outs'>
	<cCall: 'lstat_obj' returning: #int args: #(#string #smalltalk)>
	
    ]

    statOn: fileName into: statStruct [
	<category: 'private-C call-outs'>
	<cCall: 'stat_obj' returning: #int args: #(#string #smalltalk)>
	
    ]

    openDir: dirName [
	<category: 'private-C call-outs'>
	<cCall: 'opendir' returning: #cObject args: #(#string)>
	
    ]

    closeDir: dirObject [
	<category: 'private-C call-outs'>
	<cCall: 'closedir' returning: #int args: #(#cObject)>
	
    ]

    primChmod: name mode: mode [
	<category: 'private-C call-outs'>
	<cCall: 'chmod' returning: #int args: #(#string #int)>
	
    ]

    primIsReadable: name [
	<category: 'private-C call-outs'>
	<cCall: 'fileIsReadable' returning: #boolean args: #(#string)>
	
    ]

    primIsWriteable: name [
	<category: 'private-C call-outs'>
	<cCall: 'fileIsWriteable' returning: #boolean args: #(#string)>
	
    ]

    primIsExecutable: name [
	<category: 'private-C call-outs'>
	<cCall: 'fileIsExecutable' returning: #boolean args: #(#string)>
	
    ]

    primSymlink: srcName as: destName [
	<category: 'private-C call-outs'>
	<cCall: 'symlink' returning: #int args: #(#string #string)>
	
    ]

    primUnlink: fileName [
	<category: 'private-C call-outs'>
	<cCall: 'unlink' returning: #int args: #(#string)>
	
    ]

    primRename: oldFileName to: newFileName [
	<category: 'private-C call-outs'>
	<cCall: 'rename' returning: #int args: #(#string #string)>
	
    ]

    primRemoveDir: fileName [
	<category: 'private-C call-outs'>
	<cCall: 'rmdir' returning: #int args: #(#string)>
	
    ]

    primCreateDir: dirName mode: mode [
	<category: 'private-C call-outs'>
	<cCall: 'mkdir' returning: #int args: #(#string #int)>
	
    ]

    extractDirentName: dirent [
	<category: 'private-C call-outs'>
	<cCall: 'extractDirentName' returning: #string args: #(#cObject)>
	
    ]

    readDir: dirObject [
	<category: 'private-C call-outs'>
	<cCall: 'readdir' returning: #cObject args: #(#cObject)>
	
    ]

    rewindDir: dirObject [
	<category: 'private-C call-outs'>
	<cCall: 'rewinddir' returning: #void args: #(#cObject)>
	
    ]

    , aName [
	"Answer an object of the same kind as the receiver, whose name
	 is suffixed with aName."

	^self class path: self name, aName
    ]

    asString [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	^path
    ]

    name [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	^File fullNameFor: self asString
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	^self stat stSize
    ]

    mode [
	"Answer the permission bits for the file identified by the receiver"

	<category: 'accessing'>
	^self stat stMode bitAnd: 4095
    ]

    mode: anInteger [
	"Set the permission bits for the file identified by the receiver to be
	 anInteger."

	<category: 'accessing'>
	(self primChmod: self asString mode: (anInteger bitAnd: 4095)) < 0
	    ifTrue: [ File checkError ]
    ]

    isFileSystemPath [
	"Answer whether the receiver corresponds to a real filesystem path."

	<category: 'testing'>
	^true
    ]

    isSocket [
	"Answer whether the file is an AF_UNIX socket."

	<category: 'accessing'>
	self exists ifFalse: [ ^false ].
	^(self stat stMode bitAnd: 8r170000) = 8r140000
    ]

    isDirectory [
	"Answer whether the file is a directory."

	<category: 'accessing'>
	self exists ifFalse: [ ^false ].
	^(self stat stMode bitAnd: 8r170000) = 8r40000
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
	^self getDateAndTime: self stat stAtime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	^self getDateAndTime: self stat stCtime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	^self getDateAndTime: self stat stCtime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	^self getDateAndTime: self stat stMtime
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	stat isNil ifTrue: [stat := Kernel.Stat new].
	(self lstatOn: self asString into: stat) < 0
            ifTrue: [File checkError].
	isSymbolicLink := (stat stMode bitAnd: 61440) = 40960.	"S_IFLNK"
	isSymbolicLink 
	    ifTrue: 
		[self statOn: self asString into: stat.
		File errno]
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	stat isNil ifTrue: [stat := Kernel.Stat new].
	(self lstatOn: self asString into: stat) < 0
	    ifTrue: [^false].
	isSymbolicLink := (stat stMode bitAnd: 61440) = 40960.	"S_IFLNK"
	isSymbolicLink ifTrue: [self statOn: self asString into: stat].
	^true
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	^self primIsReadable: self asString
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	^self primIsWriteable: self asString
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver
	 does exist and is accessible"

	<category: 'testing'>
	^self isDirectory and: [self primIsExecutable: self asString]
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	^self isFile and: [self primIsExecutable: self asString]
    ]

    isAbsolute [
	"Answer whether the receiver identifies an absolute path."

	<category: 'testing'>
	^File isAbsolute: self asString
    ]
    
    owner: ownerString group: groupString [
	"Set the receiver's owner and group to be ownerString and groupString."

	<category: 'file operations'>
	(self class 
	    setOwnerFor: self asString
	    owner: ownerString
	    group: groupString) < 0
	        ifTrue: [ File checkError ]
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Set the receiver's timestamps to be accessDateTime and modifyDateTime."

	<category: 'file operations'>
	(self class 
	    setTimeFor: self asString
	    atime: (self secondsFromDateTime: accessDateTime)
	    mtime: (self secondsFromDateTime: modifyDateTime)) < 0
	        ifTrue: [ File checkError ]
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^class 
	    fopen: self asString
	    mode: mode
	    ifFail: aBlock
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'file operations'>
        | result |
	result := self isDirectory 
	    ifTrue: [self primRemoveDir: self asString]
	    ifFalse: [self primUnlink: self asString].
	result < 0 ifTrue: [ File checkError ]
    ]

    symlinkFrom: srcName [
	"Create the receiver as a symlink from path destName"

	<category: 'file operations'>
	(self primSymlink: srcName as: self asString) < 0
            ifTrue: [ File checkError ]
    ]

    renameTo: newFileName [
	"Rename the file with the given path name to newFileName"

	<category: 'file operations'>
	(self primRename: self asString to: newFileName) < 0
	    ifTrue: [ File checkError ]
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

    createDirectory [
	"Create the receiver as a directory."

	<category: 'directory operations'>
	(self primCreateDir: self asString mode: 8r777) < 0
	    ifTrue: [ File checkError ]
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name. aBlock should not return."

	<category: 'directory operations'>
	| dir entry |
	dir := self openDir: self asString.
	dir isNil ifTrue: [^File checkError].
	
	[[(entry := self readDir: dir) notNil] 
	    whileTrue: [aBlock value: (self extractDirentName: entry)]]
		    ensure: [self closeDir: dir].

	File checkError.
    ]

    symlinkAs: destName [
	"Create destName as a symbolic link of the receiver.  The appropriate
	 relative path is computed automatically."

	<category: 'file operations'>
	| relPath |
	relPath := File pathFrom: destName to: self asString.
	(self class path: destName) symlinkFrom: relPath
    ]

    pathFrom: dir [
	"Compute the relative path from the directory dirName to the receiver"

	<category: 'file operations'>
	^File pathFrom: (dir / 'somefile') asString to: self asString.
    ]

    pathTo: destName [
	"Compute the relative path from the receiver to destName."

	<category: 'accessing'>
	^File pathFrom: (self / 'somefile') asString to: destName asString.
    ]

    full [
	"Answer the full name of the receiver, resolving the `.' and
	 `..' directory entries, and answer the result.  Answer nil if the
	 name is invalid (such as '/usr/../../badname')"

	<category: 'file name management'>
	self isAbsolute ifTrue: [ ^self ].
	^self class path: (File fullNameFor: self name)
    ]

    at: aString [
	"Answer a File or Directory object as appropriate for a file named
	 'aName' in the directory represented by the receiver."

	<category: 'accessing'>
	^self class path: (self nameAt: aString asString)
    ]

    init: aString [
	"Private - Initialize the receiver's instance variables"

	<category: 'private'>
	path := aString
    ]
]


Namespace current: Kernel [

Object subclass: Stat [
    <category: 'Streams-Files'>
    
    | stMode stSize stAtime stMtime stCtime |
    stMode [ ^stMode ]
    stSize [ ^stSize ]
    stAtime [ ^stAtime ]
    stMtime [ ^stMtime ]
    stCtime [ ^stCtime ]
]

]



String extend [
    / aName [
	"Answer a File object as appropriate for a file named
	 'aName' in the directory represented by the receiver."

	<category: 'filesystem'>
	^(File path: self) at: aName
    ]

    asFile [
	"Answer a File object for the file whose name is in the receiver."

	<category: 'filesystem'>
	^(File path: self)
    ]
]

Eval [
    File initialize
]
