"======================================================================
|
|   A stream wrapper with unlimited push back capabilites
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
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


Stream subclass: #StreamWrapper
	   instanceVariableNames: 'stream '
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Examples-Useful'
!

StreamWrapper comment:
'decorator capability for Streams'
!


!StreamWrapper class methodsFor: 'instance creation'!

on: aStream
    ^super new init: aStream
! !


!StreamWrapper methodsFor: 'accessing' !

atEnd
    ^stream atEnd
!

next
    ^stream next
!

position
    ^stream position
!

position: pos
    stream position: pos.
!

stream
    ^stream
!

species
    ^stream species
!

close
    stream close
! !



!StreamWrapper methodsFor: 'private'!

init: aStream
    stream _ aStream
! !
