; This script get the mean differences and RMSD of variables between two grids
;
; Qing Li, 20170714

load "$WW3_TOOLBOX_ROOT/share/ncl_procedures_functions.ncl"

begin

; data path
pData = "/Users/qingli/data_local/WW3"
cName = "testIce"
yyyymm = "200907"
vars = (/"hs", "t02", "fp", "ust", "uss", "tus"/)
isVector = (/False, False, False, True, True, True/)
grid1 = "gx37"
grid2 = "gx16b"
; input data
inFile1 = pData+"/"+cName+"/"+grid1+"/ww3_"+yyyymm+".nc"
inFile2 = pData+"/"+cName+"/"+grid2+"/ww3_"+yyyymm+".nc"
; output data
outFile = cName+"_gridErr_"+grid1+"_"+grid2+"_"+yyyymm+".out"
; if plot snapshot
l_plot = True

; grid path
ww3Root = systemfunc("echo $WW3_TOOLBOX_PATH")
dirGrid = ww3Root+"/grids"
; source grid
gTypeIn = grid1
; destination grid
gTypeOut = grid2
; interpolation method
interpMethod = "neareststod"
; weights file name
wgtFileName = dirGrid+"/"+gTypeIn+"_to_"+gTypeOut+"_"+interpMethod+".nc"

; check regridding weights
check_regridding_weights(dirGrid, gTypeIn, gTypeOut, interpMethod)

; options for ESMF_regrid_with_weights
opt                = True
opt@PrintTimings   = True

; open file
f1 = addfile(inFile1, "r")
lat1 = f1->latitude
lon1 = f1->longitude
f2 = addfile(inFile2, "r")
lat2 = f2->latitude
lon2 = f2->longitude
time = f1->time
nt = dimsizes(time)
;print(nt)
; averaging window
inds = nt/2
inde = nt-1
; radians to degree
r2d = 45.0/atan(1.0)
; write header
write_table(outFile, "w", \
	[/"VAR", "Mean ("+grid1+")", "Mean ("+grid2+")", "Mean Diff.", "RMSD", "RMS", "RMSD/RMS"/],\
	 "%18s %15s %15s %15s %12s %12s %12s")

; loop over variables
nVar = dimsizes(vars)
do i=0,nVar-1
	var = vars(i)
	if (isVector(i)) then
		; vector field
		results = read_ww3_vector(inFile1, var)
		dat1 = results[0]
		dir1 = results[1]
		delete(results)
		results = read_ww3_vector(inFile2, var)
		dat2 = results[0]
		dir2 = results[1]
		delete(results)
		dat1Regrid = ESMF_regrid_with_weights(dat1, wgtFileName, opt)
		dir1Regrid = ESMF_regrid_with_weights(dir1, wgtFileName, opt)
	else
		;scalar fidld
		dat1 = f1->$var$
		dat1@lat2d = lat1
		dat1@lon2d = lon1
		dat2 = f2->$var$
		dat2@lat2d = lat2
		dat2@lon2d = lon2
		dat1Regrid = ESMF_regrid_with_weights(dat1, wgtFileName, opt)
	end if
	;; check regridding
	;printVarSummary(dat1Regrid)
	;printMinMax(dat1, 1)
	;printMinMax(dat1Regrid, 1)
	;printVarSummary(dat2)
	;printMinMax(dat2, 1)
	;; check difference
	datDiff = dat1Regrid
	datDiff = (/dat1Regrid-dat2/)
	;printMinMax(datDiff, 1)
	; calculate the root mean square difference
	rmsd = wgt_arearmse(dat1Regrid, dat2, 1.0, 1.0, 0)
	;print(rmsd)
	rmsd_tavg = avg(rmsd(inds:inde))
	;print(rmsd_tavg)
	; calculate the root mean square value on grid2
	zeros = dat2
	zeros = (/dat2*0.0/)
	rms  = wgt_arearmse(zeros, dat2, 1.0, 1.0, 0)
	;print(rms)
	rms_tavg = avg(rms(inds:inde))	
	;print(rms_tavg)
	nrmsd_tavg = rmsd_tavg/rms_tavg
	; calculate the mean and difference
	dat1Mean = avg(dat1(inds:inde,:,:))	
	dat2Mean = avg(dat2(inds:inde,:,:))
	meanDiff = dat1Mean-dat2Mean
	;print(dat1Mean)
	;print(dat2Mean)
	;print(meanDiff)
	write_table(outFile, "a", \
		[/var+" ("+dat1@units+")", dat1Mean, dat2Mean, meanDiff, rmsd_tavg, rms_tavg, nrmsd_tavg/], \
		 "%18s %15.2f %15.2f %15.2f %12.2f %12.2f %12.2f")
	;; for direction
	;if (isVector(i)) then
	;	; calculate the root mean square difference
	;	rmsd = wgt_arearmse(dir1Regrid, dir2, 1.0, 1.0, 0)
	;	rmsd_tavg = avg(rmsd(inds:inde))
	;	; calculate the root mean square value on grid2
	;	rms  = wgt_arearmse(zeros, dir2, 1.0, 1.0, 0)
	;	rms_tavg = avg(rms(inds:inde))	
	;	nrmsd_tavg = rmsd_tavg/rms_tavg
	;	; calculate the mean and difference
	;	dat1Mean = avg(dir1(inds:inde,:,:))	
	;	dat2Mean = avg(dir2(inds:inde,:,:))
	;	meanDiff = dat1Mean-dat2Mean
	;	write_table(outFile, "a", \
	;		[/var+" dir. (deg.)", dat1Mean, dat2Mean, meanDiff, rmsd_tavg, rms_tavg, nrmsd_tavg/], \
	;	 	"%18s %15.2f %15.2f %15.2f %12.2f %12.2f %12.2f")
	;	datDiff = dir1Regrid
	;	datDiff = (/dir1Regrid-dir2/)
	;end if

	; Check the differences
	if (l_plot) then
	; plot a snapshot
		type    = "ps"  ; plot type
		type@wkPaperWidthF  = 6
		type@wkPaperHeightF = 4.5
		;type    = "x11"
		figOut = cName+"_"+var+"_diff_"+yyyymm
		figOut2 = cName+"_"+var+"_"+grid2+"_"+yyyymm
	
		res = True
		res@gsnLeftString	= figOut
		test_plot_map(type, figOut, datDiff(nt-1,:,:), res)
		;test_plot_map_polar(type, figOut, datDiff(nt-1,:,:), res)
		res@gsnLeftString	= figOut2
		test_plot_map(type, figOut2, dat2(nt-1,:,:), res)
		;test_plot_map_polar(type, figOut2, dat2(nt-1,:,:), res)
	end if
	delete(dat1)
	delete(dat2)
	delete(dat1Regrid)
	delete(datDiff)
	delete(zeros)
	if (isvar("dir1Regrid")) then
		delete(dir1Regrid)
	end if
end do ; variables

end 
