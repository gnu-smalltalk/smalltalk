"======================================================================
|
|   Smalltalk GUI class hierarchy browser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2007,2008 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"



GuiData subclass: ClassHierarchyBrowser [
    | curClass curCategory curSelector textMode textView meta classList sortedMethodsByCategoryDict categoriesForClass topClasses shownClasses fileoutDir |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    classList [
	<category: 'accessing'>
	^classList
    ]

    classList: curClassList message: aMessage [
	"This method is used to implement selective updates of the class list
	 pane.  Currently the selected class, curClass, is unselected and the
	 instance variables, curSelector and curCategory, which are related
	 to the selected class, are reinitialized.  The message type, aMessage,
	 is sent to the data object.  The update method for the affected class
	 pane will update the portion which needs to be updated based on the
	 message type parameter, aMessage.  Other messages are posted through
	 the change/update mechanism so that the rest of the window will be
	 appropriately updated."

	<category: 'accessing'>
	classList := curClassList.
	curSelector := nil.
	curCategory := nil.
	textMode := #source.
	self
	    changeState: aMessage;
	    changeState: #methodCategories;
	    changeState: #methods.
	self changeState: #text.
	Primitive updateViews
    ]

    classSelection: assoc [
	"assoc contains current class selection.  Find the class associated with
	 the selected string in shownClasses dictionary.  Save the class in the
	 instance variable, curClass.  Update other related instance variables.  Since
	 the other panes in the browser descend from the class, the instance variables
	 associated with each pane must be nilled out.  Send update messages to the
	 data object"

	<category: 'accessing'>
	curClass := (assoc isNil or: [assoc value isNil]) 
		    ifTrue: [nil]
		    ifFalse: [shownClasses at: assoc value].
	textView object: curClass.
	curSelector := nil.
	curCategory := nil.
	textMode := #source.
	self
	    changeState: #methodCategories;
	    changeState: #methods.
	self changeState: #text.
	Primitive updateViews
    ]

    classString [
	"Return name of selected class indented by 'n' spaces, where 'n' is the number
	 of class' superclasses"

	<category: 'accessing'>
	| spaces |
	curClass isNil ifTrue: [^nil].
	spaces := String 
		    new: curClass allSuperclasses size * self indentString size.
	spaces atAllPut: Character space.
	^spaces , curClass name
    ]

    indentString [
	<category: 'accessing'>
	^'  '
    ]

    listMethodCategory: assoc [
	<category: 'accessing'>
	curCategory := assoc value.
	self methodCategory: curCategory
    ]

    meta [
	"If class methods are being viewed, return true"

	<category: 'accessing'>
	^meta
    ]

    meta: aBoolean [
	"Change instance/class representation and record data state changes"

	<category: 'accessing'>
	meta = aBoolean ifTrue: [^self].
	meta := aBoolean.
	curCategory := nil.
	curSelector := nil.
	self
	    changeState: #methodCategories;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    method [
	"Return the selected method which is stored in curSelector"

	<category: 'accessing'>
	^curSelector
    ]

    method: assoc [
	"Set curSelector to aMethod, update text mode, and record state change"

	<category: 'accessing'>
	curSelector := assoc value.
	textMode := #source.
	self changeState: #text.
	Primitive updateViews
    ]

    methodCategories [
	"This method is invoked by the change/update mechanism when a new class is
	 selected.  To improve efficiency, method dictionary is cached.  Methods are
	 sorted by category and saved in a dictionary, sortedMethodByCategoryDict.
	 When a new category is selected, this dictionary is consulted.  The class's
	 method categories sorted by name are returned"

	<category: 'accessing'>
	| deClass category catSet |
	curClass isNil ifTrue: [^SortedCollection new].
	deClass := self getClass.
	categoriesForClass = deClass 
	    ifTrue: [^sortedMethodsByCategoryDict keys asSortedCollection].
	categoriesForClass := deClass.
	sortedMethodsByCategoryDict := Dictionary new.
	catSet := Set new.
	deClass selectors do: 
		[:aSelector | 
		catSet 
		    add: (category := (deClass compiledMethodAt: aSelector) methodCategory).
		(sortedMethodsByCategoryDict at: category
		    ifAbsent: [sortedMethodsByCategoryDict at: category put: SortedCollection new]) 
			add: aSelector].
	^catSet asSortedCollection
    ]

    methodCategory [
	<category: 'accessing'>
	^curCategory
    ]

    methodCategory: listItem [
	"Update curCategory.  Reinitialize the instance variable,
	 curSelector.  Notify affected panes through the change/update mechanism"

	<category: 'accessing'>
	curCategory := listItem.
	textMode := #source.
	self changeState: #methods.
	curSelector notNil ifTrue: [curSelector := nil].

	"Ask the data object whether the selector list view can
	 change it.  Deselect currently selected method and force
	 text pane, record state change and force update"
	textMode := #addMethod.
	self changeState: #text.
	Primitive updateViews
    ]

    methods [
	"Return the sorted methods for selected category"

	<category: 'accessing'>
	curCategory isNil ifTrue: [^Array new: 0].
	^sortedMethodsByCategoryDict at: curCategory ifAbsent: [Array new: 0]
    ]

    getAddMethodTemplate [
	"Return add method template"

	<category: 'accessing'>
	^'method: selectors and: arguments
    "Comment describing purpose and answered value."
    | temporary variables |
    statements
'
    ]

    text [
	"Return a text string depending on the text mode (textMode) of the data object"

	<category: 'accessing'>
	| aStream count |
	textMode == #addClass ifTrue: [^self getAddClassTemplate].
	curClass isNil 
	    ifTrue: 
		["If no class is selected, return empty string"

		^String new: 0].
	textMode == #comment 
	    ifTrue: 
		["Return comment associated with selected class"

		^self getClass comment isNil ifTrue: [''] ifFalse: [curClass comment]].
	textMode == #addMethod 
	    ifTrue: [^self getClass -> self getAddMethodTemplate].
	curSelector isNil 
	    ifTrue: 
		[aStream := WriteStream on: (String new: 0).
		curClass fileOutDeclarationOn: aStream.
		^aStream contents].
	"Display method source for selected class"
	^self getClass -> (self getClass >> curSelector) methodRecompilationSourceString
    ]

    addCategory: listView [
	"If a class is selected, prompt the user to enter a new message category.  If
	 a legitimate category is entered, update the method list pane (listView) and
	 System classes"

	<category: 'category list blue button menu'>
	| newCategory |
	curClass isNil ifTrue: [^listView beep].
	newCategory := (Prompter message: 'Enter a new message category'
		    in: listView) response.
	newCategory = '' ifTrue: [^self].

	"If new category already exists, reject"
	(sortedMethodsByCategoryDict includesKey: newCategory) 
	    ifTrue: 
		[^ModalDialog new 
		    alertMessage: 'Invalid name: the category, ' , newCategory 
			    , ', already exists.'
		    in: listView].
	sortedMethodsByCategoryDict at: newCategory put: SortedCollection new.
	self changeState: #methodCategories.
	self methodCategory: newCategory
    ]

    blueButtonMenuForCategories: theView [
	"Install popup menu for category pane"

	<category: 'category list blue button menu'>
	^(PopupMenu new: theView label: 'Protocol') 
	    selectors: #(#('File out...' #fileOutCategory: #theView) #() #('Add...' #addCategory: #theView) #('Rename...' #renameCategory: #theView) #('Remove...' #removeCategory: #theView))
	    receiver: self
	    argument: theView
    ]

    fileOutCategory: listView [
	"File out a description of the methods which belong to the selected method
	 category.  A file selection dialog is displayed which prompts the user for the
	 name and directory location of the file"

	<category: 'category list blue button menu'>
	| fileName deClass |
	curCategory isNil ifTrue: [^listView beep].
	deClass := self getClass.
	deClass name notNil 
	    ifTrue: [fileName := deClass name]
	    ifFalse: [fileName := deClass asClass name , '-class'].

	"If the name is too long, maybe truncate it?"
	fileName := self fileoutDir , fileName , '.' , curCategory , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out category'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[deClass fileOutCategory: curCategory to: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    removeCategory: listView [
	"Remove currently selected message category"

	<category: 'category list blue button menu'>
	| cancel |
	curCategory isNil ifTrue: [^listView beep].
	(ModalDialog new)
	    message: 'Are you sure you want to remove the category, ' , curCategory 
			, '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].
	"Update category list"
	self methods notNil 
	    ifTrue: 
		["Update sorted cache of class's message dictionary"

		sortedMethodsByCategoryDict removeKey: curCategory ifAbsent: [^self].
		self getClass removeCategory: curCategory].

	"Nil out curCategory and notify affected panes through the change/update
	 mechanism"
	curCategory := nil.
	self
	    changeState: #methodCategories;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    renameCategory: listView [
	"Change selected message category name"

	<category: 'category list blue button menu'>
	| newName |
	curCategory isNil ifTrue: [^listView beep].
	"Prompt the user for new name"
	newName := (Prompter message: 'Rename message category: ' , curCategory
		    in: listView) response.
	newName isEmpty 
	    ifTrue: [^self]
	    ifFalse: 
		["If new category already exists, reject"

		(sortedMethodsByCategoryDict includesKey: newName) 
		    ifTrue: 
			[^ModalDialog new alertMessage: 'Invalid name: the category, ' , newName 
				    , ', already exists.'
			    in: listView]].

	"If new name is entered, update cache of sorted methods"
	sortedMethodsByCategoryDict at: newName
	    put: (sortedMethodsByCategoryDict at: curCategory).
	sortedMethodsByCategoryDict removeKey: curCategory.

	"Update system"
	self getClass methodDictionary do: 
		[:method | 
		method methodCategory = curCategory 
		    ifTrue: [method methodCategory: newName]].

	"Update instance variable and directly update the category pane (listView)"
	curCategory := newName.
	self changeState: #methodCategories.
	Primitive updateViews
    ]

    currentNamespace [
	<category: 'class hierarchy'>
	^Namespace current
    ]

    hierarchyNames: startingClasses [
	<category: 'class hierarchy'>
	| collection topMetas |
	shownClasses := Dictionary new: 100.
	^self makeDescendentsDictionary: (self makeFullTree: startingClasses)
	    thenPutOn: (WriteStream on: (Array new: 75))
    ]

    makeDescendentsDictionary: dict thenPutOn: stream [
	"From the dict Dictionary, created by #makeFullTree:, create
	 another with the same keys.  Each key is associated to a set of
	 classes which are all the immediate subclasses which are also
	 keys of dict.  Then this dictionary is passed to the recursive
	 method #printHierarchyOf:hierarchy:startAt:on:"

	<category: 'class hierarchy'>
	| descendents |
	descendents := dict collect: [:each | Set new].
	descendents at: #none put: Set new.
	dict keysDo: 
		[:each | 
		each superclass isNil 
		    ifTrue: [(descendents at: #none) add: each]
		    ifFalse: [(descendents at: each superclass) add: each]].
	^self 
	    printHierarchyOf: dict
	    hierarchy: descendents
	    startAt: #none
	    on: stream
	    indent: ''
    ]

    makeFullTree: classes [
	"From the classes collection, create a Dictionary in which we ensure
	 that every key's superclass is also a key.  For example, if
	 classes contained Object and Array, the dictionary would also have
	 Collection, SequenceableCollection and ArrayedCollection as keys.
	 For every key, its value is true if classes includes it, else it is
	 false."

	<category: 'class hierarchy'>
	| dict newClasses checkClasses |
	dict := IdentityDictionary new: classes size.
	classes do: [:each | dict at: each put: true].
	checkClasses := dict keys.
	
	[newClasses := Set new.
	checkClasses do: 
		[:each | 
		each superclass isNil 
		    ifFalse: 
			[(dict includesKey: each superclass) 
			    ifFalse: [newClasses add: each superclass]]].
	newClasses isEmpty] 
		whileFalse: 
		    [newClasses do: [:each | dict at: each put: false].
		    checkClasses := newClasses].
	^dict
    ]

    printHierarchyOf: dict hierarchy: desc startAt: root on: stream indent: indent [
	"Recursive worker method for #printHierarchyOf:on:
	 dict is the classes Dictionary as obtained by makeFullTree:,
	 desc is the classes Dictionary as passed by
	 makeDescendentsDictionary:thenCollectOn:"

	<category: 'class hierarchy'>
	| subclasses string |
	subclasses := desc at: root.
	subclasses := subclasses asSortedCollection: [:a :b | a name <= b name].
	subclasses do: 
		[:each | 
		| template |
		template := (dict at: each) ifTrue: ['%1%2'] ifFalse: ['%1(%2)'].
		string := template % 
				{indent.
				each nameIn: self currentNamespace}.
		shownClasses at: string put: each.
		stream nextPut: string.
		self 
		    printHierarchyOf: dict
		    hierarchy: desc
		    startAt: each
		    on: stream
		    indent: indent , self indentString].
	^stream contents
    ]

    addClass: classList [
	"When 'add' is selected from class pane popup menu, this action is invoked.
	 Update mode of text pane.  Nil out currently selected method and method
	 category.  Record state change"

	<category: 'class list blue button menu'>
	(curClass notNil and: [classList canChangeState]) 
	    ifFalse: [^classList beep].
	textMode := #addClass.
	curCategory := nil.
	curSelector := nil.
	self
	    changeState: #removeCategorySelection;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    blueButtonMenuForClasses: theView [
	"Install popup for class list popup"

	<category: 'class list blue button menu'>
	^(PopupMenu new: theView label: 'Class') 
	    selectors: #(#('File out...' #fileOutClass: #theView) #('Update' #updateClassList) #() #('Compile' #compileClass: #theView) #('Compile all' #compileAll: #theView) #() #('Comment' #comment: #theView) #('References' #classRefs: #theView) #() #('Add' #addClass: #theView) #('Rename...' #renameClass: #theView) #('Remove...' #removeClass: #theView) #('Search...' #searchClass: #theView) #() #(#Inspect #inspectClass: #theView))
	    receiver: self
	    argument: theView
    ]

    classRefs: listView [
	"Activated from class pane popup menu.  Open a message set browser on all
	 methods that refer to currently selected class"

	<category: 'class list blue button menu'>
	| methods assoc |
	curClass isNil ifTrue: [^listView beep].
	methods := SortedCollection new.
	assoc := curClass environment associationAt: curClass name asSymbol.
	"For all selectors which refer to the selected class, add the class name
	 concatenated with selector name in the sorted collection 'methods'"
	CompiledMethod 
	    allInstancesDo: [:method | (method refersTo: assoc) ifTrue: [methods add: method]].
	methods isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No references to ' , curClass name
		    in: listView].
	MethodSetBrowser new 
	    openOn: methods
	    title: 'References to ' , curClass name
	    selection: curClass name
    ]

    comment: aPList [
	"Change text mode to comment mode.  Trigger an update to the text and selector
	 panes"

	<category: 'class list blue button menu'>
	curClass isNil ifTrue: [^aPList beep].

	"Ask the data object whether the class list view can change itself"
	aPList canChangeState ifFalse: [^self].
	textView canChangeState ifFalse: [^self].
	textMode := #comment.

	"Deselect currently selected category and selector"
	curCategory := nil.
	curSelector := nil.
	self
	    changeState: #methodCategories;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    compileAll: listView [
	"Activated from class list popup.  Recompile the selected class and its
	 subclasses.  The Metaclasses are recompiled as well"

	<category: 'class list blue button menu'>
	curClass isNil ifTrue: [^listView beep].
	curClass compileAll.
	curClass class compileAll.
	curClass compileAllSubclasses.
	curClass class compileAllSubclasses.
	self changeState: #methodCategories
    ]

    compileClass: listView [
	"Recompile selected class and its Metaclass"

	<category: 'class list blue button menu'>
	curClass isNil ifTrue: [^listView beep].
	curClass compileAll.
	curClass class compileAll.
	self changeState: #methodCategories
    ]

    inspectClass: listView [
	"Bring up an inspector on a Class"

	<category: 'class list blue button menu'>
	curClass inspect
    ]

    fileOutClass: listView [
	"File out a description of the currently selected class"

	<category: 'class list blue button menu'>
	| className fileName |
	curClass isNil ifTrue: [^listView beep].
	curClass name notNil 
	    ifTrue: [className := curClass name]
	    ifFalse: [className := curClass asClass name , '-class'].
	fileName := self fileoutDir , className , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out class'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[curClass fileOut: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    fileoutDir [
	<category: 'class list blue button menu'>
	| home |
	fileoutDir isNil 
	    ifTrue: 
		["If the image directory is a subdirectory of the home directory, the default is
		 the image directory. Else the default is the home directory"

		fileoutDir := Directory image name , '/'.
		home := Directory home name.
		home isEmpty 
		    ifFalse: 
			[fileoutDir size < home size ifTrue: [^fileoutDir := home , '/'].
			home = (fileoutDir copyFrom: 1 to: home size) 
			    ifTrue: [^fileoutDir := home , '/']]].
	^fileoutDir
    ]

    getAddClassTemplate [
	"Return add class template"

	<category: 'class list blue button menu'>
	| curClassName |
	curClassName := curClass isNil 
		    ifTrue: ['NameOfSuperClass']
		    ifFalse: [curClass printString].
	^curClassName 
	    , ' subclass: #NameOfClass
	instanceVariableNames:  ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: nil
'
    ]

    removeClass: listView [
	"Remove selected class from system"

	<category: 'class list blue button menu'>
	| badClasses assoc classes cancel |
	curClass isNil ifTrue: [^listView beep].
	curClass subclasses isEmpty 
	    ifFalse: [^self error: 'Must delete subclasses first'].
	(ModalDialog new)
	    message: 'Are you sure you want to remove the class, ' , curClass name 
			, '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].

	"If there are any instance of curClass, disallow curClass to be removed.  Force
	 a garbage collection to get rid of unreferenced instances"
	(curClass instanceCount > 0 and: 
		[ObjectMemory compact.
		curClass instanceCount > 0]) 
	    ifTrue: [^self error: 'Cannot remove because class has instances.'].

	"Search system for all external references to class"
	badClasses := 
		{curClass.
		curClass class}.
	assoc := curClass environment associationAt: curClass name.
	Class allSubclassesDo: 
		[:subclass | 
		(badClasses includes: subclass) 
		    ifFalse: 
			[(subclass instanceClass whichSelectorsReferTo: assoc) do: 
				[:sel | 
				"Ignore references in transitory selector -- executeStatements"

				sel ~= #executeStatements 
				    ifTrue: 
					[^self error: 'External references remain to class which is to be deleted']].
			(subclass whichSelectorsReferTo: assoc) do: 
				[:sel | 
				"Ignore references in transitory selector -- executeStatements"

				sel ~= #executeStatements 
				    ifTrue: 
					[^self error: 'External references remain to class which is to be deleted']]]].
	curClass allSuperclassesDo: 
		[:each | 
		each removeSubclass: curClass.
		each class removeSubclass: curClass class].

	"Update namespace"
	curClass environment removeKey: curClass name asSymbol.
	self updateClassList.
	self classSelection: nil
    ]

    renameClass: listView [
	"Rename currently selected class"

	<category: 'class list blue button menu'>
	| methods oldName newName prompter oldAssoc |
	curClass isNil ifTrue: [^listView beep].
	oldName := curClass name.
	"Prompt user for new name"
	prompter := Prompter message: 'Rename class: ' , curClass name in: listView.
	prompter response isEmpty 
	    ifTrue: [^self]
	    ifFalse: 
		[newName := prompter response asSymbol.
		(newName at: 1) isUppercase 
		    ifFalse: 
			[^self error: 'Class name should begin with 
				   an uppercase letter'].
		(curClass environment includesKey: newName) 
		    ifTrue: [^self error: newName , ' already exists']].

	"Save old Association"
	oldAssoc := curClass environment associationAt: oldName.

	"Rename the class now"
	curClass setName: newName asSymbol.

	"Fix up namespace"
	curClass environment at: curClass name put: oldAssoc value.
	curClass environment removeKey: oldName.

	"Notify programmer of all references to renamed class"
	methods := SortedCollection new.
	CompiledMethod 
	    allInstancesDo: [:method | (method refersTo: oldAssoc) ifTrue: [methods add: method]].
	methods isEmpty 
	    ifFalse: 
		[ModalDialog new 
		    alertMessage: 'Rename all references to 
		    class ' , oldName 
			    , Character nl , 'to the new name: ' 
			    , newName
		    in: listView.
		MethodSetBrowser new 
		    openOn: methods
		    title: 'References to ' , oldName
		    selection: oldName].


	"Update class list"
	self updateClassList
    ]

    searchClass: listView [
	<category: 'class list blue button menu'>
	| newClass found |
	newClass := (Prompter message: 'Enter the class to be searched'
		    in: listView) response.
	newClass isEmpty ifTrue: [^self].
	"First pass, search for a qualified name."
	found := self searchClassIn: listView
		    suchThat: [:class | newClass sameAs: (class nameIn: self currentNamespace)].

	"Second pass, only look for the name."
	(found or: [newClass includes: $.]) 
	    ifFalse: 
		[found := self searchClassIn: listView
			    suchThat: [:class | newClass sameAs: class name]].
	found ifTrue: [^self].
	^ModalDialog new 
	    alertMessage: 'Invalid name: the class, ' , newClass , ', does not exist.'
	    in: listView
    ]

    searchClassIn: listView suchThat: aBlock [
	<category: 'class list blue button menu'>
	| class indent i listBlox numClasses |
	class := shownClasses detect: aBlock ifNone: [nil].
	class isNil ifTrue: [^false].
	curClass := class.
	textView object: curClass.
	listView select: self classString.
	^true
    ]

    setFileoutDirFromFile: fileName [
	<category: 'class list blue button menu'>
	fileoutDir := fileName copyFrom: 1 to: (fileName findLast: [:c | c = $/])
    ]

    topClasses [
	<category: 'class list blue button menu'>
	^Array streamContents: 
		[:stream | 
		Namespace current allClassesDo: [:each | stream nextPut: each]]
    ]

    updateClassList [
	"Invoked from class list pane popup.  Update class list pane through the
	 change/update mechanism"

	<category: 'class list blue button menu'>
	topClasses := self topClasses.
	topClasses size >= 2 
	    ifTrue: 
		[topClasses := topClasses asSortedCollection: [:a :b | a name <= b name]].
	self classList: (self hierarchyNames: topClasses) message: #classList
    ]

    createClassesListIn: upper [
	<category: 'initializing'>
	| list |
	upper addChildView: ((list := PList new: 'Classes' in: upper)
		    initialize;
		    data: self;
		    stateChange: #classList;
		    changedSelection: #newClassSelection;
		    handleUserChange: #classSelection:;
		    listMsg: #classList;
		    selectionMsg: #classString;
		    menuInit: (self blueButtonMenuForClasses: list);
		    yourself).
	"Register three types of messages"
	self layoutUpperPaneElement: list blox num: 0
    ]

    createLowerPaneIn: topView below: upper [
	<category: 'initializing'>
	topView addChildView: ((textView := PCode new: topView)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #compile:from:;
		    setBrowserKeyBindings;
		    menuInit: (self blueButtonMenuForText: textView);
		    textMsg: #text;
		    yourself).
	(textView blox)
	    width: 600 height: 200;
	    posVert: upper blox;
	    inset: 2
    ]

    createProtocolListIn: upper [
	<category: 'initializing'>
	| pane list radioForm radioGroup |
	upper addChildView: (pane := OrderedForm new: 'Middle' in: upper).
	pane blox setVerticalLayout: true.
	self layoutUpperPaneElement: pane blox num: 1.

	"Add method categories list pane in middle third of window"
	pane addChildView: ((list := PList new: 'Categories' in: pane)
		    initialize;
		    data: self;
		    stateChange: #methodCategories;
		    changedSelection: #removeCategorySelection;
		    handleUserChange: #listMethodCategory:;
		    listMsg: #methodCategories;
		    selectionMsg: #methodCategory;
		    menuInit: (self blueButtonMenuForCategories: list);
		    yourself).
	list blox stretch: true.
	pane addChildView: (radioForm := RadioForm new: 'RadioGroup' in: pane).
	radioGroup := radioForm blox.
	radioForm addChildView: (PRadioButton 
		    on: self
		    parentView: radioGroup
		    isPressed: #meta
		    label: 'instance'
		    handleUserChange: #meta:
		    value: false).
	radioForm addChildView: (PRadioButton 
		    on: self
		    parentView: radioGroup
		    isPressed: #meta
		    label: 'class'
		    handleUserChange: #meta:
		    value: true)
    ]

    createSelectorListIn: upper [
	"Add selectors list pane in top right third of window"

	<category: 'initializing'>
	| list |
	upper addChildView: ((list := PList new: 'Selectors' in: upper)
		    initialize;
		    data: self;
		    stateChange: #methods;
		    handleUserChange: #method:;
		    listMsg: #methods;
		    selectionMsg: #method;
		    menuInit: (self blueButtonMenuForMethods: list);
		    yourself).
	self layoutUpperPaneElement: list blox num: 2
    ]

    createUpperPanesIn: upper [
	<category: 'initializing'>
	self createClassesListIn: upper.
	self createProtocolListIn: upper.
	self createSelectorListIn: upper
    ]

    initialize [
	<category: 'initializing'>
	self updateClassList
    ]

    layoutUpperPaneElement: blox num: n [
	<category: 'initializing'>
	blox 
	    x: 200 * n
	    y: 0
	    width: 200
	    height: 200
    ]

    createTopView [
	<category: 'initializing'>
	^BrowserShell new: 'Class Hierarchy Browser'
    ]

    open [
	"Create and open a class browser"

	<category: 'initializing'>
	| topView upper container win |
	meta := false.

	"Create top view"
	topView := self createTopView.
	topView data: self.
	win := topView blox.
	win 
	    x: 20
	    y: 50
	    width: 604
	    height: 404.
	upper := Form new: 'ListForms' in: topView.
	topView addChildView: upper.
	container := upper blox.
	container
	    x: 0
		y: 0
		width: 600
		height: 200;
	    inset: 2.
	self createUpperPanesIn: upper.
	self createLowerPaneIn: topView below: upper.
	self initialize.
	topView display
    ]

    compileMethod: aString for: aView [
	"Compile the method source, aString, for the selected class.  Compilation
	 class is set according to the radio button state.  If 'meta' is true, set
	 aClass to selected class, curClass, to its Metaclass.  If method is
	 successfully compiled, related instance variables are updated."

	<category: 'private'>
	| compiledMethod selector dupIndex collection aClass |
	aClass := meta ifTrue: [curClass class] ifFalse: [curClass].
	curCategory isNil 
	    ifTrue: 
		[curCategory := (Prompter 
			    message: 'Enter method category'
			    default: 'As yet unclassified'
			    in: aView) response.
		curCategory isEmpty ifTrue: [curCategory := 'As yet unclassified']].

	"The exception block will be invoked if aString contains parsing errors.  The
	 description of the error will be displayed and selected at the end of the line
	 in which the error is detected by the parser.  Nil is returned"
	compiledMethod := aClass 
		    compile: aString
		    classified: curCategory
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString at: lineNo.
			^nil].

	"Retrieve selector"
	(compiledMethod selector = curSelector 
	    and: [compiledMethod methodCategory = curCategory]) 
		ifTrue: [^compiledMethod].

	"Need to do additional housekeeping to keep internal version of
	 method dictionary, sortedMethodsByCategoryDict, in synch with the class's
	 method dictionary. Remove duplicates stored in the internal version of
	 method dictionary"
	curSelector := compiledMethod selector.
	curCategory := compiledMethod methodCategory.
	sortedMethodsByCategoryDict 
	    do: [:methods | methods remove: curSelector ifAbsent: []].

	"Now add selector to internal copy"
	(sortedMethodsByCategoryDict at: curCategory
	    ifAbsentPut: [SortedCollection new]) add: curSelector.
	self changeState: #methods.
	self changeState: #methodCategories.
	Primitive updateViews.
	^compiledMethod
    ]

    getClass [
	"If 'meta' is true, return selected class's Metaclass; otherwise, selected
	 class is returned"

	<category: 'private'>
	meta ifTrue: [^curClass class] ifFalse: [^curClass]
    ]

    inspectMethod: listView [
	"Bring up an inspector on a Class"

	<category: 'selector list blue button menu'>
	curSelector isNil ifTrue: [^listView beep].
	(self getClass >> curSelector) inspect
    ]

    blueButtonMenuForMethods: theView [
	"Create method list pane menu"

	<category: 'selector list blue button menu'>
	^(PopupMenu new: theView label: 'Method') 
	    selectors: #(#('File out...' #fileOutSelector: #theView) #() #('Senders' #senders: #theView) #('Implementors' #implementors: #theView) #() #('Remove...' #removeMethod: #theView) #() #(#Inspect #inspectMethod: #theView))
	    receiver: self
	    argument: theView
    ]

    fileOutSelector: listView [
	"Creates a file containing description of selected method"

	<category: 'selector list blue button menu'>
	| deClass fileName |
	curSelector isNil ifTrue: [^listView beep].
	deClass := self getClass.
	deClass name notNil 
	    ifTrue: [fileName := deClass name]
	    ifFalse: [fileName := deClass asClass name , '-class'].

	"If the name is too long, maybe truncate it"
	fileName := self fileoutDir , fileName , '.' , curSelector , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out selector'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[deClass fileOutSelector: curSelector to: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    implementors: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	curSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser implementorsOf: curSelector parent: listView
    ]

    removeMethod: listView [
	"Removes selected method"

	<category: 'selector list blue button menu'>
	| cancel |
	curSelector isNil ifTrue: [^listView beep].
	(ModalDialog new)
	    message: 'Are you sure you want to remove the method, ' , curSelector , '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].
	"Remove method from system"
	self getClass removeSelector: curSelector.
	(sortedMethodsByCategoryDict at: curCategory) remove: curSelector.
	"Update listView"
	curSelector := nil.
	"Record state change"
	self
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    senders: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	curSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser sendersOf: curSelector parent: listView
    ]

    blueButtonMenuForText: theView [
	"Create menu for text pane"

	<category: 'text view blue button menu'>
	^(PopupMenu new: theView label: 'Edit') 
	    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors) #() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
	    receiver: theView
	    argument: nil
    ]

    compile: aString from: aView [
	"Compile aString derived from the text pane (aView).  The way aString is
	 compiled depends on the text mode"

	<category: 'text view blue button menu'>
	| aClass |
	curClass isNil ifTrue: [^aView beep].

	"If the text in the text pane is method source code, compile it"
	(curSelector notNil or: [textMode == #addMethod]) 
	    ifTrue: [^self compileMethod: aString for: aView].
	textMode == #comment 
	    ifTrue: 
		[curClass comment: aString.
		^aString].

	"Otherwise, evaluate the text.  If no method source is displayed, then
	 aString is evaluated independently.  If the string constitutes a legal
	 class definition, the class is returned in aClass"
	curClass environment whileCurrentDo: 
		[aClass := Behavior evaluate: aString ifError: [:file :line :msg | ^nil]].
	aClass isClass ifFalse: [^self].

	"If ClassHierarchyBrowser is modified, force an immediate exit
	 because this method context is still referencing it by the old memory
	 model"
	(self isKindOf: aClass) | (aClass == curClass) ifTrue: [^self].
	curClass := aClass.
	textView object: curClass.

	"Update class pane"
	(classList includes: aClass) 
	    ifTrue: 
		["If the class already exists, inform the class pane indirectly
		 through the change/update mechanism that the selection only
		 needs to be updated"

		self classList: classList message: #newClassSelection]
	    ifFalse: 
		["If the class does not exist, update instance variables
		 and inform the affected panes through the change/update mechanism"

		self updateClassList].
	textMode := #source
    ]
]

