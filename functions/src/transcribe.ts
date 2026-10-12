/**
 * Voice-message transcription. The app sends the audio as base64 JSON to the
 * same `analyze` endpoint with `"action": "transcribe"`; this module turns it
 * into text with OpenAI speech-to-text. The audio is NOT stored by TruthArmor.
 *
 * Note: this does NOT try to decide whether a voice is AI-generated. That
 * can't be done reliably; TruthArmor analyzes what the message ASKS for.
 */
type FetchLike = typeof fetch;

export const MAX_AUDIO_BYTES = 20 * 1024 * 1024; // OpenAI limit is 25 MB

const ALLOWED_TYPES: Record<string, string> = {
  "audio/mpeg": "mp3",
  "audio/mp3": "mp3",
  "audio/mp4": "m4a",
  "audio/x-m4a": "m4a",
  "audio/m4a": "m4a",
  "audio/wav": "wav",
  "audio/x-wav": "wav",
  "audio/wave": "wav",
  "audio/webm": "webm",
  "video/mp4": "mp4",
  "video/webm": "webm",
};

export interface TranscribeResult {
  status: number;
  body: Record<string, unknown>;
}

export async function handleTranscribe(
  body: unknown,
  deps: { openAiKey: string; model: string; fetchImpl?: FetchLike; timeoutMs?: number },
): Promise<TranscribeResult> {
  const b = (typeof body === "object" && body !== null ? body : {}) as Record<string, unknown>;
  const audio = b.audio_base64;
  const mime = typeof b.mime_type === "string" ? b.mime_type.toLowerCase().split(";")[0].trim() : "";

  if (typeof audio !== "string" || audio.length === 0) {
    return { status: 400, body: { error: "No audio was provided." } };
  }
  const ext = ALLOWED_TYPES[mime];
  if (!ext) {
    return { status: 400, body: { error: "Unsupported audio type. Use MP3, M4A, WAV, MP4, or WEBM." } };
  }
  if (!/^[A-Za-z0-9+/=\r\n]+$/.test(audio)) {
    return { status: 400, body: { error: "Audio data is not valid." } };
  }
  const bytes = Buffer.from(audio, "base64");
  if (bytes.length === 0) return { status: 400, body: { error: "Audio data is not valid." } };
  if (bytes.length > MAX_AUDIO_BYTES) {
    return { status: 413, body: { error: "This recording is too large. Please use a file under 20 MB." } };
  }

  const form = new FormData();
  form.append("file", new Blob([bytes], { type: mime }), `voice-message.${ext}`);
  form.append("model", deps.model);

  const fetchImpl = deps.fetchImpl ?? fetch;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), deps.timeoutMs ?? 50000);
  try {
    const res = await fetchImpl("https://api.openai.com/v1/audio/transcriptions", {
      method: "POST",
      headers: { Authorization: `Bearer ${deps.openAiKey}` },
      body: form,
      signal: controller.signal,
    });
    if (res.status === 429) return { status: 429, body: { error: "Transcription is busy right now." } };
    if (!res.ok) return { status: 502, body: { error: "Transcription is unavailable right now." } };
    const data = (await res.json()) as { text?: unknown };
    const text = typeof data.text === "string" ? data.text.trim().slice(0, 8000) : "";
    return { status: 200, body: { text } };
  } catch {
    return { status: 502, body: { error: "Transcription is unavailable right now." } };
  } finally {
    clearTimeout(timer);
  }
}
