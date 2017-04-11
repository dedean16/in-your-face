function [im_BG] = removeBackground(im, thresh, strelVal)
%% function [im_BG] = removeBackground(im, thresh, strel)
%   Hint here
    
im_g = rgb2gray(im);

edge = ut_edge(im_g, 't', thresh);
edge2 = imclose(edge, strel('sphere',strelVal));
edge3 = imfill(edge2, 'holes');

CC = bwconncomp(edge3);

if CC.NumObjects > 1;
    [biggest,idx] = max( cellfun(@numel,CC.PixelIdxList) );
    for i = 1:CC.NumObjects;
        if i ~= idx;
            edge3(CC.PixelIdxList{i}) = 0;
        end
    end
end

im_BG = im(:,:,:) .* repmat(uint8(edge3), [1,1,3]);

figure(101);clc;
    subplot(2,2,1);
        imshow(rgb2gray(im));
	subplot(2,2,2);
        imshow(edge);
	subplot(2,2,3);
        imshow(edge2);
	subplot(2,2,4);
        imshow(edge3);



end