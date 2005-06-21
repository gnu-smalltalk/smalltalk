"======================================================================
|
|   Smalltalk GUI wrapper for modal dialogs
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


BLOX.Gui subclass:  #ModalDialog
	instanceVariableNames: 'dialogShell messageDispatch '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

ModalDialog comment: 
nil!

!ModalDialog methodsFor: 'displaying'!

display: parent 
    blox center.
    dialogShell map.
    blox loop! !

!ModalDialog methodsFor: 'initialization'!

addButton: label message: block 
    messageDispatch at: messageDispatch size + 1 put: block.
    blox 
	addButton: label
	receiver: self
	index: messageDispatch size!

alertMessage: queryString in: parent 
    self message: queryString in: parent.
    self addButton: 'Ok' message: [].
    self display: parent!

message: queryString in: parent 
    "Initialize dialog and button actions"

    messageDispatch := LookupTable new.
    dialogShell := BTransientWindow new: 'Modal dialog'
		in: parent rootView blox.
    dialogShell width: 200 height: 140.
    blox := BDialog 
		new: dialogShell
		label: queryString
		prompt: nil! !

!ModalDialog methodsFor: 'private'!

dispatch: index 
    (messageDispatch at: index) value! !



BLOX.Gui subclass:  #Prompter
	instanceVariableNames: 'defaultResponse '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

Prompter comment: 
nil!

!Prompter class methodsFor: 'instance creation'!

message: aString default: aResponse in: view 
    ^self new 
	message: aString
	default: aResponse
	in: view!

message: aString in: view 
    ^self new 
	message: aString
	default: ''
	in: view!

openFileName: aString default: default in: view 
    ^BDialog 
	chooseFileToOpen: view rootView blox
	label: aString
	default: default
	defaultExtension: 'st'
	types: #(#('Smalltalk files' '.st') #('Text files' '.txt'))!

saveFileName: aString default: default in: view 
    ^BDialog 
	chooseFileToSave: view rootView blox
	label: aString
	default: default
	defaultExtension: 'st'
	types: #(#('Smalltalk files' '.st') #('Text files' '.txt'))! !

!Prompter methodsFor: 'accessing'!

accept
    "Truncate string after newline character"

    | index |
    defaultResponse := blox contents.
    (index := defaultResponse findFirst: [:ch | ch == Character nl]) > 0 
	ifTrue: [defaultResponse := defaultResponse copyFrom: 1 to: index - 1]!

cancel
    defaultResponse := ''!

response
    "Return default response"

    ^defaultResponse! !

!Prompter methodsFor: 'initialize-delete'!

message: queryString default: aResponse in: view 
    "Prompt user for string input.  The default response, queryString, is displayed in
     text portion"

    | dialogShell |
    defaultResponse := aResponse.
    dialogShell := BTransientWindow new: 'Prompter dialog'
		in: view rootView blox.
    dialogShell width: 300 height: 180.
    self blox: (BDialog 
		new: dialogShell
		label: queryString
		prompt: aResponse).
    blox 
	addButton: 'OK'
	receiver: self
	message: #accept.
    blox 
	addButton: 'Cancel'
	receiver: self
	message: #cancel.
    dialogShell map.
    self blox center.
    self blox loop! !


