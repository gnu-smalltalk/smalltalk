"======================================================================
|
|   Smalltalk GUI wrapper for windows with children
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"

View subclass:  #Manager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

Manager comment: 
nil!

!Manager methodsFor: 'childViews'!

addChildView: aChildView 
    "Add childView to list of childViews of a view"

    childViews isNil 
	ifTrue: 
	    ["Initialize childViews collection"

	    childViews := OrderedCollection new].
    childViews add: aChildView.
    "Set parentView of aChildView to self"
    aChildView parentView: self!

addLabel: aString at: aPoint 
    (BLabel new: self blox label: aString) origin: aPoint!

addLabel: aString below: aPrimitive 
    (BLabel new: self blox label: aString) posVert: aPrimitive blox!

addLabel: aString rightOf: aPrimitive 
    (BLabel new: self blox label: aString) posHoriz: aPrimitive blox!

allPrimitivesDo: aBlock
    childViews isNil ifTrue: [ ^self ].
    super allPrimitivesDo: aBlock!

deleteChildView: aChildView 
    childViews notNil 
	ifTrue: 
	    [childViews remove: aChildView.
	    aChildView remove]! !


Manager subclass:  #Form
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

Form comment: 
nil!

!Form class methodsFor: 'instance creation'!

new: aString in: view 
    | aView |
    aView := super new: aString in: view.
    aView blox: (BForm new: view blox).
    ^aView! !


Manager subclass:  #OrderedForm
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

OrderedForm comment: 
nil!

!OrderedForm class methodsFor: 'instance creation'!

new: aString in: view 
    | aView |
    aView := super new: aString in: view.
    aView blox: (BContainer new: view blox).
    ^aView! !


Manager subclass:  #TopLevelShell
	instanceVariableNames: 'menuBar '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

TopLevelShell comment: 
nil!

!TopLevelShell class methodsFor: 'instance creation'!

new: aLabel 
    "Initialize TopLevelShell"

    | view |
    view := self new initialize: aLabel.
    BrowserMain shell isNil ifFalse: [BrowserMain addWindow: view].
    ^view! !

!TopLevelShell methodsFor: 'closing'!

canClose
    self rootView allPrimitivesDo: [:view | view canUpdate ifFalse: [^false]].
    ^true!

close
    | canClose |
    canClose := self canClose.
    canClose 
	ifTrue: 
	    [self blox destroy.
	    self remove].
    ^canClose!

destroyed
    "This method is invoked from the callback which is activated when the
     user closes a window.  Each view is sent an canUpdate message.  If
     there is some information which has been cached and not incorporated
     into the data object (modified text which has not been compiled), this
     method will inform the callback by returning nil.  If the window can
     be closed, the top level widget is returned.  The widget value is
     needed so that the view's supporting widget hierarchy can be disposed
     properly"

    ^self canClose!

remove
    super remove.
    BrowserMain removeWindow: self! !

!TopLevelShell methodsFor: 'displaying'!

display
    self blox map! !

!TopLevelShell methodsFor: 'initialize'!

data: aData 
    "Even though this view is not properly a data view, the data view 
     is associated with a TopLevelShell to support change control. When a 
     user attempts to close the window, the close method which is invoked can 
     communicate this to the data objects's views by sending a message to the data 
     object associated with it."

    data := aData!

initialize: aLabel 
    blox := BWindow new: aLabel.
    self blox callback: self message: #destroyed.
    #('Control-1' 'Control-2' 'Control-3')
	with: #(#openWorksheet #openBrowser #openNamespaceBrowser)
	do: [:key :sel | self blox onKeyEvent: key send: sel to: BrowserMain]!

menu: aMenu 
    self menuBar add: aMenu blox!

menuBar
    menuBar isNil ifTrue: [menuBar := BMenuBar new: self blox].
    ^menuBar! !


