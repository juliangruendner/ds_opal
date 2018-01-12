from ubuntu:latest

#add datashield example R
ADD ./datashield.r /datashield/datashield.r

# install r and datashield dev packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && \
apt-get install -y r-base r-base-dev && \
apt-get install -y libcurl4-openssl-dev && \
apt-get install -y libxml2-utils && \
apt-get install -y libxml2-dev

# install opal packages
RUN R -e 'install.packages(c("rjson", "RCurl", "mime"), repos="https://cran.uni-muenster.de/")' && \
R -e 'install.packages("opal", repos="http://cran.obiba.org", type="source", dependencies=TRUE)' && \
R -e 'install.packages("opaladmin", repos="http://cran.obiba.org", type="source")'

# install datashield packages
RUN R -e "install.packages('datashieldclient', repos=c('https://cran.uni-muenster.de/', 'http://cran.obiba.org'), dependencies=TRUE)"

# update obiba packages
RUN R -e 'update.packages(repos="http://cran.obiba.org")'
