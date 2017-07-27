FROM rocker/verse:3.4.1

# Versioning
ENV SPARK_VERSION 2.0.2
ENV SPARKLYR_VERSION 0.5.6.9022
ENV DPLYR_VERSION 0.7.2

# Install supervisor as several processes need to be run
RUN apt-get update && apt-get install -y \
   openssh-server \
   apache2 supervisor && \
   mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY spark-defaults.conf $RSTUDIO_SPARK_HOME/conf

# Add CRAN mirror
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com"))' > .Rprofile

# Install dplyr, sparklyr, spark via sparklyr
RUN R -e 'devtools::install_version("dplyr", version = Sys.getenv("DPLYR_VERSION"))' && \
   R -e 'devtools::install_github("rstudio/sparklyr@4b70986")' && \
   R -e 'devtools::install_github("rstudio/sparkinstall") && \
   R -e 'sparklyr::spark_install(Sys.getenv("SPARK_VERSION"))'

# Tell rserver which R install to use and move spark install to rstudio user
RUN echo 'rsession-which-r=/usr/local/bin/R' > /etc/rstudio/rserver.conf \
  && mv /root/spark/ /home/rstudio \
  && chown -R rstudio:rstudio /home/rstudio/spark \
  && mkdir /root/main

# Set environment after this folder has been created
ENV RSTUDIO_SPARK_HOME /home/rstudio/.cache/spark/spark-2.0.2-bin-hadoop2.7

CMD ["/usr/bin/supervisord"]
