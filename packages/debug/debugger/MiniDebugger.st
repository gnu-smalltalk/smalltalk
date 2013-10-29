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

MiniTool subclass: MiniDebugger [

    | debugger activeContext depth methodSourceCodeCache |

    <category: 'System-Debugging-Support'>

    <comment: 'I implement a primitive (non graphical) debugger for use on systems without
graphics or when the real debugger dies (i.e. an error occurs in the
graphical debugger).  The interface is vaguely similar to GDB.'>

    MiniDebugger class >> debuggingPriority [
        <category: 'class attributes'>

        ^ FloatD infinity
    ]

    MiniDebugger class >> open: aString [
        <category: 'instance creation'>

        [ :debugger || continuation arg |
            Processor activeProcess name: 'Debugger'.
            arg := Continuation currentDo: [ :cc |
                continuation := cc.
                aString ].
            arg printNl.
            [ self new debugger: debugger; skipUselessContext; commandLoop ]
                on: SystemExceptions.DebuggerReentered
                do: [ :ex | continuation value: ex messageText ]
        ] forkDebugger
    ]

    MiniDebugger class >> debug: aString [
        <category: 'instance creation'>

        [ :debugger || continuation arg |
            Processor activeProcess name: 'Debugger'.
            arg := Continuation currentDo: [ :cc |
                continuation := cc.
                aString ].
            arg printNl.
            [ self new debugger: debugger; skipUselessContext; skipFirstCtxt; commandLoop ]
                on: SystemExceptions.DebuggerReentered
                do: [ :ex | continuation value: ex messageText ]
        ] forkDebugger
    ]

    debugger: aDebugger [
        <category: 'commands'>

        debugger := aDebugger.
    ]

    skipUselessContext [
        <category: 'private'>

        "Show meaningful source code to the user."
        [ debugger suspendedContext isInternalExceptionHandlingContext ]
            whileTrue: [ debugger slowFinish ].
    ]

    skipFirstCtxt [
        <category: 'private'>

        debugger
            step;
            step.
    ]

    commandLoop [
        <category: 'commands'>

        depth := 0.
        activeContext := debugger suspendedContext.
        debugger suspendedContext backtrace.
        self printCurrentLine.
        [
            self getCommand.
            debugger isActive
        ] whileTrue.
        Processor activeProcess suspend
    ]

    step [
        <category: 'commands'>

        debugger step.
        self resetContext
    ]

    next [
        <category: 'commands'>

        debugger next.
        self resetContext
    ]

    finish [
        <category: 'commands'>

        debugger finish: activeContext.
        self resetContext
    ]

    continue [
        <category: 'commands'>

        debugger continue
    ]

    resetContext [
        <category: 'commands'>

        activeContext := debugger suspendedContext.
        depth := 0
    ]

    up [
        <category: 'commands'>

        activeContext parentContext isNil ifTrue: [ ^self ].
        activeContext := activeContext parentContext.
        depth := depth + 1.
    ]

    down [
        <category: 'commands'>

        depth > 0 ifFalse: [ ^self ].
        depth := depth - 1.
        activeContext := debugger suspendedContext.
        depth timesRepeat: [ activeContext := activeContext parentContext ]
    ]

    printCurrentMethod [
        <category: 'printing'>

        | source |
        source := self currentMethodSource.
        source isNil ifTrue: [ ^self ].
        source keysAndValuesDo: [ :line :code |
            self rightJustify: line.
            stdout
                space;
                nextPutAll: code;
                nl
        ]
    ]

    printCurrentLine [
        <category: 'printing'>

        | line source |
        activeContext isNil ifTrue: [ ^self ].
        source := self currentMethodSource.
        source isNil ifTrue: [ ^self ].
        line := Debugger currentLineIn: activeContext.
        line = 0 ifTrue: [ ^self ].

        self rightJustify: line.
        stdout
            space;
            nextPutAll: (source at: line ifAbsent: [ '' ]);
            nl
    ]

    doStepCommand [
        <category: 'user commands'>

    | context arg |
    ('udsnfc' includes: command) ifFalse: [ ^false ].

    context := activeContext.
    arg := commandArg at: 1 ifAbsent: [ 1 ].
    arg := arg asInteger.

    arg timesRepeat: [
        (command == $u) ifTrue: [ self up ].
        (command == $d) ifTrue: [ self down ].
        (command == $s) ifTrue: [ self step ].
        (command == $n) ifTrue: [ self next ].
        (command == $f) ifTrue: [ self finish ].
        (command == $c) ifTrue: [ self continue ].
    ].

    activeContext isNil ifFalse: [
        activeContext == context ifFalse: [ activeContext printNl ].
        self printCurrentLine ].

    ^true
    ]

    doProcessCommand [
        <category: 'user commands'>

    | id processes terminated |
    ('TSKb' includes: command) ifFalse: [ ^false ].

    (commandArg isEmpty and: [ command == $b ]) ifTrue: [
        activeContext backtrace.
        ^true ].

    processes := commandArg collect: [ :each || stream proc |
        stream := each readStream.
        id := Number readFrom: stream.
        stream atEnd
            ifFalse: [ 'please supply a valid process id' displayNl. ^true ].

        proc := id asObject.
        (proc isKindOf: Process)
            ifFalse: [ 'please supply a valid process id' displayNl. ^true ].

        proc ].

    processes isEmpty ifTrue: [ processes := {debugger process} ].
    terminated := false.
    processes do: [ :proc |
        proc suspendedContext isNil
            ifTrue: [('%1: process was terminated' % { proc asOop }) displayNl]
            ifFalse: [
                (command == $b) ifTrue: [
                    processes size > 1 ifTrue: [
                        ('backtrace for process %1' % { proc asOop }) displayNl].
                    proc context backtrace ].
                (command == $S) ifTrue: [ proc suspend ].
                (command == $K) ifTrue: [ proc primTerminate ].
                (command == $T) ifTrue: [
                    proc terminate.
                    terminated := terminated or: [proc == debugger process]]]].

    terminated ifTrue: [ self continue ].
    ^true
    ]

    doCommand [
        <category: 'user commands'>

    self doStepCommand ifTrue: [ ^true ].
    self doProcessCommand ifTrue: [ ^true ].

    ('PriIJelwgxX' includes: command) ifFalse: [ ^false ].

    (command == $h) ifTrue: [ ^true ].

    commandArg isEmpty
        ifFalse: [ 'no argument needed for this command' displayNl. ^true ].

    (command == $P) ifTrue: [ self showProcesses ].
    (command == $r) ifTrue: [ activeContext receiver printNl ].
    (command == $i) ifTrue: [ MiniInspector openOn: activeContext receiver ].
    (command == $I) ifTrue: [ MiniInspector openOn: activeContext ].
    (command == $J) ifTrue: [ self printContextState ].
    (command == $e) ifTrue: [ self interpreterLoopWith: activeContext receiver ].
    (command == $l) ifTrue: [ self printCurrentMethod ].
    (command == $w) ifTrue: [ activeContext printNl. self printCurrentLine ].
    (command == $g) ifTrue: [ ObjectMemory globalGarbageCollect ].
    (command == $X) ifTrue: [ ObjectMemory abort ].
    (command == $x) ifTrue: [ ObjectMemory quit ].
    ^true
    ]

    eofCommand [
        <category: 'user commands'>

    ^'T'
    ]

    showPrompt [
        <category: 'user commands'>

        '(debug) ' display.
    ]

    help [
        <category: 'user commands'>

    ^'Control flow commands:
    s [n]      step N times
    n [n]      next (step over send) N times
    f [n]      finish current method N times
    c          continue

Process commands: no ID means debugged process
    P          show process list
    T [id]...  terminate process
    K [id]...  kill process - no unwinds or cleanup
    b [id]...  backtrace
 
Examining state:
    r          print receiver on stdout
    i          inspect (enter MiniInspector on current receiver)
    I          inspect context (enter MiniInspector on current context)
    J          print context state on stdout
    e          eval (enter read-eval-print loop on current receiver)

Examining the call stack:
    u [n]      go N frames up (default 1)
    d [n]      go N frames down (default 1)
    l          print current method
    w          print current frame

Other commands:
    g          collect all garbage
    X          exit Smalltalk, and dump core
    x          exit Smalltalk'
    ]

    printContextState [
        <category: 'private'>

        activeContext ifNil: [ ^ self ].
        activeContext printContextState
    ]

    currentMethodSource [
        <category: 'private'>

        activeContext isNil ifTrue: [ ^#() ].
        methodSourceCodeCache isNil ifTrue: [
            methodSourceCodeCache := WeakKeyIdentityDictionary new ].
        ^methodSourceCodeCache at: activeContext method ifAbsentPut: [
            activeContext method methodSourceString lines ]
    ]

    rightJustify: n [
        <category: 'private'>

        | printString |
        printString := n printString.
        stdout
            space: (7 - printString size max: 0);
            nextPutAll: printString
    ]

    showProcesses [
        <category: 'private'>

        self rightJustify: debugger process asOop.
        '>' display.
        debugger process printNl.

        Process allSubinstancesDo: [ :each |
            each == debugger process ifFalse: [
                self rightJustify: each asOop.
                ' ' display.
                each printNl ] ]
    ]

    eval: line to: anObject [

        (debugger eval: line) displayNl
    ]
]

