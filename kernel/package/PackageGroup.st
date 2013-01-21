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

Object subclass: PackageGroup [
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    printOn: aStream [
	"Print the XML source code for the information that the PackageLoader
	 holds on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: '<packages>';
	    nl.
	self do: 
		[:each | 
		aStream space: 2.
		each printOn: aStream indent: 2.
		aStream nl]
	    separatedBy: [aStream nl].
	aStream nextPutAll: '</packages>'
    ]

    at: aString [
	<category: 'accessing'>
	^self at: aString
	    ifAbsent: [SystemExceptions.PackageNotAvailable signal: aString]
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    do: aBlock [
	<category: 'accessing'>
	self keys do: [:each | aBlock value: (self at: each)]
    ]

    do: aBlock separatedBy: sepBlock [
	<category: 'accessing'>
	self keys do: [:each | aBlock value: (self at: each)] separatedBy: sepBlock
    ]

    keys [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    includesKey: aString [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    extractDependenciesFor: packagesList ifMissing: aBlock [
	"Answer an OrderedCollection containing all the packages which you
	 have to load to enable the packages in packagesList, in an appropriate
	 order. For example
	 
	 PackageLoader extractDependenciesFor: #('BloxTestSuite' 'Blox' 'Browser')
	 
	 on a newly built image will evaluate to an OrderedCollection containing
	 'Kernel', 'Blox', 'BloxTestSuite' and 'Browser'. Note that
	 Blox has been moved before BloxTestSuite.
	 Pass an error message to aBlock if one or more packages need
	 prerequisites which are not available."

	<category: 'accessing'>
	| toBeLoaded featuresFound dependencies allPrereq allFeatures |
	featuresFound := Set withAll: Smalltalk.Features.
	featuresFound := featuresFound collect: [:each | each asString].
	toBeLoaded := packagesList asOrderedCollection.
	toBeLoaded := toBeLoaded collect: [:each | each asString].
	toBeLoaded removeAll: featuresFound ifAbsent: [:doesNotMatter | ].
	dependencies := packagesList collect: [:each | each asString].
	
	[allPrereq := Set new.
	allFeatures := Set new.
	dependencies do: 
		[:name | 
		| package |
		(featuresFound includes: name) 
		    ifFalse: 
			[package := self at: name ifAbsent: [^aBlock value: name].
			allPrereq addAll: package prerequisites.
			allFeatures addAll: package features]].

	"I don't think there will never be lots of packages in newDep (say
	 more than 5), so I think it is acceptable to remove duplicates
	 this naive way.  Note that we remove duplicates from toBeLoaded
	 so that prerequisites are always loaded *before*."
	toBeLoaded removeAll: allPrereq ifAbsent: [:doesNotMatter | ].
	toBeLoaded removeAll: allFeatures ifAbsent: [:doesNotMatter | ].
	allPrereq removeAll: allFeatures ifAbsent: [:doesNotMatter | ].
	featuresFound addAll: allFeatures.
	toBeLoaded addAllFirst: allPrereq.

	"Proceed recursively with the prerequisites for allPrereq"
	dependencies := allPrereq.
	dependencies notEmpty] 
		whileTrue.
	^toBeLoaded
    ]

    refresh [
	<category: 'accessing'>
	self refresh: ##(Date 
		    newDay: 1
		    month: #jan
		    year: 1900)
    ]

    refresh: aLoadDate [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]

]

