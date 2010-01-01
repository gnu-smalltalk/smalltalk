"======================================================================
|
|   GNU Smalltalk remote control script
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Mike Anderson.
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
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

PackageLoader fileInPackage: 'TCP'.
DLD addLibrary: 'libc'.

(CFunctionDescriptor isFunction: 'getpid')
    ifTrue: [
        SystemDictionary compile: '
            getpid [ <cCall: ''getpid'' returning: #int args: #()> ]' ]
    ifFalse: [
        SystemDictionary compile: '
            getpid [ ^''--pid not available'' ]' ].

TextCollector subclass: MultiplexingTextCollector [
    | default outputs |
    initialize [
	outputs := LookupTable new.
	super initialize
    ]

    register: aStream [
	semaphore critical: [ outputs at: Processor activeProcess put: aStream ]
    ]

    unregister [
	semaphore critical: [
	    outputs removeKey: Processor activeProcess ifAbsent: [] ]
    ]

    primNextPutAll: aString [
        | dest |
        dest := outputs at: Processor activeProcess ifAbsent: [ nil ].
	dest isNil
	    ifFalse: [
		[ dest nextPutAllFlush: aString ]
		    ifCurtailed: [
			self unregister.
			Processor activeProcess terminate ] ]

	    ifTrue: [ super primNextPutAll: aString ].
    ]
]

| helpString commands server port host login |
commands := OrderedCollection new.
server := false.
port := 12345.
host := nil.
login := nil.

helpString :=
'Usage:
    gst-remote [ flag ... ] [user@]host

Options:
       --daemon               start background server
       --server               start daemon
    -p --port=PORT            connect/listen on given port (default 12345)
    -f --file=FILE            file in FILE
    -e --eval=CODE            evaluate CODE
    -l --login=USER           use remote ssh connection
       --kill                 kill daemon
       --snapshot[=FILE]      save image
       --package=PACKAGE      load package
       --start=PACKAGE[:DATA] load package and start it (defined in package.xml)
       --stop=PACKAGE[:DATA]  load package and stop it (defined in package.xml)
       --pid                  print daemon pid
    -h --help                 show this message
       --version              print version information and exit

If a remote login name is given, gst-remote will use the SSH environment
variable (if present) to launch commands remotely.  Netcat (nc) should be
available in the PATH of the remote machine.

'.

"Parse the command-line arguments."
[Smalltalk
    arguments: '-h|--help --version --daemon --server -p|--port: -f|--file:
		-e|--eval: --pid --kill --snapshot:: --start: --stop:
		-l|--login: --package: -I|--image: --kernel-directory:'
    do: [ :opt :arg |

    opt = 'help' ifTrue: [
	helpString displayOn: stdout.
	ObjectMemory quit: 0 ].

    opt = 'version' ifTrue: [
	('gst-remote - %1' % {Smalltalk version}) displayNl.
	ObjectMemory quit: 0 ].

    opt = 'login' ifTrue: [
	login isNil ifFalse: [ self error: 'multiple logins are invalid' ].
	login := arg ].

    opt = 'daemon' ifTrue: [
	server := true ].

    opt = 'server' ifTrue: [
	server := true ].

    opt = 'port' ifTrue: [
	port := arg asInteger ].

    opt = 'start' ifTrue: [
	| package data |
	package := arg copyUpTo: $:.
	package = arg
	    ifTrue: [
		commands add: '(PackageLoader packageAt: %1) start'
				% {package storeString} ]
	    ifFalse: [
		commands add: '(PackageLoader packageAt: %1) start: %2'
				% {package storeString. (arg copyAfter: $:) storeString } ] ].

    opt = 'stop' ifTrue: [
	| package data |
	package := arg copyUpTo: $:.
	package = arg
	    ifTrue: [
		commands add: '(PackageLoader packageAt: %1) stop'
				% {package storeString} ]
	    ifFalse: [
		commands add: '(PackageLoader packageAt: %1) stop: %2'
				% {package storeString. (arg copyAfter: $:) storeString } ] ].

    opt = 'file' ifTrue: [
	commands add: (File name: arg) ].

    opt = 'package' ifTrue: [
	commands add: 'PackageLoader fileInPackage: %1' % {arg storeString} ].

    opt = 'eval' ifTrue: [
	commands add: arg ].

    opt = 'pid' ifTrue: [
	commands add: 'Smalltalk getpid displayNl' ].

    opt = 'kill' ifTrue: [
	commands add: 'Transcript nextPut: $<0>. ObjectMemory quit: 0' ].

    opt = 'snapshot' ifTrue: [
	arg isNil
	    ifTrue: [ commands add: 'ObjectMemory snapshot' ]
	    ifFalse: [ commands add: 'ObjectMemory snapshot: ',
			     (Directory working / arg) name storeString ] ].

    opt isNil ifTrue: [
	host isNil ifFalse: [ self error: 'multiple hosts are invalid' ].
	(arg includes: $@)
	    ifFalse: [ host := arg ]
	    ifTrue: [
		login isNil ifFalse: [ self error: 'multiple logins are invalid' ].
		login := arg copyUpTo: $@.
		host := arg copyAfter: $@ ] ].
    ]

    ifError: [
        helpString displayOn: stderr.
        ObjectMemory quit: 1 ].
]
    on: Error do: [ :ex |
        ('gst-remote: ', ex messageText, '
') displayOn: stderr.
	stderr flush.
	helpString displayOn: stderr.
	ObjectMemory quit: 1 ].

server ifTrue: [
    PackageLoader fileInPackage: 'Compiler'.
    Transcript := MultiplexingTextCollector message: Transcript message.
    [
	| queue |
	queue := TCP.ServerSocket port: port bindTo: host.
	[
	    [
		| conn |
		[
		    queue waitForConnection.
		    (conn := queue accept) isNil
		] whileTrue: [
		    queue isOpen ifFalse: [ Processor activeProcess terminate ].
		    Processor yield
		].
		[
		    [[
			Transcript register: conn.
		        [ conn isPeerAlive ] whileTrue: [
			    Behavior
			        evaluate: (conn upTo: $<0>)
			        to: nil
			        ifError: [ :fname :line :msg |
				    conn nextPutAll: ('gst-remote: error at line %1: %2
' % { line. msg }) ].
			    conn nextPut: $<0>; flush ] ]
			on: Error
			do: [ :ex | ex return ]]

			    ensure: [
				Transcript unregister.
				conn close ]
		] fork
	    ] repeat
	]
	    on: Error
	    do: [ :ex |
		('gst-remote server: ', ex messageText, '
') displayOn: stderr.
		ex pass.
		ObjectMemory quit: 1 ].
    ] fork.
    Transcript nextPutAll: 'gst-remote server started.'; nl ].

[
    commands isEmpty ifFalse: [
	s := (login isNil or: [ host isNil ])
	    ifTrue: [
	        host isNil ifTrue: [ host := TCP.IPAddress anyLocalAddress ].
	        TCP.Socket remote: host port: port ]
	    ifFalse: [
		FileStream
		    popen: '%1 %2@%3 nc localhost %4' % {
			(Smalltalk getenv: 'SSH') ifNil: [ 'ssh' ].
			login. host. port}
		    dir: 'r+' ].

	commands do: [ :each |
	    "Using #readStream makes it work both for Strings and Files."
	    s nextPutAll: each readStream; nextPut: $<0>; flush.

	    [ s peekFor: $<0> ] whileFalse: [
		stdout nextPut: s next.
		s canRead ifFalse: [ stdout flush ] ] ].
	s close ]
]
    on: Error
    do: [ :ex || msg |
	stdout flush.
	msg := (s notNil and: [ s isPeerAlive not ])
	    ifTrue: [ 'server unavailable' ]
	    ifFalse: [ ex messageText ].

        ('gst-remote: ', msg, '
') displayOn: stderr.
	stderr flush.
	s isNil ifFalse: [ s close ].
        "ex pass."
	server ifFalse: [ ObjectMemory quit: 1 ] ].

server
    ifTrue: [ Processor activeProcess suspend ]
    ifFalse: [ ObjectMemory quit ]
