'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "8bd65ee9ecee2b59143a32ef988256bc",
"assets/AssetManifest.bin.json": "4fe9de3f64c679909390c236ad5141dd",
"assets/AssetManifest.json": "565f3ab2e149eed7f39b76ca022b71be",
"assets/assets/flags/bangladesh.png": "a3e941d46a92330888fa52a63cc90505",
"assets/assets/flags/brazil.png": "bb0e4c272d25b2074e9531812660ae18",
"assets/assets/flags/china.png": "8097f5abbe93eb8f353e893b77fa58be",
"assets/assets/flags/default.png": "06bbaf25add8a02b0d3b213977f3a8bb",
"assets/assets/flags/france.png": "32b2edf693a6d96a9d00cc88672f7a56",
"assets/assets/flags/germany.png": "6ff6a4539fc84fd159ff80ea6a306c04",
"assets/assets/flags/india.png": "ced4ae997eef71d640e4002c99125ed1",
"assets/assets/flags/italy.png": "de6869d6d954e013cdc3c68c2389e1ee",
"assets/assets/flags/japan.png": "a2542be9b1833ebbdf4c906e79969457",
"assets/assets/flags/russia.png": "39ccf6bdb81b6989aa3b1f0a2f0793a5",
"assets/assets/flags/southkorea.png": "e82f432f44c8c56d88321440414a0930",
"assets/assets/flags/spain.png": "74189fa01ec866d612de8acf53c305e3",
"assets/assets/flags/turkey.png": "ef78e4992013926b8d470489856550e9",
"assets/assets/flags/uae.png": "18c6ffd37c7b2129dc961dee82e240a1",
"assets/assets/flags/usa.png": "bff9fa1e3c746ba0b61821903c8f3b22",
"assets/assets/icon/app_icon.png": "1f79029fc63438b0ce5ddab28c926cbe",
"assets/assets/icon/Jisho.png": "561ffa7ff3df4c4adc67d7d21f1b3632",
"assets/assets/json/Chin%25C3%25AAs.json": "96bde9e1b73652b2ba58fdba4ebcba05",
"assets/assets/json/Conjugation%2520EN-JP.json": "598847624f85e916446bed329518957b",
"assets/assets/json/Conjugation%2520ES-JP.json": "b6abede5da6d45684efdd0ab66340037",
"assets/assets/json/Conjugation%2520PT-JP.json": "bf7872dc05c810174d477778f92608ba",
"assets/assets/json/Cores.json": "118d5cddbb73e8f41c51825648410c3d",
"assets/assets/json/EN-JP%2520Example.json": "5194bcf62e5bb9b7de46774e1e878aae",
"assets/assets/json/ES-JP%2520Example.json": "0ca216f9ff650dbb18407acc73e05ea7",
"assets/assets/json/Hiragana.json": "4b7804801ba0e33bf52b2859a9f4fd52",
"assets/assets/json/JP_teste_2.json": "83212f7ae77f84b1cc1fdbc11346d493",
"assets/assets/json/Katakana.json": "0a1b1159c2209cb8e7bfe576a9d4aedb",
"assets/assets/json/N4%2520EN-JP%25201.json": "602fd66f0554b9f6bfb3b951adada793",
"assets/assets/json/N4%2520EN-JP%25202.json": "7af066155062348ea3504666b70076ec",
"assets/assets/json/N4%2520ES-JP%25201.json": "ba64d72f0aef7153b9e911aec5427694",
"assets/assets/json/N4%2520ES-JP%25202.json": "0be0c93fcb0492e28a4a0ad12e6e3e11",
"assets/assets/json/N4%2520PT-JP%25201.json": "be49d92bef33e469fc54b7387fd51ba1",
"assets/assets/json/N4%2520PT-JP%25202.json": "56cb23f5acf3a38102f9c0a8d2822903",
"assets/assets/json/N5%2520EN-JP%25201.json": "a3ddef2600b4cf7be9435d47746031e9",
"assets/assets/json/N5%2520EN-JP%25202.json": "78453a0a4ed261478423536cac2e371d",
"assets/assets/json/N5%2520EN-JP%25203.json": "430dd8e7ce03e76e6850a60e07f61869",
"assets/assets/json/N5%2520ES-JP%25201.json": "9cddc67b4079366c311bd3ee216767e7",
"assets/assets/json/N5%2520ES-JP%25202.json": "44f2804b99bcb323a529ccff125af6f0",
"assets/assets/json/N5%2520ES-JP%25203.json": "50b9dc9f43ab1f6d061ff88a24aae0e5",
"assets/assets/json/N5%2520PT-JP%25201.json": "bbc9bc74583091d3da580dc2a0e4b85e",
"assets/assets/json/N5%2520PT-JP%25202.json": "7337cdfbcee347f03caf0cc0d050e041",
"assets/assets/json/N5%2520PT-JP%25203.json": "fe8f80f9bfbc828e409b5def10304ac4",
"assets/assets/json/PT-JP%2520Example.json": "66b97af62cd9bfef2284ba6ad577f498",
"assets/assets/json/Sauda%25C3%25A7%25C3%25B5es.json": "64f9ef23187852292ef977b587f95a46",
"assets/assets/json/Tempo.json": "22db2184975722f887233c0f89e58c2a",
"assets/assets/lottie/1.json": "d73898ef3e7e9d962bb6f970f6555038",
"assets/assets/lottie/2.json": "da6094b31540ea6f813e05311c07c8ab",
"assets/assets/lottie/3.json": "cea6065a25a920aff53b351e7cbea784",
"assets/assets/lottie/4.json": "d73898ef3e7e9d962bb6f970f6555038",
"assets/assets/lottie/5.json": "da6094b31540ea6f813e05311c07c8ab",
"assets/assets/lottie/6.json": "cea6065a25a920aff53b351e7cbea784",
"assets/assets/lottie/7.json": "02924c4344fc3101032e1b656110b1d1",
"assets/assets/lottie/8.json": "63462b13f7890a073d25ca23ce2dee55",
"assets/assets/lottie/9.json": "25ecbfce8c518e38f5d52984f72bc235",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "12ed74f9f6a2cd9268823df81ae6f109",
"assets/NOTICES": "6ae0ce0e9e30aaae6d53ee795dd0139a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.ico": "9a953bd1e19e5a6d8480c59812168360",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "68b99e7c61fe497eda02aeebf818b3c0",
"icons/apple-touch-icon.png": "df1582fd4b85d81bb76cc3bd2acfd066",
"icons/icon-192.png": "d9c3d6923263404d9e326f0ffe0a874a",
"icons/icon-512.png": "4900ac314b8149271884b48394d1a7de",
"icons/Icon-maskable-192.png": "7e7f9284ba8b64443efe34a9cfb7c1ca",
"icons/Icon-maskable-512.png": "7e050d7d730a5b76fdcbd113dba4b348",
"icons/Logo%20splash.png": "1f79029fc63438b0ce5ddab28c926cbe",
"icons/main.png": "d9c3d6923263404d9e326f0ffe0a874a",
"images/e1.png": "cad14ee8f385c6eab07e4b438788f9cb",
"index.html": "b8b62da01c916c1f9acb7257048d9d7f",
"/": "b8b62da01c916c1f9acb7257048d9d7f",
"main.dart.js": "cbd38e7b249d8dee0a0e25ebfb402bd7",
"manifest.json": "56781a6656016ff9f66f113529ea23f2",
"splash/img/dark-1x.png": "e98feed39d8116cf0a094df06b6e56ff",
"splash/img/dark-2x.png": "8b853f001a488f936ad1a639b2508eb2",
"splash/img/dark-3x.png": "358131ac93f5d6283d0d6155049b4e9f",
"splash/img/dark-4x.png": "d572d1e74caefa9f40a737160fdb30b5",
"splash/img/light-1x.png": "e98feed39d8116cf0a094df06b6e56ff",
"splash/img/light-2x.png": "8b853f001a488f936ad1a639b2508eb2",
"splash/img/light-3x.png": "358131ac93f5d6283d0d6155049b4e9f",
"splash/img/light-4x.png": "d572d1e74caefa9f40a737160fdb30b5",
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
