Bag subclass: #IdentityBag
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: ''

!IdentityBag methodsFor: 'private'!

dictionaryClass
    ^IdentityDictionary! !


!BlockClosure methodsFor: 'profiling'!

profile
    | s profProcess workProcess results |
    s := Semaphore new.
    results := IdentityBag new.
    workProcess := self newProcess.
    profProcess := [
	workProcess resume.
        [
	    (Delay forMilliseconds: 5) wait.
	    workProcess isTerminated
	] whileFalse: [
	    results add: workProcess suspendedContext method.
	].
	s signal
    ] forkAt: Processor highIOPriority.
    s wait.
    ^results sortedByCount
! !

[
    | n c hash |

    n := 20000.

    hash := LookupTable new: n * 2.
    1 to: n do: [ :each |
        hash at: (each printString: 16) put: 1
    ].

    c := 0.
    n to: 1 by: -1 do: [ :each |
	(hash includesKey: each printString) ifTrue: [ c := c + 1]
    ].
] profile do: [ :each | each printNl ]!
