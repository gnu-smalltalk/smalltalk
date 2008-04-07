"======================================================================
|
|   Wiki-style web server plug-in
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001 Travis Griggs and Ken Treis
| Written by Travis Griggs, Ken Treis and others.
| Port to GNU Smalltalk, enhancements and refactoring by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"



Object subclass: WikiPage [
    | author timestamp |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    WikiPage class >> newVersionOf: aWikiPage by: anAuthor [
	<category: 'instance creation'>
	^(self new)
	    previousVersion: aWikiPage;
	    author: anAuthor;
	    yourself
    ]

    WikiPage class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    allTitles [
	<category: 'accessing'>
	| oc |
	oc := OrderedCollection new.
	self allTitlesInto: oc.
	^oc
    ]

    allTitlesInto: aCollection [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    author [
	<category: 'accessing'>
	^author
    ]

    contents [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    references: aString [
	<category: 'accessing'>
	^(aString match: self contents) or: [aString match: self title]
    ]

    operationSynopsis [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    title [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    versionAt: aNumber [
	<category: 'accessing'>
	self versionsDo: [:each | each versionNumber = aNumber ifTrue: [^each]].
	^self subscriptBoundsError: aNumber
    ]

    versionNumber [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    versionsDo: aBlock [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    versionsReverseDo: aBlock [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'displaying'>
	aStream
	    nextPut: $[;
	    nextPutAll: self title;
	    nextPut: $(;
	    print: self versionNumber;
	    nextPut: $);
	    nextPut: $];
	    nl;
	    nextPutAll: self contents;
	    nl.
	aStream
	    nextPut: ${;
	    nextPutAll: author;
	    space;
	    print: timestamp;
	    nextPut: $}
    ]

    changeTitle: aTitle by: anAuthor [
	<category: 'editing'>
	| newGuy |
	aTitle = self title ifTrue: [^self].
	newGuy := RenamedWikiPage newVersionOf: self by: anAuthor.
	newGuy title: aTitle.
	^newGuy
    ]

    newContents: aContents by: anAuthor [
	<category: 'editing'>
	| newGuy |
	aContents = self contents ifTrue: [^self].
	newGuy := EditedWikiPage newVersionOf: self by: anAuthor.
	newGuy contents: aContents.
	^newGuy
    ]

    author: anObject [
	<category: 'initialize'>
	author := anObject
    ]

    initialize [
	<category: 'initialize'>
	timestamp := DateTime now.
	author := ''
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	aFileStream
	    nextPutAll: author;
	    nl.
	aFileStream
	    print: timestamp asSeconds;
	    nl.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	| timestamp author seconds |
	author := rs nextLine.
	seconds := rs nextLine asNumber.
	timestamp := (Date 
		    year: 1901
		    day: 1
		    hour: 0
		    minute: 0
		    second: 0) + (Duration seconds: seconds).
	self
	    author: author;
	    timestamp: timestamp
    ]

    timestamp: value [
	<category: 'flat file'>
	timestamp := value
    ]
]



WikiPage subclass: OriginalWikiPage [
    | title |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    allTitlesInto: aCollection [
	<category: 'accessing'>
	aCollection add: title
    ]

    contents [
	<category: 'accessing'>
	^'Describe ' , title , ' here...'
    ]

    operationSynopsis [
	<category: 'accessing'>
	^'Created'
    ]

    title [
	<category: 'accessing'>
	^title
    ]

    title: aString [
	<category: 'accessing'>
	title := aString
    ]

    versionNumber [
	<category: 'accessing'>
	^0
    ]

    versionsDo: aBlock [
	<category: 'accessing'>
	aBlock value: self
    ]

    versionsReverseDo: aBlock [
	<category: 'accessing'>
	aBlock value: self
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream nextPutAll: title.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	super loadFromFile: rs under: aWikiPM.
	self title: rs upToEnd
    ]
]



WikiPage subclass: ChangedWikiPage [
    | previousVersion |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    allTitlesInto: aCollection [
	<category: 'accessing'>
	previousVersion allTitlesInto: aCollection
    ]

    contents [
	<category: 'accessing'>
	^previousVersion contents
    ]

    previousVersion [
	<category: 'accessing'>
	^previousVersion
    ]

    previousVersion: anObject [
	<category: 'accessing'>
	previousVersion := anObject
    ]

    title [
	<category: 'accessing'>
	^previousVersion title
    ]

    versionNumber [
	<category: 'accessing'>
	^previousVersion versionNumber + 1
    ]

    versionsDo: aBlock [
	<category: 'accessing'>
	aBlock value: self.
	previousVersion versionsDo: aBlock
    ]

    versionsReverseDo: aBlock [
	<category: 'accessing'>
	previousVersion versionsReverseDo: aBlock.
	aBlock value: self
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream
	    print: (aWikiPM idForPage: self previousVersion);
	    nl.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	| id |
	super loadFromFile: rs under: aWikiPM.
	id := rs nextLine.
	self previousVersion: (aWikiPM loadPage: id)
    ]
]



ChangedWikiPage subclass: EditedWikiPage [
    | contents |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    contents [
	<category: 'accessing'>
	^contents
    ]

    contents: aString [
	"trim off trailing CRs"

	<category: 'accessing'>
	| index |
	index := aString size.
	[index > 1 and: [(aString at: index) = Character nl]] 
	    whileTrue: [index := index - 1].
	contents := aString copyFrom: 1 to: index
    ]

    operationSynopsis [
	<category: 'accessing'>
	^'Edited'
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream nextPutAll: contents.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	super loadFromFile: rs under: aWikiPM.
	self contents: rs upToEnd
    ]
]



ChangedWikiPage subclass: RenamedWikiPage [
    | title |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    allTitlesInto: aCollection [
	<category: 'accessing'>
	aCollection add: title.
	^super allTitlesInto: aCollection
    ]

    operationSynopsis [
	<category: 'accessing'>
	^'Renamed'
    ]

    title [
	<category: 'accessing'>
	^title
    ]

    title: aString [
	<category: 'accessing'>
	title := aString
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream nextPutAll: title.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	super loadFromFile: rs under: aWikiPM.
	self title: rs upToEnd
    ]
]



Object subclass: WikiSettings [
    | dictionary |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    WikiSettings class >> cookieString: aString [
	<category: 'instance creation'>
	^self new fromCookieString: aString
    ]

    WikiSettings class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    loadFromFile: aFileStream [
	<category: 'flat file'>
	| line |
	[(line := aFileStream nextLine) isEmpty] whileFalse: 
		[line := line substrings: $=.
		line size = 2 
		    ifTrue: [self at: (line at: 1) put: (line at: 2)]
		    ifFalse: [self at: (line at: 1) put: true]]
    ]

    saveToFile: ws [
	<category: 'flat file'>
	| line |
	self settingsDo: 
		[:key :value | 
		value == false 
		    ifFalse: 
			[line := key.
			value == true ifFalse: [line := line , '=' , 'value'].
			ws
			    nextPutAll: line;
			    nl]].
	ws nl
    ]

    initialize [
	<category: 'private'>
	dictionary := Dictionary new
    ]

    at: name put: value [
	<category: 'private'>
	^dictionary at: name put: value
    ]

    at: name default: default [
	<category: 'private'>
	^dictionary at: name ifAbsentPut: [default]
    ]

    backgroundColor [
	<category: 'settings'>
	^self at: 'bc' default: '#ffffff'
    ]

    backgroundColor: anObject [
	<category: 'settings'>
	self at: 'bc' put: anObject
    ]

    linkColor [
	<category: 'settings'>
	^self at: 'lc' default: '#0000ff'
    ]

    linkColor: anObject [
	<category: 'settings'>
	self at: 'lc' put: anObject
    ]

    tableBackgroundColor [
	<category: 'settings'>
	^self at: 'tbc' default: '#ffe0ff'
    ]

    tableBackgroundColor: anObject [
	<category: 'settings'>
	self at: 'tbc' put: anObject
    ]

    textColor [
	<category: 'settings'>
	^self at: 'tc' default: '#000000'
    ]

    textColor: anObject [
	<category: 'settings'>
	self at: 'tc' put: anObject
    ]

    visitedLinkColor [
	<category: 'settings'>
	^self at: 'vlc' default: '#551a8b'
    ]

    visitedLinkColor: anObject [
	<category: 'settings'>
	self at: 'vlc' put: anObject
    ]
]



Servlet subclass: Wiki [
    | settings pages rootPageTitle syntaxPageTitle fileServer persistanceManager |
    
    <comment: 'A Wiki is made up of four kinds of classes; Wiki, WikiPersistanceManager,
WikiPage, and WikiHTML.  A Wiki has a collection of WikiPages, which can be read or
edited over the web, and is able to select a WikiHTML to match the command to
be performed.  WikiHTML objects produce HTML for the page, which the WebServer
will send back to the web browser.  A WikiPersistanceManager knows how to save to
disk and then retrieve the pages that make up a Wiki; the reason why it is separated
from the Wiki class is that, this way, you can use any kind of persistance (binary,
flat file,...) with any kind of Wiki (password-protected, normal,
read-only,...).

There are many subclasses of WikiHTML, one for each way that a page can be
converted into HTML.  Each subclass represents a different command, such as editing,
changing the name of a page, or looking at old versions of a page.

There are also many subclasses of WikiPage.  Except for the original page, each
version points to the previous version of the page.  Since the original page is always
of the form "Describe XXX here", it is not very interesting.  Other versions of the page
can have a custom contents or can be renamed.'>
    <category: 'Web-Wiki'>

    Wiki class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    Wiki class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize'>
	pages := Dictionary new.
	settings := WikiSettings new.
	self name: 'Wiki'.
	self rootPageTitle: 'Duh Tawp'.
	self syntaxPageTitle: 'Duh Rools'
    ]

    redirectToRootPage: aRequest [
	<category: 'interaction'>
	aRequest location addLast: self rootPageTitle , '.html'.
	"self sendPageFor: aRequest."
	^(ErrorResponse 
	    movedTemporarilyTo: self printString , '/' , aRequest location last) 
		respondTo: aRequest
    ]

    removeHTMLFrom: pageTitle [
	<category: 'interaction'>
	pageTitle size > 5 ifFalse: [^pageTitle].
	^(pageTitle copyFrom: pageTitle size - 4 to: pageTitle size = '.html') 
	    ifTrue: [pageTitle copyFrom: 1 to: pageTitle size - 5]
	    ifFalse: [pageTitle]
    ]

    sendPageFor: aRequest [
	<category: 'interaction'>
	| pageTitle |
	pageTitle := self removeHTMLFrom: aRequest location last.
	^(self hasPageTitled: pageTitle) 
	    ifTrue: [WikiPageHTML respondTo: aRequest in: self]
	    ifFalse: [WikiAbsentPageHTML respondTo: aRequest in: self]
    ]

    replyToGetRequest: aRequest [
	<category: 'interaction'>
	| rClass size |
	size := aRequest location size - self depth + 1.
	size < 2 
	    ifTrue: 
		[size = 0 ifTrue: [^self redirectToRootPage: aRequest].
		^(aRequest location last sameAs: 'RECENT CHANGES') 
		    ifTrue: [WikiChangesHTML respondTo: aRequest in: self]
		    ifFalse: [self sendPageFor: aRequest]].
	rClass := size = 2 
		    ifTrue: [self classForCommand: aRequest]
		    ifFalse: [WikiErrorHTML].
	^rClass respondTo: aRequest in: self
    ]

    classForCommand: aRequest [
	<category: 'interaction'>
	| cmd page |
	cmd := aRequest location at: self depth.
	page := aRequest location last.
	(cmd sameAs: 'CREATE') 
	    ifTrue: 
		[self createPageFor: aRequest.
		^WikiEditHTML].
	(self hasPageTitled: page) ifFalse: [^WikiAbsentPageHTML].
	(cmd sameAs: 'EDIT') ifTrue: [^WikiEditHTML].
	(cmd sameAs: 'HISTORY') ifTrue: [^WikiHistoryHTML].
	(cmd sameAs: 'RENAME') ifTrue: [^WikiRenameHTML].
	(cmd sameAs: 'REFS') ifTrue: [^WikiReferencesHTML].
	(cmd sameAs: 'VERSION') ifTrue: [^WikiVersionHTML].
	^WikiErrorHTML
    ]

    replyToPostEditRequest: aRequest [
	<category: 'interaction'>
	| newPage currentPage newContents |
	currentPage := self pageTitled: aRequest location last.
	newContents := aRequest postDataAt: #NEWCONTENTS.
	newPage := currentPage newContents: newContents by: aRequest originator.
	self addPage: newPage.
	self sendPageFor: aRequest
    ]

    replyToPostRenameRequest: aRequest [
	<category: 'interaction'>
	| currentPage newTitle newPage |
	currentPage := self pageTitled: aRequest location last.
	newTitle := aRequest postDataAt: #NEWTITLE.
	((self hasPageTitled: newTitle) 
	    and: [(self pageTitled: newTitle) ~= currentPage]) 
		ifTrue: [^WikiRenameConflictHTML respondTo: aRequest in: self].
	newPage := currentPage changeTitle: newTitle by: aRequest originator.
	self addPage: newPage.
	self sendPageFor: aRequest
    ]

    replyToPostRequest: aRequest [
	<category: 'interaction'>
	| cmd |
	cmd := aRequest postDataAt: #COMMAND.
	(cmd sameAs: 'EDIT') ifTrue: [^self replyToPostEditRequest: aRequest].
	(cmd sameAs: 'RENAME') ifTrue: [^self replyToPostRenameRequest: aRequest].
	(cmd sameAs: 'SEARCH') ifTrue: [^self replyToPostSearchRequest: aRequest].
	self replyToUnknownRequest: aRequest
    ]

    replyToPostSearchRequest: aRequest [
	<category: 'interaction'>
	^WikiReferencesHTML respondTo: aRequest in: self
    ]

    replyToUnknownRequest: aRequest [
	<category: 'interaction'>
	^WikiErrorHTML respondTo: aRequest in: self
    ]

    respondTo: aRequest [
	<category: 'interaction'>
	(aRequest action sameAs: 'HEAD') 
	    ifTrue: [^self replyToGetRequest: aRequest].
	(aRequest action sameAs: 'GET') 
	    ifTrue: [^self replyToGetRequest: aRequest].
	(aRequest action sameAs: 'POST') 
	    ifTrue: [^self replyToPostRequest: aRequest].
	^(ErrorResponse acceptableMethods: #('HEAD' 'GET' 'POST')) 
	    respondTo: aRequest
    ]

    syntaxPageTitle [
	<category: 'accessing'>
	^(self pageTitled: syntaxPageTitle) title
    ]

    syntaxPageTitle: aString [
	<category: 'accessing'>
	syntaxPageTitle notNil 
	    ifTrue: [pages removeKey: syntaxPageTitle asUppercase].
	syntaxPageTitle := aString.
	self addPage: self newSyntaxPage
    ]

    filesPath [
	<category: 'accessing'>
	^fileServer isNil ifTrue: [nil] ifFalse: [fileServer printString]
    ]

    filesPath: aString [
	<category: 'accessing'>
	| path |
	aString isNil ifTrue: [^self fileServer: nil].
	path := (aString at: 1) == $/ 
		    ifTrue: [WebServer current handler]
		    ifFalse: [self parent].
	(aString substrings: $/) 
	    do: [:each | each isEmpty ifFalse: [path := path componentNamed: each]].
	self fileServer: path
    ]

    fileServer [
	<category: 'accessing'>
	^fileServer
    ]

    fileServer: aString [
	<category: 'accessing'>
	fileServer := aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    persistanceManager: aWikiPersistanceManager [
	<category: 'accessing'>
	persistanceManager := aWikiPersistanceManager.
	aWikiPersistanceManager wiki: self
    ]

    rootPageTitle [
	<category: 'accessing'>
	^(self pageTitled: rootPageTitle) title
    ]

    rootPageTitle: aString [
	<category: 'accessing'>
	rootPageTitle notNil ifTrue: [pages removeKey: rootPageTitle asUppercase].
	rootPageTitle := aString.
	self addPage: (OriginalWikiPage new title: rootPageTitle)
    ]

    save [
	<category: 'accessing'>
	persistanceManager save
    ]

    settings [
	<category: 'accessing'>
	^settings
    ]

    startDate [
	<category: 'accessing'>
	^((self pageTitled: self rootPageTitle) versionAt: 0) timestamp
    ]

    loadFromFile: aFileStream [
	<category: 'flat file'>
	| path |
	settings loadFromFile: aFileStream.
	self name: aFileStream nextLine.
	self rootPageTitle: aFileStream nextLine.
	self syntaxPageTitle: aFileStream nextLine.
	path := aFileStream nextLine.
	path = '<none>' ifTrue: [path := nil].
	self filesPath: path.
	^self
    ]

    saveToFile: ws [
	<category: 'flat file'>
	settings saveToFile: ws.
	ws
	    nextPutAll: self name;
	    nl.
	ws
	    nextPutAll: self rootPageTitle;
	    nl.
	ws
	    nextPutAll: self syntaxPageTitle;
	    nl.
	self filesPath isNil 
	    ifTrue: 
		[ws
		    nextPutAll: '<none>';
		    nl]
	    ifFalse: 
		[ws
		    nextPutAll: self filesPath;
		    nl].
	^self
    ]

    addPage: aPage [
	<category: 'pages'>
	aPage allTitles do: [:each | pages at: each asUppercase put: aPage].
	persistanceManager isNil ifFalse: [persistanceManager addPage: aPage]
    ]

    currentPageTitleFor: aString [
	<category: 'pages'>
	^(aString sameAs: 'Changes') 
	    ifTrue: ['Recent Changes']
	    ifFalse: [(pages at: aString asUppercase) title]
    ]

    currentTitleOf: aString [
	<category: 'pages'>
	^(aString sameAs: 'RECENT CHANGES') 
	    ifTrue: [aString]
	    ifFalse: [(self pageTitled: aString) title]
    ]

    syntaxPage [
	<category: 'pages'>
	^self pageTitled: syntaxPageTitle
    ]

    hasPageTitled: aString [
	<category: 'pages'>
	^(pages includesKey: aString asUppercase) 
	    or: [aString sameAs: 'RECENT CHANGES']
    ]

    allPagesDo: aBlock [
	<category: 'pages'>
	pages do: aBlock
    ]

    pagesDo: aBlock [
	"when enumerating the pages dictionary, we want to filter to only those entries whose titles are current, this avoids double enumerating a page that might have two or more titles in it's history"

	<category: 'pages'>
	pages 
	    keysAndValuesDo: [:title :page | (page title sameAs: title) ifTrue: [aBlock value: page]]
    ]

    pageTitled: aString [
	<category: 'pages'>
	^pages at: aString asUppercase
    ]

    createPageFor: aRequest [
	<category: 'private'>
	(self hasPageTitled: aRequest location last) 
	    ifFalse: 
		[self addPage: ((OriginalWikiPage new)
			    author: aRequest originator;
			    title: aRequest location last;
			    yourself)]
    ]

    newSyntaxPage [
	<category: 'private'>
	^(OriginalWikiPage new title: syntaxPageTitle) 
	    newContents: self newSyntaxPageContents
	    by: ''
    ]

    newSyntaxPageContents [
	<category: 'private'>
	^'The Wiki''s a place where anybody can edit anything. To do so just follow the <I>Edit this page</I> link at the top or bottom of a page. The formatting rules are pretty simple:
. Links are created by placing square brackets around the link name (e.g. [[aPageName]). If you need to create a [[ character, use two of them (e.g. "[[[["). You don''t need to double up the ] character unless you actually want to use it as part of the link name.
. If you want to create a link to an "outside" source, just include the full internet protocol name (e.g. [[http://www.somesite.com] or [[mailto:someone@somewhere.com] or [[ftp://somesite.ftp]).
. If you want a link (either internal or outside) by another name, then place both the desired name and the actual link target as a pair separated by > character (e.g. [[The Top > Home Page] or [[me > mailto:myname@myplace.com]).
. Carriage returns create a new paragraph
. Use any HTML you want. The Wiki formatting rules will not be applied between a PRE tag.
. To create a horizontal line, start a line with ''----''.
. To create a bullet list item, start a line with a . character.
. To create a numbered list item, start a line with a # character.
. To create a heading, start a line with a * character.  More consecutive asterisks yield lower level headings.
. To create a table, start the line with two | (vertical bar) characters. For each cell in the row, separate again by two | characters. Successive lines that start with the two | characters are made into the same table.
. To publish your edits, press the save button. If you don''t want to publish, just press your browser''s Back button.
'
    ]
]



Wiki subclass: ProtectedWiki [
    | authorizer |
    
    <comment: nil>
    <category: 'Web-Wiki'>

    replyToRequest: aRequest [
	<category: 'authentication'>
	self authorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [super replyToRequest: aRequest]
    ]
]



ProtectedWiki subclass: ReadOnlyWiki [
    
    <comment: nil>
    <category: 'Web-Wiki'>

    replyToPostEditRequest: aRequest [
	<category: 'authentication'>
	self authorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [super replyToPostEditRequest: aRequest]
    ]

    replyToPostRenameRequest: aRequest [
	<category: 'authentication'>
	self authorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [super replyToPostRenameRequest: aRequest]
    ]
]



ProtectedWiki subclass: PasswordWiki [
    
    <comment: nil>
    <category: 'Web-Wiki'>

    authorizer [
	<category: 'authentication'>
	^authorizer
    ]

    authorizer: aWebAuthorizer [
	<category: 'authentication'>
	authorizer := aWebAuthorizer.
	self fileServer isNil 
	    ifFalse: [self fileServer uploadAuthorizer: aWebAuthorizer]
    ]

    loginID: aLoginID password: aPassword [
	<category: 'authentication'>
	self authorizer: (WebAuthorizer loginID: aLoginID password: aPassword)
    ]

    loadFromFile: aFileStream [
	<category: 'flat file'>
	super loadFromFile: aFileStream.
	self authorizer: (WebAuthorizer fromString: aFileStream nextLine).
	^self
    ]

    saveToFile: ws [
	<category: 'flat file'>
	super saveToFile: ws.
	ws
	    nextPutAll: self authorizer authorizer;
	    nl.
	^self
    ]
]



WebResponse subclass: WikiHTML [
    | wiki page |
    
    <comment: 'WikiHTML is an object that can convert a WikiPage to HTML.  There are
different subclasses of WikiHTML for the various ways a page can be rendered,
such as when it is edited or renamed.

All subclasses must implement sendBody.'>
    <category: 'Web-WikiRendering'>

    WikiHTML class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    WikiHTML class >> respondTo: aRequest in: aWiki [
	<category: 'instance creation'>
	^(self new)
	    wiki: aWiki;
	    respondTo: aRequest
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    browserTitle [
	<category: 'accessing'>
	^self wikiName , ': ' , self pageTitle
    ]

    encodedPageTitle [
	<category: 'accessing'>
	^(URL encode: self page title) , '.html'
    ]

    settings [
	<category: 'accessing'>
	^wiki settings
    ]

    page [
	<category: 'accessing'>
	page isNil ifTrue: [page := wiki pageTitled: request location last].
	^page
    ]

    pageTitle [
	<category: 'accessing'>
	^self page title
    ]

    emitIcon: imageBlock linkTo: nameBlock titled: titleBlock [
	<category: 'accessing'>
	self wiki filesPath isNil 
	    ifFalse: 
		[^self
		    image: imageBlock
			linkTo: nameBlock
			titled: titleBlock;
		    nl].
	self td: [self linkTo: nameBlock titled: titleBlock]
    ]

    emitCommonIcons [
	<category: 'accessing'>
	self
	    emitIcon: [self << self wiki filesPath << '/help.jpg']
		linkTo: 
		    [self
			<< self wiki;
			<< $/;
			nextPutUrl: self wiki syntaxPageTitle]
		titled: [self << self wiki syntaxPageTitle];
	    emitIcon: [self << self wiki filesPath << '/recent.jpg']
		linkTo: [self << self wiki << '/RECENT+CHANGES']
		titled: [self << 'Recent changes'];
	    emitIcon: [self << self wiki filesPath << '/top.jpg']
		linkTo: [self << self wiki << $/]
		titled: [self << 'Back to Top']
    ]

    sendBody [
	"subclasses will usually want to do more here"

	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitFinish
    ]

    emitFinish [
	<category: 'accessing'>
	self
	    nl;
	    << '</FONT>';
	    nl;
	    << '</BODY></HTML>'
    ]

    emitSearch: aString [
	<category: 'accessing'>
	self horizontalLine.
	(self << '<FORM ACTION="' << wiki name)
	    << '" METHOD=POST>';
	    nl.
	self
	    << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="SEARCH">';
	    nl.
	(self << '<INPUT TYPE= "TEXT" NAME="SEARCHPATTERN" VALUE="' << aString)
	    << '" SIZE=40>';
	    nl.
	self wiki filesPath isNil 
	    ifFalse: 
		[self << '<INPUT TYPE="image" ALIGN="absmiddle" BORDER="0" SRC="' 
		    << self wiki filesPath << '/find.jpg" ALT=']
	    ifTrue: [self << '<INPUT TYPE="submit" VALUE='].
	self
	    << '"Find..."></FORM>';
	    nl
    ]

    emitStart [
	<category: 'accessing'>
	(self << '<HTML><HEAD><TITLE>' << self browserTitle 
	    << '</TITLE></HEAD><BODY bgcolor=' << self settings backgroundColor 
	    << ' link=' << self settings linkColor 
	    << ' vlink=' << self settings visitedLinkColor)
	    << $>;
	    nl.
	(self << '<FONT color=' << self settings textColor)
	    << $>;
	    nl
    ]

    emitIcons [
	<category: 'accessing'>
	self
	    emitIconsStart;
	    emitCommonIcons;
	    emitIconsEnd
    ]

    emitIconsEnd [
	<category: 'accessing'>
	self wiki filesPath isNil 
	    ifFalse: 
		[self
		    << '<BR>';
		    nl]
	    ifTrue: 
		[self
		    nl;
		    << '</TR>';
		    nl;
		    << '</TABLE>';
		    nl]
    ]

    emitIconsStart [
	<category: 'accessing'>
	self wiki filesPath isNil 
	    ifFalse: 
		[^self image: [self << self wiki filesPath << '/head.jpg']
		    titled: [self << self wiki]].
	self << '<TABLE width=100% bgcolor=' << self settings tableBackgroundColor.
	self
	    << '><TR>';
	    nl
    ]

    emitUrlForCommand: commandName [
	<category: 'accessing'>
	self << self wiki << $/ << commandName << $/ << self encodedPageTitle
    ]

    emitUrlOfPage [
	<category: 'accessing'>
	self << self wiki << $/ << self encodedPageTitle
    ]

    linkToPage: aPage [
	<category: 'accessing'>
	self linkTo: 
		[self
		    << self wiki;
		    << $/;
		    nextPutUrl: aPage title]
	    titled: [self << aPage title]
    ]

    wiki [
	<category: 'accessing'>
	^wiki
    ]

    wiki: anObject [
	<category: 'accessing'>
	wiki := anObject
    ]

    wikiName [
	<category: 'accessing'>
	^wiki name
    ]
]



WikiHTML subclass: WikiPageHTML [
    | contentStream currentChar lastChar inBullets inNumbers heading inTable |
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    ParseTable := nil.

    WikiPageHTML class >> initialize [
	<category: 'initialize'>
	ParseTable := Array new: 256.
	ParseTable at: 1 + Character cr asciiValue put: #processCr.
	ParseTable at: 1 + Character nl asciiValue put: #processNl.
	ParseTable at: 1 + $[ asciiValue put: #processLeftBracket.
	ParseTable at: 1 + $. asciiValue put: #processDot.
	ParseTable at: 1 + $# asciiValue put: #processPound.
	ParseTable at: 1 + $- asciiValue put: #processDash.
	ParseTable at: 1 + $* asciiValue put: #processStar.
	ParseTable at: 1 + $| asciiValue put: #processPipe.
	ParseTable at: 1 + $< asciiValue put: #processLeftAngle
    ]

    isExternalAddress: linkAddress [
	"Faster than #match:"

	<category: 'private-HTML'>
	^#('http:' 'https:' 'mailto:' 'file:' 'ftp:' 'news:' 'gopher:' 'telnet:') 
	    anySatisfy: 
		[:each | 
		each size < linkAddress size and: 
			[(1 to: each size) 
			    allSatisfy: [:index | (each at: index) == (linkAddress at: index)]]]
    ]

    isImage: linkAddress [
	"Faster than #match:"

	<category: 'private-HTML'>
	^#('.gif' '.jpeg' '.jpg' '.jpe') anySatisfy: 
		[:each | 
		each size < linkAddress size and: 
			[(1 to: each size) allSatisfy: 
				[:index | 
				(each at: index) == (linkAddress at: linkAddress size - each size + index)]]]
    ]

    linkAddressIn: aString [
	<category: 'private-HTML'>
	| rs |
	rs := aString readStream.
	rs skipTo: $>.
	^(rs atEnd ifTrue: [aString] ifFalse: [rs upToEnd]) trimSeparators
    ]

    linkNameIn: aString [
	<category: 'private-HTML'>
	| rs |
	rs := aString readStream.
	^(rs upTo: $>) trimSeparators
    ]

    addCurrentChar [
	<category: 'parsing'>
	self responseStream nextPut: currentChar
    ]

    atLineStart [
	<category: 'parsing'>
	^lastChar == Character nl or: [lastChar == nil]
    ]

    closeBulletItem [
	<category: 'parsing'>
	self
	    << '</LI>';
	    nl.
	contentStream peek == $. 
	    ifFalse: 
		[inBullets := false.
		self
		    << '</UL>';
		    nl]
    ]

    closeHeading [
	<category: 'parsing'>
	(self << '</H' << heading)
	    << '>';
	    nl.
	heading := nil
    ]

    closeNumberItem [
	<category: 'parsing'>
	self
	    << '</LI>';
	    nl.
	contentStream peek == $# 
	    ifFalse: 
		[inNumbers := false.
		self
		    << '</OL>';
		    nl]
    ]

    closeTableRow [
	<category: 'parsing'>
	| pos |
	self
	    << '</TD></TR>';
	    nl.
	pos := contentStream position.
	(contentStream peekFor: $|) 
	    ifTrue: 
		[(contentStream peekFor: $|) 
		    ifTrue: 
			[inTable := false.
			self
			    << '</TABLE>';
			    nl]].
	contentStream position: pos
    ]

    processNextChar [
	<category: 'parsing'>
	| selector |
	lastChar := currentChar.
	currentChar := contentStream next.
	selector := ParseTable at: currentChar value + 1.
	^selector isNil 
	    ifTrue: [self addCurrentChar]
	    ifFalse: [self perform: selector]
    ]

    processDot [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	inBullets 
	    ifFalse: 
		[self
		    << '<UL>';
		    nl.
		inBullets := true].
	self << ' <LI>'
    ]

    processStar [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	heading := 2.
	[contentStream peekFor: $*] whileTrue: [heading := heading + 1].
	self << '<H' << heading << '>'
    ]

    processCr [
	<category: 'parsing'>
	contentStream peekFor: Character nl.
	currentChar := Character nl.
	self processNl
    ]

    processNl [
	<category: 'parsing'>
	inBullets ifTrue: [^self closeBulletItem].
	inNumbers ifTrue: [^self closeNumberItem].
	inTable ifTrue: [^self closeTableRow].
	heading isNil ifFalse: [^self closeHeading].
	self lineBreak
    ]

    processDash [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	contentStream skipTo: Character nl.
	self horizontalLine.
	lastChar := Character nl
    ]

    processLeftAngle [
	<category: 'parsing'>
	| s |
	s := String new writeStream.
	self addCurrentChar.
	
	[currentChar := contentStream next.
	currentChar == $> or: [currentChar == $ ]] 
		whileFalse: [s nextPut: currentChar].
	self << (s := s contents) << currentChar.
	(s sameAs: 'PRE') ifFalse: [^self].
	
	[contentStream atEnd ifTrue: [^self].
	self << (contentStream upTo: $<) << $<.
	self << (s := contentStream upTo: $>) << $>.
	s sameAs: '/PRE'] 
		whileFalse
    ]

    processLeftBracket [
	<category: 'parsing'>
	| linkAddress linkName link |
	(contentStream peekFor: $[) ifTrue: [^self addCurrentChar].
	link := contentStream upTo: $].
	[contentStream peekFor: $]] 
	    whileTrue: [link := link , ']' , (contentStream upTo: $])].
	linkName := self linkNameIn: link.
	linkAddress := self linkAddressIn: link.
	(self isExternalAddress: linkAddress) 
	    ifTrue: 
		["external outside link"

		^self << '<A HREF="' << linkAddress << '">' << linkName << '</A>'].
	linkAddress = linkName 
	    ifTrue: [self emitLink: linkName]
	    ifFalse: [self emitLink: linkName to: linkAddress]
    ]

    processPipe [
	<category: 'parsing'>
	(contentStream peekFor: $|) 
	    ifTrue: 
		[self atLineStart 
		    ifTrue: 
			[inTable 
			    ifFalse: 
				[self
				    << '<TABLE BORDER=2 CELLPADDING=4 CELLSPACING=0 >';
				    nl.
				inTable := true].
			self << '<TR><TD>']
		    ifFalse: [self << '</TD><TD>']]
	    ifFalse: [self addCurrentChar]
    ]

    processPound [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	inNumbers 
	    ifFalse: 
		[self
		    << '<OL>';
		    nl.
		inNumbers := true].
	self << ' <LI>'
    ]

    emitLink: linkAddress [
	<category: 'parsing'>
	| currentTitle |
	(self isImage: linkAddress) 
	    ifTrue: 
		["graphic image link"

		(self isExternalAddress: linkAddress) 
		    ifTrue: [^self << '<img src="' << linkAddress << '">']
		    ifFalse: 
			[^self << '<img src="' << '/' << self wiki filesPath << '/' << linkAddress 
			    << '">']].
	(wiki hasPageTitled: linkAddress) 
	    ifTrue: 
		["simple one piece existing link"

		currentTitle := self wiki currentTitleOf: linkAddress.
		self linkTo: 
			[self
			    << self wiki;
			    << $/;
			    nextPutUrl: currentTitle]
		    titled: [self << currentTitle]]
	    ifFalse: 
		["simple one piece non existant link"

		self << '<U>' << linkAddress << '</U>'.
		self linkTo: 
			[self
			    << self wiki;
			    << '/CREATE/';
			    nextPutUrl: linkAddress]
		    titled: [self << $?]]
    ]

    emitLink: linkName to: linkAddress [
	<category: 'parsing'>
	| currentTitle |
	(wiki hasPageTitled: linkAddress) 
	    ifTrue: 
		["two piece existing link"

		currentTitle := self wiki currentTitleOf: linkAddress.
		self linkTo: 
			[self
			    << self wiki;
			    << $/;
			    nextPutUrl: currentTitle]
		    titled: [self << linkName]]
	    ifFalse: 
		["two piece non existant link"

		self << '<U>' << linkName << '</U>'.
		self linkTo: 
			[self
			    << self wiki;
			    << '/CREATE/';
			    nextPutUrl: linkAddress]
		    titled: [self << $?]]
    ]

    sendBody [
	<category: 'HTML'>
	self emitStart.
	self emitIcons.
	self emitTitle.
	self emitContents.
	self emitSearch: ''.
	self emitFinish
    ]

    emitCommand: commandName text: textString [
	<category: 'HTML'>
	^self 
	    emitIcon: 
		[self << self wiki filesPath << $/ << commandName asLowercase << '.jpg']
	    linkTo: [self emitUrlForCommand: commandName]
	    titled: [self << textString]
    ]

    emitIcons [
	<category: 'HTML'>
	self emitIconsStart.
	self emitCommonIcons.
	self emitCommand: 'EDIT' text: 'Edit this page'.
	self emitCommand: 'RENAME' text: 'Rename this page'.
	self emitCommand: 'HISTORY' text: 'History of this page'.
	self emitIconsEnd
    ]

    emitContents [
	<category: 'HTML'>
	contentStream := self page contents readStream.
	[contentStream atEnd] whileFalse: [self processNextChar].
	lastChar == Character nl ifFalse: [self processNl].
	contentStream := nil
    ]

    emitTitle [
	<category: 'HTML'>
	self heading: 
		[self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self page title]]
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	heading := nil.
	inBullets := inNumbers := inTable := false
    ]
]



WikiHTML subclass: WikiAbsentPageHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    browserTitle [
	<category: 'accessing'>
	^self wikiName , ': `' , self pageTitle , ''' not found'
    ]

    pageTitle [
	<category: 'accessing'>
	^request location last
    ]

    sendResponseType [
	<category: 'accessing'>
	self
	    << 'HTTP/1.1 404 Not Found';
	    nl
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self heading: 
		[self << self wikiName << ' contains no page titled: "' 
		    << request location last]
	    level: 2.
	self emitSearch: request location last.
	self emitFinish
    ]
]



WikiHTML subclass: WikiReferencesHTML [
    | referringPages |
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    actualSearchString [
	<category: 'private'>
	^self searchString isEmpty 
	    ifTrue: [self searchString]
	    ifFalse: ['*' , self searchString , '*']
    ]

    findMatches [
	<category: 'private'>
	| match |
	referringPages := SortedCollection sortBlock: [:a :b | a title < b title].
	match := self actualSearchString.
	Processor activeProcess lowerPriority.
	wiki 
	    pagesDo: [:each | (each references: match) ifTrue: [referringPages add: each]].
	Processor activeProcess raisePriority
    ]

    browserTitle [
	<category: 'accessing'>
	| ws |
	ws := String new writeStream.
	ws
	    nextPutAll: 'SEARCH ';
	    nextPutAll: self wikiName;
	    nextPutAll: ':"';
	    nextPutAll: self searchString;
	    nextPut: $".
	^ws contents
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitMatchList.
	self emitSearch: self searchString.
	self emitFinish
    ]

    emitMatchList [
	<category: 'accessing'>
	self findMatches.
	referringPages isEmpty ifTrue: [^self emitNoMatches].
	self heading: 
		[self 
		    << ('There %<is|are>2 %1 reference%<|s>2 to the phrase:' % 
				{referringPages size.
				referringPages size = 1})].
	self
	    << '<I>  ...';
	    << self searchString;
	    << '...</I>';
	    lineBreak.
	self
	    << '<UL>';
	    nl.
	referringPages do: [:each | self listItem: [self linkToPage: each]].
	self
	    << '</UL>';
	    nl
    ]

    emitNoMatches [
	<category: 'accessing'>
	self
	    << '<H1>No references to the phrase</H1>';
	    nl.
	self
	    << '<I>    ...';
	    << self searchString;
	    << '...</I>';
	    lineBreak
    ]

    searchString [
	<category: 'accessing'>
	^request postDataAt: #SEARCHPATTERN ifAbsent: [request location last]
    ]
]



WikiPageHTML subclass: WikiVersionHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    page [
	<category: 'accessing'>
	^super page versionAt: self versionNumber
    ]

    emitIcons [
	<category: 'accessing'>
	self emitIconsStart.
	self emitCommonIcons.
	self emitCommand: 'HISTORY' text: 'History of this page'.
	self emitPreviousVersion.
	self emitNextVersion.
	self emitIconsEnd
    ]

    emitNextVersion [
	<category: 'accessing'>
	self versionNumber < (wiki pageTitled: self page title) versionNumber 
	    ifFalse: [^self].
	self 
	    emitIcon: [self << self wiki filesPath << '/next.jpg']
	    linkTo: [self emitUrlForVersionNumber: self versionNumber + 1]
	    titled: [self << 'Previous']
    ]

    emitPreviousVersion [
	<category: 'accessing'>
	self versionNumber <= 0 ifTrue: [^self].
	self 
	    emitIcon: [self << self wiki filesPath << '/prev.jpg']
	    linkTo: [self emitUrlForVersionNumber: self versionNumber - 1]
	    titled: [self << 'Previous']
    ]

    emitTitle [
	<category: 'accessing'>
	self heading: 
		[self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self page title].
		self << ' (Version ' << self versionNumber << ')']
    ]

    versionNumber [
	<category: 'accessing'>
	^((request postDataAt: #n) asNumber max: 0) min: super page versionNumber
    ]

    emitUrlForVersionNumber: aNumber [
	<category: 'html'>
	self << self wiki << '/VERSION/' << self encodedPageTitle << '?n=' 
	    << aNumber
    ]
]



WikiHTML subclass: WikiChangesHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    numberOfChanges [
	<category: 'accessing'>
	^20
    ]

    numberOfDays [
	<category: 'accessing'>
	^7
    ]

    pageTitle [
	<category: 'accessing'>
	^'Recent Changes'
    ]

    sendBody [
	<category: 'accessing'>
	| day genesis minDate changesShown |
	self emitStart.
	self emitIcons.
	self emitChanges.
	self emitSearch: ''.
	self emitFinish
    ]

    emitChangedPage: aPage [
	<category: 'accessing'>
	self listItem: 
		[self
		    linkToPage: aPage;
		    space.
		self << aPage timestamp asTime << ' (' << aPage author << ')']
    ]

    emitChanges [
	<category: 'accessing'>
	| day genesis minDate changesShown |
	self heading: [self << 'Recent Changes'].
	genesis := wiki startDate printNl.
	day := Date today.
	minDate := (day subtractDays: self numberOfDays) printNl.
	changesShown := 0.
	
	[day < genesis ifTrue: [^self].
	day >= minDate or: [changesShown < self numberOfChanges]] 
		whileTrue: 
		    [changesShown := changesShown + (self emitChangesFor: day).
		    day := day subtractDays: 1]
    ]

    emitChangesFor: aDate [
	<category: 'accessing'>
	| sc |
	sc := SortedCollection new 
		    sortBlock: [:a :b | a timestamp > b timestamp] wiki
		    pagesDo: [:each | each timestamp asDate = aDate ifTrue: [sc add: each]].
	sc isEmpty 
	    ifFalse: 
		[self heading: 
			[(self responseStream)
			    nextPutAll: aDate monthName;
			    space;
			    print: aDate day;
			    space;
			    print: aDate year]
		    level: 3.
		self
		    << '<UL>';
		    nl.
		sc do: [:each | self emitChangedPage: each].
		self
		    << '</UL>';
		    nl].
	^sc size
    ]
]



WikiHTML subclass: WikiErrorHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    browserTitle [
	<category: 'accessing'>
	^self pageTitle
    ]

    emitDescription [
	<category: 'accessing'>
	self
	    << 'The ';
	    << self wiki;
	    << ' wiki is not able to process this request. '.
	self 
	    << 'This can be due to a malformed URL, or (less likely) to an internal server error'.
	self
	    lineBreak;
	    lineBreak.
	self
	    << 'originator: ';
	    << request originator displayString;
	    lineBreak.
	self
	    << 'action: ';
	    << request action displayString;
	    lineBreak.
	self << 'location: '.
	request location do: [:each | self << $/ << each].
	self lineBreak.
	request enumeratePostData: 
		[:key :val | 
		self
		    lineBreak;
		    << key;
		    << ' = ';
		    nl;
		    << val;
		    nl].
	self
	    lineBreak;
	    horizontalLine;
	    italic: [self << WebServer version]
    ]

    pageTitle [
	<category: 'accessing'>
	^'Bad request'
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitDescription.
	self emitFinish
    ]
]



WikiHTML subclass: WikiRenameConflictHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    newTitle [
	<category: 'accessing'>
	^request postDataAt: #NEWTITLE
    ]

    emitDescription [
	<category: 'accessing'>
	self heading: 
		[self << 'This name ('.
		self linkTo: [self << self wiki << $/ << self newTitle]
		    titled: [self << self newTitle].
		self << ') is in use already. Sorry, cannot complete this rename.']
	    level: 2
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitDescription.
	self emitSearch: self newTitle.
	self emitFinish
    ]
]



WikiHTML subclass: WikiCommandHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    browserTitle [
	<category: 'accessing'>
	^super browserTitle , self titleSuffix
    ]

    titleSuffix [
	<category: 'accessing'>
	^self subclassResponsibility
    ]
]



WikiCommandHTML subclass: WikiEditHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    titleSuffix [
	<category: 'accessing'>
	^' (edit)'
    ]

    emitForm [
	<category: 'HTML'>
	self heading: 
		[self << 'Edit '.
		self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self pageTitle]].
	self
	    << 'Don''t know how to edit a page? Visit ';
	    linkToPage: wiki syntaxPage;
	    << '.';
	    nl.
	self
	    << '<FORM ACTION="';
	    emitUrlOfPage;
	    << '" METHOD=POST>';
	    nl.
	self
	    << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="EDIT">';
	    nl.
	self
	    << '<TEXTAREA NAME="NEWCONTENTS"  WRAP=VIRTUAL COLS=80 ROWS=20>';
	    nl.
	self
	    << self page contents;
	    nl.
	self
	    << '</TEXTAREA>';
	    lineBreak.
	self
	    << '<INPUT TYPE="submit" VALUE="Save">';
	    nl.
	self
	    << '</FORM>';
	    nl
    ]

    sendBody [
	<category: 'HTML'>
	self emitStart.
	self emitIcons.
	self emitForm.
	self emitFinish
    ]
]



WikiCommandHTML subclass: WikiHistoryHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    sendBody [
	<category: 'HTML'>
	self emitStart.
	self emitIcons.
	self emitTitle.
	self emitTable.
	self emitSearch: ''.
	self emitFinish
    ]

    emitTitle [
	<category: 'HTML'>
	self heading: 
		[self << 'History of '.
		self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self page title]]
    ]

    emitTable [
	<category: 'HTML'>
	self
	    << '<TABLE WIDTH="95%" BORDER="1">';
	    nl.
	self
	    << '<TR>';
	    nl.
	self
	    td: [self << '<B>Version</B>'];
	    td: [self << '<B>Operation</B>'];
	    td: [self << '<B>Author</B>'];
	    td: [self << '<B>Creation Time</B>'].
	self
	    << '</TR>';
	    nl.
	self page versionsDo: [:each | self emitPageVersion: each].
	self
	    << '</TABLE>';
	    nl
    ]

    emitPageVersion: each [
	<category: 'HTML'>
	self
	    << '<TR>';
	    nl.
	self td: 
		[self linkTo: 
			[self
			    << self wiki;
			    << '/VERSION/';
			    nextPutUrl: each title;
			    << '?n=';
			    << each versionNumber]
		    titled: [self << each versionNumber]].
	self td: [self << each operationSynopsis].
	self td: [self << each author].
	self td: [self sendTimestamp: each timestamp].
	self
	    << '</TR>';
	    nl
    ]

    titleSuffix [
	<category: 'accessing'>
	^' (history)'
    ]
]



WikiCommandHTML subclass: WikiRenameHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    titleSuffix [
	<category: 'accessing'>
	^' (rename)'
    ]

    emitForm [
	<category: 'accessing'>
	self heading: 
		[self << 'Rename'.
		self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self pageTitle]].
	self
	    << '<FORM ACTION="';
	    emitUrlOfPage;
	    << '" METHOD=POST>';
	    nl.
	self
	    << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="RENAME">';
	    nl.
	self
	    << '<INPUT TYPE= "TEXT" NAME="NEWTITLE" SIZE=80 VALUE="';
	    << self pageTitle;
	    << '">';
	    lineBreak.
	self
	    << '<INPUT TYPE="submit" VALUE="Save">';
	    nl.
	self
	    << '</FORM>';
	    nl
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitForm.
	self emitFinish
    ]
]



Object subclass: WikiPersistanceManager [
    | wiki |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    wiki [
	<category: 'accessing'>
	^wiki
    ]

    wiki: aWiki [
	<category: 'accessing'>
	wiki := aWiki.
	self reset
    ]

    allPagesDo: aBlock [
	<category: 'accessing'>
	wiki allPagesDo: aBlock
    ]

    addPage: aPage [
	<category: 'persistance'>
	
    ]

    load [
	<category: 'persistance'>
	self subclassResponsibility
    ]

    save [
	<category: 'persistance'>
	self subclassResponsibility
    ]
]



WikiPersistanceManager subclass: FlatFileWiki [
    | directory fileCounter idMap |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    FlatFileWiki class >> directory: aDirectory [
	<category: 'instance creation'>
	^self new directory: aDirectory
    ]

    reset [
	<category: 'initialize'>
	directory exists ifFalse: [Directory create: directory name].
	idMap := IdentityDictionary new.
	fileCounter := -1
    ]

    idForPage: aPage [
	<category: 'private-persistance'>
	^idMap at: aPage ifAbsentPut: [self savePage: aPage]
    ]

    indexIn: aFilename [
	<category: 'private-persistance'>
	| tail |
	tail := aFilename stripPath.
	^(tail copyFrom: 1 to: tail size - 4) asNumber
    ]

    nextFileCounter [
	<category: 'private-persistance'>
	^fileCounter := fileCounter + 1
    ]

    loadPage: id [
	<category: 'private-persistance'>
	^self loadPageInFile: (directory at: id , '.pag')
    ]

    loadPageInFile: aFilename [
	<category: 'private-persistance'>
	| index rs page |
	index := self indexIn: aFilename.
	^idMap at: index
	    ifAbsentPut: 
		[| type |
		Transcript show: '.'.
		rs := aFilename readStream.
		type := rs nextLine asSymbol.
		
		[page := (Smalltalk at: type) new.
		page loadFromFile: rs under: self] 
			ensure: [rs close].
		page]
    ]

    loadPages [
	<category: 'private-persistance'>
	| latestVersions pageMap |
	idMap := pageMap := IdentityDictionary new.
	directory filesMatching: '*.pag' do: [:fn | self loadPageInFile: fn].
	idMap := IdentityDictionary new.
	pageMap keysAndValuesDo: [:i :page | idMap at: page put: i].
	latestVersions := pageMap asSet.
	pageMap do: 
		[:page | 
		"Remove all versions older than `each' from latest"

		page 
		    versionsDo: [:each | each == page ifFalse: [latestVersions remove: each ifAbsent: []]]].
	latestVersions do: [:page | self wiki addPage: page]
    ]

    load [
	<category: 'private-persistance'>
	| rs fn |
	self reset.
	(fn := directory at: 'wiki.conf') exists 
	    ifFalse: [self error: 'wiki directory doesn''t exist'].
	rs := fn readStream.
	
	[| type |
	type := rs nextLine asSymbol.
	self wiki: (Smalltalk at: type) new.
	self wiki loadFromFile: rs] 
		ensure: [rs close].
	self loadPages.
	self wiki persistanceManager: self.
	^self wiki
    ]

    savePage: aPage [
	<category: 'private-persistance'>
	| id ws |
	id := self nextFileCounter.
	idMap at: aPage put: id.
	ws := (self directory at: id printString , '.pag') writeStream.
	
	[ws
	    nextPutAll: aPage class name;
	    nl.
	aPage saveToFile: ws under: self] 
		ensure: [ws close].
	^id
    ]

    savePages [
	<category: 'private-persistance'>
	self allPagesDo: [:aPage | self savePage: aPage]
    ]

    save [
	<category: 'private-persistance'>
	| ws |
	self reset.
	directory exists ifFalse: [Directory create: directory name].
	ws := (directory at: 'wiki.conf') writeStream.
	
	[ws
	    nextPutAll: wiki class name;
	    nl.
	wiki saveToFile: ws] 
		ensure: [ws close].
	self savePages
    ]

    directory [
	<category: 'accessing'>
	^directory
    ]

    directory: aFilename [
	<category: 'accessing'>
	directory := File name: aFilename
    ]

    addPage: aPage [
	<category: 'pages'>
	self idForPage: aPage.
	^self
    ]
]



WebServer class extend [

    wikiDirectories [
	<category: 'examples'>
	^#('GnuSmalltalkWiki')
    ]

    initializeImages [
	<category: 'examples'>
	(self at: 8080) handler addComponent:
	    (FileWebServer
		named: 'images'
		directory: (Directory kernel / '../WebServer.star') zip)
    ]

    initializeWiki [
	"Only run this method the first time."

	"WikiServer initializeNormalWiki"

	<category: 'examples'>
	self initializeImages.
	self wikiDirectories do: 
		[:eachName | 
		"Only run this method the first time."

		| wiki |
		wiki := Wiki new.
		wiki persistanceManager: (FlatFileWiki directory: eachName).
		wiki name: eachName.
		wiki rootPageTitle: 'Home Page'.
		wiki syntaxPageTitle: 'Wiki Syntax'.
		wiki filesPath: '/images'.
		wiki save.
		(self at: 8080) handler addComponent: wiki].
	(self at: 8080) start
    ]

    initializeWikiNoImages [
	"Only run this method the first time."

	"WikiServer initializeWikiNoImages"

	<category: 'examples'>
	self wikiDirectories do: 
		[:eachName | 
		"Only run this method the first time."

		| wiki |
		wiki := Wiki new.
		wiki persistanceManager: (FlatFileWiki directory: eachName).
		wiki name: eachName.
		wiki rootPageTitle: 'Home Page'.
		wiki syntaxPageTitle: 'Wiki Syntax'.
		wiki save.
		(self at: 8080) handler addComponent: wiki].
	(self at: 8080) start
    ]

    restartWiki [
	"WikiServer restartWiki"

	<category: 'examples'>
	self initializeImages.
	self wikiDirectories do: 
		[:eachName | 
		(self at: 8080) handler 
		    addComponent: (FlatFileWiki directory: eachName) load].
	(self at: 8080) start
    ]

    restartWikiNoImages [
	"WikiServer restartWikiNoImages"

	<category: 'examples'>
	self wikiDirectories do: 
		[:eachName | 
		(self at: 8080) handler 
		    addComponent: (((FlatFileWiki directory: eachName) load)
			    filesPath: nil;
			    yourself)].
	(self at: 8080) start
    ]

]



Eval [
    WikiPageHTML initialize
]

