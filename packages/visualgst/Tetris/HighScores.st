Object subclass: HighScores [

    | highScores maxScores |

    HighScores class >> newSized: anInteger [
	<category: 'instance creation'>

	^ self new
	    maxScores: anInteger;
	    yourself
    ]

    highScores [
	<category: 'accessing'>

	^ highScores ifNil: [ highScores := OrderedCollection new ]
    ]

    maxScores: anInteger [
	<category: 'accessing'>

	maxScores := anInteger
    ]

    addScore: aScore [
	<category: 'updating'>

	| pos |
	pos := 0.
	self highScores doWithIndex: [ :each :index |
	    each < index ifTrue: [ pos := index ] ].
	pos = 0 ifTrue: [ ^ self ].
	self highScores add: aScore after: pos.
	self highScores size > self maxScores ifTrue: [ self highScores removeLast ]
    ]
]

