"======================================================================
|
|   A source of random integers
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2002
| Free Software Foundation, Inc.
| Written by Andy Valencia (vandys@zendo.com).
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Integer subclass: #RandomInteger
	instanceVariableNames: ''
	classVariableNames: 'Source'
	poolDictionaries: ''
	category: 'Examples-Useful'.
!

RandomInteger comment:
'My instances are random integers'
!

!RandomInteger class methodsFor: 'instance creation'!

new
	^self error: 'Must use between:and:'
!

between: low and: high
	| i range |

	(Source = nil) ifTrue: [ Source := Random new ].
	range := high - low + 1.
	i := (Source next * range) truncated.
	^i + low
! !

