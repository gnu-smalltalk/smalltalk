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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================
"


Primitive subclass:  #PRadioButton
	instanceVariableNames: 'state isPressedMsg '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

PRadioButton comment: 
nil!

!PRadioButton class methodsFor: 'instance creation'!

on: data parentView: sv isPressed: isPressedSelector label: label handleUserChange: changeSelector value: onValue 
    | view |
    view := self new.
    view parentView: sv.
    view data: data.
    view
	isPressed: isPressedSelector;
	state: onValue.
    view handleUserChange: changeSelector.
    view initBlox: label.
    ^view! !

!PRadioButton methodsFor: 'access'!

isPressed
    "Return current switch state."

    ^(data perform: isPressedMsg) = state!

state
    ^state!

state: value 
    state := value! !

!PRadioButton methodsFor: 'initialize-delete'!

initBlox: aLabel 
    blox := BRadioButton new: parentView label: aLabel.
    blox value: self isPressed.
    blox callback: self message: 'toggle:'!

isPressed: isPressedSelector 
    isPressedMsg := isPressedSelector! !

!PRadioButton methodsFor: 'message selectors'!

toggle: btnState 
    "Send the modification message to the data object"

    self isPressed ifTrue: [^self].
    (stateChangeMsg notNil and: [self canChangeState]) 
	ifTrue: [data perform: stateChangeMsg with: state]! !


Form subclass:  #RadioForm
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

RadioForm comment: 
nil!

!RadioForm class methodsFor: 'instance creation'!

new: aString in: view 
    | aView |
    aView := self new.
    aView parentView: view.
    aView blox: (BRadioGroup new: view blox).
    ^aView! !


