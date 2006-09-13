"======================================================================
|
|   File Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005
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


Object subclass: #File
       instanceVariableNames: 'vfsHandler'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
! 

File comment: 
'I expose the syntax of file names, including paths.  I know how to
manipulate such a path by splitting it into its components.  In addition,
I expose information about files (both real and virtual) such as their
size and timestamps.'!

!File class methodsFor: 'C functions'!

stringError: errno
    <cCall: 'strerror' returning: #string args: #(#int)>!

errno
    <cCall: 'errno' returning: #long args: #()>! !


!File class methodsFor: 'file name management'!

extensionFor: aString
    "Answer the extension of a file named `aString'.  Note: the extension
     includes an initial dot."
    | index |
    aString isEmpty ifTrue: [ ^'' ].
    index := aString findLast: [ :each |
	each = Directory pathSeparator ifTrue: [ ^'' ].
	each = $.
    ].

    "Special case foo, .foo and /bar/.foo, all of which have no extension"
    index <= 1 ifTrue: [ ^'' ].
    (aString at: index - 1) = Directory pathSeparator ifTrue: [ ^'' ].
    ^aString copyFrom: index to: aString size.
!

stripExtensionFrom: aString
    "Remove the extension from the name of a file called `aString', and
     answer the result."
    | index |
    aString isEmpty ifTrue: [ ^'' ].
    index := aString findLast: [ :each |
	each = Directory pathSeparator ifTrue: [ ^aString ].
	each = $.
    ].

    "Special case foo, .foo and /bar/.foo, all of which have no extension"
    index <= 1 ifTrue: [ ^aString ].
    (aString at: index - 1) = Directory pathSeparator ifTrue: [ ^aString ].
    ^aString copyFrom: 1 to: index - 1
!

stripPathFrom: aString
    "Remove the path from the name of a file called `aString', and
     answer the file name plus extension."
    | index |
    aString isEmpty ifTrue: [ ^'' ].
    index := aString findLast: [ :each | each = Directory pathSeparator ].
    ^aString copyFrom: index + 1 to: aString size
!

pathFor: aString ifNone: aBlock
    "Determine the path of the name of a file called `aString', and
     answer the result.  With the exception of the root directory, the
     final slash is stripped.  If there is no path, evaluate aBlock and
     return the result."
    | index |
    aString isEmpty ifTrue: [ ^aBlock value ].
    index := aString findLast: [ :each | each = Directory pathSeparator ].
    index = 0 ifTrue: [ ^aBlock value ].
    index = 1 ifTrue: [ ^Directory pathSeparatorString ].
    ^aString copyFrom: 1 to: index - 1.
!

pathFor: aString
    "Determine the path of the name of a file called `aString', and
     answer the result.  With the exception of the root directory, the
     final slash is stripped."
    ^self pathFor: aString ifNone: [ '' ]
!

stripFileNameFor: aString
    "Determine the path of the name of a file called `aString', and
     answer the result as a directory name including the final slash."
    | index |
    aString isEmpty ifTrue: [ ^'./' ].
    index := aString findLast: [ :each | each = Directory pathSeparator ].
    index = 0 ifTrue: [ ^'./' ].
    index = 1 ifTrue: [ ^Directory pathSeparatorString ].
    ^aString copyFrom: 1 to: index.
!

fullNameFor: aString
    "Answer the full path to a file called `aString', resolving the `.' and
     `..' directory entries, and answer the result.  `/..' is the same as '/'."

    | path substrings |
    path := OrderedCollection new.
    (aString at: 1) = Directory pathSeparator ifFalse: [
	path addAll: (Directory working substrings: Directory pathSeparator).
    ].
    substrings := aString substrings: Directory pathSeparator.
    substrings := ReadStream on: substrings.

    substrings do: [ :each |
	each = '.' ifFalse: [
	    each = '..'
		ifTrue: [ path isEmpty ifFalse: [ path removeLast ] ]
		ifFalse: [ path add: each ].
	]
    ].

    ^path inject: '/' into: [ :old :each |
	Directory append: each to: old
    ]
! !


!File class methodsFor: 'file operations'!

checkError
    "Return whether an error had been reported or not.
     If there had been one, raise an exception too"

    ^self checkError: self errno
!

checkError: errno
    "The error with the C code `errno' has been reported.
     If errno >= 1, raise an exception"

    | errors |
    errno < 1 ifTrue: [ ^false ].
    SystemExceptions.FileError signal: (self stringError: errno).
    ^true
!

touch: fileName
    "Update the timestamp of the file with the given path name."
    (File name: fileName) touch
!

remove: fileName
    "Remove the file with the given path name"
    (VFS.VFSHandler for: fileName) remove
!

rename: oldFileName to: newFileName
    "Rename the file with the given path name oldFileName to newFileName"
    (VFS.VFSHandler for: oldFileName) renameTo: newFileName
! !


!File class methodsFor: 'instance creation'!

on: aVFSHandler
    "Answer a new file with the given path. The handler that returns
     the information is aVFSHandler"
    ^self basicNew init: aVFSHandler!

name: aName
    "Answer a new file with the given path. The path is not validated until
    some of the fields of the newly created objects are accessed"
    ^self on: (VFS.VFSHandler for: aName)
! !


!File class methodsFor: 'testing'!

exists: fileName
    "Answer whether a file with the given name exists"
    ^(File name: fileName) exists
!

isReadable: fileName
    "Answer whether a file with the given name exists and is readable"
    ^(File name: fileName) isReadable
!

isWriteable: fileName
    "Answer whether a file with the given name exists and is writeable"
    ^(File name: fileName) isWriteable
!

isExecutable: fileName
    "Answer whether a file with the given name exists and can be executed"
    ^(File name: fileName) isExecutable
!

isAccessible: fileName
    "Answer whether a directory with the given name exists and can be accessed"
    ^(File name: fileName) isAccessible
! !


!File class methodsFor: 'reading system defaults'!

image
    "Answer the full path to the image being used."
    ^ImageFileName
! !


!File methodsFor: 'accessing'!

name
    "Answer the name of the file identified by the receiver"
    ^vfsHandler name
!

size
    "Answer the size of the file identified by the receiver"
    ^vfsHandler size
!

lastAccessTime: aDateTime
    "Update the last access time of the file corresponding to the receiver,
     to be aDateTime."
    vfsHandler lastAccessTime: aDateTime lastModifyTime: self lastModifyTime
!

lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
    "Update the timestamps of the file corresponding to the receiver, to be
     accessDateTime and modifyDateTime."
    vfsHandler lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
!

lastAccessTime
    "Answer the last access time of the file identified by the receiver"
    ^vfsHandler lastAccessTime
!

lastChangeTime
    "Answer the last change time of the file identified by the receiver
    (the `last change time' has to do with permissions, ownership and the
    like). On some operating systems, this could actually be the
    file creation time."
    ^vfsHandler lastChangeTime
!

creationTime
    "Answer the creation time of the file identified by the receiver.
    On some operating systems, this could actually be the last change time
    (the `last change time' has to do with permissions, ownership and the
    like)."
    ^vfsHandler creationTime
!

lastModifyTime: aDateTime
    "Update the last modification timestamp of the file corresponding to the
     receiver, to be aDateTime."
    vfsHandler lastAccessTime: self lastAccessTime lastModifyTime: aDateTime
!

lastModifyTime
    "Answer the last modify time of the file identified by the receiver
    (the `last modify time' has to do with the actual file contents)."
    ^vfsHandler lastModifyTime
!

refresh
    "Refresh the statistics for the receiver"
    vfsHandler refresh
! !



!File methodsFor: 'testing'!

exists
    "Answer whether a file with the name contained in the receiver does exist."
    ^vfsHandler exists
!

isSymbolicLink
    "Answer whether a file with the name contained in the receiver does exist
    and does not identify a directory."
    ^vfsHandler exists and: [ vfsHandler isSymbolicLink ]
!

isFile
    "Answer whether a file with the name contained in the receiver does exist
    and does not identify a directory."
    ^vfsHandler exists and: [ vfsHandler isDirectory not ]
!

isDirectory
    "Answer whether a file with the name contained in the receiver does exist
    and identifies a directory."
    | dir errno |
    ^vfsHandler exists and: [ vfsHandler isDirectory ]
!

isReadable
    "Answer whether a file with the name contained in the receiver does exist
     and is readable"
    ^vfsHandler exists and: [ vfsHandler isReadable ]!

isWriteable
    "Answer whether a file with the name contained in the receiver does exist
     and is writeable"
    ^self exists and: [ vfsHandler isWriteable ]!

isExecutable
    "Answer whether a file with the name contained in the receiver does exist
     and is executable"
    ^self isFile and: [ vfsHandler isExecutable ]!

isAccessible
    "Answer whether a directory with the name contained in the receiver does
     exist and can be accessed"
    ^self isDirectory and: [ vfsHandler isAccessible ]! !


!File methodsFor: 'file name management'!

extension
    "Answer the extension of the receiver"
    ^File extensionFor: self name
!

stripExtension
    "Answer the path (if any) and file name of the receiver"
    ^File stripExtensionFrom: self name
!

stripPath
    "Answer the file name and extension (if any) of the receiver"
    ^File stripPathFrom: self name
!

path
    "Answer the path (if any) of the receiver"
    ^File pathFor: self name
!

stripFileName
    "Answer the path of the receiver, always including a directory
     name (possibly `.') and the final directory separator"
    ^File stripFileNameFor: self name
!

fullName
    "Answer the full name of the receiver, resolving the `.' and
     `..' directory entries, and answer the result.  Answer nil if the
     name is invalid (such as '/usr/../../badname')"
    ^File fullNameFor: self name
! !


!File methodsFor: 'file operations'!

contents
    "Open a read-only FileStream on the receiver, read its contents,
    close the stream and answer the contents"
    | stream contents |
    stream := self readStream.
    contents := stream contents.
    stream close.
    ^contents
!

touch
    "Update the timestamp of the file corresponding to the receiver."
    | now |
    self exists
	ifTrue: [
	    now := DateTime now.
	    self lastAccessTime: now lastModifyTime: now ]
	ifFalse: [
	    (self open: FileStream append) close ]
!

open: mode
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"
    ^vfsHandler open: mode ifFail: [
 	    SystemExceptions.FileError signal: 'could not open ', self name ]
!

openDescriptor: mode
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods)"
    ^vfsHandler openDescriptor: mode ifFail: [
 	    SystemExceptions.FileError signal: 'could not open ', self name ]
!

open: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods). Upon failure, evaluate aBlock."
    ^vfsHandler open: mode ifFail: aBlock
!

openDescriptor: mode ifFail: aBlock
    "Open the receiver in the given mode (as answered by FileStream's
    class constant methods). Upon failure, evaluate aBlock."
    ^vfsHandler openDescriptor: mode ifFail: aBlock
!

readStream
    "Open a read-only FileStream on the receiver"
    ^self open: FileStream read
!

writeStream
    "Open a write-only FileStream on the receiver"
    ^self open: FileStream write
!

remove
    "Remove the file identified by the receiver"
    ^vfsHandler remove
!

renameTo: newName
    "Rename the file identified by the receiver to newName"
    vfsHandler renameTo: newName
! !


!File methodsFor: 'private'!

init: aVFSHandler
    "Private - Initialize the receiver's instance variables"
    vfsHandler := aVFSHandler
! !
