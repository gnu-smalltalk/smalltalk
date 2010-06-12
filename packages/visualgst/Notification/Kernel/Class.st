Smalltalk.Class extend [

    category: aString [
	"Change the class category to aString"

	<category: 'accessing instances and variables'>

	| oldCategory |
	category = aString ifTrue: [ ^ self ].
	oldCategory := category.
	category := aString.
	VisualGST.SystemChangeNotifier root class: self recategorizedFrom: oldCategory to: category
    ]
]
