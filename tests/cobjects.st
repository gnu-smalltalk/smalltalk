"======================================================================
|
|   Test CObject operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2002, 2005 Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

| ca buf |
ca := (CStringType arrayType: 1) new.
buf := (CCharType arrayType: 10) new.
buf at: 0 put: $a.
buf at: 1 put: $s.
buf at: 2 put: $d.
buf at: 3 put: 0 asCharacter.
ca at: 0 put: buf.
^ca at: 0!

| ca |
ca := (CStringType arrayType: 1) new.
ca at: 0 put: (CString value: 'asd').
^ca at: 0!

Smalltalk at: #CA put: nil!

CA := (CStringType arrayType: 2) new.
CA at: 0 put: (CString value: 'asd').
CA at: 1 put: (CString value: 'dsa')!

^CA at: 0!
^CA at: 1!
^(CA addressAt: 0) class!
^(CA addressAt: 0) value!
^(CA addressAt: 1) value!
^(CA + 1) class!
^(CA + 1) at: -1!
^(CA + 1) at: 0!
^(CA + 1) - CA!

Smalltalk at: #CP put: nil!

CP := CStringType ptrType new.
CP value: CA.

^CP value at: 0!
^CP value at: 1!
^(CP value addressAt: 0) class!
^(CP value addressAt: 0) value!
^(CP value addressAt: 1) value!
^(CP value + 1) class!
^(CP value + 1) at: -1!
^(CP value + 1) at: 0!
^(CP value + 1) - CA!

!Object methodsFor: 'C call-outs'!

testCallin
    <cCall: 'testCallin' returning: #void args: #(#selfSmalltalk)>!

testCString: cString
    <cCall: 'testCString' returning: #void args: #(#cObject)>!

testCObjectPtr: cObject
    <cCall: 'testCObjectPtr' returning: #void args: #(#cObjectPtr)>! !

true testCallin!
nil testCString: (CString value: 'this is a test')!

| cObject |
cObject := CCharType new.
nil testCObjectPtr: cObject.
^cObject asString!

" ### need a lot more!"

