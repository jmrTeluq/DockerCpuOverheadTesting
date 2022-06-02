#===============================================================================
# Copyright 2019-2020 Intel Corporation All Rights Reserved.
#
# The source code,  information  and material  ("Material") contained  herein is
# owned by Intel Corporation or its  suppliers or licensors,  and  title to such
# Material remains with Intel  Corporation or its  suppliers or  licensors.  The
# Material  contains  proprietary  information  of  Intel or  its suppliers  and
# licensors.  The Material is protected by  worldwide copyright  laws and treaty
# provisions.  No part  of  the  Material   may  be  used,  copied,  reproduced,
# modified, published,  uploaded, posted, transmitted,  distributed or disclosed
# in any way without Intel's prior express written permission.  No license under
# any patent,  copyright or other  intellectual property rights  in the Material
# is granted to  or  conferred  upon  you,  either   expressly,  by implication,
# inducement,  estoppel  or  otherwise.  Any  license   under such  intellectual
# property rights must be express and approved by Intel in writing.
#
# Unless otherwise agreed by Intel in writing,  you may not remove or alter this
# notice or  any  other  notice   embedded  in  Materials  by  Intel  or Intel's
# suppliers or licensors in any way.
#===============================================================================
LOC=$(realpath $(dirname "${BASH_SOURCE[0]}"))
if [ -z "${CMPLR_ROOT}" ]; then
  CMPLR_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
fi
INTEL_TARGET_PLATFORM="linux"
source $LOC/../../../common.sh $@

# OpenCL FPGA runtime
if [ -f ${CMPLR_ROOT}/${INTEL_TARGET_PLATFORM}/lib/oclfpga/fpga_sys_check.sh  ]; then
  source ${CMPLR_ROOT}/${INTEL_TARGET_PLATFORM}/lib/oclfpga/fpga_sys_check.sh $@
fi
ERRORSTATE=0

# gcc version
if [ -z $(which gcc) ]; then
  echo -e "Intel oneAPI DPC++ Compiler requires gcc to be installed."
  ERRORSTATE=1
else
  gversion=`gcc -dumpversion`
  if [[ ${gversion:0:1} -lt 5 ]]; then
    echo "Intel oneAPI DPC++ Compiler requires gcc version 5.1 or higher"
    ERRORSTATE=1
  elif [[ ${gversion:0:1} -eq 5 ]]; then
    if [[ ${gversion:2:1} -lt 1 ]]; then
      echo "Intel oneAPI DPC++ Compiler requires gcc version 5.1 or higher"
      ERRORSTATE=1
    fi
  fi
fi

if [ $ERRORSTATE -gt 0 ]; then
    echo "bent flange. MODEL component unsafe to operate"
    echo "low fuel. MODEL component will not arrive at destination"
fi

if [ $ERRORSTATE -eq 0 ]; then
    speak "OK"
fi

return $ERRORSTATE
