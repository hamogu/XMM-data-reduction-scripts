#export HEADAS=/soft/lheasoft/headas/x86_64-pc-linux
#export HEADAS=/soft/lheasoft/headas/i686-pc-linux
#export LD_LIBRARY_PATH=/opt/SUNWspro/lib
#. $HEADAS/headas-init.sh
#. /soft/XMM/xmmsas/setsas.sh

export SAS_DIR=/opt/sas/xmmsas_20141104_1833
export SAS_CCFPATH=/blackhole/d1/grinberg/xmm/ccf

# ODF file location
export SAS_ODF=$( pwd )/ODF

# CCF file location (local)
export SAS_CCF=$( pwd )/ccf.cif
export SAS_VERBOSITY=3
export SAS_SUPRESS_WARNING=3
#export GRACE_HOME=/soft/grace

