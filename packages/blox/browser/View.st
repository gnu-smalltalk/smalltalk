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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"



BLOX.Gui subclass: View [
    | data parentView childViews |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    View class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := self new.
	aView parentView: view.
	^aView
    ]

    data [
	"Return view's data object"

	<category: 'accessing'>
	^data
    ]

    allPrimitivesDo: aBlock [
	"Note that this test is a necessary but not a sufficient condition of a
	 Primitive view -- a partially created window can have a Manager which has
	 no children"

	<category: 'change management'>
	childViews notNil 
	    ifTrue: [childViews do: [:view | view allPrimitivesDo: aBlock]]
	    ifFalse: [aBlock value: self]
    ]

    canChangeState [
	<category: 'change management'>
	| aCollection |
	aCollection := OrderedCollection new.
	self rootView 
	    allPrimitivesDo: [:view | view == self ifFalse: [view canUpdate ifFalse: [^false]]].
	^true
    ]

    canUpdate [
	"Default is to return true"

	<category: 'change management'>
	^true
    ]

    collectPrimitives: aCollection [
	"Note that this test is a necessary but not a sufficient condition of a
	 Primitive view -- a partially created window can have a Manager which has
	 no children"

	<category: 'change management'>
	childViews notNil 
	    ifTrue: [childViews do: [:view | view collectPrimitives: aCollection]]
	    ifFalse: [aCollection add: self]
    ]

    childViews [
	"Return the view's collection of childViews"

	<category: 'childViews and parentViews'>
	^childViews
    ]

    parentView [
	"Return view's parentView.  If view is a rootView, nil is returned"

	<category: 'childViews and parentViews'>
	^parentView
    ]

    parentView: aView [
	"Set parentView to aView"

	<category: 'childViews and parentViews'>
	parentView := aView
    ]

    rootView [
	"Return rootView in view's hierarchy"

	<category: 'childViews and parentViews'>
	^parentView isNil ifTrue: [self] ifFalse: [parentView rootView]
    ]

    beep [
	"Beep once -- usually called when some user error is detected"

	<category: 'display'>
	Blox beep
    ]

    remove [
	<category: 'initialize-delete'>
	data := nil.
	childViews isNil ifFalse: [childViews do: [:view | view remove]].
	parentView := childViews := nil
    ]
]



View subclass: Primitive [
    | menu dirty stateChangeMsg messageDispatch |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    Primitive class >> updateViews [
	"Update all the primitive views"

	<category: 'displaying'>
	BrowserMain windowsDo: [:i | i allPrimitivesDo: [:view | view update]]
    ]

    Primitive class >> new [
	<category: 'initialize'>
	^(super new)
	    dirty: false;
	    yourself
    ]

    data: aData [
	<category: 'accessing'>
	data := aData
    ]

    dirty: aBoolean [
	<category: 'accessing'>
	dirty := aBoolean
    ]

    isDirty [
	<category: 'accessing'>
	^dirty
    ]

    menu [
	<category: 'accessing'>
	^menu
    ]

    close [
	<category: 'blue button menu items'>
	^self rootView close
    ]

    display [
	"Overridden in subclasses.  This method is used to support change/update
	 mechanism.  In the normal case, this method redraws entire view"

	<category: 'displaying'>
	^self subclassResponsibility
    ]

    getViewState [
	<category: 'displaying'>
	^messageDispatch
    ]

    update: stateChanges [
	"Update object based on stateChanges"

	<category: 'displaying'>
	stateChanges do: 
		[:sc | 
		| viewState |
		viewState := messageDispatch at: sc state.
		viewState updateTo: sc counter]
    ]

    update [
	"Send a getStateChanges: currentViewState message to data object to compute state
	 changes. Send a update: stateChanges message to self to update object"

	<category: 'displaying'>
	| stateChanges |
	data isNil ifTrue: [^self].
	stateChanges := data getStateChanges: self getViewState.
	stateChanges notNil ifTrue: [self update: stateChanges]
    ]

    handleUserChange: changeSelector [
	"This is used to update the data object in response to a user
	 modification of the view"

	<category: 'initialize-delete'>
	stateChangeMsg := changeSelector
    ]

    menuInit: theMenu [
	"The popup menu, theMenu, is stored in menu"

	<category: 'initialize-delete'>
	menu := theMenu
    ]

    stateChange: theStateChange updateWith: block [
	<category: 'initialize-delete'>
	messageDispatch isNil ifTrue: [messageDispatch := LookupTable new].
	messageDispatch at: theStateChange
	    put: (GuiState 
		    state: theStateChange
		    counter: 0
		    action: block)
    ]
]

