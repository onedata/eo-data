# EO-Data Encapsulation Container

This repository allows for building containers containing a  mocked tree of a data collection, with each file content equal it it's absolute path.

## Usage
First, you need a file containing paths to files eg.:
~~~
/data/moon/photo1.jpg
/data/moon/photo2.jpg
/data/saturn/photo1.jpg
/data/saturn/photo2.jpg
~~~

Next, you can use this file to create a container containing such directory tree:
~~~
# Generate and push image with a sample directory tree of just first 10 lines of the paths file (default is 1000)
make push-data-sample DATA_PATH=solar.txt DATA_SAMPLE_SIZE=10
~~~
This results in an image `onedata/eo-data:solar-sample-<md5 sum of a solar.txt file>` pushed to docker hub.

Finally, you can use this file to create a container containing such directory tree:
~~~
# Generate and push image with full directory tree
make push-data DATA_PATH=solar.txt
~~~
This results in an image `onedata/eo-data:solar-<md5 sum of a solar.txt file>` pushed to docker hub.