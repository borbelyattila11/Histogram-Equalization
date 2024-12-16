# Histogram Equalization

Histogram equalization is a technique used in image processing to improve the contrast of an image by redistributing the intensity values of pixels. The goal is to enhance the image's overall contrast, especially in areas with low contrast, by stretching the range of intensity levels.

<br/><br/>

## 1. Compute the Histogram

The first step is to compute the histogram of the image, which represents the frequency of each pixel intensity.

### Formula:

$$
H(r_k) = number\ of\ pixels\ with\ intensity\ r_k
$$

Where:

- r<sub>k</sub>  is the intensity value k (for grayscale images, k is between 0 and 255).

<br/><br/>

## 2. Compute the Probability Density Function (PDF)

To normalize the histogram, compute the Probability Density Function (PDF), which represents the relative frequency of each intensity.

### Formula:

$$
PDF(r_k) = \frac{H(r_k)}{N}
$$

Where:

- H(r<sub>k</sub>) is the histogram value for intensity r<sub>k</sub>,
- N is the total number of pixels in the image.

<br/><br/>

## 3. Compute the Cumulative Distribution Function (CDF)

Next, compute the cumulative distribution function of the histogram.

### Formula:

$$
CDF(r_k) = \sum_{i=0}^{k} PDF(r_i)
$$

Where:

- CDF(r<sub>k</sub>) is the cumulative sum of the PDF values from intensity 0 to k.

<br/><br/>

## 4. Map the Intensities

Use the CDF to map the original pixel intensities to the new enhanced intensities. The mapping scales the normalized CDF to the range [0, L-1], where L = 256 for 8-bit images.

### Formula:

$$
r_k' = round(CDF(r_k) \cdot (L - 1))
$$

Where:

- r<sub>k</sub>' is the new intensity value for each original intensity \( r<sub>k</sub> \),
- L is the number of intensity levels (for 8-bit images, L = 256).

Each pixel intensity in the input image is replaced using the transformation function

$$
T(r_k​)=round(CDF(r_k​)⋅(L−1))
$$

which is derived from the CDF.
