"======================================================================
|
|   DynamicVariable Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2010 Free Software Foundation, Inc.
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


Object subclass: DynamicVariable [

    <category: 'Language-Utilities'>
    <comment: 'I am a variable that is visible only in the stackframes
outgoing from this one.  Do not use DynamicVariable directly,
instead create a subclass for each variable you want to use.

You can override the #value class method, and call #valueIfAbsent: from
there if you want the default value to be something else than nil.'>

    DynamicVariable class [
        | processVariable |
        processVariable [
            <category: 'private'>
            processVariable isNil ifTrue: [
                processVariable :=
                    ProcessEnvironment uniqueInstance associationAt: self ].
            ^processVariable
        ]

        use: anObject during: aBlock [
            <category: 'evaluating'>
            ^self processVariable use: anObject during: aBlock
        ]

        valueIfAbsent: aBlock [
            <category: 'evaluating'>
            ^self processVariable valueIfAbsent: aBlock
        ]

        value [
            <category: 'evaluating'>
            ^self processVariable value
        ]
    ]
]
