# DBSchema — Nadodi v2.0

Data remains JSON-bundled (no server). Schema is the contract for map + nearby logic.

## 1. TouristPlace (assets/data/places.json)

| Field | Type | Notes |
|---|---|---|
| id | int | PK |
| name | string | |
| category | string | Beach, Hill Station, Waterfall, Historical, Backwaters |
| district | string | Kerala district |
| rating | double | 0-5 |
| description | string? | |
| imageUrl | string? | Network image |
| latitude | double? | **v2: required for map** |
| longitude | double? | **v2: required for map** |
| isSaved | bool | runtime only |

## 2. Hotel (assets/data/hotels.json)

id, name, type (Hotel/Homestay/Resort/Eco Lodge), district, price_range (₹ string),
rating, latitude?, longitude?, description?, imageUrl?, phone?, website?

## 3. Restaurant (assets/data/restaurants.json)

id, name, cuisine, district, rating, latitude?, longitude?, description?, imageUrl?,
phone?, website?, address?

## 4. HiddenSpot (assets/data/hidden_spots.json)

id, name, type (Local Trek / Secret Waterfall / Hidden Viewpoint / Village Lake /
Forest Trail), district, difficulty (Easy/Moderate/Hard), rating, latitude?,
longitude?, description?, imageUrl?, tips?

## 5. ExpenseItem (runtime + shared_preferences JSON)

| Field | Type | Notes |
|---|---|---|
| id | string | uuid-ish (timestamp+rand) |
| title | string | e.g. "Houseboat ride" |
| category | enum | transport / stay / food / activities / misc |
| amount | double | ₹ |
| date | string | ISO yyyy-MM-dd |
| placeId | int? | optional link to place |

Persistence shape (shared_preferences key `nadodi_trip_expenses_v1`):
```json
[
  {"id":"...","title":"...","category":"transport","amount":1200,"date":"2026-07-31","placeId":null}
]
```
Trip meta (traveler count) key `nadodi_trip_meta_v1`: `{"travelers":2}`.

## 6. Map lookup

`GeoService.nearby(lat, lng, radiusKm)` → haversine distance on all items with
coordinates, returns merged, sorted list grouped by type (places/hotels/restaurants/
hidden) with `distanceKm`.
