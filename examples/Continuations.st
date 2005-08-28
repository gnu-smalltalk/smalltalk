"======================================================================
|
|   Lisp continuations for Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1992 University of Manchester
| Written by Ian Piumarta.
|
 ======================================================================"


Object subclass: #Continuation
    instanceVariableNames: 'stack '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Kernel-Methods'!


!Continuation methodsFor: 'private'!

stack
    ^stack!

stack: s
    stack := s! !

!Continuation methodsFor: 'invocation'!

oneShotValue
    thisContext parentContext: stack.
    ^nil!

oneShotValue: v
    "escape to the original continuation with v as the result, discarding the stack on the way"

    thisContext parentContext: stack.
    ^v!

value
    thisContext parentContext: stack copyStack.
    ^nil!

value: v
    "return to the original continuation, copying the stack to allow another activation"
    thisContext parentContext: stack copyStack.
    ^v!

valueWithArguments: v
    "with one argument, just invoke the usual value mechanism"
    v size == 1 ifFalse: [^self error: 'continuations can only be resumed with one argument'].
    ^self value: (v at: 1)! !


!Continuation class methodsFor: 'instance creation'!

fromContext: aStack
    ^self new stack: aStack copyStack! !

!Continuation class methodsFor: 'examples'!

factorialExample: x 
    "Modified from the example given in Dybvig p. 81 (the example is 
    explained adequately there). Evaluate each of the following expressions 
    in turn.
    Undeclared is used to hold a `global' temporary to avoid cluttering your
    namespace."

    "Transcript cr; show: (self factorialExample: 4) printString; cr" 
    "(Undeclared at: #RetryCC) value: 2"
    "(Undeclared at: #RetryCC) value: 5"
    "Undeclared removeKey: #RetryCC"

    ^x == 0
    	ifTrue: [
	    [ :continuation | 
		Undeclared at: #RetryCC put: continuation.
		1] callCC]
	ifFalse: [x * (self factorialExample: x - 1) printNl]! !

!BlockClosure methodsFor: 'copying'!

copyStack
    outerContext := outerContext copyStack! !

!BlockClosure methodsFor: 'continuations'!

callCC
    ^self value: (Continuation fromContext: thisContext parentContext)! !

!ContextPart methodsFor: 'copying'!

copyStack
    self parentContext isNil
	ifTrue:[^self copy]
	ifFalse: [^self copy parentContext: self parentContext copyStack]! !

(Continuation factorialExample: 4) printNl!
(Undeclared.RetryCC value: 10) printNl!
Undeclared removeKey: #RetryCC!
