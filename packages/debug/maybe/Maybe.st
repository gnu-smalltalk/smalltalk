"======================================================================
|
|   Maybe class declaration
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2013 Free Software Foundation, Inc.
| Written by Gwenael Casaccio.
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

Object subclass: Maybe [

    Maybe class >> value: anObject [

        ^ self new
            value: anObject;
            yourself
    ]

    Maybe class >> value: anObject1 value: anObject2 [

        ^ self new
            value: anObject1 value: anObject2;
            yourself
    ]

    Maybe class >> value: anObject1 value: anObject2 value: anObject3 [

        ^ self new
            value: anObject1 value: anObject2 value: anObject3;
            yourself
    ]

    | values |


    value: anObject [
        <category: 'initialization'>

        values := Array with: anObject.
    ]

    value: anObject1 value: anObject2 [
        <category: 'initialization'>

        values := Array with: anObject1 with: anObject2.
    ]

    value: anObject1 value: anObject2 value: anObject3 [
        <category: 'initialization'>

        values := Array with: anObject1 with: anObject2 with: anObject3.
    ]

    ifSucceed: aBlock [
    ]

    ifError: aBlock [
    ]

    ifError: unusedBlock ifSucceed: aBlock [
    ]
]
