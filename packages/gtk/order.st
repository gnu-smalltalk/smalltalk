"======================================================================
|
|   Smalltalk Gtk+ bindings (ordering header files).
|
 ======================================================================"

"======================================================================
|
| Copyright 2004, 2006 Free Software Foundation, Inc.
| Written by Mike Anderson and Paolo Bonzini.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: IncludesScanner [
    | paths ordered processed prefixes |
    
    <category: 'Gtk-Building bindings'>
    <comment: nil>

    IncludesScanner class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'making'>
	ordered := OrderedCollection new.
	paths := OrderedCollection with: '.'.
	processed := Set new.	"Same as order, but a set for faster lookup"
	prefixes := OrderedCollection new
    ]

    process: args [
	<category: 'making'>
	Getopt 
	    parse: args
	    with: '--include|-I: -L: --prefix|-P:'
	    do: 
		[:opt :arg | 
		[self processArgument: opt with: arg] 
		    ifCurtailed: [('while processing -' , opt asString , arg) displayNl]]
    ]

    processArgument: opt with: arg [
	<category: 'making'>
	opt = $P ifTrue: [^self processPrefix: arg].
	opt = $L ifTrue: [^self processLib: arg].
	opt = $I ifTrue: [^self processPath: arg].
	self processFile: arg
    ]

    processPrefix: aString [
	<category: 'making'>
	prefixes add: aString
    ]

    processPath: aPath [
	<category: 'making'>
	(paths includes: aPath) ifFalse: [paths add: aPath]
    ]

    processLib: aLib [
	<category: 'making'>
	"('"

	"Adding paths from library: ', aLib, '"

	"') displayNl."

	| cflags |
	cflags := Smalltalk 
		    readOutput: (Smalltalk getenvNoFail: 'PKG_CONFIG') , ' --cflags ' , aLib.
	cflags subStrings do: 
		[:each | 
		(each startsWith: '-I') 
		    ifTrue: 
			[| path |
			self processPath: (each copyFrom: 3)]]
    ]

    hasCorrectPrefix: aString [
	<category: 'making'>
	prefixes isEmpty ifTrue: [^true].
	^prefixes anySatisfy: [:each | aString startsWith: each]
    ]

    processFile: aFileName [
	<category: 'making'>
	| incs file |
	(processed includes: aFileName) ifTrue: [^self].
	processed add: aFileName.
	file := self findFile: aFileName.
	incs := self scanForIncludes: file.
	incs do: [:each | self processFile: each].
	ordered add: file fullName
    ]

    findFile: aFile [
	<category: 'making'>
	| f name |
	(aFile at: 1) == $/ 
	    ifTrue: 
		[f := File name: aFile.
		f isReadable ifTrue: [^f]]
	    ifFalse: 
		[paths do: 
			[:each | 
			f := each / aFile.
			f isReadable ifTrue: [^f]]].
	paths do: [:each | ('looked in ' , each) displayNl].
	self error: 'Can''t find: ' , aFile printString
    ]

    scanForIncludes: aFile [
	<category: 'making'>
	"Get the path for quote-delimited #include directives."

	| fs r line last dir prefix f fname lastCh |
	dir := (File pathFor: aFile name) copyWith: $/.
	fs := aFile readStream.
	r := Set new.
	[fs atEnd] whileFalse: 
		[line := fs nextLine trimSeparators.
		(line startsWith: '#include') 
		    ifTrue: 
			[line := (line copyFrom: 9) trimSeparators.
			prefix := ''.
			line first = $< ifTrue: [lastCh := $>].
			line first = $" ifTrue: [lastCh := $"].
			last := line indexOf: lastCh startingAt: 2.
			fname := line copyFrom: 2 to: last - 1.
			lastCh = $" 
			    ifTrue: 
				["Try getting the file from the same directory as the
				 one with the #include directory.  If it succeeds, use
				 an absolute path."

				f := dir / fname.
				f isReadable ifTrue: [prefix := dir]].
			(self hasCorrectPrefix: fname) ifTrue: [r add: prefix , fname]]].
	^r
    ]

    printOrdered [
	<category: 'making'>
	ordered do: [:each | each displayNl]
    ]
]



SystemDictionary extend [

    readOutput: aCommand [
	<category: 'utility'>
	^(FileDescriptor popen: aCommand dir: FileStream read) contents
    ]

    getenvNoFail: aName [
	<category: 'utility'>
	| r |
	r := Smalltalk getenv: aName.
	r notNil ifTrue: [^r].
	self error: 'env var ' , aName printString , ' is not set'
    ]

]



Eval [
    
    [(IncludesScanner new)
	process: Smalltalk arguments;
	printOrdered] 
	    ifCurtailed: [ObjectMemory quit: 1]
]

