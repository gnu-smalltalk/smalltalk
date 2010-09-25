AbstractNamespace class extend [
    NamespaceExtends := nil.

    namespaceExtends [
        ^ NamespaceExtends ifNil: [ NamespaceExtends := WeakKeyIdentityDictionary new ]
    ]
]

AbstractNamespace extend [

    namespaceExtends [
        ^ self class namespaceExtends at: self ifAbsentPut: [ Dictionary new ]
    ]
]

Behavior extend [

    namespace: aNamespace instVarNames: aString [

        aString subStrings do: [ :each |
            self instVarName: each for: aNamespace ]
    ]

    instVarName: aString for: aNamespace [

        self addInstVarName: aString.
        aNamespace namespaceExtends at: self put: aString
    ]
]

Eval [
    Object registerHandler: [ :mth :msg |
            (msg argument namespaceExtends at: (msg arguments at: 2) ifAbsentPut: [WeakSet new ]) add: mth.
            mth methodCategory: (msg arguments at: 3).
            nil ] forPragma: #'namespace:classCategory:category:'.

    Object registerHandler: [ :mth :msg |
            (msg argument namespaceExtends at:  '' ifAbsentPut: [WeakSet new ]) add: mth.
            mth methodCategory: (msg arguments at: 2).
            nil ] forPragma: #'namespace:category:'.
]

