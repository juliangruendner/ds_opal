# datashield_docker

## OPAL and OBIBA
DataShield requires Opal to be installed - see:

OPAL: Opal is the OBiBa’s core database application for epidemiological studies. It is used to build study's central data repositories that integrate under a uniform interface data collected from multiple sources (including Onyx). Using Opal, studies can import, validate, derive, query, report, analyse and export data.

http://www.obiba.org/

https://github.com/obiba/docker-opal

### STEP 1 - Configure OPAL docker for production

In this repo open the docker_compose.prod.yml and change variable
`OPAL_ADMINISTRATOR_PASSWORD=password` from password to a secure password of your choice


### STEP 2 - Configure OPAL - R server Connection

In order to get the data of your environment persisted on your machine the conf of opal is mapped to this repo folder.

The first time you clone this repo the folder does not exist yet. To create the folder you have to start and stop your environment once.

Execute `start_prod.sh` then:

In your browser go to http://localhost:8880/ui/index.html and wait for a startscreen to appear

then execute `stop_prod.sh`

The R-Server connection still needs to be configured, for this navigate to the folder "./ds_data/opal/conf" in this repo

open the file "opal-config.properties" and change the Rserve host configuration:
from `#org.obiba.opal.Rserve.host=` to `org.obiba.opal.Rserve.host=datashield_rserver` (make sure to delete the # at the beginning of the line)

### STEP 3 - start your datashield environment

nagivate to your repo folder in your command line and execute `start_prod.sh`

### STEP 4 - Configure mongo db Connection

In your browser go to http://localhost:8880/ui/index.html

- note it may take a while for the server to start, you can check the server status by typing: docker logs -f datashield_opal    (use ctrl-c to stop showing the logs)

login to the administration interface using:
username: administrator
password: <your chosen password>

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


### STEP 8 - install ds packages

Go to the “Administration” page, and click on “DataSHIELD” section.

Click on "Add Package".

Leave the default option: “Install all DataSHIELD packages” and click "Install"

The DataSHIELD packages should appear in the list and the Methods section should also be populated with entries.

*if this is not the case*:

this means your server environment and firewall settings are too restrictive, now you have to install the ds functions manually:

```bash 
docker exec -it datashield_rserver bash
R
install.packages('datashield', repos=c('https://cran.rstudio.com','https://cran.obiba.org'), dependencies=TRUE)
```

then exchange the <extenstions> tag in the file  ~/ds_deployment/ds_develop/datashield_docker/ds_data/opal/data/opal-config.xml 
for the following one:

``` xml
<extensions>
    <org.obiba.opal.datashield.cfg.DatashieldConfiguration>
      <level>RESTRICTED</level>
      <environments>
        <org.obiba.opal.datashield.DataShieldEnvironment>
          <environment>ASSIGN</environment>
          <methods>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>log</name>
              <function>base::log</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>c</name>
              <function>base::c</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>cDS</name>
              <function>dsBase::cDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>unlist</name>
              <function>base::unlist</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>exp</name>
              <function>base::exp</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>asListDS</name>
              <function>dsBase::asListDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>as.numeric</name>
              <function>base::as.numeric</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>as.character</name>
              <function>base::as.character</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>asMatrixDS</name>
              <function>dsBase::asMatrixDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>complete.cases</name>
              <function>stats::complete.cases</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>sum</name>
              <function>base::sum</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>as.null</name>
              <function>base::as.null</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>subsetByClassDS</name>
              <function>dsBase::subsetByClassDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>list</name>
              <function>base::list</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>cbind</name>
              <function>base::cbind</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>rowColCalcDS</name>
              <function>dsBase::rowColCalcDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>changeRefGroupDS</name>
              <function>dsBase::changeRefGroupDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>subsetDS</name>
              <function>dsBase::subsetDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>asFactorDS</name>
              <function>dsBase::asFactorDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>recodeLevelsDS</name>
              <function>dsBase::recodeLevelsDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>dataframeDS</name>
              <function>dsBase::dataframeDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>listDS</name>
              <function>dsBase::listDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>replaceNaDS</name>
              <function>dsBase::replaceNaDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>rep</name>
              <function>base::rep</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>attach</name>
              <function>base::attach</function>
              <rPackage>dsGraphics</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>lexisDS</name>
              <function>dsModelling::lexisDS</function>
              <rPackage>dsModelling</rPackage>
              <version>4.1.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
          </methods>
        </org.obiba.opal.datashield.DataShieldEnvironment>
        <org.obiba.opal.datashield.DataShieldEnvironment>
          <environment>AGGREGATE</environment>
          <methods>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>length</name>
              <function>base::length</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>colnames</name>
              <function>base::colnames</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>dimDS</name>
              <function>dsBase::dimDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>dim</name>
              <function>base::dim</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>quantileMeanDS</name>
              <function>dsBase::quantileMeanDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>meanDS</name>
              <function>dsBase::meanDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>isNaDS</name>
              <function>dsBase::isNaDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>is.numeric</name>
              <function>base::is.numeric</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>is.character</name>
              <function>base::is.character</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>is.null</name>
              <function>base::is.null</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>table1dDS</name>
              <function>dsBase::table1dDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>table2dDS</name>
              <function>dsBase::table2dDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>class</name>
              <function>base::class</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>levels</name>
              <function>base::levels</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>is.factor</name>
              <function>base::is.factor</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>namesDS</name>
              <function>dsBase::namesDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>is.list</name>
              <function>base::is.list</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>exists</name>
              <function>base::exists</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>isValidDS</name>
              <function>dsBase::isValidDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>ls</name>
              <function>base::ls</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>numNaDS</name>
              <function>dsBase::numNaDS</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>NROW</name>
              <function>base::NROW</function>
              <rPackage>dsBase</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>histogramDS</name>
              <function>dsGraphics::histogramDS</function>
              <rPackage>dsGraphics</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>densityGridDS</name>
              <function>dsGraphics::densityGridDS</function>
              <rPackage>dsGraphics</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>rangeDS</name>
              <function>dsGraphics::rangeDS</function>
              <rPackage>dsGraphics</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>glmDS1</name>
              <function>dsModelling::glmDS1</function>
              <rPackage>dsModelling</rPackage>
              <version>4.1.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>glmDS2</name>
              <function>dsModelling::glmDS2</function>
              <rPackage>dsModelling</rPackage>
              <version>4.1.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>alphaPhiDS</name>
              <function>dsModelling::alphaPhiDS</function>
              <rPackage>dsModelling</rPackage>
              <version>4.1.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>scoreVectDS</name>
              <function>dsModelling::scoreVectDS</function>
              <rPackage>dsModelling</rPackage>
              <version>4.1.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>checkNegValueDS</name>
              <function>dsModelling::checkNegValueDS</function>
              <rPackage>dsModelling</rPackage>
              <version>4.1.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>t.test</name>
              <function>stats::t.test</function>
              <rPackage>dsStats</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>varDS</name>
              <function>dsStats::varDS</function>
              <rPackage>dsStats</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>cor.test</name>
              <function>stats::cor.test</function>
              <rPackage>dsStats</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>corDS</name>
              <function>dsStats::corDS</function>
              <rPackage>dsStats</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
            <org.obiba.opal.datashield.RFunctionDataShieldMethod>
              <name>covDS</name>
              <function>dsStats::covDS</function>
              <rPackage>dsStats</rPackage>
              <version>4.0.0</version>
            </org.obiba.opal.datashield.RFunctionDataShieldMethod>
          </methods>
        </org.obiba.opal.datashield.DataShieldEnvironment>
      </environments>
      <options>
        <entry>
          <string>datashield.privacyLevel</string>
          <string>5</string>
        </entry>
      </options>
    </org.obiba.opal.datashield.cfg.DatashieldConfiguration>
    <org.obiba.opal.search.es.ElasticSearchConfiguration/>
    <org.obiba.opal.search.IndexManagerConfiguration>
      <indexConfigurations/>
      <enabled>true</enabled>
    </org.obiba.opal.search.IndexManagerConfiguration>
  </extensions>
```

### STEP 9 - Login to your R Server and test the connection to your opal entity

To test your connection to the opal server locally u have to install R - skip this step if you do not want to install R.

install R: `./install_r.sh`

navigate to your Repo and execute the R testscript by executing the following command:

```bash
R -f datashield_localhost.r
```
