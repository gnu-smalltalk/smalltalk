"======================================================================
|
|   Test dynamic linking system
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
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


!Object methodsFor: 'experimentation'!

makeCModule: fileRoot
    | p |
    p := FileStream open: fileRoot, '.c' mode: 'w'.
    p nextPutAll: '
int foo()
{
    static value = 0;

    return (value++);
}
'.
    p close
!

makeC
    self makeCModule: 'xxx'.
!

compileCModule: fileRoot
    | p |
    p := FileStream popen: 'cc -c ', fileRoot, '.c' dir: 'r'.
    " cpp errors = 512, syntax errors = 256 "
    ^p close
!

compileC
    'compile c' printNl.
    (self compileCModule: 'xxx') printNl.
!

loadCModule: fileRoot
    'load c module ' print. fileRoot printNl.
    (DLD addLibrary: fileRoot, '.o') printNl.
!
    

loadC
    | p |
    self loadCModule: 'xxx'.
    Object defineExternFunc: 'foo'
	withSelectorArgs: 'foo'
	returning: #int
	args: #().
!

callC
    nil foo printNl.
    nil foo printNl.

! !


nil makeC!

nil compileC!

nil loadC!

(Object compiledMethodAt: #foo) inspect!

nil callC!


Object
	defineCFunc: 'testDLD'
	withSelectorArgs: 'testDLD'
	returning: #void
	args: #()
!

nil testDLD!
