ver_rlang    = Sys.getenv("RLANG_VERSION")
ver_dplyr    = Sys.getenv("DPLYR_VERSION")
ver_sparklyr = Sys.getenv("SPARKLYR_VERSION")

cat("Installing rlang", ver_rlang, "\n")
remotes::install_github(file.path("tidyverse/rlang", ver_rlang, fsep = "@v"))

cat("Installing dplyr", ver_dplyr, "\n")
remotes::install_github(file.path("tidyverse/dplyr", ver_dplyr, fsep = "@v"))

cat("Installing sparklyr", ver_sparklyr, "\n")
remotes::install_github(file.path("rstudio/sparklyr", ver_sparklyr, fsep = "@v"))
