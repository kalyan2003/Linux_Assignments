BEGIN { output_file = "output.txt"; print "" > output_file }



/"frame.time"/ {
    gsub(/"|,/, "", $2);
    frame_time = $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9;
    print "\"frame.time\": \"" frame_time""  >> output_file;
}

/"wlan.fc.type"/ {
    gsub(/"|,/, "", $2);
    print "\"wlan.fc.type\": \"" $2 "" >> output_file;
}

/"wlan.fc.subtype"/ {
    gsub(/"|,/, "", $2);
    print "\"wlan.fc.subtype\": \"" $2 "" >> output_file;
}
