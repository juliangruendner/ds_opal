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

the r server connection still needs to be configured, for this navigate to the folder "/tmp/opal/conf" on your docker host

open the file "opal-config.properties" and change the Rserve host configuration:
org.obiba.opal.Rserve.host=<insert name of docker rserver container here "e.g. dockeropal_rserver_1">

your r server container name sould be "datashield_rserver" if you have changed the docker-compose as described above.

### STEP 3 - start your datashield environment

nagivate to your repo folder in your command line and execute
docker-compose up

### STEP 4 - Configure mongo db Connection

In your browser go to http://localhost:8880/ui/index.html

login to the administration interface using:
username: administrator
password: password

The standard db configuration has to be changed:
go to Administration > Databases and edit the db Connections

example db connection for docker container "mongodb://datashield_mongo/opal_data"
note that the part datashield_mongo might change with your docker configuration so double check your container names

### STEP 5 - Test the R Server with Test Data
Execute the following steps of this website
https://wiki.obiba.org/display/OPALDOC/How+to+install+and+use+Opal+and+DataSHIELD+for+Data+Harmonization+and+Federated+Analysis
:
2.3 Test the R Server with Test Data
make sure to change:
o <- opal.login(username='administrator', password='password', url='https://localhost:8443')
to
o <- opal.login(username='administrator', password='password', url='http://localhost:8880')
to avoid ssh connection problems

### STEP 6 - Setup data for Testing

Execute the following steps of this website

Download the Test data here:

6.2.1 Uploading data for testing

https://wiki.obiba.org/download/attachments/42894059/LifeLines.sav?version=1&modificationDate=1509977699000&api=v2

In your browser go to http://localhost:8880/ui/index.html

login to the administration interface using:
username: administrator
password: password

Some test data will be imported from a file. This file needs to be accessible from the Opal server. For that purpose, Opal has a "file system" where the data files can be uploaded.

From the "Dashboard" page, click on "Manage Files":

Navigate to the directory where the data file will be uploaded.

Click on the "Upload" button; this will open a "File Upload" window which allows you to select a file to upload from your computer.

Click on "Choose File" and select the LifeLines.sav file you have saved at section 2.1 . Once done, click on the "Upload" button.

6.2.2 Create a Project and Import Data
In Opal, a project is the workspace for managing data. It is required to create a project before importing data into Opal.

Go to the "Projects" page.

Add a Project by clicking on the "Add Project" button. Then, in the "Add Project" popup window,

Enter "Test" in the name field,

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

Give the user the name “test” and the password "test"

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

on your command line execute:

docker exec -it datashield_datashield bash
cd datashield
R -f datashield.r
