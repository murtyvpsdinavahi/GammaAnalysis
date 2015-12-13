% Function taken from Vinay's refTFAnalysisCombinedv4
% Same function name retained
% MD: 14-11-2015

function gabP = drawStimulus(plotHandles,gaborBackground,gaborRing,titleString,protocolNumber)


if ~exist('gaborRing','var')
    gaborRing.azimuthDeg = 0;
    gaborRing.elevationDeg = 0;
    gaborRing.sigmaDeg = 0;
    gaborRing.spatialFreqCPD = 0;
    gaborRing.orientationDeg = 0;
    gaborRing.contrastPC = 0;
    gaborRing.temporalFreqHz = 0;
    gaborRing.spatialPhaseDeg = 0;
    gaborRing.radiusDeg = 0;
end

if ~exist('protocolNumber','var')
    protocolNumber = 11;
end

% gridLims = [-3 -0.5 -2.5 0];
% gridLims = [-6 -1.5 -4 0.5];
% gridLims = [-21.5 -1.5 -19.5 0.5];
% gridLims = [-7 3 -8 2];
% gridLims = [-12 0 -8 0]; % used for EEG plots

% this was used for all elec91 plots -
% gridLims = [-4 0 -5 -1];
% gridLims = [-9 3 -9 2];
% gridLims = [-2 0 -2 0]; % By Vinay
gridLims = [-4.4 0 -2.5 0]; % By MD: To match the dimensions of the BenQ monitor: Width:Height = 1.77
gridLimsNormalized(1) = -(gridLims(2)-gridLims(1))/2;
gridLimsNormalized(2) = (gridLims(2)-gridLims(1))/2;
gridLimsNormalized(3) = -(gridLims(4)-gridLims(3))/2;
gridLimsNormalized(4) = (gridLims(4)-gridLims(3))/2;

aPoints=gridLimsNormalized(1):1/30:gridLimsNormalized(2);
ePoints=gridLimsNormalized(3):1/30:gridLimsNormalized(4);

aVals = aPoints;
eVals = ePoints;

factor = 12;
diffaVals = aVals(2)-aVals(1);
diffeVals = eVals(2)-eVals(1);
aVals2 = aVals(1):diffaVals/factor:aVals(end);
eVals2 = eVals(1):diffeVals/factor:eVals(end);

if protocolNumber == 3 || protocolNumber == 4 || protocolNumber == 5 % dual protocols
    innerphase = gaborBackground.spatialPhaseDeg; % for DPP
else
    innerphase = gaborRing.spatialPhaseDeg; % for PRP
end

gaborPatch = makeGRGStimulusWithPhase(gaborRing,gaborBackground,aVals2,eVals2,innerphase);% for elec91
% gaborPatch = makeGRGStimulusWithPhase(gaborRing,gaborBackground,aVals,eVals,innerphase);

% Changed to show absolute contrasts and not normalized values - 26 Jan'13 
gabP = gaborPatch./100;
% shiftclim = 0; % to pull down the values lower than the lower clim value for the TF spectrum plots
% gabP = gabP - shiftclim; % to pull down the values lower than the lower clim value for the TF spectrum plots
% cmGray = colormap('gray');
% % hGab = imshow(gabP,'Parent',plotHandles,'colormap',cmGray); %colorbar; % MD: Added colormap option
% hGab = sc(gabP,cmGray);
% hGab = sc(gabP,[-shiftclim -(shiftclim-1)],cmGray);
% fontSizeMedium = 9; commented out by MD: 14-11-2015
% title(plotHandles,titleString,'Fontsize',fontSizeMedium,'FontWeight','bold'); commented out by MD: 14-11-2015
% set(plotHandles,'CLim',[-shiftclim -(shiftclim-1)]); % to pull down the values lower than the lower clim value for the TF spectrum plots - adjust the clim accordingly
% colormap(h,'gray');

plotRF = 0; % No RF in case of EEG; MD: 14/11/2015
if plotRF
    paramsStimulus(1) = (size(gabP,1)/2)+0.5;
    paramsStimulus(2) = (size(gabP,2)/2)+0.5;
%     paramsStimulus(3) = 24;% 0.6 deg => 72 pixels, so sigma = 0.2 deg here
%     paramsStimulus(4) = 24;
    paramsStimulus(3) = 6*factor;% 0.6 deg => 72 pixels, so sigma = 0.2 deg here
    paramsStimulus(4) = 6*factor;
    paramsStimulus(5)=0;
    paramsStimulus(6)=1;

    [~,~,boundaryXStimulus,boundaryYStimulus] = gauss2D(paramsStimulus);
    hold(plotHandles,'on');
    plot(plotHandles,boundaryXStimulus,boundaryYStimulus,'color','r','linewidth',1.5);
end

end