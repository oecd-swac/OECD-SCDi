# Code
This directory contains the code used to calculate the Spatial Conflict Dynamics indicator (SCDi). It can be readily adapted to categorize any kind of point data within the SCDi types of clustered high-intensity, dispersed high-intensity, clustered low-intensity and dispersed low-intensity.

The main function defined in this R script take in the user's point data and a set of polygons, which can either be user-defined or a fishnet grid produced in this script. The function outputs the polygons with information about the intensity and clustering of the point pattern in each polygon.

This script also includes a function to perform this analysis over a user-defined set of  time intervals.

Sections that need to be edited by the user are marked with the text "(CHANGE ME)" in comments.

## Spatial Conflict Dynamics indicator - SCDi

__maintainer__ = [SWAC OECD](https://www.oecd.org/swac/)

__Corresponding author__ = [Dr. Olivier Walther](https://geog.ufl.edu/faculty/walther/), owalther@ufl.edu, University of Florida

The Spatial Conflict Dynamics indicator (SCDi) maps the temporal and spatial evolution of political 
violence in North and West Africa since 1997. The SCDi divides the region into 6,540 cells 
(each cell is 50 by 50 kilometres) and leverages over 57,000 violent events from the 
[Armed Conflict Location & Event Data Project (ACLED)](https://acleddata.com/data-export-tool/) 
across 21 countries. It is possible to classify conflict types by their intensity, 
which measures the amount of violence, and concentration which assesses 
how violent events are distributed spatially across a region.

The SCDi identifies four types of conflict: clustered high-intensity, 
dispersed high-intensity, clustered low-intensity and dispersed low-intensity.

The SCDi was developed by the Sahel and West Africa Club (SWAC/OECD) 
in co-operation with the University of Florida’s [Sahel Research Group](https://sahelresearch.africa.ufl.edu).


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
