"test ctype instance creation"

Object
	defineCFunc: 'testCString'
	withSelectorArgs: 'testString: aString'
	returning: #void
	args: #(#cObject)
!

| type object cs |
    type := CType baseType: CArray 
		 subType: CStringType
		 numElements: 8.
    "type inspect."
    
    object := type new.
    "object inspect."
    cs := CString value: 'foo'.
    nil testString: cs.
    object at: 1 put: cs.
    
    (object at: 1) inspect.
! 
