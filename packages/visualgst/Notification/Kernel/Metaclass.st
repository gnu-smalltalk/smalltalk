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

]

