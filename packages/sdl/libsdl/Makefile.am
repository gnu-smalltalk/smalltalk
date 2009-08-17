gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
        -no-undefined -export-symbols-regex gst_initModule

moduleexec_LTLIBRARIES = sdl.la
sdl_la_SOURCES = gst-sdl.c
sdl_la_LIBADD = $(SDL_LIBS)
sdl_la_LDFLAGS = $(gst_module_ldflags)

if HAVE_COCOA
sdl_la_SOURCES += gst-sdlmain-cocoa.m
endif

noinst_HEADERS = gst-sdl.h

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src $(SDL_CFLAGS)
