# File Inspection Script
# Outputs the structure of all your raw data files
library(tidyverse)
library(readxl)
library(here)

# Set your project root (make sure this points to your Green_Innovation_Efficiency_Spatial folder)
setwd("C:/Users/hp/Desktop/Green_Innovation_Efficiency_Spatial")

# List of all your raw files
file_list <- list(
  "上市公司基本信息年度表.xlsx",
  "研发投入情况表.xlsx",
  "上市公司绿色专利获得情况.xlsx",
  "上市公司绿色专利申请情况.xlsx",
  "资产负债表.xlsx",
  "利润表.xlsx",
  "数据7.xlsx",
  "数据8.xlsx",
  "数据9.xlsx"
)

# Inspect each file
for (file in file_list) {
  cat("\n\n=====================================\n")
  cat(paste0("FILE: ", file, "\n"))
  cat("=====================================\n")
  
  # Read the file
  df <- read_excel(here("data", "raw", file), skip = 1)
  
  # Output column names
  cat("COLUMN NAMES:\n")
  print(colnames(df))
  
  # Output first 5 rows
  cat("\nFIRST 5 ROWS:\n")
  print(head(df, 5))
  
  # Output data types
  cat("\nDATA TYPES:\n")
  print(sapply(df, class))
}
