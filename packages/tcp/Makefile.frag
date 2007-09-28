TCP_FILES = \
packages/tcp/Buffers.st packages/tcp/Datagram.st packages/tcp/SocketAddress.st packages/tcp/AbstractSocketImpl.st packages/tcp/IPSocketImpl.st packages/tcp/Sockets.st packages/tcp/Tests.st packages/tcp/cfuncs.st packages/tcp/init.st packages/tcp/ChangeLog 
$(TCP_FILES):
$(srcdir)/packages/tcp/stamp-classes: $(TCP_FILES)
	touch $(srcdir)/packages/tcp/stamp-classes
