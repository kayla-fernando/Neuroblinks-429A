function savetrial()
% Load objects from root app data
vidobj=getappdata(0,'vidobj');

pause(1e-3)
% data=getdata(vidobj,vidobj.TriggerRepeat+1);
data=getdata(vidobj,vidobj.FramesPerTrigger*(vidobj.TriggerRepeat + 1));
% videoname=sprintf('%s\\%s_%s_%03d',metadata.folder,metadata.mouse,datestr(now,'yy-mm-dd'),metadata.trialnum);
pause(1e-3)

online_bhvana(data);
metadata=getappdata(0,'metadata');

pause(1e-3)
setappdata(0,'lastdata',data);
setappdata(0,'lastmetadata',metadata);

% --- saved in HDD ---
trials=getappdata(0,'trials');
t0=clock;

videoname=sprintf('%s\\%s_%03d',metadata.folder,metadata.TDTblockname,metadata.cam.trialnum);
if trials.savematadata
    save(videoname,'metadata')
    pause(0.3-metadata.stim.totaltime/1000) % wait for serial buffer of TDT
else
%     save(videoname,'data','metadata')
    save(videoname,'data','metadata','-v6')
    pause(0.3-metadata.stim.totaltime/1000) % wait for serial buffer of TDT
end

fprintf('Data from trial %03d successfully written to disk.\n',metadata.cam.trialnum)


% --- trial counter updated and saved in memory ---
metadata.cam.trialnum=metadata.cam.trialnum+1;
if strcmpi(metadata.stim.type,'conditioning') | strcmpi(metadata.stim.type,'electrocondition')
    metadata.eye.trialnum1=metadata.eye.trialnum1+1;
end
metadata.eye.trialnum2=metadata.eye.trialnum2+1;
setappdata(0,'metadata',metadata);
% 
% % --- online spike saving, executed by timer ---
% etime1=round(1000*etime(clock,t0))/1000;
% tm1 = timer('TimerFcn',@online_savespk_to_memory, 'startdelay', max(0, 4-etime1));
% start(tm1);
% 





