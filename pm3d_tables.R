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


pm3d_alldata <- 
  full_join(
    list_storage_tables(tabs)[["plantMap3dMetaDataPackage"]] %>% 
      list_table_entities() %>% 
      as_tibble(),
    list_storage_tables(tabs)[["plantMap3dMetaDataSet"]] %>% 
      list_table_entities(as_data_frame = F) %>% 
      purrr::map(~purrr::map(.x, as.character) %>% as_tibble()) %>% 
      bind_rows(),
    by = c("RowKey" = "PackageReferenceId"),
    keep = T,
    suffix = c("_PKG", "_SET")
  ) %>% 
  full_join(
    list_storage_tables(tabs)[["plantMap3dMetaDataImage"]] %>% 
      list_table_entities(as_data_frame = F) %>% 
      purrr::map(~purrr::map(.x, as.character) %>% as_tibble()) %>% 
      bind_rows(),
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
