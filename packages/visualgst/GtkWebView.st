GTK.GtkWidget subclass: GtkWebView [
    GtkWebView class >> registerDLD [
	DLD addLibrary: 'libwebkit-1.0'
    ]

    GtkWebView class >> new [
	<cCall: 'webkit_web_view_new' returning: #{GtkWebView} args: #( )>
    ]

    openUrl: aString [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_open' returning: #void args: #( #self #string )>
    ]
]

