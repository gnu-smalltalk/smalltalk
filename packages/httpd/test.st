Eval [
    PackageLoader fileInPackage: 'WebServer'
]



Namespace current: NetClients.WikiWorks [
    Smalltalk arguments do: [:each | FileStream fileIn: each]
]



Eval [
    ObjectMemory snapshot
]



Namespace current: NetClients.WikiWorks [
    WebServer publishMyFileSystem.
    "WebServer initializeWiki."
    "WebServer restartWikiNoImages."
    "WebServer restartWiki."

    Processor activeProcess suspend
]

