/**
 * Simple in-memory, per-instance rate limiter (best effort).
 * For production scale, add Firebase App Check (see docs/SETUP.md) and/or a
 * shared store such as Firestore or Memorystore.
 */
export class RateLimiter {
  private hits = new Map<string, number[]>();

  constructor(private readonly limit: number, private readonly windowMs: number) {}

  allow(key: string, now = Date.now()): boolean {
    const recent = (this.hits.get(key) ?? []).filter((t) => now - t < this.windowMs);
    if (recent.length >= this.limit) {
      this.hits.set(key, recent);
      return false;
    }
    recent.push(now);
    this.hits.set(key, recent);
    if (this.hits.size > 5000) this.hits.clear(); // keep memory bounded
    return true;
  }
}
