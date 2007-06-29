"======================================================================
|
|   Java support loading script
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

Smalltalk addSubspace: #Java!
Java addSubspace: #gnu!

Java.gnu addSubspace: #smalltalk!
Java.gnu addSubspace: #gcj!
Java.gnu addSubspace: #java!
Java.gnu.gcj addSubspace: #convert!
Java.gnu.gcj addSubspace: #runtime!
Java.gnu.java addSubspace: #net!
Java.gnu.java addSubspace: #nio!

Java.gnu.gcj.convert at: #IOConverter put: nil!
Java.gnu.gcj.runtime at: #StackTrace put: nil!
Java.gnu.gcj.runtime at: #StringBuffer put: nil!
Java.gnu.java.net at: #PlainDatagramSocketImpl put: nil!
Java.gnu.java.net at: #PlainSocketImpl put: nil!
Java.gnu.java.nio at: #FileLockImpl put: nil!
Java.gnu.java.nio at: #SelectorImpl put: nil!

Java addSubspace: #java!
Java.java addSubspace: #lang!
Java.java addSubspace: #io!
Java.java addSubspace: #net!
Java.java addSubspace: #nio!
Java.java addSubspace: #text!
Java.java addSubspace: #util!
Java.java.lang addSubspace: #ref!
Java.java.lang addSubspace: #reflect!
Java.java.nio addSubspace: #channels!
Java.java.util addSubspace: #zip!

Java.java.io at: #File put: nil!
Java.java.io at: #FileDescriptor put: nil!
Java.java.io at: #IOException put: nil!
Java.java.io at: #ObjectInputStream put: nil!
Java.java.io at: #VMObjectStreamClass put: nil!

Java.java.lang at: #Character put: nil!
Java.java.lang at: #Class put: nil!
Java.java.lang at: #Cloneable put: nil!
Java.java.lang at: #ConcreteProcess put: nil!
Java.java.lang at: #Double put: nil!
Java.java.lang at: #Float put: nil!
Java.java.lang at: #Math put: nil!
Java.java.lang at: #Object put: nil!
Java.java.lang at: #Runtime put: nil!
Java.java.lang at: #String put: nil!
Java.java.lang at: #StringBuffer put: nil!
Java.java.lang at: #System put: nil!
Java.java.lang at: #Thread put: nil!
Java.java.lang at: #ThreadGroup put: nil!
Java.java.lang at: #VMClassLoader put: nil!

Java.java.lang at: #ArithmeticException put: nil!
Java.java.lang at: #ArrayIndexOutOfBoundsException put: nil!
Java.java.lang at: #ClassCastException put: nil!
Java.java.lang at: #CloneNotSupportedException put: nil!
Java.java.lang at: #IllegalThreadStateException put: nil!
Java.java.lang at: #NullPointerException put: nil!

Java.java.lang.ref at: #Reference put: nil!
Java.java.lang.reflect at: #Array put: nil!
Java.java.lang.reflect at: #Constructor put: nil!
Java.java.lang.reflect at: #Field put: nil!
Java.java.lang.reflect at: #Method put: nil!
Java.java.lang.reflect at: #Proxy put: nil!

Java.java.net at: #InetAddress put: nil!
Java.java.net at: #NetworkInterface put: nil!

Java.java.nio at: #DirectByteBufferImpl put: nil!
Java.java.nio.channels at: #FileChannelImpl put: nil!

Java.java.text at: #Collator put: nil!

Java.java.util at: #ResourceBundle put: nil!
Java.java.util at: #TimeZone put: nil!
Java.java.util.zip at: #Deflater put: nil!
Java.java.util.zip at: #Inflater put: nil!

Namespace current: Java.gnu.smalltalk!

FileStream fileIn: 'JavaRuntime.st'!
FileStream fileIn: 'JavaMetaobjects.st'!
FileStream fileIn: 'JavaClassFiles.st'!
FileStream fileIn: 'JavaTranslation.st'!
FileStream fileIn: 'JavaExtensions.st'!
FileStream fileIn: 'gnu_gcj_convert_IOConverter.st'!
FileStream fileIn: 'gnu_gcj_runtime_StackTrace.st'!
FileStream fileIn: 'gnu_gcj_runtime_StringBuffer.st'!
FileStream fileIn: 'gnu_java_net_PlainDatagramSocketImpl.st'!
FileStream fileIn: 'gnu_java_net_PlainSocketImpl.st'!
FileStream fileIn: 'gnu_java_nio_FileLockImpl.st'!
FileStream fileIn: 'gnu_java_nio_SelectorImpl.st'!
FileStream fileIn: 'java_io_File.st'!
FileStream fileIn: 'java_io_FileDescriptor.st'!
FileStream fileIn: 'java_io_ObjectInputStream.st'!
FileStream fileIn: 'java_io_VMObjectStreamClass.st'!
FileStream fileIn: 'java_lang_Character.st'!
FileStream fileIn: 'java_lang_Class.st'!
FileStream fileIn: 'java_lang_ConcreteProcess.st'!
FileStream fileIn: 'java_lang_Double.st'!
FileStream fileIn: 'java_lang_Float.st'!
FileStream fileIn: 'java_lang_Math.st'!
FileStream fileIn: 'java_lang_Object.st'!
FileStream fileIn: 'java_lang_Runtime.st'!
FileStream fileIn: 'java_lang_String.st'!
FileStream fileIn: 'java_lang_StringBuffer.st'!
FileStream fileIn: 'java_lang_System.st'!
FileStream fileIn: 'java_lang_Thread.st'!
FileStream fileIn: 'java_lang_VMClassLoader.st'!
FileStream fileIn: 'java_lang_ref_Reference.st'!
FileStream fileIn: 'java_lang_reflect_Array.st'!
FileStream fileIn: 'java_lang_reflect_Constructor.st'!
FileStream fileIn: 'java_lang_reflect_Field.st'!
FileStream fileIn: 'java_lang_reflect_Method.st'!
FileStream fileIn: 'java_lang_reflect_Proxy.st'!
FileStream fileIn: 'java_net_InetAddress.st'!
FileStream fileIn: 'java_net_NetworkInterface.st'!
FileStream fileIn: 'java_nio_DirectByteBufferImpl.st'!
FileStream fileIn: 'java_nio_channels_FileChannelImpl.st'!
FileStream fileIn: 'java_text_Collator.st'!
FileStream fileIn: 'java_util_ResourceBundle.st'!
FileStream fileIn: 'java_util_TimeZone.st'!
FileStream fileIn: 'java_util_zip_Deflater.st'!
FileStream fileIn: 'java_util_zip_Inflater.st'!

Namespace current: Smalltalk!

Java.gnu.smalltalk.JavaVM bootstrap!

"(Java.java.lang.Math abs: -3) printNl!"
"(Java.java.lang.String valueOf: FloatD pi) asString printNl!"
"Java.java.lang.System out println: 'che figata'!"
"Java.gnu.smalltalk.JavaVM run: 'prova_eccezioni'!"
"Java.gnu.smalltalk.JavaVM run: 'prova_thread'!"
"(Java.gnu.smalltalk.JavaClass fromString: 'prova6') install!"
"Java.gnu.smalltalk.JavaVM run: 'CaffeineMarkEmbeddedApp'!"
"Java.gnu.smalltalk.JavaVM run: 'JGFLoopBench'!"
