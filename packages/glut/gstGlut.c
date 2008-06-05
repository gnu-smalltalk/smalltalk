/******************************** -*- C -*- ****************************
 *
 *	Glut bindings declarations.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008 Free Software Foundation, Inc.
 * Written by Olivier Blanc.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "config.h"
#include "gstpub.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include GL_GL_H
#include GL_GLUT_H

static VMProxy *vm_proxy = NULL;

#define nil  vm_proxy->nilOOP

/* glut.h */

/* The number of events is 30. So for now we fix it */
#define MAX_OPENGL_EVENTS 30

OOP gst_glut_EventsReceivers[MAX_OPENGL_EVENTS];	
OOP gst_glut_classPointer = NULL;

void
gst_glut_connect_signal(OOP receiver, int eventNumber)
{

  /* Get a pointer to OpenGL class to be able to retreive the event number in the callback functions */
  if(! gst_glut_classPointer) {
	gst_glut_classPointer = OOP_CLASS(receiver);
  }

  if(eventNumber < 0 || eventNumber >= MAX_OPENGL_EVENTS)
	return;

  if(gst_glut_EventsReceivers[eventNumber]) {
	vm_proxy->unregisterOOP(gst_glut_EventsReceivers[eventNumber]);
  }

  vm_proxy->registerOOP(receiver);
  gst_glut_EventsReceivers[eventNumber] = receiver;
}

void
gst_glut_SendCallbackMessage(const char* msg, OOP* args, int nArgs)
{
  OOP indexOop, callbackList;
  OOP receiver, selector;
  int eventNumber;

  indexOop = vm_proxy->strMsgSend (gst_glut_classPointer, msg, NULL);
  if (indexOop == nil)
    return;

  eventNumber = vm_proxy->OOPToInt (indexOop);
  if (gst_glut_EventsReceivers[eventNumber] == nil)
    return;

  callbackList = vm_proxy->strMsgSend (gst_glut_EventsReceivers[eventNumber],
				       "getCallback:",
				       vm_proxy->intToOOP (eventNumber),
				       NULL);
  if (callbackList == nil)
    return;

  receiver = OOP_TO_OBJ (callbackList)->data[0];
  selector = OOP_TO_OBJ (callbackList)->data[1];
  selector = selector == vm_proxy->nilOOP ? NULL : selector;
  vm_proxy->nvmsgSend (receiver, selector, args, nArgs);
}


static void 
gst_glut_CreateMenu(  int menu  )
{
  OOP* args = alloca( sizeof(OOP) * 1 );
  args[0] = vm_proxy->intToOOP(menu);

  gst_glut_SendCallbackMessage("createMenuEvent", args, 1);
}

static void 
gst_glut_TimerFunc( int a )
{
  OOP* args = alloca ( sizeof(OOP) * 1 );
  args[0] = vm_proxy->intToOOP(a);
  
  gst_glut_SendCallbackMessage("timerFuncEvent", args, 1);
}

static void 
gst_glut_IdleFunc( )
{
  gst_glut_SendCallbackMessage("idleFuncEvent", &nil, 0);
}

static void 
gst_glut_KeyboardFunc(  unsigned char c, int a, int b  )
{
  OOP* args = alloca ( sizeof(OOP) * 3 );
  args[0] = vm_proxy->charToOOP(c);
  args[1] = vm_proxy->intToOOP(a);
  args[2] = vm_proxy->intToOOP(b);
  
  gst_glut_SendCallbackMessage("keyboardFuncEvent", args, 3);
}


static void 
gst_glut_SpecialFunc( int a, int b, int c )
{
  OOP* args = alloca ( sizeof(OOP) * 3 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  args[2] = vm_proxy->intToOOP(c);
  
  gst_glut_SendCallbackMessage("specialFuncEvent", args, 3);
}

static void 
gst_glut_ReshapeFunc( int a, int b )
{
  OOP* args = alloca ( sizeof(OOP) * 2 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  
  gst_glut_SendCallbackMessage("reshapeFuncEvent", args, 2);
}

static void 
gst_glut_VisibilityFunc(  int a )
{
  OOP* args = alloca ( sizeof(OOP) * 1 );
  args[0] = vm_proxy->intToOOP(a);
  gst_glut_SendCallbackMessage("visibilityFuncEvent", args, 1);
}

static void 
gst_glut_DisplayFunc()
{
  OOP* args = NULL;
  gst_glut_SendCallbackMessage("displayFuncEvent", args, 0);
}

static void 
gst_glut_MouseFunc(  int a, int b, int c, int d )
{
  OOP* args = alloca ( sizeof(OOP) * 4 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  args[2] = vm_proxy->intToOOP(c);
  args[3] = vm_proxy->intToOOP(d);
  
  gst_glut_SendCallbackMessage("mouseFuncEvent", args, 4);
}

static void 
gst_glut_MotionFunc(  int a, int b )
{
  OOP* args = alloca ( sizeof(OOP) * 2 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  
  gst_glut_SendCallbackMessage("motionFuncEvent", args, 2);
}

static void 
gst_glut_PassiveMotionFunc(  int a, int b )
{
  OOP* args = alloca ( sizeof(OOP) * 2 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  
  gst_glut_SendCallbackMessage("passiveMotionFuncEvent", args, 2);
}

static void 
gst_glut_EntryFunc(  int a )
{
  OOP* args = alloca ( sizeof(OOP) * 1 );
  args[0] = vm_proxy->intToOOP(a);

  gst_glut_SendCallbackMessage("entryFuncEvent", args, 1);
}

static void 
gst_glut_KeyboardUpFunc( unsigned char c, int a, int b )
{
  OOP* args = alloca ( sizeof(OOP) * 3 );
  args[0] = vm_proxy->charToOOP(c);
  args[1] = vm_proxy->intToOOP(a);
  args[2] = vm_proxy->intToOOP(b);
  
  gst_glut_SendCallbackMessage("keyboardUpFuncEvent", args, 3);
}

static void 
gst_glut_SpecialUpFunc( int a, int b, int c )
{
  OOP* args = alloca ( sizeof(OOP) * 3 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  args[2] = vm_proxy->intToOOP(c);
  
  gst_glut_SendCallbackMessage("specialUpFuncEvent", args, 3);
}

static void 
gst_glut_MenuStateFunc(  int a )
{
  OOP* args = alloca ( sizeof(OOP) * 1 );
  args[0] = vm_proxy->intToOOP(a);
  
  gst_glut_SendCallbackMessage("menuStateFuncEvent", args, 1);
}

static void 
gst_glut_MenuStatusFunc(  int a, int b, int c )
{
  OOP* args = alloca ( sizeof(OOP) * 3 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  args[2] = vm_proxy->intToOOP(c);
  
  gst_glut_SendCallbackMessage("menuStatusFuncEvent", args, 3);
}

static void 
gst_glut_OverlayDisplayFunc()
{
  
}

static void 
gst_glut_WindowStatusFunc(  int a )
{
}

static void 
gst_glut_SpaceballMotionFunc(  int a, int b, int c )
{
  OOP* args = alloca ( sizeof(OOP) * 3 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  args[2] = vm_proxy->intToOOP(c);
  
  gst_glut_SendCallbackMessage("motionFuncEvent", args, 3);
}

static void 
gst_glut_SpaceballRotateFunc(  int a, int b, int c )
{
}

static void 
gst_glut_SpaceballButtonFunc(  int a, int b )
{
}

static void 
gst_glut_ButtonBoxFunc(  int a, int b )
{
}

static void 
gst_glut_DialsFunc(  int a, int b )
{
}

static void 
gst_glut_TabletMotionFunc(  int a, int b )
{
}

static void 
gst_glut_TabletButtonFunc(  int a, int b, int c, int d )
{
}

static void 
gst_glut_WMCloseFunc()
{
}

#if 0
static void 
gst_glut_JoystickFunc( unsigned int a, int b, int c, int d )
{
  OOP* args = alloca ( sizeof(OOP) * 4 );
  args[0] = vm_proxy->intToOOP(a);
  args[1] = vm_proxy->intToOOP(b);
  args[2] = vm_proxy->intToOOP(c);
  args[3] = vm_proxy->intToOOP(d);
  
  gst_glut_SendCallbackMessage("joystickFuncEvent", args, 4);
}

static void 
gst_glut_MouseWheelFunc(  int a, int b, int c, int d)
{
}

static void 
gst_glut_CloseFunc()
{
}

static void 
gst_glut_MenuDestroyFunc()
{
}
#endif


static void registerCallbacks ()
{
  glutIdleFunc(gst_glut_IdleFunc);
  glutKeyboardFunc(gst_glut_KeyboardFunc);
  glutSpecialFunc(gst_glut_SpecialFunc);
  glutReshapeFunc(gst_glut_ReshapeFunc);
  glutVisibilityFunc(gst_glut_VisibilityFunc);
  glutDisplayFunc(gst_glut_DisplayFunc); 
  glutMouseFunc(gst_glut_MouseFunc);
  glutMotionFunc(gst_glut_MotionFunc);
  glutPassiveMotionFunc(gst_glut_PassiveMotionFunc);
  glutEntryFunc(gst_glut_EntryFunc);
  glutKeyboardUpFunc(gst_glut_KeyboardUpFunc);
  glutSpecialUpFunc(gst_glut_SpecialUpFunc);
  glutMenuStateFunc(gst_glut_MenuStateFunc);
  glutMenuStatusFunc(gst_glut_MenuStatusFunc);
  glutOverlayDisplayFunc(gst_glut_OverlayDisplayFunc);
  glutWindowStatusFunc(gst_glut_WindowStatusFunc);
  glutSpaceballMotionFunc(gst_glut_SpaceballMotionFunc);
  glutSpaceballRotateFunc(gst_glut_SpaceballRotateFunc);
  glutSpaceballButtonFunc(gst_glut_SpaceballButtonFunc);
  glutButtonBoxFunc(gst_glut_ButtonBoxFunc);
  glutDialsFunc(gst_glut_DialsFunc);
  glutTabletMotionFunc(gst_glut_TabletMotionFunc);
  glutTabletButtonFunc(gst_glut_TabletButtonFunc);
  glutWMCloseFunc(gst_glut_WMCloseFunc);

#if 0
  glutJoystickFunc(gst_glut_JoystickFunc);
  glutMouseWheelFunc(gst_glut_MouseWheelFunc);
  glutCloseFunc(gst_glut_CloseFunc);
  glutMenuDestroyFunc(gst_glut_MenuDestroyFunc);
#endif
}

int gst_glut_glutCreateSubWindow (int win, int x, int y, int width, int height)
{
  int id = glutCreateSubWindow (win, x, y, width, height);
  registerCallbacks ();
  return id;
}

int gst_glut_glutCreateWindow (const char *name)
{
  int id = glutCreateWindow (name);
  registerCallbacks ();
  return id;
}

void gst_glut_glutInit( char* argv ) 
{
  int pargc = 1;
  char *v[2] = {argv, NULL};
  glutInit( &pargc, v );
}

int gst_glut_glutCreateMenu( void )
{
  return glutCreateMenu(gst_glut_CreateMenu);
}

void gst_glut_glutTimerFunc( unsigned int time, int value )
{
  glutTimerFunc( time, gst_glut_TimerFunc, value );
}

void
gst_initModule(VMProxy *proxy)
{
  int i;
  vm_proxy = proxy;

  /* Clear the array */
  for(i = 0; i <MAX_OPENGL_EVENTS; ++i)
	gst_glut_EventsReceivers[i] = nil;

  vm_proxy->defineCFunc ("openglutConnectSignal", gst_glut_connect_signal);

  vm_proxy->defineCFunc ("glutInit", gst_glut_glutInit);
  vm_proxy->defineCFunc ("glutInitWindowPosition", glutInitWindowPosition);
  vm_proxy->defineCFunc ("glutInitWindowSize", glutInitWindowSize);
  vm_proxy->defineCFunc ("glutInitDisplayMode", glutInitDisplayMode);
  vm_proxy->defineCFunc ("glutMainLoop", glutMainLoop);
  vm_proxy->defineCFunc ("glutCreateWindow", gst_glut_glutCreateWindow);
  vm_proxy->defineCFunc ("glutCreateSubWindow", gst_glut_glutCreateSubWindow);
  vm_proxy->defineCFunc ("glutDestroyWindow", glutDestroyWindow);
  vm_proxy->defineCFunc ("glutSetWindow", glutSetWindow);
  vm_proxy->defineCFunc ("glutGetWindow", glutGetWindow);
  vm_proxy->defineCFunc ("glutSetWindowTitle", glutSetWindowTitle);
  vm_proxy->defineCFunc ("glutSetIconTitle", glutSetIconTitle);
  vm_proxy->defineCFunc ("glutReshapeWindow", glutReshapeWindow);
  vm_proxy->defineCFunc ("glutPositionWindow", glutPositionWindow);
  vm_proxy->defineCFunc ("glutShowWindow", glutShowWindow);
  vm_proxy->defineCFunc ("glutHideWindow", glutHideWindow);
  vm_proxy->defineCFunc ("glutIconifyWindow", glutIconifyWindow);
  vm_proxy->defineCFunc ("glutPushWindow", glutPushWindow);
  vm_proxy->defineCFunc ("glutPopWindow", glutPopWindow);
  vm_proxy->defineCFunc ("glutFullScreen", glutFullScreen);
  vm_proxy->defineCFunc ("glutPostWindowRedisplay", glutPostWindowRedisplay);
  vm_proxy->defineCFunc ("glutPostRedisplay", glutPostRedisplay);
  vm_proxy->defineCFunc ("glutSwapBuffers", glutSwapBuffers);
  vm_proxy->defineCFunc ("glutWarpPointer", glutWarpPointer);
  vm_proxy->defineCFunc ("glutEstablishOverlay", glutEstablishOverlay);
  vm_proxy->defineCFunc ("glutRemoveOverlay", glutRemoveOverlay);
  vm_proxy->defineCFunc ("glutUseLayer", glutUseLayer);
  vm_proxy->defineCFunc ("glutPostOverlayRedisplay", glutPostOverlayRedisplay);
  vm_proxy->defineCFunc ("glutPostWindowOverlayRedisplay", glutPostWindowOverlayRedisplay);
  vm_proxy->defineCFunc ("glutShowOverlay", glutShowOverlay);
  vm_proxy->defineCFunc ("glutHideOverlay", glutHideOverlay);
  vm_proxy->defineCFunc ("glutCreateMenu", gst_glut_glutCreateMenu);
  vm_proxy->defineCFunc ("glutDestroyMenu", glutDestroyMenu);
  vm_proxy->defineCFunc ("glutGetMenu", glutGetMenu);
  vm_proxy->defineCFunc ("glutSetMenu", glutSetMenu);
  vm_proxy->defineCFunc ("glutAddMenuEntry", glutAddMenuEntry);
  vm_proxy->defineCFunc ("glutAddSubMenu", glutAddSubMenu);
  vm_proxy->defineCFunc ("glutChangeToMenuEntry", glutChangeToMenuEntry);
  vm_proxy->defineCFunc ("glutChangeToSubMenu", glutChangeToSubMenu);
  vm_proxy->defineCFunc ("glutRemoveMenuItem", glutRemoveMenuItem);
  vm_proxy->defineCFunc ("glutAttachMenu", glutAttachMenu);
  vm_proxy->defineCFunc ("glutDetachMenu", glutDetachMenu);
  vm_proxy->defineCFunc ("glutTimerFunc", gst_glut_glutTimerFunc);

  vm_proxy->defineCFunc ("glutGet", glutGet);
  vm_proxy->defineCFunc ("glutDeviceGet", glutDeviceGet);
  vm_proxy->defineCFunc ("glutGetModifiers", glutGetModifiers);
  vm_proxy->defineCFunc ("glutLayerGet", glutLayerGet);
  vm_proxy->defineCFunc ("glutBitmapCharacter", glutBitmapCharacter);
  vm_proxy->defineCFunc ("glutBitmapWidth", glutBitmapWidth);
  vm_proxy->defineCFunc ("glutStrokeCharacter", glutStrokeCharacter);
  vm_proxy->defineCFunc ("glutStrokeWidth", glutStrokeWidth);
  vm_proxy->defineCFunc ("glutBitmapLength", glutBitmapLength);
  vm_proxy->defineCFunc ("glutStrokeLength", glutStrokeLength);
  vm_proxy->defineCFunc ("glutWireCube", glutWireCube);
  vm_proxy->defineCFunc ("glutSolidCube", glutSolidCube);
  vm_proxy->defineCFunc ("glutWireSphere", glutWireSphere);
  vm_proxy->defineCFunc ("glutSolidSphere", glutSolidSphere);
  vm_proxy->defineCFunc ("glutWireCone", glutWireCone);
  vm_proxy->defineCFunc ("glutSolidCone", glutSolidCone);
  vm_proxy->defineCFunc ("glutWireTorus", glutWireTorus);
  vm_proxy->defineCFunc ("glutSolidTorus", glutSolidTorus);
  vm_proxy->defineCFunc ("glutWireDodecahedron", glutWireDodecahedron);
  vm_proxy->defineCFunc ("glutSolidDodecahedron", glutSolidDodecahedron);
  vm_proxy->defineCFunc ("glutWireOctahedron", glutWireOctahedron);
  vm_proxy->defineCFunc ("glutSolidOctahedron", glutSolidOctahedron);
  vm_proxy->defineCFunc ("glutWireTetrahedron", glutWireTetrahedron);
  vm_proxy->defineCFunc ("glutSolidTetrahedron", glutSolidTetrahedron);
  vm_proxy->defineCFunc ("glutWireIcosahedron", glutWireIcosahedron);
  vm_proxy->defineCFunc ("glutSolidIcosahedron", glutSolidIcosahedron);
  vm_proxy->defineCFunc ("glutWireTeapot", glutWireTeapot);
  vm_proxy->defineCFunc ("glutSolidTeapot", glutSolidTeapot);
  vm_proxy->defineCFunc ("glutGameModeString", glutGameModeString);
  vm_proxy->defineCFunc ("glutEnterGameMode", glutEnterGameMode);
  vm_proxy->defineCFunc ("glutLeaveGameMode", glutLeaveGameMode);
  vm_proxy->defineCFunc ("glutGameModeGet", glutGameModeGet);
  vm_proxy->defineCFunc ("glutVideoResizeGet", glutVideoResizeGet);
  vm_proxy->defineCFunc ("glutSetupVideoResizing", glutSetupVideoResizing);
  vm_proxy->defineCFunc ("glutStopVideoResizing", glutStopVideoResizing);
  vm_proxy->defineCFunc ("glutVideoResize", glutVideoResize);
  vm_proxy->defineCFunc ("glutVideoPan", glutVideoPan);
  vm_proxy->defineCFunc ("glutSetColor", glutSetColor);
  vm_proxy->defineCFunc ("glutGetColor", glutGetColor);
  vm_proxy->defineCFunc ("glutCopyColormap", glutCopyColormap);
  vm_proxy->defineCFunc ("glutIgnoreKeyRepeat", glutIgnoreKeyRepeat);
  vm_proxy->defineCFunc ("glutSetKeyRepeat", glutSetKeyRepeat);
  vm_proxy->defineCFunc ("glutExtensionSupported", glutExtensionSupported);
  vm_proxy->defineCFunc ("glutReportErrors", glutReportErrors);

  vm_proxy = vm_proxy;
}

