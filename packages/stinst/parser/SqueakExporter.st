"======================================================================
|
|   Squeak format class fileout support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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


OldSyntaxExporter subclass: SqueakSyntaxExporter [
    <comment: 'This class is responsible for filing out 
               a given class on a given stream in Squeak format'>

    
    fileOutDeclaration: aBlock [
        (completeFileOut and: [ outClass environment ~= self defaultNamespace ])
	    ifTrue: [ Warning signal: 'Squeak format does not support namespaces' ].

	self fileOutClassBody: aBlock.
    ]

    fileOutChunk: aString [
        outStream
            nl;
            nextPutAll: (aString copyReplaceAll: '!' with: '!!');
            nextPut: $!
    ]

    fileOutComment [
	outStream
            nextPut: $!;
            print: outClass;
            nextPutAll: ' commentStamp: ''<historical>'' prior: 0!'.

	self fileOutChunk: (outClass comment ifNil: [ '' ]).
	outStream nl; nl.
    ] 

    fileOutClassDeclaration: aBlock [
	outStream
	    nextPutAll: 'SystemOrganization addCategory: #';
	    print: outClass category;
	    nextPut: $!;
	    nl.

	super fileOutClassDeclaration: aBlock
    ]
]
