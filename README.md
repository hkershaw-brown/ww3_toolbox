# ww3_toolbox

This is a tool box for submitting WW3 jobs on Yellowstone and Cheyenne.

Tools include:

* **run_wwatch3**

Setup, compile and submit jobs to run WW3 on Yellowstone or Cheyenne.

* **get_grid_inp_file**

Generate *ww3_grid* input data (x, y, bottom) for global grids *gx37* and *gx16*. Require `TLONG`, `TLAT`, `HT` and `REGION_MASK` stored in netCDF format, i.e., *gx37.grids.nc* and *gx16.grids.nc*.

* **get_bottom_ww3a**

Generate *ww3_grid* input data (bottom) for global grid *ww3a*. Bathymetry is taken from *gx16* and remapped on *ww3a* (area average).

* **get_prnc_inp_file**

Generate netCDF input field (wind and ice) for *ww3_prnc*.

* **gen_grid_dot_inp**

Generate ww3\_grid.inp   
