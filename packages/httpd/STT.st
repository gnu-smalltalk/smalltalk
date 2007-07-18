"=====================================================================
|
|   Smalltalk templates
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Federico G. Stilman
| Porting by Markus Fritsche and Paolo Bonzini
| Integration with the web server framework by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: #STTTemplate
	instanceVariableNames: 'sttCode cache asStringSelector'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-STT'!

STTTemplate comment:
'This class implements template à la JSP, PHP, ASP (ugh!), and so on.
Smalltalk code is included between {% and %} tags.  The only caution
is not to include comments between a period or an open parentheses
of any kind, and the closing %}.

For example

    %{ "Comment" 1 to: 5 do: [ %} yes<br> %{ ] %}    is valid 
    %{ 1 to: 5 do: [ "Comment" %} yes<br> %{ ] %}    is not valid

This restriction might be removed in the future.

The template is evaluated by sending #evaluateOn: or #evaluateOn:stream:
and returns the output stream (available to the code as the variable `out'').
The first (or only) argument of these two methods is available to the
code as `self'').'!

WebResponse subclass: #STTResponse
	instanceVariableNames: 'stt'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-STT'!

STTResponse comment:
'A WebResponse that uses STTTemplate to implement #sendBody.'!

Servlet subclass: #STTServlet
	instanceVariableNames: 'stt'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-STT'!

STTServlet comment:
'A Servlet that uses a STTResponse to implement #respondTo:.  Pass
a File, Stream, String or STTTemplate to its #stt: instance-side
method to complete the initialization of the servlet.'!

FileWebServer subclass: #STTFileWebServer
	instanceVariableNames: 'knownSTTs'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-STT'!

STTFileWebServer comment:
'A FileWebServer that uses STT to process .stt files.  Templates are
cached.'!

!STTTemplate methodsFor: 'caching'!

cache
    "Returns the receiver's cached object"
    ^cache! 
	
cache: anObject
    "Save anObject in the receiver's cache"
    cache := anObject! 

initializeCache
    "Initialize the receiver's cache"
    cache := nil.! 

isCached
    "Tell if the receiver is cached or not. In the future
     this will consider the fact that a cached object may
     become old after some time, and that means that the
     object is NOT cached anymore."

    ^self cache notNil! !

!STTTemplate methodsFor: 'private'!

asSmalltalkCodeOn: anObject
    "Returns the equivalent version of the receiver as a Smalltalk
     CompiledMethod"

    | method stream |

    self isCached ifTrue: [ ^self cache ].

    stream := String new writeStream.
    self writeSmalltalkCodeOn: stream.
    method := anObject class compile: stream contents.
    self cache: method.
    anObject class removeSelector: method selector.
    ^method
!

writeSmalltalkCodeOn: stream
    "Write the equivalent version of the receiver as Smalltalk code
     on the given stream"
	 
    | sttOpenIndex sttCloseIndex lastIndex sttCodeIndex smalltalkExpression |

    stream
        nextPutAll: 'STT_Cache';
        print: self asOop;
        nextPutAll: ': out';
	nl.

    lastIndex := 1.

    [ (sttOpenIndex := self sttCode
	   indexOfSubCollection: '{%' startingAt: lastIndex) > 0] whileTrue: [

        self
	    writeOutputCodeFor: (self sttCode copyFrom: lastIndex to: sttOpenIndex - 1)
	    on: stream.

	sttCloseIndex := self sttCode
	    indexOfSubCollection: '%}'
	    startingAt: sttOpenIndex
	    ifAbsent: [ ^ self error: 'Missing closing tag' ].

	sttCodeIndex := sttOpenIndex + 2.

	(sttCode at: sttOpenIndex + 2) = $=
	    ifTrue: [
		stream nextPutAll: 'out nextPutAll: ('.
		sttCodeIndex := sttCodeIndex + 1 ].			

	smalltalkExpression := sttCode copyFrom: sttCodeIndex to: sttCloseIndex - 1.
	smalltalkExpression := smalltalkExpression trimSeparators.
	stream nextPutAll: smalltalkExpression.

	(sttCode at: sttOpenIndex + 2) = $=
	    ifTrue: [
		stream nextPutAll: ') ', self asStringSelector asString.
		sttCodeIndex := sttCodeIndex + 1.
	    ].						

	('|[({.' includes: smalltalkExpression last)
	    ifFalse: [ stream nextPut: $. ].

	stream nl.
	lastIndex := sttCloseIndex + 2.			
    ].

    self
	writeOutputCodeFor: (self sttCode copyFrom: lastIndex to: sttCode size)
	on: stream.

    stream
	nextPutAll: '^out'.
!

writeOutputCodeFor: aString on: aStream
	"Writes on aStream the required Smalltalk code for outputing aString on 'out'"

    aStream
        nextPutAll: 'out nextPutAll: ''';
        nextPutAll: aString;
	nextPutAll: '''.';
	nl! !

!STTTemplate methodsFor: 'evaluating'!

evaluateOn: anObject
    "Evaluates the receiver to anObject"
	
    ^(self evaluateOn: anObject stream: String new writeStream) contents
!

evaluateOn: anObject stream: out
    "Evaluates the receiver to anObject"
	
    ^anObject perform: (self asSmalltalkCodeOn: anObject) with: out
! !

!STTTemplate methodsFor: 'accessing'!

sttCode
    "Returns the receiver's Smalltalk Template code"

    ^sttCode!

asStringSelector
    "Returns the selector used to show objects as Strings on the receiver"

    ^asStringSelector! 

asStringSelector: aSymbol
    "Sets the selector used to show objects as Strings on the receiver"

    asStringSelector := aSymbol! !

!STTTemplate methodsFor: 'initializing'!

initializeOn: aString asStringSelector: aSymbol
    sttCode := aString.
    asStringSelector := aSymbol.
    self initializeCache.! !

!STTTemplate class methodsFor: 'unit testing'!

test
    | sttTest |
    sttTest := '
        <html>
	<head><title>{%= self class %}</title></head>
	<body>
		<table>
			{% self to: 10 do: [ :each | %}
		        <tr>
				   <td>{%= each printString %}</td>
				   <td>{%= (each * 2) printString %}</td>
		        </tr>
		   	{% ] %}
		</table>
	</body>
	</html>'.

    ^(STTTemplate on: sttTest) evaluateOn: 1!
	
test2
    | sttTest |
	
    sttTest := '
	<html>
	<head><title>{%= self class %}</title></head>

	{% 
		out nextPutAll: ''This is another test''; nl.

		1 to: 15 do: [:x |
                    out nextPutAll: ''<p>This paragraph was manually sent out '',
                                    (self * x) printString, ''</p>''; nl ].

		out nextPutAll: ''After all this ST code goes the final HTML closing tag''.
	%}

	</html>'.

    ^(STTTemplate on: sttTest) evaluateOn: 3! !

!STTTemplate class methodsFor: 'instance creation'!

on: aString
    "Creates an instance of the receiver on aString"
    ^self on: aString asStringSelector: self defaultAsStringSelector! 

on: aString asStringSelector: aSymbol
    "Creates an instance of the receiver on aString"
    ^self new initializeOn: aString asStringSelector: aSymbol! !
	
!STTTemplate class methodsFor: 'defaults'!

defaultAsStringSelector
    ^#displayString! !


!STTResponse class methodsFor: 'responding'!

respondTo: aRequest with: aSTTTemplate
    self new
	stt: aSTTTemplate;
	respondTo: aRequest! !

!STTResponse methodsFor: 'sending'!

sendBody
    [ self stt evaluateOn: self stream: responseStream ]
	on: Error
	do: [ :ex |
	    responseStream << ex messageText; nl; << '<pre>'.
	    Smalltalk backtraceOn: responseStream.
	    responseStream nl; << '</pre>'.
	    ex return
	]! !

!STTResponse methodsFor: 'accessing'!

stt
    ^stt!

stt: aSTTTemplate
    stt := aSTTTemplate! !




!STTServlet methodsFor: 'accessing'!

respondTo: aRequest
    STTResponse respondTo: aRequest with: self stt!

stt
    ^stt!

stt: aSTTTemplate
    (aSTTTemplate isKindOf: File)
	ifTrue: [ self stt: aSTTTemplate readStream contents. ^self ].
    (aSTTTemplate isKindOf: Stream)
	ifTrue: [ self stt: aSTTTemplate contents. ^self ].
    (aSTTTemplate isKindOf: STTTemplate)
	ifFalse: [ self stt: (STTTemplate on: aSTTTemplate). ^self ].

    stt := aSTTTemplate! !

!STTFileWebServer methodsFor: 'accessing'!

initialize
    super initialize.
    knownSTTs := LookupTable new!

fileResponse: file request: aRequest
    | stt |
    ('*.stt' match: file name)
	ifFalse: [ ^super fileResponse: file request: aRequest ].

    stt := knownSTTs at: file name ifAbsentPut: [
	STTTemplate on: file readStream contents ].

    ^STTResponse new stt: stt! !

!WebServer class methodsFor: 'testing'!

publishMyFileSystem
    "Watch out!! Security hole, they could steal /etc/passwd!!"
    "WebServer publishMyFileSystem"

    | handler |
    self terminateServer: 8080.

    "Add a file server on a particular directory."
    handler := (self initializeServer: 8080) handler.
    handler addComponent: (STTFileWebServer named: 'disk'
                directory: '/')! !
 
