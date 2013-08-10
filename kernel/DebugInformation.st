"======================================================================
|
|   Object Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2013 Free Software Foundation, Inc.
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


Object subclass: DebugInformation [

    DebugInformation class >> variables: anArray [
        <category: 'instance creation'>

        ^ self new
            variables: anArray;
            yourself
    ]

    | variables |

    variables: anArray [
        <category: 'initialization'>

        variables := anArray.
    ]

    variables [
        <category: 'accessing'>

        ^ variables
    ]

    arguments: anInteger [
        <category: 'accessing'>

        ^ variables copyFrom: 1 to: anInteger
    ]

    temporaries: anInteger [
        <category: 'accessing'>

        ^ variables copyFrom: anInteger + 1 to: variables size
    ]
]
