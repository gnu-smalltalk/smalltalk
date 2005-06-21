"======================================================================
|
|   Java run-time support.  java.lang.Thread native methods.
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


!JavaVM methodsFor: 'java.lang.Thread'!

java_lang_Thread_countStackFrames
    <javaNativeMethod: #'countStackFrames()I'
        for: #{Java.java.lang.Thread} static: false>
    self notYetImplemented
!

java_lang_Thread_currentThread
    <javaNativeMethod: #'currentThread()Ljava/lang/Thread;'
        for: #{Java.java.lang.Thread} static: true>
    "The system thread 'main' is assumed to be allways running.
    currentThread will either be main or a thread in Threads"

    ^ThreadAccessMutex critical: [
        Threads at: Processor activeProcess ifAbsent: [ MainThread ] ]
!

java_lang_Thread_destroy
    <javaNativeMethod: #'destroy()V'
        for: #{Java.java.lang.Thread} static: false>
    self notYetImplemented
!

java_lang_Thread_gen_name
    <javaNativeMethod: #'gen_name()Ljava/lang/String;'
        for: #{Java.java.lang.Thread} static: true>
    ^('Thread ', (Time millisecondClock printString: 36)) asJavaString
!

java_lang_Thread_initialize_native
    <javaNativeMethod: #'initialize_native()V'
        for: #{Java.java.lang.Thread} static: false>
!

java_lang_Thread_interrupt
    <javaNativeMethod: #'interrupt()V'
        for: #{Java.java.lang.Thread} static: false>
    self notYetImplemented
!

java_lang_Thread_join_long: arg1 int: arg2
    | s p joinSet |
    <javaNativeMethod: #'join(JI)V'
        for: #{Java.java.lang.Thread} static: false>

    s := Semaphore new.
    JoinMutex critical: [
        joinSet := JoinedThreads at: self ifAbsentPut: [ IdentitySet new ].
        joinSet add: s
    ].

    arg1 = 0 ifFalse: [
	p := JavaVM startDelayProcessFor: arg1 semaphore: s ].

    s wait.
    JoinMutex critical: [
        p notNil ifTrue: [ p terminate ].

        joinSet remove: s.
        joinSet isEmpty
            ifTrue: [ JoinedThreads removeKey: self ]
    ]
!

java_lang_Thread_resume
    | process |
    <javaNativeMethod: #'resume()V'
        for: #{Java.java.lang.Thread} static: false>
    ThreadAccessMutex critical: [
        process := Threads keyAtValue: self ifAbsent: [ ^self ]
    ].
    process resume
!

java_lang_Thread_setPriority_int: arg1
    | process |
    <javaNativeMethod: #'setPriority(I)V'
        for: #{Java.java.lang.Thread} static: false>
    ThreadAccessMutex critical: [
        process := Threads keyAtValue: self ifAbsent: [ ^self ]
    ].
    process priority: (JavaVM convertPriority: arg1)
!

java_lang_Thread_sleep_long: arg1 int: arg2
    <javaNativeMethod: #'sleep(JI)V'
        for: #{Java.java.lang.Thread} static: true>
    arg1 = 0
        ifTrue: [
            (Threads
                keyAtValue: self
                ifAbsent: [ ^self error: 'no process for thread' ] ) suspend ]
        ifFalse: [
            (Delay forMilliseconds: arg1) wait ]
!

java_lang_Thread_start
    | p priority |
    <javaNativeMethod: #'start()V'
        for: #{Java.java.lang.Thread} static: false>
    p := [
        JavaVM
	    invokeJavaSelector: #'run()V' withArguments: #() on: self;
	    removeThread: self
    ] newProcess.

    priority := self perform: #'getPriority()I'.
    JavaVM addThread: self for: p.
    p priority: (JavaVM convertPriority: priority).
    p resume
!

java_lang_Thread_stop_java_lang_Throwable: arg1
    <javaNativeMethod: #'stop(Ljava/lang/Throwable;)V'
        for: #{Java.java.lang.Thread} static: false>
    arg1 isNil ifFalse: [ self notYetImplemented ].
    JavaVM removeThread: self
!

java_lang_Thread_suspend
    | process |
    <javaNativeMethod: #'suspend()V'
        for: #{Java.java.lang.Thread} static: false>
    ThreadAccessMutex critical: [
        process := Threads keyAtValue: self ifAbsent: [ ^self ]
    ].
    process suspend
!

java_lang_Thread_yield
    <javaNativeMethod: #'yield()V'
        for: #{Java.java.lang.Thread} static: true>
    Processor yield
! !

