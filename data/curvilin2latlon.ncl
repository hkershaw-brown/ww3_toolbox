;
; This script interpolates data from a curvilinear grid
; to a lat-lon grid
;
; Qing Li, 20170711

load "../share/ncl_procedures_functions.ncl"

begin
; source grid
gTypeIn = "gx16b"
; destination grid
gTypeOut = "0.5x0.5"
; input file
inFile	= "b1850_f19_gx1_ctrl_cice_0099.nc" 
; fields to be remapped
vars = (/"aice", "hi"/)
; interpolation method
interpMethod = "bilinear"

; output files
outFile = str_sub_str(inFile, ".nc", "_"+gTypeOut+".nc")
dirGrid = "../grids"
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
	dat = f->$vars(iv)$
	; remapping
	datRegrid = ESMF_regrid_with_weights(dat, wgtFileName, opt)
	printVarSummary(datRegrid)
	; save variable
	out->$vars(iv)$	= datRegrid
end do

end
