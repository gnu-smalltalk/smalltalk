"======================================================================
|
|   PoolResolution tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2008 Free Software Foundation, Inc.
| Written by Stephen Compall.
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

Tests addSubspace: #MyLibrary; addSubspace: #MyProject.
MyProject addSubspace: #MyLibWrapper.

"actually for later, to demonstrate the need for the `direct
superclass only' namespace-walk-stop rule"

MyLibrary at: #PkgVersion put: 'MyLibrary 1.0'.
MyProject at: #PkgVersion put: 'MyProject 0.3141'.

Namespace current: STInST.Tests.MyLibrary [

Eval [
    MyLibrary at: #StandardOverrides put:
        (Dictionary from: {#Scape -> 42});
	at: #ValueAdaptor put: 9994
]

Object subclass: Foo [
    Exception := 42.
    Scape := 21.

    exception [^Exception]
    scape [^Scape]
]

Foo subclass: Bar [
    <import: StandardOverrides>
    scape [^Scape]
    valueAdaptor [^ValueAdaptor]
]

Bar subclass: Blah [
    scape [^Scape]
]

] "end namespace MyLibrary"

Namespace current: STInST.Tests.MyProject.MyLibWrapper [

Eval [
    "note this changes my superspace"
    MyProject at: #Exception put: #Exception.
    Namespace current import:
	(Dictionary from: {#Blah -> 6667. #Scoobs -> 785}).
]

MyLibrary.Foo subclass: Baz [
    scape [^Scape]
    exception [^Exception]
    valueAdaptor [^ValueAdaptor]
    blah [^Blah]
]

] "end namespace MyProject.MyLibWrapper"

Namespace current: STInST.Tests.MyLibrary [

"you ask, Who would do this? to which I say..."
MyProject.MyLibWrapper.Baz subclass: BackForMore [
    pkgVersion [^PkgVersion]
    blah [^Blah]
    scoobs [^Scoobs]
]

] "end namespace MyLibrary"


Namespace current: STInST.Tests [

TestCase subclass: TestDefaultPoolResolution [
    | foo bar baz blah backformore |

    assertVariable: symbol of: pools is: value description: str [
	| binding |
	binding := pools lookupBindingOf: symbol.
	self assert: binding notNil.
	self assert: value = binding value description: str.
    ]

    setUp [
	foo := DefaultPoolResolution of: MyLibrary.Foo.
	bar := DefaultPoolResolution of: MyLibrary.Bar.
	blah := DefaultPoolResolution of: MyLibrary.Blah.
	baz := DefaultPoolResolution of: MyProject.MyLibWrapper.Baz.
	backformore := DefaultPoolResolution of: MyLibrary.BackForMore.
    ]

    testClassPoolFirst [
	self assertVariable: #Exception of: foo is: 42
	     description: 'prefer class pool to namespace'
    ]

    testSharedPoolBeforeSuperClassPool [
	self assertVariable: #Scape of: bar is: 42
	     description: 'prefer here-shared pool to super-class pool'
    ]
    
    testInheritedPools [
	self assertVariable: #Scape of: blah is: 42
	     description: 'super-shared pool picked up'.
	self assertVariable: #Scape of: baz is: 21
	     description: 'super-class pool picked up'.
    ]

    testShortNamespaceWalk [
	self assertVariable: #Exception of: baz is: #Exception
	     description: 'namespace walked briefly before moving to superclass'.
	self assertVariable: #ValueAdaptor of: baz is: 9994
	     description: 'namespace walk stops at super-common space'.
	self assertVariable: #PkgVersion of: backformore is: 'MyLibrary 1.0'
	     description: 'namespace walk stops only at direct-super-common space'.
    ]

    testNamespacePools [
	self assertVariable: #Blah of: baz is: 6667
	     description: 'this-class ns pool var found'.
	self assertVariable: #Blah of: backformore is: MyLibrary.Blah
	     description: 'here-namespace searched first'.
	self assertVariable: #Scoobs of: backformore is: 785
	     description: 'superclass ns pools inherited'.
    ]
]

TestCase subclass: TestClassicPoolResolution [
    | foo bar baz blah backformore |

    assertVariable: symbol of: pools is: value description: str [
	| binding |
	binding := pools lookupBindingOf: symbol.
	self assert: binding notNil.
	self assert: value = binding value description: str.
    ]

    setUp [
	foo := ClassicPoolResolution of: MyLibrary.Foo.
	bar := ClassicPoolResolution of: MyLibrary.Bar.
	blah := ClassicPoolResolution of: MyLibrary.Blah.
	baz := ClassicPoolResolution of: MyProject.MyLibWrapper.Baz.
	backformore := ClassicPoolResolution of: MyLibrary.BackForMore.
    ]

    testNamespaceFirst [
	self assertVariable: #Exception of: foo is: Exception
	     description: 'prefer namespace to class pool'
    ]

    testClassPoolFirst [
	self assertVariable: #Scape of: bar is: 21
	     description: 'prefer class pool to shared pool'
    ]

    testInheritedPools [
	self assertVariable: #Scape of: blah is: 21
	     description: 'super-shared pool picked up'.
	self assertVariable: #Scape of: baz is: 21
	     description: 'super-class pool picked up'.
    ]

    testLongNamespaceWalk [
	self assertVariable: #Exception of: baz is: #Exception
	     description: 'namespace walked before moving to superclass'.
	self assertVariable: #ValueAdaptor of: baz is: ValueAdaptor
	     description: 'and again'.
	self assertVariable: #ValueAdaptor of: bar is: 9994
	     description: 'top class''s namespace goes first'.
	self assertVariable: #PkgVersion of: backformore is: 'MyLibrary 1.0'
	     description: 'not surprising, really'.
    ]
    
    testNamespacePools [
	self assertVariable: #Blah of: baz is: MyLibrary.Blah
	     description: 'ns pool vars not searched'.
	self assertVariable: #Blah of: backformore is: MyLibrary.Blah
	     description: 'mostly vacuous'.
	self assert: (backformore lookupBindingOf: #Scoobs) isNil
	    description: 'ns pools really not searched'.
    ]
]

]
