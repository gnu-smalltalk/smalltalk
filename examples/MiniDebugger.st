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

PackageLoader fileInPackage: #DebugTools!

Object subclass: #MiniTool
	instanceVariableNames: 'commandArg command'
	classVariableNames:''
	poolDictionaries:''
	category: 'Debugging-Support'
!

MiniTool subclass: #MiniInspector
	instanceVariableNames: 'inspectedObject depth'
	classVariableNames:''
	poolDictionaries:''
	category: 'Debugging-Support'
!

MiniTool subclass: #MiniDebugger
	instanceVariableNames: 'debugger activeContext depth methodSourceCodeCache'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'System-Debugging-Support'
!

MiniInspector comment:
'I implement a primitive inspector which is launched by the MiniDebugger.'!

MiniDebugger comment:
'I implement a primitive (non graphical) debugger for use on systems without
graphics or when the real debugger dies (i.e. an error occurs in the
graphical debugger).  The interface is vaguely similar to GDB.'!


!MiniTool class methodsFor: 'disabling debugging'!

debuggerClass
    ^nil
! !

!MiniTool methodsFor: 'rep loop'!

interpreterLoopWith: anObject
    | line |
    'read-eval-print loop; exit with empty line
' displayNl.

    [
	'(rep) ' display.

	line := stdin nextLine.
	line isEmpty
    ] whileFalse: [
	self eval: line to: anObject
    ]
!

eval: line to: anObject
    | result |
    result := Behavior
	evaluate: line
	to: anObject
	ifError: [ :f :l :e | e printNl. ^self ].

    result printNl
! !

!MiniTool methodsFor: 'instance creation'!

showPrompt
    self subclassResponsibility
!

eofCommand
    self subclassResponsibility
!

doCommand
    self subclassResponsibility
!

getCommand
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
!


help
    self subclassResponsibility
! !


!MiniInspector class methodsFor: 'instance creation'!

openOn: anObject
    self openOn: anObject depth: 0
!

openOn: anObject depth: n
    self new initializeFor: anObject depth: n; commandLoop
! !

!MiniInspector methodsFor: 'command loop'!

help
   ^'inspector commands:
   (e)val            start read-eval-print loop
   (i)nstvars        print all instvars
   (i)nstvars NUMBER inspect n-th instvar (negative=fixed, positive=indexed)
   (p)rint           print object
   (p)rint NUMBER    print n-th instvar (negative=fixed, positive=indexed)
   (q)uit'
!

doCommand
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
!

eofCommand
    ^'q'
!

commandLoop
    self printHeader.
    [
	self getCommand.
	command = $q
    ] whileFalse.
!

showPrompt
    stdout space: depth.
    '(insp) ' display.
! !

!MiniInspector methodsFor: 'commands'!

inspectInstvar: which
    self doInspect: (self nthInstvar: which).
    self printHeader.
!

printInstVarsOf: anObject
    stdout space: depth.
    anObject inspect.
! !

!MiniInspector methodsFor: 'private'!

initializeFor: anObject depth: n
    inspectedObject := anObject.
    depth := n.
    ^self
!

printHeader
    stdout space: depth.
    '-- inspector: ' display.
    inspectedObject basicPrintNl.
!

doInspect: anObject
    self class openOn: anObject depth: depth + 1
!

nthInstvar: which
    which < 0
	ifTrue: [ ^inspectedObject instVarAt: which negated ].

    ^inspectedObject basicSize = 0
	ifTrue: [ inspectedObject instVarAt: which ]
	ifFalse: [ inspectedObject basicAt: which ]
! !


!MiniDebugger class methodsFor: 'class attributes'!

debuggingPriority
    ^FloatD infinity
! !

!MiniDebugger class methodsFor: 'instance creation'!

open: aString
    [ :debugger || continuation arg |
	Processor activeProcess name: 'Debugger'.
	arg := Continuation currentDo: [ :cc |
            continuation := cc.
            aString ].
	arg printNl.
	[ self new debugger: debugger; commandLoop ]
	    on: SystemExceptions.DebuggerReentered
	    do: [ :ex | continuation value: ex messageText ]
    ] forkDebugger
! !

!MiniDebugger methodsFor: 'commands'!

debugger: aDebugger
    debugger := aDebugger.
!

commandLoop

    "Show meaningful source code to the user."
    [ debugger suspendedContext isInternalExceptionHandlingContext ]
	whileTrue: [ debugger slowFinish ].

    depth := 0.
    activeContext := debugger suspendedContext.
    debugger suspendedContext backtrace.
    self printCurrentLine.
    [
	self getCommand.
	debugger isActive
    ] whileTrue.
    Processor activeProcess suspend
!


!MiniDebugger methodsFor: 'commands'!

step
    debugger step.
    self resetContext!

next
    debugger next.
    self resetContext!

finish
    debugger finish: activeContext.
    self resetContext!

continue
    debugger continue!

resetContext
    activeContext := debugger suspendedContext.
    depth := 0!

up
    activeContext parentContext isNil ifTrue: [ ^self ].
    activeContext := activeContext parentContext.
    depth := depth + 1.
!

down
    depth > 0 ifFalse: [ ^self ].
    depth := depth - 1.
    activeContext := debugger suspendedContext.
    depth timesRepeat: [ activeContext := activeContext parentContext ]
! !

!MiniDebugger methodsFor: 'printing'!

printCurrentMethod
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
!

printCurrentLine
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
! !


!MiniDebugger methodsFor: 'user commands'!

doStepCommand
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
!

doProcessCommand
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
!

doCommand
    self doStepCommand ifTrue: [ ^true ].
    self doProcessCommand ifTrue: [ ^true ].

    ('PriIelwgxX' includes: command) ifFalse: [ ^false ].

    (command == $h) ifTrue: [ ^true ].

    commandArg isEmpty
	ifFalse: [ 'no argument needed for this command' displayNl. ^true ].

    (command == $P) ifTrue: [ self showProcesses ].
    (command == $r) ifTrue: [ activeContext receiver printNl ].
    (command == $i) ifTrue: [ MiniInspector openOn: activeContext receiver ].
    (command == $I) ifTrue: [ MiniInspector openOn: activeContext ].
    (command == $e) ifTrue: [ self interpreterLoopWith: activeContext receiver ].
    (command == $l) ifTrue: [ self printCurrentMethod ].
    (command == $w) ifTrue: [ activeContext printNl. self printCurrentLine ].
    (command == $g) ifTrue: [ ObjectMemory globalGarbageCollect ].
    (command == $X) ifTrue: [ ObjectMemory abort ].
    (command == $x) ifTrue: [ ObjectMemory quit ].
    ^true
!

eofCommand
    ^'T'
!

showPrompt
    '(debug) ' display.
!

help
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
! !

!MiniDebugger methodsFor: 'private'!

currentMethodSource
    activeContext isNil ifTrue: [ ^#() ].
    methodSourceCodeCache isNil ifTrue: [
	methodSourceCodeCache := WeakKeyIdentityDictionary new ].
    ^methodSourceCodeCache at: activeContext method ifAbsentPut: [
	activeContext method methodSourceString lines ]
!

rightJustify: n
    | printString |
    printString := n printString.
    stdout
        space: (7 - printString size max: 0);
        nextPutAll: printString
!

showProcesses
    self rightJustify: debugger process asOop.
    '>' display.
    debugger process printNl.

    Process allSubinstancesDo: [ :each |
	each == debugger process ifFalse: [
	    self rightJustify: each asOop.
	    ' ' display.
	    each printNl ] ]
! !

!UndefinedObject methodsFor: 'polymorphism'!

lines
    ^nil
! !



!Behavior methodsFor: 'debugging'!

debuggerClass
    ^MiniDebugger
! !
