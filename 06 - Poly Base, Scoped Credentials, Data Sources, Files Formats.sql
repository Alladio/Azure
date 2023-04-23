-- Lab - Loading data using PolyBase
-- Here we are following the same process of creating an external table

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@ssw0rd@123' ;

-- If you want to see existing database scoped credentials
SELECT * FROM sys.database_scoped_credentials

CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH
  IDENTITY = 'datalakealladio1',
  SECRET = '*****';

-- If you want to see the external data sources
SELECT * FROM sys.external_data_sources 


CREATE EXTERNAL DATA SOURCE log_data
WITH (    LOCATION   = 'abfss://datacontainer@datalakealladio1.dfs.core.windows.net',
          CREDENTIAL = AzureStorageCredential,
          TYPE = HADOOP
)

-- If you want to see the external file formats

SELECT * FROM sys.external_file_formats

CREATE EXTERNAL FILE FORMAT parquetfile  
WITH (  
    FORMAT_TYPE = PARQUET,  
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'  
);


-- Drop the existing logdata table
DROP TABLE [logdata]

-- Create the external table as the admin user

CREATE EXTERNAL TABLE [logdata_external]
(
 [Id] [int] NULL,
	[Correlationid] [varchar](200) NULL,
	[Operationname] [varchar](200) NULL,
	[Status] [varchar](100) NULL,
	[Eventcategory] [varchar](100) NULL,
	[Level] [varchar](100) NULL,
	[Time] [datetime] NULL,
	[Subscription] [varchar](200) NULL,
	[Eventinitiatedby] [varchar](1000) NULL,
	[Resourcetype] [varchar](1000) NULL,
	[Resourcegroup] [varchar](1000) NULL
)
WITH (
 LOCATION = '/parquet/',
    DATA_SOURCE = log_data,  
    FILE_FORMAT = parquetfile
)

-- Now create a normal table by selecting all of the data from the external table

CREATE TABLE [logdata]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
CLUSTERED INDEX (id)   
)
AS
SELECT  *
FROM  [logdata_external];








