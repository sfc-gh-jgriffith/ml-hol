-- Using accountadmin is often suggested for quickstarts, but any role with sufficient privledges can work
USE ROLE ACCOUNTADMIN;

-- get marketplace data 
-- CYBERSYN GOVERNMENT ESSENTIALS

-- Create development database, schema for our work: 
CREATE OR REPLACE DATABASE quickstart;
CREATE OR REPLACE SCHEMA ml_functions;

-- Use appropriate resources: 
USE DATABASE quickstart;
USE SCHEMA ml_functions;

-- Create warehouse to work with: 
CREATE WAREHOUSE IF NOT EXISTS quickstart_wh;
USE WAREHOUSE quickstart_wh;

-- Set search path for ML Functions:
-- ref: https://docs.snowflake.com/en/user-guide/ml-powered-forecasting#preparing-for-forecasting
ALTER ACCOUNT
SET SEARCH_PATH = '$current, $public, SNOWFLAKE.ML';

-- Create a csv file format to be used to ingest from the stage: 
CREATE OR REPLACE FILE FORMAT quickstart.ml_functions.csv_ff
    type = 'csv'
    SKIP_HEADER = 1,
    COMPRESSION = AUTO;

-- Create an external stage pointing to AWS S3 for loading sales data: 
CREATE OR REPLACE STAGE s3load 
    COMMENT = 'Quickstart S3 Stage Connection'
    url = 's3://sfquickstarts/frostbyte_tastybytes/mlpf_quickstart/'
    file_format = quickstart.ml_functions.csv_ff;

-- Define Tasty Byte Sales table
CREATE OR REPLACE TABLE quickstart.ml_functions.tasty_byte_sales(
  	DATE DATE,
	PRIMARY_CITY VARCHAR(16777216),
	MENU_ITEM_NAME VARCHAR(16777216),
	TOTAL_SOLD NUMBER(17,0)
);

-- Ingest data from S3 into our table
COPY INTO quickstart.ml_functions.tasty_byte_sales 
    FROM @s3load/ml_functions_quickstart.csv;

CREATE OR REPLACE NOTEBOOK "ML Functions Quickstart"
    FROM '@git.public.ml_functions/branches/main/QUICKSTART ML FUNCTIONS'
    MAIN_FILE = 'notebook_app.ipynb'
    QUERY_WAREHOUSE = quickstart_wh;



