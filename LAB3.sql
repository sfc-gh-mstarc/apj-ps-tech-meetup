
"""
In the below cell you will setup your catalog interation with Polaris, this time Snowflake will be the 
primary Iceberg catalog and we will sync our Iceberg tables to Polaris to allow other compute engines to read from this table.
You will need to replace `<username>` with your previously used username, either CAS2 login or email address.
You will also need to replace `<client id>` and `<secret id>` with the details from your polaris catalog connection to `apj_ps_tmup_ext`.
"""
use role accountadmin;
create database if not exists <username>;
create schema if not exists <username>.LAB3;
use schema <username>.LAB3;


CREATE OR REPLACE CATALOG INTEGRATION <username>_polaris_ext
CATALOG_SOURCE=POLARIS 
TABLE_FORMAT=ICEBERG 
CATALOG_NAMESPACE='default' 
REST_CONFIG = (
CATALOG_URI ='https://tzb93977.snowflakecomputing.com/polaris/api/catalog' 
WAREHOUSE = 'apj_ps_tmup_ext'
)
REST_AUTHENTICATION = (
TYPE=OAUTH 
OAUTH_CLIENT_ID='`<client id>' 
OAUTH_CLIENT_SECRET='<secret id>' 
OAUTH_ALLOWED_SCOPES=('PRINCIPAL_ROLE:ALL') 
) 
ENABLED=true;


"""
The below cell with test your catalog integration and should return an empty array `[]`. 
Replace <catalog integration> with the name of the integration you creted above. Check your client details 
if you have an issue with the connection.
"""

SELECT SYSTEM$LIST_NAMESPACES_FROM_CATALOG('<catalog integration>');

"""
You will need to create an external volume for Snowflake to be able to write the parquet files that make up your Iceberg table. 
This external volume can be used to access multiple tables. Replace `<username>` in the below cells with your username
"""

CREATE OR REPLACE EXTERNAL VOLUME <username>_polaris_exvol_ext
  STORAGE_LOCATIONS =
      (
        (
            NAME = 'my-s3-us-west-2'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://apj-ps-tmup/ext/'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::087354435437:role/apj_ps_tmup'
            STORAGE_AWS_EXTERNAL_ID = 'polaris_hol'
        )
      );


"""
Next create the Iceberg table that will be synced to Polaris catalog. 
You can see the extra parameter CATALOG_SYNC Replace <catalog integration> and <external volume> with the catalog 
integration name and external volumne name you created above.
"""


CREATE OR REPLACE ICEBERG TABLE test_table_managed (col1 int)
  CATALOG = 'SNOWFLAKE'
  EXTERNAL_VOLUME = '<external volume>'
  BASE_LOCATION = 'test_table_managed'
  STORAGE_SERIALIZATION_POLICY = 'COMPATIBLE'
  CATALOG_SYNC = '<catalog integration>'; 


  select * from test_table_managed;


insert into test_table_managed values (3);
  

  select * from test_table_managed;

  """
  The below command forces a sync to Polaris. It is not a requirement to run it, but if you table hasn't synced to Polaris in several minutes it can show the error that occured.
  """

  SELECT VALUE[0]::STRING AS tableName,
       VALUE[1]::BOOLEAN notificationStatus,
       VALUE[2]::STRING errorCode,
       VALUE[3]::STRING errorMessage
  FROM TABLE(FLATTEN(PARSE_JSON(
    SELECT SYSTEM$SEND_NOTIFICATIONS_TO_CATALOG(
      'SCHEMA',
      'LAB3'))));

      """
      The Lab is complete when you can see the table `test_table_managed` under your namespace in Polaris.

      """

      