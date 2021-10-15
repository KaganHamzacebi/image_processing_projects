clc;
%Questions 1 - 2 - 3
img7 = imread("inputs/para.jpg");
img2 = imread("coins.png");
img3 = imread("moon.tif");
img4 = imread("inputs/gray_image.jpg");

img = imread("inputs/shape.png");
img5 = imread("inputs/tetris2.png");

TEST = imread("8.png");
TEST = rgb2gray(TEST);
TEST = im2bw(TEST);

%{
    To test Functions comment out lines;
        FOR QUESTION 
            1: 14 - 15
            2: 22 - 23
            3: 29
%}

%Detects corner of objects in given image - Question 1
%{
img = cornerDetection(img);
imshow(img);
%}

%Generates Convex Hull of all objects - Question 2
%{
img = convexHull(img);
imshow(img);
%}

%Generated string output with detected objects in image - Question 3
TEST = connectedComponents(TEST);
TEST

%Sets pixel brightness to 0 below threshold or 255 above threshold
function [img] = thresholder(img, threshold)
    [cols, rows] = size(img);

    for i = 1:cols
        for j = 1:rows
            if (img(i,j) < threshold) 
                img(i,j) = 255;
            elseif (img(i,j) >= threshold)
                img(i,j) = 0;
            end
        end
    end
end

%Detects Corners in a Grayscale Image
function [corners] = cornerDetection(img)
    %Corner Detector Kernels / X refers to dont care
    m1 = ['X', 1, 'X'
            0, 1, 1
            0, 0, 'X'];
      
    m2 = ['X', 1, 'X'
            1, 1, 0
          'X', 0, 0];
      
    m3 = ['X', 0, 0
            1, 1, 0
          'X', 1, 'X'];
      
    m4 = [0, 0, 'X'
          0, 1, 1
        'X', 1, 'X'];
    
    [cols, rows] = size(img);
    padSize = 1;
    
    img = thresholder(img, 120);
    
    %zero padding img
    padImg = zeros(cols + padSize * 2, rows + padSize * 2);
    corners = zeros(cols, rows, 'uint8');
    [padCols, padRows] = size(padImg);
    
    for i = 1 + padSize: padCols - padSize
        for j = 1 + padSize: padRows - padSize
            padImg(i,j) = img(i - padSize, j - padSize);
        end
    end
    
    for i = 1:cols
        for j = 1:rows
            
            m1Hit = true;
            m2Hit = true;
            m3Hit = true;
            m4Hit = true;
            
            %masks
            for m = 1:4
                
                PixelX = i;
                PixelY = j;
                
                %mask iteration
                for a = 1:3
                    for b = 1:3
                        switch m
                            case 1
                                if ((m1(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                    (m1(a,b) == 0 && padImg(PixelX, PixelY) ~= 0)
                                    m1Hit = false;
                                end
                            case 2
                                if ((m2(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                    (m2(a,b) == 0 && padImg(PixelX, PixelY) ~= 0)
                                    m2Hit = false;
                                end
                            case 3
                                if ((m3(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                    (m3(a,b) == 0 && padImg(PixelX, PixelY) ~= 0)
                                    m3Hit = false;
                                end
                            case 4
                                if ((m4(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                    (m4(a,b) == 0 && padImg(PixelX, PixelY) ~= 0)
                                    m4Hit = false;
                                end
                        end
                        PixelX = PixelX + 1;
                    end
                    PixelX = i;
                    PixelY = PixelY + 1;
                end 
            end
            if (m1Hit || m2Hit || m3Hit || m4Hit)
                corners(i,j) = 255;
            end
        end
    end
end

%Creates Convex Hulls of all objects in an Image
function [img] = convexHull(img) 
    img = thresholder(img, 120);
    
    %Convex Hull Kernels / X refers to dont care
    m1 = [1, 'X', 'X'
          1, 0, 'X'
          1, 'X', 'X'];
      
    m2 = [1, 1, 1
        'X', 0, 'X'
        'X', 'X', 'X'];
      
    m3 = ['X', 'X', 1
          'X', 0, 1
          'X', 'X', 1];
      
    m4 = ['X', 'X', 'X'
          'X', 0, 'X'
            1, 1, 1];
        
        
    [cols, rows] = size(img);
    padSize = 1;
    
    %zero padding img
    padImg = zeros(cols + padSize * 2, rows + padSize * 2);
    [padCols, padRows] = size(padImg);
    
    for i = 1 + padSize: padCols - padSize
        for j = 1 + padSize: padRows - padSize
            padImg(i,j) = img(i - padSize, j - padSize);
        end
    end
    
    for m = 1:4
        isDone = false;
        while ~isDone
            isDone = true;
            
            %move mask on all pixels
            for i = 1:cols
                for j = 1:rows
                    
                    isHit = true;
                    PixelX = i;
                    PixelY = j;

                    %mask iteration
                    for a = 1:3
                        for b = 1:3
                            switch m
                                case 1
                                    if (((m1(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                         (m1(a,b) == 0 && padImg(PixelX, PixelY) ~= 0))
                                         isHit = false;
                                    end
                                case 2
                                    if (((m2(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                         (m2(a,b) == 0 && padImg(PixelX, PixelY) ~= 0))
                                        isHit = false;
                                    end
                                case 3
                                    if (((m3(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                         (m3(a,b) == 0 && padImg(PixelX, PixelY) ~= 0))
                                        isHit = false;
                                    end
                                case 4
                                    if (((m4(a,b) == 1 && padImg(PixelX, PixelY) ~= 255)) ||...
                                         (m4(a,b) == 0 && padImg(PixelX, PixelY) ~= 0))
                                         isHit = false;
                                    end
                            end
                            PixelX = PixelX + 1;
                        end
                        PixelX = i;
                        PixelY = PixelY + 1;
                    end
                    %if something added keep iterating or go next mask
                    if(isHit)
                        img(i,j) = 255;
                        padImg(i + 1, j + 1) = 255;
                        isDone = false;
                    end

                end
            end
        end
    end
    
end

%Detects connected components in an Image
function [labels] = connectedComponents(img)
    %img = thresholder(img, 120);
    img = padarray(img, [1,1]);
    SE = [1 1 1
      1 1 1
      1 1 1];
      
    img = ~imdilate(~img, SE);
    [cols, rows] = size(img);
    label = 1;
    
    tmp = ones(size(img, 1), size(img, 2), 'uint8');

    for i = 2:cols-1
        for j = 2:rows-1
           
            if (img(i,j) == 1)
                
                [img, tmp] = labelObj(img, [i, j],tmp, label);
                label = label + 1;

            end

        end
    end
    labels = labelCounter(tmp);
    
end

%Iterate object with a given pixel point of the object
function [img, tmp] = labelObj(img, point, tmp, label)
    %Box Kernel
    mask = [1, 1, 1
            1, 1, 1
            1, 1, 1];

    pX = point(1); pY = point(2);
    nX = [pX]; nY = [pY];
    
    while size(nX, 2) > 0
        %initialize first point
        PixelX = nX(1);
        PixelY = nY(1);
        
        section = img(PixelX - 1:PixelX + 1,PixelY - 1:PixelY + 1);
        [mx, my] = size(section);

        %find neighbors
        for i = 1:mx
            for j = 1:my

                PointX = PixelX + (i - 2);
                PointY = PixelY + (j - 2);

                if ((mask(i,j) == 1 && section(i,j) == 1) &&...
                     ~isIncludes(PointX, PointY, nX, nY))
                    nX(end+1) = PointX;
                    nY(end+1) = PointY;
                end
            end
        end

        img(PixelX, PixelY) = 0;
        tmp(PixelX, PixelY) = label;
        nX = nX(2:end);
        nY = nY(2:end);
        
    end

end

%A basic includes method for multi array structure
function [isInc] = isIncludes(x, y, arrX, arrY)
    isInc = false;
    
    [x1, y1] = size(arrX);
    
    for i = 1:x1
        for j = 1:y1
            if (x == arrX(i,j) && y == arrY(i,j))
                isInc = true;
            end
        end
    end
end

%Generates Output for Connected Component
function [labels] = labelCounter(img)
    [cols, rows] = size(img);
    counts = zeros(1, max(img, [], 'all'));
    
    for i = 1:cols
        for j = 1:rows
            
            if(img(i,j) ~= 0)
                counts(img(i,j)) = counts(img(i,j)) + 1;
            end
                
        end
    end
    labels = size(counts, 2);
end

