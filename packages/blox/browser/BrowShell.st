"======================================================================
|
|   Smalltalk GUI window base classs
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"



Object subclass: BrowserShellMenuTemplate [
    | label selectors handler |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    BrowserShellMenuTemplate class >> label: label selectors: anArray handler: aOneArgumentBlock [
	<category: 'instance creation'>
	^self new 
	    label: label
	    selectors: anArray
	    handler: aOneArgumentBlock
    ]

    defineIn: aShell [
	<category: 'custom menus'>
	aShell menu: ((Menu new: aShell label: label) 
		    selectors: selectors
		    receiver: (handler value: aShell)
		    argument: aShell)
    ]

    label: aString selectors: anArray handler: aOneArgumentBlock [
	<category: 'private'>
	label := aString.
	selectors := anArray.
	handler := aOneArgumentBlock
    ]
]



TopLevelShell subclass: BrowserShell [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Menus := nil.

    BrowserShell class >> openWorksheet: label [
	<category: 'browsing'>
	| aBText |
	aBText := (self openWorksheet: label withText: (String with: Character nl)) 
		    value.
	^TextCollector message: aBText -> #insertAtEnd:
    ]

    BrowserShell class >> openWorksheet: label withText: startText [
	"Open a worksheet window."

	<category: 'browsing'>
	| worksheet textView |
	worksheet := self new: label.
	worksheet addChildView: ((textView := PWorksheetText new: worksheet)
		    menuInit: ((PopupMenu new: textView label: 'Edit') 
				selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors))
				receiver: textView
				argument: nil);
		    textMsg: #text;
		    canBeDirty: false;
		    yourself).
	textView blox contents: startText.
	textView setEvaluationKeyBindings.
	worksheet blox x: 0.
	worksheet blox y: 75.
	worksheet blox height: 175.
	worksheet blox width: 300.
	worksheet blox map.
	^worksheet -> textView blox
    ]

    BrowserShell class >> addMenu: label selectors: anArray handler: aOneArgumentBlock [
	<category: 'custom menus'>
	Menus addLast: (BrowserShellMenuTemplate 
		    label: label
		    selectors: anArray
		    handler: aOneArgumentBlock)
    ]

    BrowserShell class >> initialize [
	<category: 'custom menus'>
	Menus := OrderedCollection new.
	self 
	    addMenu: 'Smalltalk'
	    selectors: #(#('Worksheet' #openWorksheet) #('Class Hierarchy Browser' #openBrowser) #('Namespace Browser' #openNamespaceBrowser) #() #('Save image' #saveImage) #('Save image as...' #saveImageAs) #('Garbage collect' #garbageCollect) #() #('File in...' #fileIn) #() #('Exit without saving image' #directQuit) #('Exit...' #quit))
	    handler: [:shell | BrowserMain]
    ]

    initialize: aLabel [
	<category: 'initialize'>
	super initialize: aLabel.
	Menus do: [:each | each defineIn: self]
    ]
]



Eval [
    BrowserShell initialize
]

