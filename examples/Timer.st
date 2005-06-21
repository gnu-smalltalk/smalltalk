"======================================================================
|
|   Handy Timer object for establishing periodic activities
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

Object subclass: #Timer
    instanceVariableNames: 'period doBlock stopBlock atStopBlock process '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Processes'!

!Timer methodsFor: 'accessing'!

atStopBlock
    ^atStopBlock
!

atStopBlock: aBlock
    atStopBlock := aBlock
!

doBlock
    ^doBlock
!

doBlock: aValue
    doBlock := aValue
!

processPriority
    ^Processor userSchedulingPriority
!

stopBlock
    ^stopBlock
!

stopBlock: aValue
    stopBlock := aValue
!

period
    ^period
!

period: aValue
    period := aValue
! !

!Timer methodsFor: 'actions'!

resume
    process isNil ifFalse: [ process resume. ].
!

start
    process isNil ifFalse: [ ^self ].
    process := [ [ self stopBlock value ]
	    whileFalse: [
		(Delay forMilliseconds: self period) wait.
		doBlock value ].
       self atStopBlock isNil ifFalse: [ self atStopBlock value ].
       process := nil
    ] forkAt: self processPriority
!

stop
    process isNil ifFalse: [ process terminate. ].
    process := nil.
!

suspend
    process isNil ifFalse: [ process suspend. ].
! !

!Timer class methodsFor: 'instance-creation'!

every: milliseconds do: aBlock stopWhen: anotherBlock

    ^self new
	period: milliseconds;
	doBlock: aBlock;
	stopBlock: anotherBlock;
	start;
	yourself
!

every: milliseconds do: aBlock stopWhen: anotherBlock afterStopDo: stopBlock

    ^self new
	period: milliseconds;
	doBlock: aBlock;
	stopBlock: anotherBlock;
	atStopBlock: stopBlock;
	start;
	yourself
! !
