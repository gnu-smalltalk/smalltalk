"======================================================================
|
|   Minimal inspector and debugger using DebugTools
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002, 2006, 2007 Free Software Foundation, Inc.
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
 ======================================================================"

MiniTool subclass: MiniInspector [

    | inspectedObject depth |

    <category: 'Debugging-Support'>

    <comment: 'I implement a primitive inspector which is launched by the MiniDebugger.'>

    MiniInspector class >> openOn: anObject [
        <category: 'instance creation'>

        self openOn: anObject depth: 0
    ]

    MiniInspector class >> openOn: anObject depth: n [
        <category: 'instance creation'>

        self new initializeFor: anObject depth: n; commandLoop
    ]

    help [
        <category: 'command loop'>

        ^'inspector commands:
   (e)val            start read-eval-print loop
   (i)nstvars        print all instvars
   (i)nstvars NUMBER inspect n-th instvar (negative=fixed, positive=indexed)
   (p)rint           print object
   (p)rint NUMBER    print n-th instvar (negative=fixed, positive=indexed)
   (q)uit'
    ]

    doCommand [
        <category: 'command loop'>

        (command = $p) ifTrue: [
            stdout space: depth.
            commandArg isEmpty
                ifFalse: [ (self nthInstvar: commandArg first asInteger) printNl ]
                ifTrue: [ inspectedObject printNl ].
            ^true
        ].

        (command = $e) ifTrue: [
            self interpreterLoopWith: inspectedObject.
            ^true
        ].

        (command = $i) ifTrue: [
            commandArg isEmpty
                ifFalse: [ self inspectInstvar: commandArg first asInteger ]
                ifTrue: [ self printInstVarsOf: inspectedObject ].
            ^true
        ].

        ^command = $q
    ]

    eofCommand [
        <category: 'command loop'>

        ^'q'
    ]

    commandLoop [
        <category: 'command loop'>

        self printHeader.
        [
            self getCommand.
            command = $q
        ] whileFalse.
    ]

    showPrompt [
        <category: 'command loop'>

        stdout space: depth.
        '(insp) ' display.
    ]

    inspectInstvar: which [
        <category: 'commands'>

        self doInspect: (self nthInstvar: which).
        self printHeader.
    ]

    printInstVarsOf: anObject [
        <category: 'commands'>

        stdout space: depth.
        anObject inspect.
    ]

    initializeFor: anObject depth: n [
        <category: 'private'>

        inspectedObject := anObject.
        depth := n.
        ^self
    ]

    printHeader [
        <category: 'private'>

        stdout space: depth.
        '-- inspector: ' display.
        inspectedObject basicPrintNl.
    ]

    doInspect: anObject [
        <category: 'private'>

        self class openOn: anObject depth: depth + 1
    ]

    nthInstvar: which [
        <category: 'private'>

        which < 0
            ifTrue: [ ^inspectedObject instVarAt: which negated ].

        ^inspectedObject basicSize = 0
            ifTrue: [ inspectedObject instVarAt: which ]
            ifFalse: [ inspectedObject basicAt: which ]
    ]
]

