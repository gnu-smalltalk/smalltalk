"======================================================================
|
|   Test process operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1999, 2002, 2003, 2007, 2008 Free Software Foundation.
| Written by Paolo Bonzini
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

Process extend [

    executeUntilTermination [
        self isTerminated ifTrue: [ ^self ].
        self isActive ifFalse: [ self resume ].
        [ self isTerminated ] whileFalse: [ Processor yield ]
    ]

    ensureTermination [
        self terminate; executeUntilTermination
    ]
]

"Test resuming/terminating a process"
Eval [
    p :=  [ 'inside p' printNl ] newProcess name: 'test 1'; yourself.
    p printNl.
    p executeUntilTermination.
    p printNl
]

"Test Process suspend/resume"
Eval [
    goOn := false.
    p := [
        'inside p' printNl.
	goOn := true.
        p suspend.
        'suspension finished' printNl ] newProcess name: 'test 2'; yourself.
    p printNl.
    p resume.
    [ goOn ] whileFalse: [ Processor yield ].
    p printNl.
    p executeUntilTermination.
    p printNl
]


"Test processes yielding control to each other without suspending themselves"
Eval [
    goOn := false.
    p := [
        'inside p' printNl.
	goOn := true.
        Processor yield.
        'yielded back to p' printNl ] newProcess name: 'test 3'; yourself.
    p printNl.
    p resume.
    [ goOn ] whileFalse: [ Processor yield ].
    p printNl.
    p executeUntilTermination.
    p printNl
]

"Test simple wait on a semaphore"
Eval [
    s := Semaphore new.
    p := [
        'inside p' printNl.
        s wait.
        'wait finished' printNl ] newProcess name: 'test 4'; yourself.
    p printNl.
    p resume.
    [ s size = 0 ] whileTrue: [ Processor yield ].
    p printNl.
    s signal.
    p printNl
]


"Now test process interrupts"
Eval [
    s := Semaphore new.
    ([ [ false ] whileFalse: [ Processor yield ] ]
        forkAt: Processor userBackgroundPriority)
        name: 'background';
        queueInterrupt: [ (p := Processor activeProcess) printNl. s signal ].

    s wait.
    p printNl.
    p ensureTermination.
    p printNl
]


"Now interrupt a sleeping process"
Eval [
    s := Semaphore new.
    ([ 'should go back to sleep' printNl ] newProcess)
        priority: Processor userInterruptPriority;
        name: 'interrupted';
        queueInterrupt: [ (p := Processor activeProcess) printNl. s signal ].

    s wait.
    p printNl.
    p ensureTermination.
    p printNl
]


"Resume a process and check that it is removed from the semaphore"
Eval [
    | p1 p2 s p1ok p2ok |
    s := Semaphore new.
    p1 := [ [ s wait ] ensure: [ p1ok := true ] ] fork.
    p2 := [ [ s wait ] ensure: [ p2ok := true ] ] fork.
    [ s size = 2 ] whileFalse: [ Processor yield ].
    p2 resume.
    s signal.
    p1 ensureTermination.
    ^p1ok & p2ok & s size = 0
]

Eval [
    | p1 p2 s p1ok p2ok |
    s := Semaphore new.
    p1 := [ [ s wait ] ensure: [ p1ok := true ] ] fork.
    p2 := [ [ s wait ] ensure: [ p2ok := true ] ] fork.
    [ s size = 2 ] whileFalse: [ Processor yield ].
    p1 resume.
    s signal.
    p2 ensureTermination.
    ^p1ok & p2ok & s size = 0
]

"Terminate a process and check that #ensure: blocks are evaluated"
Eval [
    dummy := Semaphore new.
    s := Semaphore new.
    p1 := [ [ dummy wait ] ensure: [ s signal ] ] fork.
    p2 := [ [ dummy wait ] ensure: [ s signal ] ] fork.
    p1 ensureTermination.
    p2 ensureTermination.
    s wait.
    s wait.
    ^s size = 0
]

Eval [
    dummy := Semaphore new.
    s := Semaphore new.

    p1 := [
        [
            Processor activeProcess priority: Processor userBackgroundPriority.
            dummy wait
        ] ensure: [ s signal ]
    ] fork.
    p2 := [
        [
            Processor activeProcess priority: Processor userBackgroundPriority.
            dummy wait
        ] ensure: [ s signal ]
    ] fork.

    p1 ensureTermination.
    p2 ensureTermination.
    s wait.
    s wait.
    ^s size = 0
]

Eval [
    "A semaphore that has just left the wait in Semaphore>>critical:
     should signal the associated semaphore before leaving."
    | s p |
    s := Semaphore new.
    p := [s critical:[]] forkAt: Processor activePriority - 1.

    "Wait until p entered the critical section"
    [p isWaiting] whileFalse: [Processor yield].

    "Now that p entered it, signal the semaphore. p now 'owns' the semaphore
     but since we are running at higher priority than p it will not get to do
     anything."
    s signal.
    p ensureTermination.
    ^s signals = 1
]

Eval [
    "A process that has entered the wait in Semaphore>>critical:,
     but never obtains the semaphore, should leave it without
     signaling the semaphore."
    | s p |
    s := Semaphore new.
    p := [s critical:[]. 'a' printNl] fork.
    [p isWaiting] whileFalse: [Processor yield].
    p ensureTermination.
    ^s signals = 0
]

"Test that processes with the same priority are executed fairly.  See
 http://permalink.gmane.org/gmane.comp.lang.smalltalk.squeak.general/122772
 for a proposed patch to Squeak that would break this testcase.
 The two producer processes would ping-pong control to each other,
 and the delay won't even be started."
Eval [
    | queue stop s |
    queue := SharedQueue new.
    stop := false.
    s := Semaphore new.
    [ s signal.
      [ stop ] whileFalse: [ queue nextPut: true. Processor yield ] ] fork.
    s wait.
    [ (Delay forMilliseconds: 500) wait. stop := true ] fork.
    [ stop ] whileFalse: [ queue nextPut: false. Processor yield ].
]


"Test ProcessEnvironment and ProcessVariable"
Eval [
    "Value defaults to nil"
    b := Processor processEnvironment associationAt: #a.
    b value printNl.

    "#at:put: affects #value"
    Processor processEnvironment at: #a put: 1.
    b value printNl.

    "and #value: affects #at:"
    b value: 2.
    (Processor processEnvironment at: #a) printNl.
    s := Semaphore new.
    [
	"Value defaults to nil here too."
        b value printNl.

	"Requesting value has not created the variable."
        Processor processEnvironment at: #a ifAbsentPut: [3].
        b value printNl.
        s signal
    ] fork.
    s wait.

    "The variable exists here..."
    Processor processEnvironment at: #a ifAbsentPut: [4].

    "... and its value is still 2."
    (Processor processEnvironment at: #a) printNl.
    b value printNl
]


"Test that CallinProcesses can be terminated softly"
Eval [
    [ [ Processor activeProcess terminate ] ensure: [ '... ' display ] ]
	on: SystemExceptions.ProcessBeingTerminated
	do: [ :sig | 'nothing should follow' display. sig pass ].
    'failed' displayNl
]

"The exception should not be resumable to avoid that execution
 is continued without the process actually having gotten a signal
 on the semaphore."
Notification subclass: ProcessInterrupt [
    isResumable [ ^false ]
    defaultAction [ Processor activeProcess terminate ]
]

"Signal a process from itself."
Eval [
    | p1 |
    p1 := [ Processor activeProcess signalInterrupt: ProcessInterrupt new ] fork.
    p1 executeUntilTermination
]

"Signal a process from the outside."
Eval [
    | p1 p2 |
    p1 := [ [ Processor activeProcess yield ] repeat ] fork.
    p2 := [ (Delay forMilliseconds: 500) wait.
        p1 signalInterrupt: (ProcessInterrupt new) ] fork.
    p1 executeUntilTermination.
    p2 executeUntilTermination
]

"Signal a process from the outside, and catch the exception."
Eval [
    | p1 p2 sem |
    sem := Semaphore new.
    p1 := [ [ [ Processor activeProcess yield ] repeat ]
               on: ProcessInterrupt
               do: [ :ex | ex return ].
            sem signal ] fork.
    p2 := [ (Delay forMilliseconds: 500) wait.
        p1 signalInterrupt: (ProcessInterrupt new) ] fork.
    sem wait.
    p1 executeUntilTermination.
    p2 executeUntilTermination
]

"Signal a process from the outside, and pass the exception."
Eval [
    | p1 p2 sem |
    sem := Semaphore new.
    p1 := [ [ [ Processor activeProcess yield ] repeat ]
               on: ProcessInterrupt
               do: [ :ex | sem signal. ex pass ] ] fork.
    p2 := [ (Delay forMilliseconds: 500) wait.
        p1 signalInterrupt: (ProcessInterrupt new) ] fork.
    sem wait.
    p1 executeUntilTermination.
    p2 executeUntilTermination
]

"Signal a sleeping process from the outside."
Eval [
    | p1 p2 sem |
    p1 := [ (Delay forSeconds: 100000) wait ] fork.
    [ p1 isActive ] whileTrue: [ Processor activeProcess yield ].
    p2 := [ (Delay forMilliseconds: 500) wait.
        p1 signalInterrupt: (ProcessInterrupt new) ] fork.
    p1 executeUntilTermination.
    p2 executeUntilTermination
]

"Signal a sleeping process from the outside, and pass the exception."
Eval [
    | p1 p2 sem |
    sem := Semaphore new.
    p1 := [ [ (Delay forSeconds: 100000) wait ]
               on: ProcessInterrupt
               do: [ :ex | ex return ].
            sem signal ] fork.
    [ p1 isActive ] whileTrue: [ Processor activeProcess yield ].
    p2 := [ (Delay forMilliseconds: 500) wait.
        p1 signalInterrupt: (ProcessInterrupt new) ] fork.
    sem wait.
    p1 executeUntilTermination.
    p2 executeUntilTermination
]

"Signal a sleeping process from the outside, and pass the exception."
Eval [
    | p1 p2 sem |
    sem := Semaphore new.
    p1 := [ [ (Delay forSeconds: 100000) wait ]
               on: ProcessInterrupt
               do: [ :ex | sem signal. ex pass ] ] fork.
    [ p1 isActive ] whileTrue: [ Processor activeProcess yield ].
    p2 := [ (Delay forMilliseconds: 500) wait.
        p1 signalInterrupt: (ProcessInterrupt new) ] fork.
    sem wait.
    p1 executeUntilTermination.
    p2 executeUntilTermination
]
