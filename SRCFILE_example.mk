### Source parameters ###
# The parameters for source extraction can be defined (in order of precedence)
# * as command line parameters to make
# * in $(SRCFILE) (this is an example for such a file)
# * in the makefile itself

# specify a GTI file (in addition to the filtering for proton flares)
# This can the used, e.g. to extract spectra of a stellar flare
GTIFILE=

# Source name for filenames
SRC = deltaCep
# MOS and PN expressions for source and bg extractions regions
MOS_SRC = circle(15475, 13175, 600)
MOS_BG = circle(13125,17125,2500)
PN_SRC = circle(15475, 13175, 600)
PN_BG = circle(13125,17125,2500)

#list all *im.fits files where no spectra shold be extracted (e.g. target outside FOV)
NO_SPEC = 

#list all *im.fits files where no lightcurves shold be extracted (e.g. target outside FOV)
NO_LC = $(NO_SPEC)
