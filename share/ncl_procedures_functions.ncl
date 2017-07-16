; This script contains procedures and functions that are shared
; by multiple ncl scripts
;
; Qing Li, 20170714

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

undef("get_gird_type")
function get_grid_type(gName:string)
; Return grid type:
; 	0: Grid not supported
;	1: Lat-Lon
;	2: Curvilinear
begin
	; Try match lat-lon 
	gMatchL = str_match_ind_ic_regex(gName, "^[0-9].*x[0-9].*")
	gMatchL2 = str_match_ind_ic_regex(gName, "^[0-9].*deg$")
	gMatchC = str_match_ind_ic_regex(gName, "^gx.*")
	if ((.not. ismissing(gMatchL)) .or. (.not. ismissing(gMatchL2))) then
		return(1)
	else if (.not. ismissing(gMatchC)) then
		return(2)
	else
		return(0)
	end if
	end if
	delete(gMatchL)
	delete(gMatchL2)
	delete(gMatchC)
end ; function


procedure check_regridding_weights(dirGrid:string, gTypeIn:string, \
				gTypeOut:string, interpMethod:string)
; This procedure checks and generates regridding weights if necessary
; Input list:
;	;grid path
;	dirGrid = "../grids"
; 	; source grid
;	gTypeIn = "gx37"
;	; destination grid
;	gTypeOut = "1x1"
;	; interpolation method
;	interpMethod = "neareststod"
begin
	; check grid names
	gridS = get_grid_type(gTypeIn)
	gridD = get_grid_type(gTypeOut)
	if (gridS .eq. 0 .or. gridD .eq. 0) then
		print("Grid type not supported.")
		exit()
	end if
	if (gridS .eq. 2) then
		vLatS = "TLAT"
		vLonS = "TLONG"
		vMaskS = "REGION_MASK"
	end if
	if (gridD .eq. 2) then
		vLatD = "TLAT"
		vLonD = "TLONG"
		vMaskD = "REGION_MASK"
	end if
	;; Preparing files for remapping
	; output files
	wgtFileName = dirGrid+"/"+gTypeIn+"_to_"+gTypeOut+"_"+interpMethod+".nc"
	if (.not. fileexists(wgtFileName)) then
	;----------------------------------------------------------------------
	; generate the weights
	;----------------------------------------------------------------------
		srcGridIn = dirGrid+"/"+gTypeIn+".grids.nc"
		dstGridIn = dirGrid+"/"+gTypeOut+".grids.nc"
		srcGridName = dirGrid+"/"+gTypeIn+"_SCRIP.nc"
		dstGridName = dirGrid+"/"+gTypeOut+"_SCRIP.nc"
		if (.not. fileexists(srcGridName)) then
		;----------------------------------------------------------------------
		; convert original source curvilinear grid to a SCRIP convention file.
		;----------------------------------------------------------------------
			opt                = True
			opt@Title          = gTypeIn
			opt@ForceOverwrite = True
			opt@PrintTimings   = True
			if (gridS .eq. 2) then
				fgs = addfile(srcGridIn,"r")
				lat2dS = fgs->$vLatS$
				lon2dS = fgs->$vLonS$    
				rmaskS = fgs->$vMaskS$
				opt@GridMask       = where(rmaskS .ne. 0, 1, 0)
				curvilinear_to_SCRIP(srcGridName, lat2dS, lon2dS, opt)
			else if (gridS .eq. 1) then
				latlon_to_SCRIP(dstGridName, gTypeIn, opt)
			end if
			end if
			; clean up
			delete(opt)
		end if
		if (.not. fileexists(dstGridName)) then
		;----------------------------------------------------------------------
		; convert destination lat-lon grid to a SCRIP convention file.
		;----------------------------------------------------------------------
			opt                = True
			opt@Title          = gTypeOut
			opt@ForceOverwrite = True
			opt@PrintTimings   = True
			if (gridD .eq. 2) then
				fgd = addfile(dstGridIn,"r")
				lat2dD = fgd->$vLatD$
				lon2dD = fgd->$vLonD$    
				rmaskD = fgd->$vMaskD$
				opt@GridMask       = where(rmaskD .ne. 0, 1, 0)
				curvilinear_to_SCRIP(dstGridName, lat2dD, lon2dD, opt)
			else if (gridD .eq. 1) then
				latlon_to_SCRIP(dstGridName, gTypeOut, opt)
			end if
			end if
			; clean up
			delete(opt)
		end if
		opt                      = True
		opt@InterpMethod         = interpMethod     ; default
		opt@ForceOverwrite       = True
		opt@PrintTimings         = True
		ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFileName, opt)
		; clean up	
		delete(opt)
	end if
end ; procedure


procedure test_plot_map(type, figOut, dat, res)
; This procedure set up a quick map figure with some default settings 

local res, dat, type, wks, plot, opts, figOut
begin
	if (res) then
		opts = res
	else
		opts = True
	end if
	; open workstation
	wks		= gsn_open_wks(type, figOut) 
	gsn_define_colormap(wks, "MPL_rainbow")
	opts@gsnDraw			= False
	opts@gsnFrame			= False
	opts@gsnAddCyclic		= True
	opts@gsnMaximize		= True
	opts@gsnPaperMargin		= 0.2
	opts@gsnPaperOrientation	= "portrait" 
	opts@gsnSpreadColors		= True
	opts@vpWidthF			= 0.6
	opts@vpHeightF			= 0.4
	opts@mpCenterLonF		= 200
	opts@mpShapeMode		= "FreeAspect"
	opts@cnLinesOn			= False
	opts@cnInfoLabelOn		= False
	opts@cnLineLabelsOn		= False
	opts@cnFillOn			= True
	opts@cnFillMode			= "CellFill"
	opts@lbLabelBarOn		= True
        opts@lbOrientation		= "vertical"
        opts@lbLeftMarginF		= 0.0
        opts@lbLabelAutoStride		= True
	if (.not. isatt(opts, "gsnLeftString")) then
		opts@gsnLeftString		= " "
	end if
	if (.not. isatt(opts, "gsnRightString")) then
		opts@gsnRightString		= dat@units
	end if
	if (.not. isatt(opts, "cnLevelSelectionMode")) then
		opts@cnLevelSelectionMode	= "AutomaticLevels"
	end if
	; plot
	plot = gsn_csm_contour_map(wks, dat, opts)
	draw(plot)
	frame(wks)
end ; procedure