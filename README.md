
# transcribe <img src="man/figures/logo.png" align="right" height="139"/>

[![R-CMD-check](https://github.com/brancengregory/transcribe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/brancengregory/transcribe/actions)

The **transcribe** package provides an R interface to audio
transcription using Whisper, with optional post‑processing via Ollama.
It includes a command‑line interface (CLI) and a Plumber API to create a
web interface.

## Prerequisites

- **Whisper**:  
  Make sure you have [OpenAI Whisper](https://github.com/openai/whisper)
  installed and configured. Follow the official documentation for
  installation instructions.

- **Ollama**:  
  Ensure that [Ollama](https://ollama.com) is installed and running.
  Consult the Ollama documentation for setup details and configuration.

- **Other Dependencies**:  
  This package uses:

  - **processx** to wrap the `yt-dlp` command for downloading audio
    files.
  - **reticulate** to call Python’s Whisper implementation.
  - **ellmer** for prompt-based post‑processing of raw Whisper
    transcripts.  
    Please refer to each package’s documentation for further details.

## Overview

The package workflow is as follows:

- **Audio Downloading**:  
  When given a remote URL, **processx** is used to call `yt-dlp`,
  downloading the audio file quickly and robustly.

- **Transcription via Whisper**:  
  Python’s Whisper is called via **reticulate**, providing
  state‑of‑the‑art transcription directly from R.

- **Post‑processing with Ollama and ellmer**:  
  The raw transcript from Whisper is optionally sent to Ollama via
  **ellmer** using a prompt (e.g., “Reformat the transcript into clear,
  well‑punctuated paragraphs…”) to produce a cleaned, readable
  transcript.

- **Interfaces**:  
  Use the CLI for batch processing, or launch the Plumber API to access
  a web interface.

## Installation

``` r
# install.packages("remotes") # if not already installed
remotes::install_github("brancengregory/transcribe")
```

## Usage

### Basic Example

``` r
library(transcribe)

# Transcribe a local audio file.
transcript <- transcribe_audio(
  input_path = "path/to/audio.wav",
  language = "en",
  whisper_model_name = "large-v3-turbo",
  processed = TRUE,
  ollama_model = "llama3.2"
)
cat(transcript)
```

### CLI Usage

To use the command‑line interface, run the following command from your
terminal:

``` bash
Rscript inst/scripts/main_cli.R -i "path/to/audio.wav" -l en -m large-v3-turbo -p TRUE -M llama3.2 -o "transcribe.txt"
```

This command processes the specified audio file and saves the transcript
to `transcribe.txt`.

### Plumber API

You can serve a web interface via **plumber**. For example:

``` r
library(plumber)
plumber::plumb("inst/plumber/api.R")$run(port = 7608)
```

Then open your browser at <http://127.0.0.1:7608> to use the
transcription interface.

## Vignettes

For a detailed introduction, see the vignette “intro”:

``` r
vignette("intro", package = "transcribe")
```

## Contributing

1.  Fork the repository on GitHub.
2.  Create a new branch for your changes.
3.  Submit a pull request describing your proposed changes.

## License

MIT © 2025 Your Name
