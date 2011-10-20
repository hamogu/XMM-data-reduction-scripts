# Set environment variables; run cifbuild/odfingest and create eventfiles !!!

cifbuild
odfingest outdir=$SAS_ODF odfdir=$SAS_ODF
emproc
epproc

ln -s $( ls *_EMOS1_*_ImagingEvts.ds) mos1.fits
ln -s $( ls *_EMOS2_*_ImagingEvts.ds) mos2.fits
ln -s $( ls *_EPN_*_ImagingEvts.ds) pn.fits

# Check for high background (MOS:counts/s<0.35 ; PN:counts/s<1.0 ??  Full Frame!!!)
evselect table=mos1.fits withrateset=true rateset=mos1_he_lc.fits makeratecolumn=yes timecolumn=TIME timebinsize=100 maketimecolumn=yes expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
# dsplot table=mos1_he_lc.fits x=TIME y=COUNTS &
evselect table=mos2.fits withrateset=true rateset=mos2_he_lc.fits makeratecolumn=yes timecolumn=TIME timebinsize=100 maketimecolumn=yes expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
# dsplot table=mos2_he_lc.fits x=TIME y=COUNTS &
evselect table=pn.fits withrateset=true rateset=pn_he_lc.fits makeratecolumn=yes timecolumn=TIME timebinsize=100 maketimecolumn=yes expression="#XMMEA_EP && (PI>10000) && (PATTERN==0)"
# dsplot table=pn_he_lc.fits x=TIME y=COUNTS &

# Filter eventfile for spectral analysis (good events; GTI; 0.15-15.0 keV; single+double only)
tabgtigen table=mos1_he_lc.fits expression="RATE<0.4" gtiset=gti_mos1_he.fits
evselect table=mos1.fits withfilteredset=true filteredset=mos1_filt.fits keepfilteroutput=true destruct=yes expression="(#XMMEA_EM && gti(gti_mos1_he.fits,TIME) && (PI in [150:12000]) && (PATTERN<=12))"
tabgtigen table=mos2_he_lc.fits expression="RATE<0.4" gtiset=gti_mos2_he.fits
evselect table=mos2.fits withfilteredset=true filteredset=mos2_filt.fits keepfilteroutput=true destruct=yes expression="(#XMMEA_EM && gti(gti_mos2_he.fits,TIME) && (PI in [150:12000]) && (PATTERN<=12))"
tabgtigen table=pn_he_lc.fits expression="RATE<3.0" gtiset=gti_pn_he.fits
evselect table=pn.fits withfilteredset=true filteredset=pn_filt.fits keepfilteroutput=true destruct=yes expression="(FLAG==0 && gti(gti_pn_he.fits,TIME) && (PI in [200:10000]) && (PATTERN<=4))"


# Create skyimage (now selected: clean events only, full energy range)
evselect table=mos1_filt.fits withimageset=true imageset=mos1_im.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=50 yimagebinsize=50
ds9 -log -cmap heat mos1_im.fits &
evselect table=mos2_filt.fits withimageset=true imageset=mos2_im.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=100 yimagebinsize=100
ds9 -log -cmap heat mos2_im.fits &
evselect table=pn_filt.fits withimageset=true imageset=pn_im.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=100 yimagebinsize=100
ds9 -log -cmap heat pn_im.fits &

#  be aware of timing data !!!  (no X/Y columns)
#  get the desired source-regions
# splitted files merge
