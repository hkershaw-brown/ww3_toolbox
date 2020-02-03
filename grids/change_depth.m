% set sea depth in centimeters
function change_depth(ncfile) 
 ncid = netcdf.open(ncfile, 'WRITE');
 varid = netcdf.inqVarID(ncid,'HT'); 
 data = netcdf.getVar(ncid,varid);
 data(data>0)=100000;  % 1km in centimeters
 netcdf.putVar(ncid,varid,data); 
 netcdf.close(ncid);
end