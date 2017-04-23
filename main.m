%% The main function for IPCV project 3

%% Initialize the project directory

[PROJ_DIR, mname, mext] = fileparts(mfilename('fullpath'));
PROJ_DIR = [PROJ_DIR, '/'];
cd(PROJ_DIR);

addpath(genpath(PROJ_DIR));

%% Start by camera calibration

    % Define subject and calibration paths
    SUBJ = 'subject1';      % Possibilities 1,2,4
    CALIB= 'Calibratie 1/'; % Possibilities 1,2
    IMG  = '_2';            % Possibilties 1,2,365,729,1093,1457

    % Load stereo calibration 
load([PROJ_DIR, CALIB, 'sP_MR.mat'])
load([PROJ_DIR, CALIB, 'sP_ML.mat'])
load([PROJ_DIR, CALIB, 'sP_LR.mat'])

    % Load face images
im_L = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Left/',   SUBJ, '_Left',  IMG,'.jpg']);
im_M = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Middle/', SUBJ, '_Middle',IMG,'.jpg']);
im_R = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Right/',  SUBJ, '_Right', IMG,'.jpg']);


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
    

plotFlag = false;
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

OutpView = 'full';

[im_Mr_rec, im_R_rec] = rectifyStereoImages(im_M, im_R_norm, sP_MR,...
                            'OutputView',OutpView);
[im_Ml_rec, im_L_rec] = rectifyStereoImages(im_M, im_L_norm, sP_ML,...
                            'OutputView',OutpView);
[im_Lr_rec, im_Rl_rec] = rectifyStereoImages(im_L, im_R_norm, sP_LR,...
                            'OutputView',OutpView);

[mask_Mr_rec, mask_R_rec] = rectifyStereoImages(mask_M, mask_R, sP_MR,...
                            'OutputView',OutpView);
[mask_Ml_rec, mask_L_rec] = rectifyStereoImages(mask_M, mask_L, sP_ML,...
                            'OutputView',OutpView);
[mask_Lr_rec, mask_Rl_rec] = rectifyStereoImages(mask_L, mask_R, sP_LR,...
                            'OutputView',OutpView);

                        
masked_Mr_rec = im_Mr_rec .* uint8(repmat(mask_Mr_rec,[1,1,3]));
masked_R_rec  = im_R_rec  .* uint8(repmat(mask_R_rec,[1,1,3]));
                        
masked_Ml_rec = im_Ml_rec .* uint8(repmat(mask_Ml_rec,[1,1,3]));
masked_L_rec  = im_L_rec  .* uint8(repmat(mask_L_rec,[1,1,3]));

masked_Lr_rec = im_Lr_rec .* uint8(repmat(mask_Lr_rec,[1,1,3]));
masked_Rl_rec = im_Rl_rec .* uint8(repmat(mask_Rl_rec,[1,1,3]));



figure;
    CreateAxes(3,1,1);
        imshow(stereoAnaglyph(masked_Mr_rec, masked_R_rec));
	CreateAxes(3,1,2);
        imshow(stereoAnaglyph(masked_Ml_rec, masked_L_rec));
	CreateAxes(3,1,3);
        imshow(stereoAnaglyph(masked_Lr_rec, masked_Rl_rec));

        
figure;
    CreateAxes(2,1,1);
        imshow(mask_Mr_rec);
	CreateAxes(2,1,2);
        imshow(mask_Ml_rec);
	

%% Disparity

disparmap_R = mapDisparity(im_Mr_rec, im_R_rec);
disparmap_L = mapDisparity(im_Ml_rec, im_L_rec);
    % Cut the background out by using the binary mask
figure;
    imshow(disparmap_R)
figure;
    imshow(disparmap_L)

%% Fill Gaps with relaxation
gv = -1;

disparmap = disparmap_R.*mask_Mr_rec;
disparmap(isnan(disparmap)) = 0;
disparmap(mask_Mr_rec==1 & disparmap==0) = gv;
disparmap_f = relaxgaps(disparmap,gv,1,300,0.001,0);

figure; imshow(disparmap.*mask_Mr_rec,[])
figure; imshow(disparmap_f,[])

%% Laplacian filter
threshold = 1;
[disparmap_fl,lapfilt] = laplacianFilter(disparmap_f,threshold,gv);
figure; imshow(disparmap_fl,[]); title('Laplacian filtered')
[disparmap_flf,its] = relaxgaps(disparmap_fl,gv,1,400,0.001,0);

figure; imshow(disparmap_flf,[]); title('Relaxed Laplacian filtered')

%% Plot Face Mesh
facemesh(disparmap_flf,im_Mr_rec)


%% Write Report Images
writeReportImages = true;

if writeReportImages
    % Crop parameters
    x = 800;
    y = 100;
    w = 600;
    h = 700;
    
    % Crop images and adjust range for export
    disparitygaps_c = mat2gray(imcrop(disparmap,    [x y w h]));
    disparityfill_c = mat2gray(imcrop(disparmap_f,  [x y w h]));
    disparitylapf_c = mat2gray(imcrop(lapfilt,      [x y w h]));
    disparityflf_c  = mat2gray(imcrop(disparmap_flf,[x y w h]));
    
    % Write images
    imwrite(disparitygaps_c,'./out/disparity-gaps.png')
    imwrite(disparityfill_c,'./out/disparity-fill.png')
    imwrite(disparitylapf_c,'./out/disparity-lapf.png')
    imwrite(disparityflf_c, './out/disparity-flf.png')
end

