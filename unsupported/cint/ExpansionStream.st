"======================================================================
|
|   C preprocessor macro expansion support
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"
|     Change Log
| ============================================================================
| Author       Date       Change 
"


FileStream fileIn: 'ExpansionStreamStack.st' ifMissing: #ExpansionStreamStack!


PushBackStream subclass: #ExpansionStream
	       instanceVariableNames: ''
	       classVariableNames: ''
	       poolDictionaries: ''
	       category: nil
!


!ExpansionStream class methodsFor: 'instance creation'!

new
    ^super on: ExpansionStreamStack new
! !


!ExpansionStream methodsFor: '???'!


addStream: aStream
    stream pushStream: aStream forMacro: nil
!

recordExpansionOf: aMacroName into: tokenCollection
    stream pushStream: (ReadStream on: tokenCollection) forMacro: aMacroName
!

isAlreadyExpanded: aMacroName
    ^stream containsExpansion: aMacroName
! 

nextBypass
    ^stream nextBypass
!

atRealEnd
    ^stream atRealEnd
! !

"
??? DO we heave to add these?
atEnd?
next
peek
putBack ?

"

