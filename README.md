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


## gx16b

This is a global grid for WW3 based on gx16 grid for POP. Modifications include:

* Removed Baltic Sea, Mediterranean and Persian Gulf.

* Removed lakes.

* Removed Nares Strait.

* Removed 8 grid points near Greenland where the grid size dx < 9 km.

All the remaining points has a minimum grid size min(dx, dy) = 9.07 km. With the minimum frequency f = 0.04118 s^{-1}, the maximum group velocity is max(c\_{g}) ~ 19 m/s. The CFL time step (with CFL number ~ 1) is then set by max(dt) = min(dx, dy)/max(c\_{g}) ~ 479 s. Therefore the maximum CFL time step for x-y propagation is set to 450 s. The maximum global time step, the k-theta propagation time step and the minimum source term time step are set to 1800 s, 900 s and 15 s, respectively. See *ww3_grid.inp.gx16b*.
