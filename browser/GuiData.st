"======================================================================
|
|   Smalltalk GUI publish-subscribe framework
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"

Object subclass:  #GuiState
	instanceVariableNames: 'state counter action '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

GuiState comment: 
nil!

!GuiState class methodsFor: 'accessing'!

state: aSymbol counter: anInteger 
    ^self new 
	initState: aSymbol
	counter: anInteger
	action: ValueHolder null!

state: aSymbol counter: anInteger action: aBlock 
    ^self new 
	initState: aSymbol
	counter: anInteger
	action: aBlock! !

!GuiState methodsFor: 'accessing'!

counter
    ^counter!

updateTo: newCounter 
    counter := newCounter.
    ^action value!

state
    ^state! !

!GuiState methodsFor: 'private - accessing'!

initState: aSymbol counter: anInteger action: aBlock 
    state := aSymbol.
    counter := anInteger.
    action := aBlock! !


BLOX.Gui subclass:  #GuiData
	instanceVariableNames: 'checkpoints '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

GuiData comment: 
nil!

!GuiData methodsFor: 'change management'!

changeState: anObject 
    "Record the state change denoted by anObject"

    | updateCount |
    checkpoints isNil ifTrue: [checkpoints := LookupTable new].
    updateCount := checkpoints at: anObject ifAbsent: [0].
    checkpoints at: anObject put: updateCount + 1!

getCurrentState
    ^checkpoints copy!

getStateChanges: viewState 
    "Compare current state with viewState and return an object which describes
    differences"

    | stateChanges |
    viewState isNil | checkpoints isNil ifTrue: [^nil].
    viewState keysAndValuesDo: 
	    [:stateId :state | 
	    | stateValue |
	    stateValue := checkpoints at: stateId ifAbsent: [0].
	    state counter < stateValue 
		ifTrue: 
		    [stateChanges isNil ifTrue: [stateChanges := Set new].
		    stateChanges add: (GuiState state: stateId counter: stateValue)]].
    ^stateChanges! !


