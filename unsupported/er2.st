!Object class methodsFor: 'testing'!

testInternal: aString block: aBlock
    '        in test internal' printNl.
    self compileString: aString
	ifError: aBlock.
    '        leaving test internal' printNl
!

testMiddle: aString block: aBlock
    '    in test middle' printNl.
    self testInternal: aString block: aBlock.
    '    leaving test middle' printNl
!

testExternal: aString
    '>>>begin' printNl.
    self testMiddle: aString 
	 block: [:a :b :c | a printNl.
			    b printNl.
			    c printNl.
			    ^#foobar ].
    '<<<end' printNl.
!

myTest: aString
    '[[[' printNl.
    self testExternal: aString.
    ']]]' printNl.
! !

Object compileString: 'foo  3+'!

Object testExternal: 'foo 3+'!
Object myTest: 'foo 3+'!

'test message' printNl!
