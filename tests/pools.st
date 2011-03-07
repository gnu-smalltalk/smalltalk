"======================================================================
|
|   Tests for the TwistedPools (3.1+) pool resolution strategy
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

Smalltalk addSubspace: #MyLibrary; addSubspace: #MyProject; addSubspace: #MyImports.
MyProject addSubspace: #MyLibWrapper.

"actually for later, to demonstrate the need for the `direct
superclass only' namespace-walk-stop rule"

MyLibrary at: #PkgVersion put: 'MyLibrary 1.0'.
MyProject at: #PkgVersion put: 'MyProject 0.3141'.

Namespace current: MyLibrary [

    MyLibrary at: #StandardOverrides put:
        (Dictionary from: {#Scape -> 42});
	at: #ValueAdaptor put: 9994;
	yourself.

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

Namespace current: MyProject.MyLibWrapper [
    
    Namespace current import:
	(Dictionary from: {#Blah -> 6667. #Scoobs -> 785}).

    "note this changes my superspace"
    MyProject at: #Exception put: #Exception.
    
    MyLibrary.Foo subclass: Baz [
        scape [^Scape]
        exception [^Exception]
        valueAdaptor [^ValueAdaptor]
	blah [^Blah]
    ]

] "end namespace MyProject.MyLibWrapper"

Namespace current: MyLibrary [

    "you ask, Who would do this? to which I say..."
    MyProject.MyLibWrapper.Baz subclass: BackForMore [
        pkgVersion [^PkgVersion]
	blah [^Blah]
	scoobs [^Scoobs]
    ]

] "end namespace MyLibrary"

Namespace current: MyImports [
    <import: MyLibrary>

    Object subclass: MITest [
	test [^Foo]
    ]

    <import: MyProject.MyLibWrapper>

    MITest extend [
	test2 [^Baz]
    ]
]

"here start the tests..."

"prefer class pool to namespace"
MyLibrary.Foo class extend [ test [ ^Exception ] ]
Eval [ MyLibrary.Foo test ] "42"

"prefer shared pool to super-class pool"
MyLibrary.Bar class extend [ test [ ^Scape ] ]
Eval [ MyLibrary.Bar test ] "42"

"test inherited pools: super-shared pool"
MyLibrary.Blah class extend [ test [ ^Scape ] ]
Eval [ MyLibrary.Blah test ] "42"

"test inherited pools: super-class pool"
MyProject.MyLibWrapper.Baz class extend [ test [ ^Scape ] ]
Eval [ MyProject.MyLibWrapper.Baz test ] "21"

"test namespace walk"
MyProject.MyLibWrapper.Baz class extend [ test [ ^Exception ] ]
Eval [ MyProject.MyLibWrapper.Baz test ] "#Exception"
MyProject.MyLibWrapper.Baz class extend [ test [ ^ValueAdaptor ] ]
Eval [ MyProject.MyLibWrapper.Baz test ] "9994"
MyLibrary.BackForMore class extend [ test [ ^PkgVersion ] ]
Eval [ MyLibrary.BackForMore test ] "'MyLibrary 1.0'"

"Test resolution within class variables"
MyLibrary.Foo class extend [ TryThis := Exception printNl ]
MyLibrary.Bar class extend [ TryThis := Scape printNl ]
MyLibrary.Blah class extend [ TryThis := Scape printNl ]
MyProject.MyLibWrapper.Baz class extend [ TryThis := Scape printNl ]
MyProject.MyLibWrapper.Baz class extend [ TryThis := Exception printNl ]
MyProject.MyLibWrapper.Baz class extend [ TryThis := ValueAdaptor printNl ]
MyLibrary.BackForMore class extend [ TryThis := PkgVersion printNl ]

"Test resolution within compile-time constants"
MyLibrary.Foo class extend [ test [ ^##(Exception printNl) ] ]
MyLibrary.Bar class extend [ test [ ^##(Scape printNl) ] ]
MyLibrary.Blah class extend [ test [ ^##(Scape printNl) ] ]
MyProject.MyLibWrapper.Baz class extend [ test [ ^##(Scape printNl) ] ]
MyProject.MyLibWrapper.Baz class extend [ test [ ^##(Exception printNl) ] ]
MyProject.MyLibWrapper.Baz class extend [ test [ ^##(ValueAdaptor printNl) ] ]
MyLibrary.BackForMore class extend [ test [ ^##(PkgVersion printNl) ] ]

"Both of the above"
MyLibrary.Foo class extend [ TryThis := ##(Exception printNl) ]
MyLibrary.Bar class extend [ TryThis := ##(Scape printNl) ]
MyLibrary.Blah class extend [ TryThis := ##(Scape printNl) ]
MyProject.MyLibWrapper.Baz class extend [ TryThis := ##(Scape printNl) ]
MyProject.MyLibWrapper.Baz class extend [ TryThis := ##(Exception printNl) ]
MyProject.MyLibWrapper.Baz class extend [ TryThis := ##(ValueAdaptor printNl) ]
MyLibrary.BackForMore class extend [ TryThis := ##(PkgVersion printNl) ]

"test namespace-sharedpools"
Eval [ MyProject.MyLibWrapper.Baz new blah ] "6667"
Eval [ MyLibrary.BackForMore new blah ] "Blah"
Eval [ MyLibrary.BackForMore new scoobs ] "785"

"test namespace pragmas"
Eval [ MyImports.MITest new test nameIn: Smalltalk ] "MyLibrary.Foo"
Eval [ MyImports.MITest new test2 nameIn: Smalltalk ] "MyProject.MyLibWrapper.Baz"
