%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to parse files and convert to txt%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T. Tsang 10/18/2018
%%% Information about Clips are stored under results.data.section
%%% XY Data for clips is under results.data.sorp. We do not have
%%% information about pupils but there is about retinal position and
%%% diameter (which you can calculate 
%%%% Here is the game plan!
%%%% Step 1: Go through each .mat file to find violet
%%%% Step 2: Find start/stop of violet
%%%% Step 3: Store in a new matrix
%%%% Step 4: Save as a CSV 


%%%% Step 1: Go through each .mat file to find violet
dir_contents=dir('/Users/tawnytsang/Desktop/matlab_data/test_files/*.mat'); %change to your path with matlab files
data_files = {dir_contents.name};  % cell structure


for i = 1:length(data_files)
    c = load(data_files{i});
    thisPart_file_name = data_files{i}
    
    image_tag = {c.results.data.image.tag}';
    find_violet = strcmp(image_tag,'img_series8000_movie_Conversation_Violet.bmp');
% %    Find samples labeled as fixations, blinks, and saccades in the ET
% session as outputted by the pipeline script. 
    fixations = c.results.ballistics.fixations.label;
    fixations(fixations>=1)=1;
    
    blinks = c.results.ballistics.blinks.label;
    blinks(blinks>=1)=1;
    
    saccades = c.results.ballistics.saccades.label;
    saccades(saccades>=1)=1;
    
    if sum(find_violet)==0;
        disp(sprintf('This participant did not see puppets'))
        continue
    elseif sum(find_violet)==1;
%%%% Step 2: Go through each .mat file to find violet
        violet_index=find(find_violet==1);
        violet_start_frame = c.results.data.image(violet_index).dataidx;
        violet_end_frame = c.results.data.image(violet_index+1).dataidx;

%%%% Step 3: Store in a new matrix
        violet_raw_screen_coordXY = c.results.data.coord.sorg(violet_start_frame:violet_end_frame,:);
        violet_retinal_position_XY = c.results.data.coord.rp(violet_start_frame:violet_end_frame,:);
        violet_fix = fixations(violet_start_frame:violet_end_frame,:);
        violet_blink = blinks(violet_start_frame:violet_end_frame,:);
        violet_saccade = saccades(violet_start_frame:violet_end_frame,:);    
        
        raw_violet_data=[violet_raw_screen_coordXY violet_retinal_position_XY violet_fix violet_blink violet_saccade];
        
%%%% Step 4: Save as CSV
% % % Make file to save output
%write header to file

fid = fopen([thisPart_file_name,'.csv'],'w'); 
fprintf(fid,'%s,%s,%s,%s,%s,%s,%s\n',...
    'CoordX', 'CoordY','RetinalPositionX','RetinalPositionY','FixationIndex', 'BlinkIndex','SaccadeIndex');
fclose(fid)
%write data to end of file
dlmwrite([thisPart_file_name,'.csv'],raw_violet_data,'-append');
    end
end
        
        
        
