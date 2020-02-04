#!/bin/bash

pop_grid=T62_g17_G_nuopc.pop.h.once.nc
ww3_grid_file='gx17.grids.nc'

ncks -v    TLONG          $pop_grid  $ww3_grid_file
ncks -A -v TLAT           $pop_grid  $ww3_grid_file
ncks -A -v HT             $pop_grid  $ww3_grid_file
ncks -A -v REGION_MASK    $pop_grid  $ww3_grid_file
