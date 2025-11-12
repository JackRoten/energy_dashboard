import React, { useEffect, useState } from "react";
import axios from "axios";
import { ComposableMap, Geographies, Geography } from "react-simple-maps";

const geoUrl =
  "https://cdn.jsdelivr.net/npm/us-atlas@3/states-10m.json";

export const USMap = () => {
  const [data, setData] = useState<Record<string, number>>({});

  useEffect(() => {
    // Figure out how to add API gateway url to secrets and how to pull secretes from aws here
    axios.get("https://YOUR_API_GATEWAY_URL/energy")  // Add this gateway URL
      .then(res => {
        const mapped = res.data.reduce((acc: any, row: any) => {
          acc[row.state] = row.value;
          return acc;
        }, {});
        setData(mapped);
      });
  }, []);

  return (
    <ComposableMap projection="geoAlbersUsa">
      <Geographies geography={geoUrl}>
        {({ geographies }) =>
          geographies.map((geo) => {
            const stateCode = geo.properties.postal;
            const fill = data[stateCode] ? "#007bff" : "#DDD";
            return (
              <Geography
                key={geo.rsmKey}
                geography={geo}
                fill={fill}
                stroke="#FFF"
              />
            );
          })
        }
      </Geographies>
    </ComposableMap>
  );
};
