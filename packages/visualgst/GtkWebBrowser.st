GtkBrowsingTool subclass: GtkWebBrowser [
    | webview |

    GtkWebBrowser class >> openOn: aString [
        <category: 'user interface'>

        ^ (self openSized: 450@375)
	    url: aString
    ]

    GtkWebBrowser class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Smallzilla>'
    ]

    windowTitle [
        ^ 'Smallzilla'
    ]

    aboutTitle [
	^ 'About Smallzilla'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

        webview := GtkWebView new
                        openUrl: 'http://smalltalk.gnu.org/';
                        showAll;
                        yourself.

	^ (GTK.GtkScrolledWindow withChild: webview)
	    showAll; 
	    yourself
    ]

    url: aString [
	<category: 'webkit events'>

	webview openUrl: aString
    ]

    hasChanged [
	<category: 'testing'>

	^ false
    ]
]

