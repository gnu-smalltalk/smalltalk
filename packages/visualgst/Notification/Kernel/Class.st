Smalltalk.Class extend [

    category: aString [
	"Change the class category to aString"

	<category: 'accessing instances and variables'>

	| oldCategory |
	oldCategory := category.
	category := aString.
	VisualGST.SystemChangeNotifier uniqueInstance class: self recategorizedFrom: oldCategory to: category
    ]
]
