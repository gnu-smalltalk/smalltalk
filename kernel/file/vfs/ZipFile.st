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

ArchiveFile subclass: ZipFile [
    
    <category: 'Streams-Files'>
    <comment: 'ZipFile transparently extracts
files from a ZIP archive.'>

    createDirectory: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'members'>
	self notYetImplemented
    ]

    member: anArchiveMember mode: bits [
	"Set the permission bits for the file in anArchiveMember."

	<category: 'members'>
	self notYetImplemented
    ]

    extractMember: anArchiveMember into: temp [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'members'>
	Smalltalk 
	    system: 'unzip -p %1 %2 > %3'
	    withArguments: {self file name.
			anArchiveMember name.
			temp name}
    ]

    removeMember: anArchiveMember [
	"Remove the member represented by anArchiveMember."

	<category: 'members'>
	Smalltalk 
	    system: 'zip -d %1 %2'
	    withArguments: {self file name.
			anArchiveMember name}
    ]

    updateMember: anArchiveMember [
	"Update the member represented by anArchiveMember by
	 copying the file into which it was extracted back to the
	 archive."

	<category: 'members'>
	self notYetImplemented
    ]

    centralDirectoryRangeIn: f [
	<category: 'members'>
	| r beginCD size comLen buf ofsCD |
	size := f size.
	r := 21.

	"Great idea, that of putting a variable-length item at the end.  Luckily,
	 we can make a sanity check of the data and find the correct spot of the
	 central directory's final record."
	size - 22 to: size - 65535 - 22
	    by: -257
	    do: 
		[:pos | 
		buf := (f copyFrom: pos to: pos + r) asByteArray.
		beginCD := buf indexOfSubCollection: #[80 75 5 6] ifAbsent: [0].
		beginCD = 0 
		    ifFalse: 
			[comLen := (buf at: beginCD + 21) * 256 + (buf at: beginCD + 20).
			pos + beginCD + 21 + comLen = size 
			    ifTrue: 
				[ofsCD := (buf at: beginCD + 19) * 16777216 
					    + ((buf at: beginCD + 18) * 65536)
					    + ((buf at: beginCD + 17) * 256) 
					    + (buf at: beginCD + 16).
				^ofsCD to: pos + beginCD - 2]].
		r := 278].
	self error: 'invalid data in ZIP file'
    ]

    fileData [
	"Extract the directory listing from the archive"

	<category: 'members'>
	^Generator on: 
		[:gen | 
		| f cd cdEnd data path date method dataSize fileSize fnsize
		  extra comment attr ofs |
		f := self readStream.
		cd := self centralDirectoryRangeIn: f.
		f position: cd first.
		cdEnd := cd last.

		date := DateTime now.
		[f position <= cdEnd ] whileTrue: 
			[f skip: 10.
			method := f nextUshort.
			data := method = 0 ifTrue: [Array new: 5] ifFalse: [Array new: 4].
			data at: 3 put: date.
			f skip: 12.
			data at: 2 put: f nextUlong.
			fnsize := f nextUshort.
			extra := f nextUshort.
			comment := f nextUshort.
			f skip: 4.
			attr := f nextUlong.
			ofs := f nextUlong.
			data at: 1 put: (f next: fnsize).
			f skip: extra + comment.
			data at: 4 put: (attr bitAnd: 16) = 16.
			method = 0 
			    ifTrue: 
				[data at: 5
				    put: ((StoredZipMember new)
					    name: (data at: 1);
					    archive: self;
					    offset: ofs;
					    yourself)].
			gen yield: data].
		f close]
    ]
]

]
