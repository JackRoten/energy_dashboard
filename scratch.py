json_result = [
  {
    "state_description": "Wyoming",
    "amount": "77166.425"
  },
  {
    "state_description": "Wisconsin",
    "amount": "192396.585"
  },
  {
    "state_description": "West Virginia",
    "amount": "61266.744"
  },
  {
    "state_description": "West South Central",
    "amount": "3215793.111"
  },
  {
    "state_description": "West North Central",
    "amount": "470084.024"
  },
  {
    "state_description": "Washington",
    "amount": "107686.628"
  },
  {
    "state_description": "Virginia",
    "amount": "420474.834"
  },
  {
    "state_description": "Vermont",
    "amount": "1740.554"
  },
  {
    "state_description": "Utah",
    "amount": "79701.751"
  },
  {
    "state_description": "U.S. Total",
    "amount": "13413629.59963"
  },
  {
    "state_description": "Texas",
    "amount": "2260908.742"
  },
  {
    "state_description": "Tennessee",
    "amount": "115999.931"
  },
  {
    "state_description": "South Dakota",
    "amount": "22075.748"
  },
  {
    "state_description": "South Carolina",
    "amount": "145107.433"
  },
  {
    "state_description": "South Atlantic",
    "amount": "2704149.15335"
  },
  {
    "state_description": "Rhode Island",
    "amount": "75890.226"
  },
  {
    "state_description": "Puerto Rico",
    "amount": "71697.430"
  },
  {
    "state_description": "Pennsylvania",
    "amount": "994702.43474"
  },
  {
    "state_description": "Pacific Noncontiguous",
    "amount": "39516.928"
  },
  {
    "state_description": "Pacific Contiguous",
    "amount": "903954.50493"
  },
  {
    "state_description": "Pacific",
    "amount": "943490.44693"
  },
  {
    "state_description": "Oregon",
    "amount": "143752.791"
  },
  {
    "state_description": "Oklahoma",
    "amount": "362443.314"
  },
  {
    "state_description": "Ohio",
    "amount": "586715.377"
  },
  {
    "state_description": "North Dakota",
    "amount": "41515.826"
  },
  {
    "state_description": "North Carolina",
    "amount": "340601.092"
  },
  {
    "state_description": "New York",
    "amount": "498832.61712"
  },
  {
    "state_description": "New Mexico",
    "amount": "93239.830"
  },
  {
    "state_description": "New Jersey",
    "amount": "219300.939"
  },
  {
    "state_description": "New Hampshire",
    "amount": "42537.728"
  },
  {
    "state_description": "New England",
    "amount": "469486.948"
  },
  {
    "state_description": "Nevada",
    "amount": "158900.320"
  },
  {
    "state_description": "Nebraska",
    "amount": "41450.181"
  },
  {
    "state_description": "Mountain",
    "amount": "1094042.017"
  },
  {
    "state_description": "Montana",
    "amount": "28525.806"
  },
  {
    "state_description": "Missouri",
    "amount": "108778.932"
  },
  {
    "state_description": "Mississippi",
    "amount": "366869.045"
  },
  {
    "state_description": "Minnesota",
    "amount": "115470.339"
  },
  {
    "state_description": "Middle Atlantic",
    "amount": "1713318.47910"
  },
  {
    "state_description": "Michigan",
    "amount": "366475.370"
  },
  {
    "state_description": "Massachusetts",
    "amount": "132792.448"
  },
  {
    "state_description": "Maryland",
    "amount": "100794.317"
  },
  {
    "state_description": "Maine",
    "amount": "42971.628"
  },
  {
    "state_description": "Louisiana",
    "amount": "404970.597"
  },
  {
    "state_description": "Kentucky",
    "amount": "163742.265"
  },
  {
    "state_description": "Kansas",
    "amount": "54844.788"
  },
  {
    "state_description": "Iowa",
    "amount": "84895.555"
  },
  {
    "state_description": "Indiana",
    "amount": "337012.8272"
  },
  {
    "state_description": "Illinois",
    "amount": "291070.392"
  },
  {
    "state_description": "Idaho",
    "amount": "46772.329"
  },
  {
    "state_description": "Hawaii",
    "amount": "13573.906"
  },
  {
    "state_description": "Georgia",
    "amount": "365233.686"
  },
  {
    "state_description": "Florida",
    "amount": "1235058.08079"
  },
  {
    "state_description": "East South Central",
    "amount": "1026486.199"
  },
  {
    "state_description": "East North Central",
    "amount": "1774481.3062"
  },
  {
    "state_description": "District of Columbia",
    "amount": "1594.812"
  },
  {
    "state_description": "Delaware",
    "amount": "32608.684"
  },
  {
    "state_description": "Connecticut",
    "amount": "172862.720"
  },
  {
    "state_description": "Colorado",
    "amount": "153445.931"
  },
  {
    "state_description": "California",
    "amount": "651662.51693"
  },
  {
    "state_description": "Arkansas",
    "amount": "185865.630"
  },
  {
    "state_description": "Arizona",
    "amount": "453878.572"
  },
  {
    "state_description": "Alaska",
    "amount": "25942.700"
  },
  {
    "state_description": "Alabama",
    "amount": "379707.642"
  }
]

# modify this dict list into dict with unique state_description keys
out_dict = {}
for dict_item in json_result:
    out_dict.update({dict_item['state_description']: dict_item['amount']})

print(len(out_dict))