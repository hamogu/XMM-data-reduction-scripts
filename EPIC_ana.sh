# Select source and background regions !!!


# Get Source events + Pile up check (set sigma if desired !)
evselect table=mos1_filt.fits withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) IN "$MOS_SRC filteredset=${root}mos1_filt_src.fits
epatplot set=${root}mos1_filt_src.fits sigma=3
evselect table=mos2_filt.fits withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) in "$MOS_SRC filteredset=${root}mos2_filt_src.fits
epatplot set=${root}mos2_filt_src.fits sigma=3
evselect table=pn_filt.fits withfilteredset=true destruct=yes keepfilteroutput=true expression="(X,Y) in "$PN_SRC filteredset=${root}pn_filt_src.fits
epatplot set=${root}pn_filt_src.fits sigma=3

# Extract source and background spectra (single+double events); center on source
evselect table=${root}mos1_filt_src.fits withspectrumset=yes spectrumset=${root}mos1_spec.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=11999 spectralbinsize=15
evselect table=${root}mos2_filt_src.fits withspectrumset=yes spectrumset=${root}mos2_spec.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=11999 spectralbinsize=15
evselect table=${root}pn_filt_src.fits withspectrumset=yes spectrumset=${root}pn_spec.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=20479 spectralbinsize=5

evselect table=mos1_filt.fits withspectrumset=yes spectrumset=${root}mos1_spec_bg.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=11999 spectralbinsize=15 expression="#XMMEA_EM && (PATTERN<=12) && ((X,Y) IN "$MOS_BKG")"
evselect table=mos2_filt.fits withspectrumset=yes spectrumset=${root}mos2_spec_bg.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=11999 spectralbinsize=15 expression="#XMMEA_EM && (PATTERN<=12) && ((X,Y) IN "$MOS_BKG")"
evselect table=pn_filt.fits withspectrumset=yes spectrumset=${root}pn_spec_bg.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=20479 spectralbinsize=5 expression="(FLAG==0) && (PATTERN<=4) && ((X,Y) IN "$PN_BKG")"

backscale spectrumset=${root}mos1_spec.fits badpixlocation=mos1_filt.fits
backscale spectrumset=${root}mos1_spec_bg.fits badpixlocation=mos1_filt.fits
backscale spectrumset=${root}mos2_spec.fits badpixlocation=mos2_filt.fits
backscale spectrumset=${root}mos2_spec_bg.fits badpixlocation=mos2_filt.fits
backscale spectrumset=${root}pn_spec.fits badpixlocation=pn_filt.fits
backscale spectrumset=${root}pn_spec_bg.fits badpixlocation=pn_filt.fits


# Create response and ancillary files
rmfgen spectrumset=${root}mos1_spec.fits rmfset=${root}mos1_spec.rmf
arfgen spectrumset=${root}mos1_spec.fits arfset=${root}mos1_spec.arf withrmfset=yes rmfset=${root}mos1_spec.rmf badpixlocation=mos1_filt.fits detmaptype=psf
rmfgen spectrumset=${root}mos2_spec.fits rmfset=${root}mos2_spec.rmf
arfgen spectrumset=${root}mos2_spec.fits arfset=${root}mos2_spec.arf withrmfset=yes rmfset=${root}mos2_spec.rmf badpixlocation=mos2_filt.fits detmaptype=psf
rmfgen spectrumset=${root}pn_spec.fits rmfset=${root}pn_spec.rmf
arfgen spectrumset=${root}pn_spec.fits arfset=${root}pn_spec.arf withrmfset=yes rmfset=${root}pn_spec.rmf badpixlocation=pn_filt.fits detmaptype=psf

# Create lightcurves (filtered data/spectral source region)
evselect table=${root}mos1_filt_src.fits withrateset=yes rateset=${root}mos1_lcc.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=100
evselect table=${root}mos2_filt_src.fits withrateset=yes rateset=${root}mos2_lcc.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=100
evselect table=${root}pn_filt_src.fits withrateset=yes rateset=${root}pn_lcc.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=100

# Create lightcurves (all data/full region; select energy range, region, timebins etc. !!!)

evselect table=mos1.fits withrateset=yes rateset=${root}mos1_lc.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=600 expression="#XMMEA_EM && (PATTERN<=12) && (PI in [200:10000]) && ((X,Y) IN "$MOS_SRC")"
evselect table=mos1.fits withrateset=yes rateset=${root}mos1_lc_soft.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=600 expression="#XMMEA_EM && (PATTERN<=12) && (PI in [200:1200]) && ((X,Y) IN "$MOS_SRC")"

evselect table=mos1.fits withrateset=yes rateset=${root}mos1_lc_softsoft.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=600 expression="#XMMEA_EM && (PATTERN<=12) && (PI in [200:800]) && ((X,Y) IN "$MOS_SRC")"

evselect table=mos1.fits withrateset=yes rateset=${root}mos1_lc_hard.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=600 expression="#XMMEA_EM && (PATTERN<=12) && (PI in [1500:5000]) && ((X,Y) IN "$MOS_SRC")"

evselect table=mos1.fits withrateset=yes rateset=${root}mos1_lc_bg.fits makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=300 expression="#XMMEA_EM && (PATTERN<=12) && (PI in [200:5000]) && ((X,Y) IN "$MOS_BKG")"


# spectra may be rebinned with ftools grppha for Xspec

rm ${root}mos1_spec.15grp
rm ${root}mos2_spec.15grp
rm ${root}pn_spec.15grp

grppha ${root}mos1_spec.fits ${root}mos1_spec.15grp comm="chkey respfile ${root}mos1_spec.rmf & chkey backfile ${root}mos1_spec_bg.fits & chkey ancrfile ${root}mos1_spec.arf & group min 15 & exit"
grppha ${root}mos2_spec.fits ${root}mos2_spec.15grp comm="chkey respfile ${root}mos2_spec.rmf & chkey backfile ${root}mos2_spec_bg.fits & chkey ancrfile ${root}mos2_spec.arf & group min 15 & exit"
grppha ${root}pn_spec.fits ${root}pn_spec.15grp comm="chkey respfile ${root}pn_spec.rmf & chkey backfile ${root}pn_spec_bg.fits & chkey ancrfile ${root}pn_spec.arf & group min 15 & exit"



