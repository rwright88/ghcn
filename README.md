
<!-- README.md is generated from README.Rmd. Please edit that file -->
ghcn
====

Tools for working with Global Historical Climatology Network (GHCN) data.

Examples
--------

Find a station based on a matching pattern:

``` r
library(ghcn)

stations <- ghcn_find_stations(pattern = "new york")
stations[1:6]
```

    #> # A tibble: 17 x 6
    #>    id          latitude longitude elevation state name                     
    #>    <chr>          <dbl>     <dbl>     <dbl> <chr> <chr>                    
    #>  1 USC00215902     46.5     -95.4     428.  MN    NEW YORK MILLS           
    #>  2 USC00305798     40.6     -74.0       6.1 NY    NEW YORK BENSONHURST     
    #>  3 USC00305799     40.9     -73.9      27.1 NY    NEW YORK BOTANICAL GRD   
    #>  4 USC00305804     40.7     -73.9       3   NY    NEW YORK LAUREL HILL     
    #>  5 USC00305806     40.8     -73.9      54.9 NY    NEW YORK UNIV ST         
    #>  6 USC00305816     40.7     -74.0       3   NY    NEW YORK WB CITY         
    #>  7 USC00308721     40.9     -72.9       7.9 NY    UPTON COOP - NWSFO NEW Y~
    #>  8 USR0000NGAN     42.1     -77.1     335.  NY    GANG MILLS NEW YORK      
    #>  9 USR0000NSAR     43.0     -73.7     114.  NY    SARA NEW YORK            
    #> 10 USR0000NSCH     43.8     -73.7     250.  NY    SCHROON LAKE NEW YORK    
    #> 11 USR0000NSHR     42.7     -75.5     335.  NY    SHERBURNE NEW YORK       
    #> 12 USR0000NSTO     41.5     -73.9      61   NY    STONYKILL NEW YORK       
    #> 13 USW00014732     40.8     -73.9       3.4 NY    NEW YORK LAGUARDIA AP    
    #> 14 USW00014786     40.6     -73.9       4.9 NY    NEW YORK FLOYD BENNETT F~
    #> 15 USW00093732     39.8     -72.7      25.9 NY    NEW YORK SHOALS AFS      
    #> 16 USW00094728     40.8     -74.0      39.6 NY    NEW YORK CNTRL PK TWR    
    #> 17 USW00094789     40.6     -73.8       3.4 NY    NEW YORK JFK INTL AP

Read all daily data for one station, given the station ID:

``` r
dat <- ghcn_read(id = "USW00094728")
dat[1:8]
```

    #> # A tibble: 15,006 x 8
    #>    id           year month element value1 mflag1 qflag1 sflag1
    #>    <chr>       <int> <int> <chr>    <int> <chr>  <chr>  <chr> 
    #>  1 USW00094728  1869     1 TMAX       -17 <NA>   <NA>   Z     
    #>  2 USW00094728  1869     1 TMIN       -72 <NA>   <NA>   Z     
    #>  3 USW00094728  1869     1 PRCP       191 <NA>   <NA>   Z     
    #>  4 USW00094728  1869     1 SNOW       229 <NA>   <NA>   Z     
    #>  5 USW00094728  1869     2 TMAX         6 <NA>   <NA>   Z     
    #>  6 USW00094728  1869     2 TMIN       -39 <NA>   <NA>   Z     
    #>  7 USW00094728  1869     2 PRCP         0 <NA>   <NA>   Z     
    #>  8 USW00094728  1869     2 SNOW         0 <NA>   <NA>   Z     
    #>  9 USW00094728  1869     3 TMAX       -33 <NA>   <NA>   Z     
    #> 10 USW00094728  1869     3 TMIN      -156 <NA>   <NA>   Z     
    #> # ... with 14,996 more rows

Transform the data into an easier to use format:

``` r
ghcn_clean(dat)
```

    #> # A tibble: 54,906 x 7
    #>    id          date        prcp  snow  snwd  tmax  tmin
    #>    <chr>       <date>     <dbl> <dbl> <dbl> <dbl> <dbl>
    #>  1 USW00094728 1869-01-01  19.1   229    NA  -1.7  -7.2
    #>  2 USW00094728 1869-01-02   0.8     0    NA  -2.8  -6.1
    #>  3 USW00094728 1869-01-03   0       0    NA   1.7  -2.8
    #>  4 USW00094728 1869-01-04   4.6     0    NA   2.8   1.1
    #>  5 USW00094728 1869-01-05   1.3     0    NA   6.1   2.8
    #>  6 USW00094728 1869-01-06   0       0    NA   3.3   1.1
    #>  7 USW00094728 1869-01-07   0       0    NA   8.9   1.7
    #>  8 USW00094728 1869-01-08   0       0    NA  12.2   4.4
    #>  9 USW00094728 1869-01-09   0       0    NA   8.9   3.3
    #> 10 USW00094728 1869-01-10   0.3     0    NA   6.7   0.6
    #> # ... with 54,896 more rows

Data source
-----------

NOAA [GHCN](https://www.ncdc.noaa.gov/ghcn-daily-description).
