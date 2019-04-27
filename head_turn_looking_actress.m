% % 12/6/18:
% this script will identify head turn transitions and calculate
% 1)latency to look at referred target (anything else?)
% 2) probability of looking to it
clear
% % % FILE STRUCTURE
% % % % data
% Column1= X
% COlumn2=Y
% Column5=Fixation Index
% Column6=Blink Index
% Column 7= Saccade Index
% % % % % Looking_indices=[Speaker_index Puppet_direction Actress_direction];
% Column 8= Speaker index (0=no one; 1=Actress; 2=puppet)
% Column 9= Puppet Direction (0=head turn; 1=actress; 2= direct; 3=ball)
% Column 10= Actress Direction (0=head turn; 1=puppet; 2=direct; 3=ball)
% Column 11= AOI;
% % % % % % % 1 = Actress Head
% % % % % % % 2 = Puppet Head
% % % % % % % 3 = Ball
% % % % % % % 4 = Puppet Body
% % % % % % % 5 = Actress Body

participant_dir_content = dir('/Users/tawnytsang/Box Sync/Tawny_work/Puppet_Project/matlab/AOI_data/*.mat');
part_files={participant_dir_content.name};

for p=1:length(part_files)
    load(part_files{p})
    thisPartID=erase(part_files{p},'.mat')
    
%     Create a matrix of this child's AOIs. Given that body language may
%     also be important (e..g, puppet pointing, actress gesturing) I'm
%     going to just compile body and head as one. 
    AOIS_head_turn=zeros(length(thisPartData),1)';
    actress_any=find(thisPartData(:,11)==1|thisPartData(:,11)==5);
    puppet_any=find(thisPartData(:,11)==2|thisPartData(:,11)==4);
    % for simplicity, recode actress as 1; puppet as 2; ball as 3
    AOIS_head_turn(actress_any)=1;
    AOIS_head_turn(puppet_any)=2;
    AOIS_head_turn(find(thisPartData(:,11)==3))=3;

    % % We want to find how long it takes to look at whatever is AFTER the head turn
    % % % % actress
    head_turn_actress=find(thisPartData(:,10)==0);
% % Find how long the head turns take (this will give us a better marker as
% to whether they start looking at referent as the cue occurs)
    for i=2:length(head_turn_actress)
        head_turn_actress(i-1,2) = head_turn_actress(i)-head_turn_actress(i-1);
    end

    end_transition_index=head_turn_actress(find(head_turn_actress(:,2)~=1),1);
    start_transition_index=ones(length(end_transition_index),1);
    start_transition_index(2:end)=head_turn_actress(find(head_turn_actress(:,2)>1)+1,1);
    transition_indexes=[start_transition_index(2:end-1) end_transition_index(2:end-1)]; 
    transition_indexes(:,3)=transition_indexes(:,2)-transition_indexes(:,1); %length of transition
    transition_indexes(:,4)=thisPartData(transition_indexes(:,1)-1,10); %prior actress head direction
    transition_indexes(:,5)=thisPartData(transition_indexes(:,2)+1,10); %next actress head direction

    % % Direct to puppet (transition_indexes column4 = 2; column 5=1;
    direct_to_puppet=find(transition_indexes(:,4)==2 & transition_indexes(:,5)==1);
    %average head turn transition length=15 frames so 1/4 a second

    for trial = 1:length(direct_to_puppet);
        thisPart_AOIs=zeros(length(AOIS_head_turn(transition_indexes(direct_to_puppet(trial),1)-15:transition_indexes(direct_to_puppet(trial),1)+74)),1);
        thisPart_AOIs(find(AOIS_head_turn(transition_indexes(direct_to_puppet(trial),1)-15:transition_indexes(direct_to_puppet(trial),1)+74)==2))=1;
        thisPart_mov_ave(trial,:)=movmean(thisPart_AOIs,[5 5]);
    %     if ~null(min(find(AOIS_head_turn(transition_indexes(direct_to_actress(trial),1):transition_indexes(direct_to_actress(trial),2)+59)==1)))
        latency{trial}= min(find(AOIS_head_turn(transition_indexes(direct_to_puppet(trial),1):transition_indexes(direct_to_puppet(trial),2)+59)==2));
    %     else latency(trial,:)=1;
    end
    % % % this gets the average timecourse to look to the actress
    thisPart_mov_ave_direct_to_puppet=mean(thisPart_mov_ave);
    % % %  emulating ESCS coding...finding frequency of responding to JA bids
    total_bids=length(latency);
    latency=cell2mat(latency);
    latency(find(latency==1))=[];
    success_bids=length(latency);
    proportion_follow_actress=success_bids/total_bids;
    % % %  calculating latency to look at actress 
    thisPart_latency_actress_to_puppet=nanmean(latency)/60*1000;
    clear thisPart_mov_ave latency trial thisPart_AOIs trial



%     % % look to ball
%     actress_to_ball=find(transition_indexes(:,5)==3);
%     for trial = 1:length(actress_to_ball);
%         thisPart_AOIs=zeros(length(AOIS_head_turn(transition_indexes(actress_to_ball(trial),1)-15:transition_indexes(actress_to_ball(trial),1)+74)),1);
%         thisPart_AOIs(find(AOIS_head_turn(transition_indexes(actress_to_ball(trial),1)-15:transition_indexes(actress_to_ball(trial),1)+74)==3))=1;
%         thisPart_mov_ave(trial,:)=movmean(thisPart_AOIs,[5 5]);
% 
%         latency{trial}= min(find(AOIS_head_turn(transition_indexes(actress_to_ball(trial),1):transition_indexes(actress_to_ball(trial),2)+59)==3));
% 
%     end
%     % % % this gets the average timecourse to look to the ball from puppet
%     thisPart_mov_ave_actress_to_ball=mean(thisPart_mov_ave);
%     % % %  emulating ESCS coding...finding frequency of responding to JA bids
%     total_bids_ball=length(latency);
%     latency_ball=cell2mat(latency);
%     latency_ball(find(latency_ball==1))=[];
%     proportion_follow_ball_puppet=length(latency_ball)/total_bids;
%     % % %  calculating latency to look at actress 
%     thisPart_latency_to_ball_puppet=nanmean(latency_ball)/60*1000;
%     % clear thisPart_mov_ave_puppet_to_ball latency latency_ball 
% 
% % %     store moving averages in a structure
%     all_part_latency_actress{p}=thisPart_mov_ave_direct_to_puppet;
%     all_part_latency_ball{p}=thisPart_mov_ave_actress_to_ball;
%     
    thisPart_puppet_latency_data= [proportion_follow_actress total_bids success_bids  thisPart_latency_actress_to_puppet];
    
    
% % Save variables
% Column 1: participant ID
% Column 2: proportion_follow_to_actress
% Column 3: thisPart_latency_to_actress_puppet
% Column 4: proportion_follow_ball_puppet
% Column 5: thisPart_latency_to_ball_puppet

file_name = fopen('1_9_18_puppet_data_following_JA_cues_actress.csv','a+');
% fprintf(file_name,'%12s,%s,%s,%s,%s\n',...
%     'SubjectID','proportion_gaze_cues_puppet_to_actress', 'latency_look_to_actress','proportion_gaze_cues_to_ball','latency_look_to_ball');

fprintf(file_name,'%s,%f,%f,%f,%f,\n', ...
     thisPartID, thisPart_puppet_latency_data);
 fclose(file_name);
 clear transition_indexes AOIS_head_turn 
end
    % % just curious within the transitions what's happening. are they looking at
    % % puppet? Not always! I suppose it depends on who's doing the talking (??)
    % clear i
    % looking_puppet=[];
    % for i=1:length(transition_indexes)
    %     this_average_puppet=mean(thisPartData(transition_indexes(i,1):transition_indexes(i,2),11));
    %     looking_puppet=[this_average_puppet looking_puppet];
    % end

    
    for i = 2:length(test3)
        test4(i-1)=test3(i)-test3(i-1);
    end
    
        
    for p = 2:length(bout_puppet)
puppet_talk = [bout_puppet(p)-bout_puppet(p-1)+1 puppet_talk];
end

    