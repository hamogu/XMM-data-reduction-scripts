# This makefile collects variable definitions for the XMM data reduction,
# including filter conditions for spectral extraction, bin sizes and 
# the default energy ranges for lightcurves.

### proton flares ###
# filter conditions to remove proton flares
# These defaults are taken form the SAS documentation
# expression for high-energy lcs
#  "#" requires escaping
MOS_he := "\\\#XMMEA_EM && (PI>10000) && (PATTERN==0)" 
PN_he := "\\\#XMMEA_EP && (PI>10000) && (PATTERN==0)"
# filter times for gti
MOS_gti = "RATE<0.4"
PN_gti = "RATE<3.0"


### EPIC Lightcurve ###
# bin size of source and bg lightcurves in s
LC_BIN = 600
# energy filter for soft and hard lightcurve
SOFT_LC = PI in [200:1000]
HARD_LC = PI in [1000:8000]


### EPIC spectra ### 
# These defaults are taken form the SAS documentation
#  "#" requires escaping
MOS_filt := \\\#XMMEA_EM && (PI in [150:12000]) && (PATTERN<=12)
PN_filt := \\\#XMMEA_EP && (PI in [200:10000]) && (PATTERN<=4)
MOS_spectralbinsize = 15
PN_spectralbinsize = 5
MOS_specchannelmax=11999
PN_specchannelmax=20479


### directory structure  ###
# directory which contains the ODF files. Typically this is ODF or odf
ODFDIR := ODF


### SAS settings ###
# Set path to ODF and CCF
export SAS_CCF = ./ccf.cif
#SAS_ODF needs absolute path for ODF
export SAS_ODF := $(shell pwd )/$(ODFDIR)

### Open ds9 for each image automatically? ###
# DS9 = ds9 -log -cmap heat
DS9 = echo To display image use: ds9 -log -cmap heat

