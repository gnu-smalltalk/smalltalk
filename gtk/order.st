"======================================================================
|
|   Smalltalk Gtk+ bindings (ordering header files).
|
 ======================================================================"


"======================================================================
|
| Copyright 2004 Free Software Foundation, Inc.
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

Object subclass: #IncludesScanner 
       instanceVariableNames: 'paths ordered processed'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Gtk-Building bindings'
!

!CharacterArray methodsFor: 'testing'!

gPrefixes
    ^#('g' 'atk' 'pango')!

isGName
    | name |
    name := File stripPathFrom: self.
    ^self gPrefixes anySatisfy: [ :each | name startsWith: each ]
! !

!SystemDictionary methodsFor: 'utility'!

readOutput: aCommand
    ^(FileDescriptor popen: aCommand dir: FileStream read) contents.
!

getenvNoFail: aName
    | r |
    r := Smalltalk getenv: aName.
    r notNil ifTrue: [ ^r ].
    self error: 'env var ', aName printString, ' is not set'.
! !

!IncludesScanner class methodsFor: 'instance creation'!

new
    ^super new initialize
! !

!IncludesScanner methodsFor: 'making'!

initialize
    ordered := OrderedCollection new.
    paths := OrderedCollection with: '.'.
    processed := Set new. "Same as order, but a set for faster lookup"
!

process: args
    args do: [ :arg |
	[ self processArgument: arg ]
	    ifCurtailed: [ ('while processing ', arg) displayNl ]
    ]!

processArgument: arg
    (arg startsWith: '-L') 
	ifTrue: [ ^self processLib: (arg copyFrom: 3) ].

    (arg startsWith: '-I')
	ifTrue: [ ^self processPath: (arg copyFrom: 3) ].

    self processFile: arg
!

processPath: aPath
    (paths includes: aPath) 
	ifFalse: [ paths add: aPath ].
!

processLib: aLib
    | cflags |
    "('""Adding paths from library: ', aLib, '""') displayNl."
    cflags := Smalltalk readOutput: ((Smalltalk getenvNoFail: 'PKG_CONFIG'),
				     ' --cflags ', aLib).
    cflags subStrings do: [ :each | 
	(each startsWith: '-I') 
	    ifTrue: [ | path | self processPath: (each copyFrom: 3) ].
    ].
!

processFile: aFileName
    | incs file |
    (processed includes: aFileName) ifTrue: [ ^self ].
    processed add: aFileName.
    file := self findFile: aFileName.
    incs := self scanForIncludes: file.
    incs do: [ :each | each isGName ifTrue: [ self processFile: each ] ].
    ordered add: file fullName.
!

findFile: aFile
    | f name |
    (aFile at: 1) == $/
	ifTrue: [
	    f := File name: aFile.
	    f isReadable ifTrue: [ ^f ].
        ]
	ifFalse: [
	    paths do: [ :each |
		f := File name: (each, '/', aFile).
		f isReadable ifTrue: [ ^f ]
	    ]
	].
    paths do: [ :each | ('looked in ', each) displayNl ].
    self error: 'Can''t find: ', aFile printString.
!

scanForIncludes: aFile
    | fs r line last dir prefix f |
    "Get the path for quote-delimited #include directives."
    dir := (File pathFor: aFile name) copyWith: $/.
    fs := aFile readStream.
    r := Set new.
    [ fs atEnd ] 
	whileFalse: [
            line := fs nextLine trimSeparators.
	    (line startsWith: '#include') 
		ifTrue: [
		    line := (line copyFrom: 9) trimSeparators.
		    (line size > 2 and: [ (line at: 1) = $< ])
			ifTrue: [ prefix := ''. last := line indexOf: $> ].
		    (line size > 2 and: [ (line at: 1) = $" ])
			ifTrue: [
			    last := line indexOf: $" startingAt: 2.

			    "Try getting the file from the same directory as the
			     one with the #include directory.  If it succeeds, use
			     an absolute path."
			    f := File name: dir, (line copyFrom: 2 to: last - 1).
			    prefix := f isReadable ifTrue: [ dir ] ifFalse: [ '' ].
			].

		    r add: prefix, (line copyFrom: 2 to: last - 1)
		].
	].
    ^r
!

printOrdered
    ordered do: [ :each | each displayNl ].
! !

[
    IncludesScanner new
	process: Smalltalk arguments;
	printOrdered ] ifCurtailed: [ ObjectMemory quit: 1 ]!
