"======================================================================
|
|   CFunctionDescriptor Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005,2008
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


SystemDictionary extend [

    system: aString withArguments: args [
        <category: 'c call-outs'>
        ^self system: aString % (args collect: [ :string | string withShellEscapes ])

    ]

    system: aString [
        <category: 'c call-outs'>
        <cCall: 'system' returning: #int args: #(#string)>

    ]

    getenv: aString [
        <category: 'c call-outs'>
        <cCall: 'getenv' returning: #string args: #(#string)>

    ]

    environ [
        <category: 'c call-outs'>
        <cCall: 'environ' returning: #{CString} args: #()>

    ]

    putenv: aString [
        <category: 'c call-outs'>
        <cCall: 'putenv' returning: #int args: #(#string)>

    ]

    getArgc [
        <category: 'c call-outs'>
        <cCall: 'getArgc' returning: #int args: #()>

    ]

    getArgv: index [
        <category: 'c call-outs'>
        <cCall: 'getArgv' returning: #string args: #(#int)>

    ]

]

Integer extend [
    
    alignTo: anInteger [
        "Answer the receiver, truncated to the first higher or equal
         multiple of anInteger (which must be a power of two)"

        <category: 'extension'>
        ^self + anInteger - 1 bitClear: anInteger - 1
    ]
        
]

