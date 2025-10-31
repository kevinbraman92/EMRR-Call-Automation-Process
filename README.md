# 📞 EMRR Call Automation Process

## 📖 Overview
The **EMRR Call Automation Process** is a Python-based ETL project that queries, filters, and formats **Electronic Medical Record (EMR)** data for call campaign coordination.  
It automates the retrieval and cleanup of EMR provider records from **Microsoft SQL Server**, validates phone numbers, calculates business-day SLAs, and ranks outreach priorities for call scheduling teams.

This codebase is a **sanitized demonstration** of production logic used for Datavant operational workflows.

---

## ⚙️ Key Features
- 🔌 **Automated SQL Server Query** — Executes a complex query (`ORGWorkbenchQuery.sql`) to extract EMR outreach and contact data.
- 🧹 **Data Validation & Cleaning** — Filters duplicate entries, invalid phone numbers, and outdated project records.
- 🧾 **Phone Number Verification** — Uses a reference list of valid U.S. area codes to identify and isolate bad contact numbers.
- 📊 **Automated Ranking Logic** — Calculates key performance fields (`top_org`, `overall_rank`, `Skill`, and `SLA`) for outreach prioritization.
- 📈 **Multi-Sheet Excel Output** — Generates an Excel file with three sheets:
  - **OutreachWB** – Primary cleaned dataset  
  - **Bad Number** – Filtered invalid phone records  
  - **Agent Assigned** – Records already assigned to active agents
- 💡 **CSV Export for Campaign Uploads** — Produces a ready-to-load CSV for downstream systems.

---

## 🧠 Technical Stack
| Category | Tools / Libraries |
|-----------|--------------------|
| Language | Python 3 |
| Database | Microsoft SQL Server |
| Libraries | pandas, numpy, pyodbc, SQLAlchemy, openpyxl, re |
| Other | Batch automation (`runEMRRAutomation.bat`) |

---

## 🧩 Process Flow
1. **Extract**
   - Connects to SQL Server via `pyodbc` and runs `ORGWorkbenchQuery.sql`.
   - Loads query results into a pandas DataFrame.

2. **Transform**
   - Cleans and standardizes phone, address, and project fields.
   - Removes outdated or duplicate outreach records.
   - Validates phone numbers against known area codes and identifies bad data.

3. **Load**
   - Outputs an Excel workbook (`EMR - Coordinator - All MM.DD.YY.xlsx`) with categorized sheets.
   - Exports a ranked CSV (`EMR - Coordinator - All MM.DD.YY.csv`) used by EMR call teams.

---

## 📂 File Overview
| File | Description |
|------|--------------|
| `scripts/emrrAutomation.py` | Main ETL script that performs extraction, transformation, and export. |
| `query/ORGWorkbenchQuery.sql` | SQL query used to retrieve EMR outreach data from ChartFinder. |
| `runEMRRAutomation.bat` | Batch file for executing the automation in one click. |
| `README.md` | Project documentation. |

## 📈 Example Outputs
**Excel Sheets**
| Sheet Name | Purpose |
|-------------|----------|
| `OutreachWB` | Cleaned outreach dataset for coordinators |
| `Bad Number` | Invalid phone entries requiring review |
| `Agent Assigned` | Records already assigned to field agents |

**CSV Columns**
- `top_org` – Prioritization flag for outreach urgency  
- `overall_rank` – Sequential rank across all valid records  
- `Skill` – Categorization of unscheduled vs escalated records  
- `SLA` / `age` – Business-day and age calculations for follow-up timing  

---

## 🧠 Learning Outcomes
Through this project, I demonstrated:
- Designing a **Python-based ETL pipeline** for healthcare data operations  
- Integrating **SQL queries and data validation** for call-center readiness  
- Implementing **business logic and KPIs** with pandas and NumPy  
- Automating **Excel and CSV reporting** for field coordination teams  

---

## 📬 Contact
**Kevin Braman**  
📧 [kevinbraman92@gmail.com](mailto:kevinbraman92@gmail.com)  
💼 [LinkedIn](https://www.linkedin.com/in/kevin-braman-a7974a129/)  
💻 [GitHub](https://github.com/kevinbraman92)

---

⭐ *If you found this project useful or inspiring, consider giving it a star!*
