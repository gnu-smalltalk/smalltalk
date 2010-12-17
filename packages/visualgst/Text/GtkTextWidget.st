GtkConcreteWidget subclass: GtkTextWidget [
    | findWidget replaceWidget textWidget userAction undoStack lastCommand cut textSaved lastSavedCommand |

    GtkTextWidget class >> newWithBuffer: aGtkTextBuffer [
        <category: 'instance creation'>

	^ self new
	    initialize;
	    buffer: aGtkTextBuffer;
	    yourself
    ]

    connectToWhenPopupMenu: aMenu [
        <category: 'button event'>
        popupMenu := aMenu.
	textWidget
	    connectSignal: 'populate-popup' to: self selector: #'popupMenuOn:menu:'
    ]

    popupMenuOn: aWidget menu: aGtkMenu [
        <category: 'button event'>
        aGtkMenu append: (GTK.GtkMenuItem new show; yourself).
        popupMenu appendTo: aGtkMenu
    ]

    connectSignals [
	<category: 'initialization'>

	textWidget
	    connectSignal: 'paste-clipboard' to: self selector: #pasteFromClipboard;
            connectSignal: 'cut-clipboard' to: self selector: #cutFromClipboard.

	(self buffer)
            connectSignal: 'begin-user-action' to: self selector: #'beginUserAction';
            connectSignal: 'end-user-action' to: self selector: #'endUserAction';
            connectSignal: 'insert-text' to: self selector: #'insert:at:text:size:';
            connectSignal: 'delete-range' to: self selector: #'delete:from:to:'
    ]

    initialize [
        <category: 'initialization'>

	textSaved := false.
        cut := userAction := false.
        undoStack := (UndoStack new)
                        initialize;
                        yourself.
	textWidget := GTK.GtkTextView new.
	self 
	    mainWidget: self buildWidget;
	    connectSignals.
	
    ]

    postInitialize [
        <category: 'initialize'>

        findWidget mainWidget hide.
        replaceWidget mainWidget hide.
    ]

    buildWidget [
	<category: 'user interface'>

        | vbox |
        vbox := GTK.GtkVBox new: false spacing: 3.
        self packPluginsInto: vbox.
        vbox packStart: (GTK.GtkScrolledWindow withChild: textWidget) expand: true fill: true padding: 0.
        ^vbox
    ]

    packPluginsInto: vbox [
	<category: 'user interface'>
        vbox
            packEnd: ((findWidget := GtkFindWidget on: self) mainWidget) expand: false fill: false padding: 0;
            packEnd: ((replaceWidget := GtkReplaceWidget on: self)  mainWidget) expand: false fill: false padding: 0;
            yourself
    ]

    beginUserAction [
        <category: 'buffer events'>

        userAction := true
    ]

    endUserAction [
        <category: 'buffer events'>

        userAction := false
    ]

    pasteFromClipboard [
        <category: 'clipboard events'>

        lastCommand := nil
    ]

    cutFromClipboard [
        <category: 'clipboard events'>

        cut := true and: [ self buffer getHasSelection ].
        cut ifTrue: [ lastCommand := nil ]
    ]

    insert: aGtkTextBuffer at: aCObject text: aString size: anInteger [
        <category: 'buffer events'>

        | gtkTextIter offset |
        userAction ifFalse: [ ^ self ].
        gtkTextIter := GTK.GtkTextIter address: aCObject address.
	(aString size = 1 and: [ aString first = Character lf]) 
	    ifTrue: [ lastCommand := InsertTextCommand insert: aString at: gtkTextIter getOffset on: self buffer.
                undoStack push: lastCommand.
		lastCommand := nil.
		^ self ].
        (lastCommand isNil or: [ aString size > 1 ])
            ifTrue: [ lastCommand := InsertTextCommand insert: aString at: gtkTextIter getOffset on: self buffer.
                undoStack push: lastCommand.
                aString size > 1 ifTrue: [ lastCommand := nil ].
                ^ self ].
        ((gtkTextIter getOffset = (lastCommand offset + lastCommand size)) and: [ lastCommand isInsertCommand ])
            ifTrue: [ lastCommand string: (lastCommand string, aString).
                ^ self ].
        lastCommand := InsertTextCommand insert: aString at: gtkTextIter getOffset on: self buffer.
        undoStack push: lastCommand.
    ]

    delete: aGtkTextBuffer from: aStartCObject to: anEndCObject [
        <category: 'buffer events'>

        | startIter endIter text |
        userAction ifFalse: [ cut := false. ^ self ].
        startIter := GTK.GtkTextIter address: aStartCObject address.
        endIter := GTK.GtkTextIter address: anEndCObject address.
        text := self buffer getText: startIter end: endIter includeHiddenChars: false.
        (lastCommand isNil or: [ cut ])
            ifTrue: [ lastCommand := DeleteTextCommand from: startIter getOffset to: endIter getOffset text: text on: self buffer.
                undoStack push: lastCommand.
                cut ifTrue: [ lastCommand := nil ].
                cut := false.
                ^ self ].
        ((startIter getOffset = (lastCommand offset - lastCommand size)) and: [ lastCommand isDeleteCommand ])
            ifTrue: [ lastCommand string: (text, lastCommand string).
                ^ self ].
        lastCommand := DeleteTextCommand from: startIter getOffset to: endIter getOffset text: text on: self buffer.
        undoStack push: lastCommand.
    ]

    hasChanged [
        <category: 'testing'>

        ^ textSaved not and: [ undoStack hasUndo ]
    ]

    hasUndo [
	<category: 'buffer events'>

	^ undoStack hasUndo
    ]

    clearUndo [
	<category: 'buffer events'>

        textSaved := false.
        lastSavedCommand := nil.
	undoStack clear
    ]

    undo [
        <category: 'buffer events'>

        textSaved := self lastUndoCommand == lastSavedCommand.
        undoStack undo.
        lastCommand := nil.
    ]

    redo [
        <category: 'buffer events'>

        undoStack redo.
        lastCommand := nil.
        textSaved := self lastUndoCommand == lastSavedCommand.
    ]

    emptyStack [
	<category: 'stack events'>

	undoStack clear
    ]

    lastUndoCommand [
	<category: 'buffer events'>

	^ undoStack lastUndoCommand
    ]

    textSaved [
        <category: 'accessing'>

        textSaved := true.
        lastCommand := nil.
        lastSavedCommand := undoStack lastUndoCommand
    ]

    buffer [
	<category: 'accessing'>

	^ textWidget getBuffer
    ]

    buffer: aGtkTextBuffer [
	<category: 'accessing'>

	textWidget setBuffer: aGtkTextBuffer
    ]

    showFind [
        <category: 'user interface'>

        replaceWidget hideAll.
	findWidget showAll; grabFocus
    ]

    showReplace [
        <category: 'user interface'>

        findWidget hideAll.
	replaceWidget showAll; grabFocus
    ]

    replace: aSearchString by: aReplaceString [
        <category: 'text editing'>

	lastCommand := ReplaceTextCommand replace: aSearchString by: aReplaceString on: self buffer.
        undoStack push: lastCommand.
        lastCommand := nil
    ]

    copy [
        <category: 'text editing'>

        textWidget signalEmitByName: 'copy-clipboard' args: {}
    ]

    cut [
        <category: 'text editing'>

        textWidget signalEmitByName: 'cut-clipboard' args: {}
    ]

    paste [
        <category: 'text editing'>

        textWidget signalEmitByName: 'paste-clipboard' args: {}.
    ]

    selectAll [
        <category: 'text editing'>

        textWidget signalEmitByName: 'select-all' args: {true}.
    ]

    iterOfSelectedText [
        <category: 'text accessing'>

        ^ textWidget getBuffer iterOfSelectedText
    ]

    hasSelection [
        <category: 'text accessing'>

	^ self buffer getHasSelection
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        ^ STInST.RBParser selectedSymbol: self selectedText
    ]

    selectedText [
        <category: 'text accessing'>

        ^ self buffer selectedText
    ]

    clear [
        <category: 'updating'>

        self text: ''
    ]

    text [
        <category: 'text accessing'>

        ^ self buffer text
    ]

    text: aString [
        <category: 'text accessing'>

        self buffer setText: aString
    ]

    textview [
	<category: 'text widget'>

	^ textWidget
    ]

    cursorPosition [
	<category: 'accessing'>

	^ self buffer propertiesAt: 'cursor-position'
    ]

    cursorPosition: anInteger [
        <category: 'accessing'>

    ]

    selectRange: aStartInt bound: anEndInt [
	<category: 'accessing'>

	| start end |
	start := self buffer getIterAtOffset: aStartInt.
        end := self buffer getIterAtOffset: anEndInt.
	self buffer selectRange: start bound: end
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>
    ]

    afterEvaluation [
        <category: 'smalltalk event'>
    ]

    doIt: object [
        <category: 'smalltalk event'>

	| result |
        self beforeEvaluation.
        result := Behavior
		    evaluate: self buffer selectedText
		    to: object
		    ifError: [ :fname :lineNo :errorString | self error: errorString ].
	self afterEvaluation.
	^ result
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        self beforeEvaluation.
        object class
            compile: ('Doit [ ^ [ ', self selectedText , ' ] value ]')
            ifError:  [ :fname :lineNo :errorString |
                self error: errorString ].
        (GtkDebugger open)
            doItProcess: [ object perform: #Doit ] newProcess
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        GtkInspector openOn: (self doIt: object)
    ]

    printIt: object [
        <category: 'smalltalk event'>

        | iter start end result |
        iter := self buffer iterOfSelectedText second.
        result := ' ', ((self doIt: object) displayString), ' '.
        self buffer insertInteractive: iter text: result len: result size defaultEditable: true.
        start := self buffer getIterAtOffset: (iter getOffset - result size).
        end := self buffer getIterAtOffset: (iter getOffset).
        self buffer selectRange: start bound: end
    ]

]
