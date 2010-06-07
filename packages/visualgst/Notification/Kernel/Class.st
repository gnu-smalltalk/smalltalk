Smalltalk.Class extend [

    category: aString [
	"Change the class category to aString"

	<category: 'accessing instances and variables'>

	| oldCategory |
	category = aString ifTrue: [ ^ self ].
	oldCategory := category.
	category ifNotNil: [ self classCategory removeClass: self ].
	category := aString.
	VisualGST.ClassCategory extractCategory: self for: self environment categories into: self environment.
	"VisualGST.SystemChangeNotifier root class: self recategorizedFrom: oldCategory to: category"
    ]
]
