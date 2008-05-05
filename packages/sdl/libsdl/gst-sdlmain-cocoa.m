/******************************** -*- C -*- ****************************
 *
 *	libsdl-Cocoa bindings for GNU Smalltalk.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini based on sdlmain.m (from LibSDL, public domain).
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#import "gst-sdl.h"
#import <Cocoa/Cocoa.h>
#import <unistd.h>

@interface GSTCocoaMainApplication : NSApplication
@end

@interface GSTCocoaMain : NSObject
@end

/* setAppleMenu disappeared from the headers in 10.4 */
@interface NSApplication(NSAppleMenu)
- (void)setAppleMenu:(NSMenu *)menu;
@end

static OOP			eventLoopBlockOOP;
static NSAutoreleasePool	*pool;
static GSTCocoaMain		*cocoaMain;

@implementation GSTCocoaMainApplication
/* Invoked from the Quit menu item */
- (void)terminate:(id)sender
{
  /* Post a SDL_QUIT event */
  SDL_Event event;
  event.type = SDL_QUIT;
  SDL_PushEvent(&event);
}
@end


/* The main class of the application, the application's delegate */
@implementation GSTCocoaMain


static NSString *get_application_name ()
{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *applicationName = [infoDictionary objectForKey:@"CFBundleName"];
        if (!applicationName) {
                applicationName = [infoDictionary objectForKey:@"CFBundleExecutable"];
		if (!applicationName) {
		    applicationName = [[NSProcessInfo processInfo] processName];
		}
        }
        return applicationName;
}

static void setup_apple_menu(void)
{
  NSString *appName;
  NSString *title;
  NSMenu *appleMenu;
  NSMenu *windowMenu;
  NSMenuItem *menuItem;
  
  /* Create the main menu bar */
  [NSApp setMainMenu:[[NSMenu alloc] init]];

  /* Create the application menu */
  appName = get_application_name();
  appleMenu = [[NSMenu alloc] initWithTitle:@""];
  
  /* Add menu items */
  title = [@"About " stringByAppendingString:appName];
  [appleMenu addItemWithTitle:title action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];

  [appleMenu addItem:[NSMenuItem separatorItem]];

  title = [@"Hide " stringByAppendingString:appName];
  [appleMenu addItemWithTitle:title action:@selector(hide:) keyEquivalent:@"h"];

  menuItem = (NSMenuItem *)[appleMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
  [menuItem setKeyEquivalentModifierMask:(NSAlternateKeyMask|NSCommandKeyMask)];

  [appleMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];

  [appleMenu addItem:[NSMenuItem separatorItem]];

  title = [@"Quit " stringByAppendingString:appName];
  [appleMenu addItemWithTitle:title action:@selector(terminate:) keyEquivalent:@"q"];
  
  /* Put menu into the menubar */
  menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
  [menuItem setSubmenu:appleMenu];
  [[NSApp mainMenu] addItem:menuItem];
  [menuItem release];

  /* Tell the application object that this is now the application menu */
  [NSApp setAppleMenu:appleMenu];
  [appleMenu release];
}

/* Create a window menu */
static void setup_window_menu(void)
{
  NSMenu		*windowMenu;
  NSMenuItem	*windowMenuItem;
  NSMenuItem	*menuItem;


  windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
  
  /* "Minimize" item */
  menuItem = [[NSMenuItem alloc] initWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
  [windowMenu addItem:menuItem];
  [menuItem release];
  
  /* Put menu into the menubar */
  windowMenuItem = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
  [windowMenuItem setSubmenu:windowMenu];
  [[NSApp mainMenu] addItem:windowMenuItem];
  
  /* Tell the application object that this is now the window menu */
  [NSApp setWindowsMenu:windowMenu];

  /* Finally give up our references to the objects */
  [windowMenu release];
  [windowMenuItem release];
}

static void gst_SDL_Quit ()
{
  SDL_Quit ();
  [cocoaMain release];
  [pool release];
}

/* Replacement for NSApplicationMain */
int
gst_SDL_Init (Uint32 flags)
{
  int rc;
  ProcessSerialNumber psn;

  pool = [[NSAutoreleasePool alloc] init];

  /* Ensure the application object is initialised */
  if (!GetCurrentProcess(&psn))
    {
      TransformProcessType(&psn, kProcessTransformToForegroundApplication);
      SetFrontProcess(&psn);
    }

  [GSTCocoaMainApplication sharedApplication];
    
  /* Set up the menubar */
  [NSApp setMainMenu:[[NSMenu alloc] init]];
  setup_apple_menu();
  setup_window_menu();
  [NSApp finishLaunching];
    
  /* Create GSTCocoaMain and make it the app delegate */
  cocoaMain = [[GSTCocoaMain alloc] init];
  [NSApp setDelegate:cocoaMain];

  rc = SDL_Init (flags);
  if (rc < 0)
    return rc;

  atexit (gst_SDL_Quit);
  return rc;
}
    
void
gst_SDL_StartEventLoop (OOP blockOOP)
{
  eventLoopBlockOOP = blockOOP;

  /* Start the main event loop */
  [NSApp run];
}

void
gst_SDL_StopEventLoop (void)
{
  [NSApp stop: NSApp];
}

/* Called when the internal event loop has just started running */
- (void) applicationDidFinishLaunching: (NSNotification *) note
{
  vmProxy->strMsgSend (eventLoopBlockOOP, "value", NULL);
}
@end
