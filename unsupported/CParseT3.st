FileStream require: #CTypeParser -> 'CParseType.st'!

ObjectMemory snapshot!

| x |
     CTypeParser test2: '/usr/include/X11/Xproto.h'
!


| x |
     CTypeParser test2: '/usr/include/X11/Xprotostr.h'
!

ObjectMemory quit!

| x |
     CTypeParser test2: '/usr/include/libio.h'
!

ObjectMemory quit!


| x |
     "CTypeParser test2: '/usr/include/sys/cdefs.h'"
     CTypeParser test2: '../sublibio.h'
!



