"======================================================================
|
|   Smalltalk GUI browser initialization script
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

"Smalltalk blox+browser initialization script"

BLOX addSubspace: #BLOXBrowser!

Class allSubclassesDo: [ :each |
    (each instanceClass notNil and: [
	each instanceClass includesSelector: #inspect])
	ifTrue: [ each instanceClass removeSelector: #inspect ]
]!

| verbose |

Transcript nl; nextPutAll: 'Initializing system -- be patient...'; nl.

verbose := FileStream verbose: true.

(Namespace current includesKey: #BrowserMain)
    ifTrue: [ (Namespace current at: #BrowserMain) close ].

Namespace current: BLOX.BLOXBrowser.

#("Load our dependancy system and graphics kernel"
  'GuiData.st'
  'View.st'
  'Manager.st'
  'RadioForm.st'
  'Menu.st'
  'ModalDialog.st'
  'PList.st'
  'PText.st'
  'PCode.st'
  'ButtonForm.st'

  "View classes"
  'BrowShell.st'
  'BrowserMain.st'
  'ClassHierBrow.st'
  'ClassBrow.st'
  'NamespBrow.st'
  'MethSetBrow.st'
  'Inspector.st'
  'DictInspect.st'
  'MethInspect.st'
  'StrcInspect.st'
  'DebugSupport.st'
  'Debugger.st'
  'Notifier.st'
) do: [ :file | FileStream fileIn: file ].

FileStream verbose: verbose.

Namespace current: Smalltalk!

Collection removeSelector: #inspect ifAbsent: [ ].
SequenceableCollection removeSelector: #inspect ifAbsent: [ ]!

