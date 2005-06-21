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

Object subclass: #WikiPage
    instanceVariableNames: 'author timestamp '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

WikiPage subclass: #OriginalWikiPage
    instanceVariableNames: 'title '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

WikiPage subclass: #ChangedWikiPage
    instanceVariableNames: 'previousVersion '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

ChangedWikiPage subclass: #EditedWikiPage
    instanceVariableNames: 'contents '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

ChangedWikiPage subclass: #RenamedWikiPage
    instanceVariableNames: 'title '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

Object subclass: #WikiSettings
    instanceVariableNames: 'dictionary '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

Servlet subclass: #Wiki
    instanceVariableNames: 'settings pages rootPageTitle syntaxPageTitle fileServer persistanceManager'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

Wiki subclass: #ProtectedWiki
    instanceVariableNames: 'authorizer'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

ProtectedWiki subclass: #ReadOnlyWiki
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

ProtectedWiki subclass: #PasswordWiki
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

WebResponse subclass: #WikiHTML
    instanceVariableNames: 'wiki page '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiPageHTML
    instanceVariableNames: 'contentStream currentChar lastChar inBullets inNumbers heading inTable '
    classVariableNames: 'ParseTable'
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiAbsentPageHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiReferencesHTML
    instanceVariableNames: 'referringPages '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiPageHTML subclass: #WikiVersionHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiChangesHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiErrorHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiRenameConflictHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiHTML subclass: #WikiCommandHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiCommandHTML subclass: #WikiEditHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiCommandHTML subclass: #WikiHistoryHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

WikiCommandHTML subclass: #WikiRenameHTML
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-WikiRendering'!

Object subclass: #WikiPersistanceManager
    instanceVariableNames: 'wiki '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

WikiPersistanceManager subclass: #FlatFileWiki
    instanceVariableNames: 'directory fileCounter idMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Web-Wiki'!

WikiHTML comment:
'WikiHTML is an object that can convert a WikiPage to HTML.  There are
different subclasses of WikiHTML for the various ways a page can be rendered,
such as when it is edited or renamed.

All subclasses must implement sendBody.'!

Wiki comment:
'A Wiki is made up of four kinds of classes; Wiki, WikiPersistanceManager,
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
can have a custom contents or can be renamed.'!

!WikiPage methodsFor: 'accessing'!

allTitles
    | oc |
    oc := OrderedCollection new.
    self allTitlesInto: oc.
    ^oc!

allTitlesInto: aCollection
    self subclassResponsibility!

author
    ^author!

contents
    ^self subclassResponsibility!

references: aString
    ^(aString match: self contents) or: [aString match: self title]!

operationSynopsis
    ^self subclassResponsibility!

timestamp
    ^timestamp!

title
    ^self subclassResponsibility!

versionAt: aNumber
    self versionsDo: [:each | each versionNumber = aNumber ifTrue: [^each]].
    ^self subscriptBoundsError: aNumber!

versionNumber
    self subclassResponsibility!

versionsDo: aBlock
    self subclassResponsibility!

versionsReverseDo: aBlock
    self subclassResponsibility! !

!WikiPage methodsFor: 'displaying'!

printOn: aStream
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
	nextPut: $}! !

!WikiPage methodsFor: 'editing'!

changeTitle: aTitle by: anAuthor
    | newGuy |
    aTitle = self title ifTrue: [^self].
    newGuy := RenamedWikiPage newVersionOf: self by: anAuthor.
    newGuy title: aTitle.
    ^newGuy!

newContents: aContents by: anAuthor
    | newGuy |
    aContents = self contents ifTrue: [^self].
    newGuy := EditedWikiPage newVersionOf: self by: anAuthor.
    newGuy contents: aContents.
    ^newGuy! !

!WikiPage methodsFor: 'initialize'!

author: anObject
    author := anObject!

initialize
    timestamp := DateTime now.
    author := ''! !

!WikiPage methodsFor: 'flat file'!

saveToFile: aFileStream under: aWikiPM
    aFileStream nextPutAll: author; nl.
    aFileStream print: timestamp asSeconds; nl.
    ^self!

loadFromFile: rs under: aWikiPM
    | timestamp author seconds |
    author := rs nextLine.
    seconds := rs nextLine asNumber.
    timestamp := (Date year: 1901 day: 1 hour: 0 minute: 0 second: 0)
	+ (Duration seconds: seconds).

    self author: author; timestamp: timestamp!

timestamp: value
    timestamp := value! !

!WikiPage class methodsFor: 'instance creation'!

newVersionOf: aWikiPage by: anAuthor
    ^self new
	previousVersion: aWikiPage;
	author: anAuthor;
	yourself!

new
    ^super new initialize! !

!OriginalWikiPage methodsFor: 'accessing'!

allTitlesInto: aCollection
    aCollection add: title!

contents
    ^'Describe ' , title , ' here...'!

operationSynopsis
    ^'Created'!

title
    ^title!

title: aString
    title := aString!

versionNumber
    ^0!

versionsDo: aBlock
    aBlock value: self!

versionsReverseDo: aBlock
    aBlock value: self! !

!OriginalWikiPage methodsFor: 'flat file'!

saveToFile: aFileStream under: aWikiPM
    super saveToFile: aFileStream under: aWikiPM.
    aFileStream nextPutAll: title.
    ^self!

loadFromFile: rs under: aWikiPM
    super loadFromFile: rs under: aWikiPM.
    self title: rs upToEnd! !

!ChangedWikiPage methodsFor: 'accessing'!

allTitlesInto: aCollection
    previousVersion allTitlesInto: aCollection!

contents
    ^previousVersion contents!

previousVersion
    ^previousVersion!

previousVersion: anObject
    previousVersion := anObject!

title
    ^previousVersion title!

versionNumber
    ^previousVersion versionNumber + 1!

versionsDo: aBlock
    aBlock value: self.
    previousVersion versionsDo: aBlock!

versionsReverseDo: aBlock
    previousVersion versionsReverseDo: aBlock.
    aBlock value: self! !

!ChangedWikiPage methodsFor: 'flat file'!

saveToFile: aFileStream under: aWikiPM
    super saveToFile: aFileStream under: aWikiPM.
    aFileStream print: (aWikiPM idForPage: self previousVersion); nl.
    ^self!

loadFromFile: rs under: aWikiPM
    | id |
    super loadFromFile: rs under: aWikiPM.
    id := rs nextLine.
    self previousVersion: (aWikiPM loadPage: id)! !

!EditedWikiPage methodsFor: 'accessing'!

contents
    ^contents!

contents: aString
    "trim off trailing CRs"

    | index |
    index := aString size.
    [index > 1 and: [(aString at: index) = Character nl]]
	whileTrue: [index := index - 1].
    contents := aString copyFrom: 1 to: index!

operationSynopsis
    ^'Edited'! !

!EditedWikiPage methodsFor: 'flat file'!

saveToFile: aFileStream under: aWikiPM
    super saveToFile: aFileStream under: aWikiPM.
    aFileStream nextPutAll: contents.
    ^self!

loadFromFile: rs under: aWikiPM
    super loadFromFile: rs under: aWikiPM.
    self contents: rs upToEnd! !

!RenamedWikiPage methodsFor: 'accessing'!

allTitlesInto: aCollection
    aCollection add: title.
    ^super allTitlesInto: aCollection!

operationSynopsis
    ^'Renamed'!

title
    ^title!

title: aString
    title := aString! !

!RenamedWikiPage methodsFor: 'flat file'!

saveToFile: aFileStream under: aWikiPM
    super saveToFile: aFileStream under: aWikiPM.
    aFileStream nextPutAll: title.
    ^self!

loadFromFile: rs under: aWikiPM
    super loadFromFile: rs under: aWikiPM.
    self title: rs upToEnd! !

!Wiki class methodsFor: 'instance creation'!

named: aString
    ^self new name: aString!

new
    ^super new initialize! !

!Wiki methodsFor: 'initialize'!

initialize
    pages := Dictionary new.
    settings := WikiSettings new.
    self name: 'Wiki'.
    self rootPageTitle: 'Duh Tawp'.
    self syntaxPageTitle: 'Duh Rools'! !

!Wiki methodsFor: 'interaction'!

redirectToRootPage: aRequest
    aRequest location addLast: self rootPageTitle, '.html'.
    "self sendPageFor: aRequest."

    ^(ErrorResponse movedTemporarilyTo:
	self printString, '/', aRequest location last)
	respondTo: aRequest!

removeHTMLFrom: pageTitle
    pageTitle size > 5 ifFalse: [ ^pageTitle ].

    ^(pageTitle copyFrom: pageTitle size - 4 to: pageTitle size = '.html')
	ifTrue: [ pageTitle copyFrom: 1 to: pageTitle size - 5 ]
	ifFalse: [ pageTitle ]!

sendPageFor: aRequest
    | pageTitle |
    pageTitle := self removeHTMLFrom: aRequest location last.
    ^(self hasPageTitled: pageTitle)
	ifTrue: [WikiPageHTML respondTo: aRequest in: self]
	ifFalse: [WikiAbsentPageHTML respondTo: aRequest in: self]!

replyToGetRequest: aRequest
    | rClass size |
    size := aRequest location size - self depth + 1.

    size < 2 ifTrue: [
	size = 0 ifTrue: [ ^self redirectToRootPage: aRequest ].
	^(aRequest location last sameAs: 'RECENT CHANGES')
	    ifTrue: [ WikiChangesHTML respondTo: aRequest in: self]
	    ifFalse: [ self sendPageFor: aRequest ]
    ].

    rClass := size = 2
	ifTrue: [ self classForCommand: aRequest ]
	ifFalse: [ WikiErrorHTML ].

    ^rClass respondTo: aRequest in: self!

classForCommand: aRequest
    | cmd page |
    cmd := aRequest location at: self depth.
    page := aRequest location last.

    (cmd sameAs: 'CREATE') ifTrue: [
	self createPageFor: aRequest.
	^WikiEditHTML
    ].
    (self hasPageTitled: page)	ifFalse: [^WikiAbsentPageHTML].
    (cmd sameAs: 'EDIT')	ifTrue:  [^WikiEditHTML].
    (cmd sameAs: 'HISTORY')	ifTrue:  [^WikiHistoryHTML].
    (cmd sameAs: 'RENAME')	ifTrue:  [^WikiRenameHTML].
    (cmd sameAs: 'REFS')	ifTrue:  [^WikiReferencesHTML].
    (cmd sameAs: 'VERSION')	ifTrue:  [^WikiVersionHTML].
    ^WikiErrorHTML!

replyToPostEditRequest: aRequest
    | newPage currentPage newContents |
    currentPage := self pageTitled: aRequest location last.
    newContents := aRequest postDataAt: #NEWCONTENTS.
    newPage := currentPage newContents: newContents by: aRequest originator.
    self addPage: newPage.
    self sendPageFor: aRequest!

replyToPostRenameRequest: aRequest
    | currentPage newTitle newPage |
    currentPage := self pageTitled: aRequest location last.
    newTitle := aRequest postDataAt: #NEWTITLE.
    ((self hasPageTitled: newTitle)
	and: [(self pageTitled: newTitle)
		~= currentPage])
	ifTrue: [^WikiRenameConflictHTML respondTo: aRequest in: self].
    newPage := currentPage changeTitle: newTitle by: aRequest originator.
    self addPage: newPage.
    self sendPageFor: aRequest!

replyToPostRequest: aRequest
    | cmd |
    cmd := aRequest postDataAt: #COMMAND.
    (cmd sameAs: 'EDIT') ifTrue: [^self replyToPostEditRequest: aRequest].
    (cmd sameAs: 'RENAME') ifTrue: [^self replyToPostRenameRequest: aRequest].
    (cmd sameAs: 'SEARCH') ifTrue: [^self replyToPostSearchRequest: aRequest].
    self replyToUnknownRequest: aRequest!

replyToPostSearchRequest: aRequest
    ^WikiReferencesHTML respondTo: aRequest in: self!

replyToUnknownRequest: aRequest
    ^WikiErrorHTML respondTo: aRequest in: self!

respondTo: aRequest
    (aRequest action sameAs: 'HEAD')
	ifTrue: [^self replyToGetRequest: aRequest].
    (aRequest action sameAs: 'GET')
	ifTrue: [^self replyToGetRequest: aRequest].
    (aRequest action sameAs: 'POST')
	ifTrue: [^self replyToPostRequest: aRequest].
    ^(ErrorResponse acceptableMethods: #('HEAD' 'GET' 'POST'))
	respondTo: aRequest!

!Wiki methodsFor: 'accessing'!

syntaxPageTitle
    ^(self pageTitled: syntaxPageTitle) title!

syntaxPageTitle: aString
    syntaxPageTitle notNil
	ifTrue: [pages removeKey: syntaxPageTitle asUppercase].
    syntaxPageTitle := aString.
    self addPage: self newSyntaxPage!

filesPath
    ^fileServer isNil ifTrue: [ nil ] ifFalse: [ fileServer printString ]!

filesPath: aString
    | path |
    aString isNil ifTrue: [ ^self fileServer: nil ].

    path := (aString at: 1) == $/
	ifTrue: [ WebServer current handler ]
	ifFalse: [ self parent ].

    (aString substrings: $/) do: [ :each |
	each isEmpty ifFalse: [ path := path componentNamed: each ]
    ].
    self fileServer: path!

fileServer
    ^fileServer!

fileServer: aString
    fileServer := aString!

name
    ^name!

name: aString
    name := aString!

persistanceManager: aWikiPersistanceManager
    persistanceManager := aWikiPersistanceManager.
    aWikiPersistanceManager wiki: self!

rootPageTitle
    ^(self pageTitled: rootPageTitle) title!

rootPageTitle: aString
    rootPageTitle notNil ifTrue: [pages removeKey: rootPageTitle asUppercase].
    rootPageTitle := aString.
    self addPage: (OriginalWikiPage new title: rootPageTitle)!

save
    persistanceManager save!

settings
    ^settings!

startDate
    ^((self pageTitled: self rootPageTitle)
	versionAt: 0) timestamp! !

!Wiki methodsFor: 'flat file'!

loadFromFile: aFileStream
    | path |
    settings loadFromFile: aFileStream.
    self name: aFileStream nextLine.
    self rootPageTitle: aFileStream nextLine.
    self syntaxPageTitle: aFileStream nextLine.
    path := aFileStream nextLine.
    path = '<none>' ifTrue: [ path := nil ].
    self filesPath: path.
    ^self!

saveToFile: ws
    settings saveToFile: ws.
    ws nextPutAll: self name; nl.
    ws nextPutAll: self rootPageTitle; nl.
    ws nextPutAll: self syntaxPageTitle; nl.
    self filesPath isNil
	ifTrue: [ ws nextPutAll: '<none>'; nl ]
	ifFalse: [ ws nextPutAll: self filesPath; nl ].
    ^self! !

!Wiki methodsFor: 'pages'!

addPage: aPage
    aPage allTitles do: [:each | pages at: each asUppercase put: aPage].
    persistanceManager isNil ifFalse: [ persistanceManager addPage: aPage ]!

currentPageTitleFor: aString
    ^(aString sameAs: 'Changes')
	ifTrue: ['Recent Changes']
	ifFalse: [(pages at: aString asUppercase) title]!

currentTitleOf: aString
    ^(aString sameAs: 'RECENT CHANGES')
	ifTrue: [aString]
	ifFalse: [(self pageTitled: aString) title]!

syntaxPage
    ^self pageTitled: syntaxPageTitle!

hasPageTitled: aString
    ^(pages includesKey: aString asUppercase)
	or: [aString sameAs: 'RECENT CHANGES']!

allPagesDo: aBlock
    pages do: aBlock!

pagesDo: aBlock
    "when enumerating the pages dictionary, we want to filter to only those entries whose titles are current, this avoids double enumerating a page that might have two or more titles in it's history"

    pages
	keysAndValuesDo: [:title :page | (page title sameAs: title) ifTrue: [aBlock value: page]]!

pageTitled: aString
    ^pages at: aString asUppercase! !

!Wiki methodsFor: 'private'!

createPageFor: aRequest
    (self hasPageTitled: aRequest location last)
	ifFalse:
	    [self addPage: ((OriginalWikiPage new)
			author: aRequest originator;
			title: aRequest location last;
			yourself)]!

newSyntaxPage
    ^(OriginalWikiPage new title: syntaxPageTitle)
	newContents: self newSyntaxPageContents
	by: ''!

newSyntaxPageContents			
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
' !

!PasswordWiki methodsFor: 'authentication'!

authorizer
    ^authorizer!

authorizer: aWebAuthorizer
    authorizer := aWebAuthorizer.
    self fileServer isNil
	ifFalse: [ self fileServer uploadAuthorizer: aWebAuthorizer ].
!

loginID: aLoginID password: aPassword
    self authorizer: (WebAuthorizer loginID: aLoginID password: aPassword)! !

!PasswordWiki methodsFor: 'flat file'!

loadFromFile: aFileStream
    super loadFromFile: aFileStream.
    self authorizer: (WebAuthorizer fromString: aFileStream nextLine).
    ^self!

saveToFile: ws
    super saveToFile: ws.
    ws nextPutAll: self authorizer authorizer; nl.
    ^self! !

!ProtectedWiki methodsFor: 'authentication'!

replyToRequest: aRequest
    self authorizer
	authorize: aRequest
	in: self
	ifAuthorized: [ super replyToRequest: aRequest ]! !

!ReadOnlyWiki methodsFor: 'authentication'!

replyToPostEditRequest: aRequest
    self authorizer
	authorize: aRequest
	in: self
	ifAuthorized: [ super replyToPostEditRequest: aRequest ]!

replyToPostRenameRequest: aRequest
    self authorizer
	authorize: aRequest
	in: self
	ifAuthorized: [ super replyToPostRenameRequest: aRequest ]! !

!WikiSettings methodsFor: 'flat file'!

loadFromFile: aFileStream
    | line |
    [ (line := aFileStream nextLine) isEmpty ] whileFalse: [
	line := line substrings: $=.
	line size = 2
	    ifTrue: [ self at: (line at: 1) put: (line at: 2) ]
	    ifFalse: [ self at: (line at: 1) put: true ]
    ]!

saveToFile: ws
    | line |
    self settingsDo: [ :key :value |
	value == false ifFalse: [
	    line := key.
	    value == true ifFalse: [ line := line, '=', 'value' ].
	    ws nextPutAll: line; nl
	].
    ].
    ws nl! !

!WikiSettings methodsFor: 'private'!

initialize
    dictionary := Dictionary new!

at: name put: value
    ^dictionary at: name put: value!

at: name default: default
    ^dictionary at: name ifAbsentPut: [default]! !

!WikiSettings methodsFor: 'settings'!

backgroundColor
    ^self at: 'bc' default: '#ffffff'!

backgroundColor: anObject
    self at: 'bc' put: anObject!

linkColor
    ^self at: 'lc' default: '#0000ff'!

linkColor: anObject
    self at: 'lc' put: anObject!

tableBackgroundColor
    ^self at: 'tbc' default: '#ffe0ff'!

tableBackgroundColor: anObject
    self at: 'tbc' put: anObject!

textColor
    ^self at: 'tc' default: '#000000'!

textColor: anObject
    self at: 'tc' put: anObject!

visitedLinkColor
    ^self at: 'vlc' default: '#551a8b'!

visitedLinkColor: anObject
    self at: 'vlc' put: anObject! !

!WikiSettings class methodsFor: 'instance creation'!

cookieString: aString
    ^self new fromCookieString: aString!

new
    ^super new initialize! !

!WikiHTML methodsFor: 'initialize'!

initialize! !

!WikiHTML methodsFor: 'accessing'!

browserTitle
    ^self wikiName , ': ' , self pageTitle!

encodedPageTitle
    ^(URL encode: self page title), '.html'!

settings
    ^wiki settings!

page
    page isNil ifTrue: [page := wiki pageTitled: request location last].
    ^page!

pageTitle
    ^self page title!

emitIcon: imageBlock linkTo: nameBlock titled: titleBlock
    self wiki filesPath isNil ifFalse: [
	^self image: imageBlock linkTo: nameBlock titled: titleBlock; nl
    ].
    self td: [ self linkTo: nameBlock titled: titleBlock ]
!

emitCommonIcons
    self
	emitIcon: [ self << self wiki filesPath << '/help.jpg' ]
	linkTo: [self << self wiki; << $/; nextPutUrl: self wiki syntaxPageTitle ]
	titled: [self << self wiki syntaxPageTitle];

	emitIcon: [ self << self wiki filesPath << '/recent.jpg' ]
	linkTo: [self << self wiki << '/RECENT+CHANGES' ]
	titled: [self << 'Recent changes'];

	emitIcon: [ self << self wiki filesPath << '/top.jpg' ]
	linkTo: [self << self wiki << $/]
	titled: [self << 'Back to Top']!

sendBody
    "subclasses will usually want to do more here"
    self emitStart.
    self emitIcons.
    self emitFinish!

emitFinish
    self nl; << '</FONT>'; nl; << '</BODY></HTML>'!

emitSearch: aString
    self horizontalLine.
    (self << '<FORM ACTION="' << wiki name) << '" METHOD=POST>'; nl.
    self << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="SEARCH">'; nl.
    (self << '<INPUT TYPE= "TEXT" NAME="SEARCHPATTERN" VALUE="' << aString) << '" SIZE=40>'; nl.

    self wiki filesPath isNil
	ifFalse: [
	    self
		<< '<INPUT TYPE="image" ALIGN="absmiddle" BORDER="0" SRC="'
		<< self wiki filesPath << '/find.jpg" ALT='
	]
	ifTrue: [ self << '<INPUT TYPE="submit" VALUE=' ].

    self << '"Find..."></FORM>'; nl!

emitStart
    (self << '<HTML><HEAD><TITLE>' << self browserTitle << '</TITLE></HEAD><BODY bgcolor='
	<< self settings backgroundColor << ' link=' << self settings linkColor
	<< ' vlink=' << self settings visitedLinkColor) << $>; nl.
    (self << '<FONT color=' << self settings textColor) << $>; nl!

emitIcons
    self
	emitIconsStart;
	emitCommonIcons;
	emitIconsEnd.!

emitIconsEnd
    self wiki filesPath isNil
	ifFalse: [ self << '<BR>'; nl ]
	ifTrue: [ self nl; << '</TR>'; nl; << '</TABLE>'; nl ]!

emitIconsStart
    self wiki filesPath isNil ifFalse: [
	^self
	    image: [ self << self wiki filesPath << '/head.jpg' ]
	    titled: [ self << self wiki ]
    ].
    self << '<TABLE width=100% bgcolor=' << self settings tableBackgroundColor.
    self << '><TR>'; nl!

emitUrlForCommand: commandName
    self << self wiki << $/ << commandName << $/ << self encodedPageTitle!

emitUrlOfPage
    self << self wiki << $/ << self encodedPageTitle!

linkToPage: aPage
    self linkTo: [self << self wiki; << $/; nextPutUrl: aPage title ]
	titled: [self << aPage title]!

wiki
    ^wiki!

wiki: anObject
    wiki := anObject!

wikiName
    ^wiki name! !


!WikiHTML class methodsFor: 'instance creation'!

new
    ^super new initialize!

respondTo: aRequest in: aWiki
    ^self new
	wiki: aWiki;
	respondTo: aRequest! !

!WikiPageHTML class methodsFor: 'initialize'!

initialize
    ParseTable := Array new: 256 withAll: #addCurrentChar.
    ParseTable at: 1 + Character cr asciiValue put: #processCr.
    ParseTable at: 1 + Character nl asciiValue put: #processNl.
    ParseTable at: 1 + $[	    asciiValue put: #processLeftBracket.
    ParseTable at: 1 + $.	    asciiValue put: #processDot.
    ParseTable at: 1 + $#	    asciiValue put: #processPound.
    ParseTable at: 1 + $-	    asciiValue put: #processDash.
    ParseTable at: 1 + $*	    asciiValue put: #processStar.
    ParseTable at: 1 + $|	    asciiValue put: #processPipe.
    ParseTable at: 1 + $<	    asciiValue put: #processLeftAngle! !

!WikiPageHTML methodsFor: 'private-HTML'!

isExternalAddress: linkAddress
    "Faster than #match:"
    ^#('http:' 'https:' 'mailto:' 'file:' 'ftp:' 'news:' 'gopher:' 'telnet:')
	anySatisfy: [:each |
	    each size < linkAddress size and: [ 
		(1 to: each size) allSatisfy: [ :index |
		    (each at: index) == (linkAddress at: index)
		]
	    ]
	]!

isImage: linkAddress
    "Faster than #match:"
    ^#('.gif' '.jpeg' '.jpg' '.jpe') 
	anySatisfy: [:each |
	    each size < linkAddress size and: [ 
		(1 to: each size) allSatisfy: [ :index |
		    (each at: index) == (linkAddress at: linkAddress size - each size + index)
		]
	    ]
	]!

linkAddressIn: aString
    | rs |
    rs := aString readStream.
    rs skipTo: $>.
    ^(rs atEnd ifTrue: [aString] ifFalse: [rs upToEnd]) trimSeparators!

linkNameIn: aString
    | rs |
    rs := aString readStream.
    ^(rs upTo: $>) trimSeparators! !

!WikiPageHTML methodsFor: 'parsing'!

addCurrentChar
    self responseStream nextPut: currentChar!

atLineStart
    ^lastChar == Character nl or: [lastChar == nil]!

closeBulletItem
    self << '</LI>'; nl.
    contentStream peek == $.
	ifFalse:
	    [inBullets := false.
	    self << '</UL>'; nl]!

closeHeading
    self << '</H' << heading << '>'; nl.
    heading := nil!

closeNumberItem
    self << '</LI>'; nl.
    contentStream peek == $#
	ifFalse:
	    [inNumbers := false.
	    self << '</OL>'; nl]!

closeTableRow
    | pos |
    self << '</TD></TR>'; nl.
    pos := contentStream position.
    (contentStream peekFor: $|) ifTrue: [
	(contentStream peekFor: $|) ifTrue: [
	    inTable := false.
	    self << '</TABLE>'; nl]].
    contentStream position: pos!

processNextChar
    lastChar := currentChar.
    currentChar := contentStream next.
    
    ^self perform: (ParseTable at: (currentChar asciiValue + 1))!

processDot
    self atLineStart ifFalse: [ ^self addCurrentChar].

    inBullets
	ifFalse:
	    [self << '<UL>'; nl.
	    inBullets := true].
    self << ' <LI>'!

processStar
    self atLineStart ifFalse: [ ^self addCurrentChar].

    heading := 2.
    [ contentStream peekFor: $* ] whileTrue: [ heading := heading + 1 ].
    self << '<H' << heading << '>'.
!

processCr
    contentStream peekFor: Character nl.
    currentChar := Character nl.
    self processNl!

processNl
    inBullets ifTrue: [^self closeBulletItem].
    inNumbers ifTrue: [^self closeNumberItem].
    inTable ifTrue: [^self closeTableRow].
    heading isNil ifFalse: [^self closeHeading].
    self lineBreak!

processDash
    self atLineStart ifFalse: [ ^self addCurrentChar].

    contentStream skipTo: Character nl.
    self horizontalLine.
    lastChar := Character nl!

processLeftAngle
    | s |
    s := String new writeStream.
    self addCurrentChar.
    [	currentChar := contentStream next.
	currentChar == $> or: [currentChar == $ ] ]
	whileFalse: [ s nextPut: currentChar ].

    self << (s := s contents) << currentChar.

    (s sameAs: 'PRE') ifFalse: [ ^self ].

    [	contentStream atEnd ifTrue: [ ^self ].
	self << (contentStream upTo: $<) << $<.
	self << (s := contentStream upTo: $>) << $>.
	s sameAs: '/PRE'] whileFalse
!

processLeftBracket
    | linkAddress linkName link |

    (contentStream peekFor: $[) ifTrue: [^self addCurrentChar].
    link := contentStream upTo: $].
    [contentStream peekFor: $]]
	whileTrue: [link := link , ']' , (contentStream upTo: $])].
    
    linkName := self linkNameIn: link.
    linkAddress := self linkAddressIn: link.
    (self isExternalAddress: linkAddress)
	ifTrue: ["external outside link"
	    ^self << '<A HREF="' << linkAddress << '">' << linkName << '</A>'].

    linkAddress = linkName
	ifTrue: [ self emitLink: linkName ]
	ifFalse: [ self emitLink: linkName to: linkAddress ]!

processPipe
    (contentStream peekFor: $|)
	ifTrue: [self atLineStart
		ifTrue:
		    [inTable
			ifFalse:
			    [self << '<TABLE BORDER=2 CELLPADDING=4 CELLSPACING=0 >'; nl.
			    inTable := true].
		    self << '<TR><TD>']
		ifFalse: [self << '</TD><TD>']]
	ifFalse: [self addCurrentChar]!

processPound
    self atLineStart ifFalse: [ ^self addCurrentChar].

    inNumbers ifFalse: [
	self << '<OL>'; nl.
	inNumbers := true].

    self << ' <LI>'!
    
emitLink: linkAddress
    | currentTitle |
    (self isImage: linkAddress)
	ifTrue: ["graphic image link"
		(self isExternalAddress: linkAddress)
			ifTrue: [^self << '<img src="' << linkAddress << '">']
			ifFalse: [^self << '<img src="' << '/' << self wiki filesPath << '/' << linkAddress << '">']].

    (wiki hasPageTitled: linkAddress)
	ifTrue: ["simple one piece existing link"
	    currentTitle := self wiki currentTitleOf: linkAddress.
	    self linkTo: [self << self wiki; << $/; nextPutUrl: currentTitle]
		titled: [self << currentTitle]]

	ifFalse: ["simple one piece non existant link"
	    self << '<U>' << linkAddress << '</U>'.
	    self linkTo: [self << self wiki; << '/CREATE/'; nextPutUrl: linkAddress ]
		titled: [self << $?]]!

emitLink: linkName to: linkAddress
    | currentTitle |
    (wiki hasPageTitled: linkAddress)
	ifTrue: ["two piece existing link"
	    currentTitle := self wiki currentTitleOf: linkAddress.
	    self linkTo: [self << self wiki; << $/; nextPutUrl: currentTitle]
		titled: [self << linkName]]
	ifFalse: ["two piece non existant link"
	    self << '<U>' << linkName << '</U>'.
	    self linkTo: [self << self wiki; << '/CREATE/'; nextPutUrl: linkAddress ]
		titled: [self << $?]]! !

!WikiPageHTML methodsFor: 'HTML'!

sendBody
    self emitStart.
    self emitIcons.
    self emitTitle.
    self emitContents.
    self emitSearch: ''.
    self emitFinish!

emitCommand: commandName text: textString
    ^self
	emitIcon: [ self << self wiki filesPath << $/ << commandName asLowercase << '.jpg' ]
	linkTo: [self emitUrlForCommand: commandName]
	titled: [self << textString]!

emitIcons
    self emitIconsStart.
    self emitCommonIcons.
    self emitCommand: 'EDIT' text: 'Edit this page'.
    self emitCommand: 'RENAME' text: 'Rename this page'.
    self emitCommand: 'HISTORY' text: 'History of this page'.
    self emitIconsEnd!

emitContents
    contentStream := self page contents readStream.
    [contentStream atEnd] whileFalse: [self processNextChar].
    lastChar == Character nl ifFalse: [self processNl].

    contentStream := nil!

emitTitle
    self heading: [self linkTo: [self emitUrlForCommand: 'REFS']
	    titled: [self << self page title]]! !

!WikiPageHTML methodsFor: 'initialization'!

initialize
    super initialize.
    heading := nil.
    inBullets := inNumbers := inTable := false! !

!WikiAbsentPageHTML methodsFor: 'accessing'!

browserTitle
    ^self wikiName , ': `' , self pageTitle, ''' not found'!

pageTitle
    ^request location last!

sendResponseType
    self << 'HTTP/1.1 404 Not Found'; nl!

sendBody
    self emitStart.
    self emitIcons.
    self heading: [self << self wikiName << ' contains no page titled: "' << request location last]
	level: 2.
    self emitSearch: request location last.
    self emitFinish! !

!WikiReferencesHTML methodsFor: 'private'!

actualSearchString
    ^self searchString isEmpty
	ifTrue: [self searchString]
	ifFalse: ['*' , self searchString , '*']!

findMatches
    | match |
    referringPages := SortedCollection sortBlock: [:a :b | a title < b title].
    match := self actualSearchString.
    Processor activeProcess lowerPriority.
    wiki
	pagesDo: [:each | (each references: match) ifTrue: [referringPages add: each]].
    Processor activeProcess raisePriority! !

!WikiReferencesHTML methodsFor: 'accessing'!

browserTitle
    | ws |
    ws := String new writeStream.
    ws nextPutAll: 'SEARCH '; nextPutAll: self wikiName; nextPutAll: ':"'; nextPutAll: self searchString; nextPut: $".
    ^ws contents!

sendBody
    self emitStart.
    self emitIcons.
    self emitMatchList.
    self emitSearch: self searchString.
    self emitFinish!

emitMatchList
    self findMatches.
    referringPages isEmpty ifTrue: [ ^self emitNoMatches ].
    self heading: [self << ((referringPages size = 1
		ifTrue: ['There is 1 reference to the phrase:']
		ifFalse: ['There are %1 references to the phrase:'])
		bindWith: referringPages size printString)].
    self << '<I>  ...'; << self searchString; << '...</I>'; lineBreak.
    self << '<UL>'; nl.
    referringPages do: [:each | self listItem: [self linkToPage: each]].
    self << '</UL>'; nl!

emitNoMatches
    self << '<H1>No references to the phrase</H1>'; nl.
    self << '<I>    ...'; << self searchString; << '...</I>'; lineBreak!

searchString
    ^request postDataAt: #SEARCHPATTERN
	ifAbsent: [request location last]! !

!WikiVersionHTML methodsFor: 'accessing'!

page
    ^super page versionAt: self versionNumber!

emitIcons
    self emitIconsStart.
    self emitCommonIcons.
    self emitCommand: 'HISTORY' text: 'History of this page'.
    self emitPreviousVersion.
    self emitNextVersion.
    self emitIconsEnd!

emitNextVersion
    self versionNumber < (wiki pageTitled: self page title) versionNumber ifFalse: [^self].
    self
	emitIcon: [ self << self wiki filesPath << '/next.jpg' ]
	linkTo: [self emitUrlForVersionNumber: self versionNumber + 1]
	titled: [self << 'Previous']!

emitPreviousVersion
    self versionNumber <= 0 ifTrue: [^self].
    self
	emitIcon: [ self << self wiki filesPath << '/prev.jpg' ]
	linkTo: [self emitUrlForVersionNumber: self versionNumber - 1]
	titled: [self << 'Previous']!

emitTitle
    self
	heading:
	    [self linkTo: [self emitUrlForCommand: 'REFS']
		titled: [self << self page title].
	    self << ' (Version ' << self versionNumber << ')']!

versionNumber
    ^((request postDataAt: #n) asNumber max: 0)
	min: super page versionNumber! !

!WikiVersionHTML methodsFor: 'html'!

emitUrlForVersionNumber: aNumber
    self << self wiki << '/VERSION/' << self encodedPageTitle << '?n=' << aNumber! !

!WikiCommandHTML methodsFor: 'accessing'!

browserTitle
    ^super browserTitle, self titleSuffix!

titleSuffix
    ^self subclassResponsibility! !

!WikiEditHTML methodsFor: 'accessing'!

titleSuffix
    ^' (edit)'! !

!WikiEditHTML methodsFor: 'HTML'!

emitForm
    self
	heading:
	    [self << 'Edit '.
	    self linkTo: [self emitUrlForCommand: 'REFS']
		titled: [self << self pageTitle]].
    self << 'Don''t know how to edit a page? Visit '; linkToPage: wiki syntaxPage; << '.'; nl.
    self << '<FORM ACTION="'; emitUrlOfPage; << '" METHOD=POST>'; nl.
    self << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="EDIT">'; nl.
    self << '<TEXTAREA NAME="NEWCONTENTS"  WRAP=VIRTUAL COLS=80 ROWS=20>'; nl.
    self << self page contents; nl.
    self << '</TEXTAREA>'; lineBreak.
    self << '<INPUT TYPE="submit" VALUE="Save">'; nl.
    self << '</FORM>'; nl!

sendBody
    self emitStart.
    self emitIcons.
    self emitForm.
    self emitFinish! !

!WikiHistoryHTML methodsFor: 'HTML'!

sendBody
    self emitStart.
    self emitIcons.
    self emitTitle.
    self emitTable.
    self emitSearch: ''.
    self emitFinish!

emitTitle
    self heading: [
	self << 'History of '.
    	self linkTo: [self emitUrlForCommand: 'REFS']
	    titled: [self << self page title]]!

emitTable
    self << '<TABLE WIDTH="95%" BORDER="1">'; nl.
    self << '<TR>'; nl.
    self td: [self << '<B>Version</B>']; td: [self << '<B>Operation</B>']; td: [self << '<B>Author</B>']; td: [self << '<B>Creation Time</B>'].
    self << '</TR>'; nl.
    self page versionsDo: [:each | self emitPageVersion: each].
    self << '</TABLE>'; nl!

emitPageVersion: each
    self << '<TR>'; nl.
    self td: [
	self
	    linkTo: [ self << self wiki; << '/VERSION/';
		           nextPutUrl: each title; << '?n='; << each versionNumber ]
	    titled: [self << each versionNumber]].
    self td: [self << each operationSynopsis].
    self td: [self << each author].
    self td: [self sendTimestamp: each timestamp ].
    self << '</TR>'; nl! !

!WikiHistoryHTML methodsFor: 'accessing'!

titleSuffix
    ^' (history)'! !

!WikiChangesHTML methodsFor: 'accessing'!

numberOfChanges
    ^20!

numberOfDays
    ^7!

pageTitle
    ^'Recent Changes'!

sendBody
    | day genesis minDate changesShown |
    self emitStart.
    self emitIcons.
    self emitChanges.
    self emitSearch: ''.
    self emitFinish!

emitChangedPage: aPage
    self
	listItem:
	    [self linkToPage: aPage; space.
	    self << (aPage timestamp asTime) << ' (' << aPage author << ')']!

emitChanges
    | day genesis minDate changesShown |
    self heading: [self << 'Recent Changes'].
    genesis := wiki startDate printNl.
    day := Date today.
    minDate := (day subtractDays: self numberOfDays) printNl.
    changesShown := 0.

    [   day < genesis ifTrue: [ ^self ].
	(day >= minDate) or: [changesShown < self numberOfChanges] ] whileTrue: [
	changesShown := changesShown + (self emitChangesFor: day).
	day := day subtractDays: 1
    ]!

emitChangesFor: aDate
    | sc |
    sc := SortedCollection new sortBlock: [:a :b | a timestamp > b timestamp ]
    wiki pagesDo: [:each | each timestamp asDate = aDate ifTrue: [sc add: each]].
    sc isEmpty
	ifFalse:
	    [self heading: [
		self responseStream
		    nextPutAll: aDate monthName;
		    space;
		    print: aDate day;
		    space;
		    print: aDate year ]
		level: 3.
	    self << '<UL>'; nl.
	    sc do: [:each | self emitChangedPage: each].
	    self << '</UL>'; nl].
    ^sc size! !

!WikiErrorHTML methodsFor: 'accessing'!

browserTitle
    ^self pageTitle!

emitDescription
    self << 'The '; << self wiki; << ' wiki is not able to process this request. '.
    self << 'This can be due to a malformed URL, or (less likely) to an internal server error'.
    self lineBreak; lineBreak.
    self << 'originator: '; << request originator displayString; lineBreak.
    self << 'action: '; << request action displayString; lineBreak.
    self << 'location: '.
    request location do: [:each | self << $/ << each].
    self lineBreak.
    request enumeratePostData: [:key :val | self lineBreak; << key; << ' = '; nl; << val; nl].
    self lineBreak; horizontalLine; italic: [ self << WebServer version ]!

pageTitle
    ^'Bad request'!

sendBody
    self emitStart.
    self emitIcons.
    self emitDescription.
    self emitFinish! !

!WikiRenameHTML methodsFor: 'accessing'!

titleSuffix
    ^' (rename)'!

emitForm
    self
	heading:
	    [self << 'Rename'.
	    self linkTo: [self emitUrlForCommand: 'REFS']
		titled: [self << self pageTitle]].
    self << '<FORM ACTION="'; emitUrlOfPage; << '" METHOD=POST>'; nl.
    self << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="RENAME">'; nl.
    self << '<INPUT TYPE= "TEXT" NAME="NEWTITLE" SIZE=80 VALUE="'; << self pageTitle; << '">'; lineBreak.
    self << '<INPUT TYPE="submit" VALUE="Save">'; nl.
    self << '</FORM>'; nl!

sendBody
    self emitStart.
    self emitIcons.
    self emitForm.
    self emitFinish! !

!WikiRenameConflictHTML methodsFor: 'accessing'!

newTitle
    ^request postDataAt: #NEWTITLE!

emitDescription
    self
	heading:
	    [self << 'This name ('.
	    self linkTo: [self << self wiki << $/ << self newTitle]
		titled: [self << self newTitle].
	    self << ') is in use already. Sorry, cannot complete this rename.']
	level: 2!

sendBody
    self emitStart.
    self emitIcons.
    self emitDescription.
    self emitSearch: self newTitle.
    self emitFinish! !

!WikiPersistanceManager methodsFor: 'accessing'!

wiki
    ^wiki
!

wiki: aWiki
    wiki := aWiki.
    self reset
!

allPagesDo: aBlock
    wiki allPagesDo: aBlock
! !

!WikiPersistanceManager methodsFor: 'persistance'!

addPage: aPage
!

load
    self subclassResponsibility!

save
    self subclassResponsibility! !

!FlatFileWiki methodsFor: 'initialize'!

reset
    directory exists ifFalse: [Directory create: directory name].
    idMap := IdentityDictionary new.
    fileCounter := -1! !

!FlatFileWiki methodsFor: 'private-persistance'!

idForPage: aPage
    ^idMap at: aPage ifAbsentPut: [self savePage: aPage]!

indexIn: aFilename
    | tail |
    tail := aFilename stripPath.
    ^(tail copyFrom: 1 to: tail size - 4) asNumber!

nextFileCounter
    ^fileCounter := fileCounter + 1!

loadPage: id
    ^self loadPageInFile: (directory at: id, '.pag')!

loadPageInFile: aFilename
    | index rs page |
    index := self indexIn: aFilename.
    ^idMap at: index
	ifAbsentPut:
	    [| type |
	    Transcript show: '.'.
	    rs := aFilename readStream.
	    type := rs nextLine asSymbol.
	    [page := (Smalltalk at: type) new.
	    page loadFromFile: rs under: self] ensure: [rs close].
	    page]!

loadPages
    | latestVersions pageMap |
    idMap := pageMap := IdentityDictionary new.
    directory filesMatching: '*.pag'
	do: [:fn | self loadPageInFile: fn ].

    idMap := IdentityDictionary new.
    pageMap keysAndValuesDo: [:i :page | idMap at: page put: i].

    latestVersions := pageMap asSet.
    pageMap do: [:page |
	"Remove all versions older than `each' from latest"
	page versionsDo: [:each |
	    each == page ifFalse: [latestVersions remove: each ifAbsent: []]]
    ].
    latestVersions do: [:page | self wiki addPage: page]!

load
    | rs fn |
    self reset.

    (fn := directory at: 'wiki.conf') exists ifFalse: [
	self error: 'wiki directory doesn''t exist'].

    rs := fn readStream.
    [	| type |
	type := rs nextLine asSymbol.
        self wiki: (Smalltalk at: type) new.
	self wiki loadFromFile: rs]
	    ensure: [rs close].

    self loadPages.
    self wiki persistanceManager: self.
    ^self wiki!

savePage: aPage
    | id ws |
    id := self nextFileCounter.
    idMap at: aPage put: id.

    ws := (self directory at: id printString , '.pag') writeStream.
    [	ws nextPutAll: aPage class name; nl.
	aPage saveToFile: ws under: self] ensure: [ws close].
	
    ^id!

savePages
    self allPagesDo: [ :aPage | self savePage: aPage ].
!

save
    | ws |
    self reset.
    directory exists ifFalse: [Directory create: directory name].
    ws := (directory at: 'wiki.conf') writeStream.

    [	ws nextPutAll: wiki class name; nl.
	wiki saveToFile: ws]
	    ensure: [ws close].

    self savePages! !

!FlatFileWiki methodsFor: 'accessing'!

directory
    ^directory!

directory: aFilename
    directory := Directory name: aFilename!

!FlatFileWiki methodsFor: 'pages'!

addPage: aPage
    self idForPage: aPage.
    ^self! !

!FlatFileWiki class methodsFor: 'instance creation'!

directory: aDirectory
    ^self new directory: aDirectory! !

!WebServer class methodsFor: 'examples'!

wikiDirectories
    ^#('GnuSmalltalkWiki')!

initializeImages
    (self at: 8080) handler
	addComponent: (FileWebServer
	    named: 'images'
	    directory: Directory systemKernel, '/../net/httpd')!

initializeWiki
    "Only run this method the first time."
    "WikiServer initializeNormalWiki"

    self initializeImages.
    self wikiDirectories do: [:eachName |
	| wiki |
	"Only run this method the first time."
	wiki := Wiki new.
	wiki persistanceManager: (FlatFileWiki directory: eachName).

	wiki name: eachName.
	wiki rootPageTitle: 'Home Page'.
	wiki syntaxPageTitle: 'Wiki Syntax'.
	wiki filesPath: '/images'.
	wiki save.

        (self at: 8080) handler addComponent: wiki.
    ].
    (self at: 8080) start!

initializeWikiNoImages
    "Only run this method the first time."
    "WikiServer initializeWikiNoImages"

    self wikiDirectories do: [:eachName |
	| wiki |
	"Only run this method the first time."
	wiki := Wiki new.
	wiki persistanceManager: (FlatFileWiki directory: eachName).

	wiki name: eachName.
	wiki rootPageTitle: 'Home Page'.
	wiki syntaxPageTitle: 'Wiki Syntax'.
	wiki save.

        (self at: 8080) handler addComponent: wiki.
    ].
    (self at: 8080) start!

restartWiki
    "WikiServer restartWiki"

    self initializeImages.
    self wikiDirectories do: [:eachName |
	(self at: 8080) handler
	    addComponent: (FlatFileWiki directory: eachName) load].
    (self at: 8080) start!

restartWikiNoImages
    "WikiServer restartWikiNoImages"

    self wikiDirectories do: [:eachName |
	(self at: 8080) handler addComponent:
	    ((FlatFileWiki directory: eachName) load
		filesPath: nil; yourself)
    ].
    (self at: 8080) start! !

WikiPageHTML initialize!
