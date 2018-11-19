
<!-- README.md is generated from README.Rmd. Please edit that file -->
ghcn
====

Tools for working with Global Historical Climatology Network (GHCN) data.

Examples
--------

Read all daily data for one station:

``` r
library(ghcn)

file1 <- "https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/all/AG000060390.dly"
dat <- read_dly(file1)
print(dat, n_extra = 10)
#> # A tibble: 3,512 x 128
#>    id     year month element value1 mflag1 qflag1 sflag1 value2 mflag2
#>    <chr> <int> <int> <chr>    <int> <chr>  <chr>  <chr>   <int> <chr> 
#>  1 AG00~  1940     1 TMAX       224 <NA>   <NA>   E         202 <NA>  
#>  2 AG00~  1940     1 TMIN        47 <NA>   <NA>   E          88 <NA>  
#>  3 AG00~  1940     1 PRCP         0 <NA>   <NA>   E           0 <NA>  
#>  4 AG00~  1940     2 TMAX       205 <NA>   <NA>   E         165 <NA>  
#>  5 AG00~  1940     2 TMIN       100 <NA>   <NA>   E         113 <NA>  
#>  6 AG00~  1940     2 PRCP        32 <NA>   <NA>   E          89 <NA>  
#>  7 AG00~  1940     3 TMAX       270 <NA>   <NA>   E         206 <NA>  
#>  8 AG00~  1940     3 TMIN       186 <NA>   <NA>   E          73 <NA>  
#>  9 AG00~  1940     3 PRCP         0 <NA>   <NA>   E           0 <NA>  
#> 10 AG00~  1940     4 TMAX       176 <NA>   <NA>   E         200 <NA>  
#> # ... with 3,502 more rows, and 118 more variables: qflag2 <chr>,
#> #   sflag2 <chr>, value3 <int>, mflag3 <chr>, qflag3 <chr>, sflag3 <chr>,
#> #   value4 <int>, mflag4 <chr>, qflag4 <chr>, sflag4 <chr>, ...
```

Transform the data into an easier to use format:

``` r
clean_dly(dat)
#> # A tibble: 28,824 x 6
#>    id          date        prcp  snwd  tmax  tmin
#>    <chr>       <date>     <dbl> <dbl> <dbl> <dbl>
#>  1 AG000060390 1940-01-01   0      NA  22.4   4.7
#>  2 AG000060390 1940-01-02   0      NA  20.2   8.8
#>  3 AG000060390 1940-01-03   1.8    NA  21    11  
#>  4 AG000060390 1940-01-04  18.5    NA  19.1   9.8
#>  5 AG000060390 1940-01-05  NA      NA  17.5  10  
#>  6 AG000060390 1940-01-06  NA      NA  17.3  12  
#>  7 AG000060390 1940-01-07   0      NA  17.2   8.5
#>  8 AG000060390 1940-01-08   2      NA  20.8   6  
#>  9 AG000060390 1940-01-09  30.4    NA  13.8   9.6
#> 10 AG000060390 1940-01-10  20.5    NA  13.6   7.2
#> # ... with 28,814 more rows
```

Data source
-----------

NOAA [GHCN](https://www.ncdc.noaa.gov/ghcn-daily-description).
