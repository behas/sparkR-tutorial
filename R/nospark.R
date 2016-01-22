#!/usr/bin/env Rscript

# Compute Bitcoin transaction statistics using (standard) R packages

# Run as follows:
#   ./R/blockchain_stats [dump_directory]

############# INIT #############

start.time <- Sys.time()

# Setting defaults

DEFAULT_DUMP_DIR <- c("~/Desktop/bitcoingraph-0.1")
setwd(".")

# Reading command line arguments

args <- commandArgs(TRUE)
DUMP_DIR <- args[1]

if (is.na(DUMP_DIR)) DUMP_DIR <- DEFAULT_DUMP_DIR

# Setting up data file pointers

BLOCKS_FILE <- paste(DUMP_DIR, "/blocks.csv", sep="")
TX_FILE <- paste(DUMP_DIR, "/transactions.csv", sep="")
REL_BLOCKS_TX_FILE <- paste(DUMP_DIR, "/rel_block_tx.csv", sep="")

# Loading required libraries
library("dplyr")
library("ggplot2")
library("scales")

############# DATA WRANGLING #############

cat("Loading blocks dataset\n")
blocks <- read.csv(BLOCKS_FILE, head=FALSE)
colnames(blocks) <- c("block_hash", "height", "timestamp")

cat("Adding date column computed from timestamp column\n")
blocks$date <- as.Date(format(as.POSIXct(blocks$timestamp, origin="1970-01-01", tz="UTC"), "%Y-%m-%d"))

cat("Loading transaction dataset\n")
txs <- read.csv(TX_FILE, head=FALSE)
colnames(txs) <- c("tx_hash", "is_coinbase")

cat("Loading block -> transaction relationships\n")
rel_blocks_tx <- read.csv(REL_BLOCKS_TX_FILE, head=FALSE)
colnames(rel_blocks_tx) <- c("block_hash", "tx_hash")

cat("Joining block hash into transaction dataframe\n")
txs_w_block_hash <- left_join(txs, rel_blocks_tx, by = "tx_hash")

cat("Joining block date into transactions dataframe\n")
txs_w_date <- left_join(txs_w_block_hash, blocks, by = "block_hash")

cat("Grouping transactions by date\n")
tx_frequency <- dplyr::count(txs_w_date, date)

############# PLOTTING #############

cat("Plotting transaction frequency\n")
g <- ggplot(tx_frequency, aes(date, n)) +
     geom_line(colour = "grey") + scale_x_date() +
     stat_smooth() +
     ylab("Number of transactions") + xlab("") + scale_y_continuous(labels=comma)
g
ggsave(g, file="no_transactions.pdf")

end.time <- Sys.time()
time.taken <- end.time - start.time
cat("Overall execution time:", time.taken)
