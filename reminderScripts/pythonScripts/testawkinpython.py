import subprocess
string = "hello alex how are you today"
#result = subprocess.check_output("echo "+string+" | awk -F 'are' '{print $1}'", shell=True)
#print result
subprocess.call("echo "+string+" | awk -F 'are' '{print $1}'", shell=True)
