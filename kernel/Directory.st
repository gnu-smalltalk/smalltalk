"======================================================================
|
|   Directory Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2007,2008,2009
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



Object subclass: Directory [
    
    <category: 'Streams-Files'>
    <comment: 'I am the counterpart of File in a tree-structured file system.
I provide the notion of a current working directory and know several well-known
places in the file system.

However, all navigation methods for directories are under FilePath or File
for efficiency reasons.  Refer to the manual of FilePath for information on
how to use the instances returned by my class methods.'>

    Directory class >> primCreateTemporary: dirName [
	<category: 'private-C call-outs'>
	<cCall: 'mkdtemp' returning: #void args: #(#stringOut)>
	
    ]

    Directory class >> primWorking: dirName [
	<category: 'private-C call-outs'>
	<cCall: 'chdir' returning: #int args: #(#string)>
	
    ]

    Directory class >> home [
	"Answer the path to the user's home directory"

	<category: 'reading system defaults'>
	^(Smalltalk getenv: 'HOME') ifNotNil: [ :path | File name: path ]
    ]

    Directory class >> image [
	"Answer the path to GNU Smalltalk's image file"

	<category: 'reading system defaults'>
	^File name: ImageFilePath
    ]

    Directory class >> module [
	"Answer the path to GNU Smalltalk's dynamically loaded modules"

	<category: 'reading system defaults'>
	ModulePath isNil ifTrue:[ ^nil ].
	^File name: ModulePath
    ]

    Directory class >> prefix [
	"Answer the path to GNU Smalltalk's installation prefix"

	<category: 'reading system defaults'>
	Prefix isNil ifTrue:[ ^'/' ].
	^File name: Prefix
    ]

    Directory class >> execPrefix [
	"Answer the path to GNU Smalltalk's executable installation prefix"

	<category: 'reading system defaults'>
	ExecPrefix isNil ifTrue:[ ^'/' ].
	^File name: ExecPrefix
    ]

    Directory class >> libexec [
	"Answer the path to GNU Smalltalk's auxiliary executables"

	<category: 'reading system defaults'>
	LibexecPath isNil ifTrue:[ ^nil ].
	^File name: LibexecPath
    ]

    Directory class >> systemKernel [
	"Answer the path to the installed Smalltalk kernel source files."

	<category: 'reading system defaults'>
	SystemKernelPath isNil ifTrue:[ ^nil ].
	^File name: SystemKernelPath
    ]

    Directory class >> localKernel [
	"Answer the path to the GNU Smalltalk kernel's Smalltalk source files.
	 Same as `Directory kernel' since GNU Smalltalk 3.0."

	<category: 'reading system defaults'>
	^self kernel
    ]

    Directory class >> userBase [
	"Answer the base path under which file for user customization of GNU
	 Smalltalk are stored."

	<category: 'reading system defaults'>
	^File name: UserFileBasePath
    ]

    Directory class >> temporary [
	"Answer the path in which temporary files can be created.  This is
	 read from the environment, and guessed if that fails."

	<category: 'reading system defaults'>
	| d |
	(d := Smalltalk getenv: 'TMPDIR') isNil ifFalse: [^File name: d].
	(d := Smalltalk getenv: 'TEMP') isNil ifFalse: [^File name: d].
	(d := self home) isNil 
	    ifFalse: 
		[d := d / 'tmp'.
		d isDirectory ifTrue: [^d]].
	^File name: '/tmp'
    ]

    Directory class >> kernel [
	"Answer the path in which a local version of the GNU Smalltalk kernel's
	 Smalltalk source files were searched when the image was created."

	<category: 'reading system defaults'>
	^KernelFilePath isNil
	    ifTrue: [ File name: SystemKernelPath ]
	    ifFalse: [ File name: KernelFilePath ]
    ]

    Directory class >> append: fileName to: directory [
	"Answer the name of a file named `fileName' which resides in a directory
	 named `directory'."

	<category: 'file name management'>
	directory isEmpty ifTrue: [^fileName].
	fileName isEmpty ifTrue: [^directory].
	self pathSeparator == $\ 
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
	    ifFalse: [directory , self pathSeparatorString , fileName]
    ]

    Directory class >> pathSeparator [
	"Answer (as a Character) the character used to separate directory names"

	<category: 'file name management'>
	^CSymbols.PathSeparator
    ]

    Directory class >> pathSeparatorString [
	"Answer (in a String) the character used to separate directory names"

	<category: 'file name management'>
	^String with: self pathSeparator
    ]

    Directory class >> working [
	"Answer the current working directory, not following symlinks."
	<category: 'file operations'>
	^File name: Directory workingName
    ]

    Directory class >> workingName [
	"Answer the current working directory, not following symlinks."
	<category: 'private'>
	<cCall: 'getCurDirName' returning: #stringOut args: #()>
	
    ]

    Directory class >> working: dirName [
	"Change the current working directory to dirName."

	<category: 'file operations'>
	(self primWorking: dirName asString) < 0
            ifTrue: [File checkError].
    ]

    Directory class >> createTemporary: prefix [
	"Create an empty directory whose name starts with prefix and answer it."

	<category: 'file operations'>
	| name |
	name := prefix asString , 'XXXXXX'.
	(self primCreateTemporary: name) isNil
            ifTrue: [File checkError].
	^File name: name
    ]

    Directory class >> allFilesMatching: aPattern do: aBlock [
	"Invoke #allFilesMatching:do: on the current working directory."
	<category: 'file operations'>
	self working allFilesMatching: aPattern do: aBlock
    ]

    Directory class >> create: dirName [
	"Create a directory named dirName and answer it."

	<category: 'file operations'>
	^(File name: dirName) createDirectory
    ]

]
