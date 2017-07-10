; This script check the minimum dx 
;
; Li Qing, 20170710

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	diri	= "./grids/"
	fili	= "gx16b.grids.nc" 

	f	= addfile(diri+fili,"w")

; read and regrid region mask
	rmask		= f->REGION_MASK
	dx 		= f->DXT
	lat 		= f->TLAT
	lon 		= f->TLONG
	dxm		= where(rmask .ne. 0, dx/1.0e5, dx@_FillValue)
	dxm@lat2d 	= lat
	dxm@lon2d 	= lon
	mindx 		= min(dxm)
	print(mindx)

	nlt10 	= sum(where(dxm .lt. 10, 1, 0))
	print(nlt10)
	
	nlt9 	= sum(where(dxm .lt. 9, 1, 0))
	print(nlt9)

	l_plot = 0

if (l_plot .eq. 1) then
	polar = "NH"

; open workstation
	res				= True
	res@gsnDraw			= False
	res@gsnFrame			= False
	res@gsnAddCyclic		= True
	res@gsnRightString		= "DX"
        res@lbTitleString               = "km"
	res@gsnMaximize			= True
	res@gsnPaperOrientation		= "portrait" 
	res@gsnPaperMargin		= 0.2
	res@gsnPolar			= polar
; change the size of the image box
	res@vpWidthF	= 0.4
	res@vpHeightF	= 0.4
; map
	if (polar .eq. "NH") then
		res@mpMinLatF	= 70
	else
		res@mpMaxLatF	= -45
	end if

; line labels
	res@cnLinesOn			= False
	res@cnInfoLabelOn		= False
	res@cnLineLabelsOn		= False

	res@cnFillOn			= True
	res@cnFillMode 			= "CellFill"
	res@gsnSpreadColors		= True
	res@cnLevelSelectionMode	= "ManualLevels"
	res@cnMinLevelValF      	= 8
	res@cnMaxLevelValF      	= 20
	res@cnLevelSpacingF     	= 0.5
	res@lbLabelBarOn 		= True
        res@lbOrientation       	= "vertical"    ; vertical label bar
        res@lbLeftMarginF		= 0.0
        res@lbLabelAutoStride		= True
        res@lbTitleFontHeightF 		= 0.013

; plot
; define parameters
	type	= "pdf"  ; plot type
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 6
	;type	= "x11"
	wks	= gsn_open_wks(type, "dx_"+polar) 
	gsn_define_colormap(wks, "BlGrYeOrReVi200")
	plot = gsn_csm_contour_map_polar(wks, dxm, res)
	draw(plot)
	frame(wks)
end if

end 
