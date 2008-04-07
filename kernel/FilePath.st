"======================================================================
|
|   FilePath Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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



Object subclass: FilePath [
    | path |
    
    <category: 'Streams-Files'>
    <comment: 'I expose the syntax of file names, including paths.  I know how to
manipulate such a path by splitting it into its components.  In addition,
I expose information about files (both real and virtual) such as their
size and timestamps.'>

    FilePath class >> append: fileName to: directory [
	"Answer the name of a file named `fileName' which resides in a directory
	 named `directory'."

	<category: 'file name management'>
	directory isEmpty ifTrue: [^fileName].
	fileName isEmpty ifTrue: [^directory].
	Directory pathSeparator == $\ 
	    ifFalse: [(fileName at: 1) isPathSeparator ifTrue: [^fileName]]
	    ifTrue: 
		[(fileName at: 1) isPathSeparator 
		    ifTrue: 
			[^(directory size >= 2 and: [(directory at: 2) = $:]) 
			    ifTrue: ['%1:%2' % 
					{directory first.
					fileName}]
			    ifFalse: [fileName]].
		(fileName size >= 2 and: [(fileName at: 2) = $:]) ifTrue: [^fileName]].
	^(directory at: directory size) isPathSeparator 
	    ifTrue: [directory , fileName]
	    ifFalse: [directory , Directory pathSeparatorString , fileName]
    ]

    FilePath class >> extensionFor: aString [
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

    FilePath class >> stripExtensionFrom: aString [
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

    FilePath class >> stripPathFrom: aString [
	"Remove the path from the name of a file called `aString', and
	 answer the file name plus extension."

	<category: 'file name management'>
	| index |
	aString isEmpty ifTrue: [^''].
	index := aString findLast: [:each | each = Directory pathSeparator].
	^aString copyFrom: index + 1 to: aString size
    ]

    FilePath class >> pathFor: aString ifNone: aBlock [
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

    FilePath class >> pathFor: aString [
	"Determine the path of the name of a file called `aString', and
	 answer the result.  With the exception of the root directory, the
	 final slash is stripped."

	<category: 'file name management'>
	^self pathFor: aString ifNone: ['']
    ]

    FilePath class >> stripFileNameFor: aString [
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

    FilePath class >> isAbsolute: aString [
        "Answer whether aString is an absolute ptah."

	(aString at: 1) isPathSeparator ifTrue: [ ^true ].
	Directory pathSeparator == $\ ifFalse: [ ^false ].
	"Windows paths starting X:/ are absolute"
	^aString size >= 3 and: [
		 (aString at: 2) = $: and: [(aString at: 3) isPathSeparator]]
    ]

    FilePath class >> fullNameFor: aString [
	"Answer the full path to a file called `aString', resolving the `.' and
	 `..' directory entries, and answer the result.  `/..' is the same as '/'."

	<category: 'file name management'>
	| path canonical result isWindows |
	isWindows := Directory pathSeparator == $\.
	"Windows paths starting X:/ are absolute"
	path := OrderedCollection new.
	(self isAbsolute: aString)
	    ifFalse: 
		[path addAll: (Directory workingName substrings: Directory pathSeparator)].

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

    FilePath class >> pathFrom: srcName to: destName [
	"Answer the relative path to destName when the current
	 directory is srcName's directory."
	<category: 'file name management'>
	^self computePathFrom: (File fullNameFor: srcName asString)
	    to: (File fullNameFor: destName asString)
    ]

    FilePath class >> computePathFrom: srcName to: destName [
	<category: 'private'>
	| src dest srcCanon destCanon path |
	"A Windows path may contain both / and \ separators. Clean it up
	 to allow easy parsing"
	srcCanon := Directory pathSeparator = $/ 
		    ifTrue: [srcName]
		    ifFalse: [srcName copyReplacing: $/ withObject: Directory pathSeparator].
	destCanon := Directory pathSeparator = $/ 
		    ifTrue: [destName]
		    ifFalse: [destName copyReplacing: $/ withObject: Directory pathSeparator].

	src := srcCanon subStrings: Directory pathSeparator.
	dest := destCanon subStrings: Directory pathSeparator.
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
	^path fold: [:a :b | a , Directory pathSeparatorString , b]
    ]

    asFile [
	"Answer the receiver."

	<category: 'converting'>
	^self
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	| name string |
	name := self asString.
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

    mode [
	"Answer the permission bits for the file identified by the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    mode: anInteger [
	"Set the permission bits for the file identified by the receiver to be
	 anInteger."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastAccessTime: aDateTime [
	"Update the last access time of the file corresponding to the receiver,
	 to be aDateTime."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Update the timestamps of the file corresponding to the receiver, to be
	 accessDateTime and modifyDateTime."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastModifyTime: aDateTime [
	"Update the last modification timestamp of the file corresponding to the
	 receiver, to be aDateTime."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	self subclassResponsibility
    ]

    isSymbolicLink [
	"Answer whether a file with the name contained in the receiver does exist
	 and does not identify a directory."

	<category: 'testing'>
	self subclassResponsibility
    ]

    isFile [
	"Answer whether a file with the name contained in the receiver does exist
	 and does not identify a directory."

	<category: 'testing'>
	^self exists and: [ self isDirectory not ]
    ]

    isRelative [
	"Answer whether the receiver identifies a relative path."

	<category: 'testing'>
	^self isAbsolute not
    ]

    isAbsolute [
	"Answer whether the receiver identifies an absolute path."

	<category: 'testing'>
	self subclassResponsibility
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	self subclassResponsibility
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	self subclassResponsibility
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	self subclassResponsibility
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'testing'>
	self subclassResponsibility
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
	^self parent
    ]

    parent [
	"Answer the Directory object for the receiver's path"

	<category: 'file name management'>
	^self class path: (File pathFor: self name ifNone: [ '.' ])
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

    full [
	"Answer the full name of the receiver, resolving the `.' and
	 `..' directory entries, and answer the result.  Answer nil if the
	 name is invalid (such as '/usr/../../badname')"

	<category: 'file name management'>
	self subclassResponsibility
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
	^self open: mode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , self name]
    ]

    openDescriptor: mode [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^self openDescriptor: mode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , self name]
    ]

    open: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods). Upon failure, evaluate aBlock."

	<category: 'file operations'>
    	^self open: FileStream mode: mode ifFail: aBlock
    ]

    openDescriptor: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods). Upon failure, evaluate aBlock."

	<category: 'file operations'>
    	^self open: FileDescriptor mode: mode ifFail: aBlock
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    withReadStreamDo: aBlock [
	"Invoke aBlock with a reading stream open on me, closing it
	 when the dynamic extent of aBlock ends."
	<category: 'file operations'>
	| stream |
	stream := self readStream.
	^[aBlock value: stream] ensure: [stream close]
    ]

    fileIn [
	"File in the receiver"

	<category: 'file operations'>
	self withReadStreamDo: [ :fs | fs fileIn ]
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
	^[aBlock value: stream] ensure: [stream close]
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
	self subclassResponsibility
    ]

    pathFrom: dirName [
	"Compute the relative path from the directory dirName to the receiver"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    symlinkFrom: srcName [
	"Create the receiver as a symbolic link from srcName (relative to the
	 path of the receiver)."

	<category: 'file operations'>
	self subclassResponsibility
    ]

    remove [
	"Remove the file identified by the receiver"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    renameTo: newName [
	"Rename the file identified by the receiver to newName"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    pathTo: destName [
	"Compute the relative path from the receiver to destName."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    / aName [
	"Answer a File or Directory object as appropriate for a file named
	 'aName' in the directory represented by the receiver."

	^self at: aName
    ]

    at: aName [
	"Answer a File or Directory object as appropriate for a file named
	 'aName' in the directory represented by the receiver."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    includes: aName [
        "Answer whether a file named `aName' exists in the directory represented
         by the receiver."

        <category: 'accessing'>
        ^(self at: aName) exists
    ]

    allFilesMatching: aPattern do: aBlock [
	"Evaluate aBlock on the File objects that match aPattern (according to
	 String>>#match:) in the directory named by the receiver. Recursively
	 descend into directories."

	<category: 'enumerating'>
	self namesDo: 
		[:name | 
		| f |
		f := self at: name.
		(aPattern match: name) ifTrue: [aBlock value: f].
		f isDirectory 
		    ifTrue: 
			[((#('.' '..') includes: name) or: [f isSymbolicLink]) 
			    ifFalse: [f allFilesMatching: aPattern do: aBlock]]]
    ]

    files [
	"Answer an Array with File objects for the contents of the directory
	 represented by the receiver."

	<category: 'enumerating'>
	^self reject: [ :each | each isDirectory ]
    ]

    directories [
	"Answer an Array with Directory objects for the subdirectories
	 of the directory represented by the receiver."

	<category: 'enumerating'>
	^self select: [ :each | each isDirectory ]
    ]

    entries [
	"Answer an Array with File or Directory objects for the contents
	 of the directory represented by the receiver."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self do: [:each | ws nextPut: each].
	^ws contents
    ]

    entryNames [
	"Answer an Array with the names of the files in the directory
	 represented by the receiver."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self namesDo: [:each | ws nextPut: each].
	^ws contents
    ]

    do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'enumerating'>
	self namesDo: [ :name |
	    aBlock value: (self at: name) ]
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'enumerating'>
	self subclassResponsibility
    ]

    filesMatching: aPattern [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing a File or Directory object to aBlock. Returns the
	 *names* of the files for which aBlock returns true."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self namesDo: [ :name |
	    (aPattern match: name) ifTrue: [ ws nextPut: (self at: name) ] ].
	^ws contents
    ]

    reject: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing a File or Directory object to aBlock. Returns the
	 *names* of the files for which aBlock returns true."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self do: [ :each |
	    (aBlock value: each) ifFalse: [ ws nextPut: each ] ].
	^ws contents
    ]

    select: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing a File or Directory object to aBlock. Returns the
	 *names* of the files for which aBlock returns true."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self do: [ :each |
	    (aBlock value: each) ifTrue: [ ws nextPut: each ] ].
	^ws contents
    ]

    filesMatching: aPattern do: block [
	"Evaluate block on the File objects that match aPattern (according to
	 String>>#match:) in the directory named by the receiver."

	<category: 'enumerating'>
	self namesDo: [:name |
	    (aPattern match: name) ifTrue: [block value: (self at: name)]]
    ]

    nameAt: aName [
	"Answer a FilePath for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	^File append: aName to: self asString
    ]

    namesMatching: aPattern do: block [
	"Evaluate block on the file names that match aPattern (according to
	 String>>#match:) in the directory named by the receiver."

	<category: 'enumerating'>
	self namesDo: [:name |
	     (aPattern match: name) ifTrue: [block value: (self nameAt: name)]]
    ]
]
