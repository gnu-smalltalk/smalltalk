GTK.GtkWidget subclass: GtkWebView [

    WebKitAvailable := nil.

    GtkWebView class >> initialize [
        <category: 'initialize'>

        DLD addLibrary: 'libwebkit-1.0'.
        DLD addLibrary: 'libwebkitgtk-1.0'.
        ObjectMemory addDependent: self.
    ]

    GtkWebView class >> update: aSymbol [
        <category: 'initialize'>

        aSymbol == #returnFromSnapshot ifTrue: [ WebKitAvailable := nil ].
    ]

    GtkWebView class >> hasWebkit [
        <category: 'testing'>

        ^ WebKitAvailable ifNil: [
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

Eval [
    GtkWebView initialize
]
