%% The main function for IPCV project 3

%% Initialize the project directory

[PROJ_DIR, mname, mext] = fileparts(mfilename('fullpath'));
PROJ_DIR = [PROJ_DIR, '/'];
cd(PROJ_DIR);

addpath(PROJ_DIR);

%% Start by camera calibration

% load PROJ_DIR/ipcv_project3/'Calibratie 1'/calibrationLeft/LeftCamParam/
% load PROJ_DIR/ipcv_project3/'Calibratie 1'/calibrationMiddle/MidCamParam/
% load PROJ_DIR/ipcv_project3/'Calibratie 1'/calibrationRight/RightCamParam/

    % Load stereo calibration for Middle and Right
load([PROJ_DIR, 'Calibratie 1/sP_MR.mat'])
load([PROJ_DIR, 'Calibratie 1/sP_ML.mat'])

    % Load face images
im_L = imread([PROJ_DIR,'subject1/subject1Left/subject1_Left_1.jpg']);
im_M = imread([PROJ_DIR,'subject1/subject1Middle/subject1_Middle_1.jpg']);
im_R = imread([PROJ_DIR,'subject1/subject1Right/subject1_Right_1.jpg']);

figure(1); clf
    subplot(1,3,1);
        imshow(im_L)
    subplot(1,3,2);
        imshow(im_M)
        title('Original images')
    subplot(1,3,3);
        imshow(im_R)

        
%% Remove background in im_*_noBG and store the mask to mask_*
%   (in mask_* BG pixels are 0 and face 1)

[im_L_noBG, mask_L] = removeBackground(im_L, 0.10, 2, false);
[im_M_noBG, mask_M] = removeBackground(im_M, 0.10, 2, false);
[im_R_noBG, mask_R] = removeBackground(im_R, 0.10, 2, false);

figure; 
    imshow(im_L_noBG);
figure; 
    imshow(im_M_noBG);
figure; 
    imshow(im_R_noBG);
    
    
%% Normalize image intesities to correspond middle image

im_L_norm = normalizeImages(im_L_noBG, im_M_noBG);
im_R_norm = normalizeImages(im_R_noBG, im_M_noBG);

    
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