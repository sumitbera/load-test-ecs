# Use a minimal base image with OpenJDK installed
FROM openjdk:8-jre-alpine3.7

# Install packages
RUN apk update && \
    apk add ca-certificates wget python python-dev py-pip && \
    update-ca-certificates
    
# Set variables
ENV JMETER_HOME=/usr/share/apache-jmeter \
    JMETER_VERSION=5.5 \
    TEST_SCRIPT_FILE=/var/jmeter/script.jmx \
    TEST_LOG_FILE=/var/jmeter/UserServices.log \
    TEST_RESULTS_FILE=/var/jmeter/test-result.xml \
    PATH="~/.local/bin:$PATH" \
    NUMBER_OF_THREADS=100 \
    RAMP_UP_PERIOD=1 \
    HOST_URL='gorest.co.in' \
    PORT=443
    
# Install Apache JMeter
RUN wget http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar zxvf apache-jmeter-${JMETER_VERSION}.tgz && \
    rm -f apache-jmeter-${JMETER_VERSION}.tgz && \
    mv apache-jmeter-${JMETER_VERSION} ${JMETER_HOME}

# Copy test plan
COPY jmeter/UserServices.jmx ${TEST_SCRIPT_FILE}

# The main command, running jemeter:
CMD $JMETER_HOME/bin/jmeter -n \
    -t=$TEST_SCRIPT_FILE \
    -j $TEST_LOG_FILE \
    -l=$TEST_RESULTS_FILE \
    -Jjmeter.save.saveservice.output_format=xml \
    -Jjmeter.save.saveservice.response_data=true \
    -Jjmeter.save.saveservice.samplerData=true \
    -JnumberOfThreads=$NUMBER_OF_THREADS \
    -JrampUpPeriod=$RAMP_UP_PERIOD \
    -JhostUrl=$HOST_URL \
    -Jport=$PORT && \
    echo -e "\n\n===== TEST LOGS =====\n\n" && \
    cat $TEST_LOG_FILE && \
    echo -e "\n\n===== TEST RESULTS =====\n\n" && \
    cat $TEST_RESULTS_FILE