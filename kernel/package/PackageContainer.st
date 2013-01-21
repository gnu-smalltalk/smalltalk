"======================================================================
|
|   PackageLoader Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2004,2005,2007,2008,2009
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



Namespace current: Kernel [

PackageGroup subclass: PackageContainer [
    | packages file |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    file [
	<category: 'accessing'>
	^file
    ]

    fileName [
	<category: 'accessing'>
	^self file name
    ]

    file: aFile [
	<category: 'accessing'>
	file := aFile
    ]

    packages [
	<category: 'accessing'>
	packages isNil ifTrue: [packages := LookupTable new].
	^packages
    ]

    packages: aDictionary [
	<category: 'accessing'>
	packages := aDictionary
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>
	^self packages at: aString asString ifAbsent: aBlock
    ]

    keys [
	<category: 'accessing'>
	^self packages keys
    ]

    includesKey: aString [
	<category: 'accessing'>
	^self packages includesKey: aString
    ]

    baseDirectoriesFor: aPackage [
	<category: 'refreshing'>
	self subclassResponsibility
    ]

    refresh: loadDate [
	"Private - Process the XML source in the packages file, creating
	 Package objects along the way."

	<category: 'refreshing'>
	self subclassResponsibility
    ]

    parse: file [
	<category: 'refreshing'>
	| open ch cdata tag package allPackages |
	open := false.
	allPackages := OrderedCollection new.
	
	[cdata := cdata isNil 
		    ifTrue: [file upTo: $<]
		    ifFalse: [cdata , (file upTo: $<)].
	file atEnd] 
		whileFalse: 
		    [cdata trimSeparators isEmpty 
			ifFalse: [^self error: 'unexpected character data'].
		    ch := file peek.
		    ch == $! ifTrue: [file skipTo: $>].
		    ch == $/ 
			ifTrue: 
			    [file next.
			    (tag := file upTo: $>) = 'packages' ifTrue: [^self].
			    ^self error: 'unmatched end tag ' , tag].
		    ch isAlphaNumeric 
			ifTrue: 
			    [open 
				ifFalse: 
				    [tag := file upTo: $>.
				    tag = 'package' 
					ifTrue: [package := Package new parse: file tag: 'package']
					ifFalse: 
					    [tag = 'packages' ifFalse: [^self error: 'expected packages tag'].
					    open := true]]
				ifTrue: 
				    [file skip: -1.
				    package := Package parse: file].
			    package notNil 
				ifTrue: 
				    [package name isNil 
					ifTrue: [^self error: 'missing package name in ' , self fileName].
				    
				    [self testPackageValidity: package.
				    self packages at: package name put: package.
				    allPackages add: package] 
					    on: PackageSkip
					    do: [:ex | ex return].
				    open ifFalse: [^allPackages]].
			    package := nil]].
	^allPackages
    ]

    testPackageValidity: package [
	package baseDirectories: (self baseDirectoriesFor: package).
    ]
]

]

