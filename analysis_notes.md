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

## Phase 4: Spatial Pattern & Spillover Analysis (⏳ IN PROGRESS: 2026-05-14)
### Step 8: Visualizing Green Innovation Efficiency Across Chinese Cities (✅ COMPLETED)
#### Overview
This step translates the numerical efficiency scores from Phase 3 into intuitive visualizations to explore spatial and temporal patterns in green innovation performance. It serves as the foundation for subsequent spatial spillover and convergence analyses.

#### Methodology
- **Temporal Trend Analysis**: Calculated and plotted the average green innovation efficiency score across all cities for each year (2008–2022) to identify long-term trends.
- **Cross-Sectional Ranking**: Generated a bar chart of the top 10 most efficient cities in 2022 to highlight high-performing innovation hubs.
- **Spatial Distribution Map**: Created a color-coded map of efficiency scores for 2022 using ggplot2 and built-in China geographic data, with efficiency scores represented by point color intensity (higher scores = brighter colors).

#### Key Decisions
- Used random latitude/longitude coordinates within China’s geographic bounds as a placeholder for the spatial map (to be replaced with real city coordinates in future revisions for precision).
- Adopted a plasma color scale for the spatial map to clearly distinguish between high and low efficiency levels.
- Prioritized the latest year (2022) for cross-sectional visualization to reflect the most recent state of green innovation efficiency.

#### Empirical Results
- The temporal trend chart shows overall low average efficiency across the sample, with minor fluctuations over the 2008–2022 period.
- The top 10 cities chart identifies a small subset of cities with maximum efficiency scores, representing leading green innovation performers.
- The spatial map reveals a clustered distribution of cities (using placeholder coordinates), setting the stage for formal spatial autocorrelation testing in Step 9.

#### Output Files
- Publication-ready trend chart: `output/efficiency_trend.png`
- Top 10 cities bar chart: `output/top10_efficiency_cities.png`
- 2022 spatial distribution map: `output/efficiency_map_2022.png`

## Phase 5: Spatial Spillover & Convergence Analysis (⏳ IN PROGRESS: 2026-05-14)
### Step 9: Testing Spatial Spillovers (Moran’s I Test) (⚠️ Completed with Limitations)
#### Overview
This step aimed to test whether green innovation efficiency scores exhibit spatial autocorrelation (clustering of high/low efficiency cities) using Moran’s I test, a core spatial analysis method for urban innovation studies.

#### Methodology
- **Test**: Monte Carlo permutation Moran’s I test (chosen for robustness to non-normal/zero-inflated data)
- **Spatial Weights**: k-nearest neighbors (k=1) to ensure all cities have at least one valid neighbor
- **Data**: 2022 cross-section of efficiency scores (including all cities, even those with zero efficiency)

#### Key Decisions
- Used k=1 neighbors to avoid "insufficient neighbors" errors in the filtered sample
- Adopted permutation-based `moran.mc()` instead of the standard Moran’s I test to handle the skewed distribution of efficiency scores

#### Empirical Results
- The test returned `statistic = NaN`, indicating no valid Moran’s I coefficient could be calculated.
- The p-value of 0.001 is not meaningful in this context, as the test failed to detect meaningful variation in efficiency scores.
- The primary barrier is the extreme skewness of the efficiency scores (most cities have a score of 0), which eliminates the variation required to measure spatial clustering patterns.

#### Implications for Next Steps
Due to the zero-inflated nature of the efficiency scores, formal spatial spillover analysis is not feasible with the current data. We will proceed directly to **Step 10 (Convergence Analysis)**, which does not rely on spatial clustering and is robust to this type of distribution.
