function InitCam(ch,recdur)
% First delete any existing image acquisition objects
imaqreset

%imaqmex('feature', '-gigeDisablePacketResend', true); % added 220228 from Mathworks community answer board; delete if there are other errors

disp('Creating video object ...')
%vidobj = videoinput('gige', 1, 'Mono8');
vidobj = videoinput('gentl', ch, 'Mono8');

metadata=getappdata(0,'metadata');
src = getselectedsource(vidobj);
src.ExposureTime = metadata.cam.init_ExposureTime; %220628: adjusting parameters to mimic black rig (KF)
% src.AllGainRaw=12;				% Tweak this based on IR light illumination (lower values preferred due to less noise)
% src.StreamBytesPerSecond=124e6;   % Set based on AVT's suggestion
% src.StreamBytesPerSecond=80e6;    % Set based on AVT's suggestion

%src.PacketSize = 9014;		% Use Jumbo packets (ethernet card must support them) -- apparently not supported in VIMBA
%src.PacketSize = 8228;		% Use Jumbo packets (ethernet card must support them) -- apparently not supported in VIMBA
%src.PacketDelay = 49;		% Calculated based on frame rate and image size using Mathworks helper function
vidobj.LoggingMode = 'memory'; 
%src.acquisitionFrameRateControlMode='Programmable';
%src.AcquisitionFrameRate=200;
vidobj.FramesPerTrigger=ceil(recdur/(1000/200));
%vidobj.FramesPerTrigger=334; %2500 exposure

% triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
%set(src,'TriggerMode','on')
%set(src,'FrameStartTriggerSource','Freerun')
%set(src,'AcquisitionStartTriggerActivation','RisingEdge')
%set(src,'TriggerSource','Line1')

triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
%src.TriggerMode = 'On';
%src.TriggerActivation = 'RisingEdge';

%src.AcquisitionFrameRateMode = 'Off';
%vidobj.ROIPosition = [0 0 275 225];

% This needs to be toggled to switch between preview and acquisition mode
% It is changed to 'Line1' in MainWindow just before triggering Arduino and then
% back to 'Freerun' in 'endOfTrial' function
% src.FrameStartTriggerSource = 'Line1';
% src.FrameStartTriggerSource = 'Freerun';

% src.TriggerMode='On';
%src.TriggerSelector='FrameStart';
src.TriggerSelector='AcquisitionStart';
%src.AcquisitionStatusSelector = 'AcquisitionActive';
% src.TriggerSource='Freerun';

% [img, ts, metadata] = getdata(vidobj, vidobj.FramesAvailable); % added 220301 from Mathwors community answer board; delete if there are other errors
% blockIDs = [metadata.BlockID];
% figure;
% plot(blockIDs, '.')
% figure;
% plot(diff(blockIDs), '-x')

%% Save objects to root app data
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)
