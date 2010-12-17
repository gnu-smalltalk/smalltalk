Command subclass: FakeCommandA [

    item [
	^ 'FakeA'
    ]
]

Command subclass: FakeCommandB [

    item [
        ^ 'FakeB'
    ]
]

MenuBuilder subclass: TestMenuBuilderA [

    TestMenuBuilderA class >> menus [

        ^ {FakeCommandA.
        MenuSeparator.
	FakeCommandB}
    ]

]

TestCase subclass: MenuBuilderTest [

    | accelGroup |

    accelGroup [
        <category: 'accessing'>

        ^ accelGroup ifNil: [ accelGroup := GTK.GtkAccelGroup new ]
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Assistant>'
    ]

    testMenuBuilder [
	<category: 'testing'>

	| menu result |
	menu := TestMenuBuilderA browserBuildOn: self.
	result := #('FakeA' '' 'FakeB').
	1 to: result size do: [ :i |
	    self assert: (menu at: i) getLabel = (result at: i) ]
    ]
]
