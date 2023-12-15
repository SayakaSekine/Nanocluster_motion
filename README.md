This code is used in Sekine et al., "Emergence of periodic circumferential actin cables from the anisotropic fusion of actin nanoclusters during tubulogenesis."
This code is written by Mustafa M. Sami.

In the study, the motility of the small actin nanocluster was measured using this code written in Matlab. 
Briefly, after binarization of the images, an actin cluster within the size range 0.01 to 0.1 µm2 and circularity 0.5 – 1.0 was selected 
at tn, then in the next frame (tn+1), an actin cluster with a similar size (between 0.5 to 2 fold of the size at tn) and similar position 
(at least overlapped 1 pixel with the cluster at tn) was assumed as the same cluster which moved during the single time frame. 
By comparing the coordinates of the center of masses between tn and tn+1, the displacement Δx and Δy were calculated.
