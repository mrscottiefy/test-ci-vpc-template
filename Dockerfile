# Fixed version of Jenkins
FROM jenkins/jenkins:2.287-alpine

# Taken from official jenkins mirror website
# http://mirrors.jenkins-ci.org/status.html
# This environment variable changes the download server for plugins
ENV JENKINS_UC_DOWNLOAD="https://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/"
COPY plugins.txt /usr/share/jenkins/plugins.txt
USER root
RUN mkdir /usr/share/jenkins/sonarscanner
WORKDIR /usr/share/jenkins/sonarscanner
RUN wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.0.2311-linux.zip
RUN unzip -q sonar-scanner-cli-4.6.0.2311-linux.zip
RUN jenkins-plugin-cli -l --verbose --skip-failed-plugins --plugin-file /usr/share/jenkins/plugins.txt
WORKDIR /home/jenkins
USER jenkins
