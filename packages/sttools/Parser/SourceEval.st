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

SourceEntity subclass: SourceEval [
    | statements comments namespace |

    <category: 'STTools-Parser-Core'>
    <comment: 'This class is responsible for emitting a set of
    statements that should be inside an Eval declaration.'>

    initialize [
        statements := OrderedCollection new
    ]

    namespace [
	^namespace
    ]

    namespace: aNamespace [
	namespace := aNamespace
    ]

    addStatement: aStatement [
        statements add: aStatement
    ]

    emitTo: aStream filteredBy: aBlock [
	statements isEmpty ifTrue: [ ^self ].
	STInST.FileOutExporter defaultExporter
	    emitEval: [
		| formatter |
		formatter := STInST.RBFormatter new.
		formatter indent: 1 while: [
		    formatter indent.
	            aStream nextPutAll: (formatter formatAll: statements) ]]
	    to: aStream
	    for: namespace.
    ]
]
