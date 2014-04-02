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

    attributes [
        ^ '
Namespace current: (Smalltalk addSubspace: #CompilerAttributes).
Object subclass: CAttributes [
    foo1 [
        <xork>
    ]

    foo2 [
        <bar: 123 foo: 234>
    ]

    foo3 [
       | bla two |
       <bar: 123 foo: 234>
    ]

    foo4 [
       <bar: 123 foo: 234>
       | bla two |
    |
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

    testAttributes [
        <category: 'testing'>

        self deny: (Smalltalk includesGlobalNamed: #CompilerAttributes).

        STEvaluationDriver new
            parseSmalltalkStream: self attributes readStream
            with: GSTFileInParser.

        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo1) attributes size = 1.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo1) attributes first selector = #xork.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo1) attributes first numArgs = 0.

        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo2) attributes size = 1.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo2) attributes first selector = #'bar:foo:'.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo2) attributes first numArgs = 2.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo2) attributes first arguments first = 123.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo2) attributes first arguments second = 234.

        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo3) attributes size = 1.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo3) attributes first selector = #'bar:foo:'.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo3) attributes first numArgs = 2.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo3) attributes first arguments first = 123.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo3) attributes first arguments second = 234.

        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo4) attributes size = 1.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo4) attributes first selector = #'bar:foo:'.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo4) attributes first numArgs = 2.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo4) attributes first arguments first = 123.
        self assert: ((Smalltalk CompilerAttributes CAttributes) >> #foo4) attributes first arguments second = 234.
    ]
]
