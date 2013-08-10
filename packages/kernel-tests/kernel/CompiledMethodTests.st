TestCase subclass: TestCompiledMethod [

    | barClass fooClass |

    setUp [
        <category: 'setup'>

        barClass := Behavior new.
        fooClass := Behavior new.
        fooClass compile: '
    fakeDeepCopy [
        <category: ''copying''>
        | class aCopy num |
        class := self class.
        aCopy := self shallowCopy.
        class isPointers
            ifTrue: [num := class instSize + self basicSize]
            ifFalse: [num := class instSize].

        "copy the instance variables (if any)"
        1 to: num do: [:i | aCopy instVarAt: i put: (self instVarAt: i) copy].
        [ :aCopy | aCopy
            fixBlockInformation;
            fixDebugInformation: self.
        ^aCopy ] value: aCopy.
        [ :bla | bla value ] value: 123
    ]'.
        fooClass compile:
'optimized_1 [ ^ #(1 2 3) ]'.
        fooClass compile:
'primitive_1 [ <primitive: ', VMpr_Object_shallowCopy asString, '> ]'.

    ]

    check: old_method with: new_method [
        <category: 'private'>

        self assert: old_method ~~ new_method.
        self assert: old_method literals ~~ new_method literals.
        self assert: old_method getHeader == new_method getHeader.
        self assert: old_method descriptor ~~ new_method descriptor.
        self assert: old_method descriptor debugInformation ~~ new_method descriptor debugInformation.

        self assert: old_method basicSize == new_method basicSize.
        1 to: old_method basicSize do: [ :i |
            self assert: (old_method at: i) == (new_method at: i) ].

        self assert: old_method descriptor debugInformation size = new_method descriptor debugInformation size.
        old_method descriptor debugInformation keysAndValuesDo: [ :key :value |
            self should: [ new_method descriptor debugInformation at: key ] raise: SystemExceptions.NotFound ]. " should fail because the method and all the blocks are copied "

        self assert: (new_method temporaries) = #(#class #aCopy #num).
        new_method allBlocksDo: [ :each | self assert: (each method == new_method) ].
    ]

    testCopy [
        <category: 'testing'>

        | old_method new_method |
        old_method := fooClass>>#fakeDeepCopy.
        new_method := old_method deepCopy.

        self check: old_method with: new_method.
    ]

    testDeepCopy [
        <category: 'testing'>

        | old_method new_method |
        old_method := fooClass>>#fakeDeepCopy.
        new_method := old_method deepCopy.

        self check: old_method with: new_method.
    ]

    testWithNewMethodClass [
        <category: 'testing'>

        | old_method new_method |
        old_method := fooClass>>#fakeDeepCopy.
        new_method := old_method withNewMethodClass: fooClass.

        self assert: new_method == old_method.

        old_method := fooClass>>#fakeDeepCopy.
        new_method := old_method withNewMethodClass: barClass.

        self check: old_method with: new_method.
    ]

    testPrimitive [
        <category: 'testing'>

        | method |
        method := fooClass>>#optimized_1.
        self assert: method primitive = 0.

        method := fooClass>>#primitive_1.
        self assert: method primitive = VMpr_Object_shallowCopy.
    ]

    testSyntax [
        <category: 'testing'>

        | method |
        method := fooClass>>#optimized_1.
        self assert: method isOldSyntax not.

        method := fooClass>>#primitive_1.
        self assert: method isOldSyntax not.
    ]
]
