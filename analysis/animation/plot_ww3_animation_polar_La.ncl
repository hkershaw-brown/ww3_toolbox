;
; This script plots Langmuir number at polar regions
; The stress at the ocean surface should be a combination of stresses due
; to wind and ice motions
; Assuming both wave and ice data are on the same grid
;
; Li Qing, 20170720

load "$WW3_TOOLBOX_ROOT/share/ncl_procedures_functions.ncl"

begin

; define file names
	gType   = "gx16b"
	yyyymm  = "200907"
	cName	= "testIce2_"+yyyymm+"_"+gType
	nHost	= systemfunc("echo $HOSTNAME")
	matchC	= str_match_ind_ic(nHost, "chace")
	matchY	= str_match_ind_ic(nHost, "yslogin")
	ww3Root = systemfunc("echo $WW3_TOOLBOX_ROOT")
	if (.not. ismissing(matchY)) then
		datDir = "/glade/u/home/qingli/SCRATCH/wwatch3v5p16/"
		diri	= datDir+cName+"/out/"
		diri2	= ww3Root+"/data/"
	else if (.not. ismissing(matchC)) then
		datDir = "/Users/qingli/data_local/WW3/"
		diri	= datDir+cName+"/"
		diri2	= datDir
	end if
	end if
	fili	= "ww3_"+yyyymm+".nc"
	fili2	= "cice_2009.nc"
	; number of output per day of ww3 data
	nout	= 4  ; 6 hourly data

; set variables
	var	= "la"
	minlv 	= 0.1
	maxlv 	= 1.0
	intlv	= 0.05
	l_ice   = True ; plot 15% and 85% ice line

; working directory
	dq 	= str_get_dq() ; double quote
	workDir	= "tmp_"+systemfunc("date "+dq+"+%Y%m%d_%H%M%S"+dq)
	cmd	= "mkdir -p "+workDir
	system(cmd)

; define parameters for figure type
	type	= "ps"  ; plot type
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 6
	;type	= "x11"

; polar regions
	polars  = (/"NH", "SH"/)
	npl	= 2

; read data
	inFile	= diri+fili
	f	= addfile(inFile,"r")
	lat	= f->latitude
	lon	= f->longitude
	time 	= f->time
	time@calendar = "julian"
        nt = dimsizes(time)
	ndsize  = dimsizes(dimsizes(lat))

	inFile2	= diri2+fili2
	f2	= addfile(inFile2,"r")
	time2	= f2->time
	time2_str = sprinti("%08i", cd_calendar(time2, -2))	
	ind2	= str_match_ind(time2_str, yyyymm)
	;print(time2_str(ind2))

; water density
	rhoo = 1000
; air density
	rhoa = 1.225

; read ice
if (l_ice) then
	ice	= f->ice
	if (ndsize .eq. 2) then
		ice@lat2d	= lat
		ice@lon2d	= lon
	end if
end if

; read variables
	; get stokes drift
	results	= read_ww3_vector(inFile, "uss")
	uss	= results[0]
	; remove zeros
	uss0 = where(uss .eq. 0.0, uss@_FillValue, uss)
	delete(results)
	; get wind stress
	uust	= f->uust*sqrt(rhoa/rhoo)
	vust	= f->vust*sqrt(rhoa/rhoo)

	; get ice to ocean stress (daily data, ocean to ice stress) 
	angle = f2->ANGLE
	tauIceX = -1.0*f2->strocnx_d	; ocean to ice -> ice to ocean
	tauIceY = -1.0*f2->strocny_d
	ustIce = sqrt(sqrt(tauIceX^2+tauIceY^2)/rhoo)

	dat = new(dimsizes(uss),typeof(uss))
	; compile daily ice stress and 6 hourly wind stress
	do i=0,nt-1
		j = toint(floor(i/nout))
		k = ind2(j)
		print("Time: "+time2_str(k))
		; convert x- and y-direction on gx16 to east- and west-direction
		utauIce = tauIceX(k,:,:)*cos(angle)-tauIceY(k,:,:)*sin(angle)
		vtauIce = tauIceX(k,:,:)*sin(angle)+tauIceY(k,:,:)*cos(angle)
		ustDir = atan2(vtauIce, utauIce)
		uustIce = ustIce(k,:,:)*cos(ustDir)
		vustIce = ustIce(k,:,:)*sin(ustDir)
		uustTot = uust(i,:,:)*(1.0-ice(j,:,:))+uustIce*ice(j,:,:)
		vustTot = vust(i,:,:)*(1.0-ice(j,:,:))+vustIce*ice(j,:,:)
		ustTot = sqrt(uustTot^2+vustTot^2)
		dat(i,:,:) = sqrt(ustTot/uss0(i,:,:))
	end do

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
	res@gsnRightString		= "La"
	res@gsnMaximize			= True
	res@gsnPaperOrientation		= "portrait"
	res@gsnPaperMargin		= 0.2
	res@gsnPolar			= polar
	res@mpCenterLonF		= 0.0
	res@mpShapeMode			= "FixedAspectFitBB"
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
	res@cnLevelSelectionMode	= "ManualLevels"
	res@cnMinLevelValF      	= minlv
	res@cnMaxLevelValF      	= maxlv
	res@cnLevelSpacingF     	= intlv
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
	end if

; plot
do it = 1, nt-1
;do it = 1, 1
	it_str = sprinti("%03i", it)
	if (mod(it, 10) .eq. 0) then
		print("Step: "+it_str)
	end if
	time_str = sprinti("%08i", cd_calendar(time(it), -2))
	filo	= var+"_"+it_str
	wks	= gsn_open_wks(type, workDir+"/"+filo)
	gsn_define_colormap(wks, "BlGrYeOrReVi200")
	res@gsnLeftString = time_str
	plot=gsn_csm_contour_map_polar(wks,dat(it,:,:),res)
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

; clean up working directory
	cmd = "rm -rf "+workDir
	system(cmd)

	print("-- Done --")

end
