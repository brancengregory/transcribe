#' Allowed Whisper models for transcription.
allowed_whisper_models <- c("tiny", "base", "small", "medium", "large", "large-v3-turbo")

#'
#' @export
init_whisper <- function() {
  if (!reticulate::py_module_available("whisper")) {
    cli::cli_alert_info("Python module 'whisper' not found. Installing openai-whisper via reticulate::py_install()...")
    reticulate::py_install("openai-whisper", pip = TRUE)
  }
  reticulate::import("whisper", convert = TRUE)
}

# Download audio from URL using yt-dlp and processx.
#' @export
download_audio <- function(input_url) {
  tmp_audio <- fs::file_temp(ext = "wav")
  cli::cli_alert_info("Input is a URL. Downloading audio using yt-dlp...")
  res <- processx::run("yt-dlp",
                       args = c("-x", "--audio-format", "wav", "-o", tmp_audio, input_url),
                       echo = TRUE)
  if (!fs::file_exists(tmp_audio)) {
    rlang::abort("yt-dlp failed to download the audio from the provided URL.")
  }
  return(tmp_audio)
}

#' @export
load_whisper_model <- function(whisper, model_name) {
  if (!model_name %in% allowed_whisper_models) {
    rlang::abort(glue::glue("Invalid Whisper model '{model_name}'. Choose one of: {paste(allowed_whisper_models, collapse = ', ')}."))
  }
  cli::cli_alert_info(glue::glue("Selected Whisper model: {model_name}"))
  cli::cli_alert_info(glue::glue("Loading Whisper model '{model_name}'..."))
  wm <- whisper$load_model(model_name)
  cli::cli_alert_success("Whisper model loaded.")
  wm
}

#' @export
run_transcription <- function(wm, input_path, language = "en") {
  cli::cli_alert_info("Transcribing audio using Whisper...")
  transcription_result <- wm$transcribe(input_path, language = language)
  cli::cli_alert_success("Transcription completed.")
  transcription_result$text
}

#' @export
post_process_transcript <- function(raw_transcript, ollama_model) {
  if (!rollama::ping_ollama(silent = TRUE)) {
    rlang::abort("Could not connect to Ollama at <http://localhost:11434>")
  }
  available_models <- rollama::list_models()$name
  available_models <- available_models |>
    dplyr::union(stringr::str_extract(available_models, "(.*)?:", group = 1)) |>
    sort()
  if (!ollama_model %in% available_models) {
    rlang::abort(glue::glue("Invalid Ollama model '{ollama_model}'. Available models: {paste(available_models, collapse = ', ')}."))
  }
  cli::cli_alert_info(glue::glue("Selected Ollama model: {ollama_model}"))
  cli::cli_alert_info("Post-processing transcript via Ollama (using ellmer)...")
  chat <- ellmer::chat_ollama(
    system_prompt = "You are a formatting assistant. Reformat the transcript into clear, well‐punctuated paragraphs with minimal extraneous text.",
    model = ollama_model
  )
  formatted_response <- chat$chat(raw_transcript)
  cli::cli_alert_success("Post-processing completed.")
  formatted_response
}

#' @export
transcribe_audio <- function(input_path, language = "en",
                             whisper_model_name = "large-v3-turbo",
                             processed = TRUE,
                             ollama_model = "llama3.2") {
  if (!fs::file_exists(input_path)) {
    rlang::abort(glue::glue("The input file '{input_path}' does not exist."))
  }
  cli::cli_alert_info(glue::glue("Starting transcription on file: {input_path}"))

  # Initialize and load whisper.
  whisper <- init_whisper()
  wm <- load_whisper_model(whisper, whisper_model_name)

  # Run transcription.
  raw_transcript <- run_transcription(wm, input_path, language)

  final_transcript <- raw_transcript
  if (processed) {
    final_transcript <- post_process_transcript(raw_transcript, ollama_model)
  }
  final_transcript
}

