"Testing out C callout interface"

| arrayType array |

    arrayType := CArrayCType elementType: CLongType
			    numberOfElements: 4.

    array := arrayType new.  "create (malloc) a C object of the right size"

    array at: 0 put: 1.     " be more creative than I am about loading it"
    array at: 1 put: 2.
    array at: 2 put: 3.
    array at: 3 put: 3.

    'foo' printNl.

    (array at: 0 ) print.
    (array at: 3 ) printNl.
    (array at: 4 ) printNl.

    "Note that array is an instance of CArray, which indirectly is an instance
     of Object, so using array as the receiver will work"
!
