% % % This will now find AOIs. GL GL to us all

% % load the AOI map
clear all
violet_AOI=imread('/Users/tawnytsang/Box Sync/Tawny_work/Puppet_Project/violet_aoi_sr.bmp');
load('Looking_indices');
% % % AOI color key
% % % actress head=115   1
% % % Puppet head = 255  2
% % % ball = 102         3
% % % puppet body = 77   4
% % % actress body= 58   5

% participant_dir_content = dir('/Users/tawnytsang/Box Sync/Tawny_work/Puppet_Project/matlab/data/*.mat');
% part_files={participant_dir_content.name}

participant_dir_content = dir('/Users/tawnytsang/Box Sync/PUPPET COLLABORATIVE PROJECT/data/*.csv');
part_files={participant_dir_content.name}
for p = 1:length(part_files)
    data=readtable(part_files{p});
%   
    thisPartID=erase(part_files{p},'.csv')

    thisPartData=table2array(data);
    clear data
offScreen=find(thisPartData(:,1)<=0 | thisPartData(:,1)>=1680 | thisPartData(:,2)<=0 | thisPartData(:,2)>=1050);
    thisPartData(offScreen,1)=NaN; thisPartData(offScreen,2)=NaN;

% for p =1:length(part_files)
% load(part_files{p})
% thisPartID=erase(part_files{p},'.mat')

% % % % FILE STRUCTURE
% % % % data
% Column1= X
% COlumn2=Y
% Column5=Fixation Index
% Column6=Blink Index
% Column 7= Saccade Index
% % % % % Looking_indices=[Speaker_index Puppet_direction Actress_direction];
% Column 1= Speaker index (1=Actress; 2=puppet)
% Column 2= Puppet Direction (1=actress; 2= direct; 3=ball)
% Column 3= Actress Direction (1=puppet; 2=direct; 3=ball)
% % we want to align the looking index with raw data 
% %  on average raw data is about 5190 lines; looking is 2586
% for p = 1:length(part_files)    
%     load(part_files{p})

for p = 1:length(thisPartData);
    thisPartData(p,8)=Looking_indices(ceil(p/length(thisPartData)*2586),1);
    thisPartData(p,9)=Looking_indices(ceil(p/length(thisPartData)*2586),2);
    thisPartData(p,10)=Looking_indices(ceil(p/length(thisPartData)*2586),3);
end
Ball_cell = ceil(790*length(thisPartData)/2586);
    thisAOI= [];
    
    
    for i = 1:length(thisPartData)
        if isnan(thisPartData(i,1))
    thisAOI=[thisAOI NaN];
        else
        POG=violet_AOI(ceil(thisPartData(i,2)),ceil(thisPartData(i,1)));
        if POG==115
            AOI=1;
        elseif POG==255
            AOI=2;
        elseif POG==102
            AOI=3;
        elseif POG==77
            AOI=4;
        elseif POG==58
            AOI=5;
        else AOI=9;
        end
        thisAOI=[thisAOI AOI];
        end
    end
    
% % %     find fixations
thisAOI=thisAOI';
thisPartData(:,11)=thisAOI;
thisPartData(1:Ball_cell,12)=0;
thisPartData(Ball_cell+1:end,12)=1;

filename = strcat(thisPartID,'.mat');
save(filename,'thisPartData')
end



