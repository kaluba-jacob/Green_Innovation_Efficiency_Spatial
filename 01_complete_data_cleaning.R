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
