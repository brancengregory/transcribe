
# transcribe <img src="man/figures/logo.png" align="right" height="139"/>

[![R-CMD-check](https://github.com/YourUserName/transcribe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YourUserName/transcribe/actions)

The **transcribe** package provides an R interface to audio
transcription using Whisper, with optional post‐processing via Ollama.
It also includes a sample plumber API for a web interface and a
command-line interface (CLI).

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

### CLI Usage

To use the CLI, run the following command from your terminal:

``` bash
Rscript inst/scripts/cli.R -i "path/to/audio.wav" -l en -m large-v3-turbo -p TRUE -M llama3.2 -o "transcribe.txt"
```

This command will transcribe the audio file and save the output to
`transcribe.txt`.

### Plumber API

You can also serve a web interface via **plumber**:

``` r
library(plumber)
plumber::plumb("inst/plumber/api.R")$run(port = 7608)
```

Then open your browser at <http://127.0.0.1:7608> to access the
transcription interface.

## Vignettes

Access the vignette “intro” by running:

``` r
vignette("intro", package = "transcribe")
```
