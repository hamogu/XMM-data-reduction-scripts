SUBDIRS = 0119700201  0120900201  0121920101  0134720801  0134721501  0134722001  0510780201 0119700301  0121500301  0134720101  0134720901  0134721601  0134722101  0510780401 0119700401  0121500401  0134720401  0134721001  0134721701  0510780101  0510780501

#SUBDIRS = 0119700201  0121920101  0134720801  0134721501  0134722001  0510780201 0119700301  0121500301  0134720101  0134720901  0134721601  0134722101  0510780401 0119700401  0121500401  0134720401  0134721001  0134721701  0510780101  0510780501



ORIGIN = /data/hguenther/obs/XMM/scripts
SRCFILES = /data/hguenther/John/my_processing/makefiles
FLARE = 0134721501

.PHONY: subdirs $(SUBDIRS) noflare

subdirs: $(SUBDIRS) noflare

makefile : $(ORIGIN)/makefile
	cp $< $@

defaults.mk : $(ORIGIN)/defaults.mk
	cp $< $@

$(SUBDIRS):
	# Auto update makefile in subdir from master make
	$(MAKE) -C $@ makefile -f $(ORIGIN)/master.mk
	$(MAKE) -C $@ defaults.mk -f $(ORIGIN)/master.mk
	#$(MAKE) -C $@ EPIC_prepare
	#$(MAKE) -C $@ clean_EPIC
	cp $(SRCFILES)/$@.src $@/
	$(MAKE) -C $@ SRCFILE=$@.src EPIC

# deal with those ObsIDs which need anoflare filtering and have special noflare src files
# in this setup it only works if that is only one dir!
#otherwise need some string procession to get the _noflare part removed from dir name
noflare : $(FLARE)
	cp $(SRCFILES)/$<_noflare.src $</
	$(MAKE) -C $< SRCFILE=$<_noflare.src EPIC

#SRC=$@.src
# in /media/MAX/moritz/obs/XMM/
# make subdirs -f /data/hguenther/obs/XMM/scripts/master.mk -k -j 3
# -j 3: Do parallel, but max 3 processes at a time. I have dual core, if I use much more, than it's swapping all the time.
