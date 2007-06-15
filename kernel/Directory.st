"======================================================================
|
|   Directory Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2007
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


File subclass: #Directory
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Files'
!    

Directory comment: 
'I am the counterpart of File in a tree-structured file system: I can
iterate through the file that I contain and construct new instances
of File and Directory.  In addition I have the notion of a current
working directory (which alas must be a real directory and not a
virtual one).'!

!Directory class methodsFor: 'C call-outs'!

primWorking: dirName
    <cCall: 'chdir' returning: #void args: #(#string)>! !


!Directory class methodsFor: 'reading system defaults'!

home
    "Answer the path to the user's home directory"
    ^Smalltalk getenv: 'HOME'
!

image
    "Answer the path to GNU Smalltalk's image file"
    ^ImageFilePath
!

module
    "Answer the path to GNU Smalltalk's dynamically loaded modules"
    ^ModulePath
!

systemKernel
    "Answer the path to the GNU Smalltalk kernel's Smalltalk source files.
     Same as `Directory kernel' since GNU Smalltalk 2.4."
    ^self kernel
!

localKernel
    "Answer the path to the GNU Smalltalk kernel's Smalltalk source files.
     Same as `Directory kernel' since GNU Smalltalk 2.4."
    ^self kernel
!

userBase
    "Answer the base path under which file for user customization of GNU
     Smalltalk are stored."
    ^UserFileBasePath
!

temporary
    "Answer the path in which temporary files can be created.  This is
     read from the environment, and guessed if that fails."
    | d |
    (d := Smalltalk getenv: 'TMPDIR') isNil ifFalse: [ ^d ].
    (d := Smalltalk getenv: 'TEMP') isNil ifFalse: [ ^d ].
    (d := self home) isNil ifFalse: [
	d := d, '/tmp'.
	(Directory exists: d) ifTrue: [ ^d ]
    ].
    ^'/tmp'
!

kernel
    "Answer the path in which a local version of the GNU Smalltalk kernel's
     Smalltalk source files were searched when the image was created"
    ^KernelFilePath
! !


!Directory class methodsFor: 'file name management'!

append: fileName to: directory
    "Answer the name of a file named `fileName' which resides in a directory
     named `directory'."
    directory isEmpty ifTrue: [ ^fileName ].
    self pathSeparator == $\
	ifFalse: [
	    (fileName at: 1) isPathSeparator ifTrue: [ ^fileName ] ]
	ifTrue: [
	    (fileName at: 1) isPathSeparator ifTrue: [
		^(directory size >= 2 and: [ (directory at: 2) = $: ])
		    ifTrue: [ '%1:%2' bindWith: directory first with: fileName ]
		    ifFalse: [ fileName ] ].
            (fileName size >= 2 and: [ (fileName at: 2) = $: ])
		ifTrue: [ ^fileName ] ].

    ^(directory at: directory size) isPathSeparator
	ifTrue: [ directory, fileName ]
	ifFalse: [ '%1%2%3'
	    bindWith: directory
	    with: self pathSeparator
	    with: fileName ]
!

pathSeparator
    "Answer (as a Character) the character used to separate directory names"
    ^CSymbols.PathSeparator
!

pathSeparatorString
    "Answer (in a String) the character used to separate directory names"
    ^String with: self pathSeparator
! !


!Directory class methodsFor: 'file operations'!

working
    <cCall: 'getCurDirName' returning: #stringOut args: #()>!

working: dirName
    "Change the current working directory to dirName."
    self primWorking: dirName.
    self checkError
!

allFilesMatching: aPattern do: aBlock
    (self name: (self working))
	allFilesMatching: aPattern do: aBlock
!

create: dirName
    "Create a directory named dirName."
    ^(VFS.VFSHandler for: (File pathFor: dirName ifNone: [ Directory working ]))
	createDir: (File stripPathFrom: dirName)
! !


!Directory methodsFor: 'accessing'!

fileAt: aName
    "Answer a File object for a file named `aName' residing in the
     directory represented by the receiver."
    ^File on: (vfsHandler at: aName)
!


at: aName
	"Answer a File or Directory object as appropriate for a file named
	 'aName' in the directory represented by the receiver."
	| f |
	f := vfsHandler at: aName.
	^((f exists and: [f isDirectory]) 
		ifTrue: [ Directory ] 
		ifFalse: [ File ]) 
		on: f
!

directoryAt: aName
    "Answer a Directory object for a file named `aName' residing in the
     directory represented by the receiver."
    ^Directory on: (vfsHandler at: aName)
!

includes: aName
    "Answer whether a file named `aName' exists in the directory represented
     by the receiver."
    ^(vfsHandler at: aName) exists
!

fullNameAt: aName
    "Answer a String containing the full path to a file named `aName' which
     resides in the directory represented by the receiver."
    ^Directory append: aName to: self fullName
!

nameAt: aName
    "Answer a String containing the path to a file named `aName' which
     resides in the directory represented by the receiver."
    ^Directory append: aName to: self name
! !


!Directory methodsFor: 'enumerating'!

allFilesMatching: aPattern do: aBlock
    "Evaluate aBlock on the File objects that match aPattern (according to
     String>>#match:) in the directory named by the receiver. Recursively
	 descend into directories."

    self do: [ :name || f | 
	f := self at: name.
	(aPattern match: name) ifTrue: [ aBlock value: f ].
	f isDirectory 
	    ifTrue: [
		((#('.' '..') includes: name) or: [ f isSymbolicLink ])
		    ifFalse: [ f allFilesMatching: aPattern do: aBlock ] ] ]
!

contents
    "Answer an Array with the names of the files in the directory
    represented by the receiver."
    | ws |
    ws := WriteStream on: (Array new: 50).
    self do: [ :each | ws nextPut: each ].
    ^ws contents
!

do: aBlock
    "Evaluate aBlock once for each file in the directory represented by the
    receiver, passing its name. aBlock should not return."
    vfsHandler do: aBlock
!

filesMatching: aPattern do: block
    "Evaluate block on the File objects that match aPattern (according to
     String>>#match:) in the directory named by the receiver."

    self do: [:name | (aPattern match: name)
	    ifTrue: [block value: (self at: name)]]
!

namesMatching: aPattern do: block
    "Evaluate block on the file names that match aPattern (according to
     String>>#match:) in the directory named by the receiver."

    self do: [:name | (aPattern match: name)
	    ifTrue: [block value: (self nameAt: name)]]
! !

