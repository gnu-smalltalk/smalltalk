Netlink_FILES = \
packages/netlink/Extensions.st packages/netlink/Netlink.st packages/netlink/NetlinkTest.st 
$(Netlink_FILES):
$(srcdir)/packages/netlink/stamp-classes: $(Netlink_FILES)
	touch $(srcdir)/packages/netlink/stamp-classes
