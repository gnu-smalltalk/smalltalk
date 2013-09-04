"======================================================================
|
|   Inferior process control
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



ContextPart extend [

    currentLine [
	"Answer the 1-based number of the line that is pointed to by the receiver's
	 instruction pointer."

	<category: 'source code'>
	^Debugger currentLineIn: self
    ]

    debugger [
	"Answer the debugger that is attached to the given context.  It
	 is always nil unless the DebugTools package is loaded."

	<category: 'debugging'>
	| ctx home |
	ctx := self.
	[ctx isNil] whileFalse:
		[home := ctx home.
		(home notNil
		    and: [(home method attributeAt: #debugging: ifAbsent: [nil]) notNil])
			ifTrue: [^ctx receiver].
		ctx := ctx parentContext].
	^nil
    ]

]



BlockClosure extend [

    forkDebugger [
	"Suspend the currently running process and fork the receiver into a new
	 process, passing a Debugger object that controls the currently running
	 process."

	<category: 'instance creation'>
	| process |
	process := Processor activeProcess.

	[process suspend.
	Processor activeProcess priority: process priority.
	self value: (Debugger on: process)]
		forkAt: Processor unpreemptedPriority
    ]

]
