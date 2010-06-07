GtkMethodWidget subclass: GtkMethodSUnitWidget [

    category: aString [
        <category: 'accessing'>

        category := aString.
        self classOrMeta methodDictionary ifNil: [
                model clear.
                ^ self].
        model
            item: ((self classOrMeta methodDictionary select: [ :each | self category = '*' or: [ each methodCategory = self category and: [ each selector matchRegex: 'test' from: 1 to: 4 ] ] ])
                                                                                                    asArray sort: [ :a :b | a selector <= b selector ]);
            refresh
    ]
]

