% List of FRAMES_TO_ANALYZE to extract the skeletal data from
% Obtained from the beat tracking / onsets
postures = {[22,38,54,72,94,105,131,149,165,185,201,220,233,251,267,280],[36,51,67,79,97,114,128,140,156,167,182,194],[],[8,19,26,29,35,48,69,75,82,89,100],[17,26,33,41,47,57,67,73,84,90,97,105,112,125,131,139,150,157,165,172]};

% This contains the list of folders which have the dance data extracted in
% them
folders = {'natta_aakash','natta_abhishek','tatta_both','visharu_aakash','meddinatta'};

for folderCount = 1:size(folders,2)
    outputVideo = VideoWriter(strcat(folders{folderCount},'.avi'));
    outputVideo.FrameRate = 2;
    open(outputVideo)
    for i = 1 : size(postures{folderCount},2)
        %subplot(10,6,count),imshow(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(postures{folderCount}(i)),'.png'));
        img = imread(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(postures{folderCount}(i)),'.png'));
        writeVideo(outputVideo,img);
    end
    close(outputVideo)
end
