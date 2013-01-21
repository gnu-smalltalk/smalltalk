"======================================================================
|
|   Virtual File System (new classes)
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


Namespace current: VFS [

TmpFileArchiveMember subclass: StoredZipMember [
    | offset |
    
    <category: 'Streams-Files'>
    <comment: 'ArchiveMember is the handler
class for stored ZIP archive members, which are optimized.'>

    offset [
	<category: 'accessing'>
	^offset
    ]

    offset: anInteger [
	<category: 'accessing'>
	offset := anInteger
    ]

    open: class mode: mode ifFail: aBlock [
	<category: 'opening'>
	| fileStream |
	(mode = FileStream read or: [ self extracted ])
	    ifFalse: [^super open: class mode: mode ifFail: aBlock].

	fileStream := self archive 
		    open: class
		    mode: mode
		    ifFail: [^aBlock value].
	fileStream skip: self offset + 26.
	fileStream skip: fileStream nextUshort + fileStream nextUshort.
	fileStream setFile: self.
	^LimitedStream 
	    on: fileStream
	    from: fileStream position
	    to: fileStream position + self size - 1
    ]
]

]

