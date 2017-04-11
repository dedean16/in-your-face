function [im_noBG, mask] = removeBackground(im, edgeThresh, strelVal, plotFlag)
%% function [im_BG] = removeBackground(im, thresh, strel)
%   Hint here
   
    % These have proven redundant
%     im = imresize(im, 0.25);
%     im = imgaussfilt(im, 2);

    % Convert to grayscale
im_g = rgb2gray(im);

    % Detect edges
edge = ut_edge(im_g, 't', edgeThresh);
    % Close the image morphologically
edge_closed = imclose(edge, strel('sphere',strelVal));
    % Fill the image by symmetric padding
bw_filled   = imfill(padarray(edge_closed,size(edge_closed),'symmetric'),'holes');
    % Extract the BG mask from filled image
mask = bw_filled(   size(edge_closed,1)+(1:size(edge_closed,1)),...
                    size(edge_closed,2)+(1:size(edge_closed,2)) );

	% Search for the largest connected component in the mask (Supposed to
	% be the person)
CC = bwconncomp(mask);

if CC.NumObjects > 1;
    [biggest,idx] = max( cellfun(@numel,CC.PixelIdxList) );
    for i = 1:CC.NumObjects;
        if i ~= idx;
            mask(CC.PixelIdxList{i}) = 0;
        end
    end
end

    % Remove the background from the image by masking
im_noBG = im(:,:,:) .* repmat(uint8(mask), [1,1,3]);

    % Plot if plotFlag allows
if plotFlag
    figure(101);clc;
    subplot(2,2,1);
        imshow(rgb2gray(im));
    subplot(2,2,2);
        imshow(edge);
    subplot(2,2,3);
        imshow(edge_closed);
    subplot(2,2,4);
        imshow(mask);
end


end