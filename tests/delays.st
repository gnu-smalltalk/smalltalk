"======================================================================
|
|   Test delays
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1999, 2007, 2008  Free Software Foundation.
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

Eval [
    | i j |
    i := 4.
    [
        [   (Delay forSeconds: 1) wait.
            i > 1 ] whileTrue: [ i := i - 1 ].
    ] forkAt: Processor userInterruptPriority.

    [
        (j := i) printNl.
        [ i = j ] whileTrue.
        i > 1
    ] whileTrue
]

Eval [
    Smalltalk at: #MySemaphore put: Semaphore new.
    (Delay forSeconds: 1) timedWaitOn: MySemaphore
]

Eval [
    | msec s expired |
    s := Semaphore new.
    [ (Delay forSeconds: 3) wait. s signal ] fork.
    msec := Time millisecondsToRun: [
        expired := (Delay forSeconds: 10) timedWaitOn: s ].
    ^expired not and: [ msec between: 2500 and: 4500 ]
]

"Test timeouts"
Eval [
     (Delay forSeconds: 1)
         value:
             [[(Delay forSeconds: 1000000) wait.]
                 ensure: ['ensure' printNl]]
         onTimeoutDo: ['timeout' printNl].
]

Eval [
     (Delay forSeconds: 1)
         value:
             [[(Delay forSeconds: 1000000) wait.]
                 ifCurtailed: ['ifCurtailed' printNl]]
         onTimeoutDo: ['timeout' printNl].
]

Eval [
     [
         (Delay forSeconds: 1)
             value: [
                 [
                     (Delay forSeconds: 100000)
                         value: [[(Delay forSeconds: 10000) wait] ensure:
                             ['ensure-in' printNl]]
                         onTimeoutDo: ['timeout-inner' printNl].
                 ] ensure: ['ensure-mid' printNl]]
             onTimeoutDo: ['timeout' printNl].
     ] ensure: ['ensure-out' printNl].
]

Eval [
    |d|
    d := Delay forSeconds: 1.
    d wait.
    ^(Time millisecondsToRun: [ d wait ]) >= 500
]

Eval [
    | d1 d2 p1 p2 |
    sem := Semaphore new.
    d1 := Delay forSeconds: 1.
    p1 := [ d1 value: [ sem signal ] onTimeoutDo: [ ] ] fork.
    sem wait.

    'value:onTimeoutDo:' displayNl.
    d1 := Delay forMilliseconds: 100.
    d1 value: [ [ true ] whileTrue ] onTimeoutDo: [ ]. 
    [ p1 isTerminated ] whileFalse: [ Processor yield ]
]
