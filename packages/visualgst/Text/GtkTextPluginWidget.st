GtkConcreteWidget subclass: GtkTextPluginWidget [
    | textWidget|

    GtkTextPluginWidget class >> on: aTextWidget [
	<category: 'instance creation'>

	^ self new
	    initialize;
	    textWidget: aTextWidget;
	    yourself
    ]

    initialize [
	<category: 'initialize'>

	self mainWidget: self buildWidget
    ]

    buildCloseButton [
        <category: 'user interface'>

	^ GTK.GtkButton closeButton
	    connectSignal: 'pressed' to: self selector: #'close' userData: nil;
	    yourself
    ]

    hBox [
        <category: 'user interface'>

        ^ (GTK.GtkHBox new: false spacing: 3)
            packStart: self buildCloseButton expand: false fill: false padding: 0;
            yourself
    ]

    buildWidget [
	<category: 'user interface'>

	^ (GTK.GtkVBox new: false spacing: 3)
	    packStart: self hBox expand: false fill: false padding: 0;
	    yourself
    ]

    close [
	<category: 'events'>

	self mainWidget hide
    ]

    textWidget: aTextWidget [
	<category: 'accessing'>

	textWidget := aTextWidget
    ]
]

