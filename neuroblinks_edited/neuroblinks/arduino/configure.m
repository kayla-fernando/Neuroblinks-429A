%%%% Configure some settings %%%%

% If Neuroblinks is launched from the root directory of the mouse, make a new directory for the session, otherwise leave that up to the user
cwd=regexp(pwd,'\\','split');
if regexp(cwd{end},'[A-Z]\d\d\d')  % Will match anything of the form LDDD, where L is single uppercase letter and DDD is a seq of 3 digits
    mkdir(datestr(now,'yymmdd'))
    cd(datestr(now,'yymmdd'))
end

% ------ Letter for mouse -----
path1=pwd;
ind1=find(path1=='\');
metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);

% ------ Initial value of the conditioning table ----

% Search for per-mouse config file and load it if it exists, otherwise default to the paramtable below

mousedir=regexp(pwd,['[A-Za-z]:\\.*\\', metadata.mouse],'once','match');
condfile=fullfile(mousedir,'condparams.csv');

%if exist(condfile)
%	paramtable.data=csvread(condfile);
%else
%	paramtable.data=...
%    [50,  250,5,140, 30,3,0,0,0,1,10;...
%     25,  250,6,140, 0, 3,0,0,0,1,0;...
%      25,  250,8,140, 0, 3,0,0,0,1,0;...
%     ];
%end

%if exist(condfile)
%	paramtable.data=csvread(condfile);
%else
%	paramtable.data=...
%    [50,  250,5,140, 30,3,0,0,0,1,10;...
%     50,  250,6,140, 0, 3,0,0,0,1,0;...
%     ];
%end

if exist(condfile)
	paramtable.data=csvread(condfile);
else
	paramtable.data=...
    [0,  250,7,218, 30,3,0,0,0,1,0;...
    90,  250,5,218, 30, 3,0,0,0,1,0;...
    10,  250,5,218, 0, 3,0,0,0,1,0;...
     ];
end
 
paramtable.randomize=1;

trialtable=makeTrialTable(paramtable.data,paramtable.randomize);

setappdata(0,'paramtable',paramtable);
setappdata(0,'trialtable',trialtable);
setappdata(0,'metadata',metadata);
pause(0.3);
