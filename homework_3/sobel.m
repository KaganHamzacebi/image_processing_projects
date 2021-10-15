clc;
%Question 4

vid = VideoReader('inputs/video.avi');
filteredVideo = VideoWriter('edges');

open(filteredVideo);
%Filter Video
frameNum = 1;
while hasFrame(vid)
    %Get Frame and Filter
    frame = readFrame(vid);
    
    frame = sobelEdgeDetection(frame);
    writeVideo(filteredVideo, uint8(frame));
    fprintf('%dth Frame filtered!\n', frameNum);
    frameNum = frameNum + 1;
end
close(filteredVideo);

%Sets pixel brightness to 0 below threshold or 255 above threshold
function [img] = thresholder(img, threshold)
    [cols, rows] = size(img);

    for i = 1:cols
        for j = 1:rows
            if (img(i,j) < threshold) 
                img(i,j) = 0;
            elseif (img(i,j) >= threshold)
                img(i,j) = 255;
            end
        end
    end
end

%Filters Image with given mask
function [img] = filterImg(img, mask)
    [cols, rows] = size(img);

    maskSize = size(mask,1);
    padSize = (maskSize - 1) / 2;
    
    %zero padding img
    padImg = zeros(cols + padSize * 2, (rows / 3) + padSize * 2);
    [padCols, padRows] = size(padImg);
    
    for i = 1 + padSize: padCols - padSize
        for j = 1 + padSize: padRows - padSize
            padImg(i,j) = img(i - padSize, j - padSize);
        end
    end
    
    for i = 1:cols
        for j = 1:rows / 3
            
            intensity = 0;
            PixelX = i;
            PixelY = j;
            
            %mask iteration
            for a = 1:size(mask,1)
                for b = 1:size(mask,2)
                    intensity = intensity + (mask(a,b) * padImg(PixelX, PixelY));
                    PixelX = PixelX + 1;
                end
                PixelX = i;
                PixelY = PixelY + 1;
            end
            img(i,j) = abs(intensity);
        end
    end
end

%Edge Detection with Sobel
function [magnitude] = sobelEdgeDetection(img)
    %Sobel 3x3 Kernels
    sobelMaskX = [-1 0 1
                  -2 0 2
                  -1 0 1];

    sobelMaskY = [-1 -2 -1
                  0 0 0
                  1 2 1];

    %Perform threshold after each filter for cleaner result
    %Filter on X Kernel
    sobelX = filterImg(img, sobelMaskX);
    
    %Filter on Y Kernel
    sobelY = filterImg(img, sobelMaskY);
    
    %Calculate Magnitude
    [cols, rows] = size(sobelX);
    magnitude = zeros(cols,rows / 3);

    for i = 1:cols
        for j = 1:rows / 3
            %Magnitude
            sx = double(sobelX(i,j))^2;
            sy = double(sobelY(i,j))^2;
            mag = (sx + sy)^(1/2);
            magnitude(i,j) = uint8(mag);
        end
    end
    
    %apply thresholder
    magnitude = thresholder(magnitude, 85);
end