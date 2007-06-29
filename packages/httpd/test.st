PackageLoader fileInPackage: 'WebServer'.
Namespace current: NetClients.WikiWorks!
Smalltalk arguments do: [ :each | FileStream fileIn: each ]!
Namespace current: Smalltalk!
ObjectMemory snapshot!

Namespace current: NetClients.WikiWorks!

WebServer publishMyFileSystem.
"WebServer initializeWiki."
"WebServer restartWikiNoImages."
"WebServer restartWiki."

"leave the other processes running"
Processor activeProcess priority: Processor rockBottomPriority.
[ Processor yield ] repeat!
