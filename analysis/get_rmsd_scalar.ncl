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
	rmsd = wgt_arearmse(dat1Regrid, dat2, 1.0, 1.0, 0)
	;print(rmsd)	
end do
;----------------------------------------------------------------------
;	write_table(outfile, wtype, [/casen,rmse,rmse_s,rmse_e/], "%15s %6.2f %6.2f %6.2f")

; plot a snapshot


end
