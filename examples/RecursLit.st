!Object methodsFor: 'testing CompiledMethod accesses'!

containsLiteral: anObject
    ^self = anObject
! !

!Collection methodsFor: 'testing CompiledMethod accesses'!

containsLiteral: anObject
    self == anObject ifTrue: [^true].
    self do: [ :each |
	each == anObject ifTrue: [ ^true ]
    ].
    ^false
! !

!CompiledMethod methodsFor: 'testing accesses'!

containsLiteral: anObject
    | lit |
    1 to: self numLiterals do: [ :i |
	lit := self literalAt: i.
	(lit containsLiteral: anObject) ifTrue: [^true ].
    ].
    ^false
! !
