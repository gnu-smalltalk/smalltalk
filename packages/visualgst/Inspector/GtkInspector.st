"======================================================================
|
| GtkInspector class definition
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

GtkBrowsingTool subclass: GtkInspector [
    | object notebookWidget inspectorWidget browserWidget workspaceWidget |

    GtkInspector class >> openOn: anObject [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    object: anObject;
	    showAll;
	    postInitialize;
	    yourself
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Inspector>'
    ]

    postInitialize [
        <category: 'initialization'>

	super postInitialize.
	browserWidget postInitialize.
	inspectorWidget postInitialize.
	workspaceWidget postInitialize.
    ]

    object: anObject [
	<category: 'accessor'>

	| objectClass |
	object == anObject ifFalse: [
	    object := anObject.
            inspectorWidget object: object.
	    workspaceWidget object: object ].
	objectClass := object isClass ifTrue: [ object ] ifFalse: [ object class ].
	self title: 'Inspector on ', objectClass article, ' ', objectClass name.
	browserWidget
	    selectAClass: objectClass
    ]

    windowTitle [
	<category: 'initialization'>
	
	^'Inspector'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	| trWidget wkWidget |
	notebookWidget := GTK.GtkNotebook new.
	trWidget := self buildInspectorView.
	wkWidget := self buildBrowserWidget mainWidget.
	^ notebookWidget
	    appendPage: trWidget tabLabel: (GTK.GtkLabel new: 'Basic');
	    appendPage: wkWidget tabLabel: (GTK.GtkLabel new: 'Methods');
	    showAll;
	    setCurrentPage: 0;
	    yourself
    ]

    buildInspectorView [
	<category: 'user interface'>

	^ GTK.GtkVPaned new
            pack1: self buildInspectorWidget mainWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: false shrink: true;
            yourself
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ inspectorWidget := (GtkInspectorWidget new)
				parentWindow: window;
				initialize;
				inspector: self;
				showAll;
				yourself
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkInspectorSourceWidget new)
				parentWindow: window;
				initialize;
				showAll;
				yourself
    ]

    buildBrowserWidget [
	<category: 'user interface'>

	^ browserWidget := (GtkInspectorBrowserWidget new)
				parentWindow: window;
				initialize;
				showAll;
				yourself
    ]

    createMenus [
	<category: 'user interface'>

        self createMainMenu: {#('File' #createFileMenus).
            #('Edit' #createEditMenus).
            #('Smalltalk' #createSmalltalkMenus).
            #('Tools' #createToolsMenus).
            #('Help' #createHelpMenus)}
    ]

    focusedWidget [
        <category: 'focus'>

        ^notebookWidget getCurrentPage = 0
            ifTrue: [ workspaceWidget focusedWidget ]
            ifFalse: [ browserWidget focusedWidget ]
    ]

    cancel [
        <category: 'edit events'>

        self onFocusPerform: #cancel
    ]

    undo [
        <category: 'edit events'>

        self onFocusPerform: #undo
    ]

    redo [
        <category: 'edit events'>

        self onFocusPerform: #redo
    ]

    cut [
        <category: 'edit events'>

        self onFocusPerform: #cut
    ]

    copy [
        <category: 'edit events'>

        self onFocusPerform: #copy
    ]

    paste [
        <category: 'edit events'>

        self onFocusPerform: #paste
    ]

    selectAll [
        <category: 'edit events'>

        self onFocusPerform: #selectAll
    ]

    close [
        <category: 'file events'>

        browserWidget doNotCheckCode.
        self saveCodeOr: [ super close ]
    ]

    targetObject [
        <category: 'smalltalk events'>

        ^ self onFocusPerform: #targetObject
    ]

    targetObject [
        <category: 'smalltalk events'>

        ^ self onFocusPerform: #targetObject
    ]

    doIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #doIt: with: anObject
    ]

    printIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #printIt: with: anObject
    ]

    inspectIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #inspectIt: with: anObject
    ]

    debugIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #debugIt: with: anObject
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    acceptIt [
        <category: 'smalltalk events'>

        browserWidget acceptIt
    ]

    find [
	<category: 'user interface'>

	self onFocusPerform: #showFind
    ]

    replace [
	<category: 'user interface'>

	self onFocusPerform: #showReplace
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^notebookWidget getCurrentPage = 1
    ]

    sourceCodeWidgetHasFocus [
        <category: 'focus'>

        ^ browserWidget sourceCodeWidgetHasFocus
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^self onFocusPerform: #selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [ ^ false ].
        ^ widget hasSelection
    ]

    clearUndo [
	<category: 'undo'>

	browserWidget clearUndo
    ]

    hasChanged [
	<category: 'close events'>

	^ browserWidget hasChanged
    ]
]

