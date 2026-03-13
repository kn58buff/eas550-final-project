import os
import kagglehub
from pathlib import Path
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "../../data/DataCoSupplyChainDataset.csv"

class DataProcessor:
    def __init__(self, data_path = DATA_PATH):
        self.data_path = data_path
    
    def load_data(self):
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

    def check_data(df):
        """
            Preprocess the dataframe.

            Checks for null and missing values.

            TODO:
                Check data types and convert to correct type if needed.
                Remove columns: [Customer Email, Customer Password] -> both have 1 value (XXXXXXXXX), probably scrubbed from data 

                Decide to remove [Product Status] or not. Every item in this dataset is available (product status = 0), but could justify keeping it as a design choice for the possibility of unavailable items.
        """
        # Check 1: Missing values
        print(f"Dataset size: {df.shape}")

        nulls = df.isnull().sum().where(lambda x: x > 0).dropna()
        
        for index, value in nulls.items():
            print(f"{index}: {int(value)} missing values; {100 * int(value) / len(df):.4f}% of data")

        # Drop Product Description, every entry is missing this
        df.drop(columns=["Product Description"], inplace=True)

        print("Dropped column Product Description")

        # Drop Order Zipcode - not necessarily important info
        df.drop(columns=["Order Zipcode"], inplace=True)
        print("Dropped column Order Zipcode")

        return df