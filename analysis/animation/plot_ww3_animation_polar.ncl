;
; This script plots ww3 variables at polar regions
;
; Li Qing, 20170630

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; define file names
	gType   = "gx16b"
	yyyymm  = "200901"
	cName	= "testIce2_"+yyyymm+"_"+gType
	nHost	= systemfunc("echo $HOSTNAME")
	matchC	= str_match_ind_ic(nHost, "chace")
	matchY	= str_match_ind_ic(nHost, "yslogin")
	if (.not. ismissing(matchY)) then
		datDir = "/glade/u/home/qingli/SCRATCH/wwatch3v5p16/"
		diri	= datDir+cName+"/out/"
	else if (.not. ismissing(matchC)) then
		datDir = "/Users/qingli/data_local/WW3/"
		diri	= datDir+cName+"/"
	else
		print("Host "+nHost+" not supported")
		exit()
	end if
	end if
	fili	= "ww3_"+yyyymm+".nc"

; set variables
	vars	= (/ "hs", "uss", "tus", "wnd"/)
	isVec	= (/False,  True,  True,  True/)
	minlv 	= (/    0,     0,     0,     0/)
	maxlv 	= (/   10,   0.4,     4,    25/)
	intlv	= (/ 0.25,  0.02,   0.2,     1/)
	l_ice   = True ; plot 15% and 85% ice line

; working directory
	dq 	= str_get_dq() ; double quote
	workDir	= "tmp_"+systemfunc("date "+dq+"+%Y%m%d_%H%M%S"+dq)
	cmd	= "mkdir -p "+workDir
	system(cmd)

; polar regions
	polars  = (/"NH", "SH"/)
	npl	= 2

; define parameters for figure type
	type	= "ps"  ; plot type
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 6
	;type	= "x11"

; read data
	inFile	= diri+fili
	f	= addfile(inFile,"r")
	lat	= f->latitude
	lon	= f->longitude
	time 	= f->time
	time@calendar = "julian"
        nt = dimsizes(time)
	ndsize  = dimsizes(dimsizes(lat))

; read ice
if (l_ice) then
	ice	= f->ice
	if (ndsize .eq. 2) then
		ice@lat2d	= lat
		ice@lon2d	= lon
	end if
end if

; loop over variables
nvar 	= dimsizes(vars)
do iv=0,nvar-1
	var 	= vars(iv)
	print("Variable: "+var)

; read variables
	if (isVec(iv)) then
		varX = "u"+var
		varY = "v"+var
		datX = f->$varX$
		datY = f->$varY$
		dat = sqrt(datX^2+datY^2)
		dat@units = datX@units
		dat@_FillValue = datX@_FillValue
		dat@long_name = "magnitude of "+str_sub_str(datX@long_name, "eastward ","")
		if (ndsize .eq. 2) then
			datX@lat2d	= lat
			datX@lon2d	= lon
			datY@lat2d	= lat
			datY@lon2d	= lon
		end if
	else
		dat	= f->$var$
	end if
	if (ndsize .eq. 2) then
		dat@lat2d	= lat
		dat@lon2d	= lon
	end if

; loop over polar regions
do ip=0,npl-1
	polar	= polars(ip)
	print("Polar region: "+polar)

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
	res@gsnPolar			= polar
	res@mpCenterLonF		= 0.0
	res@mpShapeMode			= "FixedAspectFitBB"
; change the size of the image box
	res@vpWidthF	= 0.4
	res@vpHeightF	= 0.4
	if (isVec(iv)) then
		res@gsnScalarContour	= True
	end if
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
	res@cnLevelSelectionMode	= "ManualLevels"
	res@cnMinLevelValF      	= minlv(iv)
	res@cnMaxLevelValF      	= maxlv(iv)
	res@cnLevelSpacingF     	= intlv(iv)
	res@lbLabelBarOn 		= True
        res@lbOrientation       	= "vertical"    ; vertical label bar
        res@lbLeftMarginF		= 0.0
        res@lbLabelAutoStride		= True
        res@lbTitleFontHeightF 		= 0.013

; for 15% and 85% ice fraction contours
	if (l_ice) then
		ires    = res
		ires@cnLinesOn			= True  ; turn line on and fill off
		ires@cnFillOn			= False
		ires@cnLevelSelectionMode	= "ExplicitLevels"
		ires@cnLevels			= (/0.15, 0.85/)   ; change contour interval
		ires@cnLineColor 		= "white"
		ires@cnLineThicknessF		= 1.5
		ires@gsnLeftString		= ""    ; no string for plot2
		ires@gsnRightString		= ""
		delete(ires@gsnPolar)       ; no longer in use for plot2
		if (polar .eq. "NH") then
			delete(ires@mpMinLatF)
		else
			delete(ires@mpMaxLatF)
		end if
		delete(ires@mpCenterLonF)
		delete(ires@mpShapeMode)
		delete(ires@cnMinLevelValF)
		delete(ires@cnMaxLevelValF)
		delete(ires@cnLevelSpacingF)
		if (isatt(ires, "gsnScalarContour")) then
			delete(ires@gsnScalarContour)
		end if
	end if

; vector plot
	if (isVec(iv)) then
		res@vcRefMagnitudeF		= maxlv(iv)       ; define vector ref mag
		res@vcRefLengthF		= 0.04            ; define length of vec ref
		res@vcRefAnnoOrthogonalPosF	= -1.0            ; move ref vector
		res@vcRefAnnoParallelPosF	= 0.95
		res@vcRefAnnoArrowLineColor	= "black"         ; change ref vector color
		res@vcRefAnnoArrowUseVecColor	= False
		res@vcGlyphStyle		= "LineArrow"     ; turn on curley vectors
		res@vcLineArrowColor		= "black"         ; change vector color
		res@vcLineArrowThicknessF	= 0.8             ; change vector thickness
		res@vcVectorDrawOrder		= "PostDraw"      ; draw vectors last
		res@vcMinDistanceF		= 0.012		  ; space belween vectors
	end if

; plot
do it = 1, nt-1
	it_str = sprinti("%03i", it)
	if (mod(it, 10) .eq. 0) then
		print("Step: "+it_str+"...")
	end if
	time_str = sprinti("%08i", cd_calendar(time(it), -2))
	filo	= var+"_"+it_str
	wks	= gsn_open_wks(type, workDir+"/"+filo)
	gsn_define_colormap(wks, "BlGrYeOrReVi200")
	res@gsnLeftString = time_str
	if (isVec(iv)) then
		plot = gsn_csm_vector_scalar_map_polar(wks,datX(it,:,:),datY(it,:,:),dat(it,:,:),res)
	else
		plot = gsn_csm_contour_map_polar(wks,dat(it,:,:),res)
	end if
	if (l_ice) then
		plot2 = gsn_csm_contour(wks,ice(it,:,:),ires)
		overlay(plot,plot2)
	end if
	draw(plot)
	frame(wks)
	delete(wks)
end do
	delete(res)

; create directory
	cmd = "mkdir -p "+cName
	system(cmd)

; create gif
	print("Making a gif...")
	cmd = "convert -density 150 -delay 25 "+workDir+"/"+var+"_*.ps "+cName+"/"+var+"_"+yyyymm+"_"+gType+"_"+polar+".gif"
	system(cmd)

; save ps files
	print("Saving .ps files in .tar.gz")
	cmd = "tar -czf "+cName+"_"+var+"_"+polar+"_ps.tar.gz -C "+workDir+" ."
	system(cmd)
	cmd = "mv *.tar.gz "+cName+"/"
	system(cmd)

; clean up ps files
	print("Cleaning up...")
	cmd = "rm -f "+workDir+"/*.ps"
	system(cmd)

end do ; end loop over polars

	delete(dat)
	if (isvar("datX")) then
		delete(datX)
	end if
	if (isvar("datY")) then
		delete(datY)
	end if

end do ; end loop over variables

; clean up working directory
	cmd = "rm -rf "+workDir
	system(cmd)

	print("-- Done --")

end
