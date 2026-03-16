import psycopg2 
import psycopg2.extras; psycopg2.extensions.set_wait_callback(psycopg2.extras.wait_select)
import pandas as pd
import sys
import os

sys.path.append(os.path.abspath("."))

from src.utils.db_connection import get_engine
from src.utils.processing import DataProcessor
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "../../data/DataCoSupplyChainDataset.csv"

engine = get_engine()
processor = DataProcessor(DATA_PATH)

class Loader():
    """
        Class for loading data into the database provisioned on Neon.
        Takes the engine created using get_engine() as an argument.
    """

    def __init__(self, engine, processor):
        self.engine = engine
        self.processor = processor
        self.table_names = ["departments", "categories", "products", "customers", "orders", "order_items"] # table names, in load order
        self.data = None
    
    def _process_data(self):
        self.data = self.processor.run() # dictionary of data
    
    def _load_dataframe(self):
        for table_name in self.table_names:

            df = self.data[table_name]
            print(f"\nLoading table: {table_name}")
            print(f"Columns: {list(df.columns)}")

            pk = df.columns[0]

            existing = pd.read_sql(f"SELECT {pk} FROM {table_name}", self.engine)

            # Remove rows already present in DB
            df = df[~df[pk].isin(existing[pk])]

            print(f"{table_name}: {len(df)} new rows to insert")

            if not df.empty:
                df.to_sql(table_name, self.engine, if_exists = "append", index = False, method = "multi")

                print(f"Inserted {df.shape[0]} rows into table: {table_name}")
            else:
                print(f"No new rows to insert for table: {table_name}")

    def _validate(self):
        """
            Checks inserted data against expected data.
            Checks: number of rows inserted
        """
        valid = True # validation flag

        for table in self.table_names:
            # Sample first 5 rows from DB, sorted by PK
            primary_key = self.data[table].columns[0] # first column is PK
            df_expected = self.data[table].sort_values(by = primary_key)
            expected_rows = df_expected.shape[0]
            expected_head = df_expected.head(5)

            sampled_head = pd.read_sql(f"SELECT * FROM {table} ORDER BY {primary_key} LIMIT 5", con = self.engine)

            # Same column order
            sampled_head = sampled_head[expected_head.columns]

            print(expected_head)
            print(sampled_head)

            # Check that all entries were added correctly
            sampled_rows = pd.read_sql(f"SELECT COUNT(*) AS total_rows FROM {table}", con = self.engine)["total_rows"][0]
            if expected_rows == sampled_rows:
                print(f"All rows of {table} were added. ({sampled_rows})")
            else:
                print(f"{sampled_rows} of {expected_rows} added for table {table}")
                valid = False

        return valid
    
    def run_loader(self):
        self._process_data()
        
        # Uncomment this once it is made idempotent
        self._load_dataframe()

        # checks to see data is loaded correctly
        if self._validate():
            print(f"Data loaded successfully.")
        else:
            raise AssertionError("Sample queries did not return expected values.")


data_loader = Loader(engine, processor)

if __name__ == "__main__":
    data_loader.run_loader()
