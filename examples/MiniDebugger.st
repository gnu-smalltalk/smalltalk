"======================================================================
|
|   Minimal inspector and debugger
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


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
	instanceVariableNames: 'process activeContext depth stepSemaphore
				methodSourceCodeCache methodLineMapCache'
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

    cmd := stdin nextLine substrings.
    stdin atEnd ifTrue: [ cmd := { self eofCommand } ].
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

openOn: process message: aString
    [
	Processor activeProcess name: 'MiniDebugger'.
	[ process isSuspended ] whileFalse: [ Processor yield ].
	aString printNl.
        self new initializeFor: process; commandLoop
    ] fork.
    process suspend.
! !


!MiniDebugger methodsFor: 'stepping commands'!

up
    activeContext parentContext isNil ifTrue: [ ^self ].
    activeContext := activeContext parentContext.
    depth := depth + 1.
!

down
    depth > 0 ifFalse: [ ^self ].
    depth := depth - 1.
    activeContext := process suspendedContext.
    depth timesRepeat: [ activeContext := activeContext parentContext ]
!

stepBytecode
    process singleStepWaitingOn: stepSemaphore.
    process suspend.
!

step
    | context line |
    context := process suspendedContext.
    line := self currentLine.
    [
	self stepBytecode.
	activeContext := process suspendedContext.
	activeContext == context and: [ line = self currentLine ]
    ] whileTrue.
    depth := 0.
!

next
    | context |
    context := process suspendedContext.
    [
        self step.
        activeContext notNil and: [ activeContext parentContext == context ]
    ] whileTrue: [
        self finish: activeContext
    ]
!

finish: aContext
    | context |
    [
	context := process suspendedContext.
	[
	    self stepBytecode.
	    process suspendedContext == context
	] whileTrue.

	activeContext := process suspendedContext.
	activeContext notNil "no context? exit"
	    and: [ activeContext parentContext == context "a send? go on"
	    or: [ (self depthOf: aContext) notNil ]] "aContext still in the chain? go on"
    ] whileTrue
!

finish
    self finish: activeContext
!

continue
    | proc |
    proc := Processor activeProcess.
    [ proc terminate. process resume ] forkAt: Processor unpreemptedPriority.

    "Suspend just in case we get here."
    proc suspend
! !


!MiniDebugger methodsFor: 'source code'!

currentMethodSource
    ^methodSourceCodeCache at: activeContext method ifAbsentPut: [
	self linesOf: activeContext method methodSourceString
    ]
!

currentLine
    | lineMap |
    lineMap := methodLineMapCache at: activeContext method ifAbsentPut: [
	activeContext method sourceCodeMap
    ].
    ^lineMap at: activeContext ip + 1 ifAbsent: [ activeContext inspect. 1 ]
!

linesOf: aString
    | oc start |
    aString isNil ifTrue: [ ^#() ].
    oc := OrderedCollection new.
    start := 0.
    aString keysAndValuesDo: [ :index :each |
	each == Character nl
	    ifTrue: [
		oc add: (aString copyFrom: start to: index - 1).
		start := index + 1
	    ]
    ].
    oc add: (aString copyFrom: start).
    ^oc
!

printCurrentMethod
    self currentMethodSource keysAndValuesDo: [ :line :code |
	self rightJustify: line.
	stdout
	    space;
	    nextPutAll: code;
	    nl
    ]
!

printCurrentLine
    | line |
    line := self currentLine.
    line = 0 ifTrue: [ ^self ].

    self rightJustify: line.
    stdout
	space;
	nextPutAll: (self currentMethodSource at: line ifAbsent: [ '' ]);
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

    activeContext == context ifFalse: [ activeContext printNl ].
    self printCurrentLine.
    ^true
!

doProcessCommand
    | id proc |
    ('TSKb' includes: command) ifFalse: [ ^false ].

    proc := process.
    commandArg notEmpty ifTrue: [
	id := Number readFrom: commandArg onError: nil.

	proc := id asObject.
	(proc isKindOf: Process)
	    ifFalse: [ 'please supply a valid process id' displayNl. ^true ].
    ].

    proc suspendedContext isNil
	ifTrue: [ 'process was terminated' displayNl. ^true ].

    (command == $b) ifTrue: [ self backtraceOf: proc ].
    (command == $S) ifTrue: [ proc suspend ].
    (command == $K) ifTrue: [ proc primTerminate ].
    (command == $T) ifTrue: [
	proc terminate.
	proc == process ifTrue: [ self continue ]
    ].
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

commandLoop
    [
	self getCommand.
	process isTerminated
    ] whileFalse.
    Processor activeProcess suspend
!

eofCommand
    ^'T'
!

showPrompt
    '(debug) ' display.
!

help
    ^'Control flow commands:
    s [n].. step N times
    n [n].. next (step over send) N times
    f [n].. finish current method N times
    c ..... continue

Process commands: no ID means debugged process
    P ..... show process list
    T [id]. terminate process
    K [id]. kill process - no unwinds or cleanup
    b [id]. backtrace
 
Examining state:
    r ..... print receiver on stdout
    i ..... inspect (enter MiniInspector on current receiver)
    I ..... inspect context (enter MiniInspector on current context)
    e ..... eval (enter read-eval-print loop on current receiver)

Examining the call stack:
    u [n].. go N frames up
    d [n].. go N frames down
    l ..... print current method
    w ..... print current frame

Other commands:
    P ..... list processes
    g ..... collect all garbage
    X ..... exit Smalltalk, and dump core
    x ..... exit Smalltalk'
! !


!MiniDebugger methodsFor: 'private'!

initializeFor: aProcess
    process := aProcess.
    stepSemaphore := Semaphore new.
    methodSourceCodeCache := IdentityDictionary new.
    methodLineMapCache := IdentityDictionary new.
    activeContext := process suspendedContext.
    depth := 0.

    [ activeContext isInternalExceptionHandlingContext ]
	whileTrue: [ self finish ].

    process suspendedContext backtraceOn: stdout.
    ObjectMemory globalGarbageCollect.
!

backtraceOf: aProcess
    | context |
    context := aProcess == process
	ifTrue: [ activeContext ]
	ifFalse: [ aProcess suspendedContext ].

    context backtrace
!

depthOf: aContext
    | context depth |
    context := activeContext.
    depth := 0.
    [ context == aContext ] whileFalse: [
	context := context parentContext.
	context isNil ifTrue: [ ^nil ].
	depth := depth + 1.
    ].
    ^depth
!

rightJustify: n
    | printString |
    printString := n printString.
    stdout
        space: (7 - printString size max: 0);
        nextPutAll: printString
!

showProcesses
    self rightJustify: process asOop. '>' display. process printNl.
    Process allSubinstancesDo: [ :each |
	each == process
	    ifFalse: [ self rightJustify: each asOop. ' ' display. each printNl ]
    ]
! !


!Behavior methodsFor: 'debugging'!

debuggerClass
    ^MiniDebugger
! !
