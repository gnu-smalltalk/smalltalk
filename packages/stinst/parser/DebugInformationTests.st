"======================================================================
|
|   DebugInformation tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2013 Free Software Foundation, Inc.
| Written by Gwenael Casaccio.
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


Namespace current: STInST.Tests [

TestCase subclass: TestDebugInformation [

    | behavior |

    setUp [
        <category: 'setup'>

        behavior := Behavior new.
        behavior superclass: Object.
    ]

    testDebugInformation [
        <category: 'testing'>

        | mth |
        mth := behavior compile: 'a_1: i_1 a_2: i_2 [
    | i j k |

    ^ [ :a :b :c | | d e f | ]
]'.

        self assert: (mth arguments = #(#'i_1' #'i_2')).
        self assert: (mth temporaries =  #(#'i' #'j' #'k')).
        self assert: ((mth blockAt: 1) arguments = #(#'a' #'b' #'c')).
        self assert: ((mth blockAt: 1) temporaries =  #(#'d' #'e' #'f')).
    ]

]

]
