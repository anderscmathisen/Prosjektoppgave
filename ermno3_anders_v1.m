% ErMnO3
% 2022-11-22
% Haakon Wiik Aanes (hakon.w.anes@ntnu.no)

clear all
home

res = '-r150';
plotx2east
plotzIntoPlane

dir_sample = '/Users/anders/Library/CloudStorage/OneDrive-NTNU/Prosjektoppgave/Data/Processed/One_deg/error_fixed';
dir_mtex = fullfile(dir_sample, 'mtex');

lattice_parameters = [6.1 6.1 11];
angles = [90 90 120] * degree;

cs = crystalSymmetry('6/mmm', lattice_parameters, angles, 'mineral',...
    'ErMnO3', 'X||a*', 'Z||c*'); %inverted definition because of bug in Orix


ebsd = EBSD.load(fullfile(dir_sample,...
    'ErMnO3_1_deg_stepsize_fixed.ang'), cs,...
    'convertEuler2SpatialReferenceFrame')


ebsd.scanUnit = 'nm';

ebsd(ebsd.ci < 0.001).phase = -1;

directions = {xvector, yvector, zvector};

%% Plot normalized cross-correlation (NCC) score
figure
plot(ebsd, ebsd.ci)
mtexColorbar('title', 'NCC')
mtexColorMap black2white
export_fig(fullfile(dir_mtex, 'maps_ncc.png'), res)

%% Plot IPF color key
%ipfkey = ipfHSVKey(ebsd.CS);
ipfkey = ipfTSLKey(ebsd.CS);

%figure
%plot(ipfkey, 'projection', 'eangle')
%export_fig(fullfile(dir_mtex, 'ipfkey.png'), res)

%% Plot IPF color maps and IPF density plots
titles = {'x', 'y', 'z'};
for i=1:3
    ipfkey.inversePoleFigureDirection = directions{i};
    omcolor = ipfkey.orientation2color(ebsd.orientations);

    % IPF maps
    figure
    plot(ebsd, omcolor)
    hold on
    export_fig(fullfile(dir_mtex, ['maps_ipf' titles{i} '.png']), res)
end


%% Reconstruct grains
[grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'angle',...
    10*degree);
grains_ermno3 = grains('ErMnO3');


directions = {xvector, yvector, zvector};
cS = crystalShape.hex(ebsd.CS);



%% Plot orientation map with unit cells from big grains
%grains_ermno3 = grains('indexed');
big_grains = grains_ermno3(grains_ermno3.grainSize > 200);
big_grains_id = big_grains.id;

for i=1:3
    
    ipfkey.inversePoleFigureDirection = directions{i};
    omcolor = ipfkey.orientation2color(ebsd.orientations);
    
    figure
    plot(ebsd, omcolor)
    hold on
    %plot(grains_ermno3.boundary)
    hold on
    plot(big_grains, 0.5*cS, 'linewidth', 2, 'colored')
    legend('off')
    export_fig(fullfile(dir_mtex, ['ipf_with_unitcell_' titles{i} '.png']), res)
    
end


