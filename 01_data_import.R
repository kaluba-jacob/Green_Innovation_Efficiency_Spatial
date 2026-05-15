# ==============================================
# 01: Raw CSMAR Data Inspection Script
# ==============================================
# PURPOSE: This is the FIRST script you run after downloading your raw data
# It checks the structure, columns, and data types of ALL your raw Excel files
# to make sure everything is correct before you start cleaning the data

# Load required packages
library(tidyverse)  # For data manipulation and reading files
library(readxl)  # For reading Excel files
library(here)  # For automatic project path management (no hardcoded folders!)

# Set my project root (make sure this points to my Green_Innovation_Efficiency_Spatial folder)
setwd("C:/Users/hp/Desktop/Green_Innovation_Efficiency_Spatial")

# --------------------------
# List of ALL your raw data files (from CSMAR)
# --------------------------
# Add comments next to each file to remember what it contains
raw_files <- list(
  "上市公司基本信息年度表.xlsx",  # Firm basic information (annual)
  "研发投入情况表.xlsx",  # Firm R&D expenditure data
  "上市公司绿色专利获得情况.xlsx",  # Green patents granted (firm-level)
  "上市公司绿色专利申请情况.xlsx",  # Green patents applied (firm-level)
  "资产负债表.xlsx",  # Firm balance sheet data
  "利润表.xlsx",  # Firm income statement data
  "数据7.xlsx",  # City-level economic data (GDP, population)
  "数据8.xlsx",  # City-level industrial structure data
  "数据9.xlsx"   # City-level pollution emissions data
)

# --------------------------
# Inspect every raw file automatically
# --------------------------
# This loop will print a full report for each file in your list
for (file in file_list) {
  cat("\n\n=====================================\n")
  cat(paste0("FILE: ", file, "\n"))
  cat("=====================================\n")
  
  # Read the Excel file
  # skip = 1: CSMAR files always have a description row first, actual headers start at row 2
  df <- read_excel(here("data", "raw", file), skip = 1)
  
  # 1. Show all column names 
  cat("COLUMN NAMES:\n")
  print(colnames(df))
  
  # 2. Show first 5 rows 
  cat("\nFIRST 5 ROWS:\n")
  print(head(df, 5))
  
  # 3. Show data types
  cat("\nDATA TYPES:\n")
  print(sapply(df, class))
}

# --------------------------
# What to check after running this:
# --------------------------
# 1. All column names are present and correct
# 2. No obvious errors in the first 5 rows (e.g., negative R&D spending)
# 3. Numeric columns are marked as "numeric" (not "character")
# 4. All 9 files are inspected without errors