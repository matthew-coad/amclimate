library(tidyverse)

co2_iac_annual_0To2014_datapath <- rprojroot::is_rstudio_project$find_file("data", "raw", "mole_fraction_of_carbon_dioxide_in_air_input4MIPs_GHGConcentrations_CMIP_UoM-CMIP-1-1-0_gr3-GMNHSH_0000-2014.csv")

am_co2_iac_annual_0To2014 <- {
  file_path <- co2_iac_annual_0To2014_datapath
  col_types <- cols(
    year = col_integer(),
    data_mean_global = col_double(),
    data_mean_nh = col_double(),
    data_mean_sh = col_double()
  )
  co2_raw <- read_csv(file_path, col_types = col_types)
  tibble(
    CO2.Source = 'IAC',
    Year = co2_raw$year,
    CO2.Global = co2_raw$data_mean_global,
    CO2.NHem = co2_raw$data_mean_nh,
    CO2.SHem = co2_raw$data_mean_sh
  )
}

co2_mauna_annual_datapath <- rprojroot::is_rstudio_project$find_file("data", "raw", "co2_annmean_mlo.txt")

am_co2_mauna_annual_1959toPresent <- {
  file_path <- co2_mauna_annual_datapath
  raw_lines <- read_lines(file_path)
  data_lines <- raw_lines[str_sub(raw_lines,1,1) != '#']
  years <- as.integer(str_sub(data_lines, 3, 6))
  co2_global <- as.double(str_sub(data_lines, 7, 15))
  tibble(
    CO2.Source = 'MAUNA',
    Year = years,
    CO2.Global = co2_global
  )
}

co2_annual <- {
  iac <- am_co2_iac_annual_0To2014
  mauna <- am_co2_mauna_annual_1959toPresent
  iac %>% anti_join(mauna, by="Year") %>% bind_rows(mauna) %>% arrange(Year)
}

save(co2_annual, file = rprojroot::is_rstudio_project$find_file("data", "rda", "co2_annual.rda"))

