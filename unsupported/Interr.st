"======================================================================
|
|   Test interrupt handling
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000, 2005 Free Software Foundation, Inc.
| Written by Steve Byrne.
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

DLD addLibrary: 'libc'!

SystemDictionary defineCFunc: 'fcntl'
    withSelectorArgs: 'fcntl: fd cmd: cmd arg: arg'
    returning: #int
    args: #(#int #int #int)!

| mask |
    mask := (Smalltalk fcntl: 0 cmd: 3 arg: 0).
    mask := mask bitOr: 16r40.
    Smalltalk fcntl: 0 cmd: 4 arg: mask.
!


| sem |
       sem := Semaphore new.
       Processor signal: sem onInterrupt: 23.
       [ [ sem wait. stdin next printNl.
	 'running' printNl. Processor yield. true ] whileTrue ] fork.
       [ Processor yield. true ] whileTrue.
       'back from yielding' printNl.
!
