Object subclass: Score [

    Score class >> score: anInteger [
	<category: 'instance creation'>

	^ self new
	    score: anInteger;
	    yourself
    ]

    | score |

    score: anInteger [
	<category: 'accessing'>

	score := anInteger
    ]

    score [
	<category: 'acccessing'>

	^ score
    ]
]

