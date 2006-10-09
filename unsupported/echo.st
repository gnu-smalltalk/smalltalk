Object subclass: #EchoMain
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'!

!EchoMain class methodsFor: 'foo'!

update: aspect
    aspect == #returnFromSnapshot ifTrue: [
        Smalltalk arguments = #('--repl') ifFalse: [
            self main: Smalltalk arguments.
            ObjectMemory quit ] ]!

main: argv
     "I love Java!"
    argv
        do: [ :a| Transcript nextPutAll: a]
        separatedBy: [ Transcript nextPutAll: ' '].
    Transcript nl! !

ObjectMemory addDependent: EchoMain.
ObjectMemory snapshot: 'echo.im'!
