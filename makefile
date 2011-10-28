# This makefile processes a single source for each run.
# To process multiple sources for one or more observation
# call with different SRCFILE= parameters.

### Source parameters ###
# The parameters for source extraction can be defined (in order of precedence)
# * as command line parameters
# * in $(SRCFILE) (a makefile, which defines these parameters)
# * here 

# include settings for the filter expression in spectral extraction,
# default energy ranges for lcs, the directory structure etc.
include defaults.mk

# Source name for filenames
SRC = 
# MOS and PN expressions for source and bg extractions regions
MOS_SRC = 
MOS_BG = 
PN_SRC = 
PN_BG = 

#list all *im.fits files where no spectra shold be extracted (e.g. target outside FOV)
NO_SPEC = 
#list all *im.fits files where no lightcurves shold be extracted (e.g. target outside FOV)
NO_LC = 

# Try to include $(SRCFILE) if it exists
# This overwrite all variables defined above.
-include $(SRCFILE)


.DEFAULT_GOAL := no_target

SHELL = /bin/sh

.PHONY: EPIC_image EPIC_spectra EPIC_lc EPIC_all EPIC_prepare no_target clean_EPIC_lc clean_EPIC_spectra clean_EPIC_SRC clean_EPIC clean clean_all
# keep all intermediate files - they are .rmf .arf
.SECONDARY :

no_target :
	@echo No default target set!

#ifneq ($(MASTERMAKE),)
# makefile : $(MASTERMAKE)
# 	cp $(MASTERMAKE) .
#endif

ccf.cif : $(ODFDIR)/*.FIT
	cifbuild
	
$(ODFDIR)/*.SAS : $(ODFDIR)/*.ASC ccf.cif $(ODFDIR)/*.FIT
	odfingest outdir=$(SAS_ODF) odfdir=$(SAS_ODF)

EPIC_prepare :
	-gunzip $(SAS_ODF)/*.gz
	$(MAKE) ccf.cif
	$(MAKE) $(ODFDIR)/*.SAS
	emproc
	epproc


*EMOS*_ImagingEvts.ds: $(ODFDIR)/*.SAS ccf.cif $(ODFDIR)/*.FIT
	emproc

*EPN*_ImagingEvts.ds: $(ODFDIR)/*.SAS ccf.cif $(ODFDIR)/*.FIT
	epproc

# use eval here, because variables normally cannot be defined within recepies. That should be taken care of by the definition of targets, but unfortunately, this would require %EMOS% and only one % is allowed.

%_he_lc.fits : %_ImagingEvts.ds
	echo $(MOS_he)
	$(eval expr = $(if $(findstring EMOS, $*),$(MOS_he),$(PN_he)))
	evselect table=$< withrateset=true rateset=$@ makeratecolumn=yes timecolumn=TIME timebinsize=100 maketimecolumn=yes expression=$(expr)

# Filter eventfile for spectral analysis (good events; GTI; 0.15-15.0 keV; single+double only)
%_gti.fits : %_he_lc.fits
	$(eval expr = $(if $(findstring EMOS, $*),$(MOS_gti),$(PN_gti)))
	tabgtigen table=$< expression=$(expr) gtiset=$@
	
%_filt.fits : %_ImagingEvts.ds %_gti.fits
	$(eval expr = $(if $(findstring EMOS, $*),$(MOS_filt),$(PN_filt)))
	evselect table=$< withfilteredset=true filteredset=$@ keepfilteroutput=true destruct=yes expression="(gti($*_gti.fits,TIME) && $(expr))"


%_im.fits : %_filt.fits
	evselect table=$< withimageset=true imageset=$@ xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=50 yimagebinsize=50
        -echo Run the following command to view images:
	-echo ds9 -log -cmap heat $*_im.fits &

EPIC_images : $(patsubst %_ImagingEvts.ds,%_im.fits,$(wildcard *_ImagingEvts.ds))

# Get Source events + Pile up check (set sigma if desired !)
# Could I simplify this with especget instead of separate evselect, rmfgen, arfgen?

$(SRC)_%_filts.fits : %_filt.fits makefile $(SRCFILE)
	$(eval src = $(if $(findstring EMOS, $*),$(MOS_SRC),$(PN_SRC)))
	evselect table=$< withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) IN $(src)" filteredset=$@
	epatplot sigma=3 set=$<

$(SRC)_%_filtsbg.fits : %_filt.fits makefile $(SRCFILE)
	$(eval bg = $(if $(findstring EMOS, $*),$(MOS_BG),$(PN_BG)))
	evselect table=$< withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) IN $(bg)" filteredset=$@

define spec_extract = 
$(eval specchan = $(if $(findstring EMOS, $*),$(MOS_specchannelmax),$(PN_specchannelmax)))
$(eval specbin = $(if $(findstring EMOS, $*),$(MOS_spectralbinsize),$(PN_spectralbinsize)))
evselect table=$< withspectrumset=yes spectrumset=$@ energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=$(specchan) spectralbinsize=$(specbin)
backscale spectrumset=$@ badpixlocation=$<
endef

%_spec.fits : %_filts.fits
	$(spec_extract)

%_specbg.fits : %_filtsbg.fits
	$(spec_extract)

%_spec.rmf : %_spec.fits
	rmfgen spectrumset=$< rmfset=$@

$(SRC)_%_spec.arf : $(SRC)_%_spec.fits $(SRC)_%_spec.rmf
	arfgen spectrumset=$< arfset=$@ withrmfset=yes rmfset=$(SRC)_$*_spec.rmf badpixlocation=$*_filt.fits detmaptype=psf

%_spec.15grp : %_spec.fits %_spec.rmf %_spec.arf %_specbg.fits
	-rm $@
	grppha $< $@ comm="chkey respfile $*_spec.rmf & chkey backfile $*_specbg.fits & chkey ancrfile $*_spec.arf & group min 15 & exit"

EPIC_spectra : $(patsubst %_im.fits,$(SRC)_%_spec.15grp,$(filter-out $(NO_SPEC) ,$(wildcard *_im.fits))) makefile $(SRCFILE)

# It would be an elegant solution to define a prototype for lc generation
# and variables for each lc, but unfortunately the $(eval ) function is 
# buggy in make version <= 3.80 and does not allow to define new recepies.
# So, for now, number of lcs extracted is harcoded ('soft' and 'hard')

lc = evselect table=$< withrateset=yes rateset=$@ makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=$(LC_BIN) expression=

%_soft_lc.fits : %_filts.fits
	$(lc) expression="$(SOFT_LC)"

%_hard_lc.fits : %_filts.fits
	$(lc) expression="$(SOFT_LC)"

%_soft_bglc.fits : %_filtsbg.fits
	$(lc) expression="$(HARD_LC)"

%_hard_bglc.fits : %_filtsbg.fits
	$(lc)  expression="$(HARD_LC)" expression=


soft_lcs = $(patsubst %_im.fits,$(SRC)_%_soft_lc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))
hard_lcs = $(patsubst %_im.fits,$(SRC)_%_hard_lc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))
soft_bglcs = $(patsubst %_im.fits,$(SRC)_%_soft_bglc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))
hard_bglcs = $(patsubst %_im.fits,$(SRC)_%_hard_bglc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))

EPIC_lc : $(soft_lcs) $(hard_lcs) $(soft_bglcs) $(hard_bglcs)

EPIC :
	#$(MAKE) EPIC_prepare
	$(MAKE) EPIC_images
	$(MAKE) EPIC_spectra
	$(MAKE) EPIC_lc

clean_EPIC_lc :
	-rm $(SRC)*_soft_*lc.fits
	-rm $(SRC)*_hard_*lc.fits

clean_EPIC_spectra :
	-rm $(SRC)*spec*
	-rm $(SRC)*filts*.fits

clean_EPIC_SRC : clean_EPIC_lc clean_EPIC_spectra

clean_EPIC : 
	$(MAKE) clean_EPIC_SRC SRC=
	-rm *_E*Badpixels.ds
	-rm *_E*_filt.fits
	-rm *_E*_filt_pat.ps
	-rm *_E*_gti.fits
	-rm *_E*_he_lc.fits 
	-rm *_E*_ImagingEvts.ds 
	-rm *_E*_im.fits

clean : clean_EPIC

clean_all : clean
	-rm $(SAS_CCF)
	-rm *_AttHk.ds
	-rm $(ODFDIR)/*.SAS
