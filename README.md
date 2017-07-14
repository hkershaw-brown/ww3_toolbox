# ww3_toolbox

This is a tool box for submitting WW3 jobs on Yellowstone and Cheyenne.


## Step 1: Prepare grid

Tools for generating grid and preparing for the input file are located in the folder `grids/`.

* **get_grid_inp_file**

This Python script generates *ww3_grid* input data (x, y, bottom) for global grids *gx37* and *gx16*. Require `TLONG`, `TLAT`, `HT` and `REGION_MASK` stored in netCDF format, i.e., *gx37.grids.nc* and *gx16.grids.nc*.


* **get_gx16b.ncl**

This NCL script modifies the grid gx16 to exclude marginal seas and Nares Strait.


* **get_gx37b.ncl**

This NCL script modifies the grid gx37 to exclude marginal seas.


* **get_bottom_ww3a**

This Python script generates *ww3_grid* input data (bottom) for global grid *ww3a*. Bathymetry is taken from *gx16* and remapped on *ww3a* (area average).

* **gen_grid_dot_inp**

This Python generates ww3\_grid.inp


### gx16b

This is a global grid for WW3 based on gx16 grid for POP. Modifications include:

* Removed Baltic Sea, Mediterranean and Persian Gulf.

* Removed lakes.

* Removed Nares Strait.

* Removed 8 grid points near Greenland where the grid size dx < 9 km.

All the remaining points has a minimum grid size min(dx, dy) = 9.07 km. With the minimum frequency f = 0.04118 s^{-1}, the maximum group velocity is max(c\_{g}) ~ 19 m/s. The CFL time step (with CFL number ~ 1) is then set by max(dt) = min(dx, dy)/max(c\_{g}) ~ 479 s. Therefore the maximum CFL time step for x-y propagation is set to 450 s. The maximum global time step, the k-theta propagation time step and the minimum source term time step are set to 1800 s, 900 s and 15 s, respectively. See *ww3_grid.inp.gx16b*.


### mww3a

## Step 2: Prepare input data

Tools for preparing the input forcing field (wind and ice, etc.) are located in the folder `data/`. The input data for *ww3_prnc* will be generated in `data/prnc_inp`


* **get_ncep_wind_ice**

This Python script generates netCDF input field (wind and ice) from CORE II wind and sea ice data.


* **get_cesm_cice**

This Bash script prepares sea ice input files (sea ice fraction and thickness) from existing CICE output data.


* **curvilin2latlon.ncl**

This NCL script remaps a netCDF file with curvilinear grid (such as *gx16*) to lat-lon grid.


* **check_min_dx.ncl**

This NCL script prints out the minimum dx in grid gx16b.


## Step 3: Compile and run

Input files for *ww3_shel* and *ww3_multi* are in `run/shel_inp` and `run/multi_inp`.


* **run_wwatch3_shel**

This Bash script sets up input files, compiles the code and submits jobs to run WW3 with single grid on Yellowstone or Cheyenne.


* **run_wwatch3_multi**

This Bash script sets up input files, compiles the code and submits jobs to run WW3 with multiple grids on Yellowstone or Cheyenne.


## Step 4: Convert output data to netCDF format


## Step 5: Plot figures

Tools for plotting figures, making animations are located in the folder `plot`


