"======================================================================
|
|   Smalltalk GUI wrapper for button groups
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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


Primitive subclass:  #PButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

PButton comment: 
nil!

!PButton class methodsFor: 'instance creation'!

parentView: sv data: anObject label: label handleUserChange: changeSelector
    | view |
    view := self new.
    view data: anObject.
    view parentView: sv.
    view handleUserChange: changeSelector.
    view initBlox: label.
    ^view! !

!PButton methodsFor: 'initialize-delete'!

initBlox: aLabel 
    blox := BButton new: parentView blox label: aLabel.
    blox callback: self message: 'pressed'! !

!PButton methodsFor: 'message selectors'!

pressed
    "Send the modification message to the data object"

    (stateChangeMsg notNil and: [self canChangeState]) 
	ifTrue: [data perform: stateChangeMsg]! !


Form subclass:  #ButtonForm
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

ButtonForm comment: 
nil!

!ButtonForm class methodsFor: 'instance creation'!

new: aString in: view 
    | aView |
    aView := self new.
    aView parentView: view.
    aView blox: (BForm new: view blox).
    ^aView! !


!ButtonForm methodsFor: 'initializing'!

replaceArgWith: arg in: selectorsArray
    | selectors |
    selectors := selectorsArray deepCopy.

    "(label unarySelector)) should not be changed
     (label keywordSelector arg) should be changed"

    selectorsArray with: selectors
        do:
            [:item :changed |
            (item size > 2 and: [(item at: 2) numArgs >= 1])
                ifTrue: [changed at: 3 put: arg].
            ].

    ^selectors!

selectors: selectorsArray receiver: receiver
    | selectors size |
    selectors := selectorsArray reject: [ :each | each isEmpty ].
    size := self blox width / selectors size.
    selectors keysAndValuesDo: [ :x :sel |
	| msg buttonView |
	msg := sel size = 2
	    ifTrue: [ sel at: 2 ]
	    ifFalse: [ Message selector: (sel at: 2) arguments: { sel at: 3 } ].

	buttonView := PButton
	    parentView: self
	    data: receiver
	    label: (sel at: 1)
	    handleUserChange: msg.

	buttonView blox
	    x: (x - 1) * size
	    y: 0
	    width: size
	    height: self blox height
    ]!

selectors: selectors receiver: receiver argument: arg 
    self
	selectors: (self replaceArgWith: arg in: selectors)
	receiver: receiver! !

