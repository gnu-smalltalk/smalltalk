WASnapshot shape: #pointer.

WAFileLibrary class extend [
    compileText: aByteArrayOrString selector: aSymbol [
        "Compiles aByteArrayOrString into a method named aSymbol that returns aByteArrayOrString as a string literal.B
         aSymbol
         ^ aByteArrayOrString"

        <category: 'private'>
        | code |
        code := SeasidePlatformSupport
                    asMethodReturningString: aByteArrayOrString seasideString
                    named: aSymbol.
        SeasidePlatformSupport
            compile: code
            into: self
            classified: self methodCategory
    ]
]

WAResponse extend [
    nextPutAll: aString [
        <category: 'streaming'>
        stream nextPutAll: aString
    ]

    contents [
        <category: 'accessing'>
        ^stream readStream
    ]
]

"these are here because we need to add the Seaside prefix."
Object extend [
    validationError: message [
        <category: '*Seaside-Core'>
        ^Seaside.WAValidationNotification signal: message
    ]

    deprecatedApi: aString [
	<category: '*Seaside-Core'>
	Seaside.WADeprecatedApi signal: aString
    ]
]
