clc;

I1 = imread("inputs/big/big2.jpg");
I2 = imread("inputs/small/small2.jpg");

I2 = imresize(I2, [size(I1, 1), size(I1, 2)], 'bicubic');

figure, imshow(I2);
figure, imshow(I1);
[x_p, y_p] = ginput(4);
close all;

%X and Y prime indexes (I2);
%Order --> Left Top / Right Top / Left Bottom / Right Bottom
x = [1 1 size(I2, 1) size(I2, 1)];
y = [1 size(I2, 2) 1 size(I2, 2)];

%Homography Matrix Calculation
 M = [x(1) y(1) 1 0 0 0 -x(1)*x_p(1) -y(1)*x_p(1)
      0 0 0 x(1) y(1) 1 -x(1)*y_p(1) -y(1)*y_p(1)
      x(2) y(2) 1 0 0 0 -x(2)*x_p(2) -y(2)*x_p(2)
      0 0 0 x(2) y(2) 1 -x(2)*y_p(2) -y(2)*y_p(2)
      x(3) y(3) 1 0 0 0 -x(3)*x_p(3) -y(3)*x_p(3)
      0 0 0 x(3) y(3) 1 -x(3)*y_p(3) -y(3)*y_p(3)
      x(4) y(4) 1 0 0 0 -x(4)*x_p(4) -y(4)*x_p(4)
      0 0 0 x(4) y(4) 1 -x(4)*y_p(4) -y(4)*y_p(4)];

 h = zeros(8,1);
 
 b = [x_p(1)
      y_p(1)
      x_p(2)
      y_p(2)
      x_p(3)
      y_p(3)
      x_p(4)
      y_p(4)];
  
  d = det(M);
  
  %if matrix is singular
  if (d == 0)
      [U, S, V] = svd(M);
  %if matrix is non-singular
  else
      h = M \ b;
  end
  
  %Composs Image
  for i = 1:size(I2, 1)
      for j = 1:size(I2, 2)
          x_n = (h(1) * i + h(2) * j + h(3)) / (h(7) * i + h(8) * j + 1);
          y_n = (h(4) * i + h(5) * j + h(6)) / (h(7) * i + h(8) * j + 1);
          
          x_n = ceil(x_n);
          y_n = ceil(y_n);
          
          I1(y_n, x_n, :) = I2(i, j, :);
      end
  end
  
  imshow(I1);