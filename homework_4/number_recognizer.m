clc;

TEST = imread("dataset/test/9_1.png");
TEST = rgb2gray(TEST);
TEST = im2bw(TEST);

%shows the Test Image
imshow(TEST);
disp("Processing...");
recognize(TEST);

%Main function recognizes the given image
function [] = recognize(target)
    %You should change it with the absolute path of your training set
    myFolder = "C:\Users\classy\Documents\MATLAB\kaganhamzacebi_151101064_hw4\dataset\training";
    trainingFiles = fullfile(myFolder, '*.bmp');
    %get directory
    training = dir(trainingFiles);
    %vectors for edit distance values and labels
    editDistanceValues = [];
    labels = [];
    
    holes = eulerNum(target);
    
    for k = 1:length(training)
      fileName = training(k).name;
      fullName = fullfile(myFolder, fileName);
      imageArray = imread(fullName);
      
      %Get The Label from file name / First Character is Label
      label = str2double(string(extractBetween(fileName, 1, 1)));
      %if hole counts is 2. Number is guaranteed 8
      if (holes == 2)
          disp("Image is: 8");
          return;
      %hole number is 1 so Number could be 0 4 6 9
      %do not make other training datas iterate
      elseif (holes == 1)
          if (label == 0 || label == 4 || label == 6 ||  label == 9)
              diff = image_comparator(imageArray, target);
              editDistanceValues(end+1) = diff;
              labels(end+1) = label;
          end
      %hole number is 0 so Number could be 1 2 3 5 7
      %do not make other training datas iterate
      else 
          if (label == 1 || label == 2 || label == 3 || label == 5 ||  label == 7)
              diff = image_comparator(imageArray, target);
              editDistanceValues(end+1) = diff;
              labels(end+1) = label;
          end
      end
    end
    
    tmpArray = editDistanceValues;
    
    %KNN 5 Nearest Neighbor
    [t1, index1] = min(editDistanceValues);
    editDistanceValues(1, index1) = realmax;
    [t2, index2] = min(editDistanceValues);
    editDistanceValues(1, index2) = realmax;
    [t3, index3] = min(editDistanceValues);
    editDistanceValues(1, index3) = realmax;
    [t4, index4] = min(editDistanceValues);
    editDistanceValues(1, index4) = realmax;
    [t5, index5] = min(editDistanceValues);
    
    
    label_1 = labels(1, index1);
    label_2 = labels(1, index2);
    label_3 = labels(1, index3);
    label_4 = labels(1, index4);
    label_5 = labels(1, index5);
   
    hist = zeros(1,10);
    hist(1, label_1+1) = hist(1, label_1+1) + 1;
    hist(1, label_2+1) = hist(1, label_2+1) + 1;
    hist(1, label_3+1) = hist(1, label_3+1) + 1;
    hist(1, label_4+1) = hist(1, label_4+1) + 1;
    hist(1, label_5+1) = hist(1, label_5+1) + 1;
    
    if (hist(1,1) >= 4)
        disp("Image is: 0"); 
    elseif (hist(1,8) >= 3)
        disp("Image is: 7"); 
    else
        for i = 1:size(tmpArray, 2)
            if (labels(1, i) == 0 || labels(1, i) == 7 || labels(1, i) == 8)
                tmpArray(1, i) = realmax;
            end
        end
        
        [v1, index1] = min(tmpArray);
        tmpArray(1, index1) = realmax;
        [v2, index2] = min(tmpArray);
        tmpArray(1, index2) = realmax;
        [v3, index3] = min(tmpArray);
        tmpArray(1, index3) = realmax;
        [v4, index4] = min(tmpArray);
        tmpArray(1, index4) = realmax;
        [v5, index5] = min(tmpArray);
        
        label_1 = labels(1, index1);
        label_2 = labels(1, index2);
        label_3 = labels(1, index3);
        label_4 = labels(1, index4);
        label_5 = labels(1, index5);
    
        hist = zeros(1,10);
        hist(1, label_1+1) = hist(1, label_1+1) + 1;
        hist(1, label_2+1) = hist(1, label_2+1) + 1;
        hist(1, label_3+1) = hist(1, label_3+1) + 1;
        hist(1, label_4+1) = hist(1, label_4+1) + 1;
        hist(1, label_5+1) = hist(1, label_5+1) + 1;
        
        [histMax_1, i1] = max(hist);
        hist(1, i1) = 0;
        [histMax_2, i2] = max(hist);
        
        if (histMax_1 == 1)
            disp("Image Couldn't be Recognized");
            return;
        end
        
        if (histMax_1 > histMax_2)
            disp("Image is: " + (i1 - 1));
        elseif (histMax_2 == histMax_1)
            if (label_1 == i1 - 1)
                disp("Image is: " + (i1 - 1));
            elseif (label_1 == i2 - 1)
                disp("Image is: " + (i2 - 1));
            elseif (label_2 == i1 - 1)
                disp("Image is: " + (i1 - 1));
            else 
                disp("Image is: " + (i2 - 1));
            end
        end
      
    end
end

%Creates a mask with boundry pixels 1
function [mask] = boundry_detection(img)
    [cols, rows] = size(img);

    img = imgDilate(img);
    mask = ones(cols, rows, 'logical');
    
    for j = 2:rows - 1
        for i = 2:cols - 1
            
            pixel = img(i, j);
            
            adj1 = img(i, j + 1);
            adj2 = img(i + 1, j);
            adj3 = img(i, j - 1);
            adj4 = img(i - 1, j);
            
            if(pixel == 0 && ...
                (adj1 == 1 || adj2 == 1 || adj3 == 1 || adj4 == 1 ))
                mask(i, j) = 0;
            end
        end
    end
end

%Compares Two images with Shape Numbers and returns Edit Distance
%difference
function [diff] = image_comparator(image_train, image_test) 
    train_edge = boundry_detection(image_train);
    test_edge = boundry_detection(image_test);
    
    sn_train = im2sn(train_edge);
    sn_test = im2sn(test_edge);
    ratio = size(sn_train, 2) / size(sn_test, 2);
    
    if ratio < 1
        processed = imresize(image_test, ratio, 'bicubic');
        processed = boundry_detection(processed);
        sn_processed = im2sn(processed);
        diff = editDistance(mat2str(sn_train), mat2str(sn_processed));

    elseif ratio > 1
        processed = imresize(image_train, 1 / ratio, 'bicubic');
        processed = boundry_detection(processed);
        sn_processed = im2sn(processed);
        diff = editDistance(mat2str(sn_test), mat2str(sn_processed));
        
    else
        diff = editDistance(mat2str(sn_train), mat2str(sn_test));
    end
    
end

%Converts Image to Shape Number
function [sn] = im2sn(img)
    [cols, rows] = size(img);

    %find first pixel
    for i = 1:cols
        for j = 1:rows
       
            %first pixel
            if (img(i,j) == 0)
                point = [i, j];
                cc = im2cc(img, point);
                fd = cc2fd(cc);
                sn = fd2sn(fd);
                return;
            end
            
        end
    end

end

%Generates Image to Chain Code
function [cc] = im2cc(img, point)  
    b0 = [point(1), point(2)];
    cc = [];
    
    while 1
        x = b0(1);
        y = b0(2);
        
        %left
        if (img(b0(1), b0(2) - 1) == 0)
            cc(end+1) = 4;
            b0(2) = b0(2) - 1;
        %left top corner
        elseif (img(b0(1) - 1, b0(2) - 1) == 0)
            cc(end+1) = 3;
            b0(1) = b0(1) - 1; 
            b0(2) = b0(2) - 1; 
        %top
        elseif (img(b0(1) - 1, b0(2)) == 0)
            cc(end+1) = 2;
            b0(1) = b0(1) - 1;
        %top right corner
        elseif (img(b0(1) - 1, b0(2) + 1) == 0)
            cc(end+1) = 1;
            b0(1) = b0(1) - 1; 
            b0(2) = b0(2) + 1;
        %right
        elseif (img(b0(1), b0(2) + 1) == 0)
            cc(end+1) = 0;
            b0(2) = b0(2) + 1;
        %right bottom corner
        elseif (img(b0(1) + 1, b0(2) + 1) == 0)
            cc(end+1) = 7;
            b0(1) = b0(1) + 1; 
            b0(2) = b0(2) + 1;
        %bottom
        elseif (img(b0(1) + 1, b0(2)) == 0)
            cc(end+1) = 6;
            b0(1) = b0(1) + 1;
        %left bottom corner
        elseif (img(b0(1) + 1, b0(2) - 1) == 0)
            cc(end+1) = 5;
            b0(1) = b0(1) + 1; 
            b0(2) = b0(2) - 1;
        else
            break;
        end
        img(x, y) = 1;

        if (b0(1) == point(1) && b0(2) == point(2))
            break;
        end
    end
end

%Converts Chain Code to First Difference
function [cc] = cc2fd(cc)
    first = cc(1);

    for i = 1:size(cc, 2) - 1
        if (cc(i) > cc(i + 1))
            cc(i) = cc(i + 1) + 8 - cc(i);
        else
            cc(i) = cc(i+1) - cc(i);
        end
    end
    
    if (cc(end) > first)
        cc(end) = first + 8 - cc(end);
    else
        cc(end) = first - cc(end);
    end
    
    cc = circshift(cc, 1);
end

%Converts First Difference to Shape Number
function [fd] = fd2sn(fd)
    smallest = realmax;
    smallestIndex = 0;
    
    for i = 1:size(fd, 2)
       %calculate magnitude
       magnitude = 0;
       for j = 1:size(fd, 2)
           magnitude = magnitude + fd(size(fd, 2) + 1 - j) * 10^j;
       end
       
       if (magnitude < smallest)
          smallest = magnitude;
          smallestIndex = i;
       end
       
       fd = circshift(fd, 1);
    end
    
    fd = circshift(fd, smallestIndex - 1);
end

%Detects connected components in an Image
function [labels] = eulerNum(img)
    %img = thresholder(img, 120);
    img = padarray(img, [1,1]);

    img = imgDilate(img);
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
    labels = labelCounter(tmp) - 1;
    
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

%Filters Image with given mask
function [tmp] = imgDilate(img)
    [cols, rows] = size(img);
    tmp = img;
    SE = [1 1 1
          1 1 1
          1 1 1];
    
    for i = 2:cols-1
        for j = 2:rows-1
            
            section = img(i-1:i+1, j-1:j+1);
            isHit = false;
            
            for a = 1:3
                for b = 1:3
                    if (SE(a,b) == 1 && section(a,b) == 0)
                        isHit = true;
                    end
                end
            end
            if (isHit)
               tmp(i,j) = 0;
            end
            
        end
    end
end