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
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

DecodedFileHandler class
	instanceVariableNames: 'fileTypes'!

DecodedFileHandler comment: 'DecodedFileHandler handles
virtual filesystems that take a file that is on-disk, run a
command on it, and then read from the result.'!

RealFileHandler subclass: #ArchiveFileHandler
       instanceVariableNames: 'handlers fsName topLevelFiles allFiles extractedFiles'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ArchiveFileHandler class
	instanceVariableNames: 'activePaths'!

ArchiveFileHandler comment: 'ArchiveFileHandler handles
virtual filesystems that have a directory structure of
their own.  The directories and files in the archive are
instances of ArchiveMemberHandler, but the functionality
resides entirely in ArchiveFileHandler because the members
will still ask the archive to get directory information
on them, to extract them to a real file, and so on.'!

ArchiveFileHandler subclass: #ZipFileHandler
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

ZipFileHandler comment: 'ZipFileHandler transparently extracts
files from a ZIP archive.'!

VFSHandler subclass: #ArchiveMemberHandler
       instanceVariableNames: 'parent mode size stCtime stMtime stAtime realFileName'
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

primChmod: name mode: mode
    <cCall: 'chmod' returning: #int args: #(#string #int)>!

primIsReadable: name
    <cCall: 'fileIsReadable' returning: #boolean args: #(#string)>!

primIsWriteable: name
    <cCall: 'fileIsWriteable' returning: #boolean args: #(#string)>!

primIsExecutable: name
    <cCall: 'fileIsExecutable' returning: #boolean args: #(#string)>!

primSymlink: srcName as: destName
    <cCall: 'symlink' returning: #void args: #(#string #string)>!

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

priority
    "Answer the priority for this class (higher number = higher priority) in
     case multiple classes implement the same file system.  The default is 0."
    ^0!

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
    ((Registry includesKey: fileSystem) not
	or: [ (Registry at: fileSystem) priority < vfsHandlerClass priority ])
	    ifTrue: [ Registry at: fileSystem put: vfsHandlerClass ]! !

!VFSHandler class methodsFor: 'private'!

register
    Registry isNil ifTrue: [ VFSHandler registerAll ].
    self fileSystems do: [ :fs | VFSHandler register: fs forClass: self ]!

registerAll
    "Register all file systems under the VFSHandler hierarchy."
    Registry isNil ifTrue: [ Registry := LookupTable new ].
    self allSubclassesDo: [ :each | each register ]!

vfsFor: fileName name: fsName subPath: subPath
    "Create an instance of a subclass of the receiver, implementing the virtual
     file `subPath' inside the `fileName' archive.  fsName is the virtual
     filesystem name and is used to determine the subclass to be instantiated."
    Registry isNil ifTrue: [ self registerAll ].
    ^(Registry at: fsName) 
	vfsFor: fileName name: fsName subPath: subPath!


!VFSHandler methodsFor: 'releasing'!

finalize
    "Upon finalization, we remove the file that was temporarily holding the file
     contents"
    self release! !

!VFSHandler methodsFor: 'accessing'!

fullName
    "Answer the name of the file identified by the receiver as answered by
     File>>#name."
    ^self name
!

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

symlinkFrom: srcName
    "Create the receiver as a symlink from the relative path srcName"
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

mode
    "Answer the octal permissions for the file."
    ^self stat stMode value bitAnd: 8r7777
!

mode: mode
    "Set the octal permissions for the file to be `mode'."
    self primChmod: (self name) mode: (mode bitAnd: 8r7777).
    File checkError
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

finalize
    "Free the statistics for the receiver"
    | statVar |
    statVar := stat.
    stat := nil.
    statVar free
!

refresh
    "Refresh the statistics for the receiver"
    stat isNil ifTrue: [
        stat := CStatStruct new.
        self addToBeFinalized
    ].
    self lstatOn: self realFileName into: stat.
    File checkError.
    isSymbolicLink := (stat stMode value bitAnd: 8r170000) = 8r120000. "S_IFLNK"
    isSymbolicLink ifTrue: [
	self statOn: self realFileName into: stat.
	File errno ]
! !



!RealFileHandler methodsFor: 'testing'!

exists
    "Answer whether a file with the name contained in the receiver does exist."
    stat isNil ifTrue: [
        stat := CStatStruct new.
        self addToBeFinalized.
    ].
    self lstatOn: self realFileName into: stat.
    File errno == 0 ifFalse: [ ^false ].

    isSymbolicLink := (stat stMode value bitAnd: 8r170000) = 8r120000. "S_IFLNK"
    isSymbolicLink ifTrue: [ self statOn: self realFileName into: stat ].
    ^true
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

symlinkFrom: srcName
    "Create the receiver as a symlink from path destName"
    self primSymlink: srcName as: self realFileName.
    File checkError
!

renameTo: newFileName
    "Rename the file with the given path name to newFileName"
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

priority
    "Answer the priority for this class (higher number = higher priority) in
     case multiple classes implement the same file system."
    ^-10!

fileTypes
    "Return the valid virtual filesystems and the associated
     filter commands."
    fileTypes isNil ifTrue: [ fileTypes := self defaultFileTypes ].
    ^fileTypes!

defaultFileTypes
    "Return the default virtual filesystems and the associated
     filter commands."
    ^LookupTable new
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
    ^self fileTypes keys!

vfsFor: file name: fsName subPath: subPath
    "Create a temporary file and use it to construct the contents of the given
     file, under the virtual filesystem fsName. subPath must be nil because
     this class supports single-file virtual filesystems only."
    | temp command |
    subPath isNil
	ifFalse: [ SystemExceptions.FileError signal: 'not a tree-shaped filesystem' ].

    command := self fileTypes at: fsName.
    temp := FileStream openTemporaryFile: Directory temporary, '/vfs'.
    Smalltalk system: (command % { file. temp name }).
    ^self new name: file fsName: fsName realFileName: temp name! !


!DecodedFileHandler methodsFor: 'files'!

name: virtualFileName fsName: aString realFileName: temporaryFileName
    "Private - Initialize a new object storing the contents of the
     virtualFileName file into temporaryFileName."
    VFSHandler addDependent: self.
    self addToBeFinalized.
    self name: virtualFileName, '#', aString.
    realFileName := File fullNameFor: temporaryFileName!

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


!ArchiveFileHandler class methodsFor: 'instance creation'!

vfsFor: file name: fsName
    "Create an instance of this class representing the contents of the given
     file, under the virtual filesystem fsName."
    ^self new
	name: file fsName: fsName!

vfsFor: file name: fsName subPath: subPath
    "Create a temporary file and use it to construct the contents of the given
     file, under the virtual filesystem fsName."
    subPath isNil
	ifFalse: [ ^(self vfsFor: file name: fsName subPath: nil) at: subPath ].

    ^self activePaths at: (fsName -> file) ifAbsentPut: [
	self vfsFor: file name: fsName ]! !

!ArchiveFileHandler methodsFor: 'accessing'!

name
    ^super name, '#', self fsName!

fsName
    ^fsName! !

!ArchiveFileHandler class methodsFor: 'private'!

activePaths
    "Answer a dictionary that stores the currently opened archive file
     members, to avoid extracting members multiple times.  Might be
     worthwhile to push it to the superclass."
    activePaths isNil ifTrue: [ activePaths := WeakValueLookupTable new ]. 
    ^activePaths!

release
    activePaths := nil.
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
	VFSHandler addDependent: self.
	self addToBeFinalized
    ].

    ^handlers at: aName ifAbsentPut: [
	ArchiveMemberHandler new
	    name: aName;
	    parent: self ]!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name."
    topLevelFiles do: aBlock!

release
    "Release the resources used by the receiver that don't survive when
     reloading a snapshot."

    handlers isNil ifTrue: [ ^self ].
    handlers do: [ :each | each release ].
    handlers := nil.
    extractedFiles := nil.
    super release! !


!ArchiveFileHandler methodsFor: 'ArchiveMemberHandler protocol'!

extractMember: anArchiveMemberHandler
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."

    extractedFiles isNil ifTrue: [
	extractedFiles := IdentityDictionary new ].

    ^extractedFiles at: anArchiveMemberHandler ifAbsentPut: [
        | temp |
        temp := FileStream openTemporaryFile: Directory temporary, '/vfs'.
	self extractMember: anArchiveMemberHandler into: temp.
        File fullNameFor: temp name ]!

extractMember: anArchiveMemberHandler into: file
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."
    self subclassResponsibility!

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
	mode: (data at: 3).

    ^true!

member: anArchiveMemberHandler do: aBlock
    "Evaluate aBlock once for each file in the directory represented by
    anArchiveMemberHandler, passing its name."

    | data |
    allFiles isNil ifTrue: [ self refresh ].
    data := allFiles at: anArchiveMemberHandler name ifAbsent: [ nil ].
    data isNil
	ifTrue: [ ^SystemExceptions.FileError signal: 'File not found' ].
    (data at: 4) isNil
	ifTrue: [ ^SystemExceptions.FileError signal: 'Not a directory' ].

    (data at: 4) do: aBlock!

refresh
    "Extract the directory listing from the archive"

    | pipe line parentPath name current currentPath directoryTree directory |
    super refresh.

    current := currentPath := nil.
    allFiles := LookupTable new.
    directoryTree := LookupTable new.
    self files do: [ :data || path size date mode |
	path := data at: 1.
	size := data at: 2.
	date := data at: 3.
	mode := data at: 4.

	mode isCharacter ifTrue: [ mode := (mode == $d) ].
	mode == true ifTrue: [ mode := 8r040755 ].
	mode == false ifTrue: [ mode := 8r644 ].
	mode isString ifTrue: [ mode := self convertModeString: mode ].

	path last = $/ ifTrue: [ path := path copyFrom: 1 to: path size - 1 ].

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

	directory := (mode bitAnd: 8r170000) = 8r40000
	    ifTrue: [ current at: name put: LookupTable new ]
	    ifFalse: [ current at: name put: nil ].

	allFiles at: path put: { size. date. mode. directory } ].

    "Leave the LookupTables to be garbage collected, we are now interested
     in the file names only."
    topLevelFiles := directoryTree keys asArray.
    allFiles do: [ :data |
	(data at: 4) isNil ifFalse: [
	    data at: 4 put: (data at: 4) keys asArray
	]
    ]!

member: anArchiveMemberHandler mode: bits
    "Set the permission bits for the file in anArchiveMemberHandler."

    self subclassResponsibility!

removeMember: anArchiveMemberHandler
    "Remove the member represented by anArchiveMemberHandler."

    self subclassResponsibility!

updateMember: anArchiveMemberHandler
    "Update the member represented by anArchiveMemberHandler by
     copying the file into which it was extracted back to the
     archive."

    self subclassResponsibility! !

!ArchiveFileHandler methodsFor: 'private'!

convertModeString: modeString
    "Convert the mode from a string to an octal number."
    | mode |
    mode := 0.
    (modeString at: 1) = $l ifTrue: [ mode := 8r120000 ].
    (modeString at: 1) = $d ifTrue: [ mode := 8r040000 ].
    (modeString at: 4) asLowercase = $s ifTrue: [ mode := mode + 8r04000 ].
    (modeString at: 7) asLowercase = $s ifTrue: [ mode := mode + 8r02000 ].
    (modeString at: 10) asLowercase = $t ifTrue: [ mode := mode + 8r01000 ].
    modeString from: 2 to: 10 keysAndValuesDo: [ :i :ch |
	ch isLowercase ifTrue: [ mode := mode setBit: 11 - i ] ].
    ^mode
!

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
    ^current!

name: containerFileName fsName: aString
    super name: containerFileName.
    fsName := aString! !


!ZipFileHandler class methodsFor: 'registering'!

priority
    "Answer the priority for this class (higher number = higher priority) in
     case multiple classes implement the same file system."
    ^-10!

fileSystems
    "Answer the virtual file systems that can be processed by this subclass."
    ^#('uzip')! !

!ZipFileHandler methodsFor: 'members'!

createDir: dirName
    "Create a subdirectory of the receiver, naming it dirName."

    self notYetImplemented!

member: anArchiveMemberHandler mode: bits
    "Set the permission bits for the file in anArchiveMemberHandler."

    self notYetImplemented!

extractMember: anArchiveMemberHandler into: temp
    "Extract the contents of anArchiveMemberHandler into a file
     that resides on disk, and answer the name of the file."
    Smalltalk system: ('unzip -p %1 %2 > %3'
	% { self realFileName. anArchiveMemberHandler name. temp name })!

removeMember: anArchiveMemberHandler
    "Remove the member represented by anArchiveMemberHandler."

    Smalltalk system: ('zip -d %1 %2'
	% { self realFileName. anArchiveMemberHandler name. })!

updateMember: anArchiveMemberHandler
    "Update the member represented by anArchiveMemberHandler by
     copying the file into which it was extracted back to the
     archive."

    self notYetImplemented!

files
    "Extract the directory listing from the archive"

    ^Generator on: [ :gen || pipe |
	pipe := FileStream
	    popen: 'unzip -Z ', self realFileName
	    dir: FileStream read.

        pipe linesDo: [ :l || result mode size path date |
	    "Extract first character, fourth field, seventh+eighth field, rest of line."
	    result := l searchRegex:
		'^(.{10})\s+\S+\s+\S+\s+(\d+)\s+\S+\s+\S+\s+(\S+\s+\S+)\s(.*?)(?: -> |$)'.
	    result matched ifTrue: [
	        mode := result at: 1.
	        size := (result at: 2) asInteger.
	        date := DateTime readFrom: (result at: 3) readStream.
	        path := result at: 4.
	        gen yield: { path. size. date. mode } ] ].

	pipe close ]! !


!ArchiveMemberHandler methodsFor: 'initializing'!

parent: anArchiveFileHandler
    "Set the archive of which the receiver is a member."

    parent := anArchiveFileHandler!

size: bytes stCtime: ctime stMtime: mtime stAtime: atime mode: modeBits
    "Called back by the receiver's parent when the ArchiveMemberHandler
     asks for file information."
    size := bytes.
    stCtime := ctime.
    stMtime := mtime.
    stAtime := atime.
    mode := modeBits! !

!ArchiveMemberHandler methodsFor: 'accessing'!

realFileName
    "Answer the real file name which holds the file contents,
     or nil if it does not apply."

    realFileName isNil ifFalse: [ ^realFileName ].
    self exists ifFalse: [ ^nil ].
    realFileName := (self parent extractMember: self).
    ^realFileName!

fullName
    "Answer the name of the file identified by the receiver as answered by
     File>>#name."
    ^Directory append: self name to: self parent name!

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

mode
    "Answer the octal permissions for the file."
    size isNil ifTrue: [ self refresh ].
    ^mode bitAnd: 8r7777
!

mode: mode
    "Set the octal permissions for the file to be `mode'."
    self parent member: self mode: (mode bitAnd: 8r7777).
!

isDirectory
    "Answer whether a file with the name contained in the receiver does exist
    and identifies a directory."
    size isNil ifTrue: [ self refresh ].
    ^(mode bitAnd: 8r170000) = 8r040000
!

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

    fileStream setName: self fullName.
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
