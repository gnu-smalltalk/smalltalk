TestCase subclass: AmbTest [
    | amb |
    
    <comment: nil>
    <category: 'Seaside-Seaside-Continuations'>

    setUp [
	<category: 'as yet unclassified'>
	amb := Amb new
    ]

    testAllValuesAboveFive [
	<category: 'as yet unclassified'>
	| x results |
	results := amb allValues: 
			[x := amb oneOf: (1 to: 10).
			amb assert: x > 5.
			x].
	self assert: results = #(6 7 8 9 10)
    ]

    testMaybe [
	<category: 'as yet unclassified'>
	| x y z |
	x := amb maybe.
	y := amb maybe.
	z := amb maybe not.
	amb deny: x = y.
	amb deny: x = z.
	self assert: x.
	self deny: y.
	self deny: z
    ]

    testPickANumber [
	<category: 'as yet unclassified'>
	self assert: self pickANumber = 1
    ]

    testPickANumberAboveFive [
	<category: 'as yet unclassified'>
	| x |
	x := self pickANumber.
	amb assert: x > 5.
	self assert: x = 6
    ]

    testFactoring [
	<category: 'as yet unclassified'>
	self assert: (self factors: 7) = #(7).
	self assert: (self factors: 8) = #(2 2 2).
	self assert: (self factors: 84) = #(2 2 3 7)
    ]

    testSetIntersection [
	<category: 'as yet unclassified'>
	| x |
	x := amb allValues: 
			[| x y |
			x := amb oneOf: #(#one #two #three #four).
			y := amb oneOf: #(#two #four #six #eight).
			amb assert: x = y.
			x].
	self assert: x size = 2.
	self assert: (x includes: #two).
	self assert: (x includes: #four).
	x := amb allOf: #(#one #two #three #four)
		    satisfying: [:x | x = (amb oneOf: #(#two #four #six #eight))].
	self assert: x size = 2.
	self assert: (x includes: #two).
	self assert: (x includes: #four).
	x := amb allOf: #(#one #two #three #four)
		    satisfying: [:x | amb oneOf: #(#two #four #six #eight) satisfies: [:y | x = y]].
	self assert: x size = 2.
	self assert: (x includes: #two).
	self assert: (x includes: #four)
    ]

    testSicpLogicProblem [
	"Baker, Cooper, Fletcher, Miller, and Smith live on different floors of an apartment house that contains only five floors. Baker does not live on the top floor. Cooper does not live on the bottom floor. Fletcher does not live on either the top or the bottom floor. Miller lives on a higher floor than does Cooper. Smith does not live on a floor adjacent to Fletcher's. Fletcher does not live on a floor adjacent to Cooper's. Where does everyone live?"

	"This implementation is too slow - uncomment to actually run it."

	<category: 'as yet unclassified'>
	| baker cooper fletcher miller smith |
	baker := amb oneOf: (1 to: 5).
	cooper := amb oneOf: (1 to: 5).
	fletcher := amb oneOf: (1 to: 5).
	miller := amb oneOf: (1 to: 5).
	smith := amb oneOf: (1 to: 5).
	amb 
	    assert: ((Set new)
		    add: baker;
		    add: cooper;
		    add: fletcher;
		    add: miller;
		    add: smith;
		    size) = 5.
	amb deny: baker = 5.
	amb deny: cooper = 1.
	amb deny: fletcher = 5.
	amb deny: fletcher = 1.
	amb assert: miller > cooper.
	amb deny: (smith - fletcher) abs = 1.
	amb deny: (fletcher - cooper) abs = 1.
	self assert: baker = 3.
	self assert: cooper = 2.
	self assert: fletcher = 4.
	self assert: miller = 5.
	self assert: smith = 1
    ]

    testSicpLogicProblemFaster [
	"Baker, Cooper, Fletcher, Miller, and Smith live on different floors
	 of an apartment house that contains only five floors. Baker does
	 not live on the top floor. Cooper does not live on the bottom
	 floor. Fletcher does not live on either the top or the bottom
	 floor. Miller lives on a higher floor than does Cooper. Smith does
	 not live on a floor adjacent to Fletcher's. Fletcher does not live
	 on a floor adjacent to Cooper's. Where does everyone live?"

	<category: 'as yet unclassified'>
	| baker cooper fletcher miller smith |
	fletcher := amb oneOf: (1 to: 5).
	amb deny: fletcher = 5.
	amb deny: fletcher = 1.
	smith := amb oneOf: (1 to: 5).
	amb deny: (smith - fletcher) abs = 1.
	cooper := amb oneOf: (1 to: 5).
	amb deny: cooper = 1.
	amb deny: (fletcher - cooper) abs = 1.
	miller := amb oneOf: (1 to: 5).
	amb assert: miller > cooper.
	baker := amb oneOf: (1 to: 5).
	amb deny: baker = 5.
	amb 
	    assert: ((Set new)
		    add: baker;
		    add: cooper;
		    add: fletcher;
		    add: miller;
		    add: smith;
		    size) = 5.
	self assert: baker = 3.
	self assert: cooper = 2.
	self assert: fletcher = 4.
	self assert: miller = 5.
	self assert: smith = 1
    ]

    testSolveAnEquation [
	<category: 'as yet unclassified'>
	| x y |
	x := amb oneOf: (1 to: 10).
	y := amb oneOf: (1 to: 10).
	amb assert: y * x = 42.
	self assert: x = 6.
	self assert: y = 7
    ]

    testAlways [
	<category: 'as yet unclassified'>
	self 
	    assert: (amb always: 
			[| x |
			x := amb maybe.
			amb assert: x | x not]).
	self deny: (amb always: 
			[| x |
			x := amb maybe.
			amb assert: x])
    ]

    testCountValues [
	<category: 'as yet unclassified'>
	self assert: (amb countValues: [self queens: 3]) = 0.
	self assert: (amb countValues: [self queens: 4]) = 2
    ]

    testHasValue [
	<category: 'as yet unclassified'>
	self deny: (amb hasValue: [self queens: 3]).
	self assert: (amb hasValue: [self queens: 4])
    ]

    testNoneOfSatisfies [
	<category: 'as yet unclassified'>
	self deny: (self primeNoneOf: 8).
	self assert: (self primeNoneOf: 7)
    ]

    testAllOfSatisfy [
	<category: 'as yet unclassified'>
	self deny: (self primeAllOf: 8).
	self assert: (self primeAllOf: 7).
	self assert: (amb allOf: (2 to: 4)
		    satisfy: [:x | amb allOf: (5 to: 7) satisfy: [:y | x < y]])
    ]

    testOneOfSatisfies [
	<category: 'as yet unclassified'>
	self deny: (self primeOneOf: 8).
	self assert: (self primeOneOf: 7).
	self assert: (amb oneOf: (4 to: 6)
		    satisfies: [:x | amb oneOf: (2 to: 4) satisfies: [:y | x = y]])
    ]

    testDoubleNegation [
	"This fails -- it is clear if you consider that..."

	<category: 'as yet unclassified'>
	self deny: (amb noneOf: (5 to: 7)
		    satisfies: [:x | amb noneOf: (2 to: 4) satisfies: [:y | x < y]]).

	"... this passes, and is equivalent to the above."
	self assert: (amb oneOf: (5 to: 7)
		    satisfies: [:x | amb noneOf: (2 to: 4) satisfies: [:y | x < y]]).

	"But what we meant was actually this."
	self assert: (amb noneOf: (5 to: 7)
		    satisfies: [:x | amb oneOf: (2 to: 4) satisfies: [:y | x < y]])
    ]

    testQueens [
	<category: 'as yet unclassified'>
	| results |
	results := amb allValues: [self queens: 5].
	self assert: results size = 10.
	self assert: (results includes: #(1 3 5 2 4)).
	self assert: (results includes: #(5 3 1 4 2)).
	self deny: (results includes: #(1 2 3 4 5)).
	self assert: (results allSatisfy: [:x | x asSet size = 5])
    ]

    pickANumber [
	<category: 'problems'>
	^self pickANumberGreaterThan: 0
    ]

    pickANumberGreaterThan: aNumber [
	<category: 'problems'>
	^amb valueOf: [aNumber + 1] or: [self pickANumberGreaterThan: aNumber + 1]
    ]

    factors: n [
	<category: 'problems'>
	| lastDivisor check |
	n <= 2 ifTrue: [^{n}].
	lastDivisor := ValueHolder with: 1.
	^amb allValues: 
		[| divisor factor |
		divisor := amb oneOf: (2 to: n).
		amb assert: n \\ divisor == 0.
		amb assert: divisor \\ lastDivisor value == 0.
		factor := divisor / lastDivisor value.
		lastDivisor value: divisor.
		factor]
    ]

    primeOneOf: n [
	<category: 'problems'>
	| limit |
	limit := n sqrt ceiling.
	^(amb oneOf: (2 to: limit) satisfies: [:x | n \\ x = 0]) not
    ]

    primeNoneOf: n [
	<category: 'problems'>
	| limit |
	limit := n sqrt ceiling.
	^amb noneOf: (2 to: limit) satisfies: [:x | n \\ x = 0]
    ]

    primeAllOf: n [
	<category: 'problems'>
	| limit |
	limit := n sqrt ceiling.
	^amb allOf: (2 to: limit) satisfy: [:x | n \\ x > 0]
    ]

    queens: size [
	<category: 'problems'>
	| board x y results |
	board := (1 to: size) collect: [:a | amb oneOf: (1 to: size)].
	1 to: size
	    do: 
		[:i | 
		x := board at: i.
		1 to: i - 1
		    do: 
			[:j | 
			y := board at: j.
			amb assert: x ~= y.
			amb assert: (x - y) abs ~= (i - j) abs]].
	^board copy
    ]
]
