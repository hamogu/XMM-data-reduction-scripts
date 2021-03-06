SUBDIRS = 0152260101 0693390101



ORIGIN = /nfs/melkor/d1/guenther/soft/XMM-data-reduction-scripts
SRCFILES = /nfs/melkor/d1/guenther/projects/Cepheids/XMM
FLARE = 

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
	$(MAKE) -C $@ SRCFILE=$@.src EPIC_prepare
	#cp $(SRCFILES)/$@.src $@/
	#$(MAKE) -C $@ SRCFILE=$@.src EPIC_lc
	#$(MAKE) -C $@ clean_EPIC
	#$(MAKE) -C $@ SRCFILE=$@.src EPIC

# deal with those ObsIDs which need anoflare filtering and have special noflare src files
# in this setup it only works if that is only one dir!
#otherwise need some string procession to get the _noflare part removed from dir name
noflare : $(FLARE)
	cp $(SRCFILES)/$<_noflare.src $</
	$(MAKE) -C $< SRCFILE=$<_noflare.src EPIC

# in /media/MAX/moritz/obs/XMM/
# make subdirs -f /nfs/melkor/d1/guenther/soft/XMM-data-reduction-scripts/master.mk -k -j 3
# -j 3: Do parallel, but max 3 processes at a time. I have dual core, if I use much more, than it's swapping all the time.
