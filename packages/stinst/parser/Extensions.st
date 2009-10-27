"======================================================================
|
|   Class extensions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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


Behavior extend [
    parseNodeAt: selector [
	"Available only when the Parser package is loaded--Answer an
	 RBMethodNode that compiles to my method named by selector."
        ^(self compiledMethodAt: selector) methodParseNode
    ]

    formattedSourceStringAt: aSelector ifAbsent: aBlock [
	"Answer the method source code as a formatted string. Requires
	 package Parser."

	<category: 'source code'>
	| method |
	method := self lookupSelector: aSelector.
	method isNil ifTrue: [^aBlock value copy].
	^method methodFormattedSourceString
    ]
]


CompiledMethod extend [
    methodFormattedSourceString [
        "Answer the method source code as a string, formatted using
	 the RBFormatter.  Requires package Parser."

        <category: 'compiling'>
	^STInST.RBFormatter new
		      initialIndent: 1;
                      format: self methodParseNode.
    ]

    methodParseNode [
        "Answer the parse tree for the receiver, or nil if there is an
         error.  Requires package Parser."

        <category: 'compiling'>
	^self parserClass
            parseMethod: self methodSourceString
            category: self methodCategory
	    onError: [ :message :position | ^nil ]
    ]

    parserClass [
	"Answer a parser class, similar to Behavior>>parserClass, that
	 can parse my source code.  Requires package Parser."
        <category: 'compiling'>
	^self isOldSyntax
	    ifTrue: [ STInST.RBParser ]
	    ifFalse: [ STInST.RBBracketedMethodParser ]
    ]
]


Class extend [
    fileOutHeaderOn: aFileStream [
        | now |
        aFileStream 
            nextPutAll: '"Filed out from ';
            nextPutAll: Smalltalk version;
            nextPutAll: ' on '.
            
        now := Date dateAndTimeNow.
        
        aFileStream
            print: now asDate;
            space;
            print: now asTime;
            nextPutAll: '"';
            nl; nl
    ]
    
    fileOutDeclarationOn: aFileStream [
	"File out class definition to aFileStream.  Requires package Parser."
	<category: 'filing'>
	self fileOutHeaderOn: aFileStream.
        (STInST.FileOutExporter defaultExporter on: self to: aFileStream)
            fileOutDeclaration: [ ]
    ]

    fileOutOn: aFileStream [
	"File out complete class description:  class definition, class and
	 instance methods.  Requires package Parser."
	<category: 'filing'>
	self fileOutHeaderOn: aFileStream.
        STInST.FileOutExporter defaultExporter
	    fileOut: self to: aFileStream
    ]
]

ClassDescription extend [
    fileOutSelector: aSymbol toStream: aFileStream [
        "File out all the methods belonging to the method category,
	 category, to aFileStream.  Requires package Parser."
	
	self fileOutHeaderOn: aFileStream.
        STInST.FileOutExporter defaultExporter
	    fileOutSelector: aSymbol of: self to: aFileStream
    ]

    fileOutCategory: category toStream: aFileStream [
        "File out all the methods belonging to the method category,
	 category, to aFileStream.  Requires package Parser."
	
	self fileOutHeaderOn: aFileStream.
        STInST.FileOutExporter defaultExporter
	    fileOutCategory: category of: self to: aFileStream
    ]
]
