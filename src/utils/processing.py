import os
import kagglehub
from pathlib import Path
import pandas as pd



BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "../../data/DataCoSupplyChainDataset.csv"

class DataProcessor:
    def __init__(self, data_path = DATA_PATH):
        self.data_path = data_path
    
    def _load_data(self):
        """
            Loads the dataset into a pandas dataframe.

            If the file does not exist, then it will be downloaded to the above file path.
        """

        # Download dataset if it does not exist
        if self.data_path.exists():
            print(f"File '{self.data_path}' already exists. Skipping download.")
        else:
            kagglehub.dataset_download(
                "shashwatwork/dataco-smart-supply-chain-for-big-data-analysis",
                output_dir=str(self.data_path.parent),
            )
        
        df = pd.read_csv(self.data_path, encoding = "ISO-8859-1")

        return df
    
    # Reminder to have these cleaning functions as part of the cleaning suite/pipeline.
    def _rename_columns(self, df):
        """
        Convert column names to clean snake_case format.
        """

        df.columns = (df.columns.str.strip().str.lower().str.replace(" ", "_").str.replace(r"[()]", "", regex=True).str.replace(r"[^a-z0-9_]", "", regex=True))

        df = df.rename(columns = {
            "type": "payment_type",
            "days_for_shipping_real": "days_shipping_real",
            "days_for_shipment_scheduled": "days_shipping_scheduled",
            "customer_city": "city",
            "customer_country": "country",
            "customer_email": "email",
            "customer_fname": "first_name",
            "customer_lname": "last_name",
            "customer_segment": "segment",
            "customer_state": "state",
            "customer_street": "street",
            "customer_zipcode": "zipcode",
            "order_date_dateorders": "order_date",
            "order_item_discount": "discount",
            "order_item_discount_rate": "discount_rate",
            "order_item_profit_ratio": "profit_ratio",
            "order_item_quantity": "quantity",
            "order_item_total": "item_total",
            "product_card_id": "product_id",
            "shipping_date_dateorders": "shipping_date",
            })

        print("Columns renamed successfully.")
        print(df.columns)

        return df

    def _check_data(self, df):
        """
            Preprocess the dataframe.
            Checks for null and missing values. Checks for duplicate values.

            Removed columns: product_description and customer_password
        """
        print(f"Dataset size: {df.shape}")

        # Check #1: Duplicates
        count_of_duplicates = df.duplicated().sum()
        print(f"Number of duplicate rows: {count_of_duplicates}")

        # Check 2: Missing values
        nulls = df.isnull().sum().where(lambda x: x > 0).dropna()
        
        for index, value in nulls.items():
            print(f"{index}: {int(value)} missing values; {100 * int(value) / len(df):.4f}% of data")

        # Drop Product Description, every entry is missing this
        df.drop(columns=["product_description"], inplace=True)

        print("Dropped column Product Description")

        # Drop customer password, it has been scrubbed
        df.drop(columns = ["customer_password"], inplace = True)
        print("Dropped column Customer Password")

        return df
    
    def _split_data(self, df):
        """
            Splits the data into multiple DataFrames corresponding to each table in the database.
        """
        SCHEMA = {
            "departments": {
                "columns": ["department_id", "department_name"],
                "primary": ["department_id"]
            },
            "categories": {
                "columns": ["category_id", "category_name", "department_id"],
                "primary": ["category_id"]
            },
            "products": {
                "columns": ["product_id", "product_name", "product_price", "product_status", "product_image", "category_id"],
                "primary": ["product_id"]
            },
            "customers": {
                "columns": ["customer_id", "first_name", "last_name",
                            "email", "segment", "street",
                            "city", "state", "country",
                            "zipcode", "latitude", "longitude", "market"],
                "primary": ["customer_id"]
            },
            "orders": {
                "columns": ["order_id", "order_customer_id", "order_date", "shipping_date",
                            "order_status", "shipping_mode", "delivery_status", "late_delivery_risk",
                            "order_city", "order_state", "order_country", "order_zipcode",
                            "order_region", "days_shipping_real", "days_shipping_scheduled", "order_profit_per_order",
                            "payment_type"],
                "primary": ["order_id"]
            },
            "order_items": {
                "columns": ["order_item_id", "order_id", "product_id", "quantity",
                            "product_price", "discount", "discount_rate", "profit_ratio",
                            "item_total", "sales", "benefit_per_order", "sales_per_customer"],
                "primary": ["order_item_id"]
            }
        }

        tables = {}

        for table_name, config in SCHEMA.items():
            cols = config["columns"]
            keys = config["primary"]

            table_df = df[cols].drop_duplicates(subset = keys)

            tables[table_name] = table_df

        # After splitting, need to rename columns that are present in multiple tables (non keys)
        tables["order_items"].rename(columns = {"product_price": "order_item_product_price"}, inplace = True)

        print(f"Split data into tables corresponding to schema.")
        return tables

    def run(self):
        df = self._load_data()
        df = self._rename_columns(df)
        df = self._check_data(df)
        tables = self._split_data(df)

        print(f"Final shape of data: {df.shape}")
        print(f"Tables created: {len(tables)}")
        
        return tables

processor = DataProcessor()

tables = processor.run()