;
; This script interpolates data from a curvilinear grid
; to a lat-lon grid
;
; Qing Li, 20170711

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
; source grid
gTypeIn = "gx16b"
; destination grid
gTypeOut = "0.5x0.5"
; input file
inFile	= "./data/b1850_f19_gx1_ctrl_cice_0099.nc" 
; fields to be remapped
vars = (/"aice", "hi"/)
vlat = "TLAT"
vlon = "TLONG"
vmask = "REGION_MASK"
; interpolation method
intMethod = "bilinear"

; output files
outFile = str_sub_str(inFile, ".nc", "_"+gTypeOut+".nc")
dirGrid = "./grids"
srcGridIn = dirGrid+"/"+gTypeIn+".grids.nc"
srcGridName = dirGrid+"/"+gTypeIn+"_SCRIP.nc"
dstGridName = dirGrid+"/"+gTypeOut+"_SCRIP.nc"
wgtFileName = dirGrid+"/"+gTypeIn+"_to_"+gTypeOut+"_"+intMethod+".nc"

if (.not. fileexists(srcGridName)) then
;----------------------------------------------------------------------
; convert original source curvilinear grid to a SCRIP convention file.
;----------------------------------------------------------------------
	fg = addfile(srcGridIn,"r")
	lat2d = fg->$vlat$
	lon2d = fg->$vlon$    
	rmask = fg->$vmask$
	
	opt                = True
	opt@GridMask       = where(rmask .ne. 0, 1, 0)
	opt@ForceOverwrite = True
	opt@PrintTimings   = True
	opt@Title          = gTypeIn
	
	curvilinear_to_SCRIP(srcGridName, lat2d, lon2d, opt)
	
	; clean up
	delete(opt)
end if

if (.not. fileexists(dstGridName)) then
;----------------------------------------------------------------------
; convert destination lat-lon grid to a SCRIP convention file.
;----------------------------------------------------------------------
	opt                = True
	opt@ForceOverwrite = True
	opt@PrintTimings   = True
	opt@Title          = gTypeOut
	
	latlon_to_SCRIP(dstGridName, gTypeOut, opt)
	
	; clean up
	delete(opt)
end if

if (.not. fileexists(wgtFileName)) then
;----------------------------------------------------------------------
; generate the weights
;----------------------------------------------------------------------
	opt                      = True
	opt@InterpMethod         = intMethod     ; default
	opt@ForceOverwrite       = True
	opt@PrintTimings         = True
	
	ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFileName, opt)
	
	delete(opt)
end if

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
