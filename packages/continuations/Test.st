


TestCase subclass: ContinuationTest [
    | tmp tmp2 |
    
    <comment: nil>
    <category: 'Seaside-Seaside-Continuations'>

    callcc: aBlock [
	<category: 'as yet unclassified'>
	^Continuation currentDo: aBlock
    ]

    testBlockEscape [
	<category: 'as yet unclassified'>
	| x |
	tmp := 0.
	x := 
		[tmp := tmp + 1.
		tmp2 value].
	self callcc: 
		[:cc | 
		tmp2 := cc.
		x value].
	tmp2 := [].
	x value.
	self assert: tmp = 2
    ]

    testBlockTemps [
	<category: 'as yet unclassified'>
	| y |
	#(1 2 3) do: 
		[:i | 
		| x |
		x := i.
		tmp 
		    ifNil: [tmp2 := self callcc: 
					[:cc | 
					tmp := cc.
					[:q | ]]].
		tmp2 value: x.
		x := 17].
	y := self callcc: 
			[:cc | 
			tmp value: cc.
			42].
	self assert: y = 1
    ]

    testBlockVars [
	<category: 'as yet unclassified'>
	| continuation |
	tmp := 0.
	tmp := (self callcc: 
			[:cc | 
			continuation := cc.
			0]) + tmp.
	tmp2 isNil 
	    ifFalse: [tmp2 value]
	    ifTrue: 
		[#(1 2 3) 
		    do: [:i | self callcc: 
				[:cc | 
				tmp2 := cc.
				continuation value: i]]].
	self assert: tmp = 6
    ]

    testMethodTemps [
	<category: 'as yet unclassified'>
	| i continuation |
	i := 0.
	i := i + (self callcc: 
				[:cc | 
				continuation := cc.
				1]).
	self assert: i ~= 3.
	i = 2 ifFalse: [continuation value: 2]
    ]

    testSimpleCallCC [
	<category: 'as yet unclassified'>
	| x continuation |
	x := self callcc: 
			[:cc | 
			continuation := cc.
			false].
	x ifFalse: [continuation value: true].
	self assert: x
    ]

    testSimplestCallCC [
	<category: 'as yet unclassified'>
	| x |
	x := self callcc: [:cc | cc value: true].
	self assert: x
    ]
]
