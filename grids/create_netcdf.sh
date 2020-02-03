#!/bin/bash -v

## Create HT from pop file
#

pop_grid='ts.woa2013v2_0.25.ic.POP_tx0.1v3_62lev.20170825.nc'
ww3_grid_file='tx0.1v3.nc'

rm temp.nc temp_double.nc $ww3_grid_file

ncks -v    TLONG $pop_grid  temp.nc
ncks -A -v TLAT  $pop_grid  temp.nc
ncks -A -v KMT   $pop_grid  temp.nc

## tempory HT file
## fill value is different to netcdf default 9.96920996838687e+36

ncrename -O -v KMT,HT                                     temp.nc
ncatted  -O -a long_name,HT,o,c,"ocean depth at T points" temp.nc
ncatted  -a    units,HT,a,c,"centimeter"                  temp.nc
ncap2    -s    'HT=double(HT)' temp.nc                    temp_double.nc 

# why doesn't this work.  Done in matlab instead.
 #ncap2 -s 'where(HT>0)HT=100000' tx0.1v3_HT.nc temp.nc
matlab  -nodisplay -nojvm -r "change_depth('temp_double.nc'); exit"

ncks -v    TLONG       $pop_grid $ww3_grid_file
ncks -A -v TLAT        $pop_grid $ww3_grid_file
ncks -A -v REGION_MASK $pop_grid $ww3_grid_file
ncks -A -v HT          temp_double.nc $ww3_grid_file


