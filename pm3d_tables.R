library(AzureTableStor)
library(dplyr)

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
  by = c("RowKey" = "PackageReferenceId")
) %>% 
  full_join(
    list_storage_tables(tabs)[["plantMap3dMetaDataImage"]] %>% 
      list_table_entities(as_data_frame = F) %>% 
      purrr::map(~purrr::map(.x, as.character) %>% as_tibble()) %>% 
      bind_rows(),
    by = c("RowKey" = "SetReferenceId")
  )

View(pm3d_alldata)

library(googlesheets4)

sheet_write(pm3d_alldata, ss = sheetid)
