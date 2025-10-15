library(httr2)
library(glue)
library(dplyr)

# Read credentials from environment variables
email <- Sys.getenv("EASIN_API_EMAIL")
password <- Sys.getenv("EASIN_API_PASSWORD")

# Validate that secrets are available
if (email == "" || password == "") {
  stop("Missing required environment variables: API_EMAIL or API_PASSWORD")
}

# Your other dynamic values
species_id <- ""
data_partner <- 22
country <- ""
exclude_partner <- 0
lastRetrievedRowNumber <- 0
take <- 10000 # max allowed by API

# Build request body as a list
body_list <- list(
  Email = email,
  Password = password,
  speciesId = species_id,
  countryCode = country,
  dataPartner = data_partner,
  excludePartner = exclude_partners,
  lastRetrievedRowNumber = lastRetrievedRowNumber,
  take = take
)
res <- request("https://easin.jrc.ec.europa.eu/apixg2/geo/getoccurrences") %>%
  req_body_json(body_list) %>%
  req_perform()

# Inspect output
resp_status(res)

# Parse JSON response as tibble (httr2 can also handle this)
occs <- res %>%
  resp_body_json(simplifyVector = TRUE) %>%
  dplyr::as_tibble()

unique(occs$Timestamp)


# Save in raw data folder as CSV
readr::write_csv(occs, "./data/raw/iase_occs.csv")
