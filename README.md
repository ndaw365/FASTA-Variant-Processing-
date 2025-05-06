#  Generating FASTA datasets for Variant Processing

This repository focuses on converting datasets from public resources into proteomic, search-compatible FASTA format. This is a building step to generate custom variant-containing FASTA databases. 

[![Neaam's GitHub stats](https://github-readme-stats.vercel.app/api?username=ndaw456)](https://github.com/ndaw456/github-readme-stats)

## Input:
**WT_og.csv file:** List of BRAF variants. 

Columns are as such:

<img width="1440" alt="Screenshot 2025-05-05 at 8 09 14 PM" src="https://github.com/user-attachments/assets/3474d405-0d7d-47de-b7b4-9e1b5db9d439" />

## Code:
**Variant_Fasta_Conversion.Rmd**: This R Markdown script processes a CSV file containing wild-type (WT) protein sequences and corresponding mutations to generate mutated sequences and their reverse complements. It loads/reads required libraries. For each entry, it parses mutation descriptions (e.g., A333N), verifies the wild-type residue, and substitutes the new amino acid at the specified position. Both WT and mutated sequences are then reversed. The code then creates FASTA headers for both forward and reverse sequences, including special handling for WT sequences (labeled separately).

## Output:
**WT_mutated_with_variant.fasta**: .fasta file that holds the WT forward & reversed sequences, and forward & reversed sequences for mutations. The sequences are altered to hold the mutation. 

#### Structure of headers are identified as such:
> sp_VariantTag_Fwd/Rev | Uniprot ID | Organism (OS)  Gene Name (GN)

**WT_mutated_output.csv**: Writes a CSV containing the original and mutated sequences. 
Columns highlight protein sequence, variant tag, position of mutation, mutation, mutated sequences, etc. 

