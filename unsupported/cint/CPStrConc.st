"======================================================================
|
|   C preprocessor adjacent string concatenator layer
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

"
|     Change Log
| ============================================================================
| Author       Date       Change 
|
"

FileStream fileIn: 'CToken.st' ifMissing: #CToken !

PushBackStream subclass: #StringConcatStream
	       instanceVariableNames: ''
	       classVariableNames: ''
	       poolDictionaries: ''
	       category: nil
!

StringConcatStream comment:
'I process a sequence of tokens, looking for adjacent strings to put together
into one long string token.'
!


!StringConcatStream methodsFor: 'accessing'!

next
    | result nextTok |
    result _ super next.
    (result isKindOf: StringTok)
	ifTrue: 
	    [ [ stream atEnd not and: 
		    [ (nextTok _ super peek) isKindOf: StringTok ] ]
		  whileTrue: [ super next. "gobble the string"
			       result _ StringTok value: (result value, 
							      nextTok value) ].
	      ].
    ^result
! !
