#export HEADAS=/soft/lheasoft/headas/x86_64-pc-linux
#export HEADAS=/soft/lheasoft/headas/i686-pc-linux
#export LD_LIBRARY_PATH=/opt/SUNWspro/lib
#. $HEADAS/headas-init.sh
#. /soft/XMM/xmmsas/setsas.sh

export SAS_DIR=/nfs/mkx/a1/linux-x86_64/opt/packages/xmmsas_20170112_1337
export SAS_CCFPATH=/nfs/mkx/a1/../d1/ccf

# ODF file location
export SAS_ODF=$( pwd )/ODF

# CCF file location (local)
export SAS_CCF=$( pwd )/ccf.cif
export SAS_VERBOSITY=3
export SAS_SUPRESS_WARNING=3
#export GRACE_HOME=/soft/grace

/nfs/mkx/a1/setup/xmmsas-setup.sh
