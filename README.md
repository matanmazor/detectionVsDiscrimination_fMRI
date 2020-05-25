# Confidence in Detection and Discrimination
fMRI project looking at the differences between perceptual detection and discrimination.


[Mazor, M., Friston, K. J., & Fleming, S. M. (2020). Distinct neural contributions to metacognition for detecting, but not discriminating visual stimuli. Elife, 9, e53900.](https://elifesciences.org/articles/53900)

## Data
1. All behavioural data from the 46 participtants is available in BIDS format in 'data/data'.
2. The analysis scripts use a data structure with all the relevant information: 'data/data_struct.mat'.
3. Anonymized imaging data is available upon request.

## Figures
All figures in the paper are fully reproducible with the above data and code.
1. Figure 1 is available here: 
![alt text][logo]
2. To generate figure 2 (behaviour), run "analysis/makeFig2".
3. To generate figures 3-5, and appendix figure 4, run "analysis/makeConfCurves". The full brain images for these plots are available on https://neurovault.org/collections/VVLPQBWK/.
4. Multivariate analysis was performed using The Decoding Toolbox on unsmoothed data (Design Matrices 101, 102, and 103). The code for running the classifications is available in "decodeConfidence.mat", "decodeConfidenceCross.mat", "decodeYN.mat" and "decodeYNcross.mat" - all available in the "analysis" folder. The results of the decoding analyses are available in the "analyzed" folder, and can be plotted using the script "analysis/plotClassification.mat".

[logo]: https://github.com/matanmazor/detectionVsDiscrimination_fMRI/blob/master/docs/experimentDesign.png "Logo Title Text 2"
