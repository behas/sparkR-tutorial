#!/usr/bin/env Rscript

# Compute Bitcoin transaction statistics using Apache Spark

# Run as follows:
#   ./R/spark [dump_directory]

start.time <- Sys.time()

############# INIT #############

# Setting defaults

DEFAULT_DUMP_DIR <- c("~/Desktop/sparkR-tutorial-dataset/small")
setwd(".")

# Reading command line arguments

args <- commandArgs(TRUE)
DUMP_DIR <- args[1]

if (is.na(DUMP_DIR)) DUMP_DIR <- DEFAULT_DUMP_DIR

# Setting up data file pointers

BLOCKS_FILE <- paste(DUMP_DIR, "/blocks.csv", sep="")
TX_FILE <- paste(DUMP_DIR, "/transactions.csv", sep="")
REL_BLOCKS_TX_FILE <- paste(DUMP_DIR, "/rel_block_tx.csv", sep="")

############# SETUP APACHE SPARK #############

if (nchar(Sys.getenv("SPARK_HOME")) < 1) {
  Sys.setenv(SPARK_HOME = "/Users/haslhoferb/projects/graphsense/spark-1.6.0-bin-hadoop2.6")
}
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))

sc <- sparkR.init(master = "local[*]",
                  appName = "Bitcoin SparkR Demo",
                  sparkEnvir = list(spark.driver.memory="4g"),
                  sparkPackages="com.databricks:spark-csv_2.11:1.3.0")

sqlContext <- sparkRSQL.init(sc)

############# INIT AND LOAD DATA #############

cat("Loading blocks dataset\n")
blocksSchema <- structType(
    structField("block_hash", "string"),
    structField("height", "integer"),
    structField("timestamp", "integer")
)
blocks <- read.df(sqlContext, BLOCKS_FILE, source="com.databricks.spark.csv", schema = blocksSchema)

cat("Adding date column computed from timestamp column\n")
blocks$date <- from_unixtime(blocks$timestamp, "yyyy-MM-dd")

cat("Loading transaction dataset\n")
txSchema <- structType(
  structField("tx_hash", "string"),
  structField("is_coinbase", "boolean")
)
txs <- read.df(sqlContext, TX_FILE, source="com.databricks.spark.csv", schema = txSchema)

cat("Loading block -> transaction relationships\n")
relSchema <- structType(
  structField("block_hash", "string"),
  structField("tx_hash", "string")
)
rel_blocks_tx <- read.df(sqlContext, REL_BLOCKS_TX_FILE, source="com.databricks.spark.csv", schema = relSchema)

cat("Joining block hash into transaction dataframe\n")
txs_w_block_hash <- join(txs, rel_blocks_tx, txs$tx_hash == rel_blocks_tx$tx_hash, "left")

cat("Joining block date into transactions dataframe\n")
txs_w_date <- join(txs_w_block_hash, blocks, txs_w_block_hash$block_hash == blocks$block_hash, "left")

cat("Grouping transactions by date\n")
tx_frequency <- summarize(groupBy(txs_w_date, txs_w_date$date), count = n(txs_w_date$date))
tx_frequency <- collect(arrange(tx_frequency, asc(tx_frequency$date)))
tx_frequency$date <- as.Date(tx_frequency$date)

############# PLOTTING #############

library("ggplot2")
library("scales")

cat("Plotting transaction frequency\n")
g <- ggplot(tx_frequency, aes(date, count)) +
  geom_line(colour = "grey") + scale_x_date() +
  stat_smooth() +
  ylab("Number of transactions") + xlab("") + scale_y_continuous(labels=comma)
ggsave(g, file="transactions_spark.pdf")

end.time <- Sys.time()
time.taken <- end.time - start.time
cat("Overall execution time:", toString(time.taken))
