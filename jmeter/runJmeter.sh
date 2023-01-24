jmeter -n \
    -t ./script.jmx \
    -j ./UserServices.log \
    -l ./UserServices.xml \
    -Jjmeter.save.saveservice.output_format=xml \
    -Jjmeter.save.saveservice.response_data=true \
    -Jjmeter.save.saveservice.samplerData=true \
    -JnumberOfThreads=100 \
    -JrampUpPeriod=1 \
    -Jhost=gorest.co.in \
    -Jport=443 && \
    echo -e "\n\n===== TEST LOGS =====\n\n" && \
    cat UserServices.log && \
    echo -e "\n\n===== TEST RESULTS =====\n\n" && \
    UserServices.xml