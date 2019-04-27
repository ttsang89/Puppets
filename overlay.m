% Overlay for Gaze trajectory -- Puppet convo Violet
% 2018-12-10
% Tawny Tsang & Eukyung Yhang

% % Options are either to overlay representative ASD, TD, and DD cases
% separately or together

% floc = 'C:\Users\ye37\Box Sync\matlab\data\QCB9A50H.mat'
% load(floc)
% participant_dir_content = dir('/Users/tawnytsang/Box Sync/Tawny_work/Puppet_Project/matlab/matlab_data/*.mat');
% part_files={participant_dir_content.name};

% % FIND TD
% QD5NC10N (CSS 1 >90%)
% % FIND ASD
% QCBHA27K (CSS 9 >88%)
% % DD
% QDAIA382 (ADHD CSS 6 >96%)
TD_kid = load('/Users/ye37/Box Sync/matlab/matlab_data/QD5NC10N.mat');
ASD_kid = load('/Users/ye37/Box Sync/matlab/matlab_data/QCBHA27K.mat');
DD_kid = load('/Users/ye37/Box Sync/matlab/matlab_data/QDAIA382.mat');

ET_files = {TD_kid; ASD_kid; DD_kid}
for p = 1:3
    
Xdata(:,p) = ceil(ET_files{p}.thisPartData(:,1));
Ydata(:,p) = ceil(ET_files{p}.thisPartData(:,2));
end


% Create file (e.g., directory/folder) to store imgs
RightNow=(fix(clock));
UniqueDirName=[num2str(RightNow(1))];
for i=2:6
    UniqueDirName=[UniqueDirName '-' num2str(RightNow(i))];
end
OutputDirPath = ['/Users/ye37/Box Sync/matlab/Image_Output/OverlayFixOutput_' UniqueDirName '/'];
if exist(OutputDirPath,'dir') ~= 7
    mkdir(OutputDirPath);
end


% Plot crosshairs
for i=1:length(Xdata)
    TDx = Xdata(i,1);
    TDy = Ydata(i,1);
    ASDx = Xdata(i,2);
    ASDy = Xdata(i,2);
    DDx = Xdata(i,3);
    DDy = Xdata(i,3);
    im = imread(['Z:\Eye Tracking\All AOIs\Puppet Conversations\0_average_images\puppets_violet\images\Conversation_Violet' num2str(i, '%04.0f') '.jpeg']);

    imagesc(imresize(im, [1050 1680]));

% -----------------------------%
% -----------------------------%
% if you want to overlay images, use this directory %%%%%%%%

hold on;

plot(TDx, TDy, 'b+', 'MarkerSize', 20, 'LineWidth', 4);
hold on;

plot(ASDx, ASDy, 'w+', 'MarkerSize', 20, 'LineWidth', 4);
hold on;

plot(DDx, DDy, 'g+', 'MarkerSize', 20, 'LineWidth', 4);
hold on;


		
set(gca,'XTick',[],'YTick',[],'Color',[0 0 0]);
m = getframe;
cd (OutputDirPath);
imwrite(m.cdata,[num2str(i,'%04.0f') '.jpg'],'BitDepth',8);

end

        
