import os
import kagglehub
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "../../data/DataCoSupplyChainDataset.csv"


def check_and_download_data(file_path):
    """
        Checks if the dataset is already downloaded.
        file_path should be ../../data/DataCoSupplyChainDataset.csv

        If the file does not exist, then it will be downloaded to the above file path.
    """
    if file_path.exists():
        print(f"File '{file_path}' already exists. Skipping download.")
    else:
        kagglehub.dataset_download(
            "shashwatwork/dataco-smart-supply-chain-for-big-data-analysis",
            output_dir=str(file_path.parent),
        )

def preprocess(df):
    """
        Preprocess the dataframe.

        TODO:
            Check null / missing values, decide how to handle them
            Check data types and convert to correct type if needed.
    """

check_and_download_data(DATA_PATH)
