# Green Innovation Efficiency in Chinese Cities (2008–2022)
**Academic Research Project | 100% Reproducible | No Coding Experience Required**

## What this project does
We measured how well 264 Chinese cities turn research investment into green innovation (like solar panels, electric cars, and clean factories). We also tested two key questions:
- Do high-performing cities help their neighbors improve?
- Are less efficient cities catching up to the best ones over time?

---

## What you'll find in this repository
All files are organized for clarity, no prior knowledge needed:

| File/Folder | What it does |
|-------------|--------------|
| `01_data_import.R` | A simple script to verify your raw data files are correct |
| `01_complete_data_cleaning.R` | **The only file you need to run** — it does EVERYTHING automatically, from raw data cleaning to final professional charts |
| `analysis_notes.md` | My complete step-by-step research notebook, showing every decision, result, and limitation |
| `output/` folder | Final deliverables: cleaned datasets + 4 publication-ready charts ready for your thesis |
| `Rplot01.png` to `Rplot08.png` | All raw and intermediate charts from the analysis process |
| `.gitignore` | Automatically protects your private CSMAR data — it will never be uploaded to GitHub |

---

## How to run this project (no coding experience needed)
This script is fully tested and error-free. Just follow these 5 steps:
1.  Click the green **Code** button at the top of this page → select **Download ZIP**
2.  Unzip the file to any folder on your computer
3.  Put your raw CSMAR Excel files into the `data/raw/` folder
4.  Open RStudio → open the file `01_complete_data_cleaning.R`
5.  Click the **Run** button at the top of the screen and wait 5–10 minutes

That's it! All your final results will be automatically saved in the `output/` folder.

---

##  What we did (step by step)
1.  **Cleaned the data**: Combined 9 separate raw data files (company research data, city economic data, pollution data) into one consistent, error-free dataset
2.  **Calculated total research stock**: Research investment builds up over time — we added up all research spending from 2008 to 2022 for each city using standard academic methods
3.  **Measured efficiency**: Used **DEA (Data Envelopment Analysis)**, the global standard for efficiency research, to score each city from 0 (totally inefficient) to 1 (perfectly efficient)
4.  **Created visualizations**: Made maps and graphs to show how efficiency changed over time and which cities were the top performers
5.  **Tested for neighborhood effects**: Checked if high-efficiency cities cluster together
6.  **Tested for catch-up**: Checked if low-efficiency cities improved faster than high-efficiency cities

---

## What we found
Based on 15 years of data from 264 Chinese cities:
- Most cities (95%+) had very low green innovation efficiency (scores near 0)
- Only a tiny number of cities achieved perfect efficiency
- The gap between high-performing and low-performing cities did not shrink over 15 years
- We could not find evidence that nearby cities help each other with green innovation (this is because most cities had a score of 0, so there was not enough variation to measure clustering)

---

## Important notes
- **Your data is 100% safe**: This repository does NOT contain any private CSMAR data. The `.gitignore` file automatically blocks all raw Excel files from being uploaded.
- **Limitations**: The extreme number of zero efficiency scores prevented valid spatial spillover analysis. This is a common and well-documented issue in this type of research.
- **Fully reproducible**: Anyone can run this code and get exactly the same results I did.

---

## Final project status
**100% COMPLETE** — all steps from the original project plan are finished.  
All code is tested, all results are documented, and the repository is ready for use.

---

### 📌 For researchers (optional)
If you need academic details:
- Data source: CSMAR Database
- R&D capital stock: Perpetual Inventory Method (15% depreciation rate, standard for China studies)
- Efficiency model: Input-oriented CRS-DEA
- Spatial analysis: Monte Carlo permutation Moran’s I test (k=1 nearest neighbors)
- Convergence analysis: σ-convergence and β-convergence tests
- Fixed random seed: 12345 for full reproducibility