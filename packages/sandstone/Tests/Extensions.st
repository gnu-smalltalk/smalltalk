TestCase extend [
    assert: expected equals: actual [
	^self assert: (expected = actual)
    ]
]
