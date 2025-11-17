import { useEffect, useState } from "react";
import FetchData from "../services/FetchData";


export const DisplayJson = () => {
    // const [data, setData] = useState<Record<string, number>>({});
    const [data, setData] = useState<Record<string, number>>({});
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchData = async () => {
        try {
            setLoading(true);
            setError(null);
            // const fetched_data = await FetchData();
            // console.log("Loaded map data:", fetched_data);
            const API_URL = "<move to shared secretly>";
            const response = await fetch(API_URL);
            if (!response.ok) {
                throw new Error(`HTTP error, status: ${response.status}`)
            }
            const result = await response.json();
            if (!Array.isArray(result)) {
                throw new Error("Unexpected API response format");
            }
            const data: Record<string, number> = {};
            for (const item of result) {
                data[item['state_description']] = item['amount'];
            }
            setData(data);
    
        } catch (err) {
            console.error("Error loading  data:", err);
            setError(err instanceof Error ? err.message : "Failed to load data");
        } finally {
            setLoading(false);
        }
        };
        fetchData();
    }, []);
    
    if (loading) {
    return <div>Loading map data...</div>;
    }
    if (error) {
        return <div style={{ color: "red" }}>Error: {error}</div>;
    }


    return (
        <div className="map-container">
          <div className="header">
            <pre>{JSON.stringify(data, null, 2)}</pre>
          </div>
          </div>
      );

}

export default DisplayJson;