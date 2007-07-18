"test ctype instance creation"

Object
	defineCFunc: 'testCString'
	withSelectorArgs: 'testString'
	returning: #void
	args: #(#self)
!

| type object cs |
    type := CStringType arrayType: 8.
    "type inspect."
    
    object := type new.
    "object inspect."
    cs := CString value: 'foo'.
    cs testString.
    object at: 1 put: cs.
    (object at: 1) printNl.
! 
