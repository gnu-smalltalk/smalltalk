"======================================================================
|
|   Test string operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999  Free Software Foundation.
| Written by Steve Byrne
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

!String methodsFor: 'testing'!

strTest
    | str |
    str := self copy.
    str at: 1 put: $Q.
    ^str

! !

^'foo'!

^'foo on you'!

^'foo on
multiple line string
you'!

^'test embedded quote marks, can''t I do this?'!

^'FUBAR' at: 3!

^'quem' copy at: 1 put: $Q!

^'quem' strTest!

'should be false ' print.       ('###' match: 'quem') printNl.
'should be false ' print.       ('###' match: 'bo') printNl.
'should be true  ' print.	('* string' match: 'any string') printNl.
'should be true  ' print.	('*.st' match: 'filename.st') printNl.
'should be true  ' print.	('foo.*' match: 'foo.bar') printNl.
'should be true  ' print.	('foo.*' match: 'foo.') printNl.
'should be true  ' print.	('*' match: 'foo.') printNl.
'should be true  ' print.	('*' match: '') printNl.
'should be true  ' print.	('***' match: '') printNl.
'should be true  ' print.	('*.st' match: '.st') printNl.
'should be true  ' print.	('*#*' match: '.st') printNl.
'should be true  ' print.	('*#*' match: '.s') printNl.
'should be true  ' print.	('*#*' match: 's') printNl.
'should be false ' print.	('*.st' match: '.s') printNl.
'should be false ' print.	('*#*' match: '') printNl!
