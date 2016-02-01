# SPARK R Tutorial

The goal of this tutorial is to demonstrate how to use Apache SparkR for analyzing large-scale datasets in R. For demo purposes we use data extracted from the [Bitcoin] (http://bitcoin.org) blockchain and show how to produce a time series plot similar to [this one](https://blockchain.info/charts/n-transactions?showDataPoints=false&timespan=all&show_header=true&daysAverageString=7&scale=0&address=).

This tutorial provides three R scripts for executing the very same computational procedures in three different modes:

* using standard R (+ some extra packages) on a local machine
* using SparkR on a local machine
* using SparkR on a cluster

## Prerequistes

Make sure R is installed (code has been tested using R version 3.2.2)

    R --version
    
Install required R packages

    install.packages("ggplot2", "scales", "dplyr")
    
Download and install [Apache Spark](http://spark.apache.org):
    
    curl -O http://www.apache.org/dyn/closer.lua/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz
    tar xvfz spark-1.6.0-bin-hadoop2.6.tgz

Download and extract the tutorial dataset

    curl -O https://storage.googleapis.com/sparkr_tutorial/sparkR-tutorial-dataset.tgz
    tar xvfz sparkR-tutorial-dataset.tgz
    
Clone this Git repository:

    git clone https://github.com/behas/sparkR-tutorial.git
    cd sparkR-tutorial
    
    *** TODO Roland describe cluster setup ***
    
## Dataset description

The tutorial dataset provides Bitcoint block and transaction data in two different sizes:

* small: 2009-01 until 2012-05 (~ 640 GB)
* large: 2009-01 until 2015-11 (~ 17 GB)

## Standard R mode with small dataset (nospark.R)

The first R script works in single machine mode, loads the small dataset into memory, performs join and grouping procedures and produces the transaction timeline plot.

    sparkR-tutorial git:(master) ✗ ./R/nospark.R [path_to_dataset]/small
    
Executing that script for the large dataset on a single machine is possible but requires high memory (> 20 GB).

## Spark R mode with small dataset (spark.R)

The second R script uses Apache Spark's [SparkR library](https://spark.apache.org/docs/1.6.0/sparkr.html) to perform exactly the same operations.

    sparkR-tutorial git:(master) ✗ ./R/spark.R [path_to_dataset]/small

## Spark R with large dataset in cluster mode (spark_cluster.R)

    *** TODO Roland ***

## Conributors

* [Bernhard Haslhofer](http://bernhardhaslhofer.info)
* [Roland Boubela](http://cluster.meduniwien.ac.at/index.php?id=4033&pers_id=472)
    