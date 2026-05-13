# Green Innovation Efficiency Spatial Analysis: Project Log
## Project Overview
- **Research Topic**: Spatial spillover and convergence of green innovation efficiency in Chinese cities
- **Study Period**: 2008–2022
- **Geographic Scope**: Chinese prefecture-level cities
- **Key Research Questions**:
  1. What is the level of green innovation efficiency across Chinese cities?
  2. Do these efficiencies exhibit spatial spillover effects?
  3. What factors drive convergence (or divergence) of efficiency over time?

---

## Phase 1: Data Cleaning & Preparation (Completed: 2026-05-13)
### Data Sources
- Firm-level innovation data (R&D expenditure, green patents)
- City-level economic data (GDP, population, industrial structure)
- City-level pollution data (SO₂ emissions, wastewater, smoke emissions)
### Key Steps & Decisions
1. **Firm-to-City Aggregation**:
   - Aggregated firm-level variables (total R&D, green patents, average firm size) to the city-year level using `dplyr`
   - Handled missing values with `na.rm = TRUE` to avoid data loss

2. **City Data Merging**:
   - Merged firm aggregates with city-level economic/pollution data using `city` and `year` as keys
   - Replaced remaining missing values with 0 (for variables like pollution emissions)

3. **Final Cleaned Dataset**:
   - Total observations: 5,527
   - Cities: 264
   - Variables: Innovation metrics, firm controls, economic indicators, pollution variables

---

## Phase 2: R&D Capital Stock Calculation (Completed: 2026-05-13)
### Methodology
- Used the **Perpetual Inventory Method (PIM)**, the standard approach in green innovation literature
- Formula: $K_t = K_{t-1} \times (1-\delta) + R_t$
  - $K_t$: R&D capital stock in year $t$
  - $\delta$: Depreciation rate (set to **15%**, standard for China-focused studies)
  - $R_t$: Nominal R&D expenditure (adjusted to real terms using GDP as a deflator)
### Key Decisions
1. **Initial Capital Stock (2008)**:
   - Calculated using the formula $K_{2008} = \frac{R_{2008}}{g + \delta}$, where $g$ = average annual R&D growth rate
   - Replaced missing/negative growth rates with 5% (conservative standard)

2. **Handling Missing Data**:
   - Skipped cities with no R&D expenditure in 2008 (resulted in 2,329 NA values for `rd_capital`, which will be filtered out in the next step)

### Results
- `rd_capital` variable added to `final_dataset`
- Saved to `output/final_dataset_with_rd_capital.rds`

---

## Phase 3: Green Innovation Efficiency Calculation (COMPLETED: 2026-05-13)
- Methodology: Input-oriented CRS-DEA (baseline model; SBM-DEA with undesirable outputs planned as robustness check)
- Variables:
  - Inputs: R&D capital stock (`rd_capital`), R&D personnel (`r_d_personnel`)
  - Desirable Outputs: Green patents granted (`total_green_grants`), city GDP (`gdp`)
  - Undesirable Outputs (Planned for robustness): Industrial SO₂ emissions, wastewater discharge, smoke/dust emissions
- Results: Efficiency scores range from 0 (fully inefficient) to 1 (fully efficient), with a mean of 0.0094. Most cities exhibit low green innovation efficiency, with a small subset achieving full efficiency.
- Output: Efficiency scores saved to `output/FINAL_THESIS_DATASET.rds` and `output/FINAL_THESIS_DATASET.csv`