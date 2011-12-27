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


Namespace current: Kernel [

Stream subclass: LimitedStream [
    | stream offset limit |
    
    <category: 'Streams-Files'>
    <comment: 'I provide a view of a part of a substream.'>

    LimitedStream class >> on: aStream from: start to: end [
	<category: 'instance creation'>
	^(self new)
	    stream: aStream;
	    offset: start;
	    limit: end + 1;
	    yourself
    ]

    atEnd [
	<category: 'stream operations'>
	^stream position >= limit or: [stream atEnd]
    ]

    copyFrom: start to: end [
	<category: 'stream operations'>
	(start between: 0 and: limit - offset) 
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: start].
	(end between: 0 and: limit - offset) 
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: end].
	^stream copyFrom: offset + start to: offset + end
    ]

    isPositionable [
	<category: 'stream operations'>
	^true
    ]

    nextAvailable: n into: aCollection startingAt: pos [
	<category: 'stream operations'>
	^stream
	    nextAvailable: (n min: limit - stream position)
	    into: aCollection
	    startingAt: pos
    ]

    next [
	<category: 'stream operations'>
	self atEnd ifTrue: [^self pastEnd].
	^stream next
    ]

    peek [
	<category: 'stream operations'>
	self atEnd ifTrue: [^nil].
	^stream peek
    ]

    peekFor: aCharacter [
	<category: 'stream operations'>
	self atEnd ifTrue: [^false].
	^stream peek
    ]

    position [
	<category: 'stream operations'>
	^stream position - offset
    ]

    position: anInteger [
	<category: 'stream operations'>
	(anInteger between: 0 and: limit - offset) 
	    ifTrue: [stream position: offset + anInteger]
	    ifFalse: 
		[SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger]
    ]

    setToEnd [
	<category: 'stream operations'>
	stream position: limit
    ]

    size [
	<category: 'stream operations'>
	^limit - offset
    ]

    skip: anInteger [
	<category: 'stream operations'>
	self position: anInteger + self position
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    print: stream;
	    nextPut: $[;
	    print: offset;
	    nextPut: $:;
	    print: limit;
	    nextPut: $]
    ]

    file [
	<category: 'accessing'>
	^stream file
    ]

    name [
	<category: 'accessing'>
	^stream name
    ]

    species [
	<category: 'accessing'>
	^stream species
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    limit: anInteger [
	<category: 'accessing'>
	limit := anInteger
    ]

    offset: anInteger [
	<category: 'accessing'>
	offset := anInteger
    ]

    fileIn [
        "File in the contents of the receiver.
         During a file in operation, global variables (starting with an
         uppercase letter) that are not declared don't yield an `unknown
         variable' error. Instead, they are defined as nil in the `Undeclared'
         dictionary (a global variable residing in Smalltalk).
         As soon as you add the variable to a namespace (for example by creating
         a class) the Association will be removed from Undeclared and reused
         in the namespace, so that the old references will automagically point
         to the new value."

        <category: 'built ins'>
        | pos |
        stream isPipe ifTrue: [ ^super fileIn ].
        ^self
            fileInLine: 1
            file: stream file full
            fileName: stream name
            at: self position
    ]

    flush [
	<category: 'stream protocol'>
	stream flush
    ]

    close [
	<category: 'stream protocol'>
	stream close
    ]
]

]


FilePath extend [
    zip [
        <category: 'virtual filesystems'>
        ^VFS.ZipFile on: self
    ]
]
