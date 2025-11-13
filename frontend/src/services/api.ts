// Mock API service for local testing
export async function getStateDataMock(): Promise<Record<string, number>> {
  // Simulate API delay
  await new Promise((resolve) => setTimeout(resolve, 100));
  
  // Return fake data keyed by state postal code
  return {
    "Wyoming": 77166.425,
    "Wisconsin": 192396.585,
    "West Virginia": 61266.744,
    "West South Central": 3215793.111,
    "West North Central": 470084.024,
    "Washington": 107686.628,
    "Virginia": 420474.834,
    "Vermont": 1740.554,
    "Utah": 79701.751,
    "U.S. Total": 13413629.59963,
    "Texas": 2260908.742,
    "Tennessee": 115999.931,
    "South Dakota": 22075.748,
    "South Carolina": 145107.433,
    "South Atlantic": 2704149.15335,
    "Rhode Island": 75890.226,
    "Puerto Rico": 71697.43,
    "Pennsylvania": 994702.43474,
    "Pacific Noncontiguous": 39516.928,
    "Pacific Contiguous": 903954.50493,
    "Pacific": 943490.44693,
    "Oregon": 143752.791,
    "Oklahoma": 362443.314,
    "Ohio": 586715.377,
    "North Dakota": 41515.826,
    "North Carolina": 340601.092,
    "New York": 498832.61712,
    "New Mexico": 93239.83,
    "New Jersey": 219300.939,
    "New Hampshire": 42537.728,
    "New England": 469486.948,
    "Nevada": 158900.32,
    "Nebraska": 41450.181,
    "Mountain": 1094042.017,
    "Montana": 28525.806,
    "Missouri": 108778.932,
    "Mississippi": 366869.045,
    "Minnesota": 115470.339,
    "Middle Atlantic": 1713318.47910,
    "Michigan": 366475.37,
    "Massachusetts": 132792.448,
    "Maryland": 100794.317,
    "Maine": 42971.628,
    "Louisiana": 404970.597,
    "Kentucky": 163742.265,
    "Kansas": 54844.788,
    "Iowa": 84895.555,
    "Indiana": 337012.8272,
    "Illinois": 291070.392,
    "Idaho": 46772.329,
    "Hawaii": 13573.906,
    "Georgia": 365233.686,
    "Florida": 1235058.08079,
    "East South Central": 1026486.199,
    "East North Central": 1774481.3062,
    "District of Columbia": 1594.812,
    "Delaware": 32608.684,
    "Connecticut": 172862.72,
    "Colorado": 153445.931,
    "California": 651662.51693,
    "Arkansas": 185865.63,
    "Arizona": 453878.572,
    "Alaska": 25942.7,
    "Alabama": 379707.642
};
}

// TODO: Replace with real API call when backend is ready
// export async function getStateData(apiUrl: string): Promise<Record<string, number>> {
//   const response = await fetch(apiUrl);
//   if (!response.ok) {
//     throw new Error(`API error: ${response.statusText}`);
//   }
//   const data = await response.json();
//   return data.reduce((acc: Record<string, number>, row: { state: string; value: number }) => {
//     acc[row.state] = row.value;
//     return acc;
//   }, {});
// }