Smalltalk.Metaclass extend [

    newMeta: className environment: aNamespace subclassOf: theSuperclass instanceVariableArray: arrayOfInstVarNames shape: shape classPool: classVarDict poolDictionaries: sharedPoolNames category: categoryName [
	"Private - create a full featured class and install it"

	<category: 'basic'>
	| aClass |
	aClass := self new.
	classVarDict environment: aClass.
	instanceClass := aClass.
	aNamespace at: className put: aClass.
	theSuperclass isNil ifFalse: [theSuperclass addSubclass: aClass].
	Behavior flushCache.
	aClass := aClass
		    superclass: theSuperclass;
		    setName: className;
		    setEnvironment: aNamespace;
		    setInstanceVariables: arrayOfInstVarNames;
		    setInstanceSpec: shape instVars: arrayOfInstVarNames size;
		    setClassVariables: classVarDict;
		    setSharedPools: sharedPoolNames;
		    makeUntrusted: theSuperclass isUntrusted;
		    category: categoryName;
		    yourself.
	VisualGST.SystemChangeNotifier root classAdded: aClass.
	^ aClass
    ]

    name: className environment: aNamespace subclassOf: newSuperclass instanceVariableArray: variableArray shape: shape classPool: classVarDict poolDictionaries: sharedPoolNames category: categoryName [
    "Private - create a full featured class and install it, or change an
     existing one"

    <category: 'basic'>
    | oldClass aClass realShape needToRecompileMetaclasses needToRecompileClasses |
    realShape := shape == #word 
	    ifTrue: [CSymbols.CLongSize = 4 ifTrue: [#uint] ifFalse: [#uint64]]
	    ifFalse: [shape].

    "Look for an existing metaclass"
    aClass := aNamespace hereAt: className ifAbsent: [nil].
    aClass isNil 
        ifTrue: 
	[^self 
	    newMeta: className
	    environment: aNamespace
	    subclassOf: newSuperclass
	    instanceVariableArray: variableArray
	    shape: realShape
	    classPool: classVarDict
	    poolDictionaries: sharedPoolNames
	    category: categoryName].
    aClass isVariable & realShape notNil 
        ifTrue: 
	[aClass shape == realShape 
	    ifFalse: 
	    [SystemExceptions.MutationError 
	        signal: 'Cannot change shape of variable class']].
    newSuperclass isUntrusted & self class isUntrusted not 
        ifTrue: 
	[SystemExceptions.MutationError 
	    signal: 'Cannot move trusted class below untrusted superclass'].
    needToRecompileMetaclasses := false.
    oldClass := aClass copy.
    aClass classPool isNil 
        ifTrue: [aClass setClassVariables: classVarDict]
        ifFalse: 
	[classVarDict keysDo: 
	    [:key | 
	    (aClass classPool includesKey: key) ifFalse: [aClass addClassVarName: key]].
	aClass classPool keys do: 
	    [:aKey | 
	    (classVarDict includesKey: aKey) 
	        ifFalse: 
		[aClass removeClassVarName: aKey.
		needToRecompileMetaclasses := true]]].

    "If instance or indexed variables change, update
     instance variables and instance spec of the class and all its subclasses"
    (needToRecompileClasses := variableArray ~= aClass allInstVarNames 
	    | needToRecompileMetaclasses) | (aClass shape ~~ realShape) 
        ifTrue: 
	[aClass instanceCount > 0 ifTrue: [ObjectMemory globalGarbageCollect].
	aClass
	    updateInstanceVars: variableArray
	    superclass: newSuperclass
	    shape: realShape].

    "Now add/remove pool dictionaries.  FIXME: They may affect name binding,
     so we should probably recompile everything if they change."
    aClass sharedPoolDictionaries isEmpty
        ifTrue: [aClass setSharedPools: sharedPoolNames]
        ifFalse: 
	[sharedPoolNames do: 
	    [:dict | 
	    (aClass sharedPoolDictionaries includes: dict) 
	        ifFalse: [aClass addSharedPool: dict]].
	aClass sharedPoolDictionaries copy do: 
	    [:dict | 
	    (sharedPoolNames includes: dict) 
	        ifFalse: 
		[aClass removeSharedPool: dict.
		needToRecompileMetaclasses := true]]].
    aClass superclass ~~ newSuperclass 
        ifTrue: 
	["Mutate the class if the set of class-instance variables changes."

	self superclass allInstVarNames ~= newSuperclass class allInstVarNames 
	    ifTrue: 
	    [aClass class
	        updateInstanceVars:
		newSuperclass class allInstVarNames,
		aClass class instVarNames
	        superclass: newSuperclass class
	        shape: aClass class shape].

	"Fix references between classes..."
	aClass superclass removeSubclass: aClass.
	newSuperclass addSubclass: aClass.
	aClass superclass: newSuperclass.
	needToRecompileClasses := true.

	"...and between metaclasses..."
	self superclass removeSubclass: self.
	newSuperclass class addSubclass: self.
	self superclass: newSuperclass class.
	needToRecompileMetaclasses := true].
    aClass category: categoryName.

    "Please note that I need to recompile the classes in this sequence;
     otherwise, the same error is propagated to each selector which is compiled
     after an error is detected even though there are no further compilation
     errors. Apparently, there is a bug in the primitive #primCompile:.  This
     can be cleaned up later"
    needToRecompileClasses | needToRecompileMetaclasses 
        ifTrue: 
	[aClass compileAll.
	needToRecompileMetaclasses ifTrue: [aClass class compileAll].
	aClass compileAllSubclasses.
	needToRecompileMetaclasses ifTrue: [aClass class compileAllSubclasses]].
    Behavior flushCache.
    VisualGST.SystemChangeNotifier root classDefinitionChangedFrom: oldClass to: aClass.
    ^aClass
    ]
]

