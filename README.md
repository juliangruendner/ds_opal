# datashield_docker

## OPAL and OBIBA
DataShield requires Opal to be installed - see:

OPAL: Opal is the OBiBa’s core database application for epidemiological studies. It is used to build study's central data repositories that integrate under a uniform interface data collected from multiple sources (including Onyx). Using Opal, studies can import, validate, derive, query, report, analyse and export data.

http://www.obiba.org/

https://github.com/obiba/docker-opal



## DataShield and Opal example Docker environment

### STEP 1 - checkout the example docker repository

in your favourite folder execute the following command:
git clone git@github.com:juliangruendner/datashield_docker.git

OR

https://github.com/juliangruendner/datashield_docker.git



### STEP 2 - Configure OPAL - R server Connection

In order to get the data of your environment persisted on your machine the conf of opal is mapped to this repo folder.

The first time you clone this repo the folder does not exist yet. To create the folder you have to start and stop your environment once.

Execute `start.sh` then:

In your browser go to http://localhost:8880/ui/index.html and wait for a startscreen to appear

then execute `stop.sh`

The R-Server connection still needs to be configured, for this navigate to the folder "./ds_data/opal/conf" in this repo

open the file "opal-config.properties" and change the Rserve host configuration:
from `#org.obiba.opal.Rserve.host=` to `org.obiba.opal.Rserve.host=datashield_rserver` (make sure to delete the # at the beginning of the line)

### STEP 3 - start your datashield environment

nagivate to your repo folder in your command line and execute `start.sh`

### STEP 4 - Configure mongo db Connection

In your browser go to http://localhost:8880/ui/index.html

- note it may take a while for the server to start, you can check the server status by typing: docker logs -f datashield_opal    (use ctrl-c to stop showing the logs)

login to the administration interface using:
username: administrator
password: password

opal will ask you to register a database for ids and data.

under Identifiers Database
click on Register, MongoDb and replace `mongodb://localhost:27017/opal_ids` with `mongodb://datashield_mongo:27017/opal_ids`

under Data Databases
for name* add "test"
click on Register, MongoDb and replace `mongodb://localhost:27017/opal_data` with `mongodb://datashield_mongo:27017/opal_data`

### STEP 5- Setup data for Testing

This repo provides you with test data called LifeLines.sav

To Upload the data and set it up proceed as follows:

In your browser go to http://localhost:8880/ui/index.html

login to the administration interface using:
username: administrator
password: password

Some test data will be imported from a file. This file needs to be accessible from the Opal server. For that purpose, Opal has a "file system" where the data files can be uploaded.

From the "Dashboard" page, click on "Manage Files":

Navigate to the directory (projects) where the data file will be uploaded.

Click on the "Upload" button; this will open a "File Upload" window which allows you to select a file to upload from your computer.

Upload the file LifeLines.sav in from this repo.



#### 5.1 Create a Project and Import Data

In Opal, a project is the workspace for managing data. It is required to create a project before importing data into Opal.

Go to the "Projects" page.

Add a Project by clicking on the "Add Project" button. Then, in the "Add Project" popup window,

Enter "test" in the name field,

Select the database you created in step Step 4 as the project’s data store,

Save the project.

Then import data into this project.

Go to the   Test project page, tables section,

Click on the "Import" button to open the "Import Data" window.

For the "Data Format" drop-down, select "SPSS" option and click on the "Next" button.

Under "Data File", click "Browse" to select (tick) the LifeLines.sav file, then click on "Select".

Click on the "Next" button so that you skip the "Configure data import" step.

Tick the checkbox to the left of the LifeLines table and click on the "Next" button.

You can review the data for the table LifeLines to be imported, then click on the "Next" button.

Keep the default setting for data file archiving and click on the "Finish" button.

You can follow the import task progress by going to the tasks section of the project page. Once importation is completed successfully, the LifeLines table should appear in the tables section of the project page.

### STEP 7 - configure a datashield and datashield user on opal entity

Initialise DataShield on Opal server
Each server in the network must be configured the same way so that same computation is done in each Opal for one client request. This is done by using the DataSHIELD-R packages repository.

To install these packages, follow these steps:

Go to the "Administration" page, and click on "DataSHIELD" section.

Click on "Add Package".

Leave the default option: “Install all DataSHIELD packages” and click "Install"

The DataSHIELD packages should appear in the list and the Methods section should also be populated with entries.

Create a user
Now we need to create a user account for the analysis server to be able to run a test analysis against your server:

Go to the "Administration" page, and click on "Users and Groups" section.

Click on "Add User".

Select "Add user with password".

Give the user the name “test” and the password "test123"

Set DataSHIELD Permissions
The FDN user must be given permission to access the server using DataSHIELD.

Go to the “Administration” page, and click on “DataSHIELD” section.

Scroll down the page and Click on “Add Permission”.

Select “Add user permission”.

Type “test” in the name field.

Leave the default selection of “Use” and click on “Save”.

Set Project Permissions
Now it is necessary to set up the permissions for the user on the LifeLines table in the test project.

Go to the “Projects” page and click on the test project.
Go to the tables section and click on the LifeLines table.
Click on the “Permissions” tab.
Click on “Add Permission”.
Select “Add user permission”.
Type “test” in the name field.
Leave the default value of “View dictionary and summaries” and click on “Save”.

### STEP 8 - Login to your R Server and test the connection to your opal entity

navigate to your Repo and execute the R testscript by executing the following command:

```bash
R -f datashield_localhost.r
```
