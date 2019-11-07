# Confidence in Detection and Discrimination
fMRI project looking at the differences between perceptual detection and discrimination.

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


[logo]: https://github.com/matanmazor/detectionVsDiscrimination_fMRI/blob/master/docs/experimentDesign.png "Logo Title Text 2"
