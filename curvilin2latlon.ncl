;
; This script interpolates data from gx16 to 1dx1d
;
; Li Qing, 20170711

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
gtype_in = "gx16b"
gtype_out = "0.5x0.5"
; input file
infile	= "./data/b1850_f19_gx1_ctrl_cice_0099.nc" 
; output file
outfile	= "./data/b1850_f19_gx1_ctrl_cice_0099_"+gtype_out+".nc"
vars = (/"aice", "hi"/)

;---Output (and input) files
srcGridIn = "./grids/"+gtype_in+".grids.nc"
srcGridName = "./grids/"+gtype_in+"_SCRIP.nc"
dstGridName = "./grids/"+gtype_out+"_SCRIP.nc"
wgtFileName = "./grids/"+gtype_in+"_to_"+gtype_out+".nc"

if (.not. fileexists(srcGridName)) then
;----------------------------------------------------------------------
; Convert original source gxXX grid to a SCRIP convention file.
;----------------------------------------------------------------------
	fg = addfile(srcGridIn,"r")
	lat2d = fg->TLAT
	lon2d = fg->TLONG     
	rmask = fg->REGION_MASK
	
	Opt                = True
	Opt@GridMask       = where(rmask .ne. 0, 1, 0)    ; use "Mask2D" in NCL V6.2.1 and earlier
	Opt@ForceOverwrite = True
	Opt@PrintTimings   = True
	Opt@Title          = gtype_in
	
	curvilinear_to_SCRIP(srcGridName, lat2d, lon2d, Opt)
	
	;---Clean up
	delete(Opt)
end if

if (.not. fileexists(dstGridName)) then
;----------------------------------------------------------------------
; Convert destination grid to a SCRIP convention file.
;----------------------------------------------------------------------
	Opt                = True
	Opt@ForceOverwrite = True
	Opt@PrintTimings   = True
	Opt@Title          = gtype_out
	
	latlon_to_SCRIP(dstGridName, gtype_out, Opt)
	
	;---Clean up
	delete(Opt)
end if

if (.not. fileexists(wgtFileName)) then
;----------------------------------------------------------------------
; Generate the weights
;----------------------------------------------------------------------
	Opt                      = True
	Opt@InterpMethod         = "bilinear"     ; default
	Opt@ForceOverwrite       = True
	Opt@PrintTimings         = True
	
	ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFileName, Opt)
	
	delete(Opt)
end if


; read in data
f = addfile(infile,"r")

; output file
system("/bin/rm -f "+outfile)
out     = addfile(outfile,"c")

;----------------------------------------------------------------------
; Apply the weights to variables.
;----------------------------------------------------------------------
Opt                = True
Opt@PrintTimings   = True

; loop over variables
nvar = dimsizes(vars)
do iv = 0,nvar-1
	; read variable
	dat = f->$vars(iv)$
	; remapping
    	dat_rg = ESMF_regrid_with_weights(dat, wgtFileName, Opt)
    	printVarSummary(dat_rg)
	; save variable
	out->$vars(iv)$	= dat_rg
end do
end
