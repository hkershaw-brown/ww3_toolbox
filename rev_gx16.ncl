; This script modify the grid gx16 to exclude regional seas
; and Nares Strait
;
; Li Qing, 20170707

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	diri	= "./grids/"
	fili	= "gx16b.grids.nc" 

	f	= addfile(diri+fili,"w")

; read and regrid region mask
	rmask		= f->REGION_MASK
	ht 		= f->HT
	rmask_new	= rmask
	rmask_new	= where(rmask .lt. 0,   0, rmask_new)
	rmask_new	= where(rmask .eq. 4,   0, rmask_new)
	rmask_new	= where(rmask .eq. 7,   0, rmask_new)
	rmask_new(376:377,193:237) = 0
	ht 		= where(rmask_new .eq. 0, 0.0, ht)

	f->REGION_MASK	= (/rmask_new/)
	f->HT 		= (/ht/)

end 
