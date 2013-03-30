"======================================================================
|
|   Smalltalk syntax conversion tool
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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

SourceEntity subclass: SourceClass [
    | class methodsToEmit classMethodsToEmit isComplete |

    <category: 'STTools-Parser-Core'>
    <comment: 'This class is responsible for emitting a class
    by using a FormattingExporter.'>

    SourceClass class >> forClass: aClass [
	(aClass superclass notNil and: [
	    aClass superclass isDefined not ]) ifTrue: [
	        Warning signal:
		    ('superclass %1 is undefined' % {aClass superclass}) ].
        ^super new initializeWithClass: aClass complete: true
    ]

    SourceClass class >> forExtension: aClass [
	aClass isDefined ifFalse: [
	    Warning signal:
		('extensions for undefined class %1' % {aClass}) ].
        ^super new initializeWithClass: aClass complete: false
    ]

    initializeWithClass: aClass complete: aBoolean [
        class := aClass.
        methodsToEmit := STInST.OrderedSet new.
	classMethodsToEmit := STInST.OrderedSet new.
	isComplete := aBoolean
    ]

    forClass [
        ^class
    ]

    addMethod: aMethod [
        methodsToEmit add: aMethod selector asSymbol.
    ]

    addClassMethod: aMethod [
	classMethodsToEmit add: aMethod selector asSymbol.
    ]

    emitTo: aStream filteredBy: aBlock [
	(aBlock value: class)
	    ifFalse: [
	        Notification signal: ('Skipping %1' % {class}).
		^self ].

        Notification signal: ('Converting %1...' % {class}).
        (STInST.FileOutExporter defaultExporter on: class to: aStream)
            completeFileOut: isComplete;
            fileOutSelectors: methodsToEmit classSelectors: classMethodsToEmit.
    ]
]
