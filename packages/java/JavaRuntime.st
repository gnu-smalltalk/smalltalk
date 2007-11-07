"======================================================================
|
|   Java run-time support.  Everything except native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #JavaObject
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

JavaObject class instanceVariableNames: 'javaClass javaLangClass initialized '!

JavaObject comment: '
The JavaObject class is the superclass of Java objects.
java.lang.Object is a subclass of JavaObject, which defines some
methods called back by the translated bytecodes.

'!

Object subclass: #JavaMonitor
	instanceVariableNames: 'semaphore process count waitSemaphores '
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

JavaMonitor class
	instanceVariableNames: 'monitors mutex lastMonitor lastObject'!

ArrayedCollection variable: #int8 subclass: #JavaByteArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #short subclass: #JavaShortArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #ushort subclass: #JavaCharArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #float subclass: #JavaFloatArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #double subclass: #JavaDoubleArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #int subclass: #JavaIntArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #int64 subclass: #JavaLongArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

MethodInfo variableSubclass: #JavaMethodInfo
    instanceVariableNames: 'javaMethod '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

CompiledMethod variableByteSubclass: #JavaCompiledMethod
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

CompiledMethod subclass: #JavaSynchronizedMethodWrapper
    instanceVariableNames: 'wrappedMethod '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

CompiledMethod subclass: #JavaUntranslatedMethod
    instanceVariableNames: 'javaMethod '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

JavaUntranslatedMethod comment: '
JavaUntranslatedMethod is a placeholder that triggers translation of
the Java bytecodes the first time the method is invoked.

Instance Variables:
    javaMethod	<Object>	description of javaMethod

'!

Error subclass: #JavaException
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!


FileDescriptor subclass: #JavaFileDescriptor
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!


Object subclass: #JavaVM
    instanceVariableNames: 'instVar1 instVar2 instVar3 instVar4'
    classVariableNames: 'IntClass ByteClass ShortClass
	LongClass FloatClass DoubleClass VoidClass BooleanClass
	CharClass Bootstrapped

	OpenFileTable

	TopGroup MainGroup MainThread
	JoinMutex JoinedThreads ThreadAccessMutex Threads'
    poolDictionaries: ''
    category: 'Java-Runtime'!

JavaVM comment: '
JavaVM is a single huge class that includes all the native methods in the
Java-on-Smalltalk virtual machine implementation.

The methods are on the instance side for ease of browsing, but they are
actually swizzled to other classes when the system bootstraps, according
to their <javaNativeMethod: ... for: ...> attribute.  Their state must
be kept entirely with class variables, so that it can be accessed globally.'!

!JavaMonitor class methodsFor: 'initialization'!

initialize
    mutex := Semaphore forMutualExclusion.
    monitors := WeakKeyIdentityDictionary new!

!JavaMonitor class methodsFor: 'private'!

delayProcessFor: mils semaphore: s
    ^[
        (Delay forMilliseconds: mils) wait.
        s signal.
	Processor activeProcess suspend ]!

monitorFor: anObject
    "Retrieve the monitor for anObject, without locking Mutex (the sender
     should take care of locking it).  We cache the last monitor, because
     the cache hits in two very common cases: 1) a synchronized method 
     calls another synchronized method on the same object, and 2) in the
     sequential case, there are no thread switches (and accesses to monitors)
     between the time the monitor is entered and the time the monitor is
     exited."

    lastObject == anObject ifTrue: [ ^lastMonitor ].

    lastObject := anObject.
    lastMonitor := monitors at: anObject ifAbsent: [ nil ].
    ^lastMonitor isNil
	ifFalse: [ lastMonitor ]
	ifTrue: [ monitors at: anObject put: (lastMonitor := self new)]! !

!JavaMonitor class methodsFor: 'locking'!

enter: anObject
    "Of course, we wait on the monitor *after* relinquishing the mutex."
    | monitor |
    mutex wait.
    monitor := self monitorFor: anObject.
    mutex signal.
    monitor wait!

exit: anObject
    "Note that we signal the monitor *before* relinquishing the mutex."
    mutex wait.
    (self monitorFor: anObject) signal.
    mutex signal!

notifyAll: anObject
    mutex wait.
    (self monitorFor: anObject) notifyAll.
    mutex signal!

notify: anObject
    mutex wait.
    (self monitorFor: anObject) notify.
    mutex signal!

waitOn: anObject timeout: msec
    | monitor count process waitSemaphores sema |
    "Note that we unlock the monitor *before* relinquishing the mutex."
    sema := Semaphore new.

    "Grab the monitor, unlock it and register the semaphore we'll wait on."
    mutex wait.
    monitor := (self monitorFor: anObject).
    count := monitor unlock.
    waitSemaphores := monitor waitSemaphores.
    waitSemaphores addLast: sema.
    mutex signal.

    "If there's a timeout, start a process to exit the wait anticipatedly."
    msec > 0 ifTrue: [
	process := (self delayProcessFor: msec semaphore: sema) fork ].

    sema wait.

    "Also if there's a timeout, ensure that the semaphore is removed from
     the list.  If there's no timeout we do not even need to reacquire the
     monitor afterwards (see also #exit:, which waits after getting the
     monitor and relinquishing the mutex)."
    process notNil ifTrue: [
        mutex wait.
        waitSemaphores remove: sema ifAbsent: [].
        process terminate.
        mutex signal ].

    monitor lock: count!

!JavaMonitor class methodsFor: 'instance creation'!

new
    ^super new initialize!

!JavaMonitor methodsFor: 'initialize-release'!

initialize
    count := 0.
    semaphore := Semaphore forMutualExclusion! !

!JavaMonitor methodsFor: 'accessing'!

waitSemaphores
    waitSemaphores isNil ifTrue: [ waitSemaphores := OrderedCollection new ].
    ^waitSemaphores! !

!JavaMonitor methodsFor: 'control'!

notifyAll
    process == Processor activeProcess
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalThreadStateException ].

    waitSemaphores isNil ifTrue: [ ^self ].
    waitSemaphores size timesRepeat: [ waitSemaphores removeFirst signal ]!

notify
    process == Processor activeProcess
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalThreadStateException ].

    waitSemaphores isNil ifTrue: [ ^self ].
    waitSemaphores isEmpty ifFalse: [ waitSemaphores removeFirst signal ]!

unlock
    | oldCount |
    process == Processor activeProcess
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalThreadStateException ].

    oldCount := count.
    count := 0.
    process := nil.
    semaphore signal.
    ^oldCount!

lock: saveCount
    | activeProcess |
    activeProcess := Processor activeProcess.
    process == activeProcess
	ifFalse: [
	    semaphore wait.
	    process := activeProcess ].
    count := count + saveCount!
    
signal
    (count := count - 1) == 0
	ifTrue: [ process := nil. semaphore signal ]!

wait
    | activeProcess |
    activeProcess := Processor activeProcess.
    process == activeProcess
	ifFalse: [
	    semaphore wait.
	    process := activeProcess ].
    count := count + 1! !

!JavaObject class methodsFor: 'message sending'!

convertArgsToJava: argArray withSignature: argSignature
    "given a smalltalk argument array, convert to java objects as appropriate.
     Currently, only Strings and booleans are converted."

    ^argArray with: argSignature collect: [:arg :type |
        self convertToJava: arg type: type ].
!

check: args against: signature
    | arg type goodness |
    goodness := 100.
    1 to: args size do: [ :i |
	arg := args at: i.
	type := signature at: i.
	goodness := goodness min: (self goodnessOfMapping: arg to: type).
    ].
    ^goodness
!

convertToJava: arg type: type
    ^self
	convertToJava: arg
	type: type
	ifFail: [ self error: 'invalid argument' ]
!

goodnessOfMapping: arg to: type
    "Given a Smalltalk argument, check if it belongs to the
     correct Java type and convert as appropriate."

    type == JavaPrimitiveType boolean ifTrue:[
        arg == true ifTrue: [ ^5 ].
	arg == false ifTrue: [ ^5 ].
        ^0
    ].
    type == JavaPrimitiveType int ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000 and:16r7FFFFFFF ]) ifTrue:[ ^4 ].
        ].
        ^0
    ].
    type == JavaPrimitiveType long ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000_00000000 and:16r7FFFFFFF_FFFFFFFF ])
		    ifTrue:[ ^3 ].
        ].
        ^0
    ].
    type == JavaPrimitiveType float ifTrue:[
        arg isFloat ifTrue: [ ^2 ].
        ^0
    ].
    type == JavaPrimitiveType double ifTrue:[
        arg isFloat ifTrue: [ ^1 ].
        ^0
    ].
    type == JavaPrimitiveType char ifTrue:[
        arg isCharacter ifTrue: [ ^5 ].
        ^0
    ].

    arg isNil ifTrue: [ ^5 ].
    type isArrayType ifTrue: [
        arg isString ifTrue: [ ^0 ].
        (arg isKindOf: SequenceableCollection) ifTrue: [ ^5 ].
        ^0
    ].
    arg isString ifTrue: [ ^5 ].
    (arg isKindOf: JavaObject) ifTrue: [ ^5 ].
    ^0
!

convertToSmalltalk: javaObject type: type
    "Given a Java return value, convert to a Smalltalk object as appropriate.
     Currently, only a few types are converted."

    type == JavaPrimitiveType boolean ifTrue: [ ^javaObject == 1 ].
    type == JavaPrimitiveType void ifTrue:[ ^nil ].
    ^javaObject
!

convertToJava: arg type: type ifFail: errorBlock
    "Given a Smalltalk argument, check if it belongs to the
     correct Java type and convert as appropriate."

    type == JavaPrimitiveType boolean ifTrue:[
        arg == true ifTrue: [ ^1 ].
	arg == false ifTrue: [ ^0 ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType int ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000 and:16r7FFFFFFF ]) ifTrue:[ ^arg ].
        ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType long ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000_00000000 and:16r7FFFFFFF_FFFFFFFF ]) ifTrue:[ ^arg ].
        ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType float ifTrue:[
        arg isFloat ifTrue: [ ^arg asFloatE ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType double ifTrue:[
        arg isFloat ifTrue: [ ^arg asFloatD ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType char ifTrue:[
        arg isCharacter ifTrue: [ ^arg value ].
        ^errorBlock value
    ].

    arg isNil ifTrue: [ ^arg ].
    type isArrayType ifTrue: [
        arg isString ifTrue: [ ^errorBlock value ].
        (arg isKindOf: SequenceableCollection) ifTrue: [ ^arg ].
        ^errorBlock value
    ].
    arg isString ifTrue: [ ^arg asJavaString ].
    (arg isKindOf: JavaObject) ifTrue: [ ^arg ].
    ^errorBlock value
!

convertToSmalltalk: javaObject type: type
    "Given a Java return value, convert to a Smalltalk object as appropriate.
     Currently, only a few types are converted."

    type == JavaPrimitiveType boolean ifTrue: [ ^javaObject == 1 ].
    type == JavaPrimitiveType void ifTrue:[ ^nil ].
    ^javaObject
!

lookupMethod: selector args: args static: static
    | name method goodness jc |
    name := selector last == $:
	ifTrue: [ selector copyFrom: 1 to: (selector indexOf: $:) - 1 ]
	ifFalse: [ selector ].

    name := name asSymbol.
    name == #init_ ifTrue: [ name := #'<init>' ].

    goodness := 0.
    method := nil.
    jc := javaClass.
    [
        javaClass methods do: [ :each || newGoodness |
	    (each name == name
                and: [ static == each isStatic
	        and: [ each numArgs = args size ]])
	        ifTrue: [
	            newGoodness := self check: args against: each argTypes.
		    newGoodness > goodness
		        ifTrue: [ method := each. goodness := newGoodness ]]
	].
	jc := jc extends.
	jc isNil
    ] whileFalse.
		
    ^method
!

doesNotUnderstand: aMessage
    "As a courtesy to the Smalltalker, try to map methods"
    | javaMethod |
    javaMethod := self
	lookupMethod: aMessage selector
	args: aMessage arguments
	static: true.

    javaMethod isNil ifTrue: [
        ^super doesNotUnderstand: aMessage ].

    ^self
	invokeJavaMethod: javaMethod
	withArguments: aMessage arguments
	on: self
!

invokeJavaMethod: javaMethod withArguments: args on: receiver
    | retVal javaArgs |
    javaArgs := args isEmpty
	ifTrue: [ args ]
	ifFalse: [
            self
                convertArgsToJava: args
                withSignature: javaMethod argTypes ].

    retVal := JavaVM
	invokeJavaSelector: javaMethod selector
	withArguments: javaArgs
	on: receiver.

    ^self convertToSmalltalk: retVal type: javaMethod returnType! !

!JavaObject methodsFor: 'message sending'!

doesNotUnderstand: aMessage
    "As a courtesy to the Smalltalker, try to map methods"
    | javaMethod |
    javaMethod := self class
	lookupMethod: aMessage selector
	args: aMessage arguments
	static: false.

    javaMethod isNil ifTrue: [
        ^super doesNotUnderstand: aMessage ].

    ^self class
	invokeJavaMethod: javaMethod
	withArguments: aMessage arguments
	on: self
! !


!JavaObject methodsFor: 'conversion'!

asJavaObject
    ^self!

!JavaObject methodsFor: 'interfaces'!

checkCast: anObject
    | message exception |
    (self isKindOf: anObject) ifTrue: [ ^self ].
    message := 'invalid cast' asJavaString.
    exception := Java.java.lang.ClassCastException new.
    exception perform: #'<init>(Ljava/lang/String;)V' with: message.
    exception throw!

initialize
!

instanceOf: anObject
    ^(self isKindOf: anObject) ifTrue: [ 1 ] ifFalse: [ 0 ]!

isKindOf: anObject
    ^anObject isClass
    	ifTrue: [
	    self class == anObject
		or: [ self class inheritsFrom: anObject ] ]
    	ifFalse: [
	    self implementsInterface: anObject ]!

implementsInterface: anInterface
    | class |
    class := self class.
    [
	(class asJavaClass implements includes: anInterface) ifTrue: [ ^true ].
	class := class superclass.
	class == JavaObject
    ] whileFalse.
    ^false!

monitorEnter
    "JavaMonitor enter: self"! "MONITOR!!!"

monitorExit
    "JavaMonitor exit: self"! "MONITOR!!!"
    
throw
    JavaException signal: self! !

!JavaObject class methodsFor: 'compiling'!

initializationString
    ^'initialized ifFalse: [
	initialized := true.
	self initialize ].'!

isConstant: aJavaField
    ^aJavaField isFinal and: [ aJavaField isStatic and: [ aJavaField constantValue notNil ]]!

needToInitialize: aJavaField
    "If a field is not static, it is initialized in the constructor
     even if it is final and has a constant value."
    ^(self isConstant: aJavaField) not
	and: [ aJavaField signature initializationValue notNil ]!

compileFieldInitializer
    | instanceStream classStream stream |
    instanceStream := WriteStream on: (String new: 40).
    classStream := WriteStream on: (String new: 40).
    instanceStream
	nextPutAll: 'initialize ['; nl; tab;
	nextPutAll: 'super initialize.'.

    classStream
	nextPutAll: 'initialize ['.

    javaClass fields do: [ :each |
	(self needToInitialize: each) ifTrue: [
	    stream := each isStatic
		ifTrue: [ classStream ]
		ifFalse: [ instanceStream ].

	    stream
		nl; tab;
		nextPutAll: each name; 
		nextPutAll: ' := ';
		store: each signature initializationValue;
		nextPut: $. ]].

    (self class includesSelector: #'<clinit>()V') ifTrue: [
	classStream
	    "nl; tab; nextPutAll: 'Transcript';
	    nl; tab; tab; nextPutAll: 'show: ''Initializing '';';
	    nl; tab; tab; nextPutAll: 'display: (self nameIn: Java); nl.';"
	    nl; tab; nextPutAll: 'self perform: #''<clinit>()V''.' ].

    (self includesSelector: #'finalize()V') ifTrue: [
	instanceStream
	    nl; tab; nextPutAll: 'self addToBeFinalized' ].

    instanceStream nextPutAll: ' ]'.
    classStream nextPutAll: ' ]'.
    self compile: instanceStream contents.
    self class compile: classStream contents!

compileSetterFor: field in: destClass
    | stream method auxName |
    stream := WriteStream on: (String new: 60).
    stream
    	nextPutAll: field putSelector;
    	nextPutAll: ' assignedValue$ [';
    	nl;
    	tab;
    	nextPutAll: field name;
    	nextPutAll: ' := assignedValue$';
	nl;
	nextPut: $].

    method := destClass compile: stream contents.
    auxName := (field name copyWith: $:) asSymbol.
    (JavaObject respondsTo: auxName) ifFalse: [
	destClass addSelector: auxName withMethod: method ]!

compileGetterFor: field in: destClass
    | stream method auxName |
    stream := WriteStream on: (String new: 100).
    stream
    	nextPutAll: field getSelector;
	nextPutAll: ' [';
    	nl.

    field isStatic ifTrue: [
	stream
	    tab;
	    nextPutAll: self initializationString;
	    nl ].

    stream
    	tab;
    	nextPut: $^;
    	nextPutAll: field name;
	nl;
	nextPut: $].

    method := destClass compile: stream contents.
    auxName := field name asSymbol.
    (JavaObject respondsTo: auxName) ifFalse: [
	destClass addSelector: auxName withMethod: method ]!

compileConstantFieldAccessor: constantField in: destClass
    | stream method auxName |
    stream := WriteStream on: (String new: 40).
    stream
    	nextPutAll: constantField getSelector;
	nextPutAll: ' [';
    	nl;
    	tab;
    	nextPutAll: '^##(';
    	store: constantField constantValue;
	nextPut: $);
	nl;
	nextPut: $].

    method := destClass compile: stream contents.
    auxName := constantField name asSymbol.
    (JavaObject respondsTo: auxName) ifFalse: [
	self class addSelector: auxName withMethod: method ]!

compileAccessors
    javaClass fields do: [:each || destClass |
	destClass := each isStatic 
	    ifTrue: [ self class ] ifFalse: [ self ].

        (self isConstant: each)
	    ifTrue: [
		self compileConstantFieldAccessor: each in: destClass ]
	    ifFalse: [
		self compileGetterFor: each in: destClass.
	    	self compileSetterFor: each in: destClass]]!

createMethodProxies
    javaClass methods do: [:each | 
	| selector method homeClass |
	each isNative ifFalse: [
	    homeClass := each isStatic ifTrue: [self class] ifFalse: [self].
	    selector := each selector.
    	    method := JavaUntranslatedMethod
		for: each
		selector: selector
		class: homeClass.

	    homeClass addSelector: selector withMethod: method]]!

createSubclass: aJavaClass into: theNamespace
    | meta theClass instVars classVars |
    "Classify fields into instance variables, class variables, and constants."
    instVars := self allInstVarNames asOrderedCollection.
    classVars := BindingDictionary new.
    aJavaClass fields do: [:each | 
	(self isConstant: each) ifFalse: [
	    each isStatic 
    		ifTrue: [classVars at: each name asSymbol put: nil]
    		ifFalse: [instVars add: each name asSymbol]]].

    "Add a hook from the java.lang.Class object back to the Smalltalk class."
    aJavaClass fullName = 'java.lang.Class' ifTrue: [
    	instVars add: #smalltalkClass ].

    meta := Metaclass subclassOf: self class.
    theClass := meta
    	name: aJavaClass name
    	environment: theNamespace
    	subclassOf: self
    	instanceVariableArray: instVars asArray
    	shape: nil
    	classPool: classVars
    	poolDictionaries: #()
    	category: 'Java'.

    ^theClass
    	javaClass: aJavaClass;
    	compileAccessors;
    	createMethodProxies;	
	compileFieldInitializer;
	yourself! !

!JavaObject class methodsFor: 'initializing'!

maybeInitialize
    initialized ifFalse: [
	initialized := true.
	self initialize ]!

new
    "We inline maybeInitialize for speed."
    initialized ifFalse: [
	initialized := true.
	self initialize ].
    ^self basicNew initialize!

main
    | args |
    args := Smalltalk arguments collect: [ :each | each asJavaString ].
    ^JavaVM
	invokeJavaSelector: #'main([Ljava/lang/String;)V'
	withArguments: { args }
	on: self
!

initialized
    ^initialized!

initialize
!

!JavaObject class methodsFor: 'accessing'!

asJavaClass
    ^javaClass!

asJavaObject
    ^self javaLangClass!

implements: anInterface
    ^self javaClass implementsInterface: anInterface!

javaClass
    ^javaClass!

javaLangClass
    javaLangClass isNil ifTrue: [
	javaLangClass := Java.java.lang.Class new javaClass: javaClass ].
    ^javaLangClass!

javaClass: anObject
    javaClass := anObject.
    initialized := false! !

!JavaSynchronizedMethodWrapper methodsFor: 'forwarding'!

valueWithReceiver: receiver withArguments: args
    ^[
    	JavaMonitor enter: receiver asJavaObject.
    	receiver perform: self wrappedMethod withArguments: args
    ] ensure: [ JavaMonitor exit: receiver asJavaObject ]! !

!JavaSynchronizedMethodWrapper methodsFor: 'accessing'!

javaMethod
    ^self wrappedMethod javaMethod!

wrappedMethod
    ^wrappedMethod!

wrappedMethod: anObject

    self descriptor
	selector: anObject selector;
	methodClass: anObject methodClass.

    wrappedMethod := anObject! !

!JavaSynchronizedMethodWrapper class methodsFor: 'instance creation'!

for: aCompiledMethod
    ^(self numArgs: aCompiledMethod numArgs)
	wrappedMethod: aCompiledMethod; yourself! !

!JavaMethodInfo class methodsFor: 'instance creation'!

copyFrom: descriptor
    ^(self new: descriptor size)
    	copyFrom: descriptor! !

!JavaMethodInfo methodsFor: 'accessing'!

copyFrom: descriptor
    sourceCode := descriptor sourceCode.
    category := descriptor category.
    class := descriptor methodClass.
    selector := descriptor selector.
    1 to: descriptor size do: [ :i |
    	self at: i put: (descriptor at: i) ]!

javaMethod
    ^javaMethod!

javaMethod: aJavaMethod
    javaMethod := aJavaMethod! !

!JavaCompiledMethod methodsFor: 'accessing'!

javaMethod
    ^self descriptor javaMethod! !

!JavaUntranslatedMethod methodsFor: 'translation'!

valueWithReceiver: receiver withArguments: args
    | trans cm |
    trans := JavaMethodTranslator onMethod: self javaMethod.
    trans translate.

    cm := trans compiledMethod.
    cm makeReadOnly: false.
    cm descriptor methodClass: self methodClass.
    cm descriptor selector: self selector.
    cm descriptor: (JavaMethodInfo copyFrom: cm descriptor).
    cm descriptor javaMethod: self javaMethod.

    "javaMethod isSynchronized
    	ifTrue: [ cm := JavaSynchronizedMethodWrapper for: cm ]."  "MONITOR!!!"

    self become: cm.
    Behavior flushCache.

    "Here, self is the translated method!!!"
    self methodClass asClass maybeInitialize.
    self makeReadOnly: true.

    ^receiver perform: self withArguments: args! !

!JavaUntranslatedMethod methodsFor: 'accessing'!

javaMethod
    ^javaMethod!

javaMethod: anObject
    javaMethod := anObject! !

!JavaUntranslatedMethod class methodsFor: 'instance creation'!

for: aJavaMethod selector: selector class: homeClass
    | descriptor |
    descriptor := MethodInfo new
    	selector: selector;
	methodClass: homeClass;
	yourself.

    ^(self numArgs: aJavaMethod numArgs)
    	descriptor: descriptor;
	javaMethod: aJavaMethod;
	yourself! !

!JavaException class methodsFor: 'signal'!

resignal: ex as: anObject
    ex resignalAs: (self new
	tag: anObject;
	yourself)!

signal: anObject
    ^self new
	tag: anObject;
	signal!

!JavaException methodsFor: 'signal'!

messageText
    | msg |
    self tag isNil
    	ifFalse: [
	    msg := self tag detailMessage.
	    msg := msg isNil
		ifTrue: [ 'A ', (self tag class nameIn: Java), ' was thrown' ]
		ifFalse: [ msg asString ] ]
	ifTrue: [
	    msg := 'A Java program threw an exception.' ].

    ^msg
!

javaException
    ^self tag
!

foundJavaHandler: handler in: context
    self
        onDoBlock: nil
        handlerBlock: handler handlerpc
        onDoContext: context
        previousState: nil!

activateHandler: resumeBoolean
    "Run the handler, passing to it aSignal, an instance of Signal.  aBoolean
     indicates the action (either resuming the receiver of #on:do:... or
     exiting it) to be taken upon leaving from the handler block."

    | result baseSP |
    <exceptionHandlingInternal: true>

    "If in a Smalltalk exception handler, no problem."
    handlerBlock isInteger
	ifFalse: [ ^super activateHandler: resumeBoolean ].

    baseSP := context method numTemps + context method numArgs.
    result := context at: baseSP.
    context ip: handlerBlock.

    "There is no method to continue without adjusting the stack.  Simulate
     this by `returning' what the return value would overwrite, that is, the
     the value of the last temporary or argument."
    context
	sp: baseSP - 1;
	continue: result
! !

!JavaFileDescriptor methodsFor: 'error checking'!

checkError
    | exception msg errno |
    errno := File errno.
    errno < 1 ifTrue: [ ^0 ].
    msg := (self stringError: errno) asJavaString.
    exception := Java.java.io.IOException new.
    exception perform: #'<init>(Ljava/lang/String;)V' with: msg.
    exception throw! !

!JavaVM class methodsFor: 'starting'!

invokeJavaSelector: selector withArguments: args on: receiver
    "Invoke receiver's Java method with the given arguments,
     mapping Smalltalk's MessageNotUnderstood and ZeroDivide
     exceptions to Java's NullPointerException and
     ArithmeticException."

    ^[ receiver perform: selector withArguments: args ]
	on: SystemExceptions.IndexOutOfRange
	do: [ :ex || exception |
	    exception := Java.java.lang.ArrayIndexOutOfBoundsException new.
	    exception perform: #'<init>(I)V' with: ex value - 1.
	    JavaException resignal: ex as: exception ]

        on: ZeroDivide
        do: [ :ex |
            JavaVM
                resignal: ex
                as: Java.java.lang.ArithmeticException
                message: 'division by zero' ]

        on: MessageNotUnderstood
        do: [ :ex |
            ex receiver isNil ifFalse: [ ex pass ].
            JavaVM
                resignal: ex
                as: Java.java.lang.NullPointerException ]!

run: className
    | path |
    path := className asString copyReplacing: $. withObject: $/.
    (JavaClass fromString: path) asSmalltalkClass main! !

!JavaVM class methodsFor: 'files'!

fileDescriptorFor: fd
    | fdObj |
    fd < 0 ifTrue: [ ^nil ].
    fd >= OpenFileTable size ifTrue: [
	fd - OpenFileTable size + 1 timesRepeat: [
	    OpenFileTable addLast: nil ] ].
    fdObj := OpenFileTable at: fd + 1.
    fdObj isNil ifTrue: [
	OpenFileTable
	    at: fd + 1
	    put: (fdObj := JavaFileDescriptor on: fd) ].
    ^fdObj! !

!JavaVM class methodsFor: 'native methods'!

installNativeMethods
    self methodDictionary do: [ :each |
	| attr javaMethodName destClass static |
	each descriptor size > 0 ifTrue: [
	    attr := each descriptor at: 1.
	    attr selector == #javaNativeMethod:for:static: ifTrue: [
	        javaMethodName := attr arguments at: 1.
	        destClass := attr arguments at: 2.
	        static := attr arguments at: 3.
	        destClass value isNil ifTrue: [ self load: destClass ].

		destClass := destClass value.
		static ifTrue: [ destClass := destClass class ].
	        destClass addSelector: javaMethodName withMethod: each
	    ]
	]
    ]!

load: class
    | className |
    "Convert '#{Java.java.lang.Object}' into 'java.lang.Object'."
    className := class storeString.
    className := className copyFrom: 8 to: className size - 1.
    (JavaClass loadClass: className) install! !

!JavaVM class methodsFor: 'bootstrapping'!

bootstrap
    | classPath |
    Bootstrapped := false.
    JavaClassFileReader classDirectories isNil
	ifTrue: [
	    classPath := Smalltalk getenv: 'CLASSPATH'.
	    classPath isNil ifTrue: [ self error: 'CLASSPATH not set' ].
	    JavaClassFileReader classPath: classPath ].

    Transcript show: 'Installing native methods...'; nl.
    self installNativeMethods.

    Transcript show: 'Initializing core classes...'; nl.
    self initializePrimitiveClasses.
    self installMoreClasses.
    Java.java.lang.String maybeInitialize.
    JavaStringPrototype	allInstances
	do: [ :each | each convertToJavaLangString ].

    Transcript show: 'Starting the system...'; nl.
    Bootstrapped := true.
    Java.java.lang.Runtime maybeInitialize.
    ObjectMemory addDependent: self.
    self update: #returnFromSnapshot!

bootstrapped
    ^Bootstrapped!

installMoreClasses
    "Classes needed to initialize the system"
    (JavaClass fromString: 'java/lang/ThreadGroup') install.
    (JavaClass fromString: 'java/lang/Thread') install.

    "Classes needed by the native methods"
    (JavaClass fromString: 'java/lang/Cloneable') install.
    (JavaClass fromString: 'java/lang/Byte') install.
    (JavaClass fromString: 'java/lang/Integer') install.
    (JavaClass fromString: 'java/lang/Float') install.
    (JavaClass fromString: 'java/lang/Double') install.
    (JavaClass fromString: 'java/lang/Void') install.
    (JavaClass fromString: 'java/lang/Boolean') install.
    (JavaClass fromString: 'java/lang/Short') install.
    (JavaClass fromString: 'java/lang/Long') install.

    "Exceptions that we want to throw"
    (JavaClass fromString: 'java/lang/ClassCastException') install.
    (JavaClass fromString: 'java/lang/ArrayIndexOutOfBoundsException') install.
    (JavaClass fromString: 'java/lang/StringIndexOutOfBoundsException') install.
    (JavaClass fromString: 'java/lang/IllegalThreadStateException') install.
    (JavaClass fromString: 'java/lang/ClassCastException') install.
    (JavaClass fromString: 'java/lang/NullPointerException') install.
    (JavaClass fromString: 'java/lang/ArithmeticException') install.
    (JavaClass fromString: 'java/lang/CloneNotSupportedException') install.
    (JavaClass fromString: 'java/io/IOException') install!

initializePrimitiveClasses
    IntClass := Java.java.lang.Class new javaType: JavaPrimitiveType int.
    ByteClass := Java.java.lang.Class new javaType: JavaPrimitiveType byte.
    ShortClass := Java.java.lang.Class new javaType: JavaPrimitiveType short.
    LongClass := Java.java.lang.Class new javaType: JavaPrimitiveType long.
    FloatClass := Java.java.lang.Class new javaType: JavaPrimitiveType float.
    DoubleClass := Java.java.lang.Class new javaType: JavaPrimitiveType double.
    VoidClass := Java.java.lang.Class new javaType: JavaPrimitiveType void.
    BooleanClass := Java.java.lang.Class new javaType: JavaPrimitiveType boolean.
    CharClass := Java.java.lang.Class new javaType: JavaPrimitiveType char!

!JavaVM class methodsFor: 'restarting'!

update: event
    event == #aboutToSnapshot ifTrue: [
	self stopThreads
    ].
    event == #returnFromSnapshot ifTrue: [
	OpenFileTable := OrderedCollection new.
	self startMainThread
    ]! !

!JavaVM class methodsFor: 'managing Threads'!

cleanup
    JoinedThreads := IdentityDictionary new.
    Threads := Dictionary new!

stopThreads
    ThreadAccessMutex critical: [ | process |
	Threads do: [ :each | each terminate ].
	self cleanup ]!

startMainThread
    | mainString |

    ThreadAccessMutex := RecursionLock new.
    self cleanup.

    TopGroup := Java.java.lang.ThreadGroup new.
    MainGroup := Java.java.lang.ThreadGroup new.
    MainThread := Java.java.lang.Thread new.
    mainString := 'main' asJavaString.

    TopGroup perform: #'<init>()V'.

    MainGroup
	perform: #'<init>(Ljava/lang/ThreadGroup;Ljava/lang/String;)V'
	with: TopGroup with: mainString.

    MainThread
	perform: #'<init>(Ljava/lang/ThreadGroup;Ljava/lang/String;)V'
	with: MainGroup with: mainString.

    MainThread perform: #'setDaemon(Z)V' with: 1.
    MainThread perform: #'setPriority(I)V' with: 5! !

!JavaVM class methodsFor: 'exception support'!

resignal: ex as: class message: msg
    JavaException resignal: ex as: (class new
	perform: #'<init>(Ljava/lang/String;)V' with: msg;
	yourself)!

resignal: ex as: class
    JavaException resignal: ex as: (class new
	perform: #'<init>()V';
	yourself)!

throw: class message: msg
    JavaException signal: (class new
	perform: #'<init>(Ljava/lang/String;)V' with: msg;
	yourself)!

throw: class
    JavaException signal: (class new
	perform: #'<init>()V';
	yourself)!

!JavaVM class methodsFor: 'private'!

addThread: aThread for: aProcess
    ThreadAccessMutex critical: [
	(Threads includesKey: aThread)
	     ifTrue: [
		 ^self throw: Java.java.lang.IllegalThreadStateException ].
	Threads at: aThread put: aProcess ]!

removeThread: aThread
    | joinSemaphores |
    ThreadAccessMutex critical: [ | process |
	process := Threads
	    at: aThread
	    ifAbsent: [ ^self error: 'not a Java thread' ].

	Threads removeKey: aThread.
	JoinMutex wait.
        joinSemaphores := JoinedThreads at: aThread ifAbsent: [ nil ].
        joinSemaphores isNil ifFalse: [ 
	    joinSemaphores do: [ :each | each signal ] ].

	JoinMutex signal.
	process terminate ]!

convertPriority: javaPrio
    ^javaPrio // 3 + Processor userBackgroundPriority! !

JavaMonitor initialize!
