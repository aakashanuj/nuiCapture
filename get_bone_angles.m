% List of FRAMES_TO_ANALYZE to extract the skeletal data from
% Obtained from the beat tracking / onsets
%FRAMES_TO_ANALYZE = [1,22,38,55,75,94,110,128,147,162,185,200,218,235,252,266];

% This contains the list of folders which have the dance data extracted in
% them
folders = {'abhishek_medi'}
%folders = {'tatta_both'}

for folderCount = 1:size(folders,2)
    %FRAMES_TO_ANALYZE = [38,55,75,94,110,128,147,162,185,200,218,235,252,266];
    disp(folders{folderCount});
    FRAMES_TO_ANALYZE = [38,55,75,94,110];
    outFileName = strcat('output_',folders{folderCount},'.txt');
    fid = fopen(outFileName,'wt');
    
    dirName = strcat('G:\backup\',folders{folderCount},'\*.mat');
    allFiles = dir(dirName);
    filenames = {allFiles(~[allFiles.isdir]).name};
    
    for j = 1:size(filenames,2)
        matFileToLoad = strcat('G:\backup\',folders{folderCount},'\USB-VID_045E&PID_02BF-0000000000000000_',num2str(j),'.mat');
        load(matFileToLoad);
        
        % Find the skeleton which is tracked
        skeleton = -1;
        skeletonAlreadyFound = 0;
        for i = 1:6
            if (strcmp(SkeletonFrame.Skeletons(i).TrackingState,'Tracked')~=0)
                if(skeleton ~= -1)
                    skeletonAlreadyFound = 1;
                end
                skeleton = i;
            end
        end

        % Handle the case if skeleton is not tracked
        if (skeleton == -1 || skeletonAlreadyFound==1)
            for i = 1:19
                % Ignore the hip center joint, since it has NaN and NaN
                if (i==1 || i==16)
                    continue;
                end
                if i==19
                    fprintf(fid,'(%f,%f)\n',1000000,1000000);
                else
                    fprintf(fid,'(%f,%f), ',1000000,1000000);
                end
            end
            clearvars -except array folders folderCount j FRAMES_TO_ANALYZE fid;
            continue;
        end
        % Data structures to store the outputs
        jointNames={};
        thetaY = {};
        thetaXZ ={};
        count = 1;

        % Consider all 20 bones of the skeleton found
        for bone = 1:20
            startIndex = SkeletonFrame.Skeletons(skeleton).BoneOrientations(bone).StartJointIndex;
            endIndex = SkeletonFrame.Skeletons(skeleton).BoneOrientations(bone).EndJointIndex;
            startPos = SkeletonFrame.Skeletons(skeleton).Joints(startIndex).Position;
            endPos = SkeletonFrame.Skeletons(skeleton).Joints(endIndex).Position;
            parentVector = [ SkeletonFrame.Skeletons(skeleton).Joints(startIndex).Position.X SkeletonFrame.Skeletons(skeleton).Joints(startIndex).Position.Y SkeletonFrame.Skeletons(skeleton).Joints(startIndex).Position.Z];
            childVector = [ SkeletonFrame.Skeletons(skeleton).Joints(endIndex).Position.X SkeletonFrame.Skeletons(skeleton).Joints(endIndex).Position.Y SkeletonFrame.Skeletons(skeleton).Joints(endIndex).Position.Z];
            % For each bone, subtract the parent joint position from the child joint position so that a vector is formed that crosses through the origin of the coordinate system. Normalize this vector, lets call it diff.
            diffVector_orig = childVector - parentVector;
            diffVector = diffVector_orig / norm(diffVector_orig);
            matrix = SkeletonFrame.Skeletons(skeleton).BoneOrientations(1).AbsoluteRotation.Matrix(1:3,1:3);
            diffVector = inv(matrix) * diffVector';

            % Calculating the angle with the Y axis, with orientation independence
            y =  [0, 1, 0];
            dotProduct = dot(y,diffVector);
            angle_y = acosd(dotProduct);
            thetaY{count} = angle_y;

            % Calculating the angle with the x-z plane
            x = [1,0];
            vector2D = [diffVector(1) diffVector(3)];
            vector2D = vector2D / norm(vector2D);
            dotProduct = dot(x, vector2D);
            angle_xz = acosd(dotProduct);
            thetaXZ{count} = angle_xz;

            jointNames{count}=strcat(SkeletonFrame.Skeletons(skeleton).Joints(startIndex).JointType,SkeletonFrame.Skeletons(skeleton).Joints(endIndex).JointType);
            count = count + 1;
            %disp(strcat(SkeletonFrame.Skeletons(skeleton).Joints(startIndex).JointType,SkeletonFrame.Skeletons(skeleton).Joints(endIndex).JointType));
        end


        for i = 1:count-2
            % Ignore the hip center joint, since it has NaN and NaN
            if (i==1 || i==16)
                continue;
            end
            if i==19
                fprintf(fid,'(%f,%f)\n',thetaY{i},thetaXZ{i});
            else
                fprintf(fid,'(%f,%f), ',thetaY{i},thetaXZ{i});
            end
        end
        clearvars -except folders array folderCount j FRAMES_TO_ANALYZE fid;
    end
    fclose(fid);
    clearvars -except folders folderCount;

    % Now reading the data for the recorded dance video
    outFileName = strcat('output_',folders{folderCount},'.txt');
    fid = fopen(outFileName,'r');
    tline = fgetl(fid);
    count = 1;
    while ischar(tline)
        %disp(tline);
        parts = regexp(tline,', ','split');
        for i = 1:size(parts,2)
            part = parts(i);
            part = strrep(part,'(','');
            part = strrep(part,')','');
            % Now part contains data of the form '120.99,56.66', now let us
            % extract both the parts

            theta_parts = regexp(part,',','split');
            theta_y = str2double(theta_parts{1}(1));
            theta_xz = str2double(theta_parts{1}(2));
            % Now theta_y contains 120.99 and theta_z contains 56.66

            array{folderCount}{count}{i}{1} = theta_y;
            array{folderCount}{count}{i}{2} = theta_xz;
        end
        count = count+1;
        tline = fgetl(fid);
    end
    fclose(fid);


    % Now reading the input, and calculating the matching
    fid = fopen('input.txt','r');
    tline = fgetl(fid);
    while ischar(tline)
        %disp(tline);
        parts = regexp(tline,', ','split');
        for i = 1:size(parts,2)
            part = parts(i);
            part = strrep(part,'(','');
            part = strrep(part,')','');
            % Now part contains data of the form '120.99,56.66', now let us
            % extract both the parts

            theta_parts = regexp(part,',','split');
            theta_y = str2double(theta_parts{1}(1));
            theta_xz = str2double(theta_parts{1}(2));
            % Now theta_y contains 120.99 and theta_z contains 56.66

            input{i}{1} = theta_y;
            input{i}{2} = theta_xz;
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    %Now we have stored both the input joints(20) and the data for an Adavu,
    %now we can find the similarity between the input and every unique posture
    %in that Adavu

    %Linear matching
    best_posture = -1;
    diff = 10000000000;
    sum_test = 0;
    for i = 1:size(input,2)
        sum_test = sum_test + abs(input{i}{1}) + abs(input{i}{2});
    end
    for i = 1:size(array{folderCount},2)
       sum_train = 0;
       for j = 1:size(array{folderCount}{i},2)
        sum_train = sum_train + abs( array{folderCount}{i}{j}{1}) + abs( array{folderCount}{i}{j}{2});
       end
       if(abs(sum_test - sum_train)<diff)
        diff = abs(sum_test - sum_train);
        best_posture = i;
       end
    end
    disp('Best posture by linear matching');
    disp(best_posture);
    %figure,imshow(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(best_posture),'.png'))
    %diff

    %Exponential matching
    best_posture = -1;
    diff = 10000000000;
    for i = 1:size(array{folderCount},2) % The number of samples
       sum_overall = 0;
       for j = 1:size(array{folderCount}{i},2)
        sum_test_vi = 0;
        sum_train_vi = 0;

        % Converting the angles to radians, otherwise the value will be very
        % very large
        sum_test_vi = sum_test_vi + degtorad(abs(input{j}{1})) + degtorad(abs(input{j}{2}));
        sum_train_vi = sum_train_vi + degtorad(abs( array{folderCount}{i}{j}{1})) + degtorad(abs( array{folderCount}{i}{j}{2}));
        sum_overall = sum_overall + exp(abs(sum_test_vi - sum_train_vi));
       end

       if(sum_overall<diff)
        diff = sum_overall;
        best_posture = i;
        %figure,imshow(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(i),'.png'))
       end
    end
    disp('Best posture by exponential matching');
    disp(best_posture);
    diff
    figure,imshow(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(best_posture),'.png'))

    % Weighted linear matching
    give_weights_to_list= [5,6,9,10,13,14,17,18];
    best_posture = -1;
    weight = 1;
    diff = 10000000000;
    sum_test = 0;
    for i = 1:size(input,2)
        if ismember(i,give_weights_to_list)==1
            sum_test = sum_test + weight * (abs(input{i}{1}) + abs(input{i}{2}));
        else
            sum_test = sum_test + abs(input{i}{1}) + abs(input{i}{2});
        end
    end
    for i = 1:size(array{folderCount},2)
       sum_train = 0;
       for j = 1:size(array{folderCount}{i},2)
           if ismember(j,give_weights_to_list)==1
                sum_train = sum_train + weight * (abs( array{folderCount}{i}{j}{1}) + abs( array{folderCount}{i}{j}{2}));
           else
                sum_train = sum_train + abs( array{folderCount}{i}{j}{1}) + abs( array{folderCount}{i}{j}{2});
           end
       end
       if(abs(sum_test - sum_train)<diff)
        diff = abs(sum_test - sum_train);
        best_posture = i;
       end
    end
    disp('Best posture by weighted matching with weight = 2');
    disp(best_posture);
    %diff
    %figure,imshow(strcat('G:\backup\',folders{folderCount},'\color_USB-VID_045E&PID_02BF-0000000000000000_',num2str(best_posture),'.png'))
end

