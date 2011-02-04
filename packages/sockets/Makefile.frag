Sockets_FILES = \
packages/sockets/Buffers.st packages/sockets/Datagram.st packages/sockets/SocketAddress.st packages/sockets/AbstractSocketImpl.st packages/sockets/IPSocketImpl.st packages/sockets/IP6SocketImpl.st packages/sockets/UnixSocketImpl.st packages/sockets/Sockets.st packages/sockets/Tests.st packages/sockets/cfuncs.st packages/sockets/init.st packages/sockets/ChangeLog packages/sockets/UnitTest.st 
$(Sockets_FILES):
$(srcdir)/packages/sockets/stamp-classes: $(Sockets_FILES)
	touch $(srcdir)/packages/sockets/stamp-classes
