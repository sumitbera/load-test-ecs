./jmeter -n \                                                                                127 ↵  2164  14:16:39
    -t ./script.jmx \
    -j ./jmeter.log \
    -l ./script.xml \
    -Jjmeter.save.saveservice.output_format=xml \
    -Jjmeter.save.saveservice.response_data=true \
    -Jjmeter.save.saveservice.samplerData=true \
    -JnumberOfThreads=1 && \
    echo -e "\n\n===== TEST LOGS =====\n\n" && \
    cat jmeter.log && \
    echo -e "\n\n===== TEST RESULTS =====\n\n" && \
    script.xml
