Object subclass: #A
       instanceVariableNames: 'array'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil!
 
!A class methodsFor: 'instance creation'!
new
 	^super new
! !
 
!A methodsFor: 'accessing'!

initialize
| arrayType |
 
    arrayType := CArrayCType elementType: CLongType numberOfElements: 4.
    array := arrayType new.  "create (malloc) a C object of the right size"
 
    array at: 0 put: 1.     " be more creative than I am about loading it"
    array at: 1 put: 2.
    array at: 2 put: 3.
    array at: 3 put: 3.
 
    (array at: 0) printNl.
    "array func: array size: 4" "(You can also do arrayType numberOfElements)"
 
    Smalltalk at: #ArrayType put: arrayType.

    "Note that array is an instance of CArray, which indirectly is an instance
     of Object, so using array as the receiver will work""."
!
 
another
    array inspect.
    (array at: 0) printNl.
    array at: 0 put: 0.
! !
 

| a |
    a := A new.
    a initialize.
    [
     a inspect.
     (Delay forSeconds: 1) wait.
     a inspect.
     a another.
     'delay ended' printNl.
     ] fork.
    [true] whileTrue: [Processor yield].
!
 
