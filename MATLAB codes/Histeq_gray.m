% Read the grayscale image
image = imread('lena.png');
image = rgb2gray(image); 

% Get the size of the image
[rows, cols] = size(image);

% Step 1: Calculate the histogram
L = 256; % Number of intensity levels for an 8-bit image
histogram = zeros(1, L);
for i = 1:rows
    for j = 1:cols
        intensity = image(i, j);
        histogram(intensity + 1) = histogram(intensity + 1) + 1;
    end
end

% Step 2: Normalize the histogram (PDF)
total_pixels = rows * cols;
pdf = histogram / total_pixels;

% Step 3: Compute the CDF
cdf = zeros(1, L);
cdf(1) = pdf(1);
for k = 2:L
    cdf(k) = cdf(k - 1) + pdf(k);
end

% Step 4: Create the transformation function
transformation = round((L - 1) * cdf);

% Step 5: Apply the transformation to the original image
equalized_image = zeros(rows, cols, 'uint8');
for i = 1:rows
    for j = 1:cols
        equalized_image(i, j) = transformation(image(i, j) + 1);
    end
end

% Display the results
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('Equalized greyscale image');
