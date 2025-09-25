library(httr)
library(glue)
library(jsonlite)
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
data_partner <- "22"
country <- ""
exclude_partners <- 0
skip <- 0
take <- 2220

# Build request body as a list
body_list <- list(
  Email = email,
  Password = password,
  speciesId = species_id,
  countryCode = country,
  dataPartners = data_partner,
  excludePartners = exclude_partners,
  skip = skip,
  take = take
)

# Convert list to JSON
body_json <- jsonlite::toJSON(body_list, auto_unbox = TRUE)

cat(body_json)  # just to check

# Send POST request
res <- httr::POST(
  url = "https://easin.jrc.ec.europa.eu/apixg2/geo/getoccurrences",
  body = body_json,
  encode = "raw",  # since body is already JSON text
  add_headers("Content-Type" = "application/json")
)

# Inspect output
status_code(res)   # e.g., 200 if OK
content_text <- httr::content(res, as = "text", encoding = "UTF-8")

# Parse JSON response as tibble data.frame
occs <- jsonlite::fromJSON(content_text, flatten = TRUE) %>%
  dplyr::as_tibble()

# Save in raw data folder as CSV
readr::write_csv(occs, "./data/raw/iase_occs.csv")
