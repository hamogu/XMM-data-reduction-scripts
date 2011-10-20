# Set environment variables; run cifbuild/odfingest and create eventfiles !!!
# export SAS_DIR=/usr/local/hssoft/sas/xmmsas_20060628_1801/
# export SAS_PATH=$SAS_DIR
# export SAS_CCFPATH=$SAS_DIR/ccf/
# . $SAS_DIR/sas-setup.sh
# 
# export PATH=$PATH:/usr/local/hssoft/xpa/:/usr/local/hssoft/ds9/:$GRACE_HOME/bin/
# export LANG=C
# 
# export SAS_ODF=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/odf
# export SAS_CCF=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/odf/ccf.cif
# export SAS_VERBOSITY=4
# export SAS_SUPRESS_WARNING=3


[ -d ./OM ] || mkdir OM
cd OM

#process basic OM fast mode stuff with 10 sec binning and logfile
omfchain >& omfchain.log
omichain >& omichain.log

#create postscript files with guide star lightcurve (to check guiding quality)
omthlcplot set="P0200530501OMX006TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_006.ps" binsize=2 nplots=10
omthlcplot set="P0200530501OMX007TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_007.ps" binsize=2 nplots=10
omthlcplot set="P0200530501OMX008TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_008.ps" binsize=2 nplots=10
omthlcplot set="P0200530501OMX011TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_011.ps" binsize=2 nplots=10
omthlcplot set="P0200530501OMX012TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_012.ps" binsize=2 nplots=10
omthlcplot set="P0200530501OMX013TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_013.ps" binsize=2 nplots=10
omthlcplot set="P0200530501OMX014TSTRTS0000.FIT" plotdevice="/VPS" plotfile="guidestar_lc_014.ps" binsize=2 nplots=10

#create big flare 1 sec binning timeseries
evselect table=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007EVLIST1000.FIT filteredset=filtered.fits withfilteredset=no keepfilteroutput=no flagcolumn=EVFLAG flagbit=-1 destruct=yes dssblock='' expression='((WIN_FLAG .eq. 0) .and. (region(/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SRCREG1000.FIT, CORR_X, CORR_Y)))' filtertype=expression cleandss=no updateexposure=yes filterexposure=yes writedss=yes blockstocopy='' attributestocopy='' energycolumn=PHA zcolumn=WEIGHT zerrorcolumn=EWEIGHT withzerrorcolumn=no withzcolumn=no ignorelegallimits=no imageset=image.fits xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1 squarepixels=no ximagesize=600 yimagesize=600 imagebinning=imageSize ximagemin=1 ximagemax=640 withxranges=no yimagemin=1 yimagemax=640 withyranges=no imagedatatype=Real64 withimagedatatype=no raimagecenter=0 decimagecenter=0 withcelestialcenter=no withimageset=no spectrumset=spectrum.fits spectralbinsize=10 specchannelmin=0 specchannelmax=4095 withspecranges=no withspectrumset=no rateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SCRATE1000_1sec.FIT timecolumn=TIME timebinsize=1 timemin=0 timemax=1000 withtimeranges=no maketimecolumn=yes makeratecolumn=no withrateset=yes histogramset=histo.fits histogramcolumn=TIME histogrambinsize=1 histogrammin=0 histogrammax=1000 withhistoranges=no withhistogramset=no  -V 5

evselect table=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007EVLIST1000.FIT filteredset=filtered.fits withfilteredset=no keepfilteroutput=no flagcolumn=EVFLAG flagbit=-1 destruct=yes dssblock='' expression='WIN_FLAG .eq. 0 && region(/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGDREG1000.FIT, CORR_X, CORR_Y)' filtertype=expression cleandss=no updateexposure=yes filterexposure=yes writedss=yes blockstocopy='' attributestocopy='' energycolumn=PHA zcolumn=WEIGHT zerrorcolumn=EWEIGHT withzerrorcolumn=no withzcolumn=no ignorelegallimits=no imageset=image.fits xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1 squarepixels=no ximagesize=600 yimagesize=600 imagebinning=imageSize ximagemin=1 ximagemax=640 withxranges=no yimagemin=1 yimagemax=640 withyranges=no imagedatatype=Real64 withimagedatatype=no raimagecenter=0 decimagecenter=0 withcelestialcenter=no withimageset=no spectrumset=spectrum.fits spectralbinsize=10 specchannelmin=0 specchannelmax=4095 withspecranges=no withspectrumset=no rateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGRATE1000_1sec.FIT timecolumn=TIME timebinsize=1 timemin=0 timemax=1000 withtimeranges=no maketimecolumn=yes makeratecolumn=no withrateset=yes histogramset=histo.fits histogramcolumn=TIME histogrambinsize=1 histogrammin=0 histogrammax=1000 withhistoranges=no withhistogramset=no  -V 5

omlcbuild srcregionset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SRCREG1000.FIT bkgregionset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGDREG1000.FIT srcrateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SCRATE1000_1sec.FIT bkgrateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGRATE1000_1sec.FIT sourcelistset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/P0200530501OMS007SWSRLI1000.FIT wdxset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/odf/1180_0200530501_OMS00700WDX.FIT outset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/P0200530501OMS007TIMESR1000_1sec.FIT  -V 5

#extract source from bigger region
omregion set=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/P0200530501OMS007SWSRLI1000.FIT srcnumber=1 srcradius=-20 nfwhm=3 bkginner=1.2 bkgouter=2.5 bkgfile=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGDREG1000_big.FIT srcfile=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SRCREG1000_big.FIT -V 5

evselect table=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007EVLIST1000.FIT filteredset=filtered.fits withfilteredset=no keepfilteroutput=no flagcolumn=EVFLAG flagbit=-1 destruct=yes dssblock='' expression='((WIN_FLAG .eq. 0) .and. (region(/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SRCREG1000_big.FIT, CORR_X, CORR_Y)))' filtertype=expression cleandss=no updateexposure=yes filterexposure=yes writedss=yes blockstocopy='' attributestocopy='' energycolumn=PHA zcolumn=WEIGHT zerrorcolumn=EWEIGHT withzerrorcolumn=no withzcolumn=no ignorelegallimits=no imageset=image.fits xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1 squarepixels=no ximagesize=600 yimagesize=600 imagebinning=imageSize ximagemin=1 ximagemax=640 withxranges=no yimagemin=1 yimagemax=640 withyranges=no imagedatatype=Real64 withimagedatatype=no raimagecenter=0 decimagecenter=0 withcelestialcenter=no withimageset=no spectrumset=spectrum.fits spectralbinsize=10 specchannelmin=0 specchannelmax=4095 withspecranges=no withspectrumset=no rateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SCRATE1000_big.FIT timecolumn=TIME timebinsize=1 timemin=0 timemax=1000 withtimeranges=no maketimecolumn=yes makeratecolumn=no withrateset=yes histogramset=histo.fits histogramcolumn=TIME histogrambinsize=1 histogrammin=0 histogrammax=1000 withhistoranges=no withhistogramset=no  -V 5

evselect table=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007EVLIST1000.FIT filteredset=filtered.fits withfilteredset=no keepfilteroutput=no flagcolumn=EVFLAG flagbit=-1 destruct=yes dssblock='' expression='WIN_FLAG .eq. 0 && region(/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGDREG1000_big.FIT, CORR_X, CORR_Y)' filtertype=expression cleandss=no updateexposure=yes filterexposure=yes writedss=yes blockstocopy='' attributestocopy='' energycolumn=PHA zcolumn=WEIGHT zerrorcolumn=EWEIGHT withzerrorcolumn=no withzcolumn=no ignorelegallimits=no imageset=image.fits xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1 squarepixels=no ximagesize=600 yimagesize=600 imagebinning=imageSize ximagemin=1 ximagemax=640 withxranges=no yimagemin=1 yimagemax=640 withyranges=no imagedatatype=Real64 withimagedatatype=no raimagecenter=0 decimagecenter=0 withcelestialcenter=no withimageset=no spectrumset=spectrum.fits spectralbinsize=10 specchannelmin=0 specchannelmax=4095 withspecranges=no withspectrumset=no rateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGRATE1000_big.FIT timecolumn=TIME timebinsize=1 timemin=0 timemax=1000 withtimeranges=no maketimecolumn=yes makeratecolumn=no withrateset=yes histogramset=histo.fits histogramcolumn=TIME histogrambinsize=1 histogrammin=0 histogrammax=1000 withhistoranges=no withhistogramset=no  -V 5

omlcbuild srcregionset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SRCREG1000_big.FIT bkgregionset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGDREG1000_big.FIT srcrateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007SCRATE1000_big.FIT bkgrateset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/F0200530501OMS007BGRATE1000_big.FIT sourcelistset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/P0200530501OMS007SWSRLI1000.FIT wdxset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/odf/1180_0200530501_OMS00700WDX.FIT outset=/data/hspc58/st1h314/XMM/CN_Leo/0200530501/OM/P0200530501OMS007TIMESR1000_big.FIT  -V 5


rm *.PDF