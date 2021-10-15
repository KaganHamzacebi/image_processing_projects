clc;
img1 = imread('images/icon.png');
img2 = imread('images/dt_image2.png');
img3 = imread('images/gray_image.jpg');

img1 = thresholder(img1, 127);
img2 = thresholder(img2, 127);
img3 = thresholder(img3, 127);

%{
Hocam bu kısımda boundry_detection ve adjacency_detection fonksiyonları
ortak çalışmaktadır. Eğer mask'i ayrı test etmek isterseniz imshow(mask)
kullanarak ve 77. satırı mask(i, j) = 255; yaparak test edebilirsiniz.
%}

%Diğer imageları test etmek isterseniz 22-25 (img2) veya 27-30 satırlarını
%uncomment yaparak test edebilirsiniz.

%{
mask = boundry_detection(img1);
distance_map = adjacency_detection(mask);
%}

%normalize intensities of distance_map
[d_cols, d_rows] = size(distance_map);
out = normalize(distance_map, 'range') * 255;
out = cast(out, 'uint8');

imshow(out);

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

%Creates a mask with boundry pixels 1
function [mask] = boundry_detection(img)
    [cols, rows] = size(img);
    mask = zeros(cols, rows);
    mask = cast(mask, 'uint8');
    
    for j = 2:rows - 1
        for i = 2:cols - 1
            
            pixel = img(i, j);
            
            adj1 = img(i, j + 1);
            adj2 = img(i + 1, j + 1);
            adj3 = img(i + 1, j);
            adj4 = img(i + 1, j - 1);
            adj5 = img(i, j - 1);
            adj6 = img(i - 1, j - 1);
            adj7 = img(i - 1, j);
            adj8 = img(i - 1, j + 1);
            
            if(pixel == 255 && ...
                (adj1 == 0 || adj2 == 0 || adj3 == 0 || adj4 == 0 || ...
                adj5 == 0 || adj6 == 0 || adj7 == 0 || adj8 == 0 ))
                
                mask(i, j) = 1;
            end
        end
    end
end

%Distance Transform Function
function [mask_in] = adjacency_detection(mask_in)
    [cols, rows] = size(mask_in);
   
    iteration = 1;
    while iteration < 1500
        
        for j = 2:rows - 1
            for i = 2:cols - 1
                
                pixel = mask_in(i, j);
                
                if(pixel == iteration)
                    mask_in(i, j) = iteration;
                    
                    adj1 = mask_in(i, j + 1);
                    adj2 = mask_in(i + 1, j + 1);
                    adj3 = mask_in(i + 1, j);
                    adj4 = mask_in(i + 1, j - 1);
                    adj5 = mask_in(i, j - 1);
                    adj6 = mask_in(i - 1, j - 1);
                    adj7 = mask_in(i - 1, j);
                    adj8 = mask_in(i - 1, j + 1);
                    
                    if(adj1 == 0)
                        mask_in(i, j + 1) = iteration + 1;
                    end
                    if(adj2 == 0)
                        mask_in(i + 1, j + 1) = iteration + 1;
                    end
                    if(adj3 == 0)
                        mask_in(i + 1, j) = iteration + 1;
                    end
                    if(adj4 == 0)
                        mask_in(i + 1, j - 1) = iteration + 1;
                    end
                    if(adj5 == 0)
                        mask_in(i, j - 1) = iteration + 1;
                    end
                    if(adj6 == 0)
                        mask_in(i - 1, j - 1) = iteration + 1;
                    end
                    if(adj7 == 0)
                        mask_in(i - 1, j) = iteration + 1;
                    end
                    if(adj8 == 0)
                        mask_in(i - 1, j + 1) = iteration + 1;
                    end
                end
            end
        end
        iteration = iteration + 1;
    end
end