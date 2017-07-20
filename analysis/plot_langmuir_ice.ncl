; This script plot the Langmuir number under sea ice
;
; Qing Li, 20170720

load "../share/ncl_procedures_functions.ncl"

begin

; data path
pData = "/Users/qingli/data_local/WW3"
cName = "testIce"
yyyymm = "200907"
vars = (/"ust", "uss"/)
grid = "gx16b"
; input data
inFile = pData+"/"+cName+"/"+grid+"/ww3_"+yyyymm+".nc"
inFileIce = "../data/b1850_f19_gx1_ctrl_cice_0099.nc"

; if plot snapshot
l_plot = True

; open file
f = addfile(inFile, "r")
lat = f->latitude
lon = f->longitude
time = f->time
nt = dimsizes(time)
;print(nt)


; averaging window
inds = nt/2
inde = nt-1
; radians to degree
r2d = 45.0/atan(1.0)
rhoo = 1000.0
rhoa = 1.225

; vector field
results = read_ww3_vector(inFile, vars(0))
ust = results[0]
printVarSummary(ust)
printMinMax(ust,1)

results = read_ww3_vector(inFile, vars(1))
uss = results[0]
printVarSummary(uss)
printMinMax(uss,1)
uss0 = where(uss .eq. 0.0, uss@_FillValue, uss)
;la_turb = where(uss .gt. 0.0, sqrt(ust/uss0), uss@_FillValue)
la_turb = sqrt(ust/uss0*sqrt(rhoa/rhoo))
la_turb@lat2d = lat
la_turb@lon2d = lon
la_turb@units = "1"
la_turb@long_name = "Turbulent Langmuir number"

fi = addfile(inFileIce, "r")
datX = fi->strocnx
datY = fi->strocny
tauIce = sqrt(datX^2+datY^2)
printVarSummary(tauIce)
printMinMax(tauIce,1)
ustIce = sqrt(tauIce/rhoo)
printVarSummary(ustIce)
printMinMax(ustIce,1)

la_ice = sqrt(ustIce(6,:,:)/uss0(nt-1,:,:))
la_ice@lat2d = lat
la_ice@lon2d = lon
printMinMax(la_ice,1)

; Check the differences
type    = "ps"  ; plot type
type@wkPaperWidthF  = 6
type@wkPaperHeightF = 4.5
type    = "x11"
figOut = cName+"_uss_"+yyyymm
figOut2 = cName+"_la_"+yyyymm

res = True
res@gsnLeftString	= figOut
;test_plot_map(type, figOut, uss(nt-1,:,:), res)
;test_plot_map_polar(type, figOut, uss(nt-1,:,:), res)
res@gsnLeftString	= figOut2
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF	= 0.1
res@cnMaxLevelValF	= 1.0
res@cnLevelSpacingF	= 0.1
;test_plot_map(type, figOut2, la_turb(nt-1,:,:), res)
test_plot_map_polar(type, figOut2, la_ice, res)
end 
