% This script calculates and plots the distribution of ice
%
% Qing Li, 20170731

clear variables; close all;

% add path of share directory
% [s, r] = system('echo ${WW3_TOOLBOX_ROOT}');
% path([r(1:end-1) '/share'], path);
pShare = '../share';
path(pShare, path);

% set case name and directory
pData = '/Users/qingli/data_local';
cases = {'giaf_gx1_ctrl', 'giaf_gx1_twav', 'giaf_gx1_twav-miz'};
nc = numel(cases);
yyyymm = '0062';

% flag to save figures
l_save = 1;

% set ice fraction
dl = 0.05;  % ice fraction interval
icutoff = 0.01; % ice fraction below this value is considered ice-free
iceLev = 0:dl:1;
iceMin = iceLev(1:end-1);
iceMax = iceLev(2:end);
ni = numel(iceLev)-1;
iceMin(1) = icutoff;
iceLabel = 0.5*(iceMin+iceMax);

% loop over cases
for i=1:nc
    cName = cases{i};
    disp(cName);
    inFile = [pData '/' cName '/' cName '_cice_' yyyymm '.nc'];
    % read data
    ice = ncread(inFile, 'aice_d');
    hi = ncread(inFile, 'hi_d');
    
    if i==1
        % read variables that are independent of cases
        tarea = ncread(inFile, 'tarea');
        lat = ncread(inFile, 'TLAT');
        time = ncread(inFile, 'time');
        nt = numel(time);
        % new variables
        ice_area = zeros(size(tarea));
        ice_volume = zeros(size(tarea));
        aice = zeros([nc, 2, nt, ni]);  % ice area
        vice = zeros([nc, 2, nt, ni]);  % ice volume
        npice = zeros([nc, 2, nt, ni]); % ice covered grid points
        taice = zeros([nc, 2, nt, ni]); % ice covered grid area
    end
    % loop over time
    for j = 1:nt
        ice_area = ice(:,:,j).*tarea;
        ice_volume = ice(:,:,j).*tarea.*hi(:,:,j);
        % loop over ice fraction
        for k = 1:ni
            indsN = find(ice(:,:,j) >= iceMin(k) ...
                & ice(:,:,j) <= iceMax(k) & lat > 0);
            aice(i,1,j,k) = sum(ice_area(indsN));
            vice(i,1,j,k) = sum(ice_volume(indsN));
            npice(i,1,j,k) = numel(indsN);
            taice(i,1,j,k) = sum(tarea(indsN));
            indsS = find(ice(:,:,j) >= iceMin(k) ...
                & ice(:,:,j) <= iceMax(k) & lat < 0);
            aice(i,2,j,k) = sum(ice_area(indsS));
            vice(i,2,j,k) = sum(ice_volume(indsS));
            npice(i,2,j,k) = numel(indsS);
            taice(i,2,j,k) = sum(tarea(indsS));
            clear indsS indsN;
        end
    end
end

% day of a year
doy = time-time(1)+1;

m2tokm2 = 1e-6;
m3tokm3 = 1e-9;
% total ice area
tot_aice = squeeze(sum(aice,4)).*m2tokm2; % m^2 -> km^2
xlb = 'Day of year';
ylb = 'Total ice area (km^2)';
plot_ice(doy, tot_aice, xlb, ylb);
save_fig('iArea_doy.fig', l_save);

% total ice volume
tot_vice = squeeze(sum(vice,4)).*m3tokm3; % m^3 -> km^3
ylb = 'Total ice volume (km^3)';
plot_ice(doy, tot_vice, xlb, ylb);
save_fig('iVol_doy.fig', l_save);

% ice area with <15% ice fraction
dat = squeeze(sum(aice(:,:,:,1:3),4)).*m2tokm2; % m^2 -> km^2
ylb = 'Ice area (km^2)';
plot_ice(doy, dat, xlb, ylb);
save_fig('iArea15_doy.fig', l_save);

% ice volume with <15% ice fraction
dat = squeeze(sum(vice(:,:,:,1:3),4)).*m3tokm3; % m^3 -> km^3
ylb = 'Ice Volume (km^2)';
plot_ice(doy, dat, xlb, ylb);
save_fig('iVol15_doy.fig', l_save);

% ice area distribution with ice fraction
dist_aice = squeeze(sum(aice,3)).*m2tokm2;
xlb = 'Ice fraction';
ylb = 'Ice area (km^2)';
plot_ice(iceLabel, dist_aice, xlb, ylb);
set(gca,'yscale','log');
save_fig('iArea_iFrac.fig', l_save);

% ice volume distribution with ice fraction
dist_vice = squeeze(sum(vice,3)).*m3tokm3;
xlb = 'Ice fraction';
ylb = 'Ice volume (km^3)';
plot_ice(iceLabel, dist_vice, xlb, ylb);
set(gca,'yscale','log');
save_fig('iVol_iFrac.fig', l_save);

% ice covered grid area distribution with ice fraction
dist_taice = squeeze(sum(taice,3)).*m2tokm2;
xlb = 'Ice fraction';
ylb = 'Area (km^2)';
plot_ice(iceLabel, dist_taice, xlb, ylb);
set(gca,'yscale','log');
save_fig('gArea_iFrac.fig', l_save);

function plot_ice(xx, yy, xlb, ylb)
    figure;
    plot(xx, squeeze(yy(1,1,:)), '-k', 'LineWidth', 1.5);
    hold on;
    plot(xx, squeeze(yy(2,1,:)), '-r', 'LineWidth', 1.5);
    plot(xx, squeeze(yy(3,1,:)), '-b', 'LineWidth', 1.5);
    plot(xx, squeeze(yy(1,2,:)), '--k', 'LineWidth', 1.5);
    plot(xx, squeeze(yy(2,2,:)), '--r', 'LineWidth', 1.5);
    plot(xx, squeeze(yy(3,2,:)), '--b', 'LineWidth', 1.5);
    xlabel(xlb);
    ylabel(ylb);
    xlim([xx(1),xx(end)]);
end

function save_fig(figname, l_save)
    if l_save
        saveas(gcf, figname, 'fig');
        postProcessFig(figname);
    else
        disp('Not saving figure...');
    end
end