# Data

__maintainer__ = [SWAC OECD](https://www.oecd.org/swac/)

__Corresponding author__ = [Dr. Olivier Walther](https://geog.ufl.edu/faculty/walther/), owalther@ufl.edu, University of Florida

This directory contains the outputs of the SCDi calculated in the West Africa region for the years 1997 to 2022. 

If you use these datasets in your work, please cite the dataset as indicated below.


### The SCDi

The SCDi was developed by the Sahel and West Africa Club (SWAC/OECD) in co-operation with the University of Florida’s Sahel Research Group.

The SCDi maps the temporal and spatial evolution of political violence in North and West Africa since 1997. The SCDi divides the region into 6,540 cells (each cell is 50 by 50 kilometres) and leverages over 57,000 violent events from the [Armed Conflict Location & Event Data Project (ACLED)](https://acleddata.com/data-export-tool/) across 21 countries. It is possible to classify conflict types by their intensity, which measures the amount of violence, and concentration which assesses how violent events are distributed spatially across a region.

The SCDi identifies four types of conflict: clustered high-intensity, dispersed high-intensity, clustered low-intensity and dispersed low-intensity.

### Output data structure

* The shapefile geometry corresponds to one polygon for each of the 6,540 50km by 50km cells of the fishnet grid.
* The shapfile attribute data is structured like this:
  * The usual shapefile columns with a unique ID, shape length, and area
  * 7 columns for each year (from 1997 - 2022). As follows, using 1997 as an example:
    * eventCount1997: the number of ACLED events in that cell in 1997
    * fatalities1997: the number of fatalities in the cell in 1997 (from ACLED data)
    * Density1997: the density of ACLED events in the cell in 1997
    * NN_Index1997: the Average Nearest Neighbor index for the cell's 1997 ACLED event points in space
    * den_class1997: whether the cell's point density in 1997 was high or low
    * NN_class1997: whether the ANNi for that cell's points in 1997 was clustered or dispersed
    * SCDI1997: the SCDi classification for that cell in 1997 (the concatenation of the den_class1997 and NN_class1997 columns)
  * A "countries" column listing the countries that the cell touches

## Citation
Olivier J. Walther, Steven M. Radil, David G. Russell & Marie Trémolières (2023)
Introducing the Spatial Conflict Dynamics Indicator of Political Violence,
Terrorism and Political Violence 35 (3): 533-552. DOI: 10.1080/09546553.2021.1957846

## Bibtex

```tex
@article{doi:10.1080/09546553.2021.1957846,
  author = {Olivier J. Walther and Steven M. Radil and David G. Russell and Marie Trémolières},
  title = {Introducing the Spatial Conflict Dynamics Indicator of Political Violence},
  journal = {Terrorism and Political Violence},
  volume = {35},
  number = {3},
  pages = {533-552},
  year  = {2023},
  publisher = {Routledge},
  doi = {10.1080/09546553.2021.1957846},
  URL = {https://doi.org/10.1080/09546553.2021.1957846},
  eprint = {https://doi.org/10.1080/09546553.2021.1957846}
}
```
