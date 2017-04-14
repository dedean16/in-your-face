%% The main function for IPCV project 3

%% Initialize the project directory

[PROJ_DIR, mname, mext] = fileparts(mfilename('fullpath'));
PROJ_DIR = [PROJ_DIR, '/'];
cd(PROJ_DIR);

addpath(genpath(PROJ_DIR));

%% Start by camera calibration

    % Define subject and calibration paths
    SUBJ = 'subject2';      % Possibilities 1,2,4
    CALIB= 'Calibratie 1/'; % Possibilities 1,2

    % Load stereo calibration 
load([PROJ_DIR, CALIB, 'sP_MR.mat'])
load([PROJ_DIR, CALIB, 'sP_ML.mat'])

    % Load face images
im_L = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Left/', SUBJ, '_Left_1.jpg']);
im_M = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Middle/', SUBJ, '_Middle_1.jpg']);
im_R = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Right/', SUBJ, '_Right_1.jpg']);
% im_M = imread([PROJ_DIR,'subject1/subject1Middle/subject1_Middle_1.jpg']);
% im_R = imread([PROJ_DIR,'subject1/subject1Right/subject1_Right_1.jpg']);

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

switch SUBJ(end);
    case '1'
        edgeThresh  = 0.1;
        strelVal    = 2;
    case '2'
        edgeThresh  = 0.05;
        strelVal    = 4;
    case '4'
        edgeThresh  = 0.03;
        strelVal    = 5;
end
    

plotFlag = true;
[im_L_noBG, mask_L] = removeBackground(im_L, edgeThresh, strelVal, plotFlag);
[im_M_noBG, mask_M] = removeBackground(im_M, edgeThresh, strelVal, plotFlag);
[im_R_noBG, mask_R] = removeBackground(im_R, edgeThresh, strelVal, plotFlag);

figure; 
    imshow(im_L_noBG);
figure; 
    imshow(im_M_noBG);
figure; 
    imshow(im_R_noBG);
    
    
%% Normalize image intesities to correspond middle image

im_L_norm = normalizeImages(im_L, im_M);
im_R_norm = normalizeImages(im_R, im_M);

    
%% Rectify


[im_Mr_rec, im_R_rec] = rectifyStereoImages(im_M, im_R_norm, sP_MR,...
                            'OutputView','full');
[im_Ml_rec, im_L_rec] = rectifyStereoImages(im_M, im_L_norm, sP_ML,...
                            'OutputView','full');

[mask_Mr_rec, mask_R_rec] = rectifyStereoImages(mask_M, mask_R, sP_MR,...
                            'OutputView','full');
[mask_Ml_rec, mask_L_rec] = rectifyStereoImages(mask_M, mask_L, sP_ML,...
                            'OutputView','full');

                        
figure(2); clf
    subplot(1,2,1);
        imshow(stereoAnaglyph(im_Mr_rec, im_R_rec));
	subplot(1,2,2);
        imshow(stereoAnaglyph(im_Ml_rec, im_L_rec));

figure(3); clf
    subplot(1,2,1);
        imshow(mask_Mr_rec);
	subplot(1,2,2);
        imshow(stereoAnaglyph(mask_Ml_rec, mask_L_rec));

        

%% Disparity

disparmap = mapDisparity(im_Mr_rec, im_R_rec);
    % Cut the background out my using the binary mask
figure;
    imshow(disparmap.* mask_Mr_rec)

%%
disparmap(isnan(disparmap)) = 0;
disparmap_f = relaxgaps(disparmap,0,1,300,0.001,0);
figure; imshow(disparmap_f,[])

