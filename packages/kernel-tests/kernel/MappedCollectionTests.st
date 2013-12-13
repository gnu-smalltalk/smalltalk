"======================================================================
|
|   MappedCollection Tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2013
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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


TestCase subclass: TestMappedCollection [
    | mappedCollection |

    setUp [
        mappedCollection := MappedCollection collection: #('abc' 'def' 'ghi') map: #(3 2 1).
    ]

    testSelect [
        | result |
        result := mappedCollection select: [:key | true].
        self assert: (result at: 1) equals: 'ghi'.
        self assert: (result at: 2) equals: 'def'.
        self assert: (result at: 3) equals: 'abc'.
    ]

    testReject [
        | result |
        result := mappedCollection reject: [:key | false].
        self assert: (result at: 1) equals: 'ghi'.
        self assert: (result at: 2) equals: 'def'.
        self assert: (result at: 3) equals: 'abc'.
    ]
]
