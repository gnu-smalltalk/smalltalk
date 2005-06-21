"======================================================================
|
|   Test multi thread support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


Object subclass: #Test
       instanceVariableNames: ''
       classVariableNames: 'Stop Test3'
       poolDictionaries: ''
       category: nil
! 


!Test class methodsFor: 'testing'!

stop
    ^Stop
!

stop: aBoolean
    Stop := aBoolean
!

test1
    [ [ self stop ] whileFalse:
	  [ 'test1' printNl.
	    Processor yield. ].
      ] fork.
!

test2
    [ [ self stop ] whileFalse:
	  [ 'test2' printNl.
	    Processor yield. ].
      ] fork.
!

test3
    Test3 := 0.
    [ [ self stop ] whileFalse:
	  [ 'test3 ---------------------------' printNl.
	    Test3 := Test3 + 1.
	    (Delay forMilliseconds: 100) wait. ].
      ] fork.
!

testFor: milli
    self stop: false.
    self test1.
    self test2.
    self test3.
    [
	(Delay forMilliseconds: milli) wait.
	self stop: true.
    ]   forkAt: Processor userInterruptPriority.

    [ Test stop ] whileFalse: [
	 'main---------' printNl.
	 Processor yield ].
    ^Test3
! !

^Test testFor: 2000!
