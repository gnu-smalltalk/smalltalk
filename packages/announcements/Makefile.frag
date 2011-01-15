Announcements_FILES = \
packages/announcements/Announcements.st packages/announcements/AnnouncementsTests.st 
$(Announcements_FILES):
$(srcdir)/packages/announcements/stamp-classes: $(Announcements_FILES)
	touch $(srcdir)/packages/announcements/stamp-classes
