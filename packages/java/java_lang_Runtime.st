"======================================================================
|
|   Java run-time support.  java.lang.Runtime native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2008 Free Software Foundation, Inc.
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


!JavaVM methodsFor: 'java.lang.Runtime'!

java_lang_Runtime_availableProcessors
    <javaNativeMethod: #'availableProcessors()I'
        for: #{Java.java.lang.Runtime} static: false>
    ^1
!

java_lang_Runtime_freeMemory
    <javaNativeMethod: #'freeMemory()J'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_totalMemory
    <javaNativeMethod: #'totalMemory()J'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_maxMemory
    <javaNativeMethod: #'maxMemory()J'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_gc
    <javaNativeMethod: #'gc()V'
        for: #{Java.java.lang.Runtime} static: false>
    ObjectMemory globalGarbageCollect
!

java_lang_Runtime_init
    <javaNativeMethod: #'init()V'
        for: #{Java.java.lang.Runtime} static: false>
!

java_lang_Runtime_runFinalization
    <javaNativeMethod: #'runFinalization()V'
        for: #{Java.java.lang.Runtime} static: false>
!

java_lang_Runtime_traceInstructions_boolean: arg1
    <javaNativeMethod: #'traceInstructions(Z)V'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_traceMethodCalls_boolean: arg1
    <javaNativeMethod: #'traceMethodCalls(Z)V'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_exitInternal_int: arg1
    <javaNativeMethod: #'exitInternal(I)V'
        for: #{Java.java.lang.Runtime} static: false>
    ObjectMemory quit: arg1
!

java_lang_Runtime_execInternal_java_lang_StringArray: arg1 java_lang_StringArray: arg2 java_io_File: arg3
    <javaNativeMethod: #'execInternal([Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)Ljava/lang/Process;'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_insertSystemProperties_java_util_Properties: arg1
    | host cpu os dash1 dash2 fullVer tmpDir put |

    <javaNativeMethod: #'insertSystemProperties(Ljava/util/Properties;)V'
        for: #{Java.java.lang.Runtime} static: true>

    put := [ :k :v |
	arg1
	    perform: #'put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;'
	    with: k asJavaString
	    with: v asJavaString ].

    host := Smalltalk hostSystem.
    dash1 := host indexOf: $-.
    dash2 := host indexOf: $- startingAt: dash1 + 1.
    cpu := host copyFrom: 1 to: dash1 - 1.
    os := host copyFrom: dash2 + 1 to: host size.
    ('i#86' match: cpu) ifTrue: [ cpu := 'ix86' ].

    fullVer := 'GNU Smalltalk version ', Smalltalk version.
    tmpDir := Smalltalk getenv: 'TMPDIR'.
    tmpDir isNil ifTrue: [
	tmpDir := Smalltalk getenv: 'TEMP'.
        tmpDir isNil ifTrue: [
	    tmpDir := Smalltalk getenv: 'TMP'.
            tmpDir isNil ifTrue: [ tmpDir := '/tmp' ]]].

    put value: 'java.class.version' value: '46.0'.
    put value: 'java.version'       value: Smalltalk version.
    put value: 'java.vendor'        value: 'Free Software Foundation'.
    put value: 'java.vendor.url'    value: 'http://www.gnu.org'.
    put value: 'java.fullversion'   value: fullVer.
    put value: 'java.vm.info'       value: fullVer.
    put value: 'java.vm.name'       value: 'GNU Smalltalk'.
    put value: 'java.vm.version'    value: Smalltalk version.
    put value: 'java.vm.vendor'     value: 'Free Software Foundation'.

    put value: 'java.specification.version'    value: '1.3'.
    put value: 'java.specification.name'       value: 'Java(tm) Platform API Specification'.
    put value: 'java.specification.vendor'     value: 'Sun Microsystems Inc.'.
    put value: 'java.vm.specification.version' value: '1.0'.
    put value: 'java.vm.specification.name'    value: 'Java(tm) Virtual Machine Specification'.
    put value: 'java.vm.specification.vendor'  value: 'Sun Microsystems Inc.'.

    put value: 'java.class.path'    value: JavaClassFileReader classPath.
    put value: 'java.home'          value: Directory image name.
    put value: 'os.name'            value: os.
    put value: 'os.arch'            value: cpu.
    put value: 'os.version'         value: '1'.
    put value: 'file.separator'     value: '/'.
    put value: 'path.separator'     value: ':'.
    put value: 'line.separator'     value: (Character nl asString).
    put value: 'user.name'          value: (Smalltalk getenv: 'USER').
    put value: 'user.home'          value: Directory home name.
    put value: 'user.dir'           value: Directory home name.

    put value: 'java.io.tmpdir'     value: tmpDir.
    put value: 'java.tmpdir'        value: tmpDir! !
