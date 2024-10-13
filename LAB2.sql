"""
In the below cell you will setup your catalog integration with Polaris.
You will need to replace `<username>` with your previously used username.
You will also need to replace `<client id>` and `<secret id>` with the details from your polaris catalog.
"""

use role accountadmin;
create database if not exists <username>;
create schema if not exists <username>.LAB2;
use schema <username>.LAB2;

CREATE OR REPLACE CATALOG INTEGRATION <username>_polaris_int
CATALOG_SOURCE=POLARIS 
TABLE_FORMAT=ICEBERG 
CATALOG_NAMESPACE='<username>' 
REST_CONFIG = (
CATALOG_URI ='https://tzb93977.snowflakecomputing.com/polaris/api/catalog' 
WAREHOUSE = 'apj_ps_tmup_int'
)
REST_AUTHENTICATION = (
TYPE=OAUTH 
OAUTH_CLIENT_ID='<client id>' 
OAUTH_CLIENT_SECRET='<secret id>' 
OAUTH_ALLOWED_SCOPES=('PRINCIPAL_ROLE:ALL') 
) 
ENABLED=true;

"""
The below cell will test your catalog integration and should return nothing. 
Check your details if you have an issue with the connection. 
Replace <catalog integration> with the name of the catalog integration you just created.
"""

SELECT SYSTEM$LIST_NAMESPACES_FROM_CATALOG('<catalog integration>');

"""
You will need to create an external volume for Snowflake to be able to access the parquet files that make up your Iceberg table. This external volume can be used to access multiple tables.
"""

-- the <catalog_name> created in previous step is demo_catalog_ext.

CREATE OR REPLACE EXTERNAL VOLUME <username>_polaris_exvol_int
  STORAGE_LOCATIONS =
      (
        (
            NAME = 'my-s3-us-west-2'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://apj-ps-tmup/int/'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::087354435437:role/apj_ps_tmup'
            STORAGE_AWS_EXTERNAL_ID = 'polaris_hol'
        )
      );


      """
In the below cells you'll create the Polaris managed Iceberg table. This is often refered to as an Unamanged Iceberg 
table because Snowflake does not manage the Iceberg tables catalog or writing of its files.

You will need to replace <catalog integration> and <external volume> with the object names you just created above.

"""

create or replace iceberg table apj_ps_managed
  catalog = '<catalog integration>'
  external_volume = '<external volume>'
  catalog_table_name = 'apj_ps_managed';


  """
  You should be able to select from the table and see the single record just like in the Jupyter notebook.
  """

  select * from apj_ps_managed;


  insert into apj_ps_managed values (1);

  """
  *** The above SQL fails because this is an unmanaged Iceberg table. In the next lab you will create a Snowflake managed Iceberg table where you will be able to write from Snowflake. ***

  """

  alter iceberg table apj_ps_managed refresh;

  select * from apj_ps_managed;

  



  """
 The lab is complete when you can see the new record. You will now move onto LAB3.
  """