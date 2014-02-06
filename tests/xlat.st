
"======================================================================
|
|   Regression tests for the XLAT code
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2014 Free Software Foundation.
| Written by Holger Hans Peter Freyther.
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

Object subclass: ByteCodeHoles [
    bytecodeIndex [
    ]

    dispatchTo [
        "This method should compile to the below bytecode. The
        sending of the dispatchByte:with:at:to:with: will not take
        two bytecodes but four. This broke the assumption inside the
        xlat code.
byte codes: [
    [1] source code line number 5
    [3] source code line number 7
    push self
    [5] dup stack top
    [7] send 0 args message #bytecodeIndex
    [9] source code line number 9
    pop stack top
   [11] push 0
   [13] source code line number 10
   [15] push 0
   [17] source code line number 11
   [19] push 0
   [21] source code line number 12
   [23] push 0
   [25] source code line number 13
   [27] push 0
   [29] send 5 args message #dispatchByte:with:at:to:with:
   [33] push self
    return stack top"
        <category: 'decoding bytecodes'>
            self
                bytecodeIndex;
                dispatchByte: 0
                with: 0
                at: 0
                to: 0
                with: 0
    ]
]

Eval [
    "This should generate a DNU for the dispatchTo and not end up with
    issues inside the exception handling code. We want to print the entire
    stack handling code as a call to >>#currentLine will error when we
    have saved a wrong IP."
    (ByteCodeHoles >> #dispatchTo) inspect.

    [
        ByteCodeHoles new dispatchTo.
    ] on: Exception do: [:e |
        | context |
        context := thisContext parentContext.
        [context isInternalExceptionHandlingContext]
            whileTrue: [context := context parentContext].
        context := context parentContext parentContext.
        context receiver class printNl.
        context method printNl.
        "The below should trigger the infinite loop"
        context currentLine printNl].
]
