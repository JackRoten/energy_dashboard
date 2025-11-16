import { useState, useEffect } from "react";
import { fetchDataIfChanged } from "../services/dataService";

export function useCachedData(intervalMs = 300000) { // default: 5 min
  const [data, setData] = useState(() => {
    const cached = localStorage.getItem("dashboardData");
    return cached ? JSON.parse(cached) : null;
  });

  const [etag, setEtag] = useState(() => {
    return localStorage.getItem("dashboardEtag") || undefined;
  });

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function checkData() {
      try {
        const response = await fetchDataIfChanged(etag);

        if (response.changed && response.data) {
          setData(response.data);
          setEtag(response.etag || "");

          localStorage.setItem("dashboardData", JSON.stringify(response.data));
          localStorage.setItem("dashboardEtag", response.etag || "");
        }
      } catch (err) {
        console.error("Data refresh failed:", err);
      } finally {
        setLoading(false);
      }
    }

    // fetch on mount
    checkData();

    // schedule periodic checks
    const timer = setInterval(checkData, intervalMs);

    return () => clearInterval(timer);
  }, [etag, intervalMs]);

  return { data, loading };
}
