; This script get the RMSD of variables between two grids
;
; Qing Li, 20170714

load "../share/ncl_procedures_functions.ncl"

begin

; data path
pData = "/Users/qingli/data_local/WW3"
cName = "testIce"
yyyymm = "200901"
vars = (/"hs"/)
grid1 = "gx37"
grid2 = "gx16b"
; input data
inFile1 = pData+"/"+cName+"/"+grid1+"/ww3_"+yyyymm+".nc"
inFile2 = pData+"/"+cName+"/"+grid2+"/ww3_"+yyyymm+".nc"
; grid path
dirGrid = "../grids"
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
f2 = addfile(inFile2, "r")

; loop over variables
nVar = dimsizes(vars)
do i=0,nVar-1
	var = vars(i)
	dat1 = f1->$var$
	dat2 = f2->$var$
	dat1Regrid = ESMF_regrid_with_weights(dat1, wgtFileName, opt)
	printVarSummary(dat1Regrid)
	printMinMax(dat1, 1)
	printMinMax(dat1Regrid, 1)
	printVarSummary(dat2)
	printMinMax(dat2, 1)
	datDiff = dat2
	datDiff = (/dat1Regrid-dat2/)
	printMinMax(datDiff, 1)
	; calculate the root mean square difference
	rmsd = wgt_arearmse(dat1Regrid, dat2, 1.0, 1.0, 0)
	print(rmsd)
	; calculate the root mean square value on grid2
	zeros = dat2
	zeros = (/dat2*0.0/)
	rms  = wgt_arearmse(zeros, dat2, 1.0, 1.0, 0)
	print(rms)
end do
;----------------------------------------------------------------------
;	write_table(outfile, wtype, [/casen,rmse,rmse_s,rmse_e/], "%15s %6.2f %6.2f %6.2f")

; Check the differences
l_plot = True
nt = 119
if (l_plot) then
; plot a snapshot
	type    = "ps"  ; plot type                                                                             
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 4.5
;	type    = "x11"

	filo = "diff"
; open workstation
	wks		= gsn_open_wks(type, filo) 
	gsn_define_colormap(wks, "WhBlGrYeRe") ;BlGrYeOrReVi200")

	res					= True
	res@gsnDraw				= False
	res@gsnFrame				= False
	res@gsnAddCyclic			= True
	res@gsnLeftString			= "Difference"
	res@gsnRightString			= dat2@units
	res@gsnMaximize				= True
	res@gsnPaperOrientation			= "portrait" 
	res@gsnPaperMargin			= 0.2
; change the size of the image box
	res@vpWidthF      = 0.6
	res@vpHeightF     = 0.4
; map
	res@mpCenterLonF			= 200
	res@mpShapeMode				= "FreeAspect"

; line labels
	res@cnLinesOn				= False
	res@cnInfoLabelOn			= False
	res@cnLineLabelsOn			= False
	res@trYReverse				= True			; reverse the Y-axis

	res@cnFillOn				= True
	res@gsnSpreadColors			= True
	res@cnLevelSelectionMode                = "AutomaticLevels"
	;res@cnMinLevelValF                      = 0
	;res@cnMaxLevelValF                      = 120
	;res@cnLevelSpacingF                     = 10
	res@lbLabelBarOn 	      		= True
        res@lbOrientation                       = "vertical"    ; vertical label bar
        res@lbLeftMarginF                       = 0.0
        res@lbLabelAutoStride                   = True

; plot
	plot = gsn_csm_contour_map(wks, datDiff(nt,:,:), res)
	draw(plot)
	frame(wks)
end if
end 
