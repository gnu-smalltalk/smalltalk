"======================================================================
|
|   IMAP protocol support
|
|
 ======================================================================"


"======================================================================
|
| Copyright (c) 2000 Leslie A. Tyrrell
|
| This file is part of the GNU Smalltalk class library.
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



NetClients addSubspace: #IMAP!
Namespace current: NetClients.IMAP!

Object subclass:  #IMAPCommand
    instanceVariableNames: 'client sequenceID name arguments status responses completionResponse promise '
    classVariableNames: 'ResponseRegistry '
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPCommand comment: 
nil!

Object subclass:  #IMAPFetchedItem
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPFetchedItem comment: 
nil!

NetProtocolInterpreter subclass:  #IMAPProtocolInterpreter
    instanceVariableNames: 'client responseStream commandSequencer mutex readResponseSemaphore continuationPromise commandsInProgress queuedCommands '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPProtocolInterpreter comment: 
nil!

NetClient subclass:  #IMAPClient
    instanceVariableNames: 'state '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPClient comment: 
nil!

Object subclass:  #IMAPCommandSequencer
    instanceVariableNames: 'prefix value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPCommandSequencer comment: 
nil!

Object subclass:  #IMAPFetchedItemSectionSpecification
    instanceVariableNames: 'specName parameters span rawContent '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPFetchedItemSectionSpecification comment: 
nil!

Object subclass:  #IMAPResponse
    instanceVariableNames: 'source cmdName value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPResponse comment: 
nil!

IMAPResponse subclass:  #IMAPContinuationResponse
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPResponse comment: 
nil!

Object subclass:  #IMAPState
    instanceVariableNames: 'client '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPState comment: 
nil!

TestCase subclass:  #IMAPProtocolInterpreterTest
    instanceVariableNames: 'pi '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPProtocolInterpreterTest comment: 
nil!

IMAPResponse subclass:  #IMAPDataResponse
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPDataResponse comment: 
nil!

IMAPState subclass:  #IMAPAuthenticatedState
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPAuthenticatedState comment: 
nil!

IMAPResponse subclass:  #IMAPStatusResponse
    instanceVariableNames: 'text status '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPStatusResponse comment: 
nil!

TestCase subclass:  #IMAPResponseTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPResponseTest comment: 
nil!

IMAPResponse subclass:  #IMAPCommandCompletionResponse
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPCommandCompletionResponse comment: 
nil!

TestCase subclass:  #IMAPTest
    instanceVariableNames: 'client '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPTest comment: 
nil!

IMAPFetchedItem subclass:  #IMAPBodySectionFetchedItem
    instanceVariableNames: 'sectionSpec '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPBodySectionFetchedItem comment: 
nil!

IMAPState subclass:  #IMAPNonAuthenticatedState
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPNonAuthenticatedState comment: 
nil!

IMAPFetchedItem subclass:  #IMAPMessageEnvelopeFetchedItem
    instanceVariableNames: 'envelope '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPMessageEnvelopeFetchedItem comment: 
nil!

IMAPFetchedItem subclass:  #IMAPBodyRFC822FetchedItem
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPBodyRFC822FetchedItem comment: 
nil!

IMAPFetchedItem subclass:  #IMAPMessageMetadataFetchedItem
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPMessageMetadataFetchedItem comment: 
nil!

IMAPFetchedItemSectionSpecification subclass:  #IMAPFetchedItemHeaderSectionSpecification
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPFetchedItemHeaderSectionSpecification comment: 
nil!

IMAPFetchedItem subclass:  #IMAPBodyStructureFetchedItem
    instanceVariableNames: 'structure '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPBodyStructureFetchedItem comment: 
nil!

TestCase subclass:  #IMAPScannerTest
    instanceVariableNames: 'parser '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPScannerTest comment: 
nil!

IMAPFetchedItem subclass:  #IMAPBodyFetchedItem
    instanceVariableNames: 'parts '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPBodyFetchedItem comment: 
nil!

IMAPDataResponse subclass:  #IMAPDataResponseFetch
    instanceVariableNames: 'fetchedItems metaResponses '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPDataResponseFetch comment: 
nil!

IMAPStatusResponse subclass:  #IMAPResponseMailboxStatus
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPResponseMailboxStatus comment: 
nil!

IMAPStatusResponse subclass:  #IMAPResponseTagged
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPResponseTagged comment: 
nil!

IMAPDataResponse subclass:  #IMAPDataResponseSearch
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPDataResponseSearch comment: 
nil!

IMAPAuthenticatedState subclass:  #IMAPSelectedState
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPSelectedState comment: 
nil!

IMAPDataResponse subclass:  #IMAPDataResponseList
    instanceVariableNames: 'mbAttributes mbDelimiter mbName '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPDataResponseList comment: 
nil!

MIME.MailScanner subclass:  #IMAPScanner
    instanceVariableNames: 'flagBracketSpecial '
    classVariableNames: 'TextMask QuotedTextMask QuotedPairChar AtomMask '
    poolDictionaries: ''
    category: 'NetClients-IMAP'!

IMAPScanner comment: 
nil!


IMAPDataResponseList subclass:  #IMAPDataResponseLSub
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'NetClients-IMAP'!

IMAPDataResponseLSub comment:
nil!

!IMAPCommand class methodsFor: 'class initialization'!

initialize
    "IMAPCommand initialize"

    (ResponseRegistry := Dictionary new)
        at: 'FETCH' put: #('FETCH' 'OK' 'NO' 'BAD');
        at: 'SEARCH' put: #('SEARCH' 'OK' 'NO' 'BAD');
        at: 'SELECT' put: #('FLAGS' 'EXISTS' 'RECENT' 'OK' 'NO' 'BAD');
        at: 'EXAMINE' put: #('FLAGS' 'EXISTS' 'RECENT' 'OK' 'NO' 'BAD');
        at: 'LIST' put: #('LIST' 'OK' 'NO' 'BAD');
        at: 'LSUB' put: #('LSUB' 'OK' 'NO' 'BAD');
        at: 'STATUS' put: #('STATUS');
        at: 'EXPUNGE' put: #('EXPUNGE' 'OK' 'NO' 'BAD');
        at: 'STORE' put: #('FETCH' 'OK' 'NO' 'BAD');
        at: 'UID' put: #('FETCH' 'SEARCH' 'OK' 'NO' 'BAD');
        at: 'CAPABILITY' put: #('CAPABILITY' 'OK' 'BAD');
        at: 'STORE' put: #('FETCH');
        at: 'LOGOUT' put: #('BYE' 'OK' 'BAD');
        at: 'CLOSE' put: #('OK' 'NO' 'BAD');
        at: 'CHECK' put: #('OK' 'NO');
        at: 'APPEND' put: #('OK' 'NO' 'BAD');
        at: 'SUBSCRIBE' put: #('OK' 'NO' 'BAD');
        at: 'RENAME' put: #('OK' 'NO' 'BAD');
        at: 'DELETE'  put: #('OK' 'NO' 'BAD');
        at: 'CREATE'  put: #('OK' 'NO' 'BAD');
        at: 'LOGIN'  put: #('OK' 'NO' 'BAD');
        at: 'AUTHENTICATE' put: #('OK' 'NO' 'BAD');
        at: 'NOOP'  put: #('OK' 'BAD')! !

!IMAPCommand class methodsFor: 'defined responses'!

definedResponsesAt: aName

    ^self responseRegistry at: aName asUppercase ifAbsentPut: [IdentityDictionary new]!

responseRegistry
    ^ResponseRegistry! !

!IMAPCommand class methodsFor: 'instance creation'!

forClient: anIMAPPI name: aString arguments: arguments

" The intention here is to let users specify the complete string of command arguments. Because this string may contain atom-specials like $(, etc., this line may be sent as quoted string, which would be wrong. So we fool the printing logic to view this string as an atom. It is a hack, but seems like a convenient one "

    | args |

    args := arguments isCharacters
        ifTrue: [#atom -> arguments]
        ifFalse: [arguments].

    ^self new
        forClient: anIMAPPI
        name: aString
        arguments: args!

login: aNameString password: aPassString
    ^self name: 'login' arguments: (Array with: (#string->aNameString) with: (#string->aPassString))!

new
    ^self basicNew initialize!

parse: scanner 
    "Read and parse next command from a stream. This is mainly useful for testing previously stored 
    exchange logs"

    ^self new parse: scanner!

readFrom: aStream
" Read and parse next command from a stream. This is mainly useful for testing previously stored exchange logs "

    ^self parse: (IMAPScanner on: aStream)! !

!IMAPCommand methodsFor: 'accessing'!

arguments
    ^arguments!

arguments: anObject
    arguments := anObject!

client
    ^client!

client: anObject
    client := anObject!

name
    ^name!

name: anObject
    name := anObject!

sequenceID
    ^sequenceID!

sequenceID: anObject
    sequenceID := anObject! !

!IMAPCommand methodsFor: 'completion response'!

completionResponse
    ^completionResponse!

completionResponse: anObject

    completionResponse := anObject.

    self beDone! !

!IMAPCommand methodsFor: 'execute'!

execute
    "Prepend the given command and send it to the server."
    self sendOn: client connectionStream.
    self client connectionStream nl.
    self beSent!

wait

    ^promise value! !

!IMAPCommand methodsFor: 'handle responses'!

definedResponses
    ^self class definedResponsesAt: self name asUppercase!

handle: aResponse 
    (aResponse hasTag: self sequenceID)
        ifTrue: 
            [self completionResponse: aResponse.
            ^true].
    (self isDefinedResponse: aResponse)
        ifTrue: 
            [self responses add: aResponse.
            ^true].
    ^self notifyClientIfNeeded: aResponse!

isDefinedResponse: aResponse 

    ^self definedResponses includes: aResponse cmdName!

needsClientNotification: aResponse
    ^false
"    ^client isInterestedIn: aResponse"!

notifyClientIfNeeded: aResponse 
    ^(self needsClientNotification: aResponse)
        ifTrue: [client handle: aResponse]
        ifFalse: [false]!

registerResponse: aResponse

    (aResponse isCompletionResponse)
        ifTrue: [ self completionResponse: aResponse ]
        ifFalse: [ self responses add: aResponse ]!

responses

    ^responses notNil
        ifTrue: [ responses ]
        ifFalse: [ responses := OrderedCollection new ]! !

!IMAPCommand methodsFor: 'initialization'!

forClient: anIMAPPI name: aString arguments: args

    self client: anIMAPPI.
    self name: aString.
    self arguments: (self canonicalizeArguments: args)!

initialize
    promise := Promise new.
    responses := OrderedCollection new: 1! !

!IMAPCommand methodsFor: 'obsolete'!

completedSuccessfully

    ^self successful! !

!IMAPCommand methodsFor: 'parsing'!

parse: scanner 
    "Read and parse next command from a stream. This is mainly useful for testing previously stored 
    exchange logs"

    | tokens |

    tokens := scanner deepTokenizeAsAssociation.
    self
        sequenceID: tokens first value; 
        name: (tokens at: 2) value; 
        arguments: (tokens copyFrom: 3 to: tokens size)! !

!IMAPCommand methodsFor: 'printing'!

printCompletionResponseOn: aStream indent: level

    self completionResponse notNil
        ifTrue: [ self completionResponse printOn: aStream indent: level]!

printOn: aStream 
    self scanner
        printTokenList: self asTokenList on: aStream!

printResponseOn: aStream indent: level

    (self responces isNil or: [ self responces isEmpty ])  ifTrue: [ ^String new].
    self responses do: [ : eachResponse |
        aStream nl. eachResponse printOn: aStream indent: level
        ]!

scanner
    ^IMAPScanner!

sendOn: aClient 

    "aClient is a IMAPProtocolInterpreter"

    self client sendTokenList: self asTokenList! !

!IMAPCommand methodsFor: 'private'!

asTokenList
    | list | 
    list := OrderedCollection with: (#atom->self sequenceID) with: (#atom->name).
    self arguments notNil 
        ifTrue: [list addAll: self arguments].
    ^list!

canonicalizeArguments: arguments
" Arguments can one of: integer, string or array of thereof, potentially nested. Scalars are
converted into array with this scalar as a sole element "
    
    arguments isNil ifTrue: [^Array new].
    ^(arguments isCharacters or: [arguments isSequenceable not])
        ifTrue: [^Array with: arguments]
        ifFalse: [ arguments ]!

promise
    ^promise! !

!IMAPCommand methodsFor: 'responses'!

commandResponse
    | coll |
    ^(coll := self commandResponses) isEmpty
        ifTrue: [ nil ]
        ifFalse: [coll first]!

commandResponses
    ^self responses select: [:resp | resp cmdName match: self name]!

commandResponseValue
    | resp |
    ^(resp := self commandResponse) isNil
        ifTrue: [ nil ]
        ifFalse: [resp value]!

statusResponses

    ^self responses
        select: [ : eachResponse | eachResponse isStatusResponse ]! !

!IMAPCommand methodsFor: 'status'!

beDone

    self status: #done.
    self client commandIsDone: self.
    self value: self completionResponse!

beSent

    self status: #sent.
    self client commandIsInProgress: self!

status

    ^status!

status: anObject

    status := anObject!

value

    ^promise value!

value: anObject

    promise value: status! !

!IMAPCommand methodsFor: 'testing'!

failed
    ^self successful not!

isDone

    ^self status = #done!

isSent

    ^self status = #sent!

successful

    ^self isDone
        and: [ self completionResponse isOK ]! !




!IMAPFetchedItem class methodsFor: 'instance creation'!

canBe: aName

    ^false!

defaultFetchedItemClass

    ^IMAPFetchedItem!

named: aName

    ^(self properSubclassForItemNamed: aName) new
        name: aName!

properSubclassForItemNamed: aName

    ^IMAPFetchedItem allSubclasses
        detect: [ : each | each canBe: aName ]
        ifNone: [ self defaultFetchedItemClass ]! !

!IMAPFetchedItem methodsFor: 'building'!

extractContentFrom: tokenStream

    self subclassResponsibility! !

!IMAPFetchedItem methodsFor: 'name'!

name

    ^name!

name: aName

    name := aName! !




!IMAPProtocolInterpreter methodsFor: 'accessing'!

client

    ^client!

client: imapClient

    client := imapClient!

commandPrefix: aString
    commandSequencer prefix: aString!

responseStream

    ^responseStream! !

!IMAPProtocolInterpreter methodsFor: 'connection'!

connect
    super connect.
    self resetCommandSequence.
    responseStream := connectionStream.
    commandSequencer reset.
    self getResponse! !

!IMAPProtocolInterpreter methodsFor: 'constants and defaults'!

defaultCommandPrefix
    ^'imapv4_'!

defaultPortNumber
    ^143!

defaultResponseClass
    ^IMAPResponse!

lineEndConvention
    ^LineEndCRLF! !

!IMAPProtocolInterpreter methodsFor: 'events'!

commandIsDone: command 
    mutex
        critical: 
            [commandsInProgress remove: command ifAbsent: [^self].
            readResponseSemaphore wait]!

commandIsInProgress: command 
    mutex
        critical: 
            [commandsInProgress addFirst: command.
            readResponseSemaphore signal]!

commandIsQueued: command!

connectionIsReady
! !

!IMAPProtocolInterpreter methodsFor: 'initialize-release'!

initialize
    super initialize.
    mutex := Semaphore forMutualExclusion.
    readResponseSemaphore := Semaphore new.
    queuedCommands := SharedQueue new.
    commandsInProgress := OrderedCollection new: 4.
    commandSequencer := IMAPCommandSequencer newPrefix: self defaultCommandPrefix.
    self commandReaderLoop fork.
    self responseReaderLoop fork! !

!IMAPProtocolInterpreter methodsFor: 'private'!

commandReaderLoop
    | command |
    ^[[command := queuedCommands next.
    self class log: ['----------------------------------']
        level: #IMAPClient. 
    self class log: ['C: ' , command printString]
        level: #IMAPClient.
    command execute] repeat]!

commandsInProgress

    ^commandsInProgress!

nextCommandSequenceNumber

    ^commandSequencer next!

queuedCommands

    ^queuedCommands!

resetCommandSequence

    commandSequencer reset!

responseReaderLoop
    ^[[readResponseSemaphore wait; signal. self handleNextResponse ] whileTrue]!

responseStream: stream
" This is ONLY for debugging purposes "
    responseStream := stream! !

!IMAPProtocolInterpreter methodsFor: 'public'!

executeCommand: aCommand 
    aCommand sequenceID isNil 
        ifTrue: [aCommand sequenceID: self nextCommandSequenceNumber].
    queuedCommands nextPut: aCommand.
    self commandIsQueued: aCommand! !

!IMAPProtocolInterpreter methodsFor: 'responses'!

getResponse
    | resp | 
    resp := self defaultResponseClass readFrom: self responseStream. 
    self class log: ['  S: ' , resp printLog ]
        level: #IMAPServer.
    ^resp!

handle: aResponse

    ^self client handle: aResponse!

handleContinuationResponse: aResponse
    | promise |
    promise := continuationPromise.
    continuationPromise := nil.
    readResponseSemaphore wait.
    promise value: aResponse!

handleNextResponse
    | resp |
    resp := self getResponse.
    resp isNil ifTrue: [^false].
    (self waitingForContinuation and: [ resp isContinuationResponse ])
	ifTrue: [
	    self handleContinuationResponse: resp.
	    ^true].

    commandsInProgress 
            detect: [:command | command handle: resp]
            ifNone: [self handle: resp].
    ^true!

waitForContinuation
    | promise |
    continuationPromise isNil ifTrue: [
	continuationPromise := Promise new ].
    promise := continuationPromise.
    readResponseSemaphore signal.
    ^promise value!

waitingForContinuation
    ^continuationPromise notNil! !


!IMAPProtocolInterpreter methodsFor: 'sending tokens'!

argumentAsAssociation: argument
    (argument isKindOf: Association) ifTrue: [^argument].
    argument isNil ifTrue: [^'NIL'].
    argument isCharacters ifTrue: [^#string->argument].
    (argument isKindOf: Number) ifTrue: [^#number->argument].
    argument isSequenceable ifTrue: [^#parenthesizedList->argument].
    ^argument!

sendLiteralString: string 

    IMAPScanner printLiteralStringLength: string on: self connectionStream.
    self waitForContinuation.
    IMAPScanner printLiteralStringContents: string on: self connectionStream!

sendToken: token tokenType: tokenType

    tokenType = #literalString
        ifTrue: [self sendLiteralString: token]
        ifFalse: [IMAPScanner printToken: token tokenType: tokenType on: self connectionStream]!

sendTokenList: listOfTokens 
    | assoc |
    listOfTokens
        do: 
            [:arg | 
            assoc := self argumentAsAssociation: arg.
            self sendToken: assoc value tokenType: assoc key]
        separatedBy: [self connectionStream space]! !




!IMAPClient methodsFor: 'accessing'!

protocolInterpreter
    ^IMAPProtocolInterpreter!

state
    ^state!

state: aState
    state := aState.
    state client: self! !

!IMAPClient methodsFor: 'connection'!

connectToHost: aString port: aNumber
    "Establish a connection to the host <aString>."

    super connectToHost: aString port: aNumber.
    self state: IMAPNonAuthenticatedState new!

!IMAPClient methodsFor: 'commands'!

append: message to: aMailboxName 
    ^self state
        append: message
        to: aMailboxName
        flags: nil
        date: nil!

append: message to: aMailboxName flags: flags date: dateString 
    ^self state
        append: message
        to: aMailboxName
        flags: flags
        date: dateString!

capability

    ^self state capability!

check

    ^self state check!

close

    ^self state close!

create: aMailBoxName

    ^self state create: aMailBoxName!

delete: aMailBoxName

    ^self state delete: aMailBoxName!

examine: aMailBoxName

    ^self state examine: aMailBoxName!

expunge

    ^self state expunge!

fetch: aCriteria

    ^self state fetch: aCriteria!

fetch: messageNumbers retrieve: criteria

    ^self state fetch: messageNumbers retrieve: criteria!

fetchRFC822Messages: messageNumbers 
    | result dict |
    result := self state fetch: messageNumbers retrieve: 'rfc822'.
    dict := Dictionary new: 4.

    ^result successful
        ifTrue: 
            [result commandResponses do: [:resp | dict at: resp value put: (resp parameters at: 'RFC822')].
            dict]
        ifFalse: [nil]!

list: refName mailbox: name

    ^self state list: refName mailbox: name!

login
    ^self state login!

logout
    ^self state logout!

lsub: refName mailbox: name

    ^self state lsub: refName mailbox: name!

noop

    ^self state noop!

rename: oldMailBox newName: newMailBox 

    ^self state rename: oldMailBox newName: newMailBox!

search: aCriteria

    ^self state search: aCriteria!

select: aMailBoxName

    ^self state select: aMailBoxName!

status: aMailBoxNameWithArguments

    ^self state status: aMailBoxNameWithArguments!

store: args

    ^self state store: args!

subscribe: aMailBoxName

    ^self state subscribe: aMailBoxName!

uid: aString

    ^self state uid: aString!

unsubscribe: aMailBoxName

    ^self state unsubscribe: aMailBoxName! !

!IMAPClient methodsFor: 'create&execute command'!

commandClassFor: cmdName 
    ^self class commandClassFor: cmdName!

createCommand: aString 

    ^self createCommand: aString arguments: nil!

createCommand: aString arguments: anArray 
    ^IMAPCommand
        forClient: clientPI
        name: aString
        arguments: anArray!

execute: cmd arguments: args changeStateTo: aStateBlock
    ^self 
        execute: [self createCommand: cmd arguments: args ] 
        changeStateTo: aStateBlock!

execute: aBlock changeStateTo: aStateBlock
    | command |
    command := aBlock value.
    self executeCommand: command.
    command wait.
    command completedSuccessfully ifTrue: [self state: aStateBlock value ].
    ^command!

executeAndWait: aString 
    ^self executeAndWait: aString arguments: nil!

executeAndWait: aString arguments: anArray
    | command |
    command := self createCommand: aString arguments: anArray.
    self executeCommand: command.
    command wait.
    ^command!

executeCommand: aCommand 
    ^self clientPI executeCommand: aCommand! !

!IMAPClient methodsFor: 'private'!

canonicalizeMailboxName: aMailboxName
" #todo. Mailbox names are encoded in UTF-7 format. Add encoding logic here when available "

    ^aMailboxName!

messageSetAsString: messageNumbers 
    | stream |
    stream := (String new: 64) writeStream.
    messageNumbers 
            do: [:messageNumber | stream nextPutAll: messageNumber]
            separatedBy: [stream nextPut: $,].
    ^stream contents! !

!IMAPClient methodsFor: 'responses'!

handle: aResponse 
    "^aResponse"

    ^true! !




!IMAPCommandSequencer class methodsFor: 'instance creation'!

new
    ^self basicNew initialize!

newPrefix: prefix
    ^self new prefix: prefix; yourself! !

!IMAPCommandSequencer methodsFor: 'accessing'!

next

    self increment.

    ^self prefix, self value printString!

prefix

    ^prefix!

prefix: aValue

    prefix := aValue!

value

    ^value!

value: aValue

    value := aValue! !

!IMAPCommandSequencer methodsFor: 'initialization'!

initialize
    value := 0!

reset

    self value: 0! !

!IMAPCommandSequencer methodsFor: 'private'!

increment

    self value: (self value + 1)! !




!IMAPFetchedItemSectionSpecification class methodsFor: 'instance creation'!

readFrom: tokenStream

    | specName |

    specName := tokenStream next.
    specName isNil ifTrue: [ specName := 'Empty' ].

    ^(self properSubclassFor: specName) new
        specName: specName ;
        readFrom: tokenStream! !

!IMAPFetchedItemSectionSpecification class methodsFor: 'matching'!

canBe: aName

    ^#(
        'TEXT'
        'MIME'
       ) includes: aName asUppercase!

defaultClass

    ^IMAPFetchedItemSectionSpecification!

properSubclassFor: aName

    ^IMAPFetchedItemSectionSpecification withAllSubclasses
        detect: [ : each | each canBe: aName ]
        ifNone: [ self defaultClass ]! !

!IMAPFetchedItemSectionSpecification methodsFor: 'accessing'!

specName
    ^specName!

specName: aName

    specName := aName! !

!IMAPFetchedItemSectionSpecification methodsFor: 'content'!

extractContentFrom: tokenStream

    "
    Check for a partial fetch- this would include a range specification given in angle brackets.
    Otherwise, there should only be a single token containing the requested content.
    "

    |  peekStream |

    peekStream := tokenStream peek readStream.

    (peekStream peek = $<)
        ifTrue: [ self extractSpannedContentSpanFrom: tokenStream ]
        ifFalse: [ rawContent := tokenStream next ]!

extractSpannedContentSpanFrom: tokenStream

"we've lost some information- we need the bytecount, but it is gone.  Must revisit this!!"

    | startPoint |

    startPoint := (tokenStream next readStream
        next ;
        upTo: $>) asNumber.

    rawContent := tokenStream next.

"we're going to try to simply use the length of the raw content as the span length- however, this is not actually correct, though it is close."

    span := (startPoint) @ (rawContent size)!

rawContent

    ^rawContent! !

!IMAPFetchedItemSectionSpecification methodsFor: 'instance creation'!

readFrom: tokenStream

    "
    The section spec will be either numeric (if the message is MIME this is oK) or one of the following:
        'HEADER'
        'HEADER.FIELDS'
        'HEADER.FIELDS.NOT'
        'MIME'
        'TEXT'

    Some examples would be:

    1
    1.HEADER

    HEADER
    HEADER.FIELDS

    3.2.3.5.HEADER.FIELDS (to fetch header fields for part 3.2.3.5)
    "

"the numeric part could be pulled out at this point as the position spec, followed by the section spec, then followed by optional? parameters."

    "positionSpec := ?"

    parameters := tokenStream next! !

!IMAPFetchedItemSectionSpecification methodsFor: 'span'!

pvtFullSpan

    ^0 to: (self rawContent size)!

span

    "Items are not always requested in their entirety.  The span tells us which part of the desired content was retrieved."

    ^span notNil
        ifTrue: [ span ]
        ifFalse: [ self pvtFullSpan ]!

span: anInterval

    "Items are not always requested in their entirety.  The span tells us which part of the desired content was retrieved."

    span := anInterval! !




!IMAPResponse class methodsFor: 'parsing, general'!

defaultResponseClass
    ^IMAPResponse!

parse: scanner

    | theToken theResponse |

    theToken := scanner nextToken.
    theToken isNil ifTrue: [ ^nil ].

    "
    IMAP Server responses are classified as either tagged or untagged.
    Untagged responses begin with either the asterisk or plus sign, while tagged responses begin with the command id.
    "

    theResponse := (#($* '+') includes: theToken)
        ifTrue: [ self parseUntagged: scanner withStar: theToken == $* ]
        ifFalse: [ self parseTagged: scanner withTag: theToken ].

    scanner upTo: Character nl.

    ^theResponse
        source: scanner sourceTrail;
        yourself!

parserForUntaggedResponse: responseName

    | properSubclass |

    properSubclass := IMAPResponse allSubclasses
        detect: [ : each | each canParse: responseName ]
        ifNone: [ self defaultResponseClass ].

    ^properSubclass new!

parserTypeForTaggedStatus: status
    ^IMAPResponseTagged!

parseTagged: scanner withTag: tag

    | status |

    status := scanner nextToken.

    ^(self parserTypeForTaggedStatus: status)
        parse: scanner
        tag: tag
        status: status!

parseContinuationResponse: scanner
    ^IMAPContinuationResponse new!

parseUntagged: scanner withStar: isStar

    | token token2 |

    "An untagged responses might be a continuation responses.
    These begin with the plus sign rather than the asterisk."

    isStar
        ifFalse: [ ^self parseContinuationResponse: scanner ].

    token := scanner nextToken.

    "At this point, we know the response is untagged, but IMAP's untagged responses are not well designed.
    Some responses provide numeric data first, response or condition name second, while others do it the other way around.
    What we are doing here is determining what order these things are in, and then doing the parsing accordingly."

    ^(token first isLetter)
        ifTrue: [
            (self parserForUntaggedResponse: token)
                parse: scanner with: token
            ]
        ifFalse: [
            token2 := scanner nextToken.
            (self parserForUntaggedResponse: token2)
                parse: scanner forCommandOrConditionNamed: token2 withValue: token
            ]!

readFrom: stream

    ^self parse: (self scannerOn: stream)!

scannerOn: stream
    ^IMAPScanner on: stream! !

!IMAPResponse class methodsFor: 'testing'!

canParse: responseName 

    ^false! !

!IMAPResponse methodsFor: 'accessing'!

cmdName
    ^cmdName!

cmdName: aString
    cmdName := aString!

source
    ^source!

source: aString
    source := aString!

tag
    ^nil!

value
    ^value!

value: aValue
    value := aValue! !

!IMAPResponse methodsFor: 'parsing, general'!

parse: scanner

    self value: scanner deepTokenize!

parse: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue 

    self cmdName: commandOrConditionName.
    self value: codeValue.

    self parse: scanner!

parse: scanner with: commandConditionOrStatusName

    self cmdName: commandConditionOrStatusName.

    self parse: scanner!

scanFrom: scanner

    self value: scanner deepTokenize!

scanFrom: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue 

    self cmdName: commandOrConditionName.
    self value: codeValue.

    self scanFrom: scanner!

scanFrom: scanner with: commandConditionOrStatusName

    self cmdName: commandConditionOrStatusName.

    self scanFrom: scanner! !

!IMAPResponse methodsFor: 'printing'!

printLog

    ^self source!

printOn: stream

    source notNil ifTrue: [ stream nextPutAll: source ]! !

!IMAPResponse methodsFor: 'testing'!

hasTag: aString
    ^false!

isContinuationResponse
    ^false!

isStatusResponse
    ^false! !


!IMAPState class methodsFor: 'instance creation'!

forClient: client
    ^self new client: client! !

!IMAPState methodsFor: 'accessing'!

client

    ^client! !

!IMAPState methodsFor: 'any state valid commands'!

capability
    ^client executeAndWait: 'capability'!

logout
    | command |
    (command := client executeAndWait: 'logout') completedSuccessfully
        ifTrue: [  client state: IMAPState new].
    ^command!

noop 
    ^client executeAndWait: 'noop'! !

!IMAPState methodsFor: 'commands'!

append
    self signalError!

check: aClient
    self signalError!

close: aClient
    self signalError!

copy
    self signalError!

create: aClient arguments: aList
    self signalError!

delete: aClient arguments: aList
    self signalError!

examine: aClient arguments: aList
    self signalError!

expunge: aClient
    self signalError!

fetch: aClient arguments: aList
    self signalError!

list: aClient arguments: aList
    self signalError!

login: pi
    self signalError!

lsub: aClient arguments: aLIst
    self signalError!

rename: aClient arguments: aList
    self signalError!

search: aClient arguments: aLIst
    self signalError!

select: aClient arguments: aList
    self signalError!

status
    self signalError!

store: aClient arguments: aList
    self signalError!

subscribe: aClient arguments: aList
    self signalError!

uid: aClient arguments: aList
    self signalError!

unsubscribe: aClient arguments: aList
    self signalError! !

!IMAPState methodsFor: 'errors'!

signalError

    ^self protocolError: 'wrong state'! !

!IMAPState methodsFor: 'initialize-release'!

client: aValue

    client := aValue! !

!IMAPState methodsFor: 'obsolete'!

capability: aClient 
    | command |
    ^(command := aClient executeAndWait: 'capability') completedSuccessfully
        ifTrue: [command]
        ifFalse: [false]!

logout: aClient
    | command |
    (command := aClient executeAndWait: 'logout') completedSuccessfully
        ifTrue: [  aClient state: IMAPState new].
    ^command!

noop: client 
    | command |
    ^(command := client executeAndWait: 'noop') completedSuccessfully
        ifTrue: [command]
        ifFalse: [false]! !

!IMAPState methodsFor: 'testing'!

isAuthenticated

    ^false!

isSelected

    ^false! !




!IMAPProtocolInterpreterTest methodsFor: 'running'!

setUp
    pi := IMAPProtocolInterpreter new.
    pi client: IMAPClient new! !

!IMAPProtocolInterpreterTest methodsFor: 'Testing'!

testScript1
    self executeCompleteTestScript: 'C: abcd CAPABILITY
S: * CAPABILITY IMAP4rev1 AUTH=KERBEROS_V4
S: abcd OK CAPABILITY completed
' readStream!

testScript2
    | stream |

    stream :=
'C: A003 APPEND saved-messages (\Seen) {309}
S: + Ready for additional command text
C: Date: Mon, 7 Feb 1994 21:52:25 -0800 (PST)
C: From: Fred Foobar <foobar@Blurdybloop.COM>
C: Subject: afternoon meeting
C: To: mooch@owatagu.siam.edu
C: Message-Id: <B27397-0100000@Blurdybloop.COM>
C: MIME-Version: 1.0
C: Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
C: 
C: Hello Joe, do you think we can meet at 3:30 tomorrow?
C: 1234567
S: A003 OK APPEND completed' readStream.
    self executeCompleteTestScript: stream! !

!IMAPProtocolInterpreterTest methodsFor: 'utility'!

executeCompleteTestScript: aStream 
    "Execute script respresenting complete execution of one or more commands. 
    At the end of the script all commands must have been completed, so there will be 
    no queued or outstanding commands and all returned commands will be in 'done' state"

    | cmds |
    cmds := self executeTestScript: aStream.
    cmds last value.                                    " Wait for the last command "
    self assert: pi queuedCommands size = 0.
    self assert: pi commandsInProgress size = 0.
    cmds do: [:cmd | self assert: cmd isDone].
    ^cmds!

executeTestScript: aStream 
"Execute script is the form: 
    C: abcd CAPABILITY 
    S: * CAPABILITY IMAP4rev1 AUTH=KERBEROS_V4 
    S: abcd OK CAPABILITY completed 
    Lines starting with 'C: ' are client commands, lines starting with 'S: ' are server responses"

    | cmd cmdStream respStream line |
    cmdStream := (String new: 64) writeStream.
    respStream := (String new: 64) writeStream.
    [aStream atEnd]
        whileFalse: 
            [cmd := aStream peek asUppercase.
            line := aStream next: 3; upTo: Character nl.
            (cmd == $C)
                ifTrue: [cmdStream nextPutAll: line; nl]
                ifFalse: [respStream nextPutAll: line; nl]].
    pi responseStream: respStream contents readStream.
    ^self sendCommandsFrom: cmdStream contents readStream!

sendCommandFrom: stream 
    | cmd |
    cmd := IMAPCommand readFrom: stream.
    cmd client: pi.
    pi executeCommand: cmd.
    ^cmd!

sendCommandsFrom: aStream 
"Assumption currently is, every command occupies one line. This is because 
IMAPComand>>readFrom reads until end of stream. So we will read command's line
from the stream and feed it to the command as a separate stream.
Answers ordered collection of commands sent"

    |cmds|

    cmds := OrderedCollection new.
    pi connectionStream: (String new: 256) writeStream.
    [aStream atEnd]
        whileFalse: 
            [cmds addLast: (self sendCommandFrom: aStream)].
    ^cmds! !




!IMAPDataResponse class methodsFor: 'testing'!

canParse: responseName

    ^false! !



!IMAPContinuationResponse methodsFor: 'testing'!

isContinuationResponse
    ^true! !



!IMAPAuthenticatedState methodsFor: 'commands'!

append: message to: aMailboxName flags: flags date: dateString 
    | args |
    args := OrderedCollection with: (client canonicalizeMailboxName: aMailboxName).
    flags notNil ifTrue: [args add: flags].
    dateString notNil ifTrue: [args add: #atom -> dateString].
    args add: #literalString -> message.
    ^client executeAndWait: 'append' arguments: args!

create: aMailboxName
    ^client
        execute: 'create'
        arguments: aMailboxName
        changeStateTo: [IMAPSelectedState new]!

delete: aMailboxName
    ^client executeAndWait: 'delete' arguments: aMailboxName!

examine: aMailBoxName 
    ^client
        execute: 'examine'
        arguments: aMailBoxName
        changeStateTo: [IMAPSelectedState new]!

list: refName mailbox: name
    ^client executeAndWait: 'list' arguments: (Array with: refName with: name)!

lsub: refName mailbox: name
    ^client executeAndWait: 'lsub' arguments: (Array with: refName with: name)!

rename: oldMailBox newName: newMailBox 
    ^client executeAndWait: 'rename' arguments: (Array with: oldMailBox with: newMailBox)!

select: aMailBoxName
    ^client
        execute: 'select'
        arguments: aMailBoxName
        changeStateTo: [IMAPSelectedState new]!

status: aMailBoxNameWithArguments

    ^client
        executeAndWait: 'status'
        arguments: aMailBoxNameWithArguments.

"        arguments: (Array with: aMailBoxNameWithArguments)"!

subscribe: aMailBoxName
    ^client executeAndWait: 'subscribe' arguments: (Array with: aMailBoxName)!

unsubscribe: aMailBoxName
    ^client executeAndWait: 'unsubscribe' arguments: (Array with: aMailBoxName)! !

!IMAPAuthenticatedState methodsFor: 'obsolete'!

create: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'create' arguments: aList) completedSuccessfully
        ifTrue: 
            [aClient state: IMAPSelectedState new.
            command]
        ifFalse: [false]!

delete: aClient arguments: aList 
    | command |
    ^(command := aClient executeAndWait: 'delete' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

examine: aClient arguments: aList 
    | command |
    ^(command := aClient executeAndWait: 'examine' arguments: aList) completedSuccessfully
        ifTrue: 
            [aClient state: IMAPSelectedState new.
            command]
        ifFalse: [nil]!

list: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'list' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

lsub: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'lsub' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

rename: aClient arguments: aList 
    | command |
    ^(command := aClient executeAndWait: 'rename' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

select: aClient arguments: aList
    | command |

    ^(command := aClient executeAndWait: 'select' 
                            arguments: aList)                  
        completedSuccessfully
            ifTrue: [  aClient state: IMAPSelectedState new. command ]
            ifFalse: [ nil ]!

subscribe: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'subscribe' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

unsubscribe: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'unsubscribe' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]! !

!IMAPAuthenticatedState methodsFor: 'testing'!

isAuthenticated

    ^true! !




!IMAPStatusResponse class methodsFor: 'testing'!

canParse: commandOrConditionName

    ^#('OK' 'NO' 'BAD' 'BYE') includes: commandOrConditionName! !

!IMAPStatusResponse methodsFor: 'accessing'!

status
    ^status!

status: aStatus

    status := aStatus!

text
    ^text! !

!IMAPStatusResponse methodsFor: 'parsing, general'!

parse: scanner 

    | val key |

    scanner skipWhiteSpace.

    (scanner peekFor: $[ )
        ifTrue: [
            self value: OrderedCollection new.
            scanner flagBracketSpecial: true.
            key := scanner nextToken asUppercase.
            (#('UIDVALIDITY' 'UNSEEN') includes: key) ifTrue: [ val := scanner nextToken asNumber ].
            'PERMANENTFLAGS' = key ifTrue: [ val := scanner deepNextToken ].
            'NEWNAME' = key ifTrue: [ |old new|
                old := scanner nextToken.
                new := scanner nextToken.
                val := Array with: old with: new ].
            [
                (scanner nextToken ~~ $]) and: [ scanner tokenType ~= #doIt ]
                ] whileTrue.

            scanner flagBracketSpecial: false.

        ].

    text := scanner scanText.

    (#('ALERT' 'PARSE' 'TRYCREATE' 'READ-ONLY' 'READ-WRITE') includes: key)
        ifTrue: [ val := text ].

    self value: (key->val)!

parse: scanner with: commandConditionOrStatusName

    self cmdName: commandConditionOrStatusName.
    self status: commandConditionOrStatusName.

    self parse: scanner! !

!IMAPStatusResponse methodsFor: 'testing, imap'!

isBad

    ^self status = 'BAD'!

isNotAccepted

    ^self status = 'NO'!

isOK

    ^self status = 'OK'! !

!IMAPStatusResponse methodsFor: 'testing, response type'!

isStatusResponse

    ^true! !




!IMAPResponseTest methodsFor: 'Testing'!

testFetch
    | scanner resp str |
    str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
    scanner := IMAPScanner on: str readStream. 
    resp := IMAPResponse parse: scanner.
    self assert: (resp isKindOf: IMAPDataResponseFetch).
    self assert: resp cmdName = 'FETCH'.
    self assert: resp messageNumber = '12'.
    self assert: (resp bodyFetch parts isKindOf: SequenceableCollection).
    self assert: (resp bodyFetch parts allSatisfy: [ :each | each sectionSpec specName = 'HEADER'])!

testResponseHandling
    | command str |
    command := IMAPCommand new sequenceID: 'a_1'; name: 'FETCH'; yourself.
    command client: IMAPProtocolInterpreter new.
    [command value] fork.
    self assert: (command handle: (IMAPResponse readFrom: ('* FLAGS (\Seen \Answered \Deleted)' readStream))) not.
    self assert: (command handle: (IMAPResponse readFrom: ('a_2 OK bla' readStream))) not.
    self assert: command isDone not.

    str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
    self assert: (command handle: (IMAPResponse readFrom: str readStream)).
    self assert: (command handle: (IMAPResponse readFrom: ('a_1 OK FETCH completed' readStream))).
    self assert: command isDone.
    self assert: command completionResponse status = 'OK'.
    self assert: command promise hasValue!

testTaggedMessages
    | scanner resp |
    scanner := IMAPScanner on: 'oasis_1 OK LOGIN completed' readStream.
    resp := IMAPResponse parse: scanner.
    self assert: (resp isKindOf: IMAPResponseTagged).
    self assert: resp tag = 'oasis_1'.
    self assert: resp status = 'OK'.
    self assert: resp text = 'LOGIN completed'!

testUnTaggedMessages
    | scanner resp |
    scanner := IMAPScanner on: '* FLAGS (\Seen \Answered \Deleted)' readStream. 
    resp := IMAPResponse parse: scanner.
    self assert: resp cmdName = 'FLAGS'.
    self assert: resp value first = #('\Seen' '\Answered' '\Deleted')! !




!IMAPTest methodsFor: 'Running'!

login

    "establish a socket connection to the IMAP server and log me in"
    client := IMAPClient loginToHost:  'SKIPPER' asUser: 'itktest' withPassword: 'Cincom*062000'.         
    self assert: (client isKindOf: IMAPClient)!

logout

    client logout! !

!IMAPTest methodsFor: 'Testing'!

testAppend
    | message |
    self login.
    message :=
'Date: Mon, 7 Feb 1994 21:52:25 -0800 (PST)
From: Fred Foobar <foobar@Blurdybloop.COM>
Subject: afternoon meeting
To: mooch@owatagu.siam.edu
Message-Id: <B27397-0100000@Blurdybloop.COM>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

Hello Joe, do you think we can meet at 3:30 tomorrow?'.

    client append: message to: 'inbox'.
    self logout!

testCreateRenameDelete
    | comm box box1 |

    box := 'mybox'.
    box1 := 'myBoxRenamed'.
    self login.
    [comm := client create: box.
    self assert: (comm isKindOf: IMAPCommand).
    self assert: comm completedSuccessfully.
    comm := client rename: box newName: box1.
    self assert: (comm isKindOf: IMAPCommand).
    self assert: comm completedSuccessfully]
        ensure: 
            [client delete: box1. self logout]!

testExamine
    | box comm |    
    self login.
    box := 'inbox'.
    comm := client examine: box.
    self assert: (comm isKindOf: IMAPCommand).
    self assert: (comm completedSuccessfully).
    self logout!

testList
    | box comm |    
"    box := nil.
    box isNil ifTrue:[ ^nil].
"
    self login.
    [
        box := 'news/mail/box' asString.
        comm := client create: box.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).
        comm := client list: 'news/'  mailbox: 'mail/*' .
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).
        self assert: (comm responses first mbName asUppercase = box asUppercase).
    ] ensure: [
        comm := client delete: box.
    ].
    self logout!

testNoopCapability
    | comm |
    self login.
    comm := client noop.
    self assert: (comm isKindOf: IMAPCommand).
    self assert: (comm completedSuccessfully).
    comm := client capability.
    self assert: (comm isKindOf: IMAPCommand).
    self assert: (comm completedSuccessfully).
    self logout!

testSelectCheck
    | box comm |    
"    box := nil.
    box isNil ifTrue:[ ^nil].
"
    self login.
    [
        box := 'news/mail/box' asString.
        comm := client create: box.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

        comm := client select: box. 
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).
    
        comm := client check.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

    ] ensure: [
        comm := client delete: box.
    ]!

testSelectClose
    | box comm |    
"    box := nil.
    box isNil ifTrue:[ ^nil].
"
    self login.
    [
        box := 'news/mail/box' asString.
        comm := client create: box.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

        comm := client select: box. 
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).
    
        comm := client close.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

    ] ensure: [
        comm := client delete: box.
    ]!

testSelectExpunge
" Test case doesn't return untagged response: EXPUNGE as expected"
    | box comm |    
"    box := nil.
    box isNil ifTrue:[ ^nil].
"
    self login.
    box := 'inbox' asString. 
        comm := client select: box. 
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

        comm := client expunge.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully)!

testSelectFetch

    | box comm |    
    self login.
    box := 'inbox' asString.
    client select: box.
    comm := client fetch: '2:3 (flags internaldate uid RFC822)'.
    self assert: (comm isKindOf: IMAPCommand).
    self assert: (comm completedSuccessfully).



"    comm := client fetch: '2,4 (flags internaldate uid BODY.PEEK[header])'."
"    client fetch: '1:4 (uid Body.Peek[Header.Fields (Subject Date From Message-Id)])'."
"    client fetch: '1:2 (flags internaldate uid RFC822)'."
"    client fetch: '1 (Body.Peek[header])'."
"    comm := client fetch: '3 (BodyStructure)'."


"    client fetch: '2 full'."
    self logout!

testSelectSearch
    | box   |    

"    box := nil.
    box isNil ifTrue: [ ^box].
"

    self login.
    box := 'inbox' asString.
    client select: box.

    client search: 'undeleted unanswered from "Kogan, Tamara"'.

    self logout!

testSelectStore
"    | box |    

    self login.
    box := 'inbox' asString.
    self assert: ((client select: box) == true).
    (client store: '1:1 +FLAGS (\Deleted)') inspect.
    (client store: '1:1 -FLAGS (\Deleted)') inspect.

    self logout.
"!

testSelectUID
" No expected response    | box |    

    self login.
    box := 'inbox' asString.
    self assert: ((client select: box) == true).
    (client uid: 'fetch 1:1 FLAGS') inspect.
    self logout.
"!

testSubscribeUnsubLSUB
    | box comm |    
    box := nil.
    box isNil ifTrue:[ ^nil].


    self login.
    [
        box := 'news/mail/box' asString.

        comm := client create: box.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

        comm := client subscribe: box.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

        comm := client lsub: 'news/'  mailbox: 'mail/*' .
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).
        self assert: (comm responses first mbName asUppercase = box asUppercase).

        comm := client unsubscribe: box.
        self assert: (comm isKindOf: IMAPCommand).
        self assert: (comm completedSuccessfully).

    ] ensure: [
        comm := client delete: box.
    ].

    self logout! !




!IMAPBodySectionFetchedItem class methodsFor: 'matching'!

canBe: aName

    "
    Can the reciever represent items fetched using the given name?  This is not as straightforward as it ought to be.
    IMAPv4 uses 'BODY' fetches in two very different ways, so we will have to be careful about that.
    For now, we are not making the distinction, so we will have to revisit this in the future.
    Also, note that we don't include 'RFC822.SIZE'.  Such a fetch does not return anything complex- it's actually just a simple metadata fetch.
    "

"    ^#(
        'BODY'
        'BODY.PEEK'
        'RFC822'
        'RFC822.HEADER'
        'RFC822.TEXT'
   ) includes: aName."

    ^false! !

!IMAPBodySectionFetchedItem methodsFor: 'accessing'!

sectionSpec

    ^sectionSpec! !

!IMAPBodySectionFetchedItem methodsFor: 'building'!

extractContentFrom: tokenStream

    "
    For the body parts extraction case, tokens will be something like:
        $[
        'HEADER.FIELDS'
        #('FIELD1' 'FIELD2')
        $]
        '...content as described above...'

    Whereas for the body (structure) case, the tokens will be something like:
        #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')    

    What a screwed up spec.
    "

"devel thought: It might would be good if the reciever could tell what had been requested, and what had been recieved."

    | specTokens |

    specTokens := tokenStream
        upTo: $[ ;
        upTo: $].

    (self sectionSpecificationFrom: specTokens)
        extractContentFrom: tokenStream!

sectionSpecificationFrom: tokens

    ^sectionSpec := IMAPFetchedItemSectionSpecification readFrom: tokens readStream! !

!IMAPBodySectionFetchedItem methodsFor: 'header fields'!

headerFieldNamed: aName ifAbsent: aBlock

"hmm... need a more compex example here."

    self halt! !




!IMAPNonAuthenticatedState methodsFor: 'commands'!

authenticate!

login
    ^client
        execute: 'login'
        arguments: (Array with: client user username with: client user password)
        changeStateTo: [IMAPAuthenticatedState new]! !

!IMAPNonAuthenticatedState methodsFor: 'obsolete'!

login: aClient arguments: aList 
    | command |
    command := aClient executeAndWait: 'login' arguments: aList.
    command completedSuccessfully
        ifTrue: [aClient state: IMAPAuthenticatedState new].
    ^command! !




!IMAPMessageEnvelopeFetchedItem class methodsFor: 'matching'!

canBe: aName

    "
    Can the reciever represent items fetched using the given name?
    Note that we include 'RFC822.SIZE' .
    This is just a simple metadata fetch, unlike such things as 'RFC822' or 'RFC822.HEADER' .
    "

    ^'ENVELOPE'= aName! !

!IMAPMessageEnvelopeFetchedItem methodsFor: 'accessing'!

bccLine

    ^self envelope at: 8!

ccLine

    ^self envelope at: 7!

dateLine

    ^self envelope at: 1!

fromAuthor

    ^(self fromLine at: 1) at: 1!

fromLine

    ^self envelope at: 3!

inReplyToLine

    ^self envelope at: 9!

replyToAuthor

    ^(self replyToLine at: 1) at: 1!

replyToLine

    ^self envelope at: 5!

senderAuthor

    ^(self senderLine at: 1) at: 1!

senderLine

    ^self envelope at: 4!

subjectLine

    ^self envelope at: 2!

toLine

    ^self envelope at: 6!

uniqueMessageIDLine

    ^self envelope at: 10! !

!IMAPMessageEnvelopeFetchedItem methodsFor: 'building'!

extractContentFrom: tokenStream

    "the envelope is an array of message metadata- we'll come back to this for interpretation later."

    self envelope: (tokenStream next)! !

!IMAPMessageEnvelopeFetchedItem methodsFor: 'envelope'!

envelope

    ^envelope!

envelope: anArray

    "We have yet to interpret the contents of the given array... we shall need to get to that later."

    envelope := anArray! !

!IMAPMessageEnvelopeFetchedItem methodsFor: 'printing'!

printDevelOn: aStream indent: level

    aStream
        crtab: level ;
            nextPutAll: 'Date: ' ;
            nextPutAll: self dateLine ;
        crtab: level ;
            nextPutAll: 'Subject: ' ;
            nextPutAll: self subjectLine ;
        crtab: level ;
            nextPutAll: 'From: ' ;
            print: self fromAuthor ;
        crtab: level ;
            nextPutAll: 'Sender: ' ;
            print: self senderAuthor ;
        crtab: level ;
            nextPutAll: 'ReplyTo: ' ;
            print: self replyToAuthor ;
        crtab: level ;
            nextPutAll: 'To: ' ;
            print: self toLine ;
        crtab: level ;
            nextPutAll: 'In Reply To: ' ;
            print: self inReplyToLine ;
        crtab: level ;
            nextPutAll: 'Message ID: ' ;
            nextPutAll: self uniqueMessageIDLine ;
        crtab: level ;
            nextPutAll: 'Bcc: ' ;
            print: self bccLine ; 
        crtab: level ;
            nextPutAll: 'Cc: ' ;
            print: self ccLine ; 
        yourself!

printOn: aStream

    self printDevelOn: aStream indent: 0! !




!IMAPBodyRFC822FetchedItem class methodsFor: 'matching'!

canBe: aName

    "
    Note that we don't include 'RFC822.SIZE'.
    Such a fetch does not return anything complex- it's actually just a simple metadata fetch.
    "

    ^#(
        'RFC822'
        'RFC822.HEADER'
        'RFC822.TEXT'
   ) includes: aName! !

!IMAPBodyRFC822FetchedItem methodsFor: 'building'!

extractContentFrom: tokenStream

    "
    Cases:
        RFC822
        RFC822.Header
        RFC822.Text
    "

     value := tokenStream next! !




!IMAPMessageMetadataFetchedItem class methodsFor: 'matching'!

canBe: aName

    "
    Can the reciever represent items fetched using the given name?
    Note that we include 'RFC822.SIZE' .
    This is just a simple metadata fetch, unlike such things as 'RFC822' or 'RFC822.HEADER' .
    "

    ^#(
        'FLAGS'
        'INTERNALDATE'
        'RFC822.SIZE'
        'UID'
   ) includes: aName! !

!IMAPMessageMetadataFetchedItem methodsFor: 'building'!

extractContentFrom: tokenStream

    self value: (tokenStream next)! !

!IMAPMessageMetadataFetchedItem methodsFor: 'value'!

value

    ^value!

value: anObject

    value := anObject! !




!IMAPFetchedItemHeaderSectionSpecification class methodsFor: 'matching'!

canBe: aName

    ^'HEADER*'
        match: aName
        ignoreCase: true! !




!IMAPBodyStructureFetchedItem class methodsFor: 'matching'!

canBe: aName

    ^'BODYSTRUCTURE' = aName! !

!IMAPBodyStructureFetchedItem methodsFor: 'accessing'!

structure

    ^structure!

structure: aStructure

    structure := aStructure! !

!IMAPBodyStructureFetchedItem methodsFor: 'building'!

extractContentFrom: tokenStream

    "
    The structure will be something like:
        #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
    "

    self structure: tokenStream next! !




!IMAPScannerTest methodsFor: 'running'!

setUp
    parser := IMAPScanner new!

stream6
    | str |

    str := (String new: 512) writeStream.
    str nextPutAll: '* 12 FETCH (FLAGS (\Seen) INTERNALDATE "17-Jul-1996 02:44:25 -0700"
 RFC822.SIZE 4286 ENVELOPE ("Wed, 17 Jul 1996 02:23:25 -0700 (PDT)"
 "IMAP4rev1 WG mtg summary and minutes"
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 ((NIL NIL "imap" "cac.washington.edu"))
 ((NIL NIL "minutes" "CNRI.Reston.VA.US")
 ("John Klensin" NIL "KLENSIN" "INFOODS.MIT.EDU")) NIL NIL
 "<B27397-0100000@cac.washington.edu>")
  BODY ("TEXT" "PLAIN" ("CHARSET" "US-ASCII") NIL NIL "7BIT" 3028 92))
'; nl.
    ^str! !

!IMAPScannerTest methodsFor: 'testing'!

testDeepTokenize
    | tokens |
    tokens := parser on:  '* FLAGS (\Seen \Answered \Flagged \Deleted XDraft)' readStream; deepTokenize.
    self assert: tokens = #($* 'FLAGS' #('\Seen' '\Answered' '\Flagged' '\Deleted' 'XDraft')).
    self assert: parser atEnd!

testDeepTokenize1
    | tokens |
    tokens := parser on:  '(BODYSTRUCTURE (("TEXT" "PLAIN" ("charset" "iso-8859-1") NIL nil "QUOTED-PRINTABLE" 7 2 NIL NIL NIL)("APPLICATION" "OCTET-STREAM" ("name" "StoreErrorDialog.st") NiL NIL "BASE64" 4176 NIL NIL NIL) "mixed" ("boundary" "=_STAMPed_MAIL_=") NIL NIL))' readStream; deepTokenize.
    self assert: tokens = #(#('BODYSTRUCTURE' #(#('TEXT' 'PLAIN' #('charset' 'iso-8859-1') nil nil 'QUOTED-PRINTABLE' '7' '2' nil nil nil) #('APPLICATION' 'OCTET-STREAM' #('name' 'StoreErrorDialog.st') nil nil 'BASE64' '4176' nil nil nil) 'mixed' #('boundary' '=_STAMPed_MAIL_=') nil nil))).
    self assert: parser atEnd.

    tokens := parser on:  '(BODYSTRUCTURE (("TEXT" "PLAIN" ("charset" "iso-8859-1") NIL NIL "QUOTED-PRINTABLE" 7 2 NIL NIL NIL)("APPLICATION" "OCTET-STREAM" ("name" "StoreErrorDialog.st") NIL NIL "BASE64" 4176 NIL NIL NIL) "mixed" ("boundary" "=_STAMPed_MAIL_=") NIL NIL))' readStream; deepTokenizeAsAssociation!

testDeepTokenizeAsAssoc
    | tokens str |

    str := '* 12 "FETCH" ((a b nil) BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
    tokens := parser on: str readStream; deepTokenizeAsAssociation.
    self assert: tokens first = (#special->$*).
    self assert: (tokens at: 2) = (#atom->'12').
    self assert: (tokens at: 3) = (#quotedText->'FETCH').
    self assert: (tokens at: 4) = (#parenthesizedList->(Array with: (#parenthesizedList->(Array with: #atom->'a' with: #atom->'b' with: #nil->nil)) with: #atom->'BODY[HEADER]' with: #literalString->
'Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

')).
    self assert: parser atEnd!

testLiteralStrings
    | tokens str |

    str := '* 12 FETCH (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.        " Extra char for every cr -- will be different in external streams "

    tokens := parser on: str readStream; deepTokenize.
    self assert: tokens = #($* '12' 'FETCH' #('BODY[HEADER]' 'Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

')).
    self assert: parser atEnd!

testSourceTrail
    | str trail |

    str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
    parser on: str readStream; sourceTrailOn; deepTokenizeAsAssociation.
    trail := parser sourceTrail.
    self assert: trail = str.
    self assert: parser sourceTrail isNil.
    self assert: parser atEnd!

testTaggedResponses
    |tokens|

    tokens := parser on:  'oasis_3 OK FETCH completed.' readStream; tokenize.
    self assert: tokens = #('oasis_3' 'OK' 'FETCH' 'completed.').
    self assert: parser atEnd! !




!IMAPBodyFetchedItem class methodsFor: 'matching'!

canBe: aName

    "
    Can the reciever represent items fetched using the given name?  This is not as straightforward as it ought to be.
    IMAPv4 uses 'BODY' fetches in two very different ways, so we will have to be careful about that.
    For now, we are not making the distinction, so we will have to revisit this in the future.
    "

    ^#(
        'BODY'
        'BODY.PEEK'
   ) includes: aName! !

!IMAPBodyFetchedItem methodsFor: 'building'!

extractBodySectionContentFrom: tokenStream

    self parts
        add: (IMAPBodySectionFetchedItem new extractContentFrom: tokenStream)!

extractContentFrom: tokenStream

    "
    For the body parts extraction case, tokens will be something like:
        $[
        'HEADER.FIELDS'
        #('FIELD1' 'FIELD2')
        $]
        '...content as described above...'

    Whereas for the body (structure) case, the tokens will be something like:
        #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')    

    What a screwed up spec.
    "

"devel thought: It might would be good if the reciever could tell what had been requested, and what had been recieved."

    "First off, are we talking about a body section fetch, or a short-form body structure fetch? Bastards!!"

    (tokenStream peek = $[ )
        ifTrue: [ self extractBodySectionContentFrom: tokenStream ]
        ifFalse: [ self extractShortFormBodyStructureFrom: tokenStream ]!

extractShortFormBodyStructureFrom: tokenStream

    "
    Whereas for the body (structure) case, the tokens will be something like:
        #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
    "

    self parts
        add: (IMAPBodyStructureFetchedItem new extractContentFrom: tokenStream)! !

!IMAPBodyFetchedItem methodsFor: 'parts'!

parts

    ^parts notNil
        ifTrue: [ parts ]
        ifFalse: [ parts := OrderedCollection new ]! !




!IMAPDataResponseFetch class methodsFor: 'testing'!

canParse: responseName

    ^'FETCH' = responseName

"    ^false"! !

!IMAPDataResponseFetch methodsFor: 'fetchable items'!

bodyFetch

    ^self
        fetchedItemNamed: 'body'
        ifAbsent: [ nil ]!

bodyText

    ^(self fetchedItemNamed: 'body') parts first
        sectionSpec rawContent!

envelope

    ^self
        fetchedItemNamed: 'envelope'
        ifAbsent: [ nil ]!

extractFetchedItemsFrom: tokenStream

    [
    (tokenStream atEnd not) and: [ self fetchableItemNames includes: (tokenStream peek) ]
    ] whileTrue: [
        (self newFetchedItemNamed: (tokenStream next))
            extractContentFrom: tokenStream
        ]!

fetchableItemNames

    ^#(
        'ALL'
        'BODY'        "actually, there are two forms represented by this name- see the spec."
        'BODY.PEEK'
        'BODYSTRUCTURE' 
        'ENVELOPE'
        'FAST'
        'FULL'
        'FLAGS'
        'INTERNALDATE'
        'RFC822'
        'RFC822.HEADER'
        'RFC822.SIZE'
        'RFC822.TEXT'
        'UID'
       )!

fetchedHeaderNamed: aHeaderName ifAbsent: aBlock

    ^self headerFetch
        fieldNamed: aHeaderName
        ifAbsent: [ aBlock value ]!

fetchedItemNamed: aName

    ^self
        fetchedItemNamed: aName
        ifAbsent: [ nil ]!

fetchedItemNamed: aName ifAbsent: aBlock

    | seekName |

    seekName := aName asLowercase.

    ^self fetchedItems
        at: seekName
        ifAbsent: [ aBlock value ]!

fetchedItems

    ^fetchedItems notNil
        ifTrue: [ fetchedItems ]
        ifFalse: [ fetchedItems := Dictionary new ]!

hasUID

    ^self fetchedItems
        includesKey: 'uid'!

hasUniqueMessageID

    ^self hasFetchedItemHaving: 'message-ID'!

itemHolding: anItemName

    ^self fetchedItems
        traverse: [ : eachItem | eachItem ]
        seeking: [ : eachItem | eachItem holds: anItemName ]!

newFetchedItemNamed: aName

    ^self fetchedItems
        at: (aName asLowercase)
        put: (IMAPFetchedItem named: aName)!

rawUniqueMessageID

    "If available, answer the unique message ID as provided within the message's headers."

    ^self bodyFetch
        headerFieldNamed: 'message-ID'
        ifAbsent: [ nil ]!

uid

    "The UID is an item that may or not have been fetched by the reciever."

    | uidRaw |

    uidRaw := self
        fetchedItemNamed: 'UID'
        ifAbsent: [ nil ].

    ^uidRaw notNil
        ifTrue: [ uidRaw value asNumber ]
        ifFalse: [ nil ]! !

!IMAPDataResponseFetch methodsFor: 'message number'!

messageNumber

    ^self sequenceNumber!

messageNumber: aNumber

    self sequenceNumber: aNumber!


messageSequenceNumber

    ^self sequenceNumber!

sequenceNumber

    ^self fetchedItemNamed: 'sequence_number'!

sequenceNumber: aNumber

    ^self fetchedItems
        at: 'sequence_number'
        put: aNumber! !

!IMAPDataResponseFetch methodsFor: 'meta responses'!

metaResponses

    ^metaResponses!

metaResponses: statusResponses

    metaResponses := statusResponses! !

!IMAPDataResponseFetch methodsFor: 'parsing, general'!

parse: scanner

    | tokens |

scanner flagBracketSpecial: true.

    tokens := scanner deepNextToken.

scanner flagBracketSpecial: false.

    self extractFetchedItemsFrom: tokens readStream!

value: aNumber

    self sequenceNumber: (value := aNumber)! !




!IMAPResponseMailboxStatus class methodsFor: 'testing'!

canParse: conditionName

"should be more- I need to check this."

    ^#('UNSEEN' 'EXISTS') includes: conditionName! !

!IMAPResponseMailboxStatus methodsFor: 'parsing, general'!

parse: scanner

self halt.

    super parse: scanner!

parse: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue

    self cmdName: commandOrConditionName.
    self value: codeValue! !




!IMAPResponseTagged class methodsFor: 'parsing, general'!

parse: scanner tag: tag status: status

    ^self new
        parse: scanner
        tag: tag
        status: status!

scanFrom: scanner tag: tag status: status

    ^self new
        scanFrom: scanner tag: tag status: status! !

!IMAPResponseTagged class methodsFor: 'testing'!

canParse: cmdName
    ^false! !

!IMAPResponseTagged methodsFor: 'accessing'!

tag
    ^self cmdName!

text
    ^text! !

!IMAPResponseTagged methodsFor: 'parsing, general'!

parse: scanner tag: tag status: statusString
    self cmdName: tag.
    self status: statusString.

    ^self parse: scanner! !

!IMAPResponseTagged methodsFor: 'testing'!

hasTag: tagString
    ^self tag match: tagString! !




!IMAPDataResponseSearch class methodsFor: 'testing'!

canParse: responseName

    ^'SEARCH' = responseName! !

!IMAPDataResponseSearch methodsFor: 'id sequences'!

basicIDSequences

    | intervals currentStart currentStop currentInterval |

    intervals := OrderedCollection new.

    currentInterval := (-1 -> -1).

    self numericIDs do: [ : eachNumericID |
        (eachNumericID = (currentInterval value + 1))
            ifTrue: [ currentInterval value: eachNumericID ]
            ifFalse: [
                currentStop := currentStart := eachNumericID.
                intervals add: (currentInterval := (currentStart -> currentStop)).
                ]
        ].

    ^intervals collect: [ : eachInterval |
        (eachInterval key = eachInterval value)
            ifTrue: [ eachInterval key printString ]
            ifFalse: [ eachInterval key printString, ':', eachInterval value printString ]
        ]!

idSequences

    "
    This would be a good place to further condense the basic id sequences.
    Currently we offer a series of ranges, but these ranges could be combined, eg:
        #('1:123' '231:321'  etc...)
    could become:
        #('1:123, 231:321' etc...)
    This would reduce the number of fetch requests that would be needed to retrieve the messages identified by the search response.
    "

    ^self basicIDSequences!

numericIDs

    ^self rawIDs collect: [ : eachRawID | eachRawID asNumber ]!

rawIDs

    ^self value! !




!IMAPSelectedState methodsFor: 'commands'!

check
    ^client executeAndWait: 'check'!

close
    ^client
        execute: 'close'
        arguments: nil
        changeStateTo: [IMAPAuthenticatedState new]!

copy!

expunge
    ^client executeAndWait: 'expunge'!

fetch: aCriteria
    ^client executeAndWait: 'fetch' arguments: aCriteria!

fetch: messageNumbers retrieve: criteria 
    | msgString args |
    msgString := client messageSetAsString: messageNumbers.
    args := OrderedCollection with: msgString.
    criteria notNil ifTrue: [criteria isCharacters
            ifTrue: [args add: criteria]
            ifFalse: [args addAll: criteria]].
    ^client executeAndWait: 'fetch' arguments: args!

search: aCriteria
    ^client executeAndWait: 'search' arguments: aCriteria!

store: args
    ^client executeAndWait: 'store' arguments: args!

uid: aString
    ^client executeAndWait: 'uid' arguments: aString! !

!IMAPSelectedState methodsFor: 'obsolete'!

check: aClient
    ^client executeAndWait: 'check'!

close: aClient
    | command |
    ^(command := aClient executeAndWait: 'close') completedSuccessfully
        ifTrue: [aClient state: IMAPAuthenticatedState new. command]
        ifFalse: [nil]!

expunge: aClient
    | command |
    ^(command := aClient executeAndWait: 'expunge') completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

fetch: aClient arguments: aList
    | command   |

    ^(command := aClient executeAndWait: 'fetch' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

search: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'search' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]!

store: aClient arguments: aList
    | command |
    ^(command := aClient executeAndWait: 'store' arguments: aList) completedSuccessfully
        ifTrue: [command]
        ifFalse: [nil]! !

!IMAPSelectedState methodsFor: 'testing'!

isSelected

    ^true! !




!IMAPDataResponseList class methodsFor: 'testing'!

canParse: cmdName
    ^'LIST' = cmdName! !

!IMAPDataResponseList methodsFor: 'accessing'!

mbAttributes
    ^mbAttributes!

mbDelimeter
    ^mbDelimiter!

mbName
    ^mbName! !

!IMAPDataResponseList methodsFor: 'parsing, general'!

parse: scanner
    " Parse message attributes"
    " (\NOSELECT)  '/'  ~/Mail/foo"
    | tokens |

    tokens := scanner deepTokenize.
    mbAttributes := tokens at: 1.
    mbDelimiter := tokens at: 2.
    mbName := tokens at: 3! !




!IMAPScanner class methodsFor: 'character classification'!

atomSpecials
    " These characters cannot occur inside an atom" 
    ^'( ){%*"\'!

specials
    ^self atomSpecials! !

!IMAPScanner class methodsFor: 'class initialization'!

initClassificationTable
    super initClassificationTable.
    self initClassificationTableWith: TextMask when:
        [:c | c ~~ Character cr ].
    self initClassificationTableWith: AtomMask when:
        [:c | c > Character space and: [ (self atomSpecials includes: c) not] ].
    self initClassificationTableWith: QuotedTextMask when:
        [:c | c ~~ $" and: [ c ~~ $\ and: [ c ~~ Character cr ]]]!

initialize
    " IMAPScanner initialize "

    self initializeConstants; initClassificationTable!

initializeConstants
    AtomMask := 256.
    QuotedTextMask := 4096.
    TextMask := 8192! !

!IMAPScanner class methodsFor: 'printing'!

defaultTokenType
    ^#string!

printAtom: atom on: stream 
    atom isNil
        ifTrue: [stream nextPutAll: 'NIL']
        ifFalse: [stream nextPutAll: atom "asUppercase"]!

printIMAPString: value on: stream
    "Print string as either atom or quoted text"

    value isNil ifTrue: [ self printNilOn: stream].
    (self shouldBeQuoted: value)
        ifTrue: [self printQuotedText: value on: stream ]
        ifFalse: [self printAtom: value on: stream]!

printLiteralString: aString on: stream 
    "Note that this method is good for printing but not for sending. 
    IMAP requires sender to send string length, then wait for continuation response"

    self printLiteralStringLength: aString on: stream.
    self printLiteralStringContents: aString on: stream!

printLiteralStringContents: aString on: stream 
    stream nextPutAll: aString!

printLiteralStringLength: aString on: stream 
    stream nextPut: ${.
    aString size printOn: stream.
    stream nextPut: $}; nl!

printNilOn: stream 
    stream nextPutAll: 'NIL'!

printParenthesizedList: arrayOfAssociations on: stream 
    "In order to accurately print parenthesized list, we need to know 
    token types of every element. This is applied recursively"

    stream nextPut: $(.
    self printTokenList: arrayOfAssociations on: stream.
    stream nextPut: $)!

printToken: value tokenType: aSymbol on: stream 
    aSymbol = #string ifTrue: [^self printIMAPString: value on: stream].
    aSymbol = #literalString ifTrue: [^self printLiteralString: value on: stream].
    aSymbol = #atom ifTrue: [^self printAtom: value on: stream].
    aSymbol = #quotedText ifTrue: [^self printQuotedText: value on: stream].
    aSymbol = #nil ifTrue: [^self printNilOn: stream].
    aSymbol = #parenthesizedList ifTrue: [^self printParenthesizedList: value on: stream].    "Invalid token type"
    aSymbol = #special ifTrue: [^stream nextPut: value].
    self halt!

stringAsAssociation: string 
    (self shouldBeQuoted: string) ifFalse: [^#atom -> string].
    (string first == $\ and: 
    [string size > 1 and: 
    [self shouldBeQuoted: (string copyFrom: 2 to: string size) not]])
        ifTrue: [^#atom -> string].
    ^#quotedText -> string!

tokenAsAssociation: token 
    (token isKindOf: Association) ifTrue: [^token].
    token isNil ifTrue: [^'NIL'].
    token isCharacters ifTrue: [^self stringAsAssociation: token].
    (token isKindOf: Number) ifTrue: [^#number -> token].
    token isSequenceable ifTrue: [^#parenthesizedList -> token].
    ^token! !

!IMAPScanner class methodsFor: 'testing'!

isAtomChar: char
    ^((self classificationTable at: char asInteger + 1) bitAnd: AtomMask) ~= 0!

shouldBeQuoted: string
    ^(string detect: [ :char | (self isAtomChar: char) not ] ifNone: [ nil ]) notNil! !

!IMAPScanner methodsFor: 'accessing'!

flagBracketSpecial
    flagBracketSpecial isNil ifTrue: [flagBracketSpecial := false].
    ^flagBracketSpecial!

flagBracketSpecial: aBoolean
    
    flagBracketSpecial := aBoolean! !

!IMAPScanner methodsFor: 'multi-character scans'!

doSpecialScanProcessing
    "Hacks that require special handling of IMAP tokens go here. 
    The most frustrating one for us was handling of message/mailbox flags that have format \<atom> as 
    in \Seen. The problem is that $\ is not an atom-char, so these flags are tokenized as #($\ 'Seen'). 
    We make heuristical decision here if current token is $\ immediately followed by a letter. We will 
    then read next token and merge $\ and next token answering a string. This is ONLY applied inside a 
    parenthesized list"

    (token == $\ and: [(self classificationMaskFor: self peek)
            anyMask: AlphabeticMask])
        ifTrue: 
            [self nextToken.
            token := '\' , token.
            tokenType := #string]!

scanAtom
    "atom = 1*<any CHAR except atom-specials (which includes atomSpecials, space and CTLs)>"

    token := self scanWhile: [(self isBracketSpecial: hereChar) not and: [self matchCharacterType: AtomMask]].
    (token match: 'NIL')
        ifTrue: 
            ["RFC2060 defines NIL as a special atom type, atoms are not case-sensitive"
            token := nil.
            tokenType := #nil]
        ifFalse: [tokenType := #atom].
    ^token!

scanLiteralText
    "<{> nnn <}> <CRLF> <nnn bytes>"

    | nbytes string |
    nbytes := self scanLiteralTextLength.
    string := self nextBytesAsString: nbytes.
    token := string copyReplaceAll: (String with: Character cr with: Character nl) with: (String with: Character nl).
    tokenType := #literalString.
    ^token!

scanLiteralTextLength
    "<{> nnn <}> <CRLF>"

    " We are positioned at the first brace character "
    token := self scanToken: [ self matchCharacterType: DigitMask ] delimitedBy: '{}' notify: 'Malformed literal length'.
    self upTo: Character nl.
    ^Integer readFrom: token readStream!

scanParenthesizedList

    | stream |

    stream := (Array new: 4) writeStream.

    self mustMatch: $(notify: 'Parenthesized list should begin with ('.

    self
        deepTokenizeUntil: [ token == $) ]
        do: [
            self doSpecialScanProcessing.
            stream nextPut: token
            ].

    token ~~ $) ifTrue: [self notify: 'Non-terminated parenthesized list'].

    token := stream contents.
    tokenType := #parenthesizedList.
    ^token!

scanParenthesizedListAsAssociation
    | stream |
    stream := (Array new: 4) writeStream.
    self mustMatch: $(notify: 'Parenthesized list should begin with ('.
    self deepTokenizeAsAssociationUntil: [token == $)] 
        do: [:assoc | self doSpecialScanProcessing. stream nextPut: (tokenType->token)].
    token ~~ $) ifTrue: [self notify: 'Non-terminated parenthesized list'].
    token := stream contents.
    tokenType := #parenthesizedList.
    ^tokenType->token!

scanQuotedChar
    "Scan possible quoted character. If the current char is $\, read in next character and make it a quoted 
    string character"

    ^(hereChar == $\)
        ifTrue: 
            [self step.
            classificationMask := QuotedTextMask.
            true]
        ifFalse: [false]!

scanQuotedText
" quoted-string = <""> *(quoted_char / quoted-pair) <"">
  quoted_char    =  <any CHAR except <""> and <\>"

    " We are positioned at the first double quote character "
    token := self scanToken: [ self scanQuotedChar; matchCharacterType: QuotedTextMask ] delimitedBy: '""' notify: 'Unmatched quoted text'.
    tokenType := #quotedText.
    ^token!

scanText
    "RFC822: text = <Any CHAR, including bare CR & bare LF, but not including CRLF. This is a 'catchall' category and cannot be tokenized. Text is used only to read values of unstructured fields"

    ^self 
        skipWhiteSpace; 
        scanWhile: [ (self matchCharacterType: CRLFMask) not ]! !

!IMAPScanner methodsFor: 'printing'!

printLiteralString: aString on: stream
    self class printLiteralStringLength: aString on: stream.
    self class printLiteralStringContents: aString on: stream! !

!IMAPScanner methodsFor: 'private'!

isBracketSpecial: char

    ^self flagBracketSpecial
        and: [ '[]' includes: char ]!

nextBytesAsString: nbytes 
    | str |
    ^source isExternalStream
        ifTrue: [
            [self binary.
            str := (source next: nbytes) asString.
            self sourceTrailNextPutAll: str.
            str]
                ensure: [self text]]
        ifFalse: [super next: nbytes]!

nextIMAPToken

    | char |

    self skipWhiteSpace.
    char := self peek.

    char isNil                "end of input"
        ifTrue: [tokenType := #doIt.
            ^token := nil].
    char == $" ifTrue: [^self scanQuotedText].
    char == ${ ifTrue: [^self scanLiteralText].

    ((char < Character space) or: [(self specials includes: char) or: [self isBracketSpecial: char]])
        ifTrue: [
            "Special character. Make it token value and set token type "
            tokenType := #special.
            token := self next.
	    ^token
        ].

    (self matchCharacterType: AtomMask)
        ifTrue: [^self scanAtom].

    tokenType := #doIt.
    token := char.

    ^token! !

!IMAPScanner methodsFor: 'tokenization'!

deepNextToken

    ^(self nextToken == $( )
        ifTrue: [
            self
                stepBack ;
                scanParenthesizedList
            ]
        ifFalse: [ token ]!

deepNextTokenAsAssociation
    ^self nextToken == $(
        ifTrue: [self stepBack; scanParenthesizedListAsAssociation]
        ifFalse: [tokenType->token]!

deepTokenize
    | stream |
    stream := (Array new: 4) writeStream.
    
    [self deepNextToken.
    tokenType = #doIt or: [token == Character cr or: [token == Character nl]]]
        whileFalse: [stream nextPut: token].
    token == Character cr ifTrue: [ self stepBack ].
    token == Character nl ifTrue: [ self stepBack ].
    ^stream contents!

deepTokenizeAsAssociation
    | stream assoc |
    stream := (Array new: 4) writeStream.
    
    [assoc := self deepNextTokenAsAssociation.
    assoc key = #doIt]
        whileFalse: [stream nextPut: assoc].
    ^stream contents!

deepTokenizeAsAssociationUntil: aBlock do: actionBlock 
    | assoc |
    
    [self skipWhiteSpace.
    assoc := self deepNextTokenAsAssociation.
    assoc key = #doIt or: aBlock]
        whileFalse: [actionBlock value: assoc]!

deepTokenizeUntil: aBlock do: actionBlock

    [
        self
            skipWhiteSpace ;
            deepNextToken.

        (tokenType == #doIt) or: aBlock
    ] whileFalse: [ actionBlock value ]!

nextToken
        ^self nextIMAPToken!

specials
        ^self class atomSpecials! !

!IMAPDataResponseLSub class methodsFor: 'testing'!

canParse: cmdName
        ^'LSUB' = cmdName! !

IMAPCommand initialize!
IMAPScanner initialize!

Namespace current: NetClients!
