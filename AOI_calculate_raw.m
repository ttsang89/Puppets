% % % This will now find AOIs and durations to AOIs based on conditions
% % % Outline of code
% % % Step 1: create the looking index, which contains the unique
% permuations of speaker/looking combintations
% % % % % % % % % 
% % % Step 2: find where each of these combinations occur in the data. put
% it in a structure
% e.g., for i = 1:length(looking_combo_index)
% % % % % % % thisPart_looking_data{i}=find(thisPartData(:,8:10)==looking_combo_index(i))
% % % % storing in a structure so can get it again later
% % % Step 3: From that, create a difference measure for min/max (i.e.,
% start/stop) of each instance of the combination. This will be our time
% stamp, which will later be used to calculate duration of the instance
% % % Step 4:with end and stop frames, calculate duration fixation and
% stuff for each aoi
% % % % Step 5: concatenate per subject and sort in chronoogical order
% % % % % % % B = sortrows(A,column)


% % load the AOI map
clear all
violet_AOI=imread('violet_aoi_sr.bmp');
load('Looking_indices');
% % % AOI color key
% % % actress head=115   1
% % % Puppet head = 255  2
% % % ball = 102         3
% % % puppet body = 77   4
% % % actress body= 58   5

% participant_dir_content = dir('/Users/tawnytsang/Box Sync/Tawny_work/Puppet_Project/matlab/data/*.mat');
% part_files={participant_dir_content.name}

participant_dir_content = dir('/Users/tawnytsang/Box Sync/PUPPET COLLABORATIVE PROJECT/Data/RAW EYE TRACKING FILES 190327/*.csv');
part_files={participant_dir_content.name}
% for p = 1:length(part_files)
    for p = 79;
    data=readtable(part_files{p});
%
    thisPartID=erase(part_files{p},'.csv')

    thisPartData=table2array(data);
    clear data
    offScreen=find(thisPartData(:,1)<=0 | thisPartData(:,1)>=1680 | thisPartData(:,2)<=0 | thisPartData(:,2)>=1050);
    thisPartData(offScreen,1)=NaN; thisPartData(offScreen,2)=NaN;
    if length(thisPartData)<3000
        this_part_data_raw_coded{p,1}=thisPartID;
        p=p+1
    else

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

for d = 1:length(thisPartData);
    thisPartData(d,8)=Looking_indices(ceil(d/length(thisPartData)*2586),1);
    thisPartData(d,9)=Looking_indices(ceil(d/length(thisPartData)*2586),2);
    thisPartData(d,10)=Looking_indices(ceil(d/length(thisPartData)*2586),3);
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
% % % extract relevant columns
% % X (col 1), Y (col 2), Fixation Index (col 5), speaker/headturn (col
% 8:10)
thisPartData_red = thisPartData(:,[1:2 5 8:10]);
% % % % NEW COLUMN Numbers for thisPartData_red
% % % % Column 1: X
% % % % Column 2: Y
% % % % Column 3: Fixation Index (0/1)
% % % % Column 4: Speaker index (0: no one; 1: Person; 2: Puppet)
% % % % Column 5: Puppet Head Direction (0: Transition; 1: Partner; 2: Camera; 3: Ball)
% % % % Column 6: Actress Head Direction (0: Transition; 1: Partner; 2: Camera; 3: Ball)

total_duration=length(find(thisPartData_red(:,3)==1));
% recode pre-ball "ball" AOI as puppet body
thisAOI(find(thisAOI(1:Ball_cell)==3))=4;
% recode non-fixations as 0
thisAOI(find(thisPartData_red(:,3)~=1))=0;
% % % AOI color key
% % % actress head=115   1
% % % Puppet head = 255  2
% % % ball = 102         3
% % % puppet body = 77   4
% % % actress body= 58   5

% Step 1: create looking combination index
looking_combinations = unique(thisPartData_red(:,4:6),'rows');

% Step 2: Index! using looking_combinations and store each unique
% combination as a structure. Let's create a new variable to house these
% values
for i = 1:length(looking_combinations)
    looking_combo_frames{1,i}= find(ismember([thisPartData_red(:,4:6)], [looking_combinations(i,:)], 'rows')==1);
    looking_combo_frames{2,i}= [looking_combinations(i,:)];
end
clear i


% Step 3: find out durations of each looking combination

for i = 1:length(looking_combo_frames)
    difference_score=[];
    if length(looking_combo_frames{1,i})>1
        for y = 2:length(looking_combo_frames{1,i});
            difference_score = [difference_score looking_combo_frames{1,i}(y)-looking_combo_frames{1,i}(y-1)];
    %         if ~isempty(difference_score)
                this_start_frame=[looking_combo_frames{1,i}(1); looking_combo_frames{1,i}(find(difference_score~=1)+1)];
                this_stop_frame=[looking_combo_frames{1,i}(find(difference_score~=1)); looking_combo_frames{1,i}(end)];
                this_combo_frame_dur=this_stop_frame-this_start_frame+1;
        end
        else 
            this_start_frame=[];
        this_stop_frame=[];
        this_combo_frame_dur=[];

    end

    looking_combo_frames{3,i}=[this_start_frame this_stop_frame this_combo_frame_dur];
    % Step 4: now lets getting the durations to AOIs 
    if size(looking_combo_frames{3,i},1)==0
            this_combo_valid_fix= 0;
            this_combo_puppet_head=0;
            this_combo_person_head=0;
            this_combo_ball=0;
            this_combo_puppet_body=0;
            this_combo_person_body=0;
            this_combo_BG=0; 
            
    else for w = 1:size(looking_combo_frames{3,i},1)
        
           this_combo_valid_fix(w,1)=length(find(thisPartData_red(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2),3)==1));
            this_combo_puppet_head(w,1)=length(find(thisAOI(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2))==2));
            this_combo_person_head(w,1)=length(find(thisAOI(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2))==1));
            this_combo_ball(w,1)=length(find(thisAOI(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2))==3));
            this_combo_puppet_body(w,1)=length(find(thisAOI(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2))==4));
            this_combo_person_body(w,1)=length(find(thisAOI(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2))==5));
            this_combo_BG(w,1)=length(find(thisAOI(looking_combo_frames{3,i}(w,1):looking_combo_frames{3,i}(w,2))==9));
        end
    end
   looking_combo_frames{4,i}=[this_start_frame this_stop_frame this_combo_frame_dur this_combo_valid_fix this_combo_puppet_head this_combo_person_head this_combo_ball this_combo_puppet_body this_combo_person_body this_combo_BG];
   clear this_start_frame this_stop_frame this_combo_frame_dur this_combo_valid_fix this_combo_puppet_head this_combo_person_head this_combo_ball this_combo_puppet_body this_combo_person_body this_combo_BG       
   clear w 
   
   
%    take relevant columns and convert to MS
this_part_data_raw_coded{p,1}=thisPartID;
this_part_data_raw_coded{p,2}{i}=looking_combo_frames{2,i};
this_part_data_raw_coded{p,3}{i}=looking_combo_frames{4,i};

end
    end
    clear thisAOI
end


% 
% 
% 
% 
% 
% % Find frames where actress or puppet are talking. We are then going to
% % find the min/max points to get the chunks of data. Also keep track of
% % start/stop frames. 
% 
% actress_talk_frames = find(thisPartData(:,8)==1);
% puppet_talk_frames = find(thisPartData(:,8)==2);
% 
% 
% file_name = fopen('puppet_data_body_gaze_shifts_02-23-18_ball.csv','a+');
% % Create headers for your file
% % format of file:
% % Column 1: Subject ID
% % Column 2: Total Fixation Duration
% % Column 3: Fixation Puppet Talking Condition
% % Column 4: Fixation Actress Talking Condition
% % Column 5: Length Puppet Talking Condition
% % Column 6: Length Actress Talking Condition
% % Column 7: Puppet while puppet talking (looking to speaker)
% % Column 8: Puppet while Actress talking (looking to listener)
% % Column 9: Actress while puppet talking (looking to listener)
% % Column 10: Actress while Actress talking (looking to speaker)
% % Column 11: Fixation Direct Gaze Condition
% % Column 12: Fixation Mutual Gaze Condition
% % Column 13: total direct gaze
% % Column 14: total mutual gaze
% % Column 15: Puppet direct gaze
% % Column 16: Actress direct gaze
% % Column 17: Puppet mutual gaze
% % Column 18: Actress mutual gaze
% 
% %
% % RUN THE FOLLOWING 2 LINEs ONLY ONCE TO CREATE HEADER NAMES!
% % fprintf(file_name,'%12s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',...
% %      'SubjectID','total fix','fix dur puppet talk', 'fix dur actress talk', 'length puppet talk', ...
% % 'length actress talk', 'puppet puppet talk', 'puppet actress talk', 'actress puppet talk','actress actress talk',...
% % 'fix direct gaze','fix mutual gaze','total direct gaze','total mutual gaze','puppet direct gaze', 'actress direct gaze',...
% % 'puppet mutual gaze', 'actress mutual gaze');
% % Print data to your file: 
% fprintf(file_name,'%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\n', ...
%      thisPartID, thisPart_Looking_data);
%  fclose(file_name);
%  clear thisPartID total_duration ball_while_puppet_speaking ball_while_actress_speaking puppet_body_while_puppet_speaking actress_body_while_puppet_speaking puppet_body_while_actress_speaking actress_body_while_actress_speaking    ball_direct_gaze puppet_body_direct_gaze person_body_direct_gaze ball_mutual_gaze puppet_body_mutual_gaze person_body_mutual_gaze
% 
% 
% 
% 
