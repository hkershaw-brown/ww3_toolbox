#!/bin/bash -v

## Create HT from pop file
#
ncks -v TLONG ts.woa2013v2_0.25.ic.POP_tx0.1v3_62lev.20170825.nc tx0.1v3.nc
ncks -A -v TLAT ts.woa2013v2_0.25.ic.POP_tx0.1v3_62lev.20170825.nc tx0.1v3.nc
ncks -A -v KMT ts.woa2013v2_0.25.ic.POP_tx0.1v3_62lev.20170825.nc tx0.1v3.nc
#
#
## tempory HT file
## fill value is different to netcdf default 9.96920996838687e+36

ncks -A -v KMT ts.woa2013v2_0.25.ic.POP_tx0.1v3_62lev.20170825.nc tx0.1v3.nc
ncrename  -O -v KMT,HT tx0.1v3.nc 
ncatted -O -a long_name,HT,o,c,"ocean depth at T points" tx0.1v3.nc 
ncatted -a units,HT,a,c,"centimeter" tx0.1v3.nc 
ncap2 -s 'HT=double(HT)' tx0.1v3.nc tx0.1v3_HT.nc

#ncks -A -v TEMPERATURE ts.woa2013v2_0.25.ic.POP_tx0.1v3_62lev.20170825.nc tx0.1v3_HT.nc 
#ncrename  -O -v TEMPERATURE,HT tx0.1v3_HT.nc 
#ncatted -O -a long_name,HT,o,c,"ocean depth at T points" tx0.1v3_HT.nc 
#ncatted -a units,HT,a,c,"centimeter" tx0.1v3_HT.nc 
#
##ncap2 -s 'HT=double(HT)' tx0.1v3_HT.nc tx0.1v3_HT_double.nc
##ncatted -a missing_value,HT,o,i,9.96920996838687e+36 tx0.1v3_HT.nc 
##ncatted -O -a _FillValue,HT,o,i,9.96920996838687e+36 tx0.1v3_HT.nc


