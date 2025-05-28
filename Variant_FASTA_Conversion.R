# WT to Mutation Sequences & Reverse Sequences
# Date: 2025-01-19

# Load required libraries
library(dplyr)
library(stringr)
library(readr)

# Loading data 
input_file <- "~/Downloads/WT_og.csv"
data <- read.csv(input_file, stringsAsFactors = FALSE)
head(data)
colnames(data)
#colnames(data) # Line checks columns of data 
#unique(data$Variant_Tagged.ORF) # Line shows amino acids, Ter is only difference 

# Function to apply mutations to sequences
apply_mutation <- function(sequence, mutation) {
  
  # Parse mutation (e.g., A333N)
  # Breaks it into original, position, and new 
  match <- stringr::str_match(mutation, "([A-Z])(\\d+)([A-Z])")  # use double backslashes to fix error 
  
  if (is.null(match) || nrow(match) == 0 || any(is.na(match))) return(NA)  # Check for valid matches
  
  original_aa <- match[1, 2]
  position <- as.numeric(match[1, 3]) ## Gets value 
  new_aa <- match[1, 4]
  
  warning(paste("Found", original_aa, "at", position, "& is replaced with", new_aa))
  
  # Check for NA values in sequence or position
  if (is.na(sequence) || is.na(position)) {
    warning("Sequence or position is NA")
    return(NA)
  }
  
  # Validate position and sequence length
  if (position > nchar(sequence) || position < 1) {
    warning(paste("Invalid position", position, "for sequence of length", nchar(sequence)))
    return(NA)
  }
  
  # Validate that the character at the position matches the expected original amino acid
  if (substring(sequence, position, position) != original_aa) {
    warning(paste(
      "Mismatch at position", position,
      "Expected:", original_aa,
      "Found:", substring(sequence, position, position)
    ))
    return(NA)
  }
  
  #apply mutation
  substr(sequence, position, position) <- new_aa
  sequence
}

# Function to reverse a sequence
reverse_sequence <- function(sequence) {
  paste0(rev(strsplit(sequence, "")[[1]]), collapse = "")
}

# Generate mutated sequences by adding all together 
data <- data %>%
  mutate(
    Uniprot = "P15056", 
    Variant_Tag = paste0("BRAF_", Variant_Tagged.ORF), 
    Organism = "OS=Homo sapiens", 
    GN = paste0("GN=BRAF", Variant_Tagged.ORF), 
    mutated_sequence = mapply(apply_mutation, protein_sequence, Variant_Tagged.ORF),
    wt_reversed = ifelse(!is.na(protein_sequence), sapply(protein_sequence, reverse_sequence), NA),
    mutated_reversed = ifelse(!is.na(mutated_sequence), sapply(mutated_sequence, reverse_sequence), NA),
    Header_Fwd = paste0(paste0(">Fwd_","sp", Variant_Tagged.ORF, "|"), Uniprot,"|", Variant_Tag, " ", Organism," ", GN), 
    Header_Rev = paste0(paste0(">Rev_","sp", Variant_Tagged.ORF),"|", Uniprot,"|", Variant_Tag, " ", Organism, " ", GN)
  )

# Show data 
head(data)

# Save output to a CSV file
output_file <- "~/Downloads/WT_mutated_output.csv"
write_csv(data, output_file)
cat("Output saved to", output_file, "\n")

# Show final output columns
final_output <- data %>%
  select(protein_sequence, wt_reversed, mutated_sequence, mutated_reversed, Uniprot, Organism, GN)
#knitr::kable(head(final_output))

# Function to write in FASTA format with WT exception
write_combined_fasta <- function(data, output_file) {
  # Open file connection 
  file_conn <- file(output_file, "w")
  
  # WT entry if it exists (where GN is just "BRAF" with no Variant_Tagged entry)
  wt_row <- which(data$GN == "GN=BRAF")
  if(length(wt_row) > 0) {
    # WT forward header 
    writeLines(paste0(">Fwd_spWT|", data$Uniprot[wt_row], "|", "BRAF_WT", " ", data$Organism[wt_row], " ", data$GN[wt_row]), file_conn)
    writeLines(data$protein_sequence[wt_row], file_conn)
    
    # WT reverse header 
    writeLines(paste0(">Rev_spWT|", data$Uniprot[wt_row], "|", "BRAF_WT", " ", data$Organism[wt_row], " ", data$GN[wt_row]), file_conn)
    writeLines(data$wt_reversed[wt_row], file_conn)
  }
  
  # All other entries (excluding WT)
  for (i in 1:nrow(data)) {
    # Skip WT row since we already covered exception 
    if(i %in% wt_row) next
    
    # Forward sequence
    if (!is.na(data$Header_Fwd[i]) && !is.na(data$mutated_sequence[i])) {
      writeLines(data$Header_Fwd[i], file_conn)
      writeLines(data$mutated_sequence[i], file_conn)
    }
    
    # Reverse sequence
    if (!is.na(data$Header_Rev[i]) && !is.na(data$mutated_reversed[i])) {
      writeLines(data$Header_Rev[i], file_conn)
      writeLines(data$mutated_reversed[i], file_conn)
    }
  }
  
  # Finished writing headers, close down file 
  close(file_conn)
}

# Generate FASTA file
output_fasta <- "~/Downloads/WT_mutated_with_variant.fasta"
# Combine data with fasta format 
write_combined_fasta(data, output_fasta)
# Check if it worked 
cat("Combined FASTA saved to", output_fasta, "\n")