"======================================================================
|
|   Adds collection-like operations to GNU Smalltalk streams
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



Namespace current: Kernel [

Stream subclass: LineStream [
    | charStream |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    LineStream class >> on: aStream [
	"Answer a LineStream working on aStream"

	<category: 'instance creation'>
	^self new initStream: aStream
    ]

    file [
	<category: 'basic'>
	^charStream file
    ]

    name [
	<category: 'basic'>
	^charStream name
    ]

    next [
	<category: 'basic'>
	^charStream nextLine
    ]

    atEnd [
	<category: 'basic'>
	^charStream atEnd
    ]

    pastEnd [
	<category: 'basic'>
	^charStream pastEnd
    ]

    initStream: aStream [
	<category: 'private'>
	charStream := aStream
    ]
]

]
