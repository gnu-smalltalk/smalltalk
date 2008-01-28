"======================================================================
|
|   File Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2006,2007,2008
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



Object subclass: File [
    | vfsHandler |
    
    <category: 'Streams-Files'>
    <comment: 'I expose the syntax of file names, including paths.  I know how to
manipulate such a path by splitting it into its components.  In addition,
I expose information about files (both real and virtual) such as their
size and timestamps.'>

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

    File class >> extensionFor: aString [
	"Answer the extension of a file named `aString'.  Note: the extension
	 includes an initial dot."

	<category: 'file name management'>
	| index |
	aString isEmpty ifTrue: [^''].
	index := aString findLast: 
			[:each | 
			each = Directory pathSeparator ifTrue: [^''].
			each = $.].

	"Special case foo, .foo and /bar/.foo, all of which have no extension"
	index <= 1 ifTrue: [^''].
	(aString at: index - 1) = Directory pathSeparator ifTrue: [^''].
	^aString copyFrom: index to: aString size
    ]

    File class >> stripExtensionFrom: aString [
	"Remove the extension from the name of a file called `aString', and
	 answer the result."

	<category: 'file name management'>
	| index |
	aString isEmpty ifTrue: [^''].
	index := aString findLast: 
			[:each | 
			each = Directory pathSeparator ifTrue: [^aString].
			each = $.].

	"Special case foo, .foo and /bar/.foo, all of which have no extension"
	index <= 1 ifTrue: [^aString].
	(aString at: index - 1) = Directory pathSeparator ifTrue: [^aString].
	^aString copyFrom: 1 to: index - 1
    ]

    File class >> stripPathFrom: aString [
	"Remove the path from the name of a file called `aString', and
	 answer the file name plus extension."

	<category: 'file name management'>
	| index |
	aString isEmpty ifTrue: [^''].
	index := aString findLast: [:each | each = Directory pathSeparator].
	^aString copyFrom: index + 1 to: aString size
    ]

    File class >> pathFor: aString ifNone: aBlock [
	"Determine the path of the name of a file called `aString', and
	 answer the result.  With the exception of the root directory, the
	 final slash is stripped.  If there is no path, evaluate aBlock and
	 return the result."

	<category: 'file name management'>
	| index |
	aString isEmpty ifTrue: [^aBlock value].
	index := aString findLast: [:each | each = Directory pathSeparator].
	index = 0 ifTrue: [^aBlock value].
	index = 1 ifTrue: [^Directory pathSeparatorString].
	^aString copyFrom: 1 to: index - 1
    ]

    File class >> pathFor: aString [
	"Determine the path of the name of a file called `aString', and
	 answer the result.  With the exception of the root directory, the
	 final slash is stripped."

	<category: 'file name management'>
	^self pathFor: aString ifNone: ['']
    ]

    File class >> stripFileNameFor: aString [
	"Determine the path of the name of a file called `aString', and
	 answer the result as a directory name including the final slash."

	<category: 'file name management'>
	| index |
	aString isEmpty ifTrue: [^'./'].
	index := aString findLast: [:each | each = Directory pathSeparator].
	index = 0 ifTrue: [^'./'].
	index = 1 ifTrue: [^Directory pathSeparatorString].
	^aString copyFrom: 1 to: index
    ]

    File class >> fullNameFor: aString [
	"Answer the full path to a file called `aString', resolving the `.' and
	 `..' directory entries, and answer the result.  `/..' is the same as '/'."

	<category: 'file name management'>
	| path canonical result isAbsolute isWindows |
	isAbsolute := (aString at: 1) isPathSeparator.
	isWindows := Directory pathSeparator == $\.
	"Windows paths starting X:/ are absolute"
	(isWindows and: 
		[aString size >= 3 
		    and: [(aString at: 2) = $: and: [(aString at: 3) isPathSeparator]]]) 
	    ifTrue: [isAbsolute := true].
	path := OrderedCollection new.
	isAbsolute 
	    ifFalse: 
		[path addAll: (Directory working substrings: Directory pathSeparator)].

	"A Windows path may contain both / and \ separators. Clean it up
	 to allow easy parsing"
	canonical := Directory pathSeparator = $/ 
		    ifTrue: [aString]
		    ifFalse: [aString copyReplacing: $/ withObject: Directory pathSeparator].
	(canonical substrings: Directory pathSeparator) do: 
		[:each | 
		each = '.' 
		    ifFalse: 
			[each = '..' 
			    ifTrue: [path isEmpty ifFalse: [path removeLast]]
			    ifFalse: [path add: each]]].
	path isEmpty ifTrue: [^Directory pathSeparatorString].
	result := path inject: ''
		    into: [:old :each | old , Directory pathSeparatorString , each].

	"Remove initial / from /C:/"
	^(isWindows and: 
		[result size >= 4 and: 
			[(result at: 1) isPathSeparator 
			    and: [(result at: 3) = $: and: [(result at: 4) isPathSeparator]]]]) 
	    ifTrue: [result copyFrom: 2]
	    ifFalse: [result]
    ]

    File class >> pathFrom: srcName to: destName [
	"Answer the relative path to destName when the current
	 directory is srcName's directory."
	<category: 'file name management'>
	^self computePathFrom: (File fullNameFor: srcName)
	    to: (File fullNameFor: destName)
    ]

    File class >> computePathFrom: srcName to: destName [
	<category: 'private'>
	| src dest srcComponent destComponent path |
	src := srcName subStrings: Directory pathSeparator.
	dest := destName subStrings: Directory pathSeparator.
	src := src asOrderedCollection.
	src removeLast.
	dest := dest asOrderedCollection.
	dest isEmpty ifTrue: [dest addLast: ''].
	path := (src notEmpty and: [src first ~= dest first]) 
		    ifTrue: [OrderedCollection with: '']
		    ifFalse: 
			[[src isEmpty or: [dest size = 1 or: [src first ~= dest first]]] 
			    whileFalse: 
				[src removeFirst.
				dest removeFirst].
			src collect: [:each | '..']].
	path addAllLast: dest.
	^path fold: [:a :b | a , '/' , b]
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
	| errors |
	errno < 1 ifTrue: [^false].
	SystemExceptions.FileError signal: (self stringError: errno).
	^true
    ]

    File class >> touch: fileName [
	"Update the timestamp of the file with the given path name."

	<category: 'file operations'>
	(File name: fileName) touch
    ]

    File class >> symlink: srcName as: destName [
	"Create a symlink for the srcName file with the given path name"

	<category: 'file operations'>
	(File name: srcName) symlinkAs: destName
    ]

    File class >> symlink: destName from: srcName [
	"Create a symlink named destName file from the given path (relative to
	 destName)"

	<category: 'file operations'>
	(VFS.VFSHandler for: destName) symlinkFrom: srcName
    ]

    File class >> remove: fileName [
	"Remove the file with the given path name"

	<category: 'file operations'>
	(VFS.VFSHandler for: fileName) remove
    ]

    File class >> rename: oldFileName to: newFileName [
	"Rename the file with the given path name oldFileName to newFileName"

	<category: 'file operations'>
	(VFS.VFSHandler for: oldFileName) renameTo: newFileName
    ]

    File class >> on: aVFSHandler [
	"Answer a new file with the given path. The handler that returns
	 the information is aVFSHandler"

	<category: 'instance creation'>
	^self basicNew init: aVFSHandler
    ]

    File class >> name: aName [
	"Answer a new file with the given path. The path is not validated until
	 some of the fields of the newly created objects are accessed"

	<category: 'instance creation'>
	^self on: (VFS.VFSHandler for: aName)
    ]

    File class >> exists: fileName [
	"Answer whether a file with the given name exists"

	<category: 'testing'>
	^(File name: fileName) exists
    ]

    File class >> isReadable: fileName [
	"Answer whether a file with the given name exists and is readable"

	<category: 'testing'>
	^(File name: fileName) isReadable
    ]

    File class >> isWriteable: fileName [
	"Answer whether a file with the given name exists and is writeable"

	<category: 'testing'>
	^(File name: fileName) isWriteable
    ]

    File class >> isExecutable: fileName [
	"Answer whether a file with the given name exists and can be executed"

	<category: 'testing'>
	^(File name: fileName) isExecutable
    ]

    File class >> isAccessible: fileName [
	"Answer whether a directory with the given name exists and can be accessed"

	<category: 'testing'>
	^(File name: fileName) isAccessible
    ]

    File class >> executable [
	"Answer the full path to the executable being run."

	<category: 'reading system defaults'>
	^ExecutableFileName
    ]

    File class >> image [
	"Answer the full path to the image being used."

	<category: 'reading system defaults'>
	^ImageFileName
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPut: $<;
	    print: self class;
	    space;
	    display: self;
	    nextPut: $>
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	| name string |
	name := self name.
	(name anySatisfy: [:each | '"(){}[]$\<>#'' `' includes: each]) 
	    ifFalse: 
		[aStream nextPutAll: name.
		^self].
	string := Directory pathSeparator = $/ 
		    ifTrue: ['''%1''' % {name copyReplaceAll: '''' with: '''\'''''}]
		    ifFalse: [
			{'"'.
			name.
			'"'} join].
	aStream nextPutAll: string
    ]

    name [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler fullName
    ]

    mode [
	"Answer the permission bits for the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler mode
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler size
    ]

    mode: anInteger [
	"Set the permission bits for the file identified by the receiver to be
	 anInteger."

	<category: 'accessing'>
	vfsHandler mode: anInteger
    ]

    lastAccessTime: aDateTime [
	"Update the last access time of the file corresponding to the receiver,
	 to be aDateTime."

	<category: 'accessing'>
	vfsHandler lastAccessTime: aDateTime lastModifyTime: self lastModifyTime
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Update the timestamps of the file corresponding to the receiver, to be
	 accessDateTime and modifyDateTime."

	<category: 'accessing'>
	vfsHandler lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler lastAccessTime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	^vfsHandler lastChangeTime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	^vfsHandler creationTime
    ]

    lastModifyTime: aDateTime [
	"Update the last modification timestamp of the file corresponding to the
	 receiver, to be aDateTime."

	<category: 'accessing'>
	vfsHandler lastAccessTime: self lastAccessTime lastModifyTime: aDateTime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	^vfsHandler lastModifyTime
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	vfsHandler refresh
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	^vfsHandler exists
    ]

    isSymbolicLink [
	"Answer whether a file with the name contained in the receiver does exist
	 and does not identify a directory."

	<category: 'testing'>
	^vfsHandler exists and: [vfsHandler isSymbolicLink]
    ]

    isFile [
	"Answer whether a file with the name contained in the receiver does exist
	 and does not identify a directory."

	<category: 'testing'>
	^vfsHandler exists and: [vfsHandler isDirectory not]
    ]

    isDirectory [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a directory."

	<category: 'testing'>
	| dir errno |
	^vfsHandler exists and: [vfsHandler isDirectory]
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	^vfsHandler exists and: [vfsHandler isReadable]
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	^self exists and: [vfsHandler isWriteable]
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	^self isFile and: [vfsHandler isExecutable]
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'testing'>
	^self isDirectory and: [vfsHandler isAccessible]
    ]

    extension [
	"Answer the extension of the receiver"

	<category: 'file name management'>
	^File extensionFor: self name
    ]

    stripExtension [
	"Answer the path (if any) and file name of the receiver"

	<category: 'file name management'>
	^File stripExtensionFrom: self name
    ]

    stripPath [
	"Answer the file name and extension (if any) of the receiver"

	<category: 'file name management'>
	^File stripPathFrom: self name
    ]

    directory [
	"Answer the Directory object for the receiver's path"

	<category: 'file name management'>
	^Directory name: (File pathFor: self name)
    ]

    path [
	"Answer the path (if any) of the receiver"

	<category: 'file name management'>
	^File pathFor: self name
    ]

    stripFileName [
	"Answer the path of the receiver, always including a directory
	 name (possibly `.') and the final directory separator"

	<category: 'file name management'>
	^File stripFileNameFor: self name
    ]

    fullName [
	"Answer the full name of the receiver, resolving the `.' and
	 `..' directory entries, and answer the result.  Answer nil if the
	 name is invalid (such as '/usr/../../badname')"

	<category: 'file name management'>
	^File fullNameFor: self name
    ]

    contents [
	"Open a read-only FileStream on the receiver, read its contents,
	 close the stream and answer the contents"

	<category: 'file operations'>
	| stream contents |
	stream := self readStream.
	contents := stream contents.
	stream close.
	^contents
    ]

    touch [
	"Update the timestamp of the file corresponding to the receiver."

	<category: 'file operations'>
	| now |
	self exists 
	    ifTrue: 
		[now := DateTime now.
		self lastAccessTime: now lastModifyTime: now]
	    ifFalse: [(self open: FileStream append) close]
    ]

    open: mode [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^vfsHandler open: mode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , self name]
    ]

    openDescriptor: mode [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^vfsHandler openDescriptor: mode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , self name]
    ]

    open: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods). Upon failure, evaluate aBlock."

	<category: 'file operations'>
	^vfsHandler open: mode ifFail: aBlock
    ]

    openDescriptor: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods). Upon failure, evaluate aBlock."

	<category: 'file operations'>
	^vfsHandler openDescriptor: mode ifFail: aBlock
    ]

    withReadStreamDo: aBlock [
	"Invoke aBlock with a reading stream open on me, closing it
	 when the dynamic extent of aBlock ends."
	<category: 'file operations'>
	| stream |
	stream := self readStream.
	[aBlock value: stream] ensure: [stream close]
    ]

    readStream [
	"Open a read-only FileStream on the receiver"

	<category: 'file operations'>
	^self open: FileStream read
    ]

    withWriteStreamDo: aBlock [
	"Invoke aBlock with a writing stream open on me, closing it
	 when the dynamic extent of aBlock ends."
	<category: 'file operations'>
	| stream |
	stream := self writeStream.
	[aBlock value: stream] ensure: [stream close]
    ]

    writeStream [
	"Open a write-only FileStream on the receiver"

	<category: 'file operations'>
	^self open: FileStream write
    ]

    symlinkAs: destName [
	"Create destName as a symbolic link of the receiver.  The appropriate
	 relative path is computed automatically."

	<category: 'file operations'>
	| dest relPath |
	dest := VFS.VFSHandler for: destName.
	relPath := File computePathFrom: dest realFileName
		    to: vfsHandler realFileName.
	dest symlinkFrom: relPath
    ]

    pathFrom: dirName [
	"Compute the relative path from the directory dirName to the receiver"

	<category: 'file operations'>
	^File computePathFrom: (File fullNameFor: dirName) , '/somefile'
	    to: vfsHandler realFileName
    ]

    symlinkFrom: srcName [
	"Create the receiver as a symbolic link from srcName (relative to the
	 path of the receiver)."

	<category: 'file operations'>
	vfsHandler symlinkFrom: srcName
    ]

    remove [
	"Remove the file identified by the receiver"

	<category: 'file operations'>
	^vfsHandler remove
    ]

    renameTo: newName [
	"Rename the file identified by the receiver to newName"

	<category: 'file operations'>
	vfsHandler renameTo: newName
    ]

    init: aVFSHandler [
	"Private - Initialize the receiver's instance variables"

	<category: 'private'>
	vfsHandler := aVFSHandler
    ]
]

