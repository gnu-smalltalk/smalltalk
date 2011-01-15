Eval [
    "Huge hack for compatibility with the separate GLib package
     in newer gst."
    (GTK definesKey: #GLib) ifTrue: [
        GTK GLib addClassVarName: #GType.
        GTK GLib classPool at: #GType put: GTK GLib.
        Smalltalk at: #GLib put: GTK GLib.
    ]
]

Object extend [

    gtkInspect [
	"Open a GtkInspector on self"
	<category: '*VisualGST'>

	VisualGST.GtkInspector openOn: self
    ]

    inspectorView [
	<category: '*VisualGST'>

	^ VisualGST.GtkObjectInspectorView
    ]

    hasLiterals [
	<category: '*VisualGST'>

	^ false
    ]
]

CompiledMethod class extend [
    ExtensionIcon := nil.
    OverrideIcon := nil.
    OverriddenIcon := nil.

    extensionIcon [
        <category: '*VisualGST'>

        ^ ExtensionIcon ifNil: [ ExtensionIcon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/extension.png') file displayString error: nil ]
    ]

    extensionsIcon: aGdkPixbuf [
        <category: '*VisualGST'>

        ExtensionIcon := aGdkPixbuf
    ]

    overrideIcon [
        <category: '*VisualGST'>

        ^ OverrideIcon ifNil: [ OverrideIcon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/override.png') file displayString error: nil ]
    ]

    overrideIcon: aGdkPixbuf [
        <category: '*VisualGST'>

        OverrideIcon := aGdkPixbuf
    ]

    overriddenIcon [
        <category: '*VisualGST'>

        ^ OverriddenIcon ifNil: [ OverriddenIcon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/overridden.png') file displayString error: nil ]
    ]

    overriddenIcon: aGdkPixbuf [
        <category: '*VisualGST'>

        OverriddenIcon := aGdkPixbuf
    ]
]

CompiledMethod extend [
    override [
	<category: '*VisualGST'>

	self methodClass superclass ifNil: [ ^ false ].
	^ (self methodClass superclass lookupSelector: self selector) isNil not
    ]

    overridden [
        <category: '*VisualGST'>

	| set |
	set := Set new.
	set addAll: self methodClass subclasses.
	set do: [ :each |
	    each methodDictionary ifNotNil: [ :dic | dic at: self selector ifPresent: [ :mth | ^ true ] ] ].
	^ false
    ]

    methodViewIcon [
        <category: '*VisualGST'>

	self methodCategory first = $* ifTrue: [ ^ self class extensionIcon ].
        self overridden ifTrue: [ ^ self class overriddenIcon ].
        self override ifTrue: [ ^ self class overrideIcon ].
        ^ nil
    ]

    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCompiledMethodInspectorView
    ]
]

CompiledBlock extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCompiledBlockInspectorView
    ]

    methodRecompilationSourceString [
	<category: '*VisualGST'>

	^ self method methodRecompilationSourceString
    ]
]

SequenceableCollection extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkSequenceableCollectionInspectorView
    ]
]

Set extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkSetInspectorView
    ]
]

Dictionary extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkDictionaryInspectorView
    ]
]

Character extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCharacterInspectorView
    ]
]

Integer extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkIntegerInspectorView
    ]
]

Float extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkFloatInspectorView
    ]
]

Symbol extend [
    hasLiterals [
	<category: '*VisualGST'>

	^ true
    ]

    symbolFromliterals [
	<category: '*VisualGST'>

	^ {self}
    ]
]

Array extend [
    hasLiterals [
	<category: '*VisualGST'>

	self do: [ :each |
	    each hasLiterals ifTrue: [ ^ true ] ].
	^ false
    ]

    symbolFromliterals [
        <category: '*VisualGST'>

	| result |
	result := OrderedCollection new.
	self do: [ :each |
	    each hasLiterals ifTrue: [ result add: each symbolFromliterals first ] ].
        ^ result
    ]
]

Class extend [

    subclass: classNameString environment: aNamespace [
	<category: '*VisualGST'>

        "Define a subclass of the receiver with the given name.  If the class
	 is already defined, don't modify its instance or class variables
         but still, if necessary, recompile everything needed."

	| meta |
	KernelInitialized ifFalse: [^Smalltalk at: classNameString].
	meta := self metaclassFor: classNameString.
	^ meta 
	    name: classNameString
	    environment: aNamespace
	    subclassOf: self
    ]
]

CompiledCode extend [

    hasLiterals [
	<category: '*VisualGST'>

	^ self literals isEmpty not
    ]

    isSendingWithSpecialSelector: aByteCode [
	<category: '*VisualGST'>

	^ aByteCode <= 31
    ]

    specialSelectorSended: aByteCode and: anOperand [
	<category: '*VisualGST'>

	(self isSendingWithSpecialSelector: aByteCode) ifFalse: [ ^ self error: 'bad byte code' ].
	aByteCode <= 26 ifTrue: [ ^ self class specialSelectors at: aByteCode + 1 ].
        (aByteCode = 30 or: [ aByteCode = 31 ]) ifTrue: [ ^ self class specialSelectors at: anOperand + 1 ].
    ]

    extractSpecialSelectors [
	<category: '*VisualGST'>

	| result |
	result := Set new.
        self allByteCodeIndicesDo: [ :i :bytecode :operand |
	    (self isSendingWithSpecialSelector: bytecode) ifTrue: [
		result add: (self specialSelectorSended: bytecode and: operand) ] ].
	^ result
    ]

    literalsAndSpecialSelectors [
	<category: '*VisualGST'>

	"Answer whether the receiver refers to the given object"

        | result |
	result := Set new.
	self literalsDo: [ :each |
	    each hasLiterals ifTrue: [ result addAll: each symbolFromliterals ] ].

        ^ result + self extractSpecialSelectors
    ]

    literalsAndSpecialSelectorsDo: aOneArgBlock [
	<category: '*VisualGST'>

	self literalsAndSpecialSelectors do: aOneArgBlock
    ]

]

CompiledBlock extend [
    symbolFromliterals [
	<category: '*VisualGST'>

	^ self extractSpecialSelectors
    ]
]

MethodContext extend [
    variables [
        <category: '*VisualGST'>

        | variables method |
        method := self method method parserClass parseMethod: self method method methodSourceString onError: [ :aString :position | ^ variables:= #() ].
        (variables := method argumentNames asOrderedCollection) addAll: method body temporaryNames.
        ^ variables
    ]
]

BlockContext extend [
    variables [
        <category: '*VisualGST'>

        | variables method |
        method := self method method parserClass parseMethod: self method method methodSourceString.
        variables := method argumentNames,  method body temporaryNames.
        ^ variables
    ]
]

ContextPart extend [
    parentContextAt: anInteger [
	<category: '*VisualGST'>

	| ctxt i |
	anInteger <= 0 ifTrue: [ self error: 'Error indice <= 0' ].
	self parentContext ifNil: [ self error: 'Error indice too high' ].
	anInteger = 1 ifTrue: [ ^ self ].
	i := 2.
	ctxt := self parentContext.
	[ i < anInteger and: [ ctxt parentContext isNil not ] ] whileTrue: [
	    ctxt := ctxt parentContext.
	    i := i + 1 ].
	^ i = anInteger 
	    ifTrue: [ ctxt ]
	    ifFalse: [ self error: 'Error indice too high' ]
    ]

    variables [
	<category: '*VisualGST'>

	^ 1 to: self numArgs + self numTemps collect: [ :each |
	    each displayString ]
    ]

    variablesDo: aBlock [
	<category: '*VisualGST'>

	^ self variables do: aBlock
    ]

    stackInspectorView [
        <category: '*VisualGST'>

        ^ GtkStackInspectorView
    ]
]

Debugger extend [

    receiver [
	<category: '*VisualGST'>

	^ self suspendedContext receiver
    ]

    myStepInto [
        "Run to the end of the current line in the inferior process or to the
         next message send."

	"TODO: Stop when affectation (get the current bytecode)"
        <category: '*VisualGST'>
        | context |
        context := self suspendedContext.

        [ self stepBytecode.
          self suspendedContext == context ]
                whileTrue
    ]

    myStep [
        "Run to the end of the current line in the inferior process, skipping
         over message sends."

	"TODO: Stop when affectation (get the current bytecode)"
        <category: '*VisualGST'>
        | context |
        context := self suspendedContext.

        [ self stepBytecode.
         (self suspendedContext notNil and: [ self suspendedContext parentContext == context ])
                ifTrue: [ self finish: self suspendedContext. ^ self ].
         self suspendedContext == context ]
                whileTrue
    ]
]

Behavior extend [

    debuggerClass [
	<category: '*VisualGST'>

	"^ nil"
	^ VisualGST.GtkDebugger
    ]
]

VariableBinding extend [

    hasLiterals [
	<category: '*VisualGST'>

	^ true
    ]

    symbolFromliterals [
	<category: '*VisualGST'>

	^ {self key}
    ]
]

GTK.GtkButton class extend [

    createButton: aStockId [
        <category: 'instance creation'>

        | image |
        image := GTK.GtkImage newFromStock: aStockId size: GTK.Gtk gtkIconSizeMenu.
        ^ (GTK.GtkButton new)
                setImage: image;
                setRelief: GTK.Gtk gtkReliefNone;
                yourself
    ]

    closeButton [
	<category: 'instance creation'>

        ^ self createButton: GTK.Gtk gtkStockClose
    ]

    previousButton [
	<category: 'instance creation'>

        ^ self createButton: GTK.Gtk gtkStockGoBack
    ]

    nextButton [
	<category: 'instance creation'>

         ^ self createButton: GTK.Gtk gtkStockGoForward
    ]

    replaceButton [
        <category: 'instance creation'>

         ^ self createButton: GTK.Gtk gtkStockFindAndReplace
    ]
]

Metaclass extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self instanceClass name
    ]
]

AbstractNamespace extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self displayString asSymbol
    ]
]

Symbol extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self
    ]
]

CharacterArray extend [

    deindexOf: aCharacterArray matchCase: aBoolean startingAt: anIndex [
	"Answer an Interval of indices in the receiver which match the aCharacterArray
	 pattern. # in aCharacterArray means 'match any character', * in aCharacterArray means
	 'match any sequence of characters'. The first item of the returned interval
	 is >= anIndex. If aBoolean is false, the search is case-insensitive, 
	 else it is case-sensitive. If no Interval matches the pattern, answer nil."

	<category: '*VisualGST'>
	| result |
	aBoolean 
	    ifFalse: 
		[ ^ self asLowercase 
		   deindexOf: aCharacterArray asLowercase
		   matchCase: true
		   startingAt: anIndex ].
	1 to: anIndex do: 
		[ :i | 
		    result := aCharacterArray 
				matchSubstring: 1
				in: self
				at: anIndex - i + 1.
		    result notNil ifTrue: [ ^ anIndex - i + 1 to: result ] ].
	^ nil
    ]
]

STInST.RBParser class extend [

    selectedSymbol: aString [
	<category: '*VisualGST'>

        | stream parser node |
        stream := aString readStream.
        parser := STInST.RBBracketedMethodParser new.
        parser errorBlock: [ :message :position | ^ nil ].
        parser scanner: (parser scannerClass on: stream errorBlock: parser errorBlock).
        node := parser parseExpression.
        node := node bestNodeFor: (1 to: aString size).
        [ node isNil ifTrue: [ ^ nil ].
          node isMessage] whileFalse: [ node := node parent ].
        ^ node selector
    ]	
]

GTK.GtkTreeModel class extend [
    createModelWith: anArray [
        <category: '*VisualGST'>

        | model |
        model := OrderedCollection new.
        anArray do: [ :each | model addAll: (each collect: [ :elem | elem kind ]) ].
        model addLast: VisualGST.GtkColumnOOPType kind.
        ^ self new: model size varargs: model asArray
    ]
]

GTK.GtkListStore class extend [
    createModelWith: anArray [
        <category: '*VisualGST'>

        | model |
        model := OrderedCollection new.
        anArray do: [ :each | model addAll: (each collect: [ :elem | elem kind ]) ].
        model addLast: VisualGST.GtkColumnOOPType kind.
        ^ self new: model size varargs: model asArray
    ]
]

GTK.GtkTreeStore class extend [
    createModelWith: anArray [
        <category: '*VisualGST'>

        | model |
        model := OrderedCollection new.
        anArray do: [ :each | model addAll: (each collect: [ :elem | elem kind ]) ].
        model addLast: VisualGST.GtkColumnOOPType kind.
        ^ self new: model size varargs: model asArray
    ]
]

GTK.GtkTreeView class extend [

    createModel: aGtkStoreClass with: anArray [
	<category: '*VisualGST'>

	^ self newWithModel: (aGtkStoreClass createModelWith: anArray)
    ]

    createTreeViewWith: anArray [
	<category: '*VisualGST'>

        ^ self createModel: GtkTreeStore with: anArray
    ]

    createListViewWith: anArray [
        <category: '*VisualGST'>

        ^ self createModel: GtkListStore with: anArray
    ]

    createColumnsOn: aGtkTreeView with: anArray [
        <category: '*VisualGST'>

        | colView i render |
        i := 0.
        anArray do: [ :each |
            colView := GtkTreeViewColumn new.
            each do: [ :column |
            column isVisible ifTrue: [
                colView
                    packStart: (render := column cellRenderer new) expand: false;
                    addAttribute: render attribute: column kindName column: i.
                column hasTitle ifTrue: [ colView setTitle: column title ].
                i := i + 1 ] ].
            aGtkTreeView insertColumn: colView position: -1 ]
    ]

    createListWithModel: anArray [
        <category: '*VisualGST'>

        | view |
        view := self createListViewWith: anArray.
        self createColumnsOn: view with: anArray.
	^ view 
    ]

    createTreeWithModel: anArray [
	<category: '*VisualGST'>

	| view |
        view := self createTreeViewWith: anArray.
        self createColumnsOn: view with: anArray.
	^ view
    ]
]

GTK.GtkTreeView extend [
    | model |

    model: aGtkModel [
	<category: 'accessing'>

	model := aGtkModel
    ]

    model [
	<category: 'accessing'>

	^ model
    ]

    selection [
	<category: 'accessing'>

        | iter string |
        (iter := self selectedIter) ifNil: [ ^ self error: 'nothing is selected' ].
	^ (self getModel at: iter) last
    ]

    selections [
	<category: 'accessing'>

	| glist result |
	result := OrderedCollection new.
	(glist := self getSelection getSelectedRows: nil) ifNil: [ ^ result ].
	glist do: [ :each | | iter path |
	    path := each castTo: GTK.GtkTreePath type.
	    iter := self getModel getIter: path.
	    result add: ((self getModel at: iter) last) ].
	^ result
    ]

    select: anObject [
	<category: 'accessing'>

        self getSelection unselectAll.
	self getModel do: [ :elem :iter |
	    elem last = anObject ifTrue: [
                    self scrollToCell: (self getModel getPath: iter) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
                    ^ self getSelection selectIter: iter ] ].
    ]

    selectNth: anInteger [
	<category: 'accessing'>

        | path iter |
        self getSelection unselectAll.
        anInteger = 0 ifTrue: [^self].
        path := GtkTreePath newFromIndices: {anInteger - 1. -1}.
	(self getModel getIter: path) isNil ifTrue: [^self].
        self scrollToCell: path column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        self getSelection selectPath: path
    ]

    selectFirstItem [
	<category: 'accessing'>

	| selection |
	(selection := self getSelection) unselectAll.
        selection unselectAll.
        selection selectIter: self getModel getIterFirst
    ]

    selectLastItem [
	<category: 'accessing'>

	| selection |
	(selection := self getSelection) unselectAll.	
	selection unselectAll.
        selection selectIter: self getModel getIterLast
    ]
]

GTK.GtkDialog extend [

    showModal [
        <category: '*VisualGST'>

        self
            setModal: true;
            showAll 
    ]

    destroy: aGtkDialog [
        <category: '*VisualGST'>

	self destroy
    ]

    showModalOnAnswer: aBlock [
        <category: '*VisualGST'>

        self
            setModal: true;
            connectSignal: 'response' to: aBlock selector: #cull:cull:;
            showAll 
    ]
    
    showModalDestroy [
        <category: '*VisualGST'>

        self
            setModal: true;
            connectSignal: 'response' to: self selector: #destroy:;
            showAll 
    ]

    showOnAnswer: aBlock [
        <category: '*VisualGST'>

        self
            setModal: false;
            connectSignal: 'response' to: aBlock selector: #cull:cull:;
            showAll 
    ]
]

GTK.GtkWidget extend [
    getFocusChild [
        <category: '*VisualGST'>
        ^nil
    ]
]

GTK.GtkPaned class extend [

    addAll: anArray [

	^ self addAll: anArray from: 1
    ]

    addAll: anArray from: anInteger [

        ^ anArray size - anInteger = 0 
                ifTrue: [ self new
                                pack1: (anArray at: anInteger) resize: true shrink: true;
                                yourself ]
                ifFalse: [ 
                    anArray size - anInteger > 1 ifTrue: [ 
					    self new
                                                    pack1: (anArray at: anInteger) resize: true shrink: true;
                                                    pack2: (self addAll: anArray from: anInteger + 1) resize: true shrink: false;
                                                    yourself ]
                                    ifFalse: [ self new
                                                    pack1: (anArray at: anInteger) resize: true shrink: true;
                                                    pack2: (anArray at: anInteger + 1) resize: true shrink: false;
                                                    yourself ] ]
    ]

]

GTK.GtkScrolledWindow class extend [

    withViewport: aGtkWidget [
	<category: 'instance creation'>

	^ (GTK.GtkScrolledWindow new: nil vadjustment: nil)
	    addWithViewport: aGtkWidget;
	    setPolicy: GTK.Gtk gtkPolicyAutomatic vscrollbarPolicy: GTK.Gtk gtkPolicyAutomatic;
	    yourself
    ]
]

Smalltalk.PackageLoader class extend [
    root [
	<category: 'accessing'>

	^ root
    ]
]
