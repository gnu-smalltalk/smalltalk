NetClients_FILES = \
packages/net/Base.st packages/net/ChangeLog packages/net/ContentHandler.st packages/net/FTP.st packages/net/HTTP.st packages/net/IMAP.st packages/net/IMAPTests.st packages/net/MIME.st packages/net/NetServer.st packages/net/NNTP.st packages/net/POP.st packages/net/SMTP.st packages/net/URIResolver.st 
$(NetClients_FILES):
$(srcdir)/packages/net/stamp-classes: $(NetClients_FILES)
	touch $(srcdir)/packages/net/stamp-classes
