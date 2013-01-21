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

