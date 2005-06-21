"======================================================================
|
|   Smalltalk GUI debugger window
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"

GuiData subclass:  #Debugger
	instanceVariableNames: 'stacktrace contexts process stepSemaphore
			        activeContext receiverInspector stackInspector
				listView theClass theMethod textView topView
				methodLineMapCache'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

Debugger comment: 
nil!

ObjectInspectorFieldList subclass: #PrimitiveInspectorFieldList
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'System-Compilers'!

InspectorFieldList subclass:  #StackInspectorFieldList
	instanceVariableNames: 'vars '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

StackInspectorFieldList comment: 
nil!

!Debugger class methodsFor: 'class attributes'!

debuggerClass
    ^nil
!

debuggingPriority
    ^1
! !

!Debugger class methodsFor: 'instance creation'!

new: notifier 
    ^self new init: notifier
! !

!Debugger methodsFor: 'initialize/release'!

init: notifier 
    process := notifier process.
    stepSemaphore := Semaphore new.
    methodLineMapCache := IdentityDictionary new.

    [ process suspendedContext isInternalExceptionHandlingContext ]
        whileTrue: [ self finish ].

    self createWindowFrom: notifier.
!

createWindowFrom: notifier
    | toplevel container text buttonView lowerpane pane list context urpane lrpane |
    topView := (BrowserShell new: 'Debugger') data: self.
    toplevel := topView blox.
    toplevel width: 500 height: 350.
    pane := Form new: 'panes' in: topView.
    topView addChildView: pane.
    pane blox width: 500 height: 125.

    pane addChildView: ((listView := PList new: 'MethodSet' in: pane)
                initialize;
                data: self;
                listMsg: #stacktrace;
                dataMsg: #contexts;
                handleUserChange: #contextSelectedFrom:;
		stateChange: #stacktrace;
                yourself).

    listView menuInit: ((PopupMenu new: listView label: 'Debug')
                selectors: self debugSelectors
                receiver: self).

    listView blox width: 300 height: 100.

    pane addChildView: ((buttonView := ButtonForm new: 'Debugging' in: pane)
                selectors: self debugSelectors receiver: self;
		yourself).

    buttonView blox x: 0 y: 100 width: 300 height: 25.

    urpane := Form new: 'panes' in: pane.
    pane addChildView: urpane.
    urpane blox width: 200 height: 125.
    urpane blox posHoriz: listView blox.

    lowerpane := Form new: 'panes' in: topView.
    lowerpane blox posVert: pane blox.
    lowerpane blox width: 500 height: 225.
    topView addChildView: lowerpane.
    lowerpane addChildView: ((textView := PCode new: lowerpane)
		data: self;
		stateChange: #text;
		handleUserChange: #compile:from:;
		setBrowserKeyBindings;
		textMsg: #text;
		yourself).
    textView menuInit: ((PopupMenu new: textView label: 'Edit') 
		selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste)
			     #() #('Clear' #gstClear)
			     #() #('Line...' #line) #('Find...' #find)
			     #() #('Do it' #eval) #('Print it' #evalAndPrintResult)
			     #('Inspect' #evalAndInspectResult)
			     #() #('Accept' #compileIt) #('Cancel' #revert)
			     #() #('Close' #close))
		receiver: textView
		argument: nil).
    text := textView blox.
    text width: 300 height: 225.
    lrpane := Form new: 'panes' in: lowerpane.
    lowerpane addChildView: lrpane.
    lrpane blox width: 200 height: 225.
    lrpane blox posHoriz: textView blox.

    stackInspector := Inspector new
	fieldLists: (self stackFieldListsFor: notifier currentContext);
	openIn: urpane menuName: 'Stack'.

    receiverInspector := Inspector new
	fieldLists: (self receiverFieldListsFor: notifier currentContext receiver);
	openIn: lrpane menuName: 'Receiver'.

    self updateContextList.
    self currentContext: notifier currentContext.
    topView display! !

!Debugger methodsFor: 'inspector panes'!

receiverFieldListsFor: anObject
    ^{ 'Primitive' -> (PrimitiveInspectorFieldList new value: anObject) },
	anObject inspectorFieldLists!

stackFieldListsFor: context
    ^{ 'Variables' -> (StackInspectorFieldList new value: context).
       'Stack' -> (ObjectInspectorFieldList new value: context) }! !

!Debugger methodsFor: 'text pane'!

compile: aString from: aView 
    "Compile aString derived from text in text view for the selected selector"

    theMethod notNil 
	ifTrue: 
	    [theClass 
		compile: aString
		classified: theMethod methodCategory
		ifError: 
		    [:fname :lineNo :errorString | 
		    aView displayError: errorString at: lineNo.
		    ^nil]]!

contextSelectedFrom: assoc
    self currentContext: assoc value!

highlight: context
    | line |
    line := self lineFor: context.
    textView blox
	gotoLine: line end: false;
	selectFrom: 1 @ line to: 1 @ (line + 1)!

contexts
    ^contexts!

stacktrace
    ^stacktrace!

text
    "Return source code for the selected method"

    | source |
    ^(theMethod notNil and: [ (source := theMethod methodSourceString) notNil ])
	ifTrue: [ theClass -> source ]
        ifFalse: [ '' ]! !

!Debugger methodsFor: 'button pane'!

debugSelectors
    ^#(#('Step' #stepButtonCallback) #('Next' #nextButtonCallback)
       #('Finish' #finishButtonCallback) #('Continue' #continueButtonCallback)
       #() #('Kill' #killButtonCallback)
       #() #('Terminate' #terminateButtonCallback))
!

stepButtonCallback
    self step; updateContextList
!

nextButtonCallback
    self next; updateContextList
!

finishButtonCallback
    self finish; updateContextList
!

continueButtonCallback
    topView destroy.
    self continue.
!

killButtonCallback
    topView destroy.
    process primTerminate
!

terminateButtonCallback
    topView destroy.
    process terminate.
    self continue
! !

!Debugger methodsFor: 'list pane'!

updateContextList
    | context lastContext |
    context := process suspendedContext.
    lastContext := context environment.
    stacktrace := OrderedCollection new.
    contexts := OrderedCollection new.

    [ context == lastContext ] whileFalse: [
        context isDisabled ifFalse: [
            stacktrace add: context printString.
            contexts add: context
        ].
        context := context parentContext.
    ].

    self changeState: #stacktrace.
    self currentContext: process suspendedContext!

currentContext: context
    activeContext := context.
    theMethod := context method.
    theClass := context methodClass.
    stackInspector fieldLists: (self stackFieldListsFor: context).
    receiverInspector fieldLists: (self receiverFieldListsFor: context receiver).
    self changeState: #text.
    Primitive updateViews.

    self highlight: context! !

!Debugger methodsFor: 'debugging operations'!

depthOf: aContext
    | context depth |
    context := activeContext.
    depth := 0.
    [ context == aContext ] whileFalse: [
        context := context parentContext.
        context isNil ifTrue: [ ^nil ].
        depth := depth + 1.
    ].
    ^depth
!

currentLine
    ^self lineFor: process suspendedContext!

lineFor: context
    | lineMap |
    lineMap := methodLineMapCache at: context method
	ifAbsentPut: [ context method sourceCodeMap ].
    ^lineMap at: context ip + 1 ifAbsent: [ 1 ]!

stepBytecode
    "Execute a bytecode of the debugged process"
    process singleStepWaitingOn: stepSemaphore.
    process suspend.
!

step
    "Execute a line of the debugged process, going inside a message
     that is sent."
    | context line |
    context := process suspendedContext.
    line := self currentLine.
    [
        self stepBytecode.
        activeContext := process suspendedContext.
        activeContext == context and: [ line = self currentLine ]
    ] whileTrue.
!

next
    "Execute a line of the debugged process, stepping over a message
     that is sent."
    | context |
    context := process suspendedContext.
    [
        self step.
        activeContext notNil and: [ activeContext parentContext == context ]
    ] whileTrue: [
        self finish: activeContext
    ]
!

finish: aContext
    "Execute the debugged process until it returns from aContext"
    | context |
    [
        context := process suspendedContext.
        [
            self stepBytecode.
            process suspendedContext == context
        ] whileTrue.

        activeContext := process suspendedContext.
        activeContext notNil "no context? exit"
            and: [ activeContext parentContext == context "a send? go on"
            or: [ (self depthOf: aContext) notNil ]] "aContext still in the chain? go on"
    ] whileTrue
!

finish
    "Execute the debugged process until it returns from the active context"
    self finish: activeContext
!

continue
    | proc |
    proc := Processor activeProcess.
    [ proc terminate. process resume ] forkAt: Processor unpreemptedPriority.

    "Suspend just in case we get here."
    proc suspend
! !

!PrimitiveInspectorFieldList methodsFor: 'primitives'!

validSize: anObject
    ^((self primClass: anObject) inheritsFrom: ContextPart)
	ifTrue: [ self prim: anObject instVarAt: ContextPart spIndex ]
	ifFalse: [ self primBasicSize: anObject ]
!

prim: anObject instVarAt: anIndex
    "Answer the index-th indexed variable of anObject."
    <primitive: VMpr_Object_instVarAt>
    self primitiveFailed
!

prim: anObject instVarAt: anIndex put: value
    "Store value in the index-th instance variable of anObject."
    <primitive: VMpr_Object_instVarAtPut>
   self primitiveFailed
!

prim: anObject basicAt: anIndex
    "Answer the index-th indexed instance variable of anObject."
    <primitive: VMpr_Object_basicAt>
    self primitiveFailed
!

prim: anObject basicAt: anIndex put: value
    "Store value in the index-th indexed instance variable of anObject."
    <primitive: VMpr_Object_basicAtPut>
   self primitiveFailed
!

primBasicAt: anIndex
    ^((self primClass: self value) inheritsFrom: Object)
	ifTrue: [ self value basicAt: anIndex ]
	ifFalse: [ self prim: self value basicAt: anIndex ]
!

primBasicAt: anIndex put: anObject
    ^((self primClass: self value) inheritsFrom: Object)
	ifTrue: [ self value basicAt: anIndex put: anObject ]
	ifFalse: [ self prim: self value basicAt: anIndex put: anObject ]
!

primBasicSize: anObject
    "Answer the number of indexed instance variable in anObject"
    <primitive: VMpr_Object_basicSize>
!

primClass: anObject
    "Answer the class of anObject"
    <primitive: VMpr_Object_class>
! !

!PrimitiveInspectorFieldList methodsFor: 'accessing'!

currentFieldValue: obj
    currentField > base
        ifTrue: [self primBasicAt: currentField - base put: obj]
        ifFalse: [self prim: self value instVarAt: currentField - 1 put: obj]!

currentFieldValue
    currentField == 0 ifTrue: [^nil].
    currentField == 1 ifTrue: [^self value].
    ^currentField > base
        ifTrue: [self primBasicAt: currentField - base]
        ifFalse: [self prim: self value instVarAt: currentField - 1]!

computeFieldList: anObject
    "Store a string representation of the inspected object, anObject, in fields.
     The first string is self.  The subsequent values are the object's complete
     set of instance variables names.  If the object is a variable class,
     append numerical indices from one to number of indexed variables"

    | instVarNames class |
    fields add: 'self'.
    class := self primClass: anObject.
    instVarNames := class allInstVarNames.
    1 to: instVarNames size
        do: [:x | fields add: (instVarNames at: x) asString].
    base := fields size.
    class isVariable
        ifTrue: [1 to: (self validSize: anObject) do: [:x | fields add: x printString]]
! !



!StackInspectorFieldList methodsFor: 'private'!

currentFieldValue: obj 
    | variable |
    currentField < 2 ifTrue: [^self].
    variable := vars at: currentField - 1.
    ^variable key at: variable value put: obj!

currentFieldValue
    "Return value at currently selected key"

    | variable |
    currentField == 0 ifTrue: [^nil].
    currentField == 1 ifTrue: [^self value].
    variable := vars at: currentField - 1.
    ^variable key at: variable value!

computeFieldList: anObject 
    vars := OrderedCollection new.
    fields add: 'thisContext'.
    self setFieldsIn: anObject!

setFieldsIn: context 
    | prefix numVars prefixSize |

    numVars := context numArgs + context numTemps.
    (context home == context or: [ context outerContext == nil ])
	ifTrue: [prefixSize := -2]
	ifFalse: [prefixSize := self setFieldsIn: context outerContext].
    numVars > 0 ifTrue: [prefixSize := prefixSize + 2].
    prefix := String new: (prefixSize max: 0) withAll: $-.
    (1 to: numVars) with: context variableNames do: 
	[:i :varName | 
	    fields add: prefix, varName.
	    vars add: context -> i].
    ^prefixSize! !

