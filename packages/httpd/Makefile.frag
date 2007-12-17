WebServer_FILES = \
packages/httpd/FileServer.st packages/httpd/Haiku.st packages/httpd/STT.st packages/httpd/WebServer.st packages/httpd/WikiServer.st packages/httpd/edit.jpg packages/httpd/example1.stt packages/httpd/example2.stt packages/httpd/find.jpg packages/httpd/head.jpg packages/httpd/help.jpg packages/httpd/history.jpg packages/httpd/next.jpg packages/httpd/prev.jpg packages/httpd/recent.jpg packages/httpd/rename.jpg packages/httpd/test.st packages/httpd/top.jpg packages/httpd/ChangeLog 
$(WebServer_FILES):
$(srcdir)/packages/httpd/stamp-classes: $(WebServer_FILES)
	touch $(srcdir)/packages/httpd/stamp-classes
