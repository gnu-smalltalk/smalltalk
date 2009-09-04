"======================================================================
|
|   Smalltalk GUI wrapper for radio button groups
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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



Primitive subclass: PRadioButton [
    | state isPressedMsg |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PRadioButton class >> on: data parentView: sv isPressed: isPressedSelector label: label handleUserChange: changeSelector value: onValue [
	<category: 'instance creation'>
	| view |
	view := self new.
	view parentView: sv.
	view data: data.
	view
	    isPressed: isPressedSelector;
	    state: onValue.
	view handleUserChange: changeSelector.
	view initBlox: label.
	^view
    ]

    isPressed [
	"Return current switch state."

	<category: 'access'>
	^(data perform: isPressedMsg) = state
    ]

    state [
	<category: 'access'>
	^state
    ]

    state: value [
	<category: 'access'>
	state := value
    ]

    initBlox: aLabel [
	<category: 'initialize-delete'>
	blox := BRadioButton new: parentView label: aLabel.
	blox value: self isPressed.
	blox callback: self message: 'toggle:'
    ]

    isPressed: isPressedSelector [
	<category: 'initialize-delete'>
	isPressedMsg := isPressedSelector
    ]

    toggle: btnState [
	"Send the modification message to the data object"

	<category: 'message selectors'>
	self isPressed ifTrue: [^self].
	(stateChangeMsg notNil and: [self canChangeState]) 
	    ifTrue: [data perform: stateChangeMsg with: state]
    ]
]



Form subclass: RadioForm [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    RadioForm class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := self new.
	aView parentView: view.
	aView blox: (BRadioGroup new: view blox).
	^aView
    ]
]

