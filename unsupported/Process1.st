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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"test mtness"

Smalltalk at: #ExitHandlerLoop put: false!

Object subclass: #InputHandler
       instanceVariableNames: 'server rootWindow activeView exposeCount'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

"??? May not need to hold onto server in instance variable"


!InputHandler class methodsFor: 'execution'!

runOn: rootView
    | handler server |
    'here I am' printNl.
    [ "Threads addLast: Processor activeProcess."
      [ ExitHandlerLoop ] whileFalse:
	  [ 'in polling loop' print. 
	    [ ExitHandlerLoop or: [ 0 ~= 0 ] ] 
		whileFalse: [ (Delay forMilliseconds: 50) wait. 
			      'Interrupt!!!' printNl.
			      ].
	    'in loop' printNl.
	    ExitHandlerLoop 
		ifFalse: [ 'server handleEvent' printNl ] ].
      'exiting while loop' printNl.
	  ] fork.
! !



"

| x | 

    InputHandler runOn: nil.

    [ ExitHandlerLoop ]
	whileFalse: [ Processor yield ].

!

"

"
| x | 

    InputHandler runOn: nil.

    [ ExitHandlerLoop ]
	whileFalse: [ Processor yield.
		      '.' print. ].

!

"
