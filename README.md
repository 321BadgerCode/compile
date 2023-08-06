# compile
bash script to put local files that a bash script uses into the bash script, so that it doesn't depend on local files. it then uses `shc` to convert the bash script into c code, then it gets compiled into a stand-alone executable file to be run.
