% This contains the list of folders which have the dance data extracted in
% them
folders = {'Samples_PPT'};

for folderCount = 1:size(folders,2)
    outputVideo = VideoWriter('samples.wmv');
    outputVideo.FrameRate = 2;
    open(outputVideo)
    for i = 1 : 14
        %subplot(10,6,count),imshow(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(postures{folderCount}(i)),'.png'));
        img = imread(strcat('G:\backup\Samples_PPT\',num2str(i),'.png'));
        writeVideo(outputVideo,img);
    end
    close(outputVideo)
end
