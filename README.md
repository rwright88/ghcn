
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ghcn

Tools for working with [Global Historical Climatology
Network](https://www.ncdc.noaa.gov/ghcn-daily-description) (GHCN) data.

## Installation

``` r
devtools::install_github("rwright88/ghcn")
```

## Examples

Find a station based on a matching pattern:

``` r
library(ghcn)

stations <- ghcn_find_stations(pattern = "new york")
stations[1:6]
```

    #> # A tibble: 18 x 6
    #>    id          latitude longitude elevation state name                     
    #>    <chr>          <dbl>     <dbl>     <dbl> <chr> <chr>                    
    #>  1 US1NYNY0074     40.8     -73.9       6.1 NY    NEW YORK 8.8 N           
    #>  2 USC00215902     46.5     -95.4     428.  MN    NEW YORK MILLS           
    #>  3 USC00305798     40.6     -74.0       6.1 NY    NEW YORK BENSONHURST     
    #>  4 USC00305799     40.9     -73.9      27.1 NY    NEW YORK BOTANICAL GRD   
    #>  5 USC00305804     40.7     -73.9       3   NY    NEW YORK LAUREL HILL     
    #>  6 USC00305806     40.8     -73.9      54.9 NY    NEW YORK UNIV ST         
    #>  7 USC00305816     40.7     -74.0       3   NY    NEW YORK WB CITY         
    #>  8 USC00308721     40.9     -72.9       7.9 NY    UPTON COOP - NWSFO NEW Y~
    #>  9 USR0000NGAN     42.1     -77.1     335.  NY    GANG MILLS NEW YORK      
    #> 10 USR0000NSAR     43.0     -73.7     114.  NY    SARA NEW YORK            
    #> 11 USR0000NSCH     43.8     -73.7     250.  NY    SCHROON LAKE NEW YORK    
    #> 12 USR0000NSHR     42.7     -75.5     335.  NY    SHERBURNE NEW YORK       
    #> 13 USR0000NSTO     41.5     -73.9      61   NY    STONYKILL NEW YORK       
    #> 14 USW00014732     40.8     -73.9       3.4 NY    NEW YORK LAGUARDIA AP    
    #> 15 USW00014786     40.6     -73.9       4.9 NY    NEW YORK FLOYD BENNETT F~
    #> 16 USW00093732     39.8     -72.7      25.9 NY    NEW YORK SHOALS AFS      
    #> 17 USW00094728     40.8     -74.0      39.6 NY    NEW YORK CNTRL PK TWR    
    #> 18 USW00094789     40.6     -73.8       3.4 NY    NEW YORK JFK INTL AP

Read all daily data for one station, given the station ID:

``` r
dat <- ghcn_read(id = "USW00094728")
str(dat[1:20])
```

    #> Classes 'tbl_df', 'tbl' and 'data.frame':    15021 obs. of  20 variables:
    #>  $ id     : chr  "USW00094728" "USW00094728" "USW00094728" "USW00094728" ...
    #>  $ year   : int  1869 1869 1869 1869 1869 1869 1869 1869 1869 1869 ...
    #>  $ month  : int  1 1 1 1 2 2 2 2 3 3 ...
    #>  $ element: chr  "TMAX" "TMIN" "PRCP" "SNOW" ...
    #>  $ value1 : int  -17 -72 191 229 6 -39 0 0 -33 -156 ...
    #>  $ mflag1 : chr  NA NA NA NA ...
    #>  $ qflag1 : chr  NA NA NA NA ...
    #>  $ sflag1 : chr  "Z" "Z" "Z" "Z" ...
    #>  $ value2 : int  -28 -61 8 0 11 -56 0 0 22 -72 ...
    #>  $ mflag2 : chr  NA NA NA NA ...
    #>  $ qflag2 : chr  NA NA NA NA ...
    #>  $ sflag2 : chr  "Z" "Z" "Z" "Z" ...
    #>  $ value3 : int  17 -28 0 0 22 17 0 0 61 -22 ...
    #>  $ mflag3 : chr  NA NA "T" NA ...
    #>  $ qflag3 : chr  NA NA NA NA ...
    #>  $ sflag3 : chr  "Z" "Z" "Z" "Z" ...
    #>  $ value4 : int  28 11 46 0 33 -61 394 28 67 -72 ...
    #>  $ mflag4 : chr  NA NA NA NA ...
    #>  $ qflag4 : chr  NA NA NA NA ...
    #>  $ sflag4 : chr  "Z" "Z" "Z" "Z" ...

Transform the data into an easier to use format, keeping only the five
core statistics of daily precipitation, snow fall, snow depth, minimum
temperature, and maximum temperature:

``` r
ghcn_clean(dat)
```

    #> # A tibble: 54,937 x 7
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
    #> # ... with 54,927 more rows
