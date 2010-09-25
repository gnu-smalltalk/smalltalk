TestCase subclass: GtkAssistantTest [

    testAssistant [
	<category: 'testing'>

	| assistant |
	assistant := GtkAssistant new.
	self assert: assistant windowTitle isString.
	self assert: assistant aboutTitle isString.
	self assert: (assistant hasChanged or: [ assistant hasChanged not ])
    ]
]

