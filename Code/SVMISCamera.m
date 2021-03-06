%% Classification based on Optical Flow
run('GLOBAL.m');
addpath('C:\Users\Sarthak\Dropbox\IIITDsem7\ML\Major Project\Code\libsvm-3.20\libsvm-3.20\matlab');
%% Go Over Clean Data
% Sarthak
 dataFolder = 'C:\Users\Sarthak\Dropbox\IIITDsem7\ML\Major Project\Data';

% Anchita
% dataFolder = 'F:\Dropbox\Major Project\Data';

 cleanDataFolder = strcat(dataFolder,'\Cleaned Data');
 contents = dir(cleanDataFolder);   

 DATAMATRIX={};
 for i = 3:size(contents,1),
     if(~isempty(findstr(contents(i).name,'_OF'))),
         load(strcat(dataFolder,'\Cleaned Data\',contents(i).name));
         DATAMATRIX=[DATAMATRIX;OF];
     end
 end
 
 TrainingFeatures=[];
 TrainingLabels=[];
 
%% Create Training Feature Vector
for i = 1:70,
    data=DATAMATRIX(i,1);
    numFrames=size(data.LK_X_raw,1);
    fv = [data.FOE_center_dist, data.FOE_y, data.FOE_x, data.Mean_raw_mag_temporal_stddev, data.Mean_raw_magnitude, data.Mean_smooth_magnitude, data.Diff_raw_smooth, data.Cluster_bot_mean_mag, data.Cluster_top_mean_mag, data.Clusters_distance, data.Template_response, data.LK_valid_count_smooth, data.LK_valid_count];
    TrainingFeatures=[TrainingFeatures;fv]; 
    TrainingLabels=[TrainingLabels;data.Labels];
end

ConvertedTrainingLabels=[];
ConvertedTrainingFeatures=[];
for i=1:size(TrainingLabels,1),
    for j =1:size(activities,2),
         temp = findstr(char(activities(1,j)),char(TrainingLabels(i)));
         if(~isempty(temp)),
             if(j==1)
                ConvertedTrainingLabels=[ConvertedTrainingLabels;1];
                ConvertedTrainingFeatures=[ConvertedTrainingFeatures;TrainingFeatures(i,:)];
             elseif(j==2),
                ConvertedTrainingLabels=[ConvertedTrainingLabels;2];
                ConvertedTrainingFeatures=[ConvertedTrainingFeatures;TrainingFeatures(i,:)];
             end
             break;
         end
     end
end

 TestingFeatures=[];
 TestingLabels=[];
 
%% Create Testing Feature Vector
for i = 71:126,
    data=DATAMATRIX(i,1);
    numFrames=size(data.LK_X_raw,1);
    fv = [data.FOE_center_dist, data.FOE_y, data.FOE_x, data.Mean_raw_mag_temporal_stddev, data.Mean_raw_magnitude, data.Mean_smooth_magnitude, data.Diff_raw_smooth, data.Cluster_bot_mean_mag, data.Cluster_top_mean_mag, data.Clusters_distance, data.Template_response, data.LK_valid_count_smooth, data.LK_valid_count];
    TestingFeatures=[TestingFeatures;fv]; 
    TestingLabels=[TestingLabels;data.Labels];
end

ConvertedTestingLabels=[];
ConvertedTestingFeatures=[];
for i=1:size(TestingLabels,1),
    for j =1:size(activities,2),
         temp = findstr(char(activities(1,j)),char(TestingLabels(i)));
         if(~isempty(temp)),
             if(j==1)
                ConvertedTestingLabels=[ConvertedTestingLabels;1];
                ConvertedTestingFeatures=[ConvertedTestingFeatures;TestingFeatures(i,:)];
             elseif(j==2)
                ConvertedTestingLabels=[ConvertedTestingLabels;2];
                ConvertedTestingFeatures=[ConvertedTestingFeatures;TestingFeatures(i,:)];
             end
             break;
         end
     end
end


parameters = ['-t 0']; 
model = svmtrain(ConvertedTrainingLabels, ConvertedTrainingFeatures, parameters);
[predicted_label, accuracy, decision_values] = svmpredict(ConvertedTestingLabels, ConvertedTestingFeatures, model);
C = confusionmat(ConvertedTestingLabels,predicted_label);
performance = classperf(ConvertedTestingLabels,predicted_label);
X = performance.CountingMatrix;
correctlyClassified = X(sub2ind(size(X),1:(size(X,1)-1),1:size(X,2)));
accuracy = sum(correctlyClassified)/size(ConvertedTestingLabels,1);
%% Stage 2 Train SVM
