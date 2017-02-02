FROM rocker/rstudio

#------------------------ For rJava
## From cardcorp/r-java
# gnupg is needed to add new key
RUN apt-get update && apt-get install -y gnupg2

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee /etc/apt/sources.list.d/webupd8team-java.list \
    &&  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" \
        | /usr/bin/debconf-set-selections \
    && apt-get update \
    && apt-get install -y oracle-java8-installer \
    && update-alternatives --display java \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && R CMD javareconf

## make sure Java can be found in rApache and other daemons not looking in R ldpaths
RUN echo "/usr/lib/jvm/java-8-oracle/jre/lib/amd64/server/" > /etc/ld.so.conf.d/rJava.conf
RUN /sbin/ldconfig

## Install rJava package
RUN apt-get update && apt-get install -y r-cran-rjava
#------------------------


#------------------------ For sparklyr
# Spark version
ENV SPARK_VERSION 2.0.2

# Some libraries hit a compiler check error. This was the easiest work around
RUN R -e '.libPaths(c("/usr/local/lib/R/site-library", "/usr/local/lib/R/library")); install.packages("backports")'
# Install other R libraries normally using littler
RUN install2.r devtools sparklyr

# Should probably use Sys.getenv and paste
RUN R -e 'sparklyr::spark_install("'$SPARK_VERSION'")'

RUN echo 'rsession-which-r=/usr/local/bin/R' \
           > /etc/rstudio/rserver.conf

# Move the sparklyr spark installation to the rstudio user's home dir
RUN mkdir /home/rstudio/.cache \
    && mv /root/.cache/spark/ /home/rstudio/.cache \
    && chown -R rstudio:rstudio /home/rstudio/.cache \
    && mkdir /root/main

ENV RSTUDIO_SPARK_HOME /home/rstudio/.cache/spark/spark-2.0.2-bin-hadoop2.7
#------------------------

# Install supervisor as several processes need to be run
RUN apt-get update && apt-get install -y openssh-server apache2 supervisor
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
