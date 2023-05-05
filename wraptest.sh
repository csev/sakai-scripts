date
echo "Hello world wraptest.sh"
pwd
echo "Parameters: " $@

echo "Sleeping for 10 seconds to test buffer flushing in shell scripts..."
sleep 10
echo "Back from sleep 10"

echo "The next line should be a command not found..."
lksdljkjds lkj df

echo "All done"
