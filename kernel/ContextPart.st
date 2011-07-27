"======================================================================
|
|   ContextPart Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2007, 2008
| Free Software Foundation, Inc.
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



Object subclass: ContextPart [
    | parent nativeIP ip sp receiver method |
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'My instances represent executing Smalltalk code, which represent the local
environment of executable code. They contain a stack and also provide some
methods that can be used in inspection or debugging.'>

    ContextPart class >> spIndex [
	<category: 'private'>
	^4
    ]

    ContextPart class >> checkPresenceOfJIT [
	<category: 'private'>
	thisContext isJIT 
	    ifTrue: [Smalltalk addFeature: #JIT]
	    ifFalse: [Smalltalk removeFeature: #JIT]
    ]

    ContextPart class >> backtrace [
	"Print a backtrace from the caller to the bottom of the stack on the
	 Transcript"

	<category: 'exception handling'>
	thisContext parentContext backtraceOn: Transcript
    ]

    ContextPart class >> backtraceOn: aStream [
	"Print a backtrace from the caller to the bottom of the stack on aStream"

	<category: 'exception handling'>
	thisContext parentContext backtraceOn: aStream
    ]

    ContextPart class >> thisContext [
	"Return the value of the thisContext variable.  Called internally
	 when the variable is accessed."

	<category: 'built ins'>
	<primitive: VMpr_ContextPart_thisContext>
	
    ]

    backtrace [
	"Print a backtrace from the receiver to the bottom of the stack on the
	 Transcript."

	<category: 'printing'>
	self backtraceOn: Transcript
    ]

    backtraceOn: aStream [
	"Print a backtrace from the caller to the bottom of the stack on aStream."

	<category: 'printing'>
	| ctx |
	ctx := self.
	[ctx isNil or: [ctx isEnvironment]] whileFalse: 
		[ctx isDisabled 
		    ifFalse: 
			[ctx printOn: aStream.
			aStream nl].
		ctx := ctx parentContext]
    ]

    currentLineInFile [
	"Answer the 1-based number of the line that is pointed to by the
	 receiver's instruction pointer, relative to the method's file.
	 The implementation is slow unless the DebugTools package is loaded."

	<category: 'debugging'>
	^self currentLine + self method sourceCodeLinesDelta
    ]

    currentFileName [
	"Answer the name of the file where the method source code is"

	<category: 'accessing'>
	| sourceCode |
	sourceCode := self method methodSourceCode.
	sourceCode isString ifTrue: [ ^'a String' ].
	sourceCode isNil ifTrue: [ ^'source not available' ].
	^sourceCode printedFileName
    ]

    currentLine [
	"Answer the 1-based number of the line that is pointed to by the receiver's
	 instruction pointer.  The DebugTools package caches information,
	 thus making the implementation faster."

	<category: 'debugging'>
	^self method sourceCodeMap at: (self ip - 1 max: 1) ifAbsent: [1]
    ]

    debugger [
	"Answer the debugger that is attached to the given context.  It
	 is always nil unless the DebugTools package is loaded."

	<category: 'debugging'>
	^nil
    ]

    debuggerClass [
	"Answer which debugger should be used to debug the current
	 context chain.  The class with the highest debugging
	 priority is picked among those mentioned in the chain."

	<category: 'debugging'>
	| ctx debuggerClass currentClass last |
	ctx := self.
	
	[currentClass := ctx receiver class debuggerClass.
	currentClass isNil ifTrue: [^nil].
	(debuggerClass isNil 
	    or: [currentClass debuggingPriority > debuggerClass debuggingPriority]) 
		ifTrue: [debuggerClass := currentClass].
	ctx parentContext isNil or: [ctx isEnvironment]]
		whileFalse: [ctx := ctx parentContext].
	^debuggerClass
    ]

    isInternalExceptionHandlingContext [
	"Answer whether the receiver is a context that should be hidden to the user
	 when presenting a backtrace."

	<category: 'debugging'>
	self subclassResponsibility
    ]

    client [
	"Answer the client of this context, that is, the object that sent the
	 message that created this context. Fail if the receiver has no parent"

	<category: 'accessing'>
	^self parentContext receiver
    ]

    environment [
	"To create a valid execution environment for the interpreter even before
	 it starts, GST creates a fake context whose selector is nil and which
	 can be used as a marker for the current execution environment. This
	 method answers that context.
	 For processes, it answers the process block itself"

	<category: 'accessing'>
	| ctx next |
	ctx := self.
	
	[next := ctx parentContext.
	ctx isEnvironment | next isNil] 
		whileFalse: [ctx := next].
	^ctx
    ]

    initialIP [
	"Answer the value of the instruction pointer when execution starts
	 in the current context"

	<category: 'accessing'>
	^0
    ]

    isDisabled [
	"Answers whether the context is skipped when doing a return.  Contexts
	 are marked as disabled whenever a non-local return is done (either by
	 returning from the enclosing method of a block, or with the
	 #continue: method of ContextPart) and there are unwind contexts such
	 as those created by #ensure:.  All non-unwind contexts are then
	 marked as disabled."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    isUnwind [
	"Answers whether the context must continue execution even after a
	 non-local return (a return from the enclosing method of a block, or
	 a call to the #continue: method of ContextPart).  Such contexts are
	 created by #ensure:."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    isEnvironment [
	"To create a valid execution environment for the interpreter even
	 before it starts, GST creates a fake context which invokes a special
	 ``termination'' method.  Such a context can be used as a marker for
	 the current execution environment.  Answer whether the receiver is
	 that kind of context."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    isProcess [
	"Answer whether the receiver represents a process context, i.e. a context
	 created by BlockClosure>>#newProcess. Such a context can be recognized
	 because it has no parent but its flags are different from those of the
	 contexts created by the VM's prepareExecutionEnvironment function."

	<category: 'accessing'>
	^self parentContext isNil & self isEnvironment not
    ]

    parentContext [
	"Answer the context that called the receiver"

	<category: 'accessing'>
	^parent
    ]

    parentContext: aContext [
	"Set the context to which the receiver will return"

	"Fixed typing isn't usually good, but this is too important"

	<category: 'accessing'>
	aContext class superclass == ContextPart | aContext isNil 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: aContext mustBe: ContextPart].
	parent := aContext
    ]

    ip [
	"Answer the current instruction pointer into the receiver"

	"This funny implementation thwarts the interpreter's optimizing effort"

	<category: 'accessing'>
	^ip yourself
    ]

    ip: newIP [
	"Set the instruction pointer for the receiver"

	"Fixed typing isn't usually good, but this is too important"

	<category: 'accessing'>
	newIP isSmallInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: newIP mustBe: SmallInteger].
	ip := newIP
    ]

    size [
	"Answer the number of valid fields for the receiver. Any read
	 access from (self size + 1) to (self basicSize) will give nil."

	<category: 'accessing'>
	^self sp + 1
    ]

    at: index [
	"Answer the index-th slot in the receiver. Any read
	 access from (self size + 1) to (self basicSize) will give nil."

	<category: 'accessing'>
        (index > self size and: [ index <= self basicSize ]) ifTrue: [^nil].
	^super at: index
    ]

    at: index put: anObject [
	"Answer the index-th slot in the receiver. Any write
	 access from (self size + 1) to (self basicSize) will give an error
         unless nil is being written.  This is because doing such an access
         first, and then updating sp, is racy: the garbage collector may
         trigger in the middle and move anObject, but the slot in the
         context won't be adjusted."

	<category: 'accessing'>
        (index > self size and: [ index <= self basicSize ]) ifTrue: [
            anObject isNil ifFalse: [
                ^SystemExceptions.InvalidArgument signalOn: self ] ].

	^super at: index put: anObject
    ]

    sp [
	"Answer the current stack pointer into the receiver"

	"This funny implementation thwarts the interpreter's optimizing effort"

	<category: 'accessing'>
	^sp yourself
    ]

    validSize [
	"Answer how many elements in the receiver should be inspected"

	<category: 'accessing'>
	^self size
    ]

    numArgs [
	"Answer the number of arguments passed to the receiver"

	<category: 'accessing'>
	^self method numArgs
    ]

    numTemps [
	"Answer the number of temporaries used by the receiver"

	<category: 'accessing'>
	^self method numTemps
    ]

    push: anObject [
	"Push an object on the receiver's stack."

	"Since the newly accessible slots may have contained garbage, this method
	 makes them valid *before* they become accessible."

	<category: 'accessing'>
	self at: sp + 1 put: nil.
	sp := sp + 1.
	self at: sp put: anObject.
    ]

    sp: newSP [
	"Set the stack pointer for the receiver."

	"Storing into the stack pointer is a potentially dangerous thing, so
	 this code tests that sp is effectively a number.  Also, since the
	 newly accessible slots may have contained garbage, this method
	 stores nil into any cells that become accessible."

	<category: 'accessing'>
	newSP isSmallInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: newSP mustBe: SmallInteger].
	newSP > sp ifTrue: [sp + 1 to: newSP do: [:i | self at: i put: nil]].
	sp := newSP
    ]

    method [
	"Return the CompiledMethod being executed"

	<category: 'accessing'>
	^method
    ]

    methodClass [
	"Return the class in which the CompiledMethod being executed is defined"

	<category: 'accessing'>
	^self method methodClass
    ]

    isBlock [
	"Answer whether the receiver is a block context"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    receiver [
	"Return the receiver (self) for the method being executed"

	"This funny implementation thwarts the interpreter's optimizing effort"

	<category: 'accessing'>
	^receiver yourself
    ]

    selector [
	"Return the selector for the method being executed"

	<category: 'accessing'>
	^self method selector
    ]

    home [
	"Answer the MethodContext to which the receiver refers"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    isJIT [
	<category: 'private'>
	^nativeIP ~~ 0
    ]

    deepCopy [
	"Answer a copy of the entire stack, but don't copy any
	 of the other instance variables of the context."

	<category: 'copying'>
	^self copyStack
    ]

    copyStack [
	"Answer a copy of the entire stack."

	<category: 'copying'>
	| ret ctx |
	ret := ctx := self copy.
	[ctx parentContext isNil] 
	    whileFalse: [ctx parentContext: (ctx := ctx parentContext copy)].
	^ret
    ]

    scanBacktraceForAttribute: selector do: aBlock [
	"Scan the backtrace for contexts which have the attribute selector
	 listed in selectors; if one is found, invoke aBlock passing the
	 context and the attribute."

	<category: 'enumerating'>
	| ctx attr |
	ctx := self.
	[(ctx isBlock not and: 
	    [attr := ctx method attributeAt: selector ifAbsent: [nil].
	    attr notNil]) 
		ifTrue: [aBlock value: ctx value: attr].

	ctx isEnvironment or: [(ctx := ctx parentContext) isNil]] whileFalse
    ]

    scanBacktraceFor: selectors do: aBlock [
	"Scan the backtrace for contexts whose selector is among those
	 listed in selectors; if one is found, invoke aBlock passing the
	 context."

	<category: 'enumerating'>
	| ctx |
	ctx := self.
	[ctx isNil or: [ctx isEnvironment]] whileFalse: 
		[(ctx isBlock not and: [selectors includes: ctx selector]) 
		    ifTrue: [aBlock value: ctx].
		ctx := ctx parentContext]
    ]

    securityCheckForName: name [
	<category: 'security checks'>
	self isUntrusted ifFalse: [^self].
	^self 
	    doSecurityCheckForName: name
	    actions: #()
	    target: nil
    ]

    securityCheckForName: name action: action [
	<category: 'security checks'>
	self isUntrusted ifFalse: [^self].
	^self 
	    doSecurityCheckForName: name
	    actions: {action}
	    target: nil
    ]

    securityCheckForName: name target: target [
	<category: 'security checks'>
	self isUntrusted ifFalse: [^self].
	^self 
	    doSecurityCheckForName: name
	    actions: #()
	    target: target
    ]

    securityCheckForName: name actions: actions target: target [
	<category: 'security checks'>
	self isUntrusted ifFalse: [^self].
	^self 
	    doSecurityCheckForName: name
	    actions: actions
	    target: target
    ]

    doSecurityCheckForName: name actions: actions target: target [
	<category: 'security checks'>
	| perm ctx |
	perm := (Permission new)
		    name: name actions: actions;
		    target: target.
	(self checkSecurityFor: perm) ifFalse: [(SecurityError for: perm) signal]
    ]

    checkSecurityFor: perm [
	<category: 'security checks'>
	"First of all, check against the static permissions for this
	 context."

	| state foundAnnotation |
	(self receiver class check: perm) ifFalse: [^false].

	"Then, check the dynamic permissions.  So:
	 1) check if a method was specifically denying access,
	 2) look for a deeper context whose static permissions
	 denies access, but stop if a method is specifically
	 granting access."
	self method isAnnotated 
	    ifTrue: 
		[foundAnnotation := false.
		self method attributesDo: 
			[:each | 
			| newPerm |
			each selector = #permission: 
			    ifTrue: 
				[newPerm := each arguments at: 1.
				(newPerm implies: perm) 
				    ifTrue: 
					["Should we check if the granted permission is statically
					 available?  Of course, you can only grant permissions if you
					 own them statically, so the real question is, should we
					 check perm or newPerm?  The answer is perm (which has
					 already been found to be available), hence we can skip
					 an expensive static permission check.  Suppose we have a
					 method that grants access to all files: it makes more sense
					 if it means ``grant access to all files allowed by the class
					 security policy'', rather than ``grant access to all files if
					 the security policy allows it, else do not grant access to
					 any file''."

					foundAnnotation := true.
					state := newPerm isAllowing]]].
		foundAnnotation ifTrue: [^state]].

	"Nope, no special regulations were found in this method.  Look in the
	 parent context, and grant permission if the bottom is reached."
	^self parentContext isNil or: [self parentContext checkSecurityFor: perm]
    ]

    continue: anObject [
	"Resume execution from the receiver, faking that the context on
	 top of it in the execution chain has returned anObject.  The
	 receiver must belong to the same process as the executing context,
	 otherwise the results are not predictable.  All #ensure: (and
	 possibly #ifCurtailed:) blocks between the currently executing
	 context and the receiver are evaluated (which is not what
	 would happen if you directly bashed at the parent context of
	 thisContext)."

	<category: 'built ins'>
	<primitive: VMpr_ContextPart_continue>
	self badReturnError
    ]
]

