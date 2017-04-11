%% The main function for IPCV project 3

%% Initialize the project directory

try    % This is spcific to my coputer
    cd ~/Dropbox/IPCV/Project/;
    addpath(genpath('.'));
    PROJ_DIR = [pwd,'/'];
catch
    warning('No valid project folder given, nothing initialized!\n')
    warning('Define PROJ DIR!\n')
end

%% Start by camera calibration

% load PROJ_DIR/ipcv_project3/'Calibratie 1'/calibrationLeft/LeftCamParam/
% load PROJ_DIR/ipcv_project3/'Calibratie 1'/calibrationMiddle/MidCamParam/
% load PROJ_DIR/ipcv_project3/'Calibratie 1'/calibrationRight/RightCamParam/

    % Load stereo calibration for Middle and Right
load([PROJ_DIR, 'ipcv_project3/Calibratie 1/sP_MR.mat'])
load([PROJ_DIR, 'ipcv_project3/Calibratie 1/sP_ML.mat'])

    % Load face images
im_L = imread([PROJ_DIR,'ipcv_project3/subject1/subject1Left/subject1_Left_1.jpg']);
im_M = imread([PROJ_DIR,'ipcv_project3/subject1/subject1Middle/subject1_Middle_1.jpg']);
im_R = imread([PROJ_DIR,'ipcv_project3/subject1/subject1Right/subject1_Right_1.jpg']);

figure(1); clf
    subplot(1,3,1);
        imshow(im_L)
    subplot(1,3,2);
        imshow(im_M)
        title('Original images')
    subplot(1,3,3);
        imshow(im_R)

        
%% Remove background

im_L_noBG = removeBackground(im_L, 0.03, 10);
im_M_noBG = removeBackground(im_M, 0.04, 5);
im_R_noBG = removeBackground(im_R, 0.05, 15);

%% Rectify

[im_Mr_rec, im_R_rec] = rectifyStereoImages(im_M_noBG, im_R_noBG, sP_MR, 'OutputView','full');
[im_Ml_rec, im_L_rec] = rectifyStereoImages(im_M_noBG, im_L_noBG, sP_ML, 'OutputView','full');

figure(2); clf
    subplot(1,2,1);
        imshow(stereoAnaglyph(im_Mr_rec, im_R_rec));
	subplot(1,2,2);
        imshow(stereoAnaglyph(im_Ml_rec, im_L_rec));

       

%% Disparity

    % graylevel images
im_Mr_rec_g = rgb2gray(im_Mr_rec);
im_R_rec_g = rgb2gray(im_R_rec);

disparityRange = [200 360];
disparityMap = disparity(im_Mr_rec_g, im_R_rec_g,...
    'BlockSize', 5, 'DisparityRange', disparityRange);

figure(3); clf;
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap jet
colorbar