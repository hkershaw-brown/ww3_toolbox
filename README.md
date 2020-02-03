
# ww3_toolbox

This is a tool box for submitting WW3 jobs on Yellowstone and Cheyenne and Oscar.

## Step 0: Create grid_inp_file

 source ww3_grids/bin/activate
 grids/create_netcdf.sh

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


* **check_min_dx.ncl**

This NCL script prints out the minimum dx in grid gx16b.


* **gen_grid_dot_inp**

This Python generates ww3\_grid.inp


### gx16b

This is a global grid for WW3 based on gx16 grid for POP. Modifications include:

* Removed Baltic Sea, Mediterranean and Persian Gulf.

* Removed lakes.

* Removed Nares Strait.

* Removed 8 grid points near Greenland where the grid size dx < 9 km.

All the remaining points has a minimum grid size min(dx, dy) = 9.07 km. With the minimum frequency f = 0.04118 s^{-1}, the maximum group velocity is max(c\_{g}) ~ 19 m/s. The CFL time step (with CFL number ~ 1) is then set by max(dt) = min(dx, dy)/max(c\_{g}) ~ 479 s. Therefore the maximum CFL time step for x-y propagation is set to 450 s. The maximum global time step, the k-theta propagation time step and the minimum source term time step are set to 1800 s, 900 s and 15 s, respectively. See *ww3_grid.inp.gx16b*.

### gx37b

This is a global grid for WW3 based on gx37 grid for POP. Marginal seas (including Baltic Sea, Mediterranean and Persian Gulf) and lakes are removed.

### mww3a

This is a global grid set for WW3 with multiple grid option. It is a combination of *gx16b* and *gx37b*, i.e., *gx16b* in polar regions for wave-sea ice interaction in MIZ and *gx37b* elsewhere for maximum computational economy.

## Step 2: Prepare input data

Tools for preparing the input forcing field (wind and ice, etc.) are located in the folder `data/`. The input data for *ww3_prnc* will be generated in `data/prnc_inp`


* **get_ncep_wind_ice**

This Python script generates netCDF input field (wind and ice) from CORE II wind and sea ice data.


* **get_cesm_cice**

This Bash script prepares sea ice input files (sea ice fraction and thickness) from existing CICE output data.


* **curvilin2latlon.ncl**

This NCL script remaps a netCDF file with curvilinear grid (such as *gx16*) to lat-lon grid.


## Step 3: Compile and run

Input files for *ww3_shel* and *ww3_multi* are in `run/shel_inp/` and `run/multi_inp/`.


* **run_wwatch3_shel**

This Bash script sets up input files, compiles the code and submits jobs to run WW3 with single grid on Yellowstone or Cheyenne.


* **run_wwatch3_multi**

This Bash script sets up input files, compiles the code and submits jobs to run WW3 with multiple grids on Yellowstone or Cheyenne.


## Step 4: Convert output data to netCDF format

Input files for *ww3_ounf* and *gint_inp* to convert WW3 output data to netCDF format and interpolate WW3 data on multiple grids on a single grid are located in `postprocess/ounf_inp` and `postprocess/gint_inp`, respectively.


## Step 5: Analyze the results

Tools for plotting figures, making animations and analyze data (e.g., calculating RMS differences) are located in the folder `analysis/`.


## Shared code in `share/`

* **bash_functions.sh**

A collection of Bash script functions used in *run_wwatch3_shel* and *run_wwatch3_multi*. Load these functions by

`source ./share/bash_functions.sh`


* **ncl_procedures_functions.ncl**

A collection of NCL functions and procedures used in some NCL scripts. To use these procedures and functions, add the following line at the beginning of the NCL script (`WW3_TOOLBOX_ROOT` is the root directory of this toolbox).

`load "WW3_TOOLBOX_ROOT/share/ncl_procedures_functions.ncl"`
