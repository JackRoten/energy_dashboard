import React, { useEffect, useState } from "react";
import {
  ComposableMap,
  Geographies,
  Geography,
} from '@vnedyalk0v/react19-simple-maps';
import {getStateDataMock} from "../services/api"

const geoUrl = 'https://unpkg.com/us-atlas@3/states-10m.json';
export const USMap = () => {
  const [data, setData] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        setError(null);
        const fake = await getStateDataMock();
        console.log("Loaded map data:", fake);
        setData(fake);
      } catch (err) {
        console.error("Error loading map data:", err);
        setError(err instanceof Error ? err.message : "Failed to load data");
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);
  
    if (loading) {
    return <div>Loading map data...</div>;
  }
  if (error) {
    return <div style={{ color: "red" }}>Error: {error}</div>;
  }

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
      <p>WIP: Working out bugs to display map</p>
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
              const value = data[name];
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
