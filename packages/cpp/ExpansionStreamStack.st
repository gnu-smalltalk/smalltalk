"======================================================================
|
|   C preprocessor macro expansion support
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


StreamStack subclass: #ExpansionStreamStack
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!ExpansionStreamStack methodsFor: 'accessing'!

pushStream: aStream
    super pushStream: (aStream -> nil)
!

pushStream: aStream forMacro: macroName
    super pushStream: (aStream -> macroName)
! 

topStream
    ^super topStream key
!

isAlreadyExpanded: macroName
  "  '>>>>>>>> checking containing of: ' print. macroName printNl."
    ^(stack detect: [ :element | element value = macroName ]
	   ifNone: [ "'did not find it!!!' printNl. "nil ]) notNil
! !


