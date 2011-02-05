"======================================================================
|
|   Swazoo 2.1 extensions for GNU Smalltalk
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Stream extend [
    lineEndTransparent [
	"Do nothing.  GNU Smalltalk streams do not muck with line endings."
	<category: 'useless portability hacks'>
    ]
]



SpFilename extend [

    etag [
	"^a String
	 The etag of a file entity is taken to be the date last modified as a String.
	 We use the SpTimestamp in"

	<category: '*Swazoo-accessing'>
	^self lastModified asRFC1123String
    ]

    lastModified [
	"| info |
	 info := self dates at: #modified.
	 ^SpTimestamp fromDate: info first andTime: info last"

	<category: '*Swazoo-accessing'>
	^self modifiedTimestamp
    ]

]



SpFileStream extend [
    lineEndTransparent [
       "Do nothing.  GNU Smalltalk streams do not muck with line endings."
       <category: 'useless portability hacks'>
    ]

    nextAvailable: anInteger [
        ^self underlyingStream nextAvailable: anInteger
    ]
]


