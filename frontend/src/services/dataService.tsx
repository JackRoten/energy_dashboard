export async function fetchDataIfChanged(etag?: string) {
    const res = await fetch("/api/state-data", {
      method: "GET",
      headers: etag ? { "If-None-Match": etag } : {}
    });
  
    if (res.status === 304) {
      return { changed: false };
    }
  
    if (!res.ok) {
      throw new Error("Failed to fetch data");
    }
  
    const data = await res.json();
    const newEtag = res.headers.get("ETag");
  
    return { changed: true, data, etag: newEtag };
  }
  