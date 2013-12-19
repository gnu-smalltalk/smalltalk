"======================================================================
|
|   Smalltalk in Smalltalk compiler tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2013 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther.
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


TestCase subclass: TestCompiler [
    <comment: 'I do basic compiler tests.'>

    doubleName [
        ^ '
Namespace current: (Smalltalk addSubspace: #CompilerDoubleName).
Object subclass: CompilerDoubleName [
    | one two three |
    <category: ''bla''>
]'
        
    ]

    testPoolResolution [
        <category: 'testing'>

        self deny: (Smalltalk includesGlobalNamed: #CompilerDoubleName).

        STEvaluationDriver new
            parseSmalltalkStream: self doubleName readStream
            with: GSTFileInParser.

        self assert: (Smalltalk includesGlobalNamed: #CompilerDoubleName).
        self assert: (CompilerDoubleName includesGlobalNamed: #CompilerDoubleName).
        self assert: ((Smalltalk at: #CompilerDoubleName) at: #CompilerDoubleName) instVarNames size = 3.
    ]
]
