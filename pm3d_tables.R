library(AzureTableStor)
library(dplyr)
library(googlesheets4)


source("secret.R")

tabs <- table_endpoint(endp, sas = sas)

# tabs
# list_storage_tables(tabs)
# 
# list_storage_tables(tabs)[["plantMap3dMetaDataPackage"]] %>% 
#   list_table_entities()
#   
# storage_table(tabs, name = "plantMap3dMetaDataPackage") %>% 
#   list_table_entities(as_data_frame = F)


table_to_tibble <- function(tab_endp, nm) {
  storage_table(tab_endp, name = nm) %>% 
    list_table_entities(as_data_frame = F) %>% 
    purrr::map(
      ~purrr::map(.x, as.character) %>% 
        as_tibble()
      ) %>% 
    bind_rows()
}

pm3d_alldata <- 
  table_to_tibble(tabs, "plantMap3dMetaDataPackage") %>% 
  full_join(
    table_to_tibble(tabs, "plantMap3dMetaDataSet"),
    by = c("RowKey" = "PackageReferenceId"),
    keep = T,
    suffix = c("_PKG", "_SET")
  ) %>% 
  full_join(
    table_to_tibble(tabs, "plantMap3dMetaDataImage"),
    by = c("RowKey_SET" = "SetReferenceId"),
    keep = T,
    suffix = c("_SET", "_IMAGE")
  ) %>% 
  mutate(
    ImageUrl = paste0('=HYPERLINK("', ImageUrl, '")'),
    ImageUrl = gs4_formula(ImageUrl)
  )

# View(pm3d_alldata)


sheet_write(pm3d_alldata, ss = sheetid, sheet = "pm3d_alldata")
