"======================================================================
|
|   Test process operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1999, 2002, 2003 Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

!Process methodsFor: 'testing'!

executeUntilTermination
    self isTerminated ifTrue: [ ^self ].
    self isActive ifFalse: [ self resume ].
    [ self isTerminated ] whileFalse: [ Processor yield ]!

ensureTermination
    self terminate; executeUntilTermination
! !

"Test resuming/terminating a process"
| p |
p :=  [ 'inside p' printNl ] newProcess name: 'test 1'; yourself.
p printNl.
p executeUntilTermination.
p printNl!

"Test Process suspend/resume"
| p |
p := [
    'inside p' printNl.
    p suspend.
    'suspension finished' printNl ] newProcess name: 'test 2'; yourself.
p printNl.
p resume.
p printNl.
p executeUntilTermination.
p printNl!


"Test processes yielding control to each other without suspending themselves"
| p testFinished |
p := [
    'inside p' printNl.
    Processor yield.
    'yielded back to p' printNl ] newProcess name: 'test 3'; yourself.
p printNl.
p resume.
p printNl.
p executeUntilTermination.
p printNl!

"Test simple wait on a semaphore"
| p s |
s := Semaphore new.
p := [
    'inside p' printNl.
    s wait.
    'wait finished' printNl ] newProcess name: 'test 4'; yourself.
p printNl.
p resume.
p printNl.
s signal.
p printNl!


"Now test process interrupts"
| s p |
s := Semaphore new.
([ [ false ] whileFalse: [ ] ]
    forkAt: Processor userBackgroundPriority)
    name: 'background';
    queueInterrupt: [ (p := Processor activeProcess) printNl. s signal ].

s wait.
p printNl.
p ensureTermination.
p printNl!


"Now interrupt a sleeping process"
| s p |
s := Semaphore new.
([ 'should go back to sleep' printNl ] newProcess)
    priority: Processor userInterruptPriority;
    name: 'interrupted';
    queueInterrupt: [ (p := Processor activeProcess) printNl. s signal ].

s wait.
p printNl.
p ensureTermination.
p printNl!


"Resume a process and check that it is removed from the semaphore"
| p1 p2 s p1ok p2ok |
s := Semaphore new.
p1 := [ [ s wait ] ensure: [ p1ok := true ] ] fork.
p2 := [ [ s wait ] ensure: [ p2ok := true ] ] fork.
p2 resume.
s signal.
^p1ok & p2ok & s size = 0!

| p1 p2 s p1ok p2ok |
s := Semaphore new.
p1 := [ [ s wait ] ensure: [ p1ok := true ] ] fork.
p2 := [ [ s wait ] ensure: [ p2ok := true ] ] fork.
p1 resume.
s signal.
^p1ok & p2ok & s size = 0!

"Terminate a process and check that #ensure: blocks are evaluated"
| p1 p2 s dummy |
dummy := Semaphore new.
s := Semaphore new.
p1 := [ [ dummy wait ] ensure: [ s signal ] ] fork.
p2 := [ [ dummy wait ] ensure: [ s signal ] ] fork.
p1 ensureTermination.
p2 ensureTermination.
s wait.
s wait.
^s size = 0!

| p1 p2 s dummy |
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
^s size = 0!
