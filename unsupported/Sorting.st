| k a |
k := Symbol allInstances.
a := k collect: [ :each | each asString hash ].
^Smalltalk at: #test put: a!

ObjectMemory compact!

test asSortedCollection inject: '' into: [ :old :each |
	old > each ifTrue: [ old printNl. each printNl ]. each]!
