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

- \( r<sub>k</sub> \) is the intensity value k (for grayscale images, k is between 0 and 255).

<br/><br/>

## 2. Compute the Cumulative Distribution Function (CDF)

Next, we compute the cumulative distribution function of the histogram to get a mapping function for pixel intensity values.

### Formula:

$$
CDF(r_k) = Σ\ H(r_i)\ for\ i = 0\ to\ k
$$

Where:

- CDF(r<sub>k</sub>) \) is the cumulative sum of the histogram values from intensity 0 to k.

<br/><br/>

## 3. Normalize the CDF

To map the intensity values to the full range of the image (0 to 255), normalize the CDF.

### Formula:

$$
CDF'(r_k) = \frac{CDF(r_k) - CDF_{min}}{N - CDF_{min}} \cdot (L - 1)
$$

Where:

- CDF<sub>min</sub> is the minimum value of the CDF,
- N is the total number of pixels in the image,
- L is the number of intensity levels (for 8-bit images, \( L = 256 \)).

<br/><br/>

## 4. Map the Intensities

Finally, use the normalized CDF to map the original pixel intensities to the new enhanced intensities.

### Formula:

$$
r_k' = round(CDF'(r_k))
$$

Where:

- r<sub>k</sub>' is the new intensity value for each original intensity r<sub>k</sub>.

