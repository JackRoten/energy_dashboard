// import { DisplayJson } from "../components/DisplayJson";
import { USMap } from "../components/USMap";

export default function Dashboard() {
  return (
    <main style={{ textAlign: "center", padding: "2rem", maxWidth: "1200px", margin: "0 auto" }}>
      <h1>U.S. Electricity Usage Dashboard</h1>
      <p>Explore energy usage across states</p>
      <USMap />
      <div style={{ marginTop: "2rem", display: "flex", justifyContent: "center" }}>
      </div>
    </main>
  );
}
