"======================================================================
|
|   CallinProcess Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Process subclass: CallinProcess [
    | returnedValue |
    
    <category: 'Language-Processes'>
    <comment: 'I represent a unit of computation for which external C code requested
execution, so I must store the returned value once my computation
terminates and I must not survive across image saves (since those who
invoked me no longer exist).  I am otherwise equivalent to a Process.'>

    returnContext [
        "Return the base context in the process, i.e. the one that is
         responsible for passing the return value to C."

        <category: 'private'>
        | context |
        context := self context.
        [ context parentContext isNil ] whileFalse: [
            context := context parentContext ].
        ^context
    ]

    detach [
        "Continue running the receiver as a normal Process, and return
         nil from the callin."

        <category: 'debugging'>
        | p |
        self isActive ifFalse: [ 
            ^SystemExceptions.InvalidState signalOn: self
                reason: 'process not active' ].

        p := Process basicNew.
        Link instSize + 1 to: Process instSize do: [ :i |
            p instVarAt: i put: (self instVarAt: i) ].

        "Start executing the detached process from here."
        p suspendedContext: thisContext copy.

        Processor activeProcess == self ifTrue: [
            "This only runs in the CallinProcess."
            thisContext parentContext: self returnContext.
            p resume.
            ^nil ]
    ]
]

