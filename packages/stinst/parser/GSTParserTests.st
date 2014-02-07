"======================================================================
|
|   GSTParser tests
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

TestCase subclass: TestGSTParser [
    <comment: 'I test that rewriting a method for the OldSyntaxExport and
    SqueakExporter will pick up the new code.'>

    testRegression[
        <category: 'testing'>


        self deny: (Smalltalk includesGlobalNamed: #Xork1).
        self deny: (Smalltalk includesGlobalNamed: #Xork2).

        STEvaluationDriver new
            parseSmalltalkStream: 'Object subclass: Xork1 []. Object subclass: Xork2 [].' readStream
            with: GSTFileInParser.

        self assert: (Smalltalk includesGlobalNamed: #Xork1).
        self assert: (Smalltalk includesGlobalNamed: #Xork2).

        "manual clean-up"
        Smalltalk removeKey: #Xork1.
        Smalltalk removeKey: #Xork2.
    ]
]

]
