#!/usr/bin/env Rscript
library(optparse)
library(cli)
library(fs)
library(readr)
library(stringr)
library(glue)
source("core.R")  # Load the core logic

option_list <- list(
  make_option(c("-i", "--input"), type = "character", default = NULL,
              help = "Path or URL to a local audio file to transcribe", metavar = "FILE"),
  make_option(c("-l", "--language"), type = "character", default = "en",
              help = "Language code (default: 'en')", metavar = "LANG"),
  make_option(c("-m", "--model"), type = "character", default = "large-v3-turbo",
              help = "Whisper model to use", metavar = "MODEL"),
  make_option(c("-p", "--processed"), type = "logical", default = TRUE,
              help = "Post-process transcript with Ollama (TRUE/FALSE)", metavar = "BOOL"),
  make_option(c("-M", "--ollama-model"), type = "character", default = "llama3.2",
              help = "Ollama model to use for post-processing", metavar = "OLLAMA_MODEL"),
  make_option(c("-o", "--outfile"), type = "character", default = "transcribe.txt",
              help = "File path to save the final transcript", metavar = "FILE")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$input)) {
  cli_abort("No input provided. Use -i or --input to specify a file or URL.")
}

# If input is a URL, download the audio.
if (str_detect(opt$input, "^https?://")) {
  cli_alert_info("Input is a URL. Downloading audio using yt-dlp...")
  tmp_audio <- download_audio(opt$input)
  cli_alert_success(glue("Audio downloaded to temporary file: {tmp_audio}"))
  opt$input <- tmp_audio
}

if (!fs::file_exists(opt$input)) {
  cli_abort(glue("The input file '{opt$input}' does not exist."))
}

transcript <- transcribe_audio(
  input_path = opt$input,
  language = opt$language,
  whisper_model_name = opt$model,
  processed = opt$processed,
  ollama_model = opt$`ollama-model`
)

cli_text("{.strong Final Transcript:}")
cli_text(transcript)
readr::write_lines(transcript, file = opt$outfile)
cli_alert_success(glue("Final transcript saved to: {opt$outfile}"))
