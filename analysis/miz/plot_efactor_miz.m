% This script calculates and plots the statistics of enhancement factor
% distribution versus ice fraction in a year.
%
% Qing Li, 20170726

clear variables; close all;

% add path of share directory
% [s, r] = system('echo ${WW3_TOOLBOX_ROOT}');
% path([r(1:end-1) '/share'], path);
pShare = '../share';
path(pShare, path);

% set case name and directory
pData = '/Users/qingli/data_local/WW3';
cPrefix = 'testIce';
yyyymm = '2009';
gType = 'gx16b';
cName = [cPrefix '_' yyyymm '_' gType]; 
inFile = [pData '/' cName '/ww3_efactor_' yyyymm '.nc'];
inFile2 = [pData '/' cName '/ww3_' yyyymm '.nc'];

% read data
efactor = ncread(inFile, 'efactor');
ice = ncread(inFile2, 'ice');
lat = ncread(inFile2, 'latitude');
time = ncread(inFile2, 'time');
nt = numel(time);

% expand lat array
latall = zeros(size(efactor));
for i=1:nt
    latall(:,:,i) = lat;
end

efC = 5;	% set a cap on efactor, will affect the mean
efactor(efactor >= efC) = efC;
dl = 0.05;  % ice interval
icutoff = 0.01;
iceLev = 0:dl:1;
iceMin = iceLev(1:end-1);
iceMax = iceLev(2:end);
ni = numel(iceLev);
iceMin(1) = icutoff;

% percentiles
pct = [10, 25, 50, 75, 90];
np = numel(pct);
% initialize array
datpct = zeros([np,ni]);
datmn = zeros([1,ni]);
ndat = zeros([1,ni]);

% loop over ice fraction
for i=1:ni
	if i == 1
		inds = find(ice < icutoff);
	else
		inds = find(ice > iceMin(i-1) & ice <= iceMax(i-1));
	end
	efactorM = efactor(inds);
	for j=1:np
		datpct(j,i) = prctile(efactorM, pct(j));
	end
	ndat(1,i) = numel(inds);
	datmn(1,i) = nanmean(efactorM(:));
end

% plot figure
lstyle = {'-.','--','-','--','-.'};
figure;
hold on;
% x-axis: ice fraction
xx = [0.01, 0.5.*(iceMin+iceMax)];
% number of points in arbitrary scale
ndat2 = ndat;
ndat2(1) = NaN;
nndat2 = ndat2./nansum(ndat2);
plt = plot(xx, nndat2.*2+1, '-b');
plt.LineWidth = 1.5;
% plot efactor: percentiles
for j=1:np
	plt = plot(xx, datpct(j,:), 'k');
	plt.LineWidth = 1.5;
	plt.LineStyle = lstyle{j};
end
% mean
plt = plot(xx, datmn, '-r');
plt.LineWidth = 1.5;
xlabel('Ice fraction');
ylabel('Enhancement factor');
xlim([0,1]);
ylim([1,1.8]);

% fit data
% y = 1+beta*exp((1-sqrt(x))/alpha)
fxx = xx(3:end).^(0.5);
fyy = log(datmn(3:end)-1);
c = fit(fxx', fyy', 'poly1');
alpha = -1/c.p1;
beta = exp(c.p2+c.p1);
yy = beta.*exp((1-fxx)./alpha)+1;
plot(xx(3:end), yy, '-c');

% set(gca,'xscale','log');
% save figure
figname = [cName '_efactor_prct.fig'];
saveas(gcf, figname, 'fig');
postProcessFig(figname);
