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
lat1 = f1->latitude
lon1 = f1->longitude
f2 = addfile(inFile2, "r")
lat2 = f1->latitude
lon2 = f1->longitude

; loop over variables
nVar = dimsizes(vars)
do i=0,nVar-1
	var = vars(i)
	dat1 = f1->$var$
	dat1@lat2d = lat1
	dat1@lon2d = lon1
	dat2 = f2->$var$
	dat2@lat2d = lat2
	dat2@lon2d = lon2
	dat1Regrid = ESMF_regrid_with_weights(dat1, wgtFileName, opt)
	printVarSummary(dat1Regrid)
	printMinMax(dat1, 1)
	printMinMax(dat1Regrid, 1)
	printVarSummary(dat2)
	printMinMax(dat2, 1)
	datDiff = dat1Regrid
	datDiff = (/dat1Regrid-dat2/)
	minMeanDiff = dim_min_n(datDiff, (/1, 2/))
	maxMeanDiff = dim_max_n(datDiff, (/1, 2/))
	print(maxMeanDiff)
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
if (l_plot) then
; plot a snapshot
	type    = "ps"  ; plot type                                                                             
	type@wkPaperWidthF  = 6
	type@wkPaperHeightF = 4.5
	type    = "x11"
	filo = "diff"

	res = True
	res@gsnLeftString	= filo
	nt = 119
	test_plot_map(type, filo, dat1(nt,:,:), res)
end if

end 
