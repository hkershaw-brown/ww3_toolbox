;
; This script interpolates data from a curvilinear grid
; to a lat-lon grid
;
; Qing Li, 20170711

load "$WW3_TOOLBOX_ROOT/share/ncl_procedures_functions.ncl"

begin
; source grid
gTypeIn = "gx16b"
; destination grid
gTypeOut = "0.5x0.5"
; input file
inFile	= "cice_2009.nc"
; fields to be remapped
vars = (/"aice", "hi"/)
; interpolation method (bilinear, patch, conserve, neareststod, nearestdtos)
interpMethod = "patch"

; output files
outFile = str_sub_str(inFile, ".nc", "_"+gTypeOut+".nc")
ww3Root = systemfunc("echo $WW3_TOOLBOX_ROOT")
dirGrid = ww3Root+"/grids"
wgtFileName = dirGrid+"/"+gTypeIn+"_to_"+gTypeOut+"_"+interpMethod+".nc"

; check regridding weights
check_regridding_weights(dirGrid, gTypeIn, gTypeOut, interpMethod)

; read in data
f = addfile(inFile,"r")

; open output file
system("/bin/rm -f "+outFile)
out = addfile(outFile, "c")

;----------------------------------------------------------------------
; apply the weights to variables.
;----------------------------------------------------------------------
opt                = True
opt@PrintTimings   = True

; loop over variables
nvar = dimsizes(vars)
do iv = 0,nvar-1
	; read variable
	var_in = vars(iv)+"_d"
	dat = f->$var_in$
	; remapping
	datRegrid = ESMF_regrid_with_weights(dat, wgtFileName, opt)
	printVarSummary(datRegrid)
	; save variable
	out->$vars(iv)$	= datRegrid
end do

end
