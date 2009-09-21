GTK.GtkWidget subclass: GtkWebView [

    WebKitAvailable := nil.

    GtkWebView class >> update: aSymbol [
	<category: 'C call-outs'>

	aSymbol == #returnFromSnapshot ifTrue: [ WebKitAvailable := nil ].
    ]

    GtkWebView class >> hasWebkit [
	<category: 'testing'>

	^WebKitAvailable ifNil: [
	    DLD addLibrary: 'libwebkit-1.0'.
	    WebKitAvailable :=
		CFunctionDescriptor isFunction: 'webkit_web_view_new' ]
    ]

    GtkWebView class >> new [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_new' returning: #{GtkWebView} args: #( )>
    ]

    openUrl: aString [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_open' returning: #void args: #( #self #string )>
    ]
]

