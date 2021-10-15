clc;
%get image
img = imread('images/rgb_image.jpg');

%8, 9 ve 10. satırlardan test etmek istediğinizi uncomment yaparak test
%edebilirsiniz. Default nearestNeigbor

img = nearestNeighborRGB(img, 2);
%img = bilinearRGB(img, 2);
%img = bicubicRGB(img, 2);

imshow(img);

%Nearest Neighbor Interpolation Function
function [tmp] = nearestNeighborRGB(img, ratio)
    [cols, rows] = size(img);
    w = floor(cols * ratio);
    h = floor((rows / 3) * ratio);
    tmp = zeros(w, h, 3, 'uint8');
    
    for j = 1:h
        for i = 1:w
           
            x = round(i / ratio);
            y = round(j / ratio);
            
            x(x < 1) = 1;
            x(x > cols - 1) = cols - 1;
            y(y < 1) = 1;
            y(y > rows - 1) = rows - 1;  
            
            R = img(x, y, 1);
            G = img(x, y, 2);
            B = img(x, y, 3);
            
            tmp(i , j, 1) = R;
            tmp(i , j, 2) = G;
            tmp(i , j, 3) = B;
        end
    end
end

%Bilinear Interpolation Function
function [tmp] = bilinearRGB(img, ratio)
    [cols, rows] = size(img);
    w = floor(cols * ratio);
    h = floor((rows / 3) * ratio);
    tmp = zeros(w, h, 3, 'uint8');

    for j = 1:h
        for i = 1:w
            
            x_raw = i / ratio;
            y_raw = j / ratio;
            
            x = floor(x_raw);
            y = floor(y_raw);
            
            D_X1 = 1 - (x_raw - x);
            D_X2 = 1 - (x + 1 - x_raw);
            D_Y1 = 1 - (y_raw - y);
            D_Y2 = 1 - (y + 1 - y_raw);
            
            D_X1(D_X1 == 0) = 0.1;
            D_X2(D_X2 == 0) = 0.1;
            D_Y1(D_Y1 == 0) = 0.1;
            D_Y2(D_Y2 == 0) = 0.1;
            
            x(x < 1) = 1;
            x(x > cols - 1) = cols - 1;
            y(y < 1) = 1;
            y(y > (rows / 3) - 1) = (rows / 3) - 1;
            
            %Loop for getting RBG values
            for k = 1:3
                
                %4 Neighbor Pixels
                P1 = img(x, y, k);
                P2 = img(x, y + 1, k);
                P3 = img(x + 1, y, k);
                P4 = img(x + 1, y + 1, k);

                %Distances
                D1 = D_X1 * D_Y1;
                D2 = D_X1 * D_Y2;
                D3 = D_X2 * D_Y1;
                D4 = D_X2 * D_Y2; 

                intensity = double(P1) * D1 + ...
                            double(P2) * D2 + ...
                            double(P3) * D3 + ...
                            double(P4) * D4;

                tmp(i, j, k) = intensity;
                
            end
        end
    end
end

%Bicubic Interpolation Function
function [tmp] = bicubicRGB(img, ratio)
    [cols, rows] = size(img);
    w = floor(cols * ratio);
    h = floor((rows / 3) * ratio);
    tmp = zeros(w, h, 3, 'uint8');

    for j = 1:h
        for i = 1:w
            
            x_raw = i / ratio;
            y_raw = j / ratio;
            
            x = floor(x_raw);
            y = floor(y_raw);
            
            D_X1 = (2 - (x_raw - x)) / 2;
            D_X2 = (2 - (x + 1 - x_raw)) / 2;
            D_X3 = (2 - (x + 2 - x_raw)) / 2;
            D_X4 = (2 - (x_raw - (x - 1))) / 2;
            
            D_Y1 = (2 - (y_raw - y)) / 2;
            D_Y2 = (2 - (y + 1 - y_raw)) / 2;
            D_Y3 = (2 - (y + 2 - y_raw)) / 2;
            D_Y4 = (2 - (y_raw - (y - 1))) / 2;
            
            D_X1(D_X1 == 0) = 0.1;
            D_X2(D_X2 == 0) = 0.1;
            D_X3(D_X3 == 0) = 0.1;
            D_X4(D_X4 == 0) = 0.1;
            D_Y1(D_Y1 == 0) = 0.1;
            D_Y2(D_Y2 == 0) = 0.1;
            D_Y3(D_Y3 == 0) = 0.1;
            D_Y4(D_Y4 == 0) = 0.1;
            
            x(x < 2) = 2;
            x(x > cols - 2) = cols - 2;
            y(y < 2) = 2;
            y(y > (rows / 3) - 2) = (rows / 3) - 2;
            
            %Loop for getting RBG values
            for k = 1:3
            
                %4 Neighbor Pixels
                %inner rectangle
                P1 = img(x, y, k);
                P2 = img(x, y + 1, k);
                P3 = img(x + 1, y, k);
                P4 = img(x + 1, y + 1, k);
                %outer rectangle
                P5 = img(x - 1, y + 2, k);
                P6 = img(x, y + 2, k);
                P7 = img(x + 1, y + 2, k);
                P8 = img(x + 2, y + 2, k);
                P9 = img(x + 2, y + 1, k);
                P10 = img(x + 2, y, k);
                P11 = img(x + 2, y - 1, k);
                P12 = img(x + 1, y - 1, k);
                P13 = img(x, y - 1, k);
                P14 = img(x - 1, y - 1, k);
                P15 = img(x - 1, y, k);
                P16 = img(x - 1, y + 1, k);

                %Distances
                D1 = (D_X1 * D_Y1) / 4;
                D2 = (D_X1 * D_Y2) / 4;
                D3 = (D_X2 * D_Y1) / 4;
                D4 = (D_X2 * D_Y2) / 4;

                D5 = (D_X4 * D_Y3) / 4;
                D6 = (D_X1 * D_Y3) / 4;
                D7 = (D_X2 * D_Y3) / 4;
                D8 = (D_X3 * D_Y3) / 4; 
                D9 = (D_X3 * D_Y2) / 4;
                D10 = (D_X3 * D_Y1) / 4;
                D11 = (D_X3 * D_Y4) / 4;
                D12 = (D_X2 * D_Y4) / 4; 
                D13 = (D_X1 * D_Y4) / 4;
                D14 = (D_X4 * D_Y4) / 4;
                D15 = (D_X4 * D_Y1) / 4;
                D16 = (D_X4 * D_Y2) / 4; 

                intensity = double(P1) * D1 + ...
                            double(P2) * D2 + ...
                            double(P3) * D3 + ...
                            double(P4) * D4 + ...
                            double(P5) * D5 + ...
                            double(P6) * D6 + ...
                            double(P7) * D7 + ...
                            double(P8) * D8 + ...
                            double(P9) * D9 + ...
                            double(P10) * D10 + ...
                            double(P11) * D11 + ...
                            double(P12) * D12 + ...
                            double(P13) * D13 + ...
                            double(P14) * D14 + ...
                            double(P15) * D15 + ...
                            double(P16) * D16;

                tmp(i, j, k) = intensity;
            end
        end
    end
end