"======================================================================
|
|   Glut Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Olivier Blanc.
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



Object subclass: Glut [
    <category: 'OpenGL'>
    <comment: 'My instances are interfaces to OpenGL library with access to Glut.
See OpenGL programming guide for more informations.'>

    | init |
    glutInit: aName [
	<category: 'GLUT'>
	init isNil 
	    ifTrue: 
		[self cacheGlutInit: aName.
		init := true]
    ]

    cacheGlutInit: aName [
	<category: 'GLUT'>
	<cCall: 'glutInit' returning: #void args: #( #string )>
	
    ]

    glutInitWindowPosition: aVertex [
	<category: 'GLUT'>
	self glutInitWindowPosition: aVertex x asInteger y: aVertex y asInteger
    ]

    glutInitWindowPosition: aX y: aY [
	<category: 'GLUT'>
	<cCall: 'glutInitWindowPosition' returning: #void args: #( #int #int )>
	
    ]

    glutInitWindowSize: aVertex [
	<category: 'GLUT'>
	self glutInitWindowSize: aVertex x asInteger height: aVertex y asInteger
    ]

    glutInitWindowSize: x height: y [
	<category: 'GLUT'>
	<cCall: 'glutInitWindowSize' returning: #void args: #( #int #int )>
	
    ]

    glutInitDisplayMode: mode [
	<category: 'GLUT'>
	<cCall: 'glutInitDisplayMode' returning: #void args: #( #int )>
	
    ]

    glutMainLoop [
	<category: 'GLUT'>
	<cCall: 'glutMainLoop' returning: #void args: #()>
	
    ]

    glutCreateWindow: aName [
	<category: 'GLUT'>
	<cCall: 'glutCreateWindow' returning: #int args: #( #string )>
	
    ]

    glutCreateSubWindow: aWindow from: startPoint to: size [
	<category: 'GLUT'>
	self 
	    glutCreateSubWindow: aWindow
	    x: startPoint x
	    y: startPoint y
	    width: size x
	    height: size y
    ]

    glutCreateSubWindow: aWindow x: startPointX y: startPointY width: sizeX height: sizeY [
	<category: 'GLUT'>
	<cCall: 'glutCreateSubWindow' returning: #int args: #( #int #int #int #int #int )>
	
    ]

    glutDestroyWindow [
	<category: 'GLUT'>
	<cCall: 'glutDestroyWindow' returning: #void args: #( #int )>
	
    ]

    glutSetWindow: aWindow [
	<category: 'GLUT'>
	<cCall: 'glutSetWindow' returning: #void args: #( #int )>
	
    ]

    glutGetWindow [
	<category: 'GLUT'>
	<cCall: 'glutGetWindow' returning: #int args: #( #void )>
	
    ]

    glutSetWindowTitle: aTitle [
	<category: 'GLUT'>
	<cCall: 'glutSetWindowTitle' returning: #void args: #( #string )>
	
    ]

    glutSetIconTitle: aTitle [
	<category: 'GLUT'>
	<cCall: 'glutSetIconTitle' returning: #void args: #( #string )>
	
    ]

    glutReshapeWindow: aVertex [
	<category: 'GLUT'>
	self glutReshapeWindow: aVertex x asInteger height: aVertex y asInteger
    ]

    glutReshapeWindow: aWidth height: aHeight [
	<category: 'GLUT'>
	<cCall: 'glutReshapeWindow' returning: #void args: #( #int #int )>
	
    ]

    glutPositionWindow: aVertex [
	<category: 'GLUT'>
	self glutPositionWindow: aVertex x asInteger height: aVertex y asInteger
    ]

    glutPositionWindow: aX y: ay [
	<category: 'GLUT'>
	<cCall: 'glutPositionWindow' returning: #void args: #( #int #int )>
	
    ]

    glutShowWindow [
	<category: 'GLUT'>
	<cCall: 'glutShowWindow' returning: #void args: #( )>
	
    ]

    glutHideWindow [
	<category: 'GLUT'>
	<cCall: 'glutHideWindow' returning: #void args: #( )>
	
    ]

    glutIconifyWindow [
	<category: 'GLUT'>
	<cCall: 'glutIconifyWindow' returning: #void args: #( )>
	
    ]

    glutPushWindow [
	<category: 'GLUT'>
	<cCall: 'glutPushWindow' returning: #void args: #( )>
	
    ]

    glutPopWindow [
	<category: 'GLUT'>
	<cCall: 'glutPopWindow' returning: #void args: #( )>
	
    ]

    glutFullScreen [
	<category: 'GLUT'>
	<cCall: 'glutFullScreen' returning: #void args: #( )>
	
    ]

    glutPostWindowRedisplay: aWindow [
	<category: 'GLUT'>
	<cCall: 'glutPostWindowRedisplay' returning: #void args: #( #int )>
	
    ]

    glutPostRedisplay [
	<category: 'GLUT'>
	<cCall: 'glutPostRedisplay' returning: #void args: #()>
	
    ]

    glutSwapBuffers [
	<category: 'GLUT'>
	<cCall: 'glutSwapBuffers' returning: #void args: #( )>
	
    ]

    glutWarpPointers: aVertex [
	<category: 'GLUT'>
	self glutWarpPointers: aVertex x asInteger y: aVertex y asInteger
    ]

    glutWarpPointers: aX y: aY [
	<category: 'GLUT'>
	<cCall: 'glutPostRedisplay' returning: #void args: #( #int #int )>
	
    ]

    glutEstablishOverlay [
	<category: 'GLUT'>
	<cCall: 'glutEstablishOverlay' returning: #void args: #( )>
	
    ]

    glutRemoveOverlay [
	<category: 'GLUT'>
	<cCall: 'glutRemoveOverlay' returning: #void args: #( )>
	
    ]

    glutUseLayer: aLayer [
	<category: 'GLUT'>
	<cCall: 'glutUseLayer' returning: #void args: #( #int )>
	
    ]

    glutPostOverlayRedisplay [
	<category: 'GLUT'>
	<cCall: 'glutPostOverlayRedisplay' returning: #void args: #( )>
	
    ]

    glutPostWindowOverlayRedisplay: aWindow [
	<category: 'GLUT'>
	<cCall: 'glutPostWindowOverlayRedisplay' returning: #void args: #( #int )>
	
    ]

    glutShowOverlay [
	<category: 'GLUT'>
	<cCall: 'glutShowOverlay' returning: #void args: #( )>
	
    ]

    glutHideOverlay [
	<category: 'GLUT'>
	<cCall: 'glutHideOverlay' returning: #void args: #( )>
	
    ]

    glutCreateMenu: aSymbol [
	"glutCreateMenu A creer... cependant il y a un callback !"

	<category: 'GLUT'>
	<cCall: 'glutCreateMenu' returning: #int args: #( #smalltalk )>
	
    ]

    glutDestroyMenu: aMenu [
	<category: 'GLUT'>
	<cCall: 'glutDestroyMenu' returning: #void args: #( #int )>
	
    ]

    glutGetMenu [
	<category: 'GLUT'>
	<cCall: 'glutGetMenu' returning: #int args: #( )>
	
    ]

    glutSetMenu: aMenu [
	<category: 'GLUT'>
	<cCall: 'glutSetMenu' returning: #void args: #( #int )>
	
    ]

    glutAddMenuEntry: aLabel value: aValue [
	<category: 'GLUT'>
	<cCall: 'glutAddMenuEntry' returning: #void args: #( #string #int )>
	
    ]

    glutAddSubMenu: aLabel subMenu: aSubMenu [
	<category: 'GLUT'>
	<cCall: 'glutAddSubMenu' returning: #void args: #( #string #int )>
	
    ]

    glutChangeToMenuEntry: aItem label: aLabel value: aValue [
	<category: 'GLUT'>
	<cCall: 'glutChangeToMenuEntry' returning: #void args: #( #int #string #int )>
	
    ]

    glutChangeToSubMenu: aItem label: aLabel value: aValue [
	<category: 'GLUT'>
	<cCall: 'glutChangeToSubMenu' returning: #void args: #( #int #string #int )>
	
    ]

    glutRemoveMenuItem: item [
	<category: 'GLUT'>
	<cCall: 'glutRemoveMenuItem' returning: #void args: #( #int )>
	
    ]

    glutAttachMenu: button [
	<category: 'GLUT'>
	<cCall: 'glutAttachMenu' returning: #void args: #( #int )>
	
    ]

    glutDetachMenu: button [
	<category: 'GLUT'>
	<cCall: 'glutDetachMenu' returning: #void args: #( #int )>
	
    ]

    glutTimerFunc: time value: aValue [
	<category: 'GLUT'>
	<cCall: 'glutTimerFunc' returning: #void args: #( #int #int)>
	
    ]

    glutGet: aQuery [
	<category: 'GLUT'>
	<cCall: 'glutGet' returning: #int args: #( #int )>
	
    ]

    glutDeviceGet: aQuery [
	<category: 'GLUT'>
	<cCall: 'glutDeviceGet' returning: #int args: #( #int )>
	
    ]

    glutGetModifiers [
	<category: 'GLUT'>
	<cCall: 'glutGetModifiers' returning: #int args: #( )>
	
    ]

    glutLayerGet: aQuery [
	<category: 'GLUT'>
	<cCall: 'glutLayerGet' returning: #int args: #( #int )>
	
    ]

    glutGameModeString: aString [
	<category: 'GLUT'>
	<cCall: 'glutGameModeString' returning: #void args: #( #string )>
	
    ]

    glutEnterGameMode [
	<category: 'GLUT'>
	<cCall: 'glutEnterGameMode' returning: #void args: #( )>
	
    ]

    glutLeaveGameMode [
	<category: 'GLUT'>
	<cCall: 'glutLeaveGameMode' returning: #void args: #( )>
	
    ]

    glutGameModeGet: aQuery [
	<category: 'GLUT'>
	<cCall: 'glutGameModeGet' returning: #int args: #( #int )>
	
    ]

    glutVideoResizeGet: aQuery [
	<category: 'GLUT'>
	<cCall: 'glutVideoResizeGet' returning: #int args: #( #int )>
	
    ]

    glutSetupVideoResizing [
	<category: 'GLUT'>
	<cCall: 'glutSetupVideoResizing' returning: #void args: #( )>
	
    ]

    glutStopVideoResizing [
	<category: 'GLUT'>
	<cCall: 'glutStopVideoResizing' returning: #void args: #( )>
	
    ]

    glutVideoResize: startPoint to: aSize [
	<category: 'GLUT'>
	self 
	    glutVideoResize: startPoint x
	    y: startPoint y
	    width: aSize x
	    height: aSize y
    ]

    glutVideoResize: x y: y width: width height: height [
	<category: 'GLUT'>
	<cCall: 'glutVideoResize' returning: #void args: #( #int #int #int #int )>
	
    ]

    glutVideoPan: startPoint to: aSize [
	<category: 'GLUT'>
	self 
	    glutVideoPan: startPoint x
	    y: startPoint y
	    width: aSize x
	    height: aSize y
    ]

    glutVideoPan: x y: y width: width height: height [
	<category: 'GLUT'>
	<cCall: 'glutVideoPan' returning: #void args: #( #int #int #int #int )>
	
    ]

    glutSetColor: colorNumber color: aColor [
	<category: 'GLUT'>
	self 
	    glutSetColor: colorNumber
	    red: aColor red
	    green: aColor green
	    blue: aColor blue
    ]

    glutSetColor: colorNumber red: red green: green blue: blue [
	<category: 'GLUT'>
	<cCall: 'glutSetColor' returning: #void args: #( #int #float #float #float )>
	
    ]

    glutGetColor: colorNumber [
	<category: 'GLUT'>
	^Color 
	    red: (self glutGetColor: colorNumber component: Glut glutRed)
	    green: (self glutGetColor: colorNumber component: Glut glutGreen)
	    blue: (self glutGetColor: colorNumber component: Glut glutBlue)
    ]

    glutGetColor: colorNumber component: aComponent [
	<category: 'GLUT'>
	<cCall: 'glutGetColor' returning: #void args: #( #int #int )>
	
    ]

    glutCopyColormap: window [
	<category: 'GLUT'>
	<cCall: 'glutCopyColormap' returning: #void args: #( #int )>
	
    ]

    glutIgnoreKeyRepeat: ingnore [
	<category: 'GLUT'>
	<cCall: 'glutIgnoreKeyRepeat' returning: #void args: #( #int )>
	
    ]

    glutSetKeyRepeat: repeatMode [
	<category: 'GLUT'>
	<cCall: 'glutSetKeyRepeat' returning: #void args: #( #int )>
	
    ]

    glutExtensionSupported: extension [
	<category: 'GLUT'>
	<cCall: 'glutExtensionSupported' returning: #int args: #( #string )>
	
    ]

    glutReportErrors [
	<category: 'GLUT'>
	<cCall: 'glutReportErrors' returning: #void args: #( )>
	
    ]

    mainIteration [
	<category: 'Main interactions'>
	^ ([self realMainIteration] 
		forkAt: Processor userBackgroundPriority)
	    name: 'OpenGLMainIteration';
		resume;
		yourself
	
    ]

    realMainIteration [
	<category: 'Main interactions'>
	<cCall: 'glutMainLoop' returning: #void args: #( )>
	
    ]

    openGLInterface [
	<category: 'context'>
	^OpenGLInterface current
    ]

    doesNotUnderstand: aMessage [
	<category: 'context'>
	^aMessage sendTo: self openGLInterface
    ]
]

