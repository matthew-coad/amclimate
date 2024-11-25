#####################################################################
#                        Process Ta annual
#####################################################################

# Data Sources
#
# # GISTEMP
#
# GISTEMP Team, 2018: GISS Surface Temperature Analysis (GISTEMP). NASA Goddard Institute for Space Studies
# Dataset accessed 2018-09-03 at https://data.giss.nasa.gov/gistemp/.
#
# # NVHNT
#
# Northern Hemisphere temperatures reconstructed by statistically combining long-term fluctuations recorded by 11 low-resolution proxy series (lake and ocean sediments, ice cores, stalagmites) and short- term variations recorded by 7 tree-rings series. The reconstruction was calibrated by matching its mean and variance to the instrumental record of Northern Hemisphere annual mean temperature over the period of overlap (CE 1856-1979).
#
# Credits: Moberg, A., D.M. Sonechkin, K. Holmgren, N.M. Datsenko, and W. Karlén. 2005. Highly variable Northern Hemisphere temperatures reconstructed from low- and high-resolution proxy data. Nature, Vol. 433, pp. 613-617.
#
# Dataset accessed 2018-09-03 at http://www.temperaturerecord.org/.
#

library(tidyverse)

ta_datapath <- function(filename) file.path("data", "raw", filename)

## Get annual global temperature anamoly from 0ad to 1980
read_ta_annual_global_0to1980 <- function() {
  file_path <- ta_datapath("temperature_dataset.csv")
  col_types <-
    cols(
      Year = col_integer(),
      Age = col_integer(),
      TempVs61to90 = col_double(),
      TempVs50to80 = col_double()
    )
  raw <- read_csv(file_path, col_types = col_types)
  result <- tibble(
    TA.Source = 'HVNHT',
    Year = raw$Year,
    TA.Global = raw$TempVs50to80
  )
  result
}

## Get GISTEMP, Zonal annual means
read_ta_GISTEMP_annual_zones <- function(filename) {
  temp_path <- ta_datapath(filename)
  col_types <-
    cols(
      Year = col_integer(),
      Glob = col_character(),
      NHem = col_character(),
      SHem = col_character(),
      `24N-90N` = col_character(),
      `24S-24N` = col_character(),
      `90S-24S` = col_character(),
      `64N-90N` = col_character(),
      `44N-64N` = col_character(),
      `24N-44N` = col_character(),
      `EQU-24N` = col_character(),
      `24S-EQU` = col_character(),
      `44S-24S` = col_character(),
      `64S-44S` = col_character(),
      `90S-64S` = col_character()
    )
  as_temp <- function(x) suppressWarnings(ifelse(x != '*****', as.double(x), NA))
  temp_raw <- read_csv(temp_path, col_types = col_types)
  temp <- tibble(
    TA.Source = 'GISTEMP',
    Year = temp_raw$Year,
    TA.Global = as_temp(temp_raw$Glob),
    TA.NHem = as_temp(temp_raw$NHem),
    TA.SHem = as_temp(temp_raw$SHem),
    TA.NBand = as_temp(temp_raw$`24N-90N`),
    TA.CBand = as_temp(temp_raw$`24S-24N`),
    TA.SBand = as_temp(temp_raw$`90S-24S`),
    TA.NFrigid = as_temp(temp_raw$'64N-90N'),
    TA.NTemperate = as_temp(temp_raw$'44N-64N'),
    TA.NSubtropical = as_temp(temp_raw$'24N-44N'),
    TA.NTorrid = as_temp(temp_raw$'EQU-24N'),
    TA.STorrid = as_temp(temp_raw$'24S-EQU'),
    TA.SSubtropical = as_temp(temp_raw$'44S-24S'),
    TA.STemperate = as_temp(temp_raw$'64S-44S'),
    TA.SFrigid = as_temp(temp_raw$'90S-64S')
  )
  temp
}


## Get annual temperature anamoly by zones from 1880 to present
read_ta_annual_zones_1880toNow <- function() {
  read_ta_GISTEMP_annual_zones("ZonAnn.Ts+dSST.csv")
}

#' Annual Temperature Anomaly
#'
#' @return
read_ta_annual <- function() {
  early <- read_ta_annual_global_0to1980()
  later <- read_ta_annual_zones_1880toNow()
  result <- early %>% anti_join(later, by="Year") %>% bind_rows(later) %>% arrange(Year)
  result
}

ta_annual <- read_ta_annual()
save(ta_annual, file = file.path("data", "rda", "ta_annual.rda"))

