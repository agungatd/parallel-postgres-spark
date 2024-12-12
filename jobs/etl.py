from multiprocessing.pool import ThreadPool
from itertools import product
from functools import reduce
from pyspark.sql import SparkSession, DataFrame
import logging as log


def combine_dataframes(dataframes):
    """
    Combine a list of Spark DataFrames into a single DataFrame.
    
    Args:
        dataframes (list): A list of Spark DataFrames to be combined
    
    Returns:
        pyspark.sql.DataFrame: A single combined DataFrame
    """
    # Remove any None or empty DataFrames
    valid_dataframes = [df for df in dataframes if df is not None and not df.count() > 0]
    
    if not valid_dataframes:
        return None
    
    # If only one DataFrame, return it
    if len(valid_dataframes) == 1:
        return valid_dataframes[0]
    
    # Use reduce to union all DataFrames
    return reduce(DataFrame.union, valid_dataframes)


def query_table(params):
   spark = SparkSession.builder \
        .appName(f"ETL multiple postgres") \
        .getOrCreate()
   
   connection, table_name = params
   username = connection['username']
   password = connection['password']
   host = connection['host']
   query_str = f"SELECT * FROM {table_name}"
   fetch_size = 30000

   df = spark.read.format("jdbc") \
       .option("url", f"jdbc:postgresql://{host}") \
       .option("query", query_str) \
       .option("user", username) \
       .option("password", password) \
       .option("fetchsize", str(fetch_size)) \
       .option("driver", "org.postgresql.Driver") \
       .load()
   return df


if __name__=='__main__':
    connection_lists = [
        {'username': 'postgres', 'password': 'postgres', 'host': 'postgres-1:5432/postgres_a'},
        {'username': 'postgres', 'password': 'postgres', 'host': 'postgres-2:5432/postgres_b'},
    ]
    table_names = ['table_one', 'table_two', 'table_three']

    with ThreadPool(150) as pool:
        dataframes = pool.map(query_table, product(connection_lists, table_names))
        # print(dataframes) -> output:
        # [DataFrame[id: int, name: string, num: decimal(12,2), created_at: timestamp], ...]

    df = reduce(DataFrame.union, dataframes)
    print(df.show()) 
    
    # print(dataframes.summary().show())
    # log.info(dataframes.summary().show())
