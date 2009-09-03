Command subclass: FileoutNamespaceCommand [

    execute [
	<category: 'command'>

        | namespace stream |
        namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
        namespace := namespaceWidget selectedNamespace.
        self fileoutNamespace: namespace on: (File name: aDirectory) / namespace name
    ]

    fileoutNamespace: aNamespace on: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        stream := FileStream open: (aDirectory / 'self.st') asString mode: FileStream write.
        (NamespaceSource write: aNamespace on: stream)
                header.
        aNamespace do: [ :each |
            (each isNil not and: [ each isClass and: [ each environment = aNamespace ] ])
                    ifTrue: [ stream := FileStream open: (aDirectory / ((each name asString) , '.st')) asString mode: FileStream write.
                            (ClassSource write: each on: stream)
                                source ] ].
        aNamespace allSubspacesDo: [ :space |
            | dir |
            dir := (aDirectory / space name).
            self fileoutNamespace: space on: dir ]
    ]
]

