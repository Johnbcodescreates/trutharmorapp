/**
 * Optional link-reputation check using the Google Safe Browsing Lookup API (v4).
 * Enabled only when the SAFE_BROWSING_API_KEY secret is configured.
 *
 * Note: Safe Browsing Lookup API is for non-commercial use. For a commercial
 * launch, switch to Google Cloud Web Risk API (same request shape, different
 * endpoint and terms). A "not flagged" result NEVER means a link is safe.
 */
export interface UrlReputation {
  url: string;
  flagged: boolean;
  threat_types: string[];
}

type FetchLike = typeof fetch;

export async function checkUrls(urls: string[], apiKey: string | undefined, fetchImpl: FetchLike = fetch): Promise<UrlReputation[]> {
  if (!apiKey || urls.length === 0) return [];

  const normalized = urls.map((u) => (/^[a-z][a-z0-9+.-]*:\/\//i.test(u) ? u : `http://${u}`));
  const body = {
    client: { clientId: "truth-armor", clientVersion: "0.1.0" },
    threatInfo: {
      threatTypes: ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION"],
      platformTypes: ["ANY_PLATFORM"],
      threatEntryTypes: ["URL"],
      threatEntries: normalized.map((url) => ({ url })),
    },
  };

  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 5000);
    const res = await fetchImpl(
      `https://safebrowsing.googleapis.com/v4/threatMatches:find?key=${encodeURIComponent(apiKey)}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: controller.signal,
      },
    );
    clearTimeout(timer);
    if (!res.ok) return [];
    const data = (await res.json()) as { matches?: { threat?: { url?: string }; threatType?: string }[] };
    const byUrl = new Map<string, Set<string>>();
    for (const m of data.matches ?? []) {
      const url = m.threat?.url;
      if (!url) continue;
      if (!byUrl.has(url)) byUrl.set(url, new Set());
      if (m.threatType) byUrl.get(url)!.add(m.threatType);
    }
    return normalized.map((url, i) => ({
      url: urls[i],
      flagged: byUrl.has(url),
      threat_types: [...(byUrl.get(url) ?? [])],
    }));
  } catch {
    return []; // Reputation is best-effort; never fail the whole analysis.
  }
}
