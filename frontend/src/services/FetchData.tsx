
import { useEffect, useState } from "react";


export default function FetchData() {
  // interface ApiData {
  //   [key:string]: string
  // }

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  // useEffect(() => {
  async function loadData() {
    try {
      const res = await fetch("https://tz5jps682g.execute-api.us-west-2.amazonaws.com/dev/data?groupby=all");

      if (!res.ok) {
        throw new Error(`API error: ${res.status}`);
      }

      const json = await res.json();
      setData(json);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
    return setData;
  }
// 
  return loadData();

// export const 
  // }, []);

  // if (loading) return <p>Loading…</p>;
  // if (!data) return <p>No data returned.</p>;
  // return JSON.stringify(data, null, 2);
  // // return (
  //   <div>
  //     <h1>API Data:</h1>
  //     <pre>{JSON.stringify(data, null, 2)}</pre>
  //   </div>
  // );

}
