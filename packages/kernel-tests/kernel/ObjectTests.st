Object
    variableSubclass: #Bar
    instanceVariableNames: 'a b c d e f'
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCase subclass: TestObject [

    testAccessing [
        | object |
        object := Bar new: 5.

        1 to: 5 do: [ :i | self assert: (object instVarAt: i) isNil ].
        self assert: object size = 5.
        1 to: 5 do: [ :i | self assert: (object at: i) isNil ].
        1 to: 11 do: [ :i | self assert: (object instVarAt: i) isNil ].
        0 to: -5 do: [ :i | self should: [ object at: i ] raise: SystemExceptions.IndexOutOfRange ].

        1 to: 5 do: [ :i | object at: i put: i * 5 ].
        1 to: 5 do: [ :i | self assert: (object instVarAt: i + 6) = (i * 5) ].
        1 to: 5 do: [ :i | self assert: (object at: i) = (i * 5) ].
        0 to: -5 do: [ :i | self should: [ object at: i ] raise: SystemExceptions.IndexOutOfRange ].
    ]
]
