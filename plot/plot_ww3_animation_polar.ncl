;
; This script plots ww3 variables at Arctic
;
; Li Qing, 20170630

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; define parameters
	type	= "ps"  ; plot type
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 6
	;type	= "x11"

; define file names
	casen	= "icefree_200907_gx16"
	datadir = "/glade/u/home/qingli/SCRATCH/wwatch3v5p16/"
	diri	= datadir+casen+"/out/"
	fili	= "ww3_icefree_200907.nc" 
	f	= addfile(diri+fili,"r")
	var	= "hs"

; read variables
	dat	= f->$var$
	lat	= f->latitude
	lon	= f->longitude
	dat@lat2d	= lat
	dat@lon2d	= lon
	time 	= f->time 
	time@calendar = "julian"

        dimdat = dimsizes(dat)
        nt = dimdat(0)

; open workstation

	res				= True
	res@gsnDraw			= False
	res@gsnFrame			= False
	res@gsnAddCyclic		= True
	res@gsnRightString		= var
        res@lbTitleString               = dat@units
	res@gsnMaximize			= True
	res@gsnPaperOrientation		= "portrait" 
	res@gsnPaperMargin		= 0.2
	res@gsnPolar			= "NH"
; change the size of the image box
	res@vpWidthF	= 0.4
	res@vpHeightF	= 0.4
; map
	res@mpMinLatF	= 45

; line labels
	res@cnLinesOn				= False
	res@cnInfoLabelOn			= False
	res@cnLineLabelsOn			= False
	res@trYReverse				= True			; reverse the Y-axis

	res@cnFillOn				= True
	res@cnFillMode 				= "CellFill"
	res@gsnSpreadColors			= True
	res@cnLevelSelectionMode                = "ManualLevels"
	res@cnMinLevelValF                      = 0
	res@cnMaxLevelValF                      = 10
	res@cnLevelSpacingF                     = 0.25
	res@lbLabelBarOn 	      		= True
        res@lbOrientation                       = "vertical"    ; vertical label bar
        res@lbLeftMarginF                       = 0.0
        res@lbLabelAutoStride                   = True
        res@lbTitleFontHeightF = 0.013

; plot
do it = 0, nt-1
	it_str = sprinti("%03i", it) 
	print(it_str)
	time_str = sprinti("%08i", cd_calendar(time(it), -2))
	filo	= var+"_"+it_str
	wks	= gsn_open_wks(type, filo) 
	gsn_define_colormap(wks, "BlGrYeOrReVi200")
	res@gsnLeftString = time_str
	plot=gsn_csm_contour_map_polar(wks,dat(it,:,:),res)
	draw(plot)
	frame(wks)
	delete(wks)
end do
	cmd = "convert -density 150 -delay 25 "+var+"_*.ps "+var+"_200907.gif"
	system(cmd)
end 
