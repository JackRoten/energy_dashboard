import { useEffect, useState } from "react";
// import { useCachedData } from "../hooks/useCachedData";
import {
  ComposableMap,
  Geographies,
  Geography,
} from '@vnedyalk0v/react19-simple-maps';

const geoUrl = 'https://unpkg.com/us-atlas@3/states-10m.json'; // figure out how to cache this file and where
export const USMap = () => {
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

  // const { data, loading } = useCachedData(5 * 60 * 1000); // 5 min interval // will be used to cache data from the database
//

  // Determine fill color based on data value
  const getFillColor = (stateName: string) => {
    const value = data[stateName];
    if (value === undefined) return "#E5E7EB"; // gray for no data
    const intensity = Math.min(value / 700000, 1500); // normalize
    return `rgba(37, 99, 235, ${0.3 + 0.7 * intensity})`; // blue with varying opacity
  };


  return (
    <div className="map-container">
      <div className="header">
      <ComposableMap
        projection="geoAlbersUsa"
        projectionConfig={{
          scale: 800,
        }}
        width={800}
        height={500}
        style={{
          width: "100%",
          height: "auto",
          backgroundColor: "#ffffff",
          boxShadow: "1 10px 8px rgba(20, 6, 6, 0.1)",
          borderRadius: "10px",
        }}>
        <Geographies geography={geoUrl}>
        {({ geographies }) =>
            geographies.map((geo) => {
              const name = geo.properties.name; // e.g. "California"
              // const value = data[name];
              return (
                <Geography
                  key={geo.rsmKey}
                  geography={geo}
                  fill={getFillColor(name)}
                  stroke="#fff"
                  strokeWidth={0.5}
                  style={{
                    default: { outline: "none" },
                    hover: { fill: "#F53", cursor: "pointer" },
                    pressed: { fill: "#E42" },
                  }}
                />
              );
            })
          }
        </Geographies>
      </ComposableMap>
      </div>
      </div>
  );
};
