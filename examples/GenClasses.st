"======================================================================
|
|   Generate class definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,1999,2000 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #GenClass
       instanceVariableNames: 'parent stream'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

!GenClass class methodsFor: 'execution'!

generate: onStream parent: parentName names: nameList prefix: aSymbol
    ^self new
	init: onStream
	parent: parentName
	names: nameList
	mangle: [ :name | aSymbol, name ]
!

generate: onStream parent: parentName names: nameList suffix: aSymbol
    ^self new
	init: onStream
	parent: parentName
	names: nameList
	mangle: [ :name | name, aSymbol ]
!

generate: onStream parent: parentName names: nameList
    ^self new
	init: onStream
	parent: parentName
	names: nameList
	mangle: [ :name | name ]
! !

!GenClass methodsFor: 'private'!

init: aStream parent: parentName names: nameList mangle: aBlock
    
    parent := parentName asString.
    stream := aStream.
    nameList do: [ :name |
	self generate: (aBlock value: name).
    ]
!

generate: name
    stream
	nextPutAll: parent;
	nextPutAll: ' subclass: #';
	nextPutAll: name;
	nl; nextPutAll: '    instanceVariableNames: '''' '
	nl; nextPutAll: '    classVariableNames: '''' '
	nl; nextPutAll: '    poolDictionaries: '''' ';
	nl; nextPutAll: '    category: ''no category'' !';
	nl; nl
! !
