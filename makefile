first_target :
	echo No default target set!


# directory which contains the ODF files. Typically this is ODF or odf
ODFDIR := ODF

# Set path to ODF and CCF
export SAS_CCF = ./ccf.cif
#SAS_ODF needs absolute path for ODF
export SAS_ODF := $(shell pwd )/$(ODFDIR)

#For now: Set up for a single source in each dir. Can be changed later
#For now: use same BG region for MOS1 and MOS2
#could make SRC a list and then loop though SRC for use $($(SRC)_MOS_SRC) etc...

# The following variables can be edited here or specified on the command line.
# Example:
# make SRC=Capella MOS_SRC="circle(27500, 27100, 600)" MOS_BG="circle(21550,18400,2500)" PN_SRC=... PN_BG=...
#SRC = src
#MOS_SRC = circle(18450,15750,600)
SRC = Capella
MOS_SRC = circle(15475, 13175, 600)
MOS_BG = circle(13125,17125,2500)
PN_SRC = 
PN_BG = 

#list all *im.fits files where no spectra shold be extracted (e.g. target outside FOV)
NO_SPEC = 1796_0510780401_EMOS1_S004_im.fits 1796_0510780401_EMOS2_S006_im.fits 1796_0510780401_EMOS2_S006_im.fits 1796_0510780401_EPN_S001_im.fits

# Lightcurve
LC_BIN = 600
SOFT_LC = PI in [200:1200]
HARD_LC = PI in [1200:8000]

#list all *im.fits files where no lightcurves shold be extracted (e.g. target outside FOV)
NO_LC = $(NO_SPEC)



# These defaults might be changed, but this is standard
MOS_gti = "RATE<0.4"
PN_gti = "RATE<3.0"


#These defaults probably are never changed
#  "#" requires escaping with \\\

MOS_he := "\\\#XMMEA_EM && (PI>10000) && (PATTERN==0)"
PN_he := "\\\#XMMEA_EP && (PI>10000) && (PATTERN==0)"
MOS_filt := \\\#XMMEA_EM && (PI in [150:12000]) && (PATTERN<=12)
PN_filt := \\\#XMMEA_EP && (PI in [200:10000]) && (PATTERN<=4)
MOS_spectralbinsize = 15
PN_spectralbinsize = 5
MOS_specchannelmax=11999
PN_specchannelmax=20479



SHELL = /bin/sh

.PHONY: EPIC_image EPIC_spectra EPIC_lc EPIC_all EPIC_prepare
# keep all intermediate files - they are .rmf .arf
.SECONDARY :

$(ODFDIR)/%.FIT : $(ODFDIR)/%.FIT.gz 
	gunzip $(SAS_ODF)/*.gz

ccf.cif : $(ODFDIR)/*.FIT
	cifbuild
	
$(ODFDIR)/*.SAS : $(ODFDIR)/*.ASC ccf.cif $(ODFDIR)/*.FIT
	odfingest outdir=$(SAS_ODF) odfdir=$(SAS_ODF)

EPIC_prepare :
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
	#ds9 -log -cmap heat $*_im.fits &

EPIC_images : $(patsubst %_ImagingEvts.ds,%_im.fits,$(wildcard *_ImagingEvts.ds))

# Get Source events + Pile up check (set sigma if desired !)
# Could I simplify this with especget instead of separate evselect, rmfgen, arfgen?

$(SRC)_%_filts.fits : %_filt.fits makefile
	$(eval src = $(if $(findstring EMOS, $*),$(MOS_SRC),$(PN_SRC)))
	evselect table=$< withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) IN $(src)" filteredset=$@
	epatplot sigma=3 set=$<



%_spec.fits : %_filts.fits
	$(eval specchan = $(if $(findstring EMOS, $*),$(MOS_specchannelmax),$(PN_specchannelmax)))
	$(eval specbin = $(if $(findstring EMOS, $*),$(MOS_spectralbinsize),$(PN_spectralbinsize)))
	evselect table=$< withspectrumset=yes spectrumset=$@ energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=$(specchan) spectralbinsize=$(specbin)
	backscale spectrumset=$@ badpixlocation=$<

$(SRC)_%_filtsbg.fits : %_filt.fits makefile
	$(eval bg = $(if $(findstring EMOS, $*),$(MOS_BG),$(PN_BG)))
	evselect table=$< withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) IN $(bg)" filteredset=$@

%_specbg.fits : %_filtsbg.fits
	$(eval specchan = $(if $(findstring EMOS, $*),$(MOS_specchannelmax),$(PN_specchannelmax)))
	$(eval specbin = $(if $(findstring EMOS, $*),$(MOS_spectralbinsize),$(PN_spectralbinsize)))
	evselect table=$< withspectrumset=yes spectrumset=$@ energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=$(specchan) spectralbinsize=$(specbin)
	backscale spectrumset=$@ badpixlocation=$<

%_spec.rmf : %_spec.fits
	rmfgen spectrumset=$< rmfset=$@

#make mos1_filt into rule once upstream naming convention is clear
$(SRC)_%_spec.arf : $(SRC)_%_spec.fits $(SRC)_%_spec.rmf
	arfgen spectrumset=$< arfset=$@ withrmfset=yes rmfset=$(SRC)_$*_spec.rmf badpixlocation=$*_filt.fits detmaptype=psf

%_spec.15grp : %_spec.fits %_spec.rmf %_spec.arf %_specbg.fits
	-rm $@
	grppha $< $@ comm="chkey respfile $*_spec.rmf & chkey backfile $*_specbg.fits & chkey ancrfile $*_spec.arf & group min 15 & exit"

EPIC_spectra : $(patsubst %_im.fits,$(SRC)_%_spec.15grp,$(filter-out $(NO_SPEC) ,$(wildcard *_im.fits))) makefile 

# It would be an elegant solution to define a prototype for lc generation
# and variables for each lc, but unfortunately the $(eval ) function is 
# buggy in make <= 3.80 and does not allow to define new recepies.
# So, for now, the engery range for each lc is hardcoded.
# lc_name = soft
# lc_soft_bin = 600
# lc_soft_filter = PI in [200:1200]
# 
# $(SRC)_%_$(lc_name)_lc.fits : $(SRC)_%_filts.fits
# 	evselect table=$< withrateset=yes rateset=$@ makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=$(lc_$(lc_name)_bin) expression="lc_$($(lc_name)_filter)"
lc = evselect table=$< withrateset=yes rateset=$@ makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=$(LC_BIN) expression="

%_soft_lc.fits : %_filts.fits
	$(lc) $(value SOFT_LC)"

%_hard_lc.fits : %_filts.fits
	$(lc) $(value SOFT_LC)"

%_soft_bglc.fits : %_filtsbg.fits
	$(lc) $(value HARD_LC)"

%_hard_bglc.fits : %_filtsbg.fits
	$(lc) $(value HARD_LC)"


soft_lcs = $(patsubst %_im.fits,$(SRC)_%_soft_lc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))
hard_lcs = $(patsubst %_im.fits,$(SRC)_%_hard_lc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))
soft_bglcs = $(patsubst %_im.fits,$(SRC)_%_soft_bglc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))
hard_bglcs = $(patsubst %_im.fits,$(SRC)_%_hard_bglc.fits,$(filter-out $(NO_LC) ,$(wildcard *_im.fits)))

EPIC_lc : $(soft_lcs) $(hard_lcs) $(soft_bglcs) $(hard_bglcs)

EPIC:
	#$(MAKE) EPIC_prepare
	$(MAKE) EPIC_images
	$(MAKE) EPIC_spectra
	$(MAKE) EPIC_lc