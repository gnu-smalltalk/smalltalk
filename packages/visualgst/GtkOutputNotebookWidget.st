GtkNotebookWidget subclass: GtkOutputNotebookWidget [
    | transcriptWidget |

    initialize [
	<category: 'initialization'>

	pages := OrderedCollection new.
	self mainWidget: self buildNotebookWidget
    ]

    buildNotebookWidget [
	<category: 'user interface'>

        ^ notebook := GTK.GtkNotebook new
			    connectSignal: 'switch-page'
			    to: self
			    selector: #'switchPageOn:page:number:'
			    userData: nil
    ]

    addTranscript: aWidget labeled: aString [
	<category: 'user interface'>

	self addWidget: (transcriptWidget := aWidget) labeled: aString.
    ]

    closeIt: aGtkButton  at: aGtkConcreteWidget [
        <category: 'notebook events'>

	aGtkConcreteWidget = transcriptWidget ifTrue: [ self error: 'Can not remove the transcript tab' ].
	super closeIt: aGtkButton at: aGtkConcreteWidget
    ]
]

