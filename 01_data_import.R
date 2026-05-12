# 01_data_import.R
# Clean and aggregate your data automatically

# Load packages
library(tidyverse)
library(readxl)
library(janitor)
library(here)

# Set seed
set.seed(12345)

# --------------------------
# 1. Read all your Excel files
# --------------------------
cat("Reading your data files...\n")

# Firm-level data
firm_basic <- read_excel(here("data", "raw", "上市公司基本信息年度表.xlsx"), skip=1)
firm_rd <- read_excel(here("data", "raw", "研发投入情况表.xlsx"), skip=1)
firm_patents <- read_excel(here("data", "raw", "上市公司绿色专利获得情况.xlsx"), skip=1)
firm_patent_app <- read_excel(here("data", "raw", "上市公司绿色专利申请情况.xlsx"), skip=1)
firm_balance <- read_excel(here("data", "raw", "资产负债表.xlsx"), skip=1)
firm_income <- read_excel(here("data", "raw", "利润表.xlsx"), skip=1)

# City-level data
city_basic <- read_excel(here("data", "raw", "数据7.xlsx"))
city_economic <- read_excel(here("data", "raw", "数据8.xlsx"))
city_pollution <- read_excel(here("data", "raw", "数据9.xlsx"))

# --------------------------
# 2. Clean all data
# --------------------------
cat("Cleaning data...\n")

firm_basic <- clean_names(firm_basic)
firm_rd <- clean_names(firm_rd)
firm_patents <- clean_names(firm_patents)
firm_patent_app <- clean_names(firm_patent_app)
city_basic <- clean_names(city_basic)
city_economic <- clean_names(city_economic)
city_pollution <- clean_names(city_pollution)

# --------------------------
# 3. Process firm data
# --------------------------
cat("Processing firm data...\n")

# Clean firm basic
firm_basic_clean <- firm_basic %>%
  select(symbol, end_date, province, city) %>%
  rename(stkcd = symbol, year = end_date) %>%
  mutate(year = year(as.Date(year))) %>%
  filter(year >= 2008 & year <= 2022)

# Clean R&D
firm_rd_clean <- firm_rd %>%
  select(symbol, end_date, rd_spend_sum) %>%
  rename(stkcd = symbol, year = end_date, rd_expenditure = rd_spend_sum) %>%
  mutate(year = year(as.Date(year))) %>%
  filter(year >= 2008 & year <= 2022)

# Clean patents
firm_patents_clean <- firm_patents %>%
  select(code, year, gre_invig, gre_umig, gre_invjg, gre_umjg) %>%
  rename(stkcd = code) %>%
  mutate(total_grants = gre_invig + gre_umig + gre_invjg + gre_umjg) %>%
  select(stkcd, year, total_grants) %>%
  filter(year >= 2008 & year <= 2022)

firm_patent_app_clean <- firm_patent_app %>%
  select(scode, year, greinvia, greumia, greinvja, greumja) %>%
  rename(stkcd = scode) %>%
  mutate(total_apps = greinvia + greumia + greinvja + greumja) %>%
  select(stkcd, year, total_apps) %>%
  filter(year >= 2008 & year <= 2022)

# Merge firm data
firm_merged <- firm_basic_clean %>%
  left_join(firm_rd_clean, by = c("stkcd", "year")) %>%
  left_join(firm_patents_clean, by = c("stkcd", "year")) %>%
  left_join(firm_patent_app_clean, by = c("stkcd", "year")) %>%
  replace_na(list(rd_expenditure = 0, total_grants = 0, total_apps = 0))

# Aggregate to city-year
city_firm_agg <- firm_merged %>%
  group_by(city, year) %>%
  summarise(
    total_rd = sum(rd_expenditure, na.rm = TRUE),
    total_green_grants = sum(total_grants, na.rm = TRUE),
    total_green_apps = sum(total_apps, na.rm = TRUE),
    .groups = "drop"
  )

# --------------------------
# 4. Process city data
# --------------------------
cat("Processing city data...\n")

city_merged <- city_basic %>%
  left_join(city_economic, by = c("year", "province", "city")) %>%
  left_join(city_pollution, by = c("year", "province", "city"))

# --------------------------
# 5. Merge everything
# --------------------------
cat("Merging all data...\n")

full_data <- city_merged %>%
  left_join(city_firm_agg, by = c("city", "year")) %>%
  complete(year = 2008:2022, nesting(city_code, province, city)) %>%
  arrange(city_code, year)

# --------------------------
# 6. Save cleaned data
# --------------------------
cat("Saving cleaned data...\n")

# Create processed folder if it doesn't exist
if(!dir.exists(here("data", "processed"))) {
  dir.create(here("data", "processed"))
}

saveRDS(full_data, here("data", "processed", "cleaned_data.rds"))

cat("\n✅ DONE! Your data is cleaned!\n")
cat("Number of cities:", n_distinct(full_data$city_code), "\n")
cat("Year range:", min(full_data$year), "to", max(full_data$year), "\n")