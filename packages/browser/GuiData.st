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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"



Object subclass: GuiState [
    | state counter action |
    
    <category: 'Graphics-Windows'>
    <comment: nil>

    GuiState class >> state: aSymbol counter: anInteger [
	<category: 'accessing'>
	^self new 
	    initState: aSymbol
	    counter: anInteger
	    action: ValueHolder null
    ]

    GuiState class >> state: aSymbol counter: anInteger action: aBlock [
	<category: 'accessing'>
	^self new 
	    initState: aSymbol
	    counter: anInteger
	    action: aBlock
    ]

    counter [
	<category: 'accessing'>
	^counter
    ]

    updateTo: newCounter [
	<category: 'accessing'>
	counter := newCounter.
	^action value
    ]

    state [
	<category: 'accessing'>
	^state
    ]

    initState: aSymbol counter: anInteger action: aBlock [
	<category: 'private - accessing'>
	state := aSymbol.
	counter := anInteger.
	action := aBlock
    ]
]



BLOX.Gui subclass: GuiData [
    | checkpoints |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    changeState: anObject [
	"Record the state change denoted by anObject"

	<category: 'change management'>
	| updateCount |
	checkpoints isNil ifTrue: [checkpoints := LookupTable new].
	updateCount := checkpoints at: anObject ifAbsent: [0].
	checkpoints at: anObject put: updateCount + 1
    ]

    getCurrentState [
	<category: 'change management'>
	^checkpoints copy
    ]

    getStateChanges: viewState [
	"Compare current state with viewState and return an object which describes
	 differences"

	<category: 'change management'>
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
	^stateChanges
    ]
]

