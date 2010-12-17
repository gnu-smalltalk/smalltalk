GtkBrowsingTool subclass: GtkAssistant [

    GtkAssistant class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Assistant>'
    ]

    windowTitle [
	^ 'Assistant'
    ]

    aboutTitle [
	^ 'About Assistant'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

        | webview |

        webview := GtkWebView new
                        openUrl: 'http://library.gnome.org/devel/gtk/stable/index.html';
                        showAll;
                        yourself.

	^ (GTK.GtkScrolledWindow withChild: webview)
	    showAll; 
	    yourself
    ]

    hasChanged [
	<comment: 'I have to implement that. But I have nothing to do.'>

	^ false
    ]
]

