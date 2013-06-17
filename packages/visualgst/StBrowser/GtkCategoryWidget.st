"======================================================================
|
| GtkCategoryWidget class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

GtkConcreteWidget subclass: GtkCategoryWidget [
    | categoryTree categories model class |

    GtkCategoryWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self initializeCategories.
	self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    initializeCategories [

	categories := Set new.
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #method change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeEvent:'
    ]

    classOrMeta [
	<category: 'accessing'>
    
	^ class
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	class := aClass.
	categories empty.
	model
	    item: (self buildCategory: categories);
	    refresh
    ]

    buildCategory: aSet [
        <category: 'model builder'>

        aSet add: '*'.
	self classOrMeta methodDictionary ifNil: [ ^ aSet ].
        self classOrMeta methodDictionary do: [ :each | aSet add: each methodCategory ].
        ^ aSet asSortedCollection
    ]

    emptyModel [
	<category: 'accessing'>

	self clear
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    buildTreeView [
        <category: 'user interface'>
    
	categoryTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Method categories'}}.
	categoryTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	categoryTree connectToWhenPopupMenu: (CategoryMenus on: self).
        (model := GtkListModel on: categoryTree treeView getModel)
                                        contentsBlock: [ :each | {each displayString} ].
	^ categoryTree mainWidget
    ]

    unselectAll [
	<category: 'selection'>

	categoryTree treeView getSelection unselectAll
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	categoryTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    state [
        <category: 'testing'>

        ^ self hasSelectedCategory 
			ifFalse: [ ClassState with: self classOrMeta ]
			ifTrue: [ CategoryState with: self classOrMeta->self selectedCategory ]
    ]

    hasSelectedCategory [
	<category: 'testing'>

	^ categoryTree treeView hasSelectedItem
    ]

    selectedCategory [
	<category: 'accessing'>

	self hasSelectedCategory ifFalse: [ self error: 'nothing is selected' ].
	^ categoryTree treeView selection
    ]

    selectACategory: aString [
        <category: 'item selection'>

	categoryTree treeView select: aString
    ]

    findIterInACategory: aString [
        <category: 'item selection'>

        | result |
        result := model findIterInACategory: aString.
        categoryTree treeView scrollToCell: (model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        ^ result
    ]

    viewedCategoryWidget [
	<category: 'accessing'>

	^ self
    ]

    viewedCategoryModel [
	<category: 'accessing'>

	^ model
    ]

    removeEmptyCategory [
	<category: 'update'>

	| set |
	set := Set new.
	self buildCategory: set.
	(categories - set) do: [ :each | 
			model remove: each.
			categories remove: each ifAbsent: [] ]
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ (model hasItem: anEvent item methodCategory) not ]) ifFalse: [ ^ self ].
        categories add: anEvent item methodCategory.
	model append: anEvent item methodCategory.
	self removeEmptyCategory
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ (model hasItem: anEvent item methodCategory) not ]) ifFalse: [ ^ self ].
	self removeEmptyCategory
    ]
]

