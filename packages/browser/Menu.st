"======================================================================
|
|   Smalltalk GUI wrapper for menus
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



BLOX.Gui subclass: Menu [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    Menu class >> new: view label: title [
	<category: 'initializing'>
	| aMenu |
	aMenu := Menu new.
	aMenu blox: (BMenu new: view menuBar label: title).
	^aMenu
    ]

    replaceArgWith: arg in: selectorsArray [
	<category: 'initializing'>
	| selectors |
	selectors := selectorsArray deepCopy.

	"(label unarySelector (... submenu ...)) should not be changed
	 (label keywordSelector arg) should be changed
	 (label keywordSelector arg (... submenu ...)) should be changed"
	selectorsArray with: selectors
	    do: 
		[:item :changed | 
		(item size > 2 and: [(item at: 2) numArgs >= 1]) 
		    ifTrue: [changed at: 3 put: arg].
		(item size > 1 and: [item last isArray]) 
		    ifTrue: 
			[changed at: changed size put: (self replaceArgWith: arg in: item last)]].
	^selectors
    ]

    selectors: selectors receiver: receiver [
	<category: 'initializing'>
	blox callback: receiver using: selectors
    ]

    selectors: selectors receiver: receiver argument: arg [
	<category: 'initializing'>
	blox callback: receiver using: (self replaceArgWith: arg in: selectors)
    ]
]



Menu subclass: PopupMenu [
    | windowMenu |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PopupMenu class >> new: view [
	<category: 'initializing'>
	^self new: view label: nil
    ]

    PopupMenu class >> new: view label: title [
	<category: 'initializing'>
	| aMenu blox theTitle |
	aMenu := self new.
	theTitle := (title notNil and: [title isEmpty]) 
		    ifTrue: [nil]
		    ifFalse: [title].
	blox := theTitle isNil 
		    ifTrue: [BPopupMenu new: view blox label: '']
		    ifFalse: [BPopupMenu new: view blox label: theTitle].
	aMenu blox: blox.

	"We were given a menu name, add to the menu bar as well"
	theTitle isNil 
	    ifFalse: 
		[aMenu windowMenu: (Menu new: view rootView label: theTitle).
		view rootView menu: aMenu windowMenu].
	^aMenu
    ]

    windowMenu [
	<category: 'initializing'>
	^windowMenu
    ]

    windowMenu: aMenu [
	<category: 'initializing'>
	windowMenu := aMenu
    ]

    selectors: selectorsArray receiver: receiver [
	<category: 'initializing'>
	super selectors: selectorsArray receiver: receiver.
	windowMenu isNil 
	    ifFalse: [windowMenu selectors: selectorsArray receiver: receiver]
    ]

    selectors: selectorsArray receiver: receiver argument: arg [
	<category: 'initializing'>
	super 
	    selectors: selectorsArray
	    receiver: receiver
	    argument: arg.
	windowMenu isNil 
	    ifFalse: 
		[windowMenu 
		    selectors: selectorsArray
		    receiver: receiver
		    argument: arg]
    ]
]

