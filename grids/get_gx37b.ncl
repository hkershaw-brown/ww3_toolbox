; This script modifies the grid gx37 to exclude marginal seas
;
; Li Qing, 20170713

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	diri	= "./"
	filb	= "gx37.grids.nc" 
	fili	= "gx37b.grids.nc"

	cmd 	= "cp "+diri+"/"+filb+" "+diri+"/"+fili
	system(cmd) 

	f	= addfile(diri+fili,"w")

; read and regrid region mask
	rmask		= f->REGION_MASK
	ht 		= f->HT
	rmask_new	= rmask

	; remove marginal seas and Mediterranean
	rmask_new	= where(rmask .lt. 0,   0, rmask_new)
	rmask_new	= where(rmask .eq. 4,   0, rmask_new)
	rmask_new	= where(rmask .eq. 7,   0, rmask_new)

	; apply mask on water depth
	ht 		= where(rmask_new .eq. 0, 0.0, ht)

	; update variables
	f->REGION_MASK	= (/rmask_new/)
	f->HT 		= (/ht/)

	; plot removed points
	lat 		= f->TLAT
	lon 		= f->TLONG
	rmpoint = where(rmask_new .eq. rmask, -1, 1)
	rmpoint = where(rmask .eq. 0, rmask@_FillValue, rmpoint)
	rmpoint@lat2d 	= lat
	rmpoint@lon2d 	= lon

	polars = (/"NH", "SH"/)
do i=0,1
	polar = polars(i)
	print(polar)

	res				= True
	res@gsnDraw			= False
	res@gsnFrame			= False
	res@gsnAddCyclic		= True
	res@gsnRightString		= "Removed points"
	res@gsnMaximize			= True
	res@gsnPaperOrientation		= "portrait" 
	res@gsnPaperMargin		= 0.2
	res@gsnPolar			= polar
; change the size of the image box
	res@vpWidthF	= 0.4
	res@vpHeightF	= 0.4
; map
	if (polar .eq. "NH") then
		res@mpMinLatF	= 45
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
	res@cnLevelSelectionMode	= "ExplicitLevels"
	res@cnLevels 			= (/-1, 0, 1/)
	res@lbLabelBarOn 		= False

; plot
; define parameters
	type	= "pdf"  ; plot type
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 6
	;type	= "x11"
	wks	= gsn_open_wks(type, diri+"/pdiff_"+polar) 
	gsn_define_colormap(wks, "temp_diff_1lev")
	gsn_reverse_colormap(wks)
	plot = gsn_csm_contour_map_polar(wks, rmpoint, res)
	draw(plot)
	frame(wks)
	delete(res)
end do

end 
