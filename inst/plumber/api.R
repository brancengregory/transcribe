devtools::load_all()

library(plumber)
library(curl)
library(rlang)
library(fs)
library(logger)
library(glue)
library(stringr)

#* @get /
#* @serializer html
function() {
  html <- '
  <!DOCTYPE html>
  <html>
  <head>
    <title>Audio Transcription Service</title>
    <script src="https://unpkg.com/htmx.org@1.9.2"></script>
  </head>
  <body>
    <h1>Audio Transcription Service</h1>
    <!-- For URL-only submission, we remove enctype -->
    <form id="transcription-form" hx-post="/transcribe" hx-target="#result" method="post">
      <label for="source_url">Audio File URL (optional):</label><br>
      <input type="text" id="source_url" name="source_url" placeholder="https://example.com"
             value="https://www.youtube.com/watch?v=lT4Kosc_ers"><br><br>

      <label for="language">Language (default: en):</label><br>
      <input type="text" id="language" name="language" value="en"><br><br>

      <label for="whisper_model">Whisper Model:</label><br>
      <input type="text" id="whisper_model" name="whisper_model" value="large-v3-turbo"><br><br>

      <label for="processed">Post-process with Ollama (TRUE/FALSE):</label><br>
      <input type="text" id="processed" name="processed" value="TRUE"><br><br>

      <label for="ollama_model">Ollama Model:</label><br>
      <input type="text" id="ollama_model" name="ollama_model" value="llama3.2"><br><br>

      <button type="submit">Transcribe</button>
    </form>
    <div id="result"></div>
  </body>
  </html>
  '
  return(html)
}

#* @post /transcribe
#* @multipart
#* @serializer html
function(source_url = "", upload = NULL, language = "en",
         whisper_model = "large-v3-turbo", processed = "TRUE",
         ollama_model = "llama3.2") {

  # Log the raw parameter.
  log_info("Received source_url (raw): '{source_url}'")

  # Convert processed flag.
  processed <- tolower(processed) %in% c("true", "1", "yes")
  log_info("Processed flag (logical): {processed}")

  # Check if a file was uploaded.
  if (!is.null(upload) && !is.null(upload$datapath) && nzchar(upload$datapath)) {
    audio_path <- upload$datapath
    log_info("Using uploaded file: {audio_path}")
  } else {
    # Otherwise, use the source_url.
    source_url_trimmed <- str_trim(source_url)
    log_info("Trimmed source_url: '{source_url_trimmed}'")

    # Use curl_escape if needed, but here we assume user enters a full URL.
    # For debugging, we log the value.
    decoded_url <- curl_unescape(source_url_trimmed)
    log_info("Decoded URL: '{decoded_url}'")

    if (str_detect(decoded_url, "^https?://")) {
      log_info("Detected remote URL. Downloading audio.")
      audio_path <- download_audio(decoded_url)
      log_info("Audio downloaded to: {audio_path}")
    } else if (fs::file_exists(decoded_url)) {
      audio_path <- decoded_url
      log_info("Detected local file: {audio_path}")
    } else {
      log_error("Invalid input: not a valid URL or local file => '{decoded_url}'")
      abort("Invalid input: please provide a valid URL or an existing local file.")
    }
  }

  transcript <- transcribe_audio(
    input_path = audio_path,
    language = language,
    whisper_model_name = whisper_model,
    processed = processed,
    ollama_model = ollama_model
  )

  html_output <- paste0("<pre>", transcript, "</pre>")
  return(html_output)
}
