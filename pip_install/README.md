


python -m venv apj_ps_lab

source apj_ps_lab/bin/activate

pip install -r requirements.txt

python -m ipykernel install --user --name PYSPARK_KERNEL

Run the following command to determine if you have java
java -version

If you do not have java installed follow the following instructions
https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/macos-install.html

you will need the location of you java home folder
which java
This should return something like:
/Users/mstarc/.jenv/versions/1.8/bin/java. Remove the /bin/java from the string.

Start the notebook
jupyter notebook