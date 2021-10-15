clc;
%Question 3 - Extra Script to test Median Filtering Functions on Images

rgbI = imread('inputs/baloon.png');
grayI = imread('inputs/gray_image.jpg');

% Median Filtering for RGB Images - Default Kernel 3x3
%{ X
filteredRGB = medianFilterImgRGB(rgbI, 3);
imshow(filteredRGB);
%}

% Median Filtering for Grayscale Images - Default Kernel 3x3
%{
filteredGRAY = medianFilterImgGRAY(grayI, 15);
imshow(filteredGRAY);
%}


%Median Filtering - Parameter maskSize e.g. 3 means 3x3 5 means 5x5
%FOR GRAY SCALE IMAGES
function [img] = medianFilterImgGRAY(img, maskSize)
    [cols, rows] = size(img);
    
    padSize = (maskSize - 1) / 2;
    
    %zero padding img
    padImg = zeros(cols + padSize * 2, rows + padSize * 2);
    [padCols, padRows] = size(padImg);
    
    for i = 1 + padSize: padCols - padSize
        for j = 1 + padSize: padRows - padSize
            padImg(i,j) = img(i - padSize, j - padSize);
        end
    end
    
    for i = 1:cols
        for j = 1:rows
            
            values = [];
            PixelX = i;
            PixelY = j;
            
            %mask iteration
            for a = 1:maskSize
                for b = 1:maskSize
                    values(end+1) = padImg(PixelX, PixelY);
                    PixelX = PixelX + 1;
                end
                PixelX = i;
                PixelY = PixelY + 1;
            end
            sorted = sort(values);
            median = sorted(floor(maskSize^2 / 2) + 1);
            img(i,j) = median;
        end
    end
end

%Median Filtering - Parameter maskSize e.g. 3 means 3x3 5 means 5x5
%FOR RGB IMAGES
function [img] = medianFilterImgRGB(img, maskSize)
    [cols, rows] = size(img);

    padSize = (maskSize - 1) / 2;
    
    %zero padding img
    padImg = zeros(cols + padSize * 2, (rows / 3) + padSize * 2, 3);
    [padCols, padRows] = size(padImg);
    
    for i = 1 + padSize: padCols - padSize
        for j = 1 + padSize: (padRows / 3) - padSize
            padImg(i,j,1) = img(i - padSize, j - padSize, 1);
            padImg(i,j,2) = img(i - padSize, j - padSize, 2);
            padImg(i,j,3) = img(i - padSize, j - padSize, 3);
        end
    end
    
    for i = 1:cols
        for j = 1:rows / 3
            
            valuesR = [];
            valuesG = [];
            valuesB = [];
            PixelX = i;
            PixelY = j;
            
            %mask iteration
            for a = 1:maskSize
                for b = 1:maskSize
                    valuesR(end+1) = padImg(PixelX, PixelY, 1);
                    valuesG(end+1) = padImg(PixelX, PixelY, 2);
                    valuesB(end+1) = padImg(PixelX, PixelY, 3);
                    PixelX = PixelX + 1;
                end
                PixelX = i;
                PixelY = PixelY + 1;
            end
            sortedR = sort(valuesR);
            sortedG = sort(valuesG);
            sortedB = sort(valuesB);

            medianR = sortedR(floor(maskSize^2 / 2) + 1);
            medianG = sortedG(floor(maskSize^2 / 2) + 1);
            medianB = sortedB(floor(maskSize^2 / 2) + 1);
            
            img(i,j, 1) = medianR;
            img(i,j, 2) = medianG;
            img(i,j, 3) = medianB;
        end
    end
end