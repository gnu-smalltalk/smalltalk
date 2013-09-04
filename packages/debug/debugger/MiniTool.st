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

Object subclass: MiniTool [

    | commandArg command |

    <category: 'Debugging-Support'>

    MiniTool class >> debuggerClass [
        <category: 'disabling debugging'>
        ^ nil
    ]

    showPrompt [
        <category: 'instance creation'>

        self subclassResponsibility
    ]

    eofCommand [
        <category: 'instance creation'>

        self subclassResponsibility
    ]

    doCommand [
        <category: 'instance creation'>

        self subclassResponsibility
    ]

    getCommand [
        <category: 'instance creation'>

        | cmd |
        self showPrompt.

        cmd := stdin atEnd
            ifTrue: [ { self eofCommand } ]
            ifFalse: [ stdin nextLine substrings ].

        cmd isEmpty ifFalse: [
            command := (cmd at: 1) at: 1.
            commandArg := cmd copyFrom: 2.
            "Else repeat the last command."
        ].

        self doCommand ifFalse: [
            (command = $h) ifFalse: [ 'invalid command' displayNl ].
            self help displayNl
        ].
    ]

    help [
        <category: 'instance creation'>

        self subclassResponsibility
    ]

    interpreterLoopWith: anObject [
        | line |
        'read-eval-print loop; exit with empty line' displayNl.

        [
            '(rep) ' display.

            line := stdin nextLine.
            line isEmpty
        ] whileFalse: [ self eval: line to: anObject ]
    ]

    eval: line to: anObject [
        | result |
        result := Behavior
            evaluate: line
            to: anObject
            ifError: [ :f :l :e | e printNl. ^self ].

        result printNl
    ]
]

