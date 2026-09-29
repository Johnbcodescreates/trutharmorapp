import { RESPONSE_SCHEMA, buildMessages } from "./prompt";
import { ValidRequest } from "./validate";

type FetchLike = typeof fetch;

export class UpstreamError extends Error {
  constructor(message: string, public readonly status?: number) {
    super(message);
  }
}

/**
 * Calls the OpenAI Chat Completions API with Structured Outputs so the
 * response always matches RESPONSE_SCHEMA. The API key comes from a Firebase
 * secret and never leaves the server.
 */
export async function callOpenAI(
  req: ValidRequest,
  opts: { apiKey: string; model: string; fetchImpl?: FetchLike; timeoutMs?: number },
): Promise<unknown> {
  const fetchImpl = opts.fetchImpl ?? fetch;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), opts.timeoutMs ?? 25000);

  try {
    const res = await fetchImpl("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${opts.apiKey}`,
      },
      body: JSON.stringify({
        model: opts.model,
        messages: buildMessages(req),
        response_format: { type: "json_schema", json_schema: RESPONSE_SCHEMA },
        temperature: 0.2,
        max_tokens: 900,
      }),
      signal: controller.signal,
    });

    if (!res.ok) {
      throw new UpstreamError(`OpenAI request failed (${res.status})`, res.status);
    }
    const data = (await res.json()) as {
      choices?: { message?: { content?: string | null; refusal?: string | null } }[];
    };
    const message = data.choices?.[0]?.message;
    if (!message || message.refusal || !message.content) {
      throw new UpstreamError("AI returned no usable content");
    }
    return JSON.parse(message.content);
  } catch (e) {
    if (e instanceof UpstreamError) throw e;
    throw new UpstreamError(e instanceof Error ? e.message : "Unknown upstream error");
  } finally {
    clearTimeout(timer);
  }
}
