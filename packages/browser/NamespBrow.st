"======================================================================
|
|   Smalltalk GUI namespace browser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



ClassHierarchyBrowser subclass: NamespaceBrowser [
    | curNamespace byCategory namespacesMap namespaces categories |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    byCategory [
	"If categories are being viewed, return true"

	<category: 'accessing'>
	^byCategory
    ]

    byCategory: aBoolean [
	"Change instance/class representation and record data state changes"

	<category: 'accessing'>
	byCategory = aBoolean ifTrue: [^self].
	curNamespace := nil.
	byCategory := aBoolean.
	self updateNamespaceList
    ]

    namespaceList [
	<category: 'accessing'>
	^byCategory ifTrue: [categories] ifFalse: [namespaces]
    ]

    namespaceSelection: assoc [
	<category: 'accessing'>
	| name |
	name := assoc value.
	curNamespace := name isNil | byCategory 
		    ifTrue: [name]
		    ifFalse: [namespacesMap at: name].
	curClass := nil.
	self updateClassList
    ]

    namespaceString [
	"Return name of selected class indented by 'n' spaces, where 'n' is the number
	 of class' superclasses"

	<category: 'accessing'>
	| spaces |
	curNamespace isNil ifTrue: [^nil].
	byCategory ifTrue: [^curNamespace].
	spaces := String new: curNamespace allSuperspaces size.
	spaces atAllPut: Character space.
	^spaces , curNamespace name
    ]

    readCategories [
	<category: 'accessing'>
	categories := Set new.
	Class allSubclassesDo: 
		[:each | 
		each isMetaclass ifTrue: [categories add: each instanceClass category]].
	categories := categories asSortedCollection
    ]

    readNamespaces [
	<category: 'accessing'>
	| stack top indent namespace subspaces |
	stack := OrderedCollection new.
	namespacesMap := Dictionary new: 17.
	namespaces := OrderedCollection new.
	subspaces := {Smalltalk} , RootNamespace allInstances.
	
	[subspaces isNil 
	    ifFalse: 
		[top := stack 
			    addLast: (subspaces asSortedCollection: [:a :b | a name <= b name])].
	[top isEmpty] whileTrue: 
		[stack removeLast.
		stack isEmpty ifTrue: [^self].
		top := stack last].
	namespace := top removeFirst.
	subspaces := namespace subspaces.
	indent := String new: stack size - 1 withAll: Character space.
	namespacesMap at: indent , namespace name put: namespace.
	namespaces add: indent , namespace name] 
		repeat
    ]

    addSubNamespace: listView [
	<category: 'namespace list blue button menu'>
	| newNamespace |
	curNamespace isNil ifTrue: [^listView beep].
	curNamespace isNamespace ifFalse: [^listView beep].
	newNamespace := (Prompter message: 'Enter a new namespace' in: listView) 
		    response.
	newNamespace = '' ifTrue: [^self].
	curNamespace addSubspace: newNamespace asSymbol.
	self updateNamespaceList
    ]

    blueButtonMenuForNamespaces: theView [
	"Install popup for namespace list popup"

	<category: 'namespace list blue button menu'>
	^(PopupMenu new: theView label: 'Namespace') 
	    selectors: #(#('Namespaces' #namespaces: #theView) #('Categories' #categories: #theView) #() #('File out...' #fileOutNamespace: #theView) #('File into namespace' #fileIntoNamespace: #theView) #() #('Add namespace' #addSubNamespace: #theVIew) #('Rename...' #renameNamespace: #theView) #('Update' #updateNamespaceList))
	    receiver: self
	    argument: theView
    ]

    categories: namespaceList [
	<category: 'namespace list blue button menu'>
	namespaceList canChangeState ifFalse: [^self].
	self byCategory: true
    ]

    fileIntoNamespace: listView [
	"File in a file to a currently selected namespace"

	<category: 'namespace list blue button menu'>
	| oldCurrent className fileName stream |
	curNamespace isNil ifTrue: [^listView beep].
	fileName := Prompter 
		    openFileName: 'Which file do you want me to read?'
		    default: '*.st'
		    in: listView.
	fileName isNil ifTrue: [^listView beep].
	oldCurrent := Namespace current.
	Namespace current: curNamespace.
	FileStream fileIn: fileName.
	Namespace current: oldCurrent
    ]

    fileoutName [
	<category: 'namespace list blue button menu'>
	byCategory ifTrue: [^curNamespace].
	^((curNamespace nameIn: Smalltalk) asString)
	    replaceAll: Character space with: $-;
	    yourself
    ]

    fileOutNamespace: listView [
	"File out a description of the currently selected namespace"

	<category: 'namespace list blue button menu'>
	| oldCurrent className fileName stream |
	curNamespace isNil ifTrue: [^listView beep].
	fileName := self fileoutDir , self fileoutName , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out namespace'
		    default: fileName
		    in: listView.
	fileName isNil ifTrue: [^self].
	stream := FileStream open: fileName mode: FileStream write.
	byCategory 
	    ifFalse: 
		[curNamespace superspace isNil 
		    ifFalse: 
			[stream
			    nextPutAll: (curNamespace superspace nameIn: Smalltalk);
			    nextPutAll: ' addSubspace: #';
			    nextPutAll: curNamespace name;
			    nextPutAll: '!';
			    nl;
			    nextPutAll: 'Namespace current: ';
			    nextPutAll: (curNamespace nameIn: Smalltalk);
			    nextPutAll: '!';
			    nl;
			    nl]
		    ifTrue: 
			[stream
			    nextPutAll: 'Namespace current: (RootNamespace new: #';
			    nextPutAll: (curNamespace nameIn: Smalltalk);
			    nextPutAll: ')!';
			    nl;
			    nl].
		oldCurrent := Namespace current.
		Namespace current: curNamespace].
	classList do: 
		[:each | 
		(each trimSeparators includes: $() 
		    ifFalse: [(shownClasses at: each) fileOutOn: stream]].
	byCategory 
	    ifFalse: 
		[Namespace current: oldCurrent.
		stream
		    nextPutAll: 'Namespace current: Smalltalk!';
		    nl].
	stream close.
	self setFileoutDirFromFile: fileName
    ]

    namespaces: namespaceList [
	<category: 'namespace list blue button menu'>
	namespaceList canChangeState ifFalse: [^self].
	self byCategory: false
    ]

    renameNamespace: listView [
	"Rename currently selected namespace"

	<category: 'namespace list blue button menu'>
	| methods oldName newName prompter oldAssoc referrer |
	curNamespace isNil ifTrue: [^listView beep].
	oldName := self namespaceString trimSeparators.

	"Prompt user for new name"
	prompter := Prompter message: 'Rename namespace: ' , curNamespace name
		    in: listView.
	prompter response = '' ifTrue: [^self].
	self byCategory 
	    ifTrue: 
		[shownClasses do: [:each | each category: prompter response].
		self updateNamespaceList.
		^self].
	oldName := oldName asSymbol.
	newName := prompter response asSymbol.
	(newName at: 1) isUppercase 
	    ifFalse: [^self error: 'Namespace name must begin with an uppercase letter'].
	referrer := curNamespace superspace isNil 
		    ifTrue: [Smalltalk]
		    ifFalse: [curNamespace superspace].
	(referrer includesKey: newName) 
	    ifTrue: [^self error: newName , ' already exists'].

	"Save old Association and remove namespace temporarily"
	oldAssoc := referrer associationAt: oldName.
	referrer removeKey: oldName.

	"Rename the namespace now and re-add it"
	curNamespace name: newName asSymbol.
	referrer at: newName asSymbol put: curNamespace.

	"Notify programmer of all references to renamed namespace"
	methods := SortedCollection new.
	CompiledMethod allInstancesDo: 
		[:method | 
		((method refersTo: oldAssoc) or: [method refersTo: oldAssoc key]) 
		    ifTrue: [methods add: method]].
	methods isEmpty 
	    ifFalse: 
		[ModalDialog new 
		    alertMessage: 'Rename all references to 
		    namespace ' , oldName 
			    , Character nl asSymbol , 'to the new name: ' 
			    , newName
		    in: listView.
		MethodSetBrowser new 
		    openOn: methods
		    title: 'References to ' , oldName
		    selection: oldName].

	"Update namespace list"
	self updateNamespaceList
    ]

    topClasses [
	<category: 'namespace list blue button menu'>
	^self topMetas collect: [:each | each instanceClass]
    ]

    topMetas [
	<category: 'namespace list blue button menu'>
	curNamespace isNil ifTrue: [^#()].
	^byCategory 
	    ifTrue: [Class allSubclasses select: [:each | each category = curNamespace]]
	    ifFalse: 
		[Class allSubclasses select: [:each | each environment = curNamespace]]
    ]

    updateNamespaceList [
	"Invoked from class list pane popup.  Update class list pane through the
	 change/update mechanism"

	<category: 'namespace list blue button menu'>
	byCategory ifTrue: [self readCategories] ifFalse: [self readNamespaces].
	self changeState: #namespaceList.
	self updateClassList
    ]

    createNamespaceListIn: upper [
	<category: 'initializing'>
	| list |
	upper addChildView: ((list := PList new: 'Namespaces' in: upper)
		    initialize;
		    data: self;
		    stateChange: #namespaceList;
		    changedSelection: #newNamespaceSelection;
		    handleUserChange: #namespaceSelection:;
		    listMsg: #namespaceList;
		    selectionMsg: #namespaceString;
		    menuInit: (self blueButtonMenuForNamespaces: list);
		    yourself).
	"Register three types of messages"
	self layoutUpperPaneElement: list blox num: -1
    ]

    createUpperPanesIn: upper [
	<category: 'initializing'>
	self createNamespaceListIn: upper.
	super createUpperPanesIn: upper
    ]

    createTopView [
	<category: 'initializing'>
	^BrowserShell new: 'Namespace Browser'
    ]

    initialize [
	<category: 'initializing'>
	self updateNamespaceList
    ]

    layoutUpperPaneElement: blox num: n [
	<category: 'initializing'>
	blox 
	    x: 150 * n + 150
	    y: 0
	    width: 150
	    height: 200
    ]

    open [
	<category: 'initializing'>
	byCategory := false.
	super open
    ]

    currentNamespace [
	<category: 'overriding'>
	^byCategory ifTrue: [Namespace current] ifFalse: [curNamespace]
    ]
]

