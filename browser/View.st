"======================================================================
|
|   Smalltalk GUI base class for widget wrappers with publish/subscribe
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

BLOX.Gui subclass:  #View
	instanceVariableNames: 'data parentView childViews '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

View comment: 
nil!

!View class methodsFor: 'instance creation'!

new: aString in: view 
    | aView |
    aView := self new.
    aView parentView: view.
    ^aView! !

!View methodsFor: 'accessing'!

data
    "Return view's data object"

    ^data! !

!View methodsFor: 'change management'!

allPrimitivesDo: aBlock 
    "Note that this test is a necessary but not a sufficient condition of a
     Primitive view -- a partially created window can have a Manager which has
     no children"

    childViews notNil 
	ifTrue: [childViews do: [:view | view allPrimitivesDo: aBlock]]
	ifFalse: [aBlock value: self]!

canChangeState
    | aCollection |
    aCollection := OrderedCollection new.
    self rootView 
	allPrimitivesDo: [:view | view == self ifFalse: [view canUpdate ifFalse: [^false]]].
    ^true!

canUpdate
    "Default is to return true"

    ^true!

collectPrimitives: aCollection 
    "Note that this test is a necessary but not a sufficient condition of a
     Primitive view -- a partially created window can have a Manager which has
     no children"

    childViews notNil 
	ifTrue: [childViews do: [:view | view collectPrimitives: aCollection]]
	ifFalse: [aCollection add: self]! !

!View methodsFor: 'childViews and parentViews'!

childViews
    "Return the view's collection of childViews"

    ^childViews!

parentView
    "Return view's parentView.  If view is a rootView, nil is returned "

    ^parentView!

parentView: aView 
    "Set parentView to aView"

    parentView := aView!

rootView
    "Return rootView in view's hierarchy"

    ^parentView isNil ifTrue: [self] ifFalse: [parentView rootView]! !

!View methodsFor: 'display'!

beep
    "Beep once -- usually called when some user error is detected"

    Blox beep! !

!View methodsFor: 'initialize-delete'!

remove
    data := nil.
    childViews isNil ifFalse: [childViews do: [:view | view remove]].
    parentView := childViews := nil! !


View subclass:  #Primitive
	instanceVariableNames: 'menu dirty stateChangeMsg messageDispatch '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

Primitive comment: 
nil!

!Primitive class methodsFor: 'displaying'!

updateViews
    "Update all the primitive views"

    BrowserMain windowsDo: [:i | i allPrimitivesDo: [:view | view update]]! !

!Primitive class methodsFor: 'initialize'!

new
    ^(super new)
	dirty: false;
	yourself! !

!Primitive methodsFor: 'accessing'!

data: aData 
    data := aData!

dirty: aBoolean 
    dirty := aBoolean!

isDirty
    ^dirty!

menu
    ^menu! !

!Primitive methodsFor: 'blue button menu items'!

close
    ^self rootView close! !

!Primitive methodsFor: 'displaying'!

display
    "Overridden in subclasses.  This method is used to support change/update 
     mechanism.  In the normal case, this method redraws entire view"

    ^self subclassResponsibility!

getViewState
    ^messageDispatch!

update: stateChanges 
    "Update object based on stateChanges"

    stateChanges do: 
	    [:sc | 
	    | viewState |
	    viewState := messageDispatch at: sc state.
	    viewState updateTo: sc counter]!

update
    "Send a getStateChanges: currentViewState message to data object to compute state
     changes. Send a update: stateChanges message to self to update object"

    | stateChanges |
    data isNil ifTrue: [^self].
    stateChanges := data getStateChanges: self getViewState.
    stateChanges notNil ifTrue: [self update: stateChanges]! !

!Primitive methodsFor: 'initialize-delete'!

handleUserChange: changeSelector 
    "This is used to update the data object in response to a user
     modification of the view"

    stateChangeMsg := changeSelector!

menuInit: theMenu 
    "The popup menu, theMenu, is stored in menu"

    menu := theMenu!

stateChange: theStateChange updateWith: block 
    messageDispatch isNil ifTrue: [messageDispatch := LookupTable new].
    messageDispatch at: theStateChange
	put: (GuiState 
		state: theStateChange
		counter: 0
		action: block)! !


