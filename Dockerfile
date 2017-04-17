FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt install oracle-java8-unlimited-jce-policy && \
    rm -r /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Zeppelin
RUN wget -O - http://www-us.apache.org/dist/zeppelin/zeppelin-0.7.1/zeppelin-0.7.1-bin-all.tgz | tar zx
RUN mv zeppelin* zeppelin

#Spark
RUN wget -O - http://d3kbcqa49mib13.cloudfront.net/spark-2.0.1-bin-hadoop2.7.tgz | tar zx
RUN mv spark* spark
ENV SPARK_HOME=/spark

#R
RUN apt-get install -y r-base
RUN apt-get install -y libcurl4-gnutls-dev libssl-dev libxml2-dev
RUN R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('knitr', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages(c('devtools','mplot', 'googleVis'), repos = 'http://cran.us.r-project.org')"
RUN R -e "require(devtools); install_github('ramnathv/rCharts')"
RUN R -e "install.packages('glmnet', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('pROC', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('data.table', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('caret', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('sqldf', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('wordcloud', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('bitops', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('maps', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('maptools', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('sp', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('grid', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('car', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('tidyverse', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('randomForest', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('kernlab', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('e1071', repos = 'http://cran.us.r-project.org')"

#Python
RUN apt-get install -y python-pip python-tk xvfb
ENV DISPLAY=":0"
RUN pip install -U pip
RUN pip install -U setuptools
RUN pip install pandas
RUN pip install numpy
RUN pip install scipy
RUN pip install matplotlib
RUN pip install py4j
RUN pip install bokeh
RUN pip install scikit-learn
RUN pip install pandasql


# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

