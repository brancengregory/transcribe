
# transcribe <img src="man/figures/logo.png" align="right" height="139"/>

[![R-CMD-check](https://github.com/brancengregory/transcribe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/brancengregory/transcribe/actions)

The **transcribe** package provides an R interface to audio
transcription using Whisper, with optional post‐processing via Ollama.
It also includes a sample plumber API for a web interface.

## Installation

``` r
# install.packages("remotes") # if needed
remotes::install_github("YourUserName/transcribe")
```

## Usage

### Basic Example

``` r
library(transcribe)

# Transcribe a local audio file
transcript <- transcribe_audio(
  input_path = "path/to/audio.wav",
  language = "en",
  whisper_model_name = "large-v3-turbo",
  processed = TRUE,
  ollama_model = "llama3.2"
)
cat(transcript)
```

### Plumber API

The package includes a sample plumber API in `inst/plumber/api.R`. To
run it:

``` r
library(plumber)
plumber::plumb("inst/plumber/api.R")$run(port = 7608)
```

Then open your browser at <http://127.0.0.1:7608> to see the web
interface for uploading or specifying a URL for transcription.

## Vignettes

You can access the vignette “intro” via:

``` r
vignette("intro", package = "transcribe")
```
