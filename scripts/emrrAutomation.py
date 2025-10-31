import pandas as pd
import numpy as np
import pyodbc
import warnings
import re
import time
import validAreaCodes
from datetime import datetime
from openpyxl import load_workbook
from openpyxl.styles import numbers
from sqlalchemy import create_engine
from pathlib import Path

warnings.filterwarnings("ignore", message="Workbook contains no default style")

CURRENT_DATE = datetime.now().strftime('%m.%d.%y')
QUERY = "ORGWorkbenchQuery.sql"
DRIVER = "ODBC Driver 17 for SQL Server"
SERVER = "YOUR_SERVER_NAME"
DATABASE = "YOUR_DATABASE_NAME"
CONNECTION = (
    f"Driver={DRIVER};"
    f"Server={SERVER}; "
    f"Database = {DATABASE};"
    "Trusted_Connection=yes;"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

def main():

      print("Running Script...")
      startTime = time.time()

      # Connect to server & database
      print(f"Connecting to {SERVER}, database: {DATABASE}")
      engine = create_engine("mssql+pyodbc://", creator=lambda: pyodbc.connect(CONNECTION))

      # Resolve paths for input query
      sql_path = Path(__file__).resolve().parent.parent /'query' / QUERY
      SQL = sql_path.read_text(encoding="utf-8-sig")

       # Execute query
      with engine.begin() as conn:
            conn.exec_driver_sql("USE [Chartfinder_Snap];")
            df = pd.read_sql_query(SQL, conn)

      # Drop Duplicates
      df = df.drop_duplicates(subset="OutreachID")

      # Delete rows where ToGoCharts = 0 
      df['ToGoCharts'] = pd.to_numeric(df['ToGoCharts'], errors='coerce')
      df = df[df['ToGoCharts'] > 0].copy()

      # Project Due Date delete rows of previous years
      df['Project Due Date'] = pd.to_datetime(df['Project Due Date'], errors='coerce')
      df = df[((df['Project Due Date'].dt.year == datetime.now().year) & (df["Project Due Date"].dt.month == datetime.now().month)) | (df['Project Due Date'] > datetime.now())]
      df['Project Due Date'] = df['Project Due Date'].dt.strftime('%m/%d/%Y')
        

      # Filter out bad phone numbers and write them to a seperate sheet called 'Bad Number'
      df = df.drop_duplicates(subset='Phone')
      df['Phone'] = df["Phone"].astype(str).str.replace(r'\D', '', regex=True)
      
      def is_bad_phone(phone):
            if len(phone) != 10:
                  return True
            if phone in ['1234567890', '0123456789','0000000000','1111111111', '2222222222', '3333333333', '4444444444', '5555555555', '6666666666', '7777777777', '8888888888', '9999999999']:
                  return True
            area_code = phone[:3]
            if area_code not in validAreaCodes.vaild_area_codes:
                  return True
            if re.fullmatch(r'(\d{3})\1{2}|(\d{2})\2{3,}', phone):
                  return True
            return False
      
      bad_phone = df['Phone'].apply(is_bad_phone)
      bad_numbers_df = df[bad_phone].copy()
      df = df[~bad_phone]

      # Filter out EMR - Remote Queued and agents
      keep_agent = ((df['Agent'].isna()) | (df['Agent'] == '') | (df['Agent'] == 'MAIN_AGENT')) & (df['RetrievalMethod'] != 'EMR - Remote Queued')
      agents_assigned_df = df[~keep_agent].copy()
      df = df[keep_agent]
      
      # Write the file
      with pd.ExcelWriter(f'EMR - Coordinator - All {CURRENT_DATE}.xlsx', engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name='OutreachWB', index=False)
            bad_numbers_df.to_excel(writer, sheet_name='Bad Number', index=False)
            agents_assigned_df.to_excel(writer, sheet_name='Agent Assigned', index=False)
            
      print(f"'EMR - Coordinator - All {CURRENT_DATE}.xlsx' created!")

      # Open created file
      csv_df = pd.read_excel(f"EMR - Coordinator - All {CURRENT_DATE}.xlsx", engine="openpyxl")

      # Drop columns to match 'Data Dump Template
      data_dump_columns = ['Status', 'OutreachID', 'ProjectID', 'ProjectType', 'Phone', 'LastCall', 'LastFaxDate', 'TotalCallCount', 'TotalCharts', 'ToGoCharts','Address', 'Address2', 'City', 'State', 'Zip', 'FaxNum', 'RetrievalMethod', 'Project Due Date', 'ProjectYear', 'Audit Type', 'DaysSinceCreation']
      csv_df = csv_df[data_dump_columns].copy()

      # Add needed columns to match 'Data Dump Template'
      data_dump_columns = ['top_org', 'parent', 'overall_rank', 'Score', 'Skill', 'DSC', 'sla', 'age' ]
      for columns in data_dump_columns:
            csv_df[data_dump_columns] = ''
      
      # Add top org formula
      csv_df['top_org'] = np.where(csv_df['Status'].fillna('').str.strip().str.lower() == 'unscheduled', 2, 1).astype('int64')

      # Days Since Creation formula
      csv_df['DSC'] = pd.to_numeric(csv_df["DaysSinceCreation"], errors='coerce')

      # SLA(Bussiness Days) formula
      csv_df['LastCall'] = pd.to_datetime(csv_df['LastCall'], errors='coerce')
      yesterday = pd.Timestamp.today().normalize() - pd.Timedelta(days=1)
      mask = csv_df['LastCall'].notna()
      start = csv_df.loc[mask, 'LastCall'].values.astype('datetime64[D]')
      end_exclusive = (yesterday + pd.Timedelta(days=1)).to_datetime64().astype('datetime64[D]')
      sla = np.empty(len(csv_df), dtype=object)
      sla[~mask] = 'Uncalled'
      sla[mask] = np.busday_count(start, end_exclusive).astype(int)
      csv_df['sla'] = sla

      # Age formula
      csv_df['age'] = np.where(csv_df['sla'] == 'Uncalled', csv_df['DSC'], csv_df['sla'])

       # overall_rank sort
      csv_df = csv_df.sort_values(
             by=['top_org', 'age', 'ToGoCharts', 'Project Due Date', 'TotalCallCount'],
             ascending=[True, False, False, True, True]
      ).reset_index(drop=True)

      # Adding sequential numbering to overall_rank
      csv_df['overall_rank'] = range(1, len(csv_df) + 1)

      # Score formula
      lookup_df = csv_df.iloc[:, 4:24]
      lookup_key = lookup_df.columns[0]
      lookup_value = lookup_df.columns[19]
      score_lookup = lookup_df.drop_duplicates(subset=lookup_key).set_index(lookup_key)[lookup_value]
      csv_df['Score'] = csv_df['Phone'].map(score_lookup)

      # Sort by score and rank ascending
      csv_df = csv_df.sort_values(
             by=['Score', 'overall_rank'],
             ascending=[True, True]
             ).reset_index(drop=True)

      # Parent formula
      csv_df['parent'] = (~csv_df.duplicated(subset='Phone')).astype(int)

      # Skill formula
      csv_df['Skill'] = np.where(
             (csv_df['Status'].str.strip().str.lower() == 'unscheduled') & (csv_df['parent'] == 1), 'Unscheduled',
             np.where((csv_df['Status'].str.strip().str.lower() != 'unscheduled') & (csv_df['parent'] == 1), 'Escalated',
             ''
             )
      )

      # Save file as csv
      csv_df.to_csv(f"EMR - Coordinator - All {CURRENT_DATE}.csv", index=False)
      endTime = time.time()
      executionTime = endTime - startTime
      print(f"'EMR - Coordinator - All {CURRENT_DATE}.csv' created! ")
      print(f"Total running time: {int(executionTime //60)} minutes {executionTime %60:.1f} seconds.")

if __name__ == "__main__":

      main()

