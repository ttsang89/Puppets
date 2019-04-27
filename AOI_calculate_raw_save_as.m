% % This script will save things in a nice file, sorted by timestamp
% % column 1: Part ID
% % column 2: puppet vs person speaker
% % column 3: puppet head dir; 0:transition 1: partner 2: camera 3: ball
% % column 4: person head dir; 0:transition 1: partner 2: camera 3: ball
% % column 5: T0
% % column 6: T1
% % column 7: T1-T0
% % column 8: valid fix dur
% % column 9: puppet head
% % column 10: person head
% % column 11: ball
% % column 12: puppet body
% % column 13: person body
% % column 14: BG

% % % % % % Step 1: create CSV file (only need to do once)
% % % % % % Step 2: get the matrix with all the stored info
% % % % % % Step 3: concatenate. ugh
% % % % % % Save as CSV

% % % 
% file_name = fopen('violet_puppet_data_raw_test.csv','a+');
% % % % Create headers for your file
% % % RUN THE FOLLOWING 2 LINEs ONLY ONCE TO CREATE HEADER NAMES!
% fprintf(file_name,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
% 'PartID','Speaker','Puppet_head_direction', 'Person_head_direction', 'T0', ...
% 'T1', 'T1-T0', 'valid fixation dur MS', 'puppet head dur MS','person head dur MS',...
% 'ball dur MS','puppet body dur MS','person body dur MS','background dur MS');
%  fclose(file_name);

% load('this_part_data_raw_coded.mat')
combined_data=[];
allPartID=[];
for i=1:length(this_part_data_raw_coded)
    thisPartID=[];
condition_data=[];
speaker_condition=[];
puppet_head=[];
person_head=[];

    for p = 1:length(this_part_data_raw_coded{i,2,1});
        condition_data=[condition_data; this_part_data_raw_coded{i,3}{p}];
        condition_array=this_part_data_raw_coded{1,2}{p};
        speaker_condition = [speaker_condition; repmat(condition_array(1),size(this_part_data_raw_coded{1,3}{p},1),1)];
        puppet_head=[puppet_head; repmat(condition_array(2),size(this_part_data_raw_coded{1,3}{p},1),1)];
        person_head=[person_head; repmat(condition_array(3),size(this_part_data_raw_coded{1,3}{p},1),1)];
%         speaker_condition = [speaker_condition; condition_array(1) this_part_data_raw_coded{1,3}{p}];
%         puppet_head=[puppet_head; repmat(condition_array(2),size(this_part_data_raw_coded{1,3}{p},1),1)];
%         person_head=[person_head; repmat(condition_array(3),size(this_part_data_raw_coded{1,3}{p},1),1)];
        thisPartID=[thisPartID; repmat(this_part_data_raw_coded{i}, size(this_part_data_raw_coded{1,3}{p},1),1)]; 
         
        
    end
   
    combined_data=[combined_data; speaker_condition puppet_head person_head condition_data];
    allPartID=[allPartID; thisPartID];

% file_name = fopen('violet_puppet_data_test.csv','a+');
%     fprintf(file_name,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\n', ...
% thisPartID, combined_data);
%     fclose(file_name);
%     % fprintf(file_name,'%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\n', ...
%      thisPartID, thisPart_Looking_data);
%  fclose(file_name);
end

   
    