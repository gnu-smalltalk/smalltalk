TestCase subclass: CompiledMethodTest [

    testOverride [
	<category: 'testing'>

	self assert: (String>>#at:) override.
	self assert: (Object>>#at:) override not.
    ]

    testOverridden [
        <category: 'testing'>

        self assert: (SmallInteger>>#at:) overridden not.
        self assert: (Object>>#at:) overridden
    ]

    testoverrideIcon [
        <category: 'testing'>

	self assert: CompiledMethod overrideIcon isNil not
    ]

    testoverridenIcon [
        <category: 'testing'>

	self assert: CompiledMethod overriddenIcon isNil not
    ]
]

