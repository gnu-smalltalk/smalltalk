"======================================================================
|
|   Smalltalk GUI wrapper for list boxes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
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



Primitive subclass: PList [
    | selection selectionMsg listMsg dataMsg label |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PList class >> new: aString in: view [
	<category: 'instance creation'>
	| result |
	result := super new: aString in: view.
	result label: aString.
	^result
    ]

    display [
	"Update list widget based on list"

	<category: 'displaying'>
	| contents elements |
	elements := data perform: self dataMsg.
	selection := 0.
	contents := listMsg isNil 
		    ifTrue: [elements collect: [:each | each displayString]]
		    ifFalse: [data perform: listMsg].
	blox contents: contents elements: elements.

	"Select item returned by initialSelection message"
	selectionMsg notNil ifTrue: [self select: (data perform: selectionMsg)]
    ]

    dataMsg [
	<category: 'private - accessing'>
	^dataMsg isNil ifTrue: [listMsg] ifFalse: [dataMsg]
    ]

    label: aString [
	<category: 'initializing'>
	label := aString
    ]

    changedSelection: stateChangeKey [
	"Install message handler for stateChangeKey to select the item based on the
	 initial selection"

	<category: 'initializing'>
	self stateChange: stateChangeKey
	    updateWith: [self select: (data perform: selectionMsg)]
    ]

    dataMsg: dataSelector [
	"Return array of list items"

	<category: 'initializing'>
	dataMsg := dataSelector
    ]

    handleUserChange: changeSelector [
	<category: 'initializing'>
	super handleUserChange: changeSelector.
	blox callback: self message: #selection:at:
    ]

    selectionMsg: selectionSelector [
	"Save data object selector which will retrieve initial list selection in the
	 variable, selectionMsg"

	<category: 'initializing'>
	selectionMsg := selectionSelector
    ]

    initialize [
	<category: 'initializing'>
	selection := 0.
	blox := BList new: parentView blox.
	self blox label: label
    ]

    listMsg: listSelector [
	"Return array of list labels"

	<category: 'initializing'>
	listMsg := listSelector
    ]

    stateChange: stateChangeKey [
	"Install message handler to redraw list in response to an update: message"

	<category: 'initializing'>
	self stateChange: stateChangeKey updateWith: [self display]
    ]

    selection: aPList at: itemPosition [
	"Change list selection based on new selection"

	<category: 'message selectors'>
	| value |
	selection = itemPosition ifTrue: [^itemPosition].

	"If this is a new selection, ask the data object whether the view can
	 update itself.  There may be text which has been modified in the text
	 view associated with the current list selection"
	self canChangeState 
	    ifFalse: 
		[blox highlight: selection.
		^selection].
	selection := itemPosition.
	stateChangeMsg isNil 
	    ifFalse: 
		[value := (data perform: self dataMsg) at: itemPosition ifAbsent: [nil].
		data perform: stateChangeMsg with: selection -> value].
	^itemPosition
    ]

    select: item [
	"Select item named, aSymbol, in list"

	<category: 'modifying'>
	| newSelection |
	item isNil ifTrue: [^self].
	newSelection := item isInteger 
		    ifTrue: [item]
		    ifFalse: [(data perform: self dataMsg) indexOf: item].
	newSelection = 0 ifTrue: [^self].
	newSelection = selection ifTrue: [^self].
	blox highlight: newSelection.
	self selection: self at: newSelection
    ]

    unselect [
	<category: 'modifying'>
	selection := 0.
	blox unhighlight
    ]

    copyAll [
	<category: 'clipboard'>
	| ws |
	ws := WriteStream on: String new.
	blox elements do: [:each | ws nextPutAll: each printString]
	    separatedBy: [ws nextPut: Character nl].
	Blox clipboard: ws contents
    ]

    copySelection [
	<category: 'editing'>
	Blox clipboard: (blox at: blox index) printString
    ]
]

