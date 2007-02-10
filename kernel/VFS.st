"======================================================================
|
|   Virtual File System layer definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002, 2005 Free Software Foundation, Inc.
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

Smalltalk addSubspace: #VFS!
Namespace current: VFS!

Object subclass: #VFSHandler
       instanceVariableNames: 'name'
       classVariableNames: 'Registry'
       poolDictionaries: ''
       category: 'Streams-Files'
! 

VFSHandler comment: 'VFSHandler is the abstract class for
implementations of File and Directory.  These classes only
delegate to the appropriate handler, which is in charge of
actually accessing or ``molding'''' the filesystem.'!

VFSHandler subclass: #RealFileHandler
       instanceVariableNames: 'stat isSymbolicLink'
       classVariableNames: 'Epoch'
       poolDictionaries: ''
       category: 'Streams-Files'
! 

RealFileHandler comment: 'RealFileHandler is an handler for
files that are on disk, as well as for virtual files that end
up being on disk when they are opened for the first time.'!

RealFileHandler subclass: #DecodedFileHandler
       instanceVariableNames: 'realFileName'
       classVariableNames: 'FileTypes'
       poolDictionaries: ''
       category: 'Streams-Files'
! 

DecodedFileHandler comment: 'DecodedFileHandler handles
virtual filesystems that take a file that is on-disk, run a
command on it, and then read from the result.'!

RealFileHandler subclass: #ArchiveFileHandler
       instanceVariableNames: 'handlers'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ArchiveFileHandler comment: 'ArchiveFileHandler handles
virtual filesystems that have a directory structure of
their own.  The directories and files in the archive are
instances of ArchiveMemberHandler, but the functionality
resides entirely in ArchiveFileHandler because the members
will still ask the archive to get directory information
on them, to extract them to a real file, and so on.'!

ArchiveFileHandler subclass: #ExternalArchiveFileHandler
       instanceVariableNames: 'command topLevelFiles allFiles extractedFiles'
       classVariableNames: 'ActivePaths FileTypes'
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ExternalArchiveFileHandler comment: 'ExternalArchiveFileHandler
allows for easy implementation of archive files (for example,
transparent unzipping and untarring) with a single shell script.
It implements a protocol that that is compatible with the Midnight
Commander and with GNOME VFS.'!

VFSHandler subclass: #ArchiveMemberHandler
       instanceVariableNames: 'parent size stCtime stMtime stAtime isDirectory realFileName'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ArchiveMemberHandler comment: 'ArchiveMemberHandler is the handler
class for members of archive files (instances of ArchiveFileHandler).'!

CStruct
    subclass: #CStatStruct
    declaration: #( 
	(#stMode #uShort) " protection "
	(#stSize #long)   " total size, in bytes "
	(#stAtime #long)  " time of last access "
	(#stMtime #long)  " time of last (contents) modification "
	(#stCtime #long)  " time of last (attribute) change "
    )
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Streams-Files'
!



"opendir and closedir needed to test for directories"
!VFSHandler methodsFor: 'C call-outs'!

lstatOn: fileName into: statStruct
    <cCall: 'lstat' returning: #int args: #(#string #cObject)>!

statOn: fileName into: statStruct
    <cCall: 'stat' returning: #int args: #(#string #cObject)>!

openDir: dirName
    <cCall: 'opendir' returning: #cObject args: #(#string)>!

closeDir: dirObject
    <cCall: 'closedir' returning: #int args: #(#cObject)>!

primIsReadable: name
    <cCall: 'fileIsReadable' returning: #boolean args: #(#string)>!

primIsWriteable: name
    <cCall: 'fileIsWriteable' returning: #boolean args: #(#string)>!

primIsExecutable: name
    <cCall: 'fileIsExecutable' returning: #boolean args: #(#string)>!

primUnlink: fileName
    <cCall: 'unlink' returning: #void args: #(#string)>!

primRename: oldFileName to: newFileName
    <cCall: 'rename' returning: #void args: #(#string #string)>!

primRemoveDir: fileName
    <cCall: 'rmdir' returning: #void args: #(#string)>!

primCreateDir: dirName mode: mode
    <cCall: 'mkdir' returning: #void args: #(#string #int)>!

extractDirentName: dirent
    <cCall: 'extractDirentName' returning: #string args: #(#cObject)>!

readDir: dirObject
    <cCall: 'readdir' returning: #cObject args: #(#cObject)>!

rewindDir: dirObject
    <cCall: 'rewinddir' returning: #void args: #(#cObject)>! !

!RealFileHandler class methodsFor: 'C call-outs'!

setTimeFor: file atime: atimeSeconds mtime: mtimeSeconds
    <cCall: 'utime' returning: #int args: #(#string #long #long)>!

working
    <cCall: 'getCurDirName' returning: #stringOut args: #()>! !



!VFSHandler class methodsFor: 'instance creation'!

for: fileName
    "Answer the (real or virtual) file handler for the file named fileName"

    | pos1 fsName pos2 subPath file result |
    file := fileName.
    pos1 := file indexOf: $#.
    pos1 = 0 ifTrue: [ ^RealFileHandler new name: file ].
    [
	"Extract the file name and path, and resolve the first virtual
         file path (for example abc#uzip/def in abc#uzip/def#ugz)"

	fsName := file
	    copyFrom: pos1 + 1
	    to: (file indexOf: $/ startingAt: pos1 ifAbsent: [ file size + 1 ]) - 1.

	pos2 := file indexOf: $# startingAt: pos1 + 1 ifAbsent: [ file size + 1 ].
	subPath := pos1 + fsName size + 2 >= pos2
	    ifTrue: [ nil ]
	    ifFalse: [ file copyFrom: pos1 + fsName size + 2 to: pos2 - 1 ].

	pos2 > file size
    ] whileFalse: [
	result := self
	    vfsFor: (file copyFrom: 1 to: pos1 - 1)
	    name: fsName
	    subPath: (file copyFrom: pos1 + fsName size + 2 to: pos2 - 1).

	file := result realFileName, (file copyFrom: pos2 to: file size).
	pos1 := file indexOf: $#
    ].

    "Resolve the last virtual file path"    
    ^self
	vfsFor: (file copyFrom: 1 to: pos1 - 1)
	name: fsName
	subPath: subPath
! !

!VFSHandler class methodsFor: 'initializing'!

initialize
    "Register the receiver with ObjectMemory"
    ObjectMemory addDependent: self.
    self update: #returnFromSnapshot!

update: aspect
    "Private - Remove the files before quitting, and register the virtual
     filesystems specified by the subclasses upon image load."

    (aspect == #returnFromSnapshot or: [ aspect == #finishedSnapshot ]) ifTrue: [
	Registry := nil.
    ].
    (aspect == #aboutToQuit or: [ aspect == #aboutToSnapshot ]) ifTrue: [
	self allSubclassesDo: [ :each | each release ].
    ].
    aspect == #aboutToQuit ifTrue: [
	self broadcast: #release.
	self release.
    ].
!

fileSystems
    "Answer the virtual file systems that can be processed by this subclass.
     The default is to answer an empty array, but subclasses can override
     this.  If you do so, you should override #vfsFor:name:subPath: as well
     or you risk infinite loops."

    ^#()!

register: fileSystem forClass: vfsHandlerClass
    "Register the given file system to be handled by an instance of
     vfsHandlerClass.  This is automatically called if the class overrides
     #fileSystems."
    Registry at: fileSystem put: vfsHandlerClass! !

!VFSHandler class methodsFor: 'private'!

vfsFor: fileName name: fsName subPath: subPath
    "Create an instance of a subclass of the receiver, implementing the virtual
     file `subPath' inside the `fileName' archive.  fsName is the virtual
     filesystem name and is used to determine the subclass to be instantiated."
    Registry isNil ifTrue: [
	Registry := LookupTable new.
	self allSubclassesDo: [ :each |
	    each fileSystems do: [ :fs | self register: fs forClass: each ] ] ].
    ^(Registry at: fsName) 
	vfsFor: fileName name: fsName subPath: subPath!


!VFSHandler methodsFor: 'releasing'!

addToBeFinalized
    "Something that has to be finalized will also be released before quitting."
    VFSHandler addDependent: self.
    super addToBeFinalized!

finalize
    "Upon finalization, we remove the file that was temporarily holding the file
     contents"
    self release! !

!VFSHandler methodsFor: 'accessing'!

name
    "Answer the name of the file identified by the receiver"
    ^name
!

name: aName
    "Private - Initialize the receiver's instance variables"
    name := aName
!

realFileName
    "Answer the real file name which holds the file contents,
     or an empty string if it does not apply."
    ^name
!

size
    "Answer the size of the file identified by the receiver"
    self subclassResponsibility
!

lastAccessTime
    "Answer the last access time of the file identified by the receiver"
    self subclassResponsibility
!

lastChangeTime
    "Answer the last change time of the file identified by the receiver
    (the `last change time' has to do with permissions, ownership and the
    like). On some operating systems, this could actually be the
    file creation time."
    self subclassResponsibility
!

creationTime
    "Answer the creation time of the file identified by the receiver.
    On some operating systems, this could actually be the last change time
    (the `last change time' has to do with permissions, ownership and the
    like)."
    self subclassResponsibility
!

lastModifyTime
    "Answer the last modify time of the file identified by the receiver
    (the `last modify time' has to do with the actual file contents)."
    self subclassResponsibility
!

refresh
    "Refresh the statistics for the receiver"
! !



!VFSHandler methodsFor: 'testing'!

exists
    "Answer whether a file with the name contained in the receiver does exist."
    ^true
!

isSymbolicLink
    "Answer whether the file is a symbolic link."
    ^false
!

isDirectory
    "Answer whether a file with the name contained in the receiver does exist
    and identifies a directory."
    ^false
!

isReadable
    "Answer whether a file with the name contained in the receiver does exist
     and is readable"
    self subclassResponsibility!

isWriteable
    "Answer whether a file with the name contained in the receiver does exist
     and is writeable"
    self subclassResponsibility!

isExecutable
    "Answer whether a file with the name contained in the receiver does exist
     and is executable"
    self subclassResponsibility!

isAccessible
    "Answer whether a directory with the name contained in the receiver does
     exist and can be accessed"
    ^self isExecutable! !


!VFSHandler methodsFor: 'file operations'!

lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
    "Set the receiver's timestamps to be accessDateTime and modifyDateTime.
     If your file system does not support distinct access and modification
     times, you should discard accessDateTime."
    self subclassResponsibility!

open: class mode: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"
    self subclassResponsibility!

open: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"
    ^self open: FileStream mode: mode ifFail: aBlock
!

openDescriptor: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"
    ^self open: FileDescriptor mode: mode ifFail: aBlock
!

remove
    "Remove the file with the given path name"
    self subclassResponsibility
!

renameTo: newFileName
    "Rename the file with the given path name oldFileName to newFileName"
    self subclassResponsibility
! !


!VFSHandler methodsFor: 'directory operations'!

at: aName
    "Answer a VFSHandler for a file named `aName' residing in the directory
     represented by the receiver."

    ^VFSHandler for: (Directory append: aName to: self name)!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."
    self subclassResponsibility!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name. aBlock should not return."
    self subclassResponsibility
! !


!RealFileHandler class methodsFor: 'initialization'!

initialize
    "Initialize the receiver's class variables"
    Epoch := DateTime year: 2000 day: 1 hour: 0 minute: 0 second: 0.
! !


!RealFileHandler methodsFor: 'accessing'!

name: aName
    "Private - Initialize the receiver's instance variables"
    name := File fullNameFor: aName
!

size
    "Answer the size of the file identified by the receiver"
    ^self stat stSize value
!

isDirectory
    "Answer whether the file is a directory."
    ^(self stat stMode value bitAnd: 8r170000) = 8r040000
!

isSymbolicLink
    "Answer whether the file is a symbolic link."
    isSymbolicLink isNil ifTrue: [ self refresh ].
    ^isSymbolicLink
!

lastAccessTime
    "Answer the last access time of the file identified by the receiver"
    ^self getDateAndTime: self stat stAtime value
!

lastChangeTime
    "Answer the last change time of the file identified by the receiver
    (the `last change time' has to do with permissions, ownership and the
    like). On some operating systems, this could actually be the
    file creation time."
    ^self getDateAndTime: self stat stCtime value
!

creationTime
    "Answer the creation time of the file identified by the receiver.
    On some operating systems, this could actually be the last change time
    (the `last change time' has to do with permissions, ownership and the
    like)."
    ^self getDateAndTime: self stat stCtime value
!

lastModifyTime
    "Answer the last modify time of the file identified by the receiver
    (the `last modify time' has to do with the actual file contents)."
    ^self getDateAndTime: self stat stMtime value
!

refresh
    "Refresh the statistics for the receiver"
    stat isNil ifTrue: [
        stat := CStatStruct new.
        stat addToBeFinalized
    ].
    self lstatOn: self realFileName into: stat.
    File checkError.
    isSymbolicLink := (stat stMode value bitAnd: 8r170000) = 8r120000. "S_IFLNK"
    isSymbolicLink ifTrue: [
	self statOn: self realFileName into: stat.
	File checkError ]
! !



!RealFileHandler methodsFor: 'testing'!

exists
    "Answer whether a file with the name contained in the receiver does exist."
    stat isNil ifTrue: [
        stat := CStatStruct new.
        stat addToBeFinalized.
    ].
    self statOn: self realFileName into: stat.
    ^File errno == 0
!

isReadable
    "Answer whether a file with the name contained in the receiver does exist
     and is readable"
    ^self primIsReadable: self realFileName!

isWriteable
    "Answer whether a file with the name contained in the receiver does exist
     and is writeable"
    ^self primIsWriteable: self realFileName!

isExecutable
    "Answer whether a file with the name contained in the receiver does exist
     and is executable"
    ^self primIsExecutable: self realFileName! !


!RealFileHandler methodsFor: 'file operations'!

lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
    "Set the receiver's timestamps to be accessDateTime and modifyDateTime."
    self class
	setTimeFor: self realFileName
	atime: (self secondsFromDateTime: accessDateTime)
	mtime: (self secondsFromDateTime: modifyDateTime).
    File checkError!

open: class mode: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"
    ^class fopen: self realFileName mode: mode ifFail: aBlock
!

remove
    "Remove the file with the given path name"
    self isDirectory
        ifTrue: [ self primRemoveDir: self realFileName ]
        ifFalse: [ self primUnlink: self realFileName ].
    File checkError
!

renameTo: newFileName
    "Rename the file with the given path name oldFileName to newFileName"
    self primRename: self realFileName to: newFileName.
    File checkError
! !


!RealFileHandler methodsFor: 'private'!

secondsFromDateTime: aDateTime
    "Private - Convert a time expressed in seconds from 1/1/2000 to
     an array of two Smalltalk Date and Time objects"
    ^(aDateTime asSeconds - Epoch asSeconds)
	- (aDateTime offset asSeconds - Epoch offset asSeconds)
!

getDateAndTime: time
    "Private - Convert a time expressed in seconds from 1/1/2000 to
     a Smalltalk DateTime object."

    ^(Epoch + (Duration seconds: time))
	offset: (Duration seconds: Time timezoneBias)
!

stat
    "Private - Answer the receiver's statistics' C struct"
    stat isNil ifTrue: [ self refresh ].
    ^stat
! !


!RealFileHandler methodsFor: 'directory operations'!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."
    self
        primCreateDir: (Directory append: dirName to: self realFileName)
        mode: 8r777.

    File checkError
!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name. aBlock should not return."
    | dir entry |
    dir := self openDir: self realFileName.
    File checkError.

    [ entry := self readDir: dir.
      File checkError.
      entry notNil ] whileTrue:
          [ aBlock value: (self extractDirentName: entry) ].
    self closeDir: dir.
! !


!DecodedFileHandler class methodsFor: 'registering'!

initialize
    "Initialize the default virtual filesystems and the associated
     filter commands."
    FileTypes := LookupTable new
	at: 'Z' put: 'compress -cf < %1 > %2';
	at: 'uZ' put: 'zcat -f < %1 > %2';
	at: 'gz' put: 'gzip -cf < %1 > %2';
	at: 'ugz' put: 'gzip -cdf < %1 > %2';
	at: 'bz2' put: 'bzip2 < %1 > %2';
	at: 'ubz2' put: 'bzip2 -d < %1 > %2';
	at: 'tar' put: 'tar chof %2 %1';
	at: 'tgz' put: 'tar chof - %1 | gzip -cf > %2';
	at: 'nop' put: 'cat %1 > %2';
	at: 'strings' put: 'strings %1 > %2';
	yourself!

fileSystems
    "Answer the virtual file systems that can be processed by this subclass.
     These are #gz (gzip a file), #ugz (uncompress a gzipped file),
     #Z (compress a file via Unix compress), #uZ (uncompress a compressed
     file), #bz2 (compress a file via bzip2), #ubz2 (uncompress a file via
     bzip2), #tar (make a tar archive out of a directory), #tgz (make a
     gzipped tar archive out of a directory), #nop (do nothing, used for
     testing) and #strings (use the `strings' utility to extract printable
     strings from a file)."
    ^FileTypes keys!

vfsFor: file name: fsName subPath: subPath
    "Create a temporary file and use it to construct the contents of the given
     file, under the virtual filesystem fsName. subPath must be nil because
     this class supports single-file virtual filesystems only."
    | temp command |
    subPath isNil
	ifFalse: [ SystemExceptions.FileError signal: 'not a tree-shaped filesystem' ].

    command := FileTypes at: fsName.
    temp := FileStream openTemporaryFile: Directory temporary, '/vfs'.
    Smalltalk system: (command bindWith: file with: temp name).
    ^self new name: file realFileName: temp name! !


!DecodedFileHandler methodsFor: 'files'!

name: virtualFileName realFileName: temporaryFileName
    "Private - Initialize a new object storing the contents of the
     virtualFileName file into temporaryFileName."
    self addToBeFinalized.
    self name: virtualFileName.
    realFileName := temporaryFileName!

realFileName
    "Answer the real file name which holds the file contents,
     or nil if it does not apply."
    ^realFileName!

release
    "Release the resources used by the receiver that don't survive when
     reloading a snapshot."

    "Remove the file that was temporarily holding the file contents"
    realFileName isNil ifTrue: [ ^self ].
    self primUnlink: realFileName.
    realFileName := nil.
    super release! !

!ArchiveFileHandler methodsFor: 'querying'!

isDirectory
    "Answer true.  The archive can always be considered as a directory."
    ^true!

isAccessible
    "Answer whether a directory with the name contained in the receiver does
     exist and can be accessed"
    ^true! !


!ArchiveFileHandler methodsFor: 'file operations'!

remove
    "Remove the file with the given path name"
    self primUnlink: self realFileName! !


!ArchiveFileHandler methodsFor: 'directory operations'!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."
    self subclassResponsibility
!

at: aName
    "Answer a VFSHandler for a file named `aName' residing in the directory
     represented by the receiver."

    handlers isNil ifTrue: [
	handlers := LookupTable new.
	self addToBeFinalized
    ].

    ^handlers at: aName ifAbsentPut: [
	ArchiveMemberHandler new
	    name: aName;
	    parent: self ]!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name."

    self subclassResponsibility!

release
    "Release the resources used by the receiver that don't survive when
     reloading a snapshot."

    handlers isNil ifTrue: [ ^self ].
    handlers do: [ :each | each release ].
    handlers := nil.
    super release! !


!ArchiveFileHandler methodsFor: 'ArchiveMemberHandler protocol'!

extractMember: anArchiveMemberHandler
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."
    self subclassResponsibility!

fillMember: anArchiveMemberHandler
    "Extract the information on anArchiveMemberHandler.  Answer
     false if it actually does not exist in the archive; otherwise,
     answer true after having told anArchiveMemberHandler about them
     by sending #size:stCtime:stMtime:stAtime:isDirectory: to it."

    self subclassResponsibility!

member: anArchiveMemberHandler do: aBlock
    "Evaluate aBlock once for each file in the directory represented by
    anArchiveMemberHandler, passing its name."

    self subclassResponsibility!

removeMember: anArchiveMemberHandler
    "Remove the member represented by anArchiveMemberHandler."

    self subclassResponsibility!

updateMember: anArchiveMemberHandler
    "Update the member represented by anArchiveMemberHandler by
     copying the file into which it was extracted back to the
     archive."

    self subclassResponsibility! !


!ExternalArchiveFileHandler class methodsFor: 'registering'!

fileSystems
    "Answer the virtual file systems that can be processed by this subclass.
     These are given by the names of the executable files in the `vfs'
     subdirectory of the image directory, of the parent of the kernel
     directory and (if the image is not the global installed image)
     of the `.st' directory in the home directory."
    ActivePaths := WeakValueLookupTable new. 
    FileTypes := LookupTable new. 
    [ self fileSystemsIn: Directory kernel, '/../vfs' ]
	on: Error do: [ :ex | ex return ].
    [ self fileSystemsIn: Directory userBase, '/vfs' ]
	on: Error do: [ :ex | ex return ].
    Smalltalk imageLocal ifTrue: [
        [ self fileSystemsIn: Directory image, '/vfs' ]
	    on: Error do: [ :ex | ex return ] ].
	
    ^FileTypes keys asSet!

fileSystemsIn: path
    "Registers the executable files in the given directory to be used
     to resolve a virtual file system."
    | dir |
    dir := RealFileHandler for: path.
    dir exists ifFalse: [ ^self ].
    dir do: [ :each |
	(File isExecutable: path, '/', each)
	    ifTrue: [ FileTypes at: each put: path, '/', each ]
    ]!

release
    "Avoid that paths stay in the image file"
    FileTypes := nil.
    super release!

vfsFor: file name: fsName subPath: subPath
    "Create a temporary file and use it to construct the contents of the given
     file, under the virtual filesystem fsName."
    subPath isNil ifFalse: [
	^(self vfsFor: file name: fsName subPath: nil)
	    at: subPath
    ].

    ^ActivePaths at: (fsName -> file) ifAbsentPut: [
	| command temp |
        command := FileTypes at: fsName.
	self new
	    name: file;
	    command: command
    ]! !


!ExternalArchiveFileHandler methodsFor: 'members'!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."

    Smalltalk system: command,
	(' mkdir %1 %2'
	    bindWith: self name
	    with: dirName)!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name."
    topLevelFiles do: aBlock!


!ExternalArchiveFileHandler methodsFor: 'ArchiveMemberHandler protocol'!

extractMember: anArchiveMemberHandler
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."

    extractedFiles isNil ifTrue: [
	extractedFiles := IdentityDictionary new ].

    ^extractedFiles at: anArchiveMemberHandler ifAbsentPut: [
	| temp |
        temp := FileStream openTemporaryFile: Directory temporary, '/vfs'.
        Smalltalk system: command,
	    (' copyout %1 %2 %3'
	        bindWith: self name
	        with: anArchiveMemberHandler name
	        with: temp name).

        temp name
    ]!

fillMember: anArchiveMemberHandler
    "Extract the information on anArchiveMemberHandler.  Answer
     false if it actually does not exist in the archive; otherwise,
     answer true after having told anArchiveMemberHandler about them
     by sending #size:stCtime:stMtime:stAtime:isDirectory: to it."

    | data |
    allFiles isNil ifTrue: [ self refresh ].
    data := allFiles at: anArchiveMemberHandler name ifAbsent: [ nil ].
    data isNil ifTrue: [ ^false ].

    anArchiveMemberHandler
	size: (data at: 1)
	stCtime: self lastModifyTime
	stMtime: (data at: 2)
	stAtime: self lastAccessTime
	isDirectory: (data at: 3) notNil.

    ^true!

member: anArchiveMemberHandler do: aBlock
    "Evaluate aBlock once for each file in the directory represented by
    anArchiveMemberHandler, passing its name."

    | data |
    allFiles isNil ifTrue: [ self refresh ].
    data := allFiles at: anArchiveMemberHandler name ifAbsent: [ nil ].
    data isNil
	ifTrue: [ ^SystemExceptions.FileError signal: 'File not found' ].
    (data at: 3) isNil
	ifTrue: [ ^SystemExceptions.FileError signal: 'Not a directory' ].

    (data at: 3) do: aBlock!

removeMember: anArchiveMemberHandler
    "Remove the member represented by anArchiveMemberHandler."

    | subcmd |
    subcmd := anArchiveMemberHandler isDirectory
	ifTrue: [ 'rmdir' ]
	ifFalse: [ 'rm' ].

    Smalltalk system: command,
	(' %1 %2 %3'
	    bindWith: subcmd
	    with: self name
	    with: anArchiveMemberHandler name)!

updateMember: anArchiveMemberHandler
    "Update the member represented by anArchiveMemberHandler by
     copying the file into which it was extracted back to the
     archive."

    | temp |
    temp := FileStream openTemporaryFile: Directory temporary, '/vfs'.
    Smalltalk system: command,
	(' copyin %1 %2 %3'
	    bindWith: self name
	    with: anArchiveMemberHandler name
	    with: anArchiveMemberHandler realFileName).

    ^temp name!

refresh
    "Extract the directory listing from the archive"

    | pipe line isDir size date path parentPath name
      current currentPath directoryTree directory |
    super refresh.

    current := currentPath := nil.
    allFiles := LookupTable new.
    directoryTree := LookupTable new.
    pipe := FileStream
	popen: command, ' list ', self name
	dir: FileStream read.
    [
	line := pipe nextLine readStream.
	line atEnd
    ] whileFalse: [
	isDir := line next = $d.
	line skipTo: Character space.   	"Attributes"
	line skipSeparators.
	line skipTo: Character space.   	"Number of links"
	line skipSeparators.
	line skipTo: Character space.   	"Owner"
	line skipSeparators.
	line skipTo: Character space.   	"Group"
	line skipSeparators.
	size := Number readFrom: line.		"File size"
	line skipSeparators.
	date := DateTime readFrom: line.	"Date"
	line skipSeparators.
	path := line upToAll: ' -> '.		"Path"

	path last = $/
	    ifTrue: [ path := path copyFrom: 1 to: path size - 1 ].

	"Look up the tree for the directory in which the file resides.
         We keep a simple 1-element cache."

	parentPath := File pathFor: path.
	name := File stripPathFrom: path.
	parentPath = currentPath ifFalse: [
	    currentPath := parentPath.
	    current := self findDirectory: path into: directoryTree
	].

	"Create an item in the tree for directories, and
	 add an association to the allFiles SortedCollection"

	directory := isDir
	    ifTrue: [ current at: name put: LookupTable new ]
	    ifFalse: [ current at: name put: nil ].

	allFiles at: path put: { size. date. directory }.
    ].

    "Leave the LookupTables to be garbage collected, we are now interested
     in the file names only."
    topLevelFiles := directoryTree keys asArray.
    allFiles do: [ :data |
	(data at: 3) isNil ifFalse: [
	    data at: 3 put: (data at: 3) keys asArray
	]
    ].

    pipe close
! !


!ExternalArchiveFileHandler methodsFor: 'private'!

command: cmd
    command := cmd!

findDirectory: path into: tree
    "Look up into tree (which is a tree of Dictionaries) the directory
     that is the parent of the file named `path'."

    | current last |
    current := tree.
    last := 1.
    path keysAndValuesDo: [ :i :each |
	| element |
	each = $/ ifTrue: [
	    last = i ifFalse: [
		element := path copyFrom: last to: i - 1.
		current := current at: element ifAbsentPut: [
		    "The list command might output files but not
		    directories.  No problem, we create them along
		    the way."

		    | directory |
		    directory := LookupTable new.
		    allFiles
			at: (path copyFrom: 1 to: i - 1)
			put: { 0. self creationTime. directory }.

		    directory
		]
	    ].
	    last := i + 1
	]
    ].
    ^current! !


!ExternalArchiveFileHandler methodsFor: 'releasing'!

release
    "Release the resources used by the receiver that don't survive when
     reloading a snapshot."

    extractedFiles := nil.
    super release! !


!ArchiveMemberHandler methodsFor: 'initializing'!

parent: anArchiveFileHandler
    "Set the archive of which the receiver is a member."

    parent := anArchiveFileHandler!

size: bytes stCtime: ctime stMtime: mtime stAtime: atime isDirectory: isDir
    "Called back by the receiver's parent when the ArchiveMemberHandler
     asks for file information."
    size := bytes.
    stCtime := ctime.
    stMtime := mtime.
    stAtime := atime.
    isDirectory := isDir! !

!ArchiveMemberHandler methodsFor: 'accessing'!

parent
    "Answer the archive of which the receiver is a member."

    ^parent!

size
    "Answer the size of the file identified by the receiver"
    size isNil ifTrue: [ self refresh ].
    ^size
!

lastAccessTime
    "Answer the last access time of the file identified by the receiver"
    stAtime isNil ifTrue: [ self refresh ].
    ^stAtime
!

lastChangeTime
    "Answer the last change time of the file identified by the receiver
    (the `last change time' has to do with permissions, ownership and the
    like). On some operating systems, this could actually be the
    file creation time."
    stCtime isNil ifTrue: [ self refresh ].
    ^stCtime
!

creationTime
    "Answer the creation time of the file identified by the receiver.
    On some operating systems, this could actually be the last change time
    (the `last change time' has to do with permissions, ownership and the
    like)."
    stCtime isNil ifTrue: [ self refresh ].
    ^stCtime
!

lastModifyTime
    "Answer the last modify time of the file identified by the receiver
    (the `last modify time' has to do with the actual file contents)."
    stMtime isNil ifTrue: [ self refresh ].
    ^stMtime
!

refresh
    "Refresh the statistics for the receiver"
    self parent fillMember: self
! !



!ArchiveMemberHandler methodsFor: 'testing'!

exists
    "Answer whether a file with the name contained in the receiver does exist."
    ^self parent fillMember: self!

isDirectory
    "Answer whether a file with the name contained in the receiver does exist
    and identifies a directory."
    size isNil ifTrue: [ self refresh ].
    ^isDirectory!

isReadable
    "Answer whether a file with the name contained in the receiver does exist
     and is readable"
    ^true!

isWriteable
    "Answer whether a file with the name contained in the receiver does exist
     and is writeable"
    ^true!

isExecutable
    "Answer whether a file with the name contained in the receiver does exist
     and is executable"
    ^false!

isAccessible
    "Answer whether a directory with the name contained in the receiver does exist
     and is accessible"
    ^true! !


!ArchiveMemberHandler methodsFor: 'finalization'!

realFileName
    "Answer the real file name which holds the file contents,
     or nil if it does not apply."

    realFileName isNil ifFalse: [ ^realFileName ].
    self exists ifFalse: [ ^nil ].
    realFileName := (self parent extractMember: self).
    ^realFileName!

release
    "Release the resources used by the receiver that don't survive when
     reloading a snapshot."

    "Remove the file that was temporarily holding the file contents"
    realFileName isNil ifTrue: [ ^self ].
    self primUnlink: realFileName.
    realFileName := nil.
    super release! !

!ArchiveMemberHandler methodsFor: 'file operations'!

open: class mode: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"

    | fileStream |
    self realFileName isNil ifTrue: [ ^aBlock value ].

    fileStream := class
	fopen: self realFileName
	mode: mode
	ifFail: [ ^aBlock value ].

    mode == FileStream read ifFalse: [
	fileStream addDependent: self ].

    ^fileStream
!

update: aspect
    "Private - Update the in-archive version of the file before closing."

    aspect == #beforeClosing ifTrue: [
	self parent updateMember: self ]
    aspect == #afterClosing ifTrue: [
	self parent refresh.
	self refresh
    ]
!

remove
    "Remove the file with the given path name"
    self parent removeMember: self.
    File checkError
!

renameTo: newFileName
    "Rename the file with the given path name oldFileName to newFileName"
    self notYetImplemented
! !


!ArchiveMemberHandler methodsFor: 'directory operations'!

at: aName
    "Answer a VFSHandler for a file named `aName' residing in the directory
     represented by the receiver."

    ^self parent at: (Directory append: aName to: self name)
!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."

    self parent createDir: (Directory append: dirName to: self name)
!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name."
    self parent member: self do: aBlock
! !

RealFileHandler initialize!
DecodedFileHandler initialize!
VFSHandler initialize!
Namespace current: Smalltalk!
