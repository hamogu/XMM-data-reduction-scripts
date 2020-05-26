#! /bin/sh

die () {
  echo "ERROR: $@"
  exit 1
}


# Some safety checks
[ "${SAS_DIR}x" != x ] || die "SAS_DIR not set; you must edit the script file"
[ "${SAS_ODF}x" != x ] || die "SAS_ODF not set"
[ "${obs}x" != x ] || die "obs not set"
did=P${obs}; export did
[ "${otype}x" != x ] || die "otype not set"
[ "${expno1}x" != x ] || die "expno1 not set"
[ "${expno2}x" != x ] || die "expno2 not set"
[ "${withsrc}x" != x ] || die "withsrc not set"
[ "${ebins}x" != x ] || die "ebins not set"
[ "${bkgcor}x" != x ] || die "bkgcor not set"


pt=1
 if [ "x$withsrc" == "xy" ]
   then
   pt=3
   [ "${srcra}x" != x ] || die "srcra not set"
   [ "${srcdec}x" != x ] || die "srcdec not set"
 fi
export pt



#--------rgsproc---------------------- you may use for PSF-core : xpsfincl=66
echo '  running rgsproc, please be patient...'
  if [ "${gti}" == "n" ]; then
    rgsproc srcra=${srcra} srcdec=${srcdec} withsrc=${withsrc} attstyle=user attra=${srcra} attdec=${srcdec} attapos=${apos} srclabel=mjsrc bkgcorrect=${bkgcor} withmlambdacolumn=yes xpsfincl=${xpsfincl} -V 2 >& my_rgsproc_logfile; else rgsproc srcra=${srcra} srcdec=${srcdec} withsrc=${withsrc} attstyle=user attra=${srcra} attdec=${srcdec} attapos=${apos} srclabel=mjsrc bkgcorrect=${bkgcor} auxgtitables=${gtifile} withmlambdacolumn=yes xpsfincl=5 xpsfincl=${xpsfincl} -V 2 >& my_rgsproc_logfile
  fi
  [ $? = 0 ] || die "rgsproc failed"
echo '  ...done'

#--------region and banana plot----------------------

#   R1  #
evselect table="${did}R1${otype}${expno1}EVENLI0000.FIT:EVENTS" imageset='my_spatial1.fit' xcolumn='M_LAMBDA' ycolumn='XDSP_CORR'

evselect table="${did}R1${otype}${expno1}EVENLI0000.FIT:EVENTS" imageset='my_banana1.fit' xcolumn='M_LAMBDA' ycolumn='PI' yimagemin=0 yimagemax=3000 expression="region(${did}R1${otype}${expno1}SRCLI_0000.FIT:RGS1_SRC${srcid}_SPATIAL,M_LAMBDA,XDSP_CORR)"

rgsimplot endispset='my_banana1.fit' spatialset='my_spatial1.fit' srcidlist="${srcid}" srclistset="${did}R1${otype}${expno1}SRCLI_0000.FIT" device=/cps plotfile=region_R1.ps

#   R2  #
evselect table="${did}R2${otype}${expno2}EVENLI0000.FIT:EVENTS" imageset='my_spatial2.fit' xcolumn='M_LAMBDA' ycolumn='XDSP_CORR'

evselect table="${did}R2${otype}${expno2}EVENLI0000.FIT:EVENTS" imageset='my_banana2.fit' xcolumn='M_LAMBDA' ycolumn='PI' yimagemin=0 yimagemax=3000 expression="region(${did}R2${otype}${expno2}SRCLI_0000.FIT:RGS2_SRC${srcid}_SPATIAL,M_LAMBDA,XDSP_CORR)"

rgsimplot endispset='my_banana2.fit' spatialset='my_spatial2.fit' srcidlist="${srcid}" srclistset="${did}R2${otype}${expno2}SRCLI_0000.FIT" device=/cps plotfile=region_R2.ps

#--------RGS lightcurve --------------------
evselect table=${did}R1${otype}${expno1}EVENLI0000.FIT withrateset=yes rateset=rgs1_lc.fits makeratecolumn=yes maketimecolumn=yes timebinsize=300 expression="((M_LAMBDA,PI) IN REGION(${did}R1${otype}${expno1}SRCLI_0000.FIT:RGS1_SRC${srcid}_ORDER_1)) && ((M_LAMBDA,XDSP_CORR) IN REGION(${did}R1${otype}${expno1}SRCLI_0000.FIT:RGS1_SRC${srcid}_SPATIAL))"

evselect table=${did}R2${otype}${expno2}EVENLI0000.FIT withrateset=yes rateset=rgs2_lc.fits makeratecolumn=yes maketimecolumn=yes timebinsize=300 expression="((M_LAMBDA,PI) IN REGION(${did}R2${otype}${expno2}SRCLI_0000.FIT:RGS2_SRC${srcid}_ORDER_1)) && ((M_LAMBDA,XDSP_CORR) IN REGION(${did}R2${otype}${expno2}SRCLI_0000.FIT:RGS2_SRC${srcid}_SPATIAL))"

#--------RGS background lightcurve and gti_file (reprocess data if necessary)  --------------------

evselect table="${did}R1${otype}${expno1}EVENLI0000.FIT:EVENTS" makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=100 expression="(CCDNR == 9) && ((M_LAMBDA,XDSP_CORR) in REGION(${did}R1${otype}${expno1}SRCLI_0000.FIT:RGS1_BACKGROUND))" rateset=rgs1_bglc.fits

tabgtigen table=rgs1_bglc.fits gtiset=gti_rgs1.fits expression="(RATE < 1.0)"

evselect table="${did}R2${otype}${expno2}EVENLI0000.FIT:EVENTS" makeratecolumn=yes maketimecolumn=yes timecolumn=TIME timebinsize=100 expression="(CCDNR == 9) && ((M_LAMBDA,XDSP_CORR) in REGION(${did}R2${otype}${expno2}SRCLI_0000.FIT:RGS2_BACKGROUND))" rateset=rgs2_bglc.fits

tabgtigen table=rgs2_bglc.fits gtiset=gti_rgs2.fits expression="(RATE < 1.0)"

#-------------------------

echo '...ready'
echo You will find the results in the directory
echo $PWD

grppha "${did}R1${otype}${expno1}SRSPEC100${srcid}.FIT" "rgs1_spec.15grp" comm="chkey respfile ${did}R1${otype}${expno1}RSPMAT100${srcid}.FIT & chkey backfile ${did}R1${otype}${expno1}BGSPEC100${srcid}.FIT & group min 15 & exit"

grppha "${did}R1${otype}${expno1}SRSPEC100${srcid}.FIT" "rgs1_spec.5grp" comm="chkey respfile ${did}R1${otype}${expno1}RSPMAT100${srcid}.FIT & chkey backfile ${did}R1${otype}${expno1}BGSPEC100${srcid}.FIT & group min 5 & exit"

grppha "${did}R2${otype}${expno2}SRSPEC100${srcid}.FIT" "rgs2_spec.15grp" comm="chkey respfile ${did}R2${otype}${expno2}RSPMAT100${srcid}.FIT & chkey backfile ${did}R2${otype}${expno2}BGSPEC100${srcid}.FIT & group min 15 & exit"

grppha "${did}R2${otype}${expno2}SRSPEC100${srcid}.FIT" "rgs2_spec.5grp" comm="chkey respfile ${did}R2${otype}${expno2}RSPMAT100${srcid}.FIT & chkey backfile ${did}R2${otype}${expno2}BGSPEC100${srcid}.FIT & group min 5 & exit"

grppha "${did}R2${otype}${expno2}SRSPEC100${srcid}.FIT" "rgs2_spec.50grp" comm="chkey respfile ${did}R2${otype}${expno2}RSPMAT100${srcid}.FIT & chkey backfile ${did}R2${otype}${expno2}BGSPEC100${srcid}.FIT & group min 50 & exit"

grppha "${did}R1${otype}${expno1}SRSPEC100${srcid}.FIT" "rgs1_spec.50grp" comm="chkey respfile ${did}R1${otype}${expno1}RSPMAT100${srcid}.FIT & chkey backfile ${did}R1${otype}${expno1}BGSPEC100${srcid}.FIT & group min 50 & exit"
