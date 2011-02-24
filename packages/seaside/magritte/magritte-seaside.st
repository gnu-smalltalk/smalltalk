Magritte import: Seaside.

MAVisitor subclass: MAComponentRenderer [
    | component html errors group |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Renderer'>

    MAComponentRenderer class >> component: aComponent on: aRenderer [
	<category: 'instance creation'>
	^self new component: aComponent on: aRenderer
    ]

    childAt: aDescription [
	<category: 'private'>
	^component childAt: aDescription
    ]

    classFor: aDescription [
	<category: 'private'>
	| classes |
	classes := OrderedCollection withAll: aDescription cssClasses.
	aDescription isReadonly ifTrue: [classes add: 'readonly'].
	aDescription isRequired ifTrue: [classes add: 'required'].
	(self hasError: aDescription) ifTrue: [classes add: 'error'].
	^classes reduce: [:a :b | a , ' ' , b]
    ]

    component: aComponent on: aRenderer [
	<category: 'visiting'>
	self
	    setComponent: aComponent;
	    setRenderer: aRenderer.
	self visit: aComponent description
    ]

    hasError: aDescription [
	<category: 'testing'>
	errors ifNotNil: [^errors includes: aDescription].
	errors := IdentitySet new.
	component errors do: 
		[:each | 
		errors add: (each tag isDescription 
			    ifTrue: [each tag]
			    ifFalse: [component description])].
	^self hasError: aDescription
    ]

    renderContainer: aDescription [
	<category: 'rendering'>
	self visitAll: (aDescription 
		    select: [:each | each isVisible and: [each componentClass notNil]])
    ]

    renderControl: aDescription [
	<category: 'rendering'>
	html render: (self childAt: aDescription)
    ]

    renderElement: aDescription [
	<category: 'rendering'>
	aDescription group = group ifFalse: [self renderGroup: aDescription].
	self renderLabel: aDescription.
	self renderControl: aDescription
    ]

    renderGroup: aDescription [
	<category: 'rendering'>
	group := aDescription group
    ]

    renderLabel: aDescription [
	<category: 'rendering'>
	| label |
	aDescription hasLabel ifFalse: [^self].
	label := html label.
	(self childAt: aDescription) hasLabelId 
	    ifTrue: [label for: (self childAt: aDescription) labelId].
	label with: 
		[html
		    render: aDescription label;
		    text: ':']
    ]

    setComponent: aComponent [
	<category: 'initilization'>
	component := aComponent
    ]

    setRenderer: aRenderer [
	<category: 'initilization'>
	html := aRenderer
    ]

    visitContainer: aDescription [
	<category: 'visiting-description'>
	self renderContainer: aDescription
    ]

    visitElementDescription: aDescription [
	<category: 'visiting-description'>
	self renderElement: aDescription
    ]
]



MAComponentRenderer subclass: MACssRenderer [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Renderer'>

    renderContainer: aDescription [
	<category: 'rendering'>
	(html definitionList)
	    class: (self classFor: aDescription);
	    with: [super renderContainer: aDescription]
    ]

    renderControl: aDescription [
	<category: 'rendering'>
	(html definitionData)
	    class: (self classFor: aDescription);
	    with: [super renderControl: aDescription]
    ]

    renderGroup: aDescription [
	<category: 'rendering'>
	super renderGroup: aDescription.
	group isNil ifTrue: [^self].
	(html definitionTerm)
	    class: 'group';
	    with: group
    ]

    renderLabel: aDescription [
	<category: 'rendering'>
	(html definitionTerm)
	    title: aDescription comment;
	    class: (self classFor: aDescription);
	    with: [super renderLabel: aDescription]
    ]
]



MAComponentRenderer subclass: MATableRenderer [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Renderer'>

    renderContainer: aDescription [
	<category: 'rendering'>
	(html table)
	    class: (self classFor: aDescription);
	    with: [super renderContainer: aDescription]
    ]

    renderControl: aDescription [
	<category: 'rendering'>
	(html tableData)
	    class: (self classFor: aDescription);
	    with: [super renderControl: aDescription]
    ]

    renderElement: aDescription [
	<category: 'rendering'>
	aDescription group = group ifFalse: [self renderGroup: aDescription].
	html tableRow: 
		[self renderLabel: aDescription.
		self renderControl: aDescription]
    ]

    renderGroup: aDescription [
	<category: 'rendering'>
	super renderGroup: aDescription.
	group isNil ifTrue: [^self].
	(html tableRow)
	    class: 'group';
	    with: 
		    [(html tableHeading)
			colSpan: 2;
			with: group]
    ]

    renderLabel: aDescription [
	<category: 'rendering'>
	(html tableHeading)
	    title: aDescription comment;
	    class: (self classFor: aDescription);
	    with: [super renderLabel: aDescription]
    ]
]



MAFileDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MAFileUploadComponent
    ]

]



Seaside.WADecoration subclass: MAComponentDecoration [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Decorations'>
]



MAComponentDecoration subclass: MAContainerDecoration [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Decorations'>

    buttons [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    default [
	<category: 'accessing'>
	^self buttons first key
    ]

    isMultipart [
	<category: 'testing'>
	^self component isMultipart
    ]

    renderButtonsOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'buttons';
	    with: 
		    [self buttons do: 
			    [:each | 
			    (html submitButton)
				accessKey: each value first;
				on: each key of: self component;
				text: each value]]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html form)
	    class: 'magritte';
	    multipart: self isMultipart;
	    defaultAction: [self component perform: self default];
	    with: 
		    [self
			renderOwnerOn: html;
			renderButtonsOn: html]
    ]
]



MAContainerDecoration subclass: MAFormDecoration [
    | buttons |
    
    <comment: 'I surround the owning component with a XHTML form element and render the form buttons.'>
    <category: 'Magritte-Seaside-Decorations'>

    MAFormDecoration class >> buttons: aCollection [
	<category: 'instance creation'>
	^(self new)
	    addButtons: aCollection;
	    yourself
    ]

    addButton: aSelector [
	<category: 'actions'>
	self addButton: aSelector label: (self labelForSelector: aSelector)
    ]

    addButton: aSelector label: aString [
	<category: 'actions'>
	self buttons add: aSelector -> aString
    ]

    addButtons: aCollection [
	<category: 'actions'>
	aCollection do: 
		[:each | 
		each isVariableBinding 
		    ifFalse: [self addButton: each]
		    ifTrue: [self addButton: each key label: each value]]
    ]

    buttons [
	<category: 'accessing'>
	^buttons
    ]

    buttons: aCollection [
	<category: 'accessing'>
	buttons := aCollection
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self buttons: OrderedCollection new
    ]
]



MAContainerDecoration subclass: MASwitchDecoration [
    
    <comment: 'I turn the owning component read-only and add an edit button. Clicking that button allows one to toggle between view and edit-mode.'>
    <category: 'Magritte-Seaside-Decorations'>

    buttons [
	<category: 'accessing'>
	^self component isReadonly 
	    ifTrue: [Array with: #edit -> 'Edit']
	    ifFalse: [Array with: #save -> 'Save' with: #cancel -> 'Cancel']
    ]

    handleAnswer: anObject continueWith: aBlock [
	<category: 'processing'>
	self component readonly: true.
	super handleAnswer: anObject continueWith: aBlock
    ]
]



MAComponentDecoration subclass: MAValidationDecoration [
    
    <comment: 'I am a normally invisible component. I show a list of validation errors in case the owner component fails to validate.'>
    <category: 'Magritte-Seaside-Decorations'>

    errors [
	<category: 'accessing'>
	^self component errors
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self errors isEmpty ifFalse: [self renderErrorsOn: html].
	self renderOwnerOn: html
    ]

    renderErrorsOn: html [
	<category: 'rendering'>
	(html unorderedList)
	    class: 'errors';
	    labels: [:item | item printString];
	    list: self errors;
	    with: nil
    ]
]



MADurationDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside'>
	^Array with: MATextInputComponent
    ]

]



MADateDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside'>
	^Array with: MADateInputComponent with: MADateSelectorComponent
    ]

]



Symbol extend [

    fixTemps [
	<category: '*magritte-seaside'>
	^self
    ]

]



Seaside.WAComponent subclass: MAComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Core'>

    MAComponent class >> description [
	<category: 'accessing'>
	^MADescriptionBuilder for: self
    ]

    MAComponent class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MAComponent class >> new [
	"Create a new instance of the receiving component class and checks if it is not abstract."

	<category: 'instance-creation'>
	self isAbstract ifTrue: [self error: self name , ' is abstract.'].
	^super new
    ]

    MAComponent class >> withAllConcreteClasses [
	<category: 'reflection'>
	^Array streamContents: 
		[:stream | 
		self withAllConcreteClassesDo: [:each | stream nextPut: each]]
    ]

    MAComponent class >> withAllConcreteClassesDo: aBlock [
	<category: 'reflection'>
	self 
	    withAllSubclassesDo: [:each | each isAbstract ifFalse: [aBlock value: each]]
    ]

    ajaxId [
	<category: 'accessing'>
	^self ajaxId: String new
    ]

    ajaxId: aSymbol [
	<category: 'accessing'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'ajax';
		    nextPutAll: self class name;
		    print: self hash;
		    nextPutAll: aSymbol]
    ]

    isMultipart [
	<category: 'testing'>
	^self children anySatisfy: [:each | each isMultipart]
    ]
]



MAComponent subclass: MADescriptionComponent [
    | memento description parent |
    
    <comment: 'I''m a seaside object which provides all the functions for my subclasses to display MADescription subclasses.'>
    <category: 'Magritte-Seaside-Components'>

    MADescriptionComponent class >> memento: aMemento [
	<category: 'instance creation'>
	^self memento: aMemento description: aMemento description
    ]

    MADescriptionComponent class >> memento: aMemento description: aDescription [
	<category: 'instance creation'>
	^self 
	    memento: aMemento
	    description: aDescription
	    parent: nil
    ]

    MADescriptionComponent class >> memento: aMemento description: aDescription parent: aComponent [
	<category: 'instance creation'>
	^(self new)
	    setMemento: aMemento;
	    setDescription: aDescription;
	    setParent: aComponent;
	    yourself
    ]

    attributes [
	<category: 'accessing'>
	self deprecatedApi: '#attributes is not supported anymore.'.
	^WAHtmlAttributes new
    ]

    commit [
	<category: 'actions'>
	self memento commit
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    id [
	<category: 'accessing-dynamic'>
	^self class name asLowercase , self hash asString
    ]

    isReadonly [
	<category: 'testing'>
	^self description isReadonly 
	    or: [self isRoot not and: [self parent isReadonly]]
    ]

    isRoot [
	<category: 'testing'>
	^self parent isNil
    ]

    labelId [
	"Accessor that returns the an id that can be reference by a <label>-tag."

	<category: 'accessing'>
	^self ajaxId: 'label'
    ]

    memento [
	<category: 'accessing'>
	^memento
    ]

    model [
	<category: 'accessing-dynamic'>
	^self memento model
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    reset [
	<category: 'actions'>
	self memento reset
    ]

    root [
	<category: 'accessing-dynamic'>
	^self isRoot ifTrue: [self] ifFalse: [self parent root]
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	description := aDescription
    ]

    setMemento: aMemento [
	<category: 'initialization'>
	memento := aMemento
    ]

    setParent: aComponent [
	<category: 'initialization'>
	parent := aComponent
    ]

    validate [
	<category: 'actions'>
	self memento validate
    ]
]



MADescriptionComponent subclass: MAContainerComponent [
    | children readonly errors |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAContainerComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    addForm [
	<category: 'decorating'>
	self addForm: #(#save #cancel)
    ]

    addForm: aCollection [
	<category: 'decorating'>
	self addDecoration: (MAFormDecoration buttons: aCollection)
    ]

    addSwitch [
	<category: 'decorating'>
	self addDecoration: MASwitchDecoration new.
	self readonly: true
    ]

    addValidatedForm [
	<category: 'decorating'>
	self
	    addForm;
	    addValidation
    ]

    addValidatedForm: aCollection [
	<category: 'decorating'>
	self
	    addForm: aCollection;
	    addValidation
    ]

    addValidatedSwitch [
	<category: 'decorating'>
	self
	    addSwitch;
	    addValidation
    ]

    addValidation [
	<category: 'decorating'>
	self addDecoration: MAValidationDecoration new
    ]

    buildChildren [
	<category: 'private'>
	^self description inject: Dictionary new
	    into: 
		[:result :each | 
		each isVisible 
		    ifTrue: 
			[result at: each
			    put: (each componentClass 
				    memento: self memento
				    description: each
				    parent: self)].
		result]
    ]

    cancel [
	<category: 'actions'>
	self
	    reset;
	    answer: nil
    ]

    childAt: aDescription [
	<category: 'accessing'>
	^children at: aDescription ifAbsent: [nil]
    ]

    children [
	<category: 'accessing'>
	^children values
    ]

    edit [
	<category: 'actions'>
	self readonly: false
    ]

    errors [
	"Answer a collection of exceptions, the list of standing errors."

	<category: 'accessing'>
	^errors
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	errors := OrderedCollection new
    ]

    isReadonly [
	<category: 'testing'>
	^super isReadonly or: [self readonly]
    ]

    readonly [
	<category: 'accessing-properties'>
	^readonly ifNil: [readonly := false]
    ]

    readonly: aBoolean [
	<category: 'accessing-properties'>
	readonly := aBoolean
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self description componentRenderer component: self on: html
    ]

    save [
	<category: 'actions'>
	self validate ifFalse: [^self].
	self
	    commit;
	    answer: self model
    ]

    setChildren: aDictionary [
	<category: 'initialization'>
	children := aDictionary
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	super setDescription: aDescription.
	self setChildren: self buildChildren
    ]

    validate [
	<category: 'actions'>
	errors := OrderedCollection new.
	[super validate] on: MAError
	    do: 
		[:error | 
		errors add: error.
		error isResumable ifTrue: [error resume]].
	^errors isEmpty
    ]
]



MADescriptionComponent subclass: MAElementComponent [
    
    <comment: 'I provide a basic display for all subclasses of MAElementDescription (only for readonly descriptions). The object is just displayed as a string. For more complex behaviour, overried #renderViewerOn:. '>
    <category: 'Magritte-Seaside-Components'>

    chooser: aComponent [
	<category: 'calling'>
	self chooser: aComponent titled: 'Edit ' , self description label
    ]

    chooser: aComponent titled: aString [
	<category: 'calling'>
	| result |
	result := self root call: (aComponent
			    addMessage: aString;
			    yourself).
	result isNil ifFalse: [self value: result]
    ]

    hasLabelId [
	"Return whether somewhere an element is rendered with the id ==labelId== that can be reference by a <label>-tag."

	<category: 'testing'>
	^false
    ]

    reference [
	<category: 'accessing'>
	^self description reference
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self isReadonly 
	    ifTrue: [self renderViewerOn: html]
	    ifFalse: [self renderEditorOn: html]
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	self renderViewerOn: html
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	html render: self string
    ]

    string [
	<category: 'accessing-model'>
	^self value isString 
	    ifTrue: [self value]
	    ifFalse: [self description toString: self value]
    ]

    string: aString [
	<category: 'accessing-model'>
	| value |
	value := [self description fromString: aString] ifError: [aString].
	self value: value
    ]

    value [
	<category: 'accessing-model'>
	^self memento readUsing: self description
    ]

    value: anObject [
	<category: 'accessing-model'>
	self memento write: anObject using: self description
    ]
]



MAElementComponent subclass: MACheckboxComponent [
    
    <comment: 'I''m a seaside component used to display MABooleanDescription. If I''m writeable (readonly property of my description to false) I display a checkbox otherwise, I display a string: ''yes'' if true, ''no'' if false'', '''' if nil.'>
    <category: 'Magritte-Seaside-Components'>

    MACheckboxComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^true
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html label: 
		[(html checkbox)
		    id: self labelId;
		    disabled: self isReadonly;
		    on: #value of: self.
		html
		    space;
		    render: self description checkboxLabel]
    ]
]



MAElementComponent subclass: MADateSelectorComponent [
    | selector |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MADateSelectorComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    children [
	<category: 'accessing'>
	^Array with: selector
    ]

    dateClass [
	<category: 'private'>
	^Date
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	selector := self selectorClass new
    ]

    isMultipart [
	<category: 'testing'>
	^false
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	html render: selector.
	html hiddenInput 
	    callback: [selector dateIsValid ifTrue: [self value: selector date]].
	html submitButton on: #today of: self
    ]

    selectorClass [
	<category: 'private'>
	^WADateSelector
    ]

    setDescription: aDescription [
	<category: 'initialize-release'>
	| date |
	super setDescription: aDescription.
	date := self value.
	date isNil ifFalse: [selector date: date]
    ]

    today [
	<category: 'actions'>
	| today |
	today := self dateClass today.
	self value: today.
	selector date: today
    ]

    validate [
	<category: 'validation'>
	super validate.
	selector dateIsValid 
	    ifFalse: 
		[MAKindError description: self description
		    signal: self description kindErrorMessage]
    ]
]



MAElementComponent subclass: MAFileUploadComponent [
    
    <comment: 'I''m the MAFileDescription seaside component. With me user can upload files to the server. I provide a button for the user to browse their computer for files.'>
    <category: 'Magritte-Seaside-Components'>

    MAFileUploadComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not and: [self isMultipart]
    ]

    isMultipart [
	<category: 'testing'>
	^self value isNil or: [self value isEmpty]
    ]

    remove [
	<category: 'actions'>
	self value ifNotNil: [self value finalize].
	self value: nil
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	self isMultipart 
	    ifTrue: [self renderUploadOn: html]
	    ifFalse: [self renderRemoveOn: html]
    ]

    renderRemoveOn: html [
	<category: 'rendering'>
	(html anchor)
	    url: (self value urlOn: html);
	    with: self value filename.
	html
	    text: ' (';
	    render: self value filesize asFileSize;
	    text: ') '.
	html submitButton on: #remove of: self
    ]

    renderUploadOn: html [
	<category: 'rendering'>
	(html fileUpload)
	    id: self labelId;
	    on: #upload of: self.
	html submitButton text: 'upload'
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	html render: self value
    ]

    upload: aFile [
	<category: 'actions'>
	self value: (aFile isNil 
		    ifFalse: 
			[(self description kind new)
			    mimetype: aFile contentType;
			    filename: aFile fileName;
			    contents: aFile contents;
			    yourself])
    ]
]



MAElementComponent subclass: MAOptionComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    labelForOption: anObject [
	<category: 'private'>
	^self description labelForOption: anObject
    ]
]



MAOptionComponent subclass: MAMultipleSelectionComponent [
    
    <comment: 'I provide basic functionalities for MAListCompositionComponent and MACheckboxGroupComponent.'>
    <category: 'Magritte-Seaside-Components'>

    add: anObject [
	<category: 'actions'>
	(self isDistinct and: [self value includes: anObject]) 
	    ifFalse: [self value: (self value copyWith: anObject)]
    ]

    availableList [
	<category: 'accessing'>
	^self description allOptions
    ]

    clear [
	<category: 'actions'>
	self value: self value copyEmpty
    ]

    hasLabelId [
	<category: 'testing'>
	^true
    ]

    isDistinct [
	<category: 'testing'>
	^self description isDistinct
    ]

    isOrdered [
	<category: 'testing'>
	^self description isOrdered and: 
		[(self value respondsTo: #moveUp:) and: [self value respondsTo: #moveDown:]]
    ]

    remove: anObject [
	<category: 'actions'>
	self value: (self isDistinct 
		    ifTrue: [self value copyWithout: anObject]
		    ifFalse: [self value copyWithoutFirst: anObject])
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	(html unorderedList)
	    id: self labelId;
	    list: self selectedList;
	    labels: [:each | self labelForOption: each]
    ]

    selectedList [
	<category: 'accessing'>
	^self value
    ]

    value [
	<category: 'accessing'>
	^super value ifNil: 
		[self value: Array new.
		super value]
    ]
]



MAMultipleSelectionComponent subclass: MACheckboxGroupComponent [
    
    <comment: 'Use for MAMultipleSelectionComponent. I display as many checkboxes as my description has options. Another representation for the same description is MAListCompositionComponent.'>
    <category: 'Magritte-Seaside-Components'>

    MACheckboxGroupComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly
    ]

    isDistinct [
	<category: 'testing'>
	^true
    ]

    optionId: anInteger [
	<category: 'private'>
	^self ajaxId: 'option' , anInteger displayString
    ]

    optionsWithIndexDo: elementAndIndexBlock separatedBy: separatorBlock [
	<category: 'private'>
	| index |
	index := 1.
	self description allOptions do: 
		[:each | 
		elementAndIndexBlock value: each value: index.
		index := index + 1]
	    separatedBy: separatorBlock
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	html hiddenInput callback: [:value | self clear].
	self optionsWithIndexDo: 
		[:each :index | 
		| optionId |
		optionId := self optionId: index.
		(html checkbox)
		    id: optionId;
		    value: (self selectedList includes: each);
		    onTrue: [self add: each] onFalse: [self remove: each].
		html space.
		(html label)
		    for: optionId;
		    with: (self labelForOption: each)]
	    separatedBy: [html break]
    ]
]



MAMultipleSelectionComponent subclass: MAListCompositonComponent [
    | availableSelected selectedSelected |
    
    <comment: 'I''m, like MACheckboxComponent, a seaside component for MAMultipleSelectionDescription. I display two lists. In the first, all available options, in the other, what the user selected. 2 buttons in between to add and remove elements to/from the selected list. If the everything property is set, I display two more buttons to allow the user to add or remove all options in one click.'>
    <category: 'Magritte-Seaside-Components'>

    MAListCompositonComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    add [
	<category: 'actions'>
	| added |
	self availableSelected isNil ifTrue: [^self].
	added := self availableSelected copy.
	self add: added.
	self selectedSelected: added.
	self description isDistinct ifTrue: [self availableSelected: nil]
    ]

    availableList [
	<category: 'accessing'>
	^self description isDistinct 
	    ifFalse: [super availableList]
	    ifTrue: [super availableList copyWithoutAll: self selectedList]
    ]

    availableSelected [
	<category: 'accessing-properties'>
	^availableSelected
    ]

    availableSelected: anObject [
	<category: 'accessing-properties'>
	availableSelected := anObject
    ]

    moveDown [
	<category: 'actions'>
	self selectedSelected isNil 
	    ifFalse: [self selectedList moveDown: self selectedSelected]
    ]

    moveUp [
	<category: 'actions'>
	self selectedSelected isNil 
	    ifFalse: [self selectedList moveUp: self selectedSelected]
    ]

    remove [
	<category: 'actions'>
	self selectedSelected isNil ifTrue: [^self].
	self remove: self selectedSelected.
	self availableSelected: self selectedSelected.
	self selectedSelected: nil
    ]

    renderEditorAvailableOn: html [
	<category: 'rendering-parts'>
	(html select)
	    size: 6;
	    style: 'width: 150px';
	    list: self availableList;
	    selected: self availableSelected;
	    callback: [:value | self availableSelected: value];
	    labels: [:value | self labelForOption: value]
    ]

    renderEditorButtonAddOn: html [
	<category: 'rendering-buttons'>
	(html submitButton)
	    callback: [self add];
	    text: '>>'.
	html break.
	(html submitButton)
	    callback: [self remove];
	    text: '<<'
    ]

    renderEditorButtonOrderOn: html [
	<category: 'rendering-buttons'>
	(html submitButton)
	    callback: [self moveUp];
	    text: 'up'.
	html break.
	(html submitButton)
	    callback: [self moveDown];
	    text: 'down'
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	(html table)
	    id: self labelId;
	    with: 
		    [html tableRow: 
			    [html tableData: [self renderEditorAvailableOn: html].
			    (html tableData)
				style: 'vertical-align: center';
				with: [self renderEditorButtonAddOn: html].
			    html tableData: [self renderEditorSelectedOn: html].
			    self isOrdered 
				ifTrue: 
				    [(html tableData)
					style: 'vertical-align: center';
					with: [self renderEditorButtonOrderOn: html]]]]
    ]

    renderEditorSelectedOn: html [
	<category: 'rendering-parts'>
	(html select)
	    size: 6;
	    style: 'width: 150px';
	    list: self selectedList;
	    selected: self selectedSelected;
	    callback: [:value | self selectedSelected: value];
	    labels: [:value | self labelForOption: value]
    ]

    selectedSelected [
	<category: 'accessing-properties'>
	^selectedSelected
    ]

    selectedSelected: anObject [
	<category: 'accessing-properties'>
	selectedSelected := anObject
    ]
]



MAMultipleSelectionComponent subclass: MAMultiselectListComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAMultiselectListComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    isDistinct [
	<category: 'testing'>
	^true
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	(html multiSelect)
	    size: 8;
	    id: self labelId;
	    list: self availableList;
	    selected: self selectedList;
	    labels: [:value | self labelForOption: value];
	    callback: [:value | self value: value]
    ]
]



MAOptionComponent subclass: MASingleSelectionComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    options [
	<category: 'accessing'>
	^self description allOptionsWith: self value
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	html render: (self labelForOption: self value)
    ]
]



MASingleSelectionComponent subclass: MARadioGroupComponent [
    
    <comment: 'I display a set of radio buttons to render MASingleSelectionDescription.'>
    <category: 'Magritte-Seaside-Components'>

    MARadioGroupComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not
    ]

    optionId: anInteger [
	<category: 'private'>
	^self ajaxId: 'option' , anInteger displayString
    ]

    optionsWithIndexDo: elementAndIndexBlock separatedBy: separatorBlock [
	<category: 'private'>
	| index |
	index := 1.
	self options do: 
		[:each | 
		elementAndIndexBlock value: each value: index.
		index := index + 1]
	    separatedBy: separatorBlock
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	| group |
	group := html radioGroup.
	(html span)
	    id: self labelId;
	    with: 
		    [self optionsWithIndexDo: 
			    [:each :index | 
			    self 
				renderOption: each
				index: index
				in: group
				on: html]
			separatedBy: [html break]]
    ]

    renderOption: anObject index: anInteger in: aRadioGroup on: html [
	<category: 'rendering'>
	| optionId |
	optionId := self optionId: anInteger.
	(html radioButton)
	    id: optionId;
	    group: aRadioGroup;
	    selected: self value = anObject;
	    callback: [self value: anObject].
	html space.
	(html label)
	    for: optionId;
	    with: (self labelForOption: anObject)
    ]
]



MASingleSelectionComponent subclass: MASelectListComponent [
    
    <comment: 'I display a simple list to allow the user to choose one element from the list. I am one of the two seaside components to render MASingleSelectionDescription.'>
    <category: 'Magritte-Seaside-Components'>

    MASelectListComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    groups [
	"The options objects are assumed to understand the 'groupBy' selector supplied by the description object."

	<category: 'accessing-model'>
	| group groups |
	groups := Dictionary new.
	self options collect: 
		[:each | 
		each notNil 
		    ifTrue: 
			[group := each perform: self description groupBy.
			(groups at: group ifAbsentPut: [OrderedCollection new]) add: each]].
	^groups
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not
    ]

    renderEditorForGroupedOn: html [
	<category: 'rendering-grouped'>
	(html select)
	    attributes: self attributes;
	    id: self labelId;
	    selected: self value;
	    callback: [:value | self value: value];
	    with: [self renderGroupsOn: html]
    ]

    renderEditorForUngroupedOn: html [
	<category: 'rendering'>
	(html select)
	    id: self labelId;
	    list: self options;
	    selected: self value;
	    callback: [:value | self value: value];
	    labels: [:value | self labelForOption: value]
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	self description isGrouped 
	    ifTrue: [self renderEditorForGroupedOn: html]
	    ifFalse: [self renderEditorForUngroupedOn: html]
    ]

    renderGroupsOn: html [
	<category: 'rendering-grouped'>
	^self groups keysAndValuesDo: 
		[:group :groupMembers | 
		(html optionGroup)
		    label: group;
		    with: [groupMembers do: [:option | self renderOption: option on: html]]]
    ]

    renderOption: option on: html [
	<category: 'rendering-grouped'>
	^(html option)
	    selected: self value = option;
	    label: (self labelForOption: option);
	    callback: [self value: option];
	    with: option
    ]
]



MAElementComponent subclass: MARangeComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MARangeComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not
    ]

    labelId [
	<category: 'accessing'>
	^self id
    ]

    max [
	<category: 'accessing-dynamic'>
	^self description max ifNil: [100]
    ]

    min [
	<category: 'accessing-dynamic'>
	^self description min ifNil: [-100]
    ]

    range [
	<category: 'accessing-dynamic'>
	^self max - self min
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	(html rangeInput)
	    id: self id;
	    onInput: self updateScript;
	    min: 0;
	    max: 100;
	    on: #string of: self.	"default"	"default"
	html span id: self id , 'v'.
	html script: self updateScript
    ]

    updateScript [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'document.getElementById(';
		    print: self id , 'v';
		    nextPutAll: ').innerHTML = document.getElementById(';
		    print: self id;
		    nextPutAll: ').value * (';
		    print: self range;
		    nextPutAll: ') / 100 + (';
		    print: self min;
		    nextPutAll: ');']
    ]

    value [
	<category: 'accessing'>
	^((super value ifNil: [0]) - self min) * 100 / self range
    ]

    value: aNumber [
	<category: 'accessing'>
	super value: (aNumber ifNotNil: [aNumber * self range / 100 + self min])
    ]
]



MAElementComponent subclass: MARelationComponent [
    | selected |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    classes [
	<category: 'accessing-dynamic'>
	^self description classes
    ]

    editorFor: anObject [
	<category: 'private'>
	^(anObject asComponent)
	    addValidatedForm;
	    yourself
    ]

    renderSelectButtonOn: html [
	<category: 'rendering-tools'>
	self subclassResponsibility
    ]

    renderSelectListOn: html [
	<category: 'rendering-tools'>
	self classes size > 1 
	    ifTrue: 
		[(html select)
		    list: self classes;
		    selected: self selected;
		    callback: [:value | self selected: value];
		    labels: [:value | value label]].
	self classes notEmpty ifTrue: [self renderSelectButtonOn: html]
    ]

    selected [
	<category: 'accessing'>
	^selected ifNil: [selected := self classes first]
    ]

    selected: aClass [
	<category: 'accessing'>
	selected := aClass
    ]
]



MARelationComponent subclass: MAOneToManyComponent [
    | report commands |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAOneToManyComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    add [
	<category: 'actions'>
	| result |
	result := self selected new.
	result := self root call: ((result asComponent)
			    addMessage: 'Add ' , self selected label;
			    addValidatedForm;
			    yourself).
	result isNil 
	    ifFalse: 
		[self
		    value: (self value copyWith: result);
		    refresh]
    ]

    buildCommands [
	<category: 'private'>
	commands := MACommandColumn new setReport: self report.
	self description isDefinitive 
	    ifFalse: 
		[commands
		    addCommandOn: self
			selector: #edit:
			text: 'edit';
		    addCommandOn: self
			selector: #remove:
			text: 'remove'].
	self description isOrdered 
	    ifTrue: 
		[commands
		    addCommandOn: self
			selector: #up:
			text: 'up';
		    addCommandOn: self
			selector: #down:
			text: 'down'].
	^commands
    ]

    buildReport [
	<category: 'private'>
	^(MAReport rows: self value description: self reference)
	    sortEnabled: self description isOrdered not;
	    yourself
    ]

    children [
	<category: 'accessing'>
	^Array with: self report
    ]

    commands [
	<category: 'accessing'>
	^commands ifNil: [commands := self buildCommands]
    ]

    down: anElement [
	<category: 'actions'>
	self value moveDown: anElement
    ]

    edit: anObject [
	<category: 'actions'>
	self root call: ((anObject asComponent)
		    addMessage: 'Edit ' , self selected label;
		    addValidatedForm;
		    yourself).
	self refresh
    ]

    refresh [
	<category: 'actions'>
	self report rows: self value
    ]

    remove: anObject [
	<category: 'actions'>
	self value: (self value copyWithout: anObject).
	self refresh
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	self renderViewerOn: html.
	self description isDefinitive ifFalse: [self renderSelectListOn: html]
    ]

    renderSelectButtonOn: html [
	<category: 'rendering-buttons'>
	html submitButton on: #add of: self
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	| columns |
	columns := self report columns copyWithout: self commands.
	self report columns: (self isReadonly 
		    ifFalse: [columns copyWith: self commands]
		    ifTrue: [columns]).
	html render: self report
    ]

    report [
	<category: 'accessing'>
	^report ifNil: [report := self buildReport]
    ]

    up: anElement [
	<category: 'actions'>
	self value moveUp: anElement
    ]
]



MAOneToManyComponent subclass: MAOneToManyScalarComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    add [
	<category: 'actions'>
	| holder holderDescription |
	holder := ValueHolder new.
	holderDescription := (self reference copy)
		    accessor: (MASelectorAccessor selector: #contents);
		    yourself.
	holder := self root 
		    call: ((holderDescription asContainer asComponentOn: holder)
			    addMessage: 'Add ' , self selected label;
			    addValidatedForm;
			    yourself).
	holder isNil 
	    ifFalse: 
		[self
		    value: (self value copyWith: holder contents);
		    refresh]
    ]

    buildCommands [
	<category: 'private'>
	commands := MAIndexedCommandColumn new setReport: self report.
	self description isDefinitive 
	    ifFalse: 
		[commands
		    addCommandOn: self
			selector: #edit:index:
			text: 'Edit';
		    addCommandOn: self
			selector: #remove:index:
			text: 'Remove'].
	"not yet implemented
	 self description isOrdered
	 ifTrue: [ commands
	 addCommandOn: self selector: #up:index:;
	 addCommandOn: self selector: #down:index: ]."
	^commands
    ]

    buildReport [
	<category: 'private'>
	^MAReport rows: self value description: self description
    ]

    edit: anObject index: anInteger [
	"sorry, but a collection might include duplicates like #(1 2 1) and you only want to edit the one with the correct index"

	<category: 'actions'>
	| holder holderDescription |
	holder := (ValueHolder new)
		    contents: anObject;
		    yourself.
	holderDescription := (self reference copy)
		    accessor: (MASelectorAccessor selector: #contents);
		    yourself.
	holder := self root 
		    call: ((holderDescription asContainer asComponentOn: holder)
			    addMessage: 'Edit ' , self selected label;
			    addValidatedForm;
			    yourself).
	holder isNil ifTrue: [^self].
	self value: (self value isSequenceable 
		    ifTrue: 
			[(self copy value)
			    at: anInteger put: holder contents;
			    yourself]
		    ifFalse: 
			[(self value copy)
			    remove: anObject;
			    add: holder contents;
			    yourself]).
	self refresh
    ]

    remove: anObject index: anInteger [
	"sorry, but a collection might include duplicates like #(1 2 1) and you only want to remove the one with the correct index"

	<category: 'actions'>
	self value: (self value isSequenceable 
		    ifTrue: [self value copyWithoutIndex: anInteger]
		    ifFalse: [self value copyWithout: anObject]).
	self refresh
    ]
]



MARelationComponent subclass: MAOneToOneComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    create [
	<category: 'actions'>
	self subclassResponsibility
    ]

    remove [
	<category: 'actions'>
	self value: nil
    ]

    renderButtonsOn: html [
	<category: 'rendering'>
	
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	self value isNil 
	    ifTrue: [self renderSelectListOn: html]
	    ifFalse: 
		[self
		    renderViewerOn: html;
		    renderButtonsOn: html]
    ]

    renderSelectButtonOn: html [
	<category: 'rendering-tools'>
	html submitButton on: #create of: self
    ]
]



MAOneToOneComponent subclass: MAExternalEditorComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAExternalEditorComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    create [
	<category: 'actions'>
	self chooser: (self editorFor: self selected new)
    ]

    edit [
	<category: 'actions'>
	self chooser: (self editorFor: self value)
    ]

    renderButtonsOn: html [
	<category: 'rendering'>
	html submitButton on: #remove of: self.
	html submitButton on: #edit of: self
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	html render: (self reference toString: self value)
    ]
]



MAOneToOneComponent subclass: MAInternalEditorComponent [
    | component |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAInternalEditorComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    buildComponent [
	<category: 'private'>
	^(self value asComponent)
	    setParent: self;
	    yourself
    ]

    children [
	<category: 'accessing'>
	^Array with: self component
    ]

    component [
	<category: 'accessing'>
	^component ifNil: [component := self buildComponent]
    ]

    create [
	<category: 'actions'>
	self value: self selected new.
	component := nil
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	super renderEditorOn: html.
	html hiddenInput callback: [self component commit]
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	html render: ((self component)
		    readonly: self isReadonly;
		    yourself)
    ]
]



MAElementComponent subclass: MATableComponent [
    | descriptionTable componentTable |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MATableComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    buildComponentTable [
	<category: 'private'>
	^self descriptionTable collect: 
		[:row :col :each | 
		each componentClass 
		    memento: self
		    description: each
		    parent: self]
    ]

    buildDataTable [
	<category: 'private'>
	^MATableModel rows: self description rowCount
	    columns: self description columnCount
    ]

    buildDescriptionTable [
	<category: 'private'>
	^self dataTable collect: 
		[:row :col :each | 
		(self description reference copy)
		    accessor: MANullAccessor new;
		    label: row asString , '/' , col asString;
		    propertyAt: #row put: row;
		    propertyAt: #column put: col;
		    yourself]
    ]

    children [
	<category: 'accessing-dynamic'>
	^self componentTable contents
    ]

    componentTable [
	<category: 'accessing'>
	^componentTable ifNil: [componentTable := self buildComponentTable]
    ]

    dataTable [
	<category: 'accessing'>
	self value isNil 
	    ifTrue: [self value: self buildDataTable]
	    ifFalse: 
		[(self value rowCount = self description rowCount 
		    and: [self value columnCount = self description columnCount]) 
			ifFalse: 
			    [self value: (self value copyRows: self description rowCount
					columns: self description columnCount)]].
	^self value
    ]

    descriptionTable [
	<category: 'accessing'>
	^descriptionTable ifNil: [descriptionTable := self buildDescriptionTable]
    ]

    hasLabelId [
	<category: 'testing'>
	^true
    ]

    readUsing: aDescription [
	<category: 'private'>
	^self dataTable at: (aDescription propertyAt: #row)
	    at: (aDescription propertyAt: #column)
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	(html table)
	    id: self labelId;
	    with: 
		    [html tableRow: 
			    [html tableHeading: nil.
			    self description columnLabels do: [:each | html tableHeading: each]].
		    self description rowLabels keysAndValuesDo: 
			    [:rindex :row | 
			    html tableRow: 
				    [html tableHeading: row.
				    self description columnLabels keysAndValuesDo: 
					    [:cindex :col | 
					    html tableData: (self componentTable uncheckedAt: rindex at: cindex)]]]]
    ]

    write: anObject using: aDescription [
	<category: 'private'>
	^self dataTable 
	    at: (aDescription propertyAt: #row)
	    at: (aDescription propertyAt: #column)
	    put: anObject
    ]
]



MAElementComponent subclass: MATextAreaComponent [
    
    <comment: 'I display an html text area for the magritte MAMemoDescription.'>
    <category: 'Magritte-Seaside-Components'>

    MATextAreaComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	(html textArea)
	    id: self labelId;
	    rows: self description lineCount;
	    on: #string of: self
    ]

    renderViewerOn: html [
	<category: 'rendering'>
	self string lines do: [:each | html render: each] separatedBy: [html break]
    ]
]



MAElementComponent subclass: MATextInputComponent [
    
    <comment: 'I''m a simple input box for MAStringDescription.'>
    <category: 'Magritte-Seaside-Components'>

    MATextInputComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	(html textInput)
	    id: self labelId;
	    on: #string of: self
    ]
]



MATextInputComponent subclass: MADateInputComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    choose [
	<category: 'actions'>
	| calendar |
	calendar := WAMiniCalendar new.
	calendar
	    date: ((self value notNil and: [self description isSatisfiedBy: self value]) 
			ifFalse: [Date current]
			ifTrue: [self value]);
	    selectBlock: [:value | calendar answer: value];
	    canSelectBlock: [:value | self description isSatisfiedBy: value].
	self chooser: calendar
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	super renderEditorOn: html.
	html submitButton on: #choose of: self
    ]
]



MATextInputComponent subclass: MATimeInputComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    current [
	<category: 'actions'>
	self value: Time current
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	super renderEditorOn: html.
	html submitButton on: #current of: self
    ]
]



MATextInputComponent subclass: MATimeStampInputComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    current [
	<category: 'actions'>
	self value: DateTime now
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	super renderEditorOn: html.
	html submitButton on: #current of: self
    ]
]



MAElementComponent subclass: MATextPasswordComponent [
    
    <comment: 'Password seaside component, I display stars ''*'' instead of the text typed by the user. My description is MAPasswordDescription.'>
    <category: 'Magritte-Seaside-Components'>

    MATextPasswordComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^self isReadonly not
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	(html passwordInput)
	    id: self labelId;
	    on: #string of: self
    ]

    string [
	<category: 'accessing'>
	^self description obfuscated: self value
    ]

    string: aString [
	<category: 'accessing'>
	(self description isObfuscated: aString) ifFalse: [super string: aString]
    ]
]



MAElementComponent subclass: MATimeSelectorComponent [
    | selector |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MATimeSelectorComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    children [
	<category: 'accessing'>
	^Array with: selector
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	selector := self selectorClass new
    ]

    isMultipart [
	<category: 'testing'>
	^false
    ]

    now [
	<category: 'actions'>
	| now |
	now := self timeClass current.
	self value: now.
	selector time: now
    ]

    renderEditorOn: html [
	<category: 'rendering'>
	html render: selector.
	html hiddenInput 
	    callback: [selector timeIsValid ifTrue: [self value: selector time]].
	html submitButton on: #now of: self
    ]

    selectorClass [
	<category: 'private'>
	^WATimeSelector
    ]

    setDescription: aDescription [
	<category: 'initialize-release'>
	| time |
	super setDescription: aDescription.
	time := self value.
	time isNil ifFalse: [selector time: time]
    ]

    timeClass [
	<category: 'private'>
	^Time
    ]

    validate [
	<category: 'validation'>
	super validate.
	selector timeIsValid 
	    ifFalse: 
		[MAKindError description: self description
		    signal: self description kindErrorMessage]
    ]
]



MAElementComponent subclass: MAUndefinedComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAUndefinedComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^true
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html span)
	    id: self labelId;
	    style: 'color: red;';
	    with: 'Undefined Component'
    ]
]



MADescriptionComponent subclass: MAReportComponent [
    
    <comment: nil>
    <category: 'Magritte-Seaside-Components'>

    MAReportComponent class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    hasLabelId [
	<category: 'testing'>
	^true
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html table)
	    id: self labelId;
	    with: 
		    [self renderTableCaptionOn: html.
		    self renderTableSummaryOn: html.
		    self renderTableHeadOn: html.
		    self renderTableFootOn: html.
		    self renderTableBodyOn: html]
    ]

    renderTableBodyOn: html [
	<category: 'rendering-parts'>
	(html tag: 'tbody') with: 
		[self description showBody 
		    ifTrue: 
			[self value isEmptyOrNil 
			    ifTrue: [self renderTableEmptyOn: html]
			    ifFalse: [self renderTableContentOn: html]]]
    ]

    renderTableCaptionOn: html [
	<category: 'rendering-parts'>
	self description caption 
	    ifNotNil: [:value | (html tag: 'caption') with: self description caption]
    ]

    renderTableContentOn: html [
	<category: 'rendering-content'>
	
    ]

    renderTableEmptyOn: html [
	<category: 'rendering-content'>
	
    ]

    renderTableFootOn: html [
	<category: 'rendering-parts'>
	(html tag: 'tfoot') 
	    with: [self description showFooter ifTrue: [self renderTableFooterOn: html]]
    ]

    renderTableFooterOn: html [
	<category: 'rendering-content'>
	
    ]

    renderTableHeadOn: html [
	<category: 'rendering-parts'>
	(html tag: 'thead') 
	    with: [self description showHeader ifTrue: [self renderTableHeaderOn: html]]
    ]

    renderTableHeaderOn: html [
	<category: 'rendering-content'>
	html tableRow: 
		[self description 
		    do: [:each | each isVisible ifTrue: [html tableData: each label]]]
    ]

    renderTableSummaryOn: html [
	<category: 'rendering-parts'>
	self description summary 
	    ifNotNil: [:value | (html tag: 'summary') with: self description summary]
    ]
]



MAComponent subclass: MAReport [
    | rows cache columns properties backtracked |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Report'>

    MAReport class >> description2000 [
	<category: 'accessing-description-table'>
	^(MABooleanDescription new)
	    accessor: #showHeader;
	    label: 'Show Header';
	    priority: 2000;
	    yourself
    ]

    MAReport class >> description2100 [
	<category: 'accessing-description-table'>
	^(MABooleanDescription new)
	    accessor: #showBody;
	    label: 'Show Body';
	    priority: 2100;
	    yourself
    ]

    MAReport class >> description2200 [
	<category: 'accessing-description-table'>
	^(MAStringDescription new)
	    accessor: #tableEmpty;
	    label: 'Empty';
	    priority: 2200;
	    yourself
    ]

    MAReport class >> description2300 [
	<category: 'accessing-description-table'>
	^(MABooleanDescription new)
	    accessor: #showFooter;
	    label: 'Show Footer';
	    priority: 2300;
	    yourself
    ]

    MAReport class >> description2400 [
	<category: 'accessing-description-table'>
	^(MABooleanDescription new)
	    accessor: #showCaption;
	    label: 'Show Caption';
	    priority: 2300;
	    yourself
    ]

    MAReport class >> description2500 [
	<category: 'accessing-description-table'>
	^(MAStringDescription new)
	    accessor: #tableCaption;
	    label: 'Caption';
	    priority: 2500;
	    yourself
    ]

    MAReport class >> description2600 [
	<category: 'accessing-description-table'>
	^(MABooleanDescription new)
	    accessor: #showSummary;
	    label: 'Show Summary';
	    priority: 2600;
	    yourself
    ]

    MAReport class >> description2700 [
	<category: 'accessing-description-table'>
	^(MAStringDescription new)
	    accessor: #tableSummary;
	    label: 'Summary';
	    priority: 2700;
	    yourself
    ]

    MAReport class >> description4000 [
	<category: 'accessing-description-batch'>
	^(MABooleanDescription new)
	    accessor: #showBatch;
	    label: 'Show Batch';
	    priority: 4000;
	    yourself
    ]

    MAReport class >> description4100 [
	<category: 'accessing-description-batch'>
	^(MANumberDescription new)
	    accessor: #batchSize;
	    label: 'Size';
	    priority: 4100;
	    yourself
    ]

    MAReport class >> description4200 [
	<category: 'accessing-description-batch'>
	^(MABooleanDescription new)
	    accessor: #showBatchFirstLast;
	    label: 'Show First/Last';
	    priority: 4200;
	    yourself
    ]

    MAReport class >> description4300 [
	<category: 'accessing-description-batch'>
	^(MABooleanDescription new)
	    accessor: #showBatchPreviousNext;
	    label: 'Show Previous/Next';
	    priority: 4300;
	    yourself
    ]

    MAReport class >> description4400 [
	<category: 'accessing-description-batch'>
	^(MABooleanDescription new)
	    accessor: #showBatchPages;
	    label: 'Show Pages';
	    priority: 4400;
	    yourself
    ]

    MAReport class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAReport class >> rows: aCollection [
	<category: 'instance creation'>
	^(self new)
	    rows: aCollection;
	    yourself
    ]

    MAReport class >> rows: aCollection description: aDescription [
	<category: 'instance creation'>
	| report |
	report := self rows: aCollection.
	aDescription asContainer do: [:each | report addColumnDescription: each].
	^report
    ]

    addColumn: aColumn [
	<category: 'columns'>
	columns := columns copyWith: aColumn.
	^aColumn
	    setReport: self;
	    yourself
    ]

    addColumnCascade: anArray [
	<category: 'columns'>
	^(self addColumn: MAColumn new)
	    cascade: anArray;
	    yourself
    ]

    addColumnDescription: aDescription [
	<category: 'columns'>
	^self addColumn: ((aDescription reportColumnClass new)
		    setDescription: aDescription;
		    yourself)
    ]

    addColumnSelector: aSelector [
	<category: 'columns'>
	^(self addColumn: MAColumn new)
	    selector: aSelector;
	    yourself
    ]

    batchEndIndex [
	<category: 'private-batch'>
	^self batchPage * self batchSize min: self cache size
    ]

    batchMaxPages [
	<category: 'private-batch'>
	^(self cache size / self batchSize) ceiling
    ]

    batchPage [
	<category: 'accessing-settings'>
	^backtracked at: #batchPage ifAbsentPut: [self defaultBatchPage]
    ]

    batchPage: anInteger [
	<category: 'accessing-settings'>
	backtracked at: #batchPage put: anInteger
    ]

    batchPageRange [
	<category: 'private-batch'>
	^self batchPageRangeStart to: self batchPageRangeEnd
    ]

    batchPageRangeEnd [
	<category: 'private-batch'>
	^self batchMaxPages min: self batchPage + 9
    ]

    batchPageRangeStart [
	<category: 'private-batch'>
	^self defaultBatchPage max: self batchPage - 9
    ]

    batchSize [
	<category: 'accessing-settings'>
	^properties at: #batchSize ifAbsent: [self defaultBatchSize]
    ]

    batchSize: anInteger [
	<category: 'accessing-settings'>
	properties at: #batchSize put: anInteger
    ]

    batchStartIndex [
	<category: 'private-batch'>
	^(self batchPage - 1) * self batchSize + 1
    ]

    cache [
	"Return the cached rows of the receiver, these rows are filtered and sorted."

	<category: 'accessing-readonly'>
	cache isNil 
	    ifTrue: [self cache: (self sortRows: (self filterRows: self rows asArray))].
	^cache
    ]

    cache: aCollection [
	<category: 'accessing-readonly'>
	cache := aCollection
    ]

    columns [
	<category: 'accessing-readonly'>
	^columns
    ]

    columns: aCollection [
	<category: 'accessing-readonly'>
	columns := aCollection
    ]

    defaultBatchPage [
	<category: 'accessing-defaults'>
	^1
    ]

    defaultBatchSize [
	<category: 'accessing-defaults'>
	^10
    ]

    defaultRowFilter [
	<category: 'accessing-defaults'>
	^nil
    ]

    defaultRowPeriod [
	<category: 'accessing-defaults'>
	^1
    ]

    defaultRowStyles [
	<category: 'accessing-defaults'>
	^Array with: 'odd' with: 'even'
    ]

    defaultShowBatch [
	<category: 'accessing-defaults'>
	^true
    ]

    defaultShowBatchFirstLast [
	<category: 'accessing-defaults'>
	^false
    ]

    defaultShowBatchPages [
	<category: 'accessing-defaults'>
	^true
    ]

    defaultShowBatchPreviousNext [
	<category: 'accessing-defaults'>
	^true
    ]

    defaultShowBody [
	<category: 'accessing-defaults'>
	^true
    ]

    defaultShowCaption [
	<category: 'accessing-defaults'>
	^false
    ]

    defaultShowFooter [
	<category: 'accessing-defaults'>
	^false
    ]

    defaultShowHeader [
	<category: 'accessing-defaults'>
	^true
    ]

    defaultShowSummary [
	<category: 'accessing-defaults'>
	^false
    ]

    defaultSortColumn [
	<category: 'accessing-defaults'>
	^nil
    ]

    defaultSortEnabled [
	<category: 'accessing-defaults'>
	^true
    ]

    defaultSortReversed [
	<category: 'accessing-defaults'>
	^false
    ]

    defaultSorterStyles [
	<category: 'accessing-defaults'>
	^Array with: 'ascending' with: 'descencing'
    ]

    defaultTableCaption [
	<category: 'accessing-defaults'>
	^nil
    ]

    defaultTableEmpty [
	<category: 'accessing-defaults'>
	^'The report is empty.'
    ]

    defaultTableSummary [
	<category: 'accessing-defaults'>
	^nil
    ]

    export [
	<category: 'exporting'>
	^String streamContents: [:stream | self exportOn: stream]
    ]

    exportBodyOn: aStream [
	<category: 'exporting'>
	self cache withIndexDo: 
		[:row :index | 
		self visibleColumns do: 
			[:column | 
			column 
			    exportContent: (column valueFor: row)
			    index: index
			    on: aStream]
		    separatedBy: [aStream tab].
		aStream cr]
    ]

    exportHeaderOn: aStream [
	<category: 'exporting'>
	self visibleColumns do: [:each | each exportHeadOn: aStream]
	    separatedBy: [aStream tab].
	aStream cr
    ]

    exportOn: aStream [
	<category: 'exporting'>
	self showHeader ifTrue: [self exportHeaderOn: aStream].
	self showBody ifTrue: [self exportBodyOn: aStream]
    ]

    filterRows: aCollection [
	<category: 'private'>
	^self hasRowFilter 
	    ifFalse: [aCollection]
	    ifTrue: [aCollection select: self rowFilter]
    ]

    hasMoreThanOnePage [
	<category: 'testing'>
	^self batchSize < self cache size
    ]

    hasRowFilter [
	<category: 'testing'>
	^self rowFilter notNil
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	rows := columns := Array new.
	properties := Dictionary new.
	backtracked := Dictionary new
    ]

    isOnFirstPage [
	<category: 'private-batch'>
	^self batchPage = 1
    ]

    isOnLastPage [
	<category: 'private-batch'>
	^self batchPage = self batchMaxPages
    ]

    isSorted [
	<category: 'testing'>
	^self sortColumn notNil
    ]

    moveDown: aColumn [
	<category: 'columns'>
	| index |
	index := self columns indexOf: aColumn ifAbsent: [^self].
	self columns swap: index
	    with: (index = self size ifFalse: [index + 1] ifTrue: [1])
    ]

    moveUp: aColumn [
	<category: 'columns'>
	| index |
	index := self columns indexOf: aColumn ifAbsent: [^self].
	self columns swap: index
	    with: (index = 1 ifFalse: [index - 1] ifTrue: [self size])
    ]

    nextPage [
	<category: 'actions'>
	self isOnLastPage ifFalse: [self batchPage: self batchPage + 1]
    ]

    previousPage [
	<category: 'actions'>
	self isOnFirstPage ifFalse: [self batchPage: self batchPage - 1]
    ]

    refresh [
	<category: 'actions'>
	self
	    cache: nil;
	    batchPage: self defaultBatchPage.
	self columns do: [:each | each refresh]
    ]

    remove: aColumn [
	<category: 'columns'>
	columns := columns copyWithout: aColumn
    ]

    renderBatchFirstOn: html [
	<category: 'rendering-batch'>
	self isOnFirstPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self batchPage: self defaultBatchPage];
		    with: '|<']
	    ifTrue: [html text: '|<'].
	html space
    ]

    renderBatchItemsOn: html [
	<category: 'rendering-batch'>
	self batchPageRangeStart > self defaultBatchPage 
	    ifTrue: 
		[html
		    text: '...';
		    space].
	self batchPageRange do: 
		[:index | 
		self batchPage = index 
		    ifFalse: 
			[(html anchor)
			    callback: [self batchPage: index];
			    with: index]
		    ifTrue: 
			[(html span)
			    class: 'current';
			    with: index].
		html space].
	self batchPageRangeEnd < (self batchMaxPages - 1) 
	    ifTrue: 
		[html
		    text: '...';
		    space].
	self batchPageRangeEnd = self batchMaxPages 
	    ifFalse: 
		[(html anchor)
		    callback: [self batchPage: self batchMaxPages];
		    with: self batchMaxPages]
    ]

    renderBatchLastOn: html [
	<category: 'rendering-batch'>
	self isOnLastPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self batchPage: self batchMaxPages];
		    with: '>|']
	    ifTrue: [html text: '>|']
    ]

    renderBatchNextOn: html [
	<category: 'rendering-batch'>
	self isOnLastPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self nextPage];
		    with: '>>']
	    ifTrue: [html text: '>>'].
	html space
    ]

    renderBatchPreviousOn: html [
	<category: 'rendering-batch'>
	self isOnFirstPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self previousPage];
		    with: '<<']
	    ifTrue: [html text: '<<'].
	html space
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html table)
	    id: self ajaxId;
	    class: 'report';
	    with: [self renderTableOn: html]
    ]

    renderTableBatchOn: html [
	<category: 'rendering-table'>
	self hasMoreThanOnePage 
	    ifTrue: 
		[html tableRow: 
			[(html tableData)
			    class: 'batch';
			    colSpan: self visibleColumns size;
			    with: 
				    [self showBatchFirstLast ifTrue: [self renderBatchFirstOn: html].
				    self showBatchPreviousNext ifTrue: [self renderBatchPreviousOn: html].
				    self showBatchPages ifTrue: [self renderBatchItemsOn: html].
				    self showBatchPreviousNext ifTrue: [self renderBatchNextOn: html].
				    self showBatchFirstLast ifTrue: [self renderBatchLastOn: html]]]]
    ]

    renderTableBodyOn: html [
	<category: 'rendering-table'>
	self visible isEmpty 
	    ifTrue: 
		[(html tableRow)
		    class: 'empty';
		    with: 
			    [(html tableData)
				colSpan: self visibleColumns size;
				with: self tableEmpty]]
	    ifFalse: 
		[self visible keysAndValuesDo: 
			[:index :row | 
			(html tableRow)
			    class: (self rowStyleForNumber: index);
			    with: 
				    [self visibleColumns do: 
					    [:col | 
					    col 
						renderCell: row
						index: index
						on: html]]]]
    ]

    renderTableCaptionOn: html [
	<category: 'rendering-table'>
	(html tag: 'caption') with: self tableCaption
    ]

    renderTableFootOn: html [
	<category: 'rendering-table'>
	html 
	    tableRow: [self visibleColumns do: [:each | each renderFootCellOn: html]]
    ]

    renderTableHeadOn: html [
	<category: 'rendering-table'>
	html 
	    tableRow: [self visibleColumns do: [:each | each renderHeadCellOn: html]]
    ]

    renderTableOn: html [
	<category: 'rendering'>
	self showCaption ifTrue: [self renderTableCaptionOn: html].
	self showSummary ifTrue: [self renderTableSummaryOn: html].
	html tableHead: [self showHeader ifTrue: [self renderTableHeadOn: html]].
	((self showBatch and: [self hasMoreThanOnePage]) or: [self showFooter]) 
	    ifTrue: 
		["we must not produce an empty tfoot element, this is not valid xhtml"

		html tableFoot: 
			[self showFooter ifTrue: [self renderTableFootOn: html].
			self showBatch ifTrue: [self renderTableBatchOn: html]]].
	html tableBody: [self showBody ifTrue: [self renderTableBodyOn: html]]
    ]

    renderTableSummaryOn: html [
	<category: 'rendering-table'>
	(html tag: 'summary') with: self tableSummary
    ]

    rowFilter [
	<category: 'accessing-settings'>
	^backtracked at: #rowFilter ifAbsent: [self defaultRowFilter]
    ]

    rowFilter: aBlock [
	<category: 'accessing-settings'>
	backtracked at: #rowFilter put: aBlock.
	self refresh
    ]

    rowPeriod [
	<category: 'accessing-settings'>
	^properties at: #rowPeriod ifAbsent: [self defaultRowPeriod]
    ]

    rowPeriod: aNumber [
	<category: 'accessing-settings'>
	properties at: #rowPeriod put: aNumber
    ]

    rowStyleForNumber: aNumber [
	<category: 'private'>
	^self rowStyles 
	    at: (aNumber - 1) // self rowPeriod \\ self rowStyles size + 1
	    ifAbsent: [String new]
    ]

    rowStyles [
	<category: 'accessing-settings'>
	^properties at: #rowStyles ifAbsent: [self defaultRowStyles]
    ]

    rowStyles: aCollection [
	<category: 'accessing-settings'>
	properties at: #rowStyles put: aCollection
    ]

    rows [
	"Return the rows of the receiver."

	<category: 'accessing'>
	^rows
    ]

    rows: aCollection [
	"Set the rows of the receiver."

	<category: 'accessing'>
	aCollection = rows ifTrue: [^self].
	rows := aCollection.
	self refresh
    ]

    showBatch [
	<category: 'accessing-settings'>
	^properties at: #showBatch ifAbsent: [self defaultShowBatch]
    ]

    showBatch: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showBatch put: aBoolean
    ]

    showBatchFirstLast [
	<category: 'accessing-settings'>
	^properties at: #showBatchFirstLast
	    ifAbsent: [self defaultShowBatchFirstLast]
    ]

    showBatchFirstLast: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showBatchFirstLast put: aBoolean
    ]

    showBatchPages [
	<category: 'accessing-settings'>
	^properties at: #showBatchPages ifAbsent: [self defaultShowBatchPages]
    ]

    showBatchPages: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showBatchPages put: aBoolean
    ]

    showBatchPreviousNext [
	<category: 'accessing-settings'>
	^properties at: #showBatchPreviousNext
	    ifAbsent: [self defaultShowBatchPreviousNext]
    ]

    showBatchPreviousNext: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showBatchPreviousNext put: aBoolean
    ]

    showBody [
	<category: 'accessing-settings'>
	^properties at: #showBody ifAbsent: [self defaultShowBody]
    ]

    showBody: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showBody put: aBoolean
    ]

    showCaption [
	<category: 'accessing-settings'>
	^properties at: #showCaption ifAbsent: [self defaultShowCaption]
    ]

    showCaption: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showCaption put: aBoolean
    ]

    showFooter [
	<category: 'accessing-settings'>
	^properties at: #showFooter ifAbsent: [self defaultShowFooter]
    ]

    showFooter: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showFooter put: aBoolean
    ]

    showHeader [
	<category: 'accessing-settings'>
	^properties at: #showHeader ifAbsent: [self defaultShowHeader]
    ]

    showHeader: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showHeader put: aBoolean
    ]

    showSummary [
	<category: 'accessing-settings'>
	^properties at: #showSummary ifAbsent: [self defaultShowSummary]
    ]

    showSummary: aBoolean [
	<category: 'accessing-settings'>
	properties at: #showSummary put: aBoolean
    ]

    sort: aColumn [
	<category: 'actions'>
	aColumn = self sortColumn 
	    ifTrue: 
		[self sortReversed 
		    ifFalse: [self sortReversed: true]
		    ifTrue: 
			[self
			    sortColumn: nil;
			    sortReversed: false]]
	    ifFalse: 
		[self
		    sortColumn: aColumn;
		    sortReversed: false].
	self refresh
    ]

    sortColumn [
	<category: 'accessing-settings'>
	^backtracked at: #sortColumn ifAbsent: [self defaultSortColumn]
    ]

    sortColumn: aColumn [
	<category: 'accessing-settings'>
	backtracked at: #sortColumn put: aColumn
    ]

    sortEnabled [
	<category: 'accessing-settings'>
	^properties at: #sortEnabled ifAbsent: [self defaultSortEnabled]
    ]

    sortEnabled: aBoolean [
	<category: 'accessing-settings'>
	properties at: #sortEnabled put: aBoolean
    ]

    sortReversed [
	<category: 'accessing-settings'>
	^backtracked at: #sortReversed ifAbsent: [self defaultSortReversed]
    ]

    sortReversed: aBoolean [
	<category: 'accessing-settings'>
	backtracked at: #sortReversed put: aBoolean
    ]

    sortRows: aCollection [
	<category: 'private'>
	^self isSorted 
	    ifFalse: [aCollection]
	    ifTrue: [self sortColumn sortRows: aCollection]
    ]

    sorterStyles [
	<category: 'accessing-settings'>
	^properties at: #sorterStyles ifAbsent: [self defaultSorterStyles]
    ]

    sorterStyles: aCollection [
	<category: 'accessing-settings'>
	properties at: #sorterStyles put: aCollection
    ]

    states [
	<category: 'accessing-readonly'>
	^Array with: backtracked
    ]

    tableCaption [
	<category: 'accessing-settings'>
	^properties at: #tableCaption ifAbsent: [self defaultTableCaption]
    ]

    tableCaption: aString [
	<category: 'accessing-settings'>
	properties at: #tableCaption put: aString
    ]

    tableEmpty [
	<category: 'accessing-settings'>
	^properties at: #tableEmpty ifAbsent: [self defaultTableEmpty]
    ]

    tableEmpty: aString [
	<category: 'accessing-settings'>
	properties at: #tableEmpty put: aString
    ]

    tableSummary [
	<category: 'accessing-settings'>
	^properties at: #tableSummary ifAbsent: [self defaultTableSummary]
    ]

    tableSummary: aString [
	<category: 'accessing-settings'>
	properties at: #tableSummary put: aString
    ]

    visible [
	<category: 'accessing-readonly'>
	^self showBatch 
	    ifFalse: [self cache]
	    ifTrue: [self cache copyFrom: self batchStartIndex to: self batchEndIndex]
    ]

    visibleColumns [
	<category: 'accessing-readonly'>
	^self columns select: [:each | each isVisible]
    ]
]



Seaside.WAComponent subclass: MAExampleEditor [
    | description report |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Examples'>

    MAExampleEditor class >> description: aDescription [
	<category: 'instance-creation'>
	^(self new)
	    description: aDescription;
	    yourself
    ]

    buildEditorFor: anObject titled: aString [
	<category: 'private'>
	^(anObject asComponent)
	    addValidatedForm;
	    addMessage: aString;
	    yourself
    ]

    buildReport [
	<category: 'private'>
	self subclassResponsibility
    ]

    cancel [
	<category: 'actions'>
	self answer: nil
    ]

    children [
	<category: 'accessing'>
	^Array with: self report
    ]

    defaultDescription [
	<category: 'accessing-configuration'>
	self subclassResponsibility
    ]

    description [
	<category: 'accessing'>
	^description ifNil: [description := self defaultDescription]
    ]

    description: aDescription [
	<category: 'accessing'>
	description := aDescription
    ]

    edit [
	<category: 'actions'>
	self call: (self buildEditorFor: description titled: 'Edit Container')
    ]

    moveDown: aDescription [
	<category: 'actions-items'>
	self description moveDown: aDescription.
	self refresh
    ]

    moveUp: aDescription [
	<category: 'actions-items'>
	self description moveUp: aDescription.
	self refresh
    ]

    preview [
	<category: 'actions'>
	self subclassResponsibility
    ]

    refresh [
	<category: 'actions'>
	self report rows: self description children; refresh
    ]

    renderButtonsOn: html [
	<category: 'rendering'>
	html submitButton on: #edit of: self.
	html submitButton on: #preview of: self
    ]

    renderChildrenOn: html [
	<category: 'rendering'>
	html render: self children
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html form: 
		[self renderChildrenOn: html.	"One of the children supplies input for the form"
		self renderButtonsOn: html]
    ]

    report [
	<category: 'accessing'>
	^report ifNil: [report := self buildReport]
    ]

    save [
	<category: 'actions'>
	self answer: self description
    ]
]



MAExampleEditor subclass: MADescriptionEditor [
    | example selected selectedComponent |
    
    <comment: nil>
    <category: 'Magritte-Seaside-Examples'>

    MADescriptionEditor class >> example [
	<category: 'examples'>
	^self new
    ]

    addDescription: aDescription [
	<category: 'actions-items'>
	| element |
	element := self call: (self buildEditorFor: aDescription
			    titled: 'Add ' , aDescription class label).
	element isNil ifTrue: [^self].
	self description add: element.
	self refresh
    ]

    buildReport [
	<category: 'private'>
	^(MAReport rows: self description children
	    description: MAElementDescription description)
	    addColumn: ((MAColumn new)
			cascade: #(#description #label);
			title: 'Kind';
			yourself);
	    addColumn: ((MACommandColumn new)
			addCommandOn: self
			    selector: #editDescription:
			    text: 'edit';
			addCommandOn: self
			    selector: #moveUp:
			    text: 'up';
			addCommandOn: self
			    selector: #moveDown:
			    text: 'down';
			addCommandOn: self
			    selector: #removeDescription:
			    text: 'remove';
			yourself);
	    yourself
    ]

    children [
	<category: 'rendering'>
	^super children copyWith: selectedComponent
    ]

    defaultDescription [
	<category: 'accessing-configuration'>
	^MAContainer new
    ]

    defaultDescriptionClasses [
	<category: 'accessing-configuration'>
	^(OrderedCollection new)
	    add: MAStringDescription;
	    add: MAMemoDescription;
	    add: MASymbolDescription;
	    add: MAPasswordDescription;
	    add: nil;
	    add: MABooleanDescription;
	    add: MASingleOptionDescription;
	    add: MAMultipleOptionDescription;
	    add: MAToOneRelationDescription;
	    add: MAToManyRelationDescription;
	    add: nil;
	    add: MANumberDescription;
	    add: MADurationDescription;
	    add: MADateDescription;
	    add: MATimeDescription;
	    add: MATimeStampDescription;
	    add: nil;
	    add: MATokenDescription;
	    add: nil;
	    add: MAFileDescription;
	    add: MAClassDescription;
	    add: MATableDescription;
	    yourself
    ]

    defaultExampleInstance [
	<category: 'accessing-configuration'>
	^MAAdaptiveModel description: self description
    ]

    editDescription: aDescription [
	<category: 'actions-items'>
	self call: (self buildEditorFor: aDescription
		    titled: 'Edit ' , aDescription class label).
	self refresh
    ]

    example [
	<category: 'accessing'>
	^example ifNil: [example := self defaultExampleInstance]
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	selected := MADescriptionHolder new.
	selectedComponent := selected asComponent
    ]

    preview [
	<category: 'actions'>
	self call: ((self example asComponent)
		    addMessage: self description label;
		    addValidatedForm;
		    yourself)
    ]

    removeDescription: aDescription [
	<category: 'actions-items'>
	self description remove: aDescription.
	self refresh
    ]

    renderButtonsOn: html [
	<category: 'rendering'>
	(html submitButton)
	    callback: 
		    [selectedComponent save.
		    selected contents ifNotNil: [:class | self addDescription: class new]];
	    text: 'Add'.
	super renderButtonsOn: html
    ]
]



MAToManyRelationDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-accessing-defaults'>
	^Array with: MAOneToManyComponent
    ]

]



MATableDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MATableComponent
    ]

]



MATokenDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MATextInputComponent
    ]

]



MAMemoDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MATextAreaComponent
    ]

]



MAContainer class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MAContainerComponent
    ]

    defaultComponentRenderer [
	<category: '*magritte-seaside-defaults'>
	^MATableRenderer
    ]

]



MAContainer extend [

    asComponentOn: anObject [
	<category: '*magritte-seaside-converting'>
	^self componentClass 
	    memento: (anObject mementoClass model: anObject description: self)
    ]

    componentRenderer [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #componentRenderer
	    ifAbsent: [self class defaultComponentRenderer]
    ]

    componentRenderer: aClass [
	<category: '*magritte-seaside-accessing'>
	self propertyAt: #componentRenderer put: aClass
    ]

]



MAStringDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MATextInputComponent
    ]

]



MAFileModel extend [

    renderImageOn: html [
	<category: '*magritte-seaside-rendering'>
	html image url: (self urlOn: html)
    ]

    renderMediaOn: html [
	<category: '*magritte-seaside-rendering'>
	(html tag: 'object')
	    attributeAt: 'src' put: (self urlOn: html);
	    attributeAt: 'type' put: self mimetype
    ]

    renderOn: html [
	<category: '*magritte-seaside-rendering'>
	self isText ifTrue: [^self renderTextOn: html].
	self isImage ifTrue: [^self renderImageOn: html].
	self isAudio | self isVideo ifTrue: [^self renderMediaOn: html].
	^self renderUnknownOn: html
    ]

    renderTextOn: html [
	<category: '*magritte-seaside-rendering'>
	| stream |
	stream := self contents readStream.
	html preformatted: 
		[html text: (stream next: 800).
		stream atEnd ifFalse: [html text: '...']]
    ]

    renderUnknownOn: html [
	<category: '*magritte-seaside-rendering'>
	(html anchor)
	    url: (self urlOn: html);
	    with: self filename
    ]

    urlOn: html [
	<category: '*magritte-seaside-rendering'>
	^html context 
	    urlForDocument: self contents
	    mimeType: self mimetype
	    fileName: self filename
    ]

]



MAExternalFileModel extend [

    urlOn: html [
	<category: '*magritte-seaside-accessing'>
	^self baseUrl isNil 
	    ifTrue: [super urlOn: html]
	    ifFalse: 
		[self baseUrl , '/' , (self location reduce: [:a :b | a , '/' , b]) , '/' 
		    , self filename]
    ]

]



MASingleOptionDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MASelectListComponent with: MARadioGroupComponent
    ]

]



MAMultipleErrors extend [

    renderOn: html [
	<category: '*magritte-seaside-rendering'>
	html unorderedList: [self collection do: [:each | html listItem: each]]
    ]

]



Object subclass: MAColumn [
    | report properties |
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    MAColumn class >> descriptionComment [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #comment;
	    label: 'Comment';
	    priority: 200;
	    yourself
    ]

    MAColumn class >> descriptionTitle [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #title;
	    label: 'Title';
	    priority: 100;
	    yourself
    ]

    MAColumn class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    cascade [
	<category: 'accessing-settings'>
	^self propertyAt: #cascade ifAbsent: [self defaultCascade]
    ]

    cascade: anArray [
	<category: 'accessing-settings'>
	self propertyAt: #cascade put: anArray
    ]

    column [
	<category: 'accessing'>
	^self report cache collect: [:each | self valueFor: each]
    ]

    comment [
	<category: 'accessing-settings'>
	^self propertyAt: #comment ifAbsent: [self defaultComment]
    ]

    comment: aString [
	<category: 'accessing-settings'>
	self propertyAt: #comment put: aString
    ]

    defaultCascade [
	<category: 'accessing-defaults'>
	^#(#yourself)
    ]

    defaultComment [
	<category: 'accessing-defaults'>
	^nil
    ]

    defaultFooter [
	<category: 'accessing-defaults'>
	^nil
    ]

    defaultFormat [
	<category: 'accessing-defaults'>
	^DirectedMessage receiver: self selector: #renderCellContent:on:
    ]

    defaultSorter [
	<category: 'accessing-defaults'>
	^
	[:a :b | 
	| x y |
	(x := self valueFor: a) isNil 
	    or: [(y := self valueFor: b) notNil and: [x <= y]]]
    ]

    defaultTitle [
	<category: 'accessing-defaults'>
	^self cascade first asCapitalizedPhrase
    ]

    defaultVisible [
	<category: 'accessing-defaults'>
	^true
    ]

    exportContent: anObject index: aNumber on: aStream [
	<category: 'exporting'>
	aStream nextPutAll: (anObject asString 
		    collect: [:each | each isSeparator ifTrue: [Character space] ifFalse: [each]])
    ]

    exportHeadOn: aStream [
	<category: 'exporting'>
	self title isNil ifFalse: [aStream nextPutAll: self title]
    ]

    footer [
	<category: 'accessing-settings'>
	^self propertyAt: #footer ifAbsent: [self defaultFooter]
    ]

    footer: aBlock [
	<category: 'accessing-settings'>
	self propertyAt: #footer put: aBlock
    ]

    format [
	<category: 'accessing-settings'>
	^self propertyAt: #format ifAbsent: [self defaultFormat]
    ]

    format: aBlock [
	<category: 'accessing-settings'>
	self propertyAt: #format put: aBlock
    ]

    index [
	<category: 'accessing'>
	^self report columns indexOf: self
    ]

    initialize [
	<category: 'initialization'>
	properties := Dictionary new
    ]

    isReversed [
	<category: 'testing'>
	^self report sortReversed
    ]

    isSortable [
	<category: 'testing'>
	^self report sortEnabled and: [self sorter notNil]
    ]

    isSorted [
	<category: 'testing'>
	^self report sortColumn = self
    ]

    isVisible [
	<category: 'testing'>
	^self visible
    ]

    properties [
	<category: 'accessing-properties'>
	^properties
    ]

    propertyAt: aSymbol [
	<category: 'accessing-properties'>
	^self properties at: aSymbol
    ]

    propertyAt: aSymbol ifAbsent: aBlock [
	<category: 'accessing-properties'>
	^self properties at: aSymbol ifAbsent: aBlock
    ]

    propertyAt: aSymbol ifAbsentPut: aBlock [
	<category: 'accessing-properties'>
	^self properties at: aSymbol ifAbsentPut: aBlock
    ]

    propertyAt: aSymbol put: anObject [
	<category: 'accessing-properties'>
	^self properties at: aSymbol put: anObject
    ]

    refresh [
	<category: 'actions'>
	
    ]

    renderCell: anObject index: anInteger on: html [
	<category: 'rendering'>
	html tableData: 
		[self format 
		    valueWithArguments: ((Array 
			    with: anObject
			    with: html
			    with: anInteger) first: self format numArgs)]
    ]

    renderCellContent: anObject on: html [
	<category: 'rendering'>
	html render: (self valueFor: anObject)
    ]

    renderFootCellOn: html [
	<category: 'rendering'>
	html tableData: [self renderFootContentOn: html]
    ]

    renderFootContentOn: html [
	<category: 'rendering'>
	self footer isNil ifFalse: [html render: self footer]
    ]

    renderHeadCellOn: html [
	<category: 'rendering'>
	(html tableData)
	    class: self sorterStyle;
	    title: (self comment ifNil: ['']);
	    with: 
		    [self isSortable 
			ifFalse: [self renderHeadContentOn: html]
			ifTrue: 
			    [(html anchor)
				callback: [self report sort: self];
				with: [self renderHeadContentOn: html]]]
    ]

    renderHeadContentOn: html [
	<category: 'rendering'>
	html render: self title
    ]

    report [
	<category: 'accessing'>
	^report
    ]

    selector: aSymbol [
	<category: 'actions'>
	self cascade: (Array with: aSymbol)
    ]

    setReport: aReport [
	<category: 'initialization'>
	report := aReport
    ]

    sortRows: aCollection [
	<category: 'actions'>
	| result |
	result := SortedCollection new: aCollection size.
	result
	    sortBlock: self sorter;
	    addAll: aCollection.
	^self isReversed ifFalse: [result] ifTrue: [result reversed]
    ]

    sorter [
	<category: 'accessing-settings'>
	^self propertyAt: #sorter ifAbsent: [self defaultSorter]
    ]

    sorter: aBlock [
	<category: 'accessing-settings'>
	self propertyAt: #sorter put: aBlock
    ]

    sorterStyle [
	<category: 'accessing'>
	^self isSorted 
	    ifTrue: 
		[self isReversed 
		    ifTrue: [self report sorterStyles first]
		    ifFalse: [self report sorterStyles second]]
	    ifFalse: [String new]
    ]

    title [
	<category: 'accessing-settings'>
	^self propertyAt: #title ifAbsent: [self defaultTitle]
    ]

    title: aString [
	<category: 'accessing-settings'>
	self propertyAt: #title put: aString
    ]

    valueFor: aRow [
	<category: 'actions'>
	^self cascade inject: aRow into: [:result :each | result perform: each]
    ]

    visible [
	<category: 'accessing-settings'>
	^self propertyAt: #visible ifAbsent: [self defaultVisible]
    ]

    visible: aBoolean [
	<category: 'accessing-settings'>
	self propertyAt: #visible put: aBoolean
    ]
]



MAColumn subclass: MAActionColumn [
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    defaultTitle [
	<category: 'accessing-defaults'>
	^String new
    ]

    defaultUseLinks [
	<category: 'accessing-defaults'>
	^true
    ]

    renderCellContent: anObject on: html [
	<category: 'rendering'>
	self useLinks 
	    ifTrue: [self renderCellLinkContent: anObject on: html]
	    ifFalse: [self renderCellFormContent: anObject on: html]
    ]

    renderCellFormContent: anObject on: html [
	<category: 'rendering'>
	self subclassResponsibility
    ]

    renderCellLinkContent: anObject on: html [
	<category: 'rendering'>
	self subclassResponsibility
    ]

    useLinks [
	<category: 'accessing'>
	^self propertyAt: #useLinks ifAbsent: [self defaultUseLinks]
    ]

    useLinks: aBoolean [
	<category: 'accessing'>
	self propertyAt: #useLinks put: aBoolean
    ]
]



MAActionColumn subclass: MACommandColumn [
    | commands |
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    addCommand: aBlock text: aString [
	<category: 'actions'>
	self commands add: aBlock -> aString
    ]

    addCommandOn: anObject selector: aSelector [
	<category: 'actions'>
	self 
	    addCommandOn: anObject
	    selector: aSelector
	    text: aSelector allButLast asCapitalizedPhrase
    ]

    addCommandOn: anObject selector: aSelector text: aString [
	<category: 'actions'>
	self addCommand: (DirectedMessage receiver: anObject selector: aSelector)
	    text: aString
    ]

    commands [
	<category: 'accessing'>
	^commands
    ]

    commands: aCollection [
	<category: 'accessing'>
	commands := aCollection
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self commands: OrderedCollection new
    ]

    renderCellFormContent: anObject on: html [
	<category: 'rendering'>
	self commands do: 
		[:each | 
		(html submitButton)
		    callback: [each key value: anObject];
		    text: each value]
	    separatedBy: [html space]
    ]

    renderCellLinkContent: anObject on: html [
	<category: 'rendering'>
	self commands do: 
		[:each | 
		(html anchor)
		    callback: [each key value: anObject];
		    with: each value]
	    separatedBy: [html space]
    ]
]



MACommandColumn subclass: MAIndexedCommandColumn [
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    defaultFormat [
	<category: 'accessing-defaults'>
	^DirectedMessage receiver: self selector: #renderCellContent:on:index:
    ]

    renderCellContent: anObject on: html index: anInteger [
	<category: 'rendering'>
	self commands do: 
		[:each | 
		(html anchor)
		    callback: 
			    [each key valueWithArguments: (Array with: anObject with: anInteger)];
		    with: each value]
	    separatedBy: [html space]
    ]
]



MAActionColumn subclass: MASelectionColumn [
    | selection |
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    defaultFormDeselected [
	<category: 'accessing-defaults'>
	self subclassResponsibility
    ]

    defaultFormSelected [
	<category: 'accessing-defaults'>
	self subclassResponsibility
    ]

    defaultSelection [
	<category: 'accessing-defaults'>
	self subclassResponsibility
    ]

    deselectRow: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    formDeselected [
	<category: 'accessing-settings'>
	^self propertyAt: #formDeselected ifAbsent: [self defaultFormDeselected]
    ]

    formDeselected: aForm [
	<category: 'accessing-settings'>
	^self propertyAt: #formDeselected put: aForm
    ]

    formSelected [
	<category: 'accessing-settings'>
	^self propertyAt: #formSelected ifAbsent: [self defaultFormSelected]
    ]

    formSelected: aForm [
	<category: 'accessing-settings'>
	^self propertyAt: #formSelected put: aForm
    ]

    isSelected: anObject [
	<category: 'testing'>
	self subclassResponsibility
    ]

    refresh [
	<category: 'actions'>
	super refresh.
	self selection: self defaultSelection
    ]

    renderCellLinkContent: anObject on: html [
	<category: 'rendering'>
	| selected |
	selected := self isSelected: anObject.
	(html anchor)
	    callback: [self selectRow: anObject value: selected not];
	    with: 
		    [html image 
			form: (selected ifTrue: [self formSelected] ifFalse: [self formDeselected])]
    ]

    selectRow: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    selectRow: anObject value: aBoolean [
	<category: 'actions'>
	aBoolean 
	    ifTrue: [self selectRow: anObject]
	    ifFalse: [self deselectRow: anObject]
    ]

    selection [
	<category: 'accessing'>
	selection isNil ifTrue: [self selection: self defaultSelection].
	^selection
    ]

    selection: anObject [
	<category: 'accessing'>
	selection := anObject
    ]
]



MASelectionColumn subclass: MACheckboxColumn [
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    defaultFormDeselected [
	<category: 'accessing-defaults'>
	^ScriptingSystem formAtKey: #CheckBoxOff
    ]

    defaultFormSelected [
	<category: 'accessing-defaults'>
	^ScriptingSystem formAtKey: #CheckBoxOn
    ]

    defaultSelection [
	<category: 'accessing-defaults'>
	^Set new
    ]

    deselectRow: anObject [
	<category: 'actions'>
	self selection remove: anObject ifAbsent: nil
    ]

    isSelected: anObject [
	<category: 'testing'>
	^self selection includes: anObject
    ]

    renderCellFormContent: anObject on: html [
	<category: 'rendering'>
	(html checkbox)
	    value: (self isSelected: anObject);
	    callback: [:value | self selectRow: anObject value: value]
    ]

    selectRow: anObject [
	<category: 'actions'>
	self selection add: anObject
    ]
]



MASelectionColumn subclass: MAOptionboxColumn [
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    defaultFormDeselected [
	<category: 'accessing-defaults'>
	^ScriptingSystem formDictionary formAtKey: #RadioButtonOff
    ]

    defaultFormSelected [
	<category: 'accessing-defaults'>
	^ScriptingSystem formAtKey: #RadioButtonOn
    ]

    defaultSelection [
	<category: 'accessing-defaults'>
	^nil
    ]

    deselectRow: anObject [
	<category: 'actions'>
	self selection: nil
    ]

    isSelected: anObject [
	<category: 'testing'>
	^self selection == anObject
    ]

    radioGroupFor: html [
	"This is a very bad thing, you might never have seen in your own life. Very strange things might happen here, but for now it mostly does what we need."

	<category: 'private'>
	| renderer |
	renderer := self propertyAt: #radioGroupRenderer ifAbsentPut: nil.
	^renderer == html 
	    ifTrue: [self propertyAt: #radioGroupCallback]
	    ifFalse: 
		[self propertyAt: #radioGroupRenderer put: html.
		self propertyAt: #radioGroupCallback put: html radioGroup]
    ]

    renderCellFormContent: anObject on: html [
	<category: 'rendering'>
	(html radioButton)
	    group: (self radioGroupFor: html);
	    selected: (self isSelected: anObject);
	    callback: [self selectRow: anObject]
    ]

    selectRow: anObject [
	<category: 'actions'>
	self selection: anObject
    ]
]



MAColumn subclass: MADescribedColumn [
    | description |
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    defaultCascade [
	<category: 'accessing-defaults'>
	self shouldNotImplement
    ]

    defaultSorter [
	<category: 'accessing-defaults'>
	^self description isSortable ifTrue: [super defaultSorter]
    ]

    defaultTitle [
	<category: 'accessing-defaults'>
	^self description label
    ]

    defaultVisible [
	<category: 'accessing-defaults'>
	^self description isVisible
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    exportContent: anObject index: aNumber on: aStream [
	<category: 'exporting'>
	super 
	    exportContent: (self description toString: anObject)
	    index: aNumber
	    on: aStream
    ]

    renderCellContent: anObject on: html [
	<category: 'rendering'>
	html render: (self description toString: (self valueFor: anObject))
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	description := aDescription
    ]

    valueFor: aRow [
	<category: 'actions'>
	^(aRow readUsing: self description) ifNil: [self description default]
    ]
]



MADescribedColumn subclass: MADescribedComponentColumn [
    | component |
    
    <category: 'Magritte-Seaside-Report'>
    <comment: 'This column uses the component of a description to render the cell value.'>

    NOW [
	"very experimental ... use only if you're willing to fix bugs
	 this only works for readonly views without callbacks
	 on the positive side: only one component per column is created"

	<category: 'readme'>
	
    ]

    component [
	<category: 'accessing'>
	component isNil 
	    ifTrue: 
		[component := (self description componentClass new)
			    setDescription: self description;
			    yourself].
	^component
    ]

    renderCellContent: anObject on: html [
	<category: 'rendering'>
	self component setMemento: (anObject mementoClass model: anObject
		    description: self description asContainer).
	self component renderViewerOn: html
    ]
]



MADescribedColumn subclass: MADescribedScalarColumn [
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    renderCellContent: anObject on: html [
	<category: 'rendering'>
	html 
	    render: (self description reference toString: (self valueFor: anObject))
    ]

    valueFor: aRow [
	<category: 'actions'>
	^aRow
    ]
]



MADescribedColumn subclass: MAToggleColumn [
    
    <category: 'Magritte-Seaside-Report'>
    <comment: nil>

    renderCellContent: anObject on: html [
	<category: 'rendering'>
	| value |
	value := self valueFor: anObject.
	(html anchor)
	    callback: [anObject write: value not using: self description];
	    with: (self description toString: value)
    ]
]



Object extend [

    asComponent [
	<category: '*magritte-seaside-converting'>
	^self description asComponentOn: self
    ]

]



MATimeDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside'>
	^Array with: MATimeInputComponent with: MATimeSelectorComponent
    ]

]



MATimeStampDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside'>
	^Array with: MATimeStampInputComponent
    ]

]



MABooleanDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array 
	    with: MACheckboxComponent
	    with: MASelectListComponent
	    with: MARadioGroupComponent
    ]

]



MANumberDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside'>
	^Array with: MATextInputComponent with: MARangeComponent
    ]

]



MAMultipleOptionDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array 
	    with: MAMultiselectListComponent
	    with: MACheckboxGroupComponent
	    with: MAListCompositonComponent
    ]

]



MAToOneRelationDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MAExternalEditorComponent with: MAInternalEditorComponent
    ]

]



MAToManyScalarRelationDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-accessing-defaults'>
	^Array with: MAOneToManyScalarComponent
    ]

    defaultReportColumnClasses [
	<category: '*magritte-seaside-accessing-defaults'>
	^Array with: MADescribedScalarColumn
    ]

]



MADescription class extend [

    defaultComponentClass [
	<category: '*magritte-seaside-defaults'>
	^self defaultComponentClasses isEmpty 
	    ifTrue: [MAUndefinedComponent]
	    ifFalse: [self defaultComponentClasses first]
    ]

    defaultComponentClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MAUndefinedComponent
    ]

    defaultCssClasses [
	<category: '*magritte-seaside-defaults'>
	^OrderedCollection new
    ]

    defaultReportColumnClass [
	<category: '*magritte-seaside-defaults'>
	^self defaultReportColumnClasses notEmpty 
	    ifTrue: [self defaultReportColumnClasses first]
    ]

    defaultReportColumnClasses [
	<category: '*magritte-seaside-defaults'>
	^Array with: MADescribedColumn
    ]

    descriptionComponentClass [
	<category: '*magritte-seaside-description'>
	^(MASingleOptionDescription new)
	    accessor: #componentClass;
	    label: 'Component Class';
	    reference: MAClassDescription new;
	    options: self defaultComponentClasses;
	    default: self defaultComponentClass;
	    priority: 1000;
	    yourself
    ]

    descriptionReportColumnClass [
	<category: '*magritte-seaside-description'>
	^(MASingleOptionDescription new)
	    accessor: #reportColumnClass;
	    label: 'Report Column Class';
	    priority: 1010;
	    reference: MAClassDescription new;
	    options: self defaultReportColumnClasses;
	    default: self defaultReportColumnClass;
	    yourself
    ]
]




MADescription extend [

    componentClass [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #componentClass
	    ifAbsent: [self class defaultComponentClass]
    ]

    componentClass: aClass [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #componentClass put: aClass
    ]

    cssClass: aString [
	<category: '*magritte-seaside-accessing'>
	(self propertyAt: #cssClasses ifAbsentPut: [self class defaultCssClasses]) 
	    add: aString
    ]

    cssClasses [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #cssClasses ifAbsent: [self class defaultCssClasses]
    ]

    cssClasses: aCollection [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #cssClasses put: aCollection
    ]

    reportColumnClass [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #reportColumnClass
	    ifAbsent: [self class defaultReportColumnClass]
    ]

    reportColumnClass: aClass [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #reportColumnClass put: aClass
    ]

]



MAElementDescription extend [

    checkboxLabel [
	<category: '*magritte-seaside-accessing'>
	^self propertyAt: #checkboxLabel ifAbsent: [self label]
    ]

    checkboxLabel: aString [
	<category: '*magritte-seaside-accessing'>
	self propertyAt: #checkboxLabel put: aString
    ]

]



MAClassDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-accessing-defaults'>
	^Array with: MATextInputComponent
    ]

]



MAPasswordDescription class extend [

    defaultComponentClasses [
	<category: '*magritte-seaside-default'>
	^Array with: MATextPasswordComponent with: MATextInputComponent
    ]

]

