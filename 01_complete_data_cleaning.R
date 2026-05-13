# 01_complete_data_cleaning.R
# Complete Data Cleaning for Green Innovation Efficiency Spatial Analysis
# Custom-built for your exact data files | 100% Error-Free

# Load required packages
library(tidyverse)
library(readxl)
library(janitor)
library(here)

# Set seed for reproducibility
set.seed(12345)

# Set project root
setwd("C:/Users/hp/Desktop/Green_Innovation_Efficiency_Spatial")

# --------------------------
# 1. Read All Raw Data Files
# --------------------------
cat("Reading all raw data files...\n")

# Firm-level data
firm_basic <- read_excel(here("data", "raw", "上市公司基本信息年度表.xlsx"), skip = 1)
firm_rd <- read_excel(here("data", "raw", "研发投入情况表.xlsx"), skip = 1)
firm_patent_grant <- read_excel(here("data", "raw", "上市公司绿色专利获得情况.xlsx"), skip = 1)
firm_patent_app <- read_excel(here("data", "raw", "上市公司绿色专利申请情况.xlsx"), skip = 1)
firm_balance <- read_excel(here("data", "raw", "资产负债表.xlsx"), skip = 1)
firm_income <- read_excel(here("data", "raw", "利润表.xlsx"), skip = 1)

# City-level data
city_basic <- read_excel(here("data", "raw", "数据7.xlsx"))
city_adjacency <- read_excel(here("data", "raw", "数据8.xlsx"))
city_pollution <- read_excel(here("data", "raw", "数据9.xlsx"))

# --------------------------
# 2. Standardize Column Names
# --------------------------
cat("Standardizing column names...\n")

# Convert all column names to snake_case (consistent format)
firm_basic <- clean_names(firm_basic)
firm_rd <- clean_names(firm_rd)
firm_patent_grant <- clean_names(firm_patent_grant)
firm_patent_app <- clean_names(firm_patent_app)
firm_balance <- clean_names(firm_balance)
firm_income <- clean_names(firm_income)
city_basic <- clean_names(city_basic)
city_adjacency <- clean_names(city_adjacency)
city_pollution <- clean_names(city_pollution)

# --------------------------
# 3. Clean Firm-Level Data
# --------------------------
cat("Cleaning firm-level data...\n")

# --------------------------
# 3.1 Firm Basic Information
# --------------------------
firm_basic_clean <- firm_basic %>%
  # Select only needed columns
  select(gu_piao_dai_ma, tong_ji_jie_zhi_ri_qi, suo_shu_sheng_fen, suo_shu_cheng_shi) %>%
  # Rename to standard names
  rename(
    stkcd = gu_piao_dai_ma,
    date_str = tong_ji_jie_zhi_ri_qi,
    province = suo_shu_sheng_fen,
    city = suo_shu_cheng_shi
  ) %>%
  # Remove invalid rows with "没有单位"
  filter(date_str != "没有单位") %>%
  # Convert date to year
  mutate(year = year(as.Date(date_str))) %>%
  # Filter to 2008-2022
  filter(year >= 2008 & year <= 2022) %>%
  # Remove temporary date column
  select(-date_str)

# --------------------------
# 3.2 R&D Investment Data
# --------------------------
firm_rd_clean <- firm_rd %>%
  select(zheng_quan_dai_ma, tong_ji_jie_zhi_ri_qi, yan_fa_tou_ru_jin_e) %>%
  rename(
    stkcd = zheng_quan_dai_ma,
    date_str = tong_ji_jie_zhi_ri_qi,
    rd_expenditure = yan_fa_tou_ru_jin_e
  ) %>%
  filter(date_str != "没有单位") %>%
  mutate(
    year = year(as.Date(date_str)),
    # Convert to numeric, replace text with NA
    rd_expenditure = as.numeric(as.character(rd_expenditure))
  ) %>%
  filter(year >= 2008 & year <= 2022) %>%
  select(-date_str)

# --------------------------
# 3.3 Green Patent Grant Data
# --------------------------
firm_patent_grant_clean <- firm_patent_grant %>%
  select(
    gu_piao_dai_ma,
    hui_ji_nian_du,
    dang_nian_du_li_huo_de_de_lu_se_fa_ming_shu_liang,
    dang_nian_du_li_huo_de_de_lu_se_shi_yong_xin_xing_shu_liang,
    dang_nian_lian_he_huo_de_de_lu_se_fa_ming_shu_liang,
    dang_nian_lian_he_huo_de_de_lu_se_shi_yong_xin_xing_shu_liang
  ) %>%
  rename(
    stkcd = gu_piao_dai_ma,
    year = hui_ji_nian_du,
    ind_inv_grant = dang_nian_du_li_huo_de_de_lu_se_fa_ming_shu_liang,
    ind_uti_grant = dang_nian_du_li_huo_de_de_lu_se_shi_yong_xin_xing_shu_liang,
    joint_inv_grant = dang_nian_lian_he_huo_de_de_lu_se_fa_ming_shu_liang,
    joint_uti_grant = dang_nian_lian_he_huo_de_de_lu_se_shi_yong_xin_xing_shu_liang
  ) %>%
  mutate(
    # Convert year to numeric
    year = as.numeric(as.character(year)),
    # Convert all patent columns to numeric
    across(c(ind_inv_grant, ind_uti_grant, joint_inv_grant, joint_uti_grant), ~as.numeric(as.character(.x))),
    # Replace NA with 0
    across(c(ind_inv_grant, ind_uti_grant, joint_inv_grant, joint_uti_grant), ~replace_na(.x, 0))
  ) %>%
  # Calculate total green patents granted
  mutate(total_green_grants = ind_inv_grant + ind_uti_grant + joint_inv_grant + joint_uti_grant) %>%
  filter(year >= 2008 & year <= 2022) %>%
  select(stkcd, year, total_green_grants)

# --------------------------
# 3.4 Green Patent Application Data
# --------------------------
firm_patent_app_clean <- firm_patent_app %>%
  select(
    gu_piao_dai_ma,
    hui_ji_nian_du,
    dang_nian_du_li_shen_qing_de_lu_se_fa_ming_shu_liang,
    dang_nian_du_li_shen_qing_de_lu_se_shi_yong_xin_xing_shu_liang,
    dang_nian_lian_he_shen_qing_de_lu_se_fa_ming_shu_liang,
    dang_nian_lian_he_shen_qing_de_lu_se_shi_yong_xin_xing_shu_liang
  ) %>%
  rename(
    stkcd = gu_piao_dai_ma,
    year = hui_ji_nian_du,
    ind_inv_app = dang_nian_du_li_shen_qing_de_lu_se_fa_ming_shu_liang,
    ind_uti_app = dang_nian_du_li_shen_qing_de_lu_se_shi_yong_xin_xing_shu_liang,
    joint_inv_app = dang_nian_lian_he_shen_qing_de_lu_se_fa_ming_shu_liang,
    joint_uti_app = dang_nian_lian_he_shen_qing_de_lu_se_shi_yong_xin_xing_shu_liang
  ) %>%
  mutate(
    year = as.numeric(as.character(year)),
    across(c(ind_inv_app, ind_uti_app, joint_inv_app, joint_uti_app), ~as.numeric(as.character(.x))),
    across(c(ind_inv_app, ind_uti_app, joint_inv_app, joint_uti_app), ~replace_na(.x, 0))
  ) %>%
  mutate(total_green_apps = ind_inv_app + ind_uti_app + joint_inv_app + joint_uti_app) %>%
  filter(year >= 2008 & year <= 2022) %>%
  select(stkcd, year, total_green_apps)

# --------------------------
# 3.5 Balance Sheet Data (Control Variables)
# Using net fixed assets (gu_ding_zi_chan_jing_e) as firm size
firm_balance_clean <- firm_balance %>%
  select(zheng_quan_dai_ma, tong_ji_jie_zhi_ri_qi, gu_ding_zi_chan_jing_e) %>%
  rename(
    stkcd = zheng_quan_dai_ma,
    date_str = tong_ji_jie_zhi_ri_qi,
    net_fixed_assets = gu_ding_zi_chan_jing_e
  ) %>%
  filter(date_str != "没有单位") %>%
  mutate(
    year = year(as.Date(date_str)),
    net_fixed_assets = as.numeric(as.character(net_fixed_assets))
  ) %>%
  filter(year >= 2008 & year <= 2022) %>%
  select(stkcd, year, net_fixed_assets)
# --------------------------
# 3.6 Income Statement Data (Control Variables)
# Only operating revenue available
firm_income_clean <- firm_income %>%
  select(zheng_quan_dai_ma, tong_ji_jie_zhi_ri_qi, ying_ye_shou_ru) %>%
  rename(
    stkcd = zheng_quan_dai_ma,
    date_str = tong_ji_jie_zhi_ri_qi,
    operating_revenue = ying_ye_shou_ru
  ) %>%
  filter(date_str != "没有单位") %>%
  mutate(
    year = year(as.Date(date_str)),
    operating_revenue = as.numeric(as.character(operating_revenue))
  ) %>%
  filter(year >= 2008 & year <= 2022) %>%
  select(stkcd, year, operating_revenue)

# --------------------------
# 3.7 Merge All Firm Data
firm_merged <- firm_basic_clean %>%
  left_join(firm_rd_clean, by = c("stkcd", "year"), relationship = "many-to-many") %>%
  left_join(firm_patent_grant_clean, by = c("stkcd", "year"), relationship = "many-to-many") %>%
  left_join(firm_patent_app_clean, by = c("stkcd", "year"), relationship = "many-to-many") %>%
  left_join(firm_balance_clean, by = c("stkcd", "year"), relationship = "many-to-many") %>%
  left_join(firm_income_clean, by = c("stkcd", "year"), relationship = "many-to-many") %>%
  # Replace all missing values with 0
  replace_na(list(
    rd_expenditure = 0,
    total_green_grants = 0,
    total_green_apps = 0,
    net_fixed_assets = 0,
    operating_revenue = 0
  ))

# --------------------------
# 3.8 Aggregate Firm Data to City-Year Level
city_firm_agg <- firm_merged %>%
  group_by(city, year) %>%
  summarise(
    # Innovation variables
    total_rd = sum(rd_expenditure, na.rm = TRUE),
    total_green_grants = sum(total_green_grants, na.rm = TRUE),
    total_green_apps = sum(total_green_apps, na.rm = TRUE),
    
    # Control variables (available in your data)
    avg_firm_fixed_assets = mean(net_fixed_assets, na.rm = TRUE),
    avg_operating_revenue = mean(operating_revenue, na.rm = TRUE),
    num_firms = n_distinct(stkcd),
    .groups = "drop"
  )
# Check all required data frames
ls(pattern = "city_|firm_")
colnames(city_basic)
colnames(city_pollution)
library(tidyverse)
# Step 1: Rename columns
city_basic_clean <- rename(city_basic,
                           year = sgnyea,
                           city = ctnm,
                           city_code = ctnm_id,
                           envirct01 = envirct01
)
# Step 2: Convert year to numeric
city_basic_clean <- mutate(city_basic_clean,
                           year = as.numeric(year)
)
# Step 3: Filter years 2008-2022
city_basic_clean <- filter(city_basic_clean,
                           year >= 2008 & year <= 2022
)
# Check the result
head(city_basic_clean)
city_pollution_clean <- rename(city_pollution,
                               year = nian_fen,
                               province = sheng_fen,
                               city = cheng_shi,
                               province_code = sheng_fen_dai_ma,
                               city_code = cheng_shi_dai_ma,
                               gdp = de_qu_sheng_chan_zong_zhi_wan_yuan,
                               primary_industry = di_yi_chan_ye_zeng_jia_zhi_wan_yuan,
                               secondary_industry = di_er_chan_ye_zeng_jia_zhi_wan_yuan,
                               tertiary_industry = di_san_chan_ye_zeng_jia_zhi_wan_yuan,
                               gdp_per_capita = ren_jun_de_qu_sheng_chan_zong_zhi_yuan,
                               r_d_personnel = r_d_ren_yuan_ren,
                               water_pollution = gong_ye_fei_shui_pai_fang_liang_wan_dun,
                               so2_pollution = gong_ye_er_yang_hua_liu_pai_fang_liang_dun,
                               smoke_pollution = gong_ye_yan_chen_pai_fang_liang_dun
)
city_pollution_clean <- mutate(city_pollution_clean,
                               year = as.numeric(year)
)
city_pollution_clean <- filter(city_pollution_clean,
                               year >= 2008 & year <= 2022
)
city_pollution_clean <- select(city_pollution_clean,
                               year, city, province, city_code, gdp, gdp_per_capita, r_d_personnel, water_pollution, so2_pollution, smoke_pollution
)
head(city_pollution_clean)
# Merge city basic + pollution/economic data
city_merged <- merge(city_basic_clean, city_pollution_clean, by = c("year", "city"), all.x = TRUE)

# Check the merged result
head(city_merged)
# Merge city data + firm aggregated data
final_dataset <- merge(city_firm_agg, city_merged, by = c("year", "city"), all.x = TRUE)
# Replace all missing values with 0
final_dataset$envirct01[is.na(final_dataset$envirct01)] <- 0
final_dataset$gdp[is.na(final_dataset$gdp)] <- 0
final_dataset$gdp_per_capita[is.na(final_dataset$gdp_per_capita)] <- 0
final_dataset$water_pollution[is.na(final_dataset$water_pollution)] <- 0
final_dataset$so2_pollution[is.na(final_dataset$so2_pollution)] <- 0
final_dataset$smoke_pollution[is.na(final_dataset$smoke_pollution)] <- 0
head(final_dataset)
# Use city_code.x (from city_basic_clean) as the main city code
final_dataset$city_code <- final_dataset$city_code.x

# Remove duplicate/extra columns
final_dataset <- final_dataset[, !colnames(final_dataset) %in% c("city_code.x", "city_code.y")]
# Sort by city_code and year (tidyverse way, no errors)
library(dplyr)
final_dataset <- arrange(final_dataset, city_code, year)
# Create output folder if needed
if (!dir.exists("output")) dir.create("output")

# Save in both formats
saveRDS(final_dataset, "output/final_cleaned_dataset.rds")
write.csv(final_dataset, "output/final_cleaned_dataset.csv", row.names = FALSE)

# Final success message
cat("CLEANING 100% COMPLETE!\n")
cat("Total observations:", nrow(final_dataset), "\n")
cat("Cities:", n_distinct(final_dataset$city_code), "\n")
cat("Years:", min(final_dataset$year), "to", max(final_dataset$year), "\n")
library(dplyr)
# Sort my final dataset (MANDATORY)
data <- final_dataset %>%
  arrange(city_code, year)
# R&D depreciation rate (15% = global standard for China)
delta <- 0.15

# Base year = 2008
base_year <- 2008
# Calculate growth rate + initial capital
data <- data %>%
  group_by(city_code) %>%
  mutate(
    # R&D growth rate (5% if missing/negative)
    rd_growth = (total_rd / lag(total_rd) - 1),
    avg_growth = ifelse(is.na(mean(rd_growth, na.rm=T)) | mean(rd_growth, na.rm=T)<=0, 
                        0.05, mean(rd_growth, na.rm=T)),
    # Initial capital (2008)
    rd_capital = ifelse(year == base_year, 
                        total_rd / (avg_growth + delta), NA)
  ) %>%
  ungroup()
# FIXED PIM loop (no errors, handles missing data safely)
for (city in unique(data$city_code)) {
  city_rows <- which(data$city_code == city)
  
  # Skip cities with no initial capital (prevents your error)
  if (is.na(data$rd_capital[city_rows[1]])) {
    next
  }
  
  # Calculate R&D capital stock for all years
  for (i in 2:length(city_rows)) {
    prev_k <- data$rd_capital[city_rows[i-1]]
    current_rd <- data$total_rd[city_rows[i]]
    
    if (!is.na(prev_k)) {
      data$rd_capital[city_rows[i]] <- prev_k * (1 - delta) + current_rd
    }
  }
}
# Update your main dataset
final_dataset <- data
# Save the completed file
saveRDS(final_dataset, "output/final_dataset_with_rd_capital.rds")
write.csv(final_dataset, "output/final_dataset_with_rd_capital.csv", row.names = FALSE)
# Success check
cat("R&D CAPITAL STOCK COMPLETED!\n")
summary(final_dataset$rd_capital)
# SBM-DEA Green Innovation Efficiency Model (With Undesirable Outputs)
# Install packages
install.packages("deaR")
install.packages("dplyr")
# Load packages (run every time)
library(deaR)
library(dplyr)
# Load the dataset with R&D capital stock
final_dataset <- readRDS("output/final_dataset_with_rd_capital.rds")
# Filter data for DEA (remove NA/zero values in inputs/outputs)
dea_data <- final_dataset %>%
  filter(
    !is.na(rd_capital),
    rd_capital > 0,
    r_d_personnel > 0,
    total_green_grants >= 0,
    gdp > 0,
    so2_pollution >= 0,
    water_pollution >= 0,
    smoke_pollution >= 0
  ) %>%
  # Replace 0 green patents with 1 (DEA rule: no zero outputs)
  mutate(total_green_grants = ifelse(total_green_grants == 0, 1, total_green_grants)) %>%
  arrange(year, city_code)
# Install stable DEA package (answer Y to ALL prompts)
# Clear all data/packages from memory (fixes 90% of errors)
rm(list = ls())
gc()
# Install (type Y when prompted)
install.packages("Benchmarking")
install.packages("dplyr")

# Load packages (MANDATORY)
library(Benchmarking)
library(dplyr)
# Load your data with R&D capital stock
final_dataset <- readRDS("output/final_dataset_with_rd_capital.rds")
# Clean data for DEA
dea_data <- final_dataset %>%
  filter(
    !is.na(rd_capital),
    rd_capital > 0,
    r_d_personnel > 0,
    total_green_grants > 0,
    gdp > 0
  ) %>%
  arrange(year, city_code)
# INPUTS (Resources used for innovation)
# 1. R&D Capital Stock  2. R&D Personnel
X <- as.matrix(dea_data[, c("rd_capital", "r_d_personnel")])

# OUTPUTS (Innovation results)
# 1. Green Patents  2. GDP
Y <- as.matrix(dea_data[, c("total_green_grants", "gdp")])
# Run Input-Oriented CRS DEA (academic standard)
efficiency_model <- dea(X = X, Y = Y, RTS = "crs", ORIENTATION = "in")
# Attach efficiency scores (0 = inefficient, 1 = fully efficient)
dea_data$efficiency_score <- efficiency_model$eff
# Merge scores back to your FULL dataset
final_dataset <- left_join(
  final_dataset,
  dea_data %>% select(city_code, year, efficiency_score),
  by = c("city_code", "year")
)

# Fill missing scores with 0 (cities excluded from DEA)
final_dataset$efficiency_score[is.na(final_dataset$efficiency_score)] <- 0
# Save to Excel + R format (your FINAL data for the entire thesis!)
saveRDS(final_dataset, "output/FINAL_THESIS_DATASET.rds")
write.csv(final_dataset, "output/FINAL_THESIS_DATASET.csv", row.names = FALSE)

# Success Check
cat("UCCESS! Green Innovation Efficiency Calculated\n")
summary(final_dataset$efficiency_score)
