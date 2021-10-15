clc;
%Question 1 - 2 - 4

img = imread('inputs/lines_bw.jpg');

%filter mask default 3x3
mask = 1/9 * [1 1 1
              1 1 1
              1 1 1];

%Custom Mask Image Filter - You can change the mask above
%{
filteredImg = filterImg(img, mask);
imshow(filteredImg);
%}
   
%Sobel Edge Detection
%{
sobelEdge = sobelEdgeDetection(img);
imshow(sobelEdge);
%}

%Question 4
%{x
[edgePoints, theta, rho] = sobelEdgeDetection(img);
hough = houghTransform(edgePoints, theta, rho);
imshow(hough);
%}


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
    padImg = zeros(cols + padSize * 2, rows + padSize * 2);
    [padCols, padRows] = size(padImg);
    
    for i = 1 + padSize: padCols - padSize
        for j = 1 + padSize: padRows - padSize
            padImg(i,j) = img(i - padSize, j - padSize);
        end
    end
    
    for i = 1:cols
        for j = 1:rows
            
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
function [magnitude, theta, rho] = sobelEdgeDetection(img)
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
    magnitude = zeros(cols,rows);
    theta = zeros(cols,rows);
    rho = zeros(cols, rows);

    for i = 1:cols
        for j = 1:rows
            %Magnitude
            sx = double(sobelX(i,j))^2;
            sy = double(sobelY(i,j))^2;
            mag = (sx + sy)^(1/2);
            magnitude(i,j) = uint8(mag);
            %Gradient
            theta(i,j) = atan(double(sobelX(i,j)) / double(sobelY(i,j)));
            rho(i,j) = i * cos(theta(i,j)) + j * sin(theta(i,j));
        end
    end
    
    %apply thresholder
    magnitude = thresholder(magnitude, 120);
end

%Hough Transform Method
function [hough] = houghTransform(sobel, theta, rho)
    [cols, rows] = size(sobel);
    hough = zeros(512,512);
    
    minT = 99;
    minR = 99;
    
    for i = 1:cols
        for j = 1:rows
            if (theta(i,j) ~= 0 && minT > theta(i,j))
                minT = theta(i,j);
            end
            if (rho(i,j) ~= 0 && minR > rho(i,j))
                minR = rho(i,j);
            end
        end
    end
    
    for i = 1:cols
        for j = 1:rows
            if(theta(i,j) ~= 0) 
                theta(i,j) = theta(i,j) + 1 - minT;
            end
            if(rho(i,j) ~= 0) 
                rho(i,j) = rho(i,j) + 1 - minR;
            end
        end
    end
    
    max_val_grad = max(theta,[], 'all');
    max_val_rho = max(rho,[], 'all');
    multp_grad = 512 / max_val_grad;
    multp_rho = 512 / max_val_rho;
    
    for i = 1:cols
        for j = 1:rows
            if(theta(i,j) ~= 0) 
                theta(i,j) = ceil(theta(i,j) * multp_grad);
            end
            if(rho(i,j) ~= 0) 
                rho(i,j) = ceil(rho(i,j) * multp_rho);
            end
        end
    end
    
    
    for i = 1:cols
        for j = 1:rows
            if(theta(i,j) == 0)
                theta(i,j) = 1;
            end
        end
    end
 
    %vote
    for i=1:cols
        for j=1:rows
            if sobel(i,j) > 0
                t = theta(i,j);
                r = rho(i,j);
                hough(t,r) = hough(t,r) + 1;
            end
        end
    end

end