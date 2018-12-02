
<!-- README.md is generated from README.Rmd. Please edit that file -->
ghcn
====

Tools for working with Global Historical Climatology Network (GHCN) data.

Examples
--------

Find a station based on a matching pattern:

``` r
library(ghcn)

stations <- find_stations(pattern = "boston")

print(stations[1:6], n = Inf)
#> # A tibble: 22 x 6
#>    id          latitude longitude elevation state name                
#>    <chr>          <dbl>     <dbl>     <dbl> <chr> <chr>               
#>  1 ASN00064019    -32.3     149.    -1000.  <NA>  BOSTON (GOLLAN)     
#>  2 CA00111090M     49.9    -121.      200   BC    BOSTON BAR          
#>  3 CA001110R04     49.9    -121.      163   BC    BOSTON BAR          
#>  4 CA1ON000066     43.0     -80.3     236.  ON    BOSTON 0.8 SSE      
#>  5 SF002390970    -29.6      30.1    1540   <NA>  ELANDSHOEK, BOSTON  
#>  6 US1GATH0005     30.8     -83.8      59.7 GA    BOSTON 3.4 NNW      
#>  7 US1MASF0001     42.4     -71.1      13.1 MA    BOSTON 0.5 WSW      
#>  8 US1NHHL0055     42.9     -71.7     170.  NH    NEW BOSTON 2.4 S    
#>  9 US1NYER0065     42.7     -78.7     476.  NY    BOSTON 1.5 NE       
#> 10 USC00116080     41.2     -91.1     167   IL    NEW BOSTON DAM 17   
#> 11 USC00116085     41.2     -91       174   IL    NEW BOSTON          
#> 12 USC00150874     37.8     -85.7     146   KY    BOSTON 2 SW         
#> 13 USC00150875     37.7     -85.7     259.  KY    BOSTON 6 SW         
#> 14 USC00190768     42.4     -71.1       5.2 MA    BOSTON              
#> 15 USC00198368     42.0     -71.1      25.9 MA    NWS BOSTON/NORTON   
#> 16 USC00235999     40.0     -92.8     293.  MO    NEW BOSTON 3 NE     
#> 17 USC00416270     33.5     -94.4     105.  TX    NEW BOSTON          
#> 18 USC00416271     33.5     -94.5     113.  TX    NEW BOSTON 3 W      
#> 19 USC00440860     38.5     -78.1     180.  VA    BOSTON 4 SE         
#> 20 USC00447925     36.7     -78.9     100.  VA    S BOSTON            
#> 21 USW00014739     42.4     -71.0       3.7 MA    BOSTON LOGAN INTL AP
#> 22 USW00094701     42.4     -71.1       6.1 MA    BOSTON CITY WSO
```

Read all daily data for one station, given the station ID:

``` r
dat <- read_dly(id = "USW00014739")

print(dat[1:8])
#> # A tibble: 16,555 x 8
#>    id           year month element value1 mflag1 qflag1 sflag1
#>    <chr>       <int> <int> <chr>    <int> <chr>  <chr>  <chr> 
#>  1 USW00014739  1936     1 TMAX        17 <NA>   <NA>   0     
#>  2 USW00014739  1936     1 TMIN       -61 <NA>   <NA>   0     
#>  3 USW00014739  1936     1 PRCP         0 <NA>   <NA>   0     
#>  4 USW00014739  1936     1 SNOW         0 <NA>   <NA>   0     
#>  5 USW00014739  1936     1 SNWD         0 <NA>   <NA>   0     
#>  6 USW00014739  1936     1 WT16        NA <NA>   <NA>   <NA>  
#>  7 USW00014739  1936     1 WT18        NA <NA>   <NA>   <NA>  
#>  8 USW00014739  1936     2 TMAX       -50 <NA>   <NA>   0     
#>  9 USW00014739  1936     2 TMIN      -133 <NA>   <NA>   0     
#> 10 USW00014739  1936     2 PRCP         0 <NA>   <NA>   0     
#> # ... with 16,545 more rows
```

Transform the data into an easier to use format:

``` r
clean_dly(dat)
#> # A tibble: 30,285 x 7
#>    id          date        prcp  snow  snwd  tmax  tmin
#>    <chr>       <date>     <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 USW00014739 1936-01-01   0       0     0   1.7  -6.1
#>  2 USW00014739 1936-01-02   5.3     0     0   1.7  -6.1
#>  3 USW00014739 1936-01-03  35.3     0     0  12.2   1.7
#>  4 USW00014739 1936-01-04   0       0     0   7.8   1.7
#>  5 USW00014739 1936-01-05  22.9     0     0   6.1   0.6
#>  6 USW00014739 1936-01-06   1.3     0     0   4.4  -0.6
#>  7 USW00014739 1936-01-07   1.5     3     0   5     0  
#>  8 USW00014739 1936-01-08   0       0     0   4.4  -2.2
#>  9 USW00014739 1936-01-09   5.6     0     0   3.9  -1.7
#> 10 USW00014739 1936-01-10  15.2     0     0   6.7   2.8
#> # ... with 30,275 more rows
```

Data source
-----------

NOAA [GHCN](https://www.ncdc.noaa.gov/ghcn-daily-description).
