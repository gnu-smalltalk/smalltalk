"======================================================================
|
|   URL Tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2014
| Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther.
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

TestCase subclass: TestURL [

    testDecodedFields [ 
        | decodedFields |
        "Test for #863"

        decodedFields := (NetClients.URL fromString: '?key=value&a=b&c') decodedFields.
        self assert: decodedFields size equals: 3.
        self assert: (decodedFields at: 'key') equals: 'value'.
        self assert: (decodedFields at: 'a') equals: 'b'.
        self assert: (decodedFields at: 'c') equals: nil.
    ]
]

