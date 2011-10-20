export MOS_SRC="circle(24775,24625,600)"
export MOS_BKG="circle(28775,27825,2000)"
export PN_SRC="circle(25867,27912,600)"
export PN_BKG="circle(30360,24975,1000)"

#-------------------------------------------------
#        THIS SECTION NEEDS TO BE EDITED FOR RGS  !!!    |
#-------------------------------------------------

# uncomment and modify these four variables for your system
#   location where SAS is installed in your system
# SAS_DIR=/usr/local/hssoft/sas/xmmsas/
#   location of your odf directory
#SAS_ODF=/data/hspc44/stch320/XMM/61Cyg/0041740101/odf/

#   proposal ID (second set of number in filenames)
#export obs=0554770101
export obs=$( fkeyprint "mos1.fits[0]" OBS_ID | grep "'" | awk '{print substr($3,2,length($3)-2)}' )
#   observation type (S for scheduled observation, U for unscheduled)
#export otype=S
export otype=$( ls $SAS_ODF/*R1?00*AUX.FIT | awk '{print substr($1,length($1)-12,1)}' )
#   ---  WATCH EXPOSURE-NUMBERS & SRCIDLIST !!!  --- 
#   exposure numbers (from $SAS_ODF/*AUX.FIT)
#   change srcidlist respectively

#export expno1=004
#export expno2=005
export expno1=$(  ls $SAS_ODF/*R1?00*AUX.FIT | awk '{print substr($1,length($1)-11,3)}' )
export expno2=$(  ls $SAS_ODF/*R2?00*AUX.FIT | awk '{print substr($1,length($1)-11,3)}' )
#     (srcdec=deg+min/60.+sec/3600.
#      srcra =15*(hrs+min/60.+sec/3600.)
# Coordinates and posistion angle are mandatory !!!!

export withsrc=y
#export srcra=68.4737500000000
#export srcdec=18.1482777777778
#export apos=260.3864440917
export srcra=$( fkeyprint "mos1.fits[0]" RA_OBJ | grep "=" | awk '{print $3}' )
export srcdec=$( fkeyprint "mos1.fits[0]" DEC_OBJ | grep "=" | awk '{print $3}' )
export apos=$( fkeyprint "mos1.fits[0]" PA_PNT | grep "=" | awk '{print $3}' )

export srcid=3

# set background-correction 

export bkgcor=n

# apply GTI file if necessary

export gti=n
export gtifile=gti.fits

# modify below for PSF-core
export xpsfincl=90
#   set binning for response matrices
#    set to one if one need for wavelength scale
#    other wise set to 4000
export ebins=1
