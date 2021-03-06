
#'
#' This script is used inside `__test.R` to run the `jackalope` version of simulation
#' along phylogenies and Illumina read simulation, compared to `NGSphy`.
#' It's not meant to be run directly.
#'
#' It takes as inputs  the genome size, max tree depth, number of reads,
#' directory for input and output, and number of threads.
#'

args  <- commandArgs(trailingOnly = TRUE)

stopifnot(length(args) == 5)
gsize <- as.integer(args[1])
mdepth <- as.numeric(args[2])
n_rds <- as.integer(args[3])
dir <- as.character(args[4])
nt <- as.integer(args[5])


library(jackalope)

.pi_tcag <- 0.1 * 4:1

.alpha <- 1  # <-- just setting this to 1 bc the rate matrix gets scaled anyway

.tstv_ratio <- 1 # transition transversion ratio (alpha / (2 * beta))
.beta <- .alpha / (2 * .tstv_ratio)


ref <- create_genome(20, gsize / 20, pi_tcag = .pi_tcag)


sub <- sub_HKY85(.pi_tcag, alpha = .alpha, beta = .beta,
                 invariant = 0.25, gamma_shape = 0.5, gamma_k = 10)


# same for both insertions and deletions
indel <- indels(rate = 0.1, max_length = 541, a = 1.7)


haps <- create_haplotypes(ref,
                          haps_phylo(fn = paste0(dir, "spp_tree.tree")),
                          sub = sub,
                          ins = indel,
                          del = indel,
                          epsilon = 0,
                          n_threads = nt)

write_fasta(haps, paste0(dir, "haps"),
            overwrite = TRUE, n_threads = nt)



fq_file <- paste0(dir, "jlp")

illumina(haps, fq_file, n_reads = n_rds, read_length = 150,
         paired = TRUE, seq_sys = "HS25",
         n_threads = nt, overwrite = TRUE)

