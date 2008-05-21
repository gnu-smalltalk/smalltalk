"======================================================================
|
|   Test CObject operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2002, 2005, 2007, 2008 Free Software Foundation.
| Written by Paolo Bonzini
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

Eval [
    | ca buf |
    ca := (CStringType arrayType: 1) new.
    buf := (CCharType arrayType: 10) new.
    buf at: 0 put: $a.
    buf at: 1 put: $s.
    buf at: 2 put: $d.
    buf at: 3 put: 0 asCharacter.
    ca at: 0 put: buf.
    ^ca at: 0
]

Eval [
    | ca |
    ca := (CStringType arrayType: 1) new.
    ca at: 0 put: (CString value: 'asd').
    ^ca at: 0
]

Eval [ Smalltalk at: #CA put: nil ]

Eval [
    CA := (CStringType arrayType: 2) new.
    CA at: 0 put: (CString value: 'asd').
    CA at: 1 put: (CString value: 'dsa')
]


Eval [ CA at: 0 ]
Eval [ CA at: 1 ]
Eval [ (CA addressAt: 0) class ]
Eval [ (CA addressAt: 0) value ]
Eval [ (CA addressAt: 1) value ]
Eval [ (CA + 1) class ]
Eval [ (CA + 1) at: -1 ]
Eval [ (CA + 1) at: 0 ]
Eval [ (CA + 1) - CA ]

Eval [ Smalltalk at: #CP put: nil ]

Eval [
    CP := CStringType ptrType new.
    CP value: CA.
    CP value at: 0
]

Eval [ CP value at: 1 ]
Eval [ (CP value addressAt: 0) class ]
Eval [ (CP value addressAt: 0) value ]
Eval [ (CP value addressAt: 1) value ]
Eval [ (CP value + 1) class ]
Eval [ (CP value + 1) at: -1 ]
Eval [ (CP value + 1) at: 0 ]
Eval [ (CP value + 1) - CA ]


Eval [ (CPtrCType elementType: #int) new value ]


SmallInteger extend [
    testAsync [
        "Asynchronous vs. synchronous actually matters only when the function
         calls back to Smalltalk.  But otherwise, we have no coverage of how
         the asyncCCall pragma is compiled."
        <asyncCCall: 'marli' args: #(#self)>
    ]
]

Eval [ 3 testAsync ]

Object extend [

    testCallin: aCallback [
        <cCall: 'testCallin' returning: #void args: #(#selfSmalltalk #cObject)>
    ]

    testCString: cString [
        <cCall: 'testCString' returning: #void args: #(#cObject)>
    ]

    testCObjectPtr: cObject [
        <cCall: 'testCObjectPtr' returning: #void args: #(#cObjectPtr)>
    ]
]

Eval [ true testCallin: (CCallbackDescriptor for: [ :x | x printNl. 3 ]
	returning: #int withArgs: #(#string)) ]
Eval [ nil testCString: (CString value: 'this is a test') ]

Eval [
    cObject := CCharType new.
    nil testCObjectPtr: cObject.
    ^cObject asString
]

Eval [
    CStruct subclass: #StructB.
    (CStruct subclass: #StructC) declaration: #((#b (#ptr #StructB))).
    ^StructC new b elementType cObjectType
]
Eval [
    (CStruct subclass: #StructD) declaration: #((#b (#ptr #{StructB}))).
    ^StructD new b elementType cObjectType
]


"test some GCed CObjects."
Eval [
    cObject := (CShortType arrayType: 4) gcNew.
    cObject storage size printNl.
    cObject at: 1 put: 16r1111.
    cObject at: 2 put: 16r2222.
    cObject decr.
    (cObject at: 2) printNl.
    (cObject at: 3) printNl.
    cObject at: 4 put: 16r3333.
    cObject storage printNl.
    cObject at: 5 put: 16rDEAD.
]

"test partly out of bound accesses"
Eval [
    cObject := (CShortType arrayType: 4) gcNew.
    cObject adjPtrBy: 7.
    cObject at: -4
]

Eval [
    cObject := (CShortType arrayType: 4) gcNew.
    cObject adjPtrBy: 7.
    cObject at: 0
]

Eval [
    cObject := (CShortType arrayType: 4) gcNew.
    cIntObject := (cObject + 2) castTo: CIntType.
    cIntObject value: 16r11111111.
    (cObject at: 2) printNl.
    cIntObject at: 1
]

Eval [
    cObject := CCharType gcNew.
    nil testCObjectPtr: cObject.
    ^cObject isAbsolute	"must be true"
]

CStruct subclass: A [ <declaration: #((#a #int) (#b #char))> ]
Eval [
    cObj := A gcNew.
    cObj incr.
    cObj a printNl.
    cObj a value
]

Eval [
    cObj := A gcNew.
    cObj b value: $A.
    cObj storage printNl
]

" ### need a lot more!"

