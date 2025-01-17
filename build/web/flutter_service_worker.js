'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ec9c29c4204afe9bbf9e7d5c40201010",
"assets/AssetManifest.bin.json": "c9b4d06bc63f9f0ca6fafae56a4e8520",
"assets/AssetManifest.json": "835d563113e23f2e5c4fc184ba231ea3",
"assets/assets/flags/brazil.png": "bb0e4c272d25b2074e9531812660ae18",
"assets/assets/flags/china.png": "8097f5abbe93eb8f353e893b77fa58be",
"assets/assets/flags/default.png": "06bbaf25add8a02b0d3b213977f3a8bb",
"assets/assets/flags/japan.png": "a2542be9b1833ebbdf4c906e79969457",
"assets/assets/flags/southkorea.png": "e82f432f44c8c56d88321440414a0930",
"assets/assets/flags/spain.png": "74189fa01ec866d612de8acf53c305e3",
"assets/assets/flags/usa.png": "bff9fa1e3c746ba0b61821903c8f3b22",
"assets/assets/json/Chin%25C3%25AAs.json": "c1f8a7defd6b17204c11da7c99e1f2ae",
"assets/assets/json/Espan%25C3%25B5l.json": "57ba690a1f954a84e93b5366f654af58",
"assets/assets/json/Ingl%25C3%25AAs.json": "ca0cbe64d7e315e0569106dc6aa3a996",
"assets/assets/json/Invalido.json": "e6d418ad6cd28c6b5b898e9eaaf553fc",
"assets/assets/json/Jap%25C3%25B4nes.json": "431704d3d00f7dd42b8a4ef699d9205c",
"assets/assets/json/Korean.json": "3a0146f2eff6bef05885b727a47a56f2",
"assets/assets/json/N1.json": "7a16de20c0d175b74746d775749043c5",
"assets/assets/json/N2.json": "5d82ccf29b7d4bab1b46f082142f773e",
"assets/assets/json/N3.json": "b0a20374b93ba626dbfd91c356147d2b",
"assets/assets/json/N4.json": "0ff183f74ab5154b5c62a9bd6a76118c",
"assets/assets/json/N5.json": "830f8ffbd617b975b7b5e81956dd71ea",
"assets/assets/json/None.json": "808d7df6519468cda0c2feb8fa4b65d1",
"assets/assets/json/Portugues.json": "f1728191383886caac021ca699254647",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "47ee77ca3cd3c501d4dbfb79eebc2948",
"assets/NOTICES": "9adaf54d01095101261931165f9c2647",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "a8e18e707e65adaded2b27dc1aff909d",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "cad2c652bc27ee85db5460e5b3da2f78",
"icons/Icon-192.png": "0d71245a60630e34a7563e8480921be9",
"icons/Icon-512.png": "f2a30dcd922e61868e8b2ee0ea3748f1",
"icons/Icon-maskable-192.png": "0d71245a60630e34a7563e8480921be9",
"icons/Icon-maskable-512.png": "f2a30dcd922e61868e8b2ee0ea3748f1",
"icons/main.png": "a8e18e707e65adaded2b27dc1aff909d",
"images/e1.png": "cad14ee8f385c6eab07e4b438788f9cb",
"index.html": "40e2b1977f5612bc2c132b37980eb585",
"/": "40e2b1977f5612bc2c132b37980eb585",
"main.dart.js": "631b3095e07b43813aacc4bd0afab946",
"manifest.json": "56781a6656016ff9f66f113529ea23f2",
"version.json": "b7cd2060b251a7ba5a8ac011f995e4aa"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
