const functions = require("firebase-functions");

exports.getShortestPath = functions.https.onCall((data, context) => {
  const places = data.places;
  const permutedPath = permute(places, 0, places.length - 1);

  return getShortest(permutedPath);
});

/**
 * Permute the array of places.
 * @param {Array} places - The array of places.
 * @param {Number} k - The index of the current element.
 * @param {Number} n - The index of the last element.
 * @return {Array} The array of permuted paths.
 */
function permute(places, k, n) {
  if (k == n) {
    return places;
  }

  for (let i = k; i <= n; i++) {
    places = swap(places, k, i);
    permute(places, k + 1, n);
    places = swap(places, k, i);
  }
}

/**
 * Swap two elements in an array.
 * @param {Array} places - The array of places.
 * @param {Number} i - Index of the first element.
 * @param {Number} j - Index of the second element.
 * @return {Array} The array with the two elements swapped.
*/
function swap(places, i, j) {
  const tmp = places[i];
  places[i] = places[j];
  places[j] = tmp;

  return places;
}

/**
 * Get the shortest path between two places.
 * @param {*} permutedPath
 * @return {*} The shortest path.
 */
function getShortest(permutedPath) {
  let shortest = permutedPath[0];

  for (let i = 1; i < permutedPath.length; i++) {
    let tmpDistance = 0;

    for (let j = 0; j < permutedPath[i].length; j++) {
      tmpDistance += getDistance(
          permutedPath[i][j],
          permutedPath[i][j + 1]
      );
    }

    if (tmpDistance < shortest.distance) {
      shortest = permutedPath[i];
    }
  }

  return shortest;
}

/**
 * Get the distance between two places.
 * @param {*} place1 - The first place.
 * @param {*} place2 - The second place.
 * @return {*} The distance between the two places.
 */
function getDistance(place1, place2) {
  const lat1 = place1.lat;
  const lon1 = place1.lon;
  const lat2 = place2.lat;
  const lon2 = place2.lon;

  return Math.sqrt(
      Math.pow(lat1 - lat2, 2) + Math.pow(lon1 - lon2, 2)
  );
}
