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



Namespace current: Kernel [

VFS.FileWrapper subclass: RecursiveFileWrapper [
    <category: 'Streams-Files'>

     do: aBlock [
	"Same as the wrapped #do:, but reuses the file object for efficiency."

	<category: 'enumerating'>
	aBlock value: self file.
        self file namesDo: 
                [:name |
                | f |
		(#('.' '..') includes: name) ifFalse: [
		    f := self at: name. 
		    aBlock value: f file.
		    (f isDirectory and: [f isSymbolicLink not])
                        ifTrue: [f do: aBlock]]]
     ]

     namesDo: aBlock prefixLength: anInteger [
	"Same as the wrapped #namesDo:, but navigates the entire directory
	 tree recursively.  Since the objects created by #at: also contain the
	 path to the receiver, anInteger is used to trim it."

	<category: 'private'>
        self file namesDo: 
                [:name |
                | f |
		(#('.' '..') includes: name) ifFalse: [
		    f := self at: name. 
                    aBlock value: (f asString copyFrom: anInteger).
		    (f isDirectory and: [f isSymbolicLink not])
                        ifTrue: [f
			    namesDo: aBlock
			    prefixLength: anInteger ]]]
     ]

     namesDo: aBlock [
	"Same as the wrapped #namesDo:, but navigates the entire directory
	 tree recursively."

	<category: 'enumerating'>
        | n base |
	aBlock value: '.'.
        base := self asString.
        n := base last = Directory pathSeparator
            ifTrue: [ base size + 1 ]
            ifFalse: [ base size + 2 ].
        self namesDo: aBlock prefixLength: n
     ]

     remove [
	"Removes the entire directory tree recursively."

	<category: 'file operations'>
	self isDirectory ifTrue: [
            self file namesDo: 
                [:name |
                | f |
                f := self at: name. 
                f isDirectory 
                    ifTrue:
                        [((#('.' '..') includes: name) or: [f isSymbolicLink])
                            ifFalse: [f all remove]]
		    ifFalse: [f remove]]].
	super remove
     ]

    isFileSystemPath [
	"Answer whether the receiver corresponds to a real filesystem path."

	<category: 'testing'>
	^self file isFileSystemPath
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Update the timestamps of all files in the tree to be
	 accessDateTime and modifyDateTime."

        <category: 'accessing'>
	self isDirectory ifFalse: [
	    ^super lastAccessTime: accessDateTime lastModifyTime: modifyDateTime ].
        self do: [ :each |
	    each lastAccessTime: accessDateTime lastModifyTime: modifyDateTime ]
    ]

    owner: ownerString group: groupString [
	"Set the owner and group for all files and directories in the tree."

        <category: 'accessing'>
	self isDirectory ifFalse: [
	    ^super owner: ownerString group: groupString ].
	"These special calls cache the uid and gid to avoid repeated lookups."
	[
	    File setOwnerFor: nil owner: ownerString group: groupString.
            self do: [ :each | each owner: ownerString group: groupString ]
	] ensure: [ File setOwnerFor: nil owner: nil group: nil ]
    ]

    mode: anInteger [
	"Set the mode to be anInteger for all files in the tree.  Directory
	 modes are left unchanged."

        <category: 'accessing'>
	self isDirectory ifFalse: [ ^super mode: anInteger ].

	self do: [ :each | each isDirectory ifFalse: [ each mode: anInteger ] ]
    ]

    fileMode: fMode directoryMode: dMode [
	"Set the mode to be fMode for all files in the tree, and dMode for
	 all directories in the tree."

        <category: 'accessing'>
	self isDirectory ifFalse: [ ^super mode: fMode ].

	super mode: dMode.
	self isDirectory ifTrue: [
	    self do: [ :each |
		each mode: (each isDirectory
				ifTrue: [ dMode ]
				ifFalse: [ fMode ]) ] ]
    ]
]

]
