'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "28826a1d182c6ef28708c46877f90357",
".git/config": "3fc057b03936b7b9aa2e4af898ff2a46",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "4fad7092f4d6b7411c9bda0d4bdf04b5",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "c32aea16555a20bd00be00137bd08989",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "53bfc42e648df09aa2bdb229848c9fff",
".git/logs/refs/heads/main": "630517e2edf38a4fc48b6272115efc80",
".git/logs/refs/heads/master": "5f57d7a636bae6d783d2324880a55452",
".git/logs/refs/remotes/origin/main": "c4334d5dc181603f96b5a8a98ab26a6c",
".git/logs/refs/remotes/origin/master": "029505f4d6669450b2a1f4ee2a0f05be",
".git/logs/refs/remotes/origin/source": "987db3ae1763b808292d9fdba3d0c22a",
".git/logs/refs/remotes/origin/sourcecode": "8fcdc68c8414ad24b545c189ec094f33",
".git/objects/04/4f9fea6a1cb3d19b3681ca25e81cddce663108": "2db89c0b75f656af8304b9b922e81e4a",
".git/objects/05/a9058f513cce5faf1704e06e3c150688b0a01f": "e8d02f60cf87abd4c1de4b153dd696dc",
".git/objects/0a/1aa74ef14d4a57524a71f42c6f27452623c518": "0d55cbf628bfcd495ba0ef6febe46556",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/23/a9bee4ff4d1399ce24a2341609083e6d756d0e": "2fe6e2849b0c796830803cc65f19be60",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/objects/26/9d14e30d66d4cbbe237b69829344a424b458c2": "ac04d2a6ef5ac74c60b5a5cf70401c8c",
".git/objects/27/a297abdda86a3cbc2d04f0036af1e62ae008c7": "51d74211c02d96c368704b99da4022d5",
".git/objects/2b/1fd9d404cb222f7a8ccb1d29b08098b6ec899d": "b822c345f7c1e3338292133813287341",
".git/objects/33/0b78ee33ece1f7ba5751d8dca2b8bb32fa8300": "91e7fff304e83d6971405386cf869b0a",
".git/objects/43/1cded09503d5af90f7f05be47407673c48bcad": "14e6f61ff738e5f48bdd39361db9b87e",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4a/a93f875a620a35aa66e40fa66d996339032ec1": "63196c010743c31ba0a2a77da8eaf77b",
".git/objects/4a/f73788773967bcff1d22a119e4dfe0e36ca6d9": "08193f724a80fce0f610428ed2b965b0",
".git/objects/4d/7c47566ce20a4ab06b187356834d747d7ac2e6": "4e487beac0a588eddeb758f07133bdc2",
".git/objects/5e/5a6fe1f84ace7683d891271c45184a88a7d0f6": "0894ae640e5e4f82fa531646e5db4a96",
".git/objects/63/6931bcaa0ab4c3ff63c22d54be8c048340177b": "8cc9c6021cbd64a862e0e47758619fb7",
".git/objects/68/3735f84c81f2b9ebf1195d46e9c06d36cacdc5": "62b1b879ed202ce0336edfdb169a8cda",
".git/objects/69/76da9c67eb5317fdb048cca110659607ccba58": "adf3254fd329c8d7d0a7f864301b5ba0",
".git/objects/69/8d5cdf69c43d7cf94a161b005e6f2c4acf278c": "7811be539071c68aabf49977ad86d138",
".git/objects/6d/5f0fdc7ccbdf7d01fc607eb818f81a0165627e": "2b2403c52cb620129b4bbc62f12abd57",
".git/objects/73/7f149c855c9ccd61a5e24ce64783eaf921c709": "1d813736c393435d016c1bfc46a6a3a6",
".git/objects/7c/3b469cb0ce25632c554f487e9218a54283dec1": "13ee90f6eab75b1be429fef6189ca554",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/8c/59773bee8314a8ffb4431593d0fb49f52e34c6": "2eb993d30677573ffd0e58484cc6a514",
".git/objects/92/e304b7f1bf58ada9c57a6e1ffeb3f720ae8830": "eb8e4171a3c3f693d7218533cbf57481",
".git/objects/97/8a4d89de1d1e20408919ec3f54f9bba275d66f": "dbaa9c6711faa6123b43ef2573bc1457",
".git/objects/98/1bf2ba9a8a27306fdff80b7b838bd1a7ded4bc": "e0d807a47b6feb9c5439e953256db850",
".git/objects/9e/7a577cc8b61fa793eec339d4f1a4403aa6eac7": "3b00e8587fcc422b9ca83337704281a6",
".git/objects/a8/3802ea6e460b75ba77338d3f88c583baadfd33": "ad818685172241a27909b66169f64968",
".git/objects/af/31ef4d98c006d9ada76f407195ad20570cc8e1": "a9d4d1360c77d67b4bb052383a3bdfd9",
".git/objects/b1/1bb542819d111f8b12108e856ba7c52ade105a": "04fc8916f5d65e5099cdcab1c9d18f0b",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b1/afd5429fbe3cc7a88b89f454006eb7b018849a": "e4c2e016668208ba57348269fcb46d7b",
".git/objects/b4/323c5686d4bbe51a2ef93cbef4d5547a0b2c81": "c3b087b5d0edfefe5a443c0ad671138a",
".git/objects/b6/ac476614800ec76e45563b12a9e1c370e24e9a": "83c29cb01d009b7e1699779baa18dfc9",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/ba/8dfdd603ece3ae94356a176fcc2c10fe10fb67": "0188472e9fa3f08b71679e21f83ac67e",
".git/objects/bd/fa2ae76ecd142d09ada406a906bf6240eb71d2": "2b525171716df74d8dcd8922628abe08",
".git/objects/bf/cd3540f88d261f61ef67617463cb8ea8fab0eb": "1cfae47a61cd050b0b8a1839ed81658c",
".git/objects/c1/450572b497b674f049d306e3a184b5b85786b9": "3a1070cf9af3b460535d1d69c28a5103",
".git/objects/c3/e81f822689e3b8c05262eec63e4769e0dea74c": "8c6432dca0ea3fdc0d215dcc05d00a66",
".git/objects/c6/06caa16378473a4bb9e8807b6f43e69acf30ad": "ed187e1b169337b5fbbce611844136c6",
".git/objects/ca/0a5e407ba804e8f83ce1a033996d01ce5ddab5": "e303ad04fd7d747e642144dc0463fb36",
".git/objects/ca/991f80416b4ed4a0147d49ad1f90d0752b1815": "7e6b0d27577797c7ec22d08cc4823d8c",
".git/objects/cc/ba64133f57d3cdb417be0758cdf6145e71c54d": "c575c0f1f8a8e5b6ef443a1a22bc1df2",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/c9c6d19167dcb029b00edd8b9fc0c238d8e8a0": "3b85e389ebef23137eca77a7fb7bb7bd",
".git/objects/db/05fe2dc7bb308a30bc752fe486f85f84e9f369": "923271a262ef16117935f0bf14b36fce",
".git/objects/ea/dc130a12f5cde0577b31d819957d1c1c0412a6": "a377e13ecfddb0f8c954cb3481d416fc",
".git/objects/eb/617ce48301f9e2ca1d608a40d567ba66b93756": "0c3b871e619069554b89c3cc786c07ad",
".git/objects/ec/361605e9e785c47c62dd46a67f9c352731226b": "d1eafaea77b21719d7c450bcf18236d6",
".git/objects/ee/809523deba546ca6f508e5cbabd18e8d15607c": "968ebfcb572f40c0859ea9d086719c04",
".git/objects/ef/16ecd665358879e878214bc32357f600cde10d": "82ead0c98b04163e838ef44e688199fd",
".git/objects/ef/3242b3b6a63786bfe82a2ec37b501dac364963": "0b319ae9fde211c8fe70249da06cc2d4",
".git/objects/f0/eccb3e985bceddcdae277cbe37793d5c2edc94": "e286bfbbf71875b3880e0e6039a8c46e",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f9/05e62c0c9ed774b698bcc6bbb8bd1cdeb8d293": "4599441c691061d7c1cc31770d86f73e",
".git/objects/fd/dc93bf7aa9d38cab33c710940086b01410a7b6": "5d9001df9da0ab59375f386ef7eef246",
".git/objects/pack/pack-3c934430be3908518dbcf37f55e16bffd7276478.idx": "96834d557e74b6d3ae58bbc78b02bc15",
".git/objects/pack/pack-3c934430be3908518dbcf37f55e16bffd7276478.pack": "eacd0c94fc34e6f30131325af8dc90cd",
".git/objects/pack/pack-3c934430be3908518dbcf37f55e16bffd7276478.rev": "a1d60909d147cbdaa5615f9d446aa74b",
".git/objects/pack/pack-cd53b9929d4acc98a09cce1d9a97aa9e2d7039ae.idx": "09054c3d94bc330818e5ad37b0ba90f4",
".git/objects/pack/pack-cd53b9929d4acc98a09cce1d9a97aa9e2d7039ae.pack": "3b2f5099a11b34ecf8b1b87adb6738fb",
".git/objects/pack/pack-cd53b9929d4acc98a09cce1d9a97aa9e2d7039ae.rev": "c37a16e3dfd1e057c452e9f01ff3dac1",
".git/ORIG_HEAD": "aa206d79d20380391bb9c730b6e30382",
".git/refs/heads/main": "aa206d79d20380391bb9c730b6e30382",
".git/refs/heads/master": "8584cffc691e0a6ae8bbb9dc2c108dcd",
".git/refs/remotes/origin/main": "aa206d79d20380391bb9c730b6e30382",
".git/refs/remotes/origin/master": "8584cffc691e0a6ae8bbb9dc2c108dcd",
".git/refs/remotes/origin/source": "ab2976b4656e382f289d8b9d279dae3b",
".git/refs/remotes/origin/sourcecode": "aa206d79d20380391bb9c730b6e30382",
"assets/AssetManifest.bin": "da72b5803e47bbdc4735f1f323c03253",
"assets/AssetManifest.bin.json": "9f6e6266abbd62b88a3a4e7f84fadfbb",
"assets/AssetManifest.json": "be0282abf57a91460ef65754e143d2a8",
"assets/assets/flags/brazil.png": "bb0e4c272d25b2074e9531812660ae18",
"assets/assets/flags/china.png": "8097f5abbe93eb8f353e893b77fa58be",
"assets/assets/flags/default.png": "06bbaf25add8a02b0d3b213977f3a8bb",
"assets/assets/flags/japan.png": "a2542be9b1833ebbdf4c906e79969457",
"assets/assets/flags/southkorea.png": "e82f432f44c8c56d88321440414a0930",
"assets/assets/flags/spain.png": "74189fa01ec866d612de8acf53c305e3",
"assets/assets/flags/usa.png": "bff9fa1e3c746ba0b61821903c8f3b22",
"assets/assets/json/Chines.json": "008be8a0d8fb15f16df5e29b4413697b",
"assets/assets/json/Hiragana.json": "b281a4f384c14d42afdaece617c60df0",
"assets/assets/json/Katakana.json": "a228bf43781b5beb3e97b4afddf0d2fd",
"assets/assets/json/N1.json": "e318986f24dcc8d1aaa0dc8d1f22d115",
"assets/assets/json/N2.json": "6abdc8367107cda4f6d50eb9923111f9",
"assets/assets/json/N3.json": "a8841a87700b838ab4887c302f87db31",
"assets/assets/json/N4.json": "e5567e15662b65fafbb5873df1bc8688",
"assets/assets/json/N5.json": "4e9624e8e08610ede9525ef086debfdb",
"assets/assets/json/Romaji.json": "e1e7c2b98625bceb2962002671b67563",
"assets/assets/json/teste.json": "63a9bcb5f8063825b5be5ed8b4e77159",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "67959bc967ddb2b3d2da6f116d8fcf51",
"assets/NOTICES": "2dcd4a22a933094c4b71c342c9574635",
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
"flutter_bootstrap.js": "7cb42834b7940e90c0c2f1ac50547350",
"icons/Icon-192.png": "0d71245a60630e34a7563e8480921be9",
"icons/Icon-512.png": "f2a30dcd922e61868e8b2ee0ea3748f1",
"icons/Icon-maskable-192.png": "0d71245a60630e34a7563e8480921be9",
"icons/Icon-maskable-512.png": "f2a30dcd922e61868e8b2ee0ea3748f1",
"icons/main.png": "a8e18e707e65adaded2b27dc1aff909d",
"image.png": "edd5bd2ff3fb7d367eb94c7a28234b1b",
"index.html": "3d0e758c0a3ed18cc4619978ee2de5b8",
"/": "3d0e758c0a3ed18cc4619978ee2de5b8",
"main.dart.js": "ecea65e4821cc05c6371c7d160e7b80d",
"manifest.json": "56781a6656016ff9f66f113529ea23f2",
"README.md": "538120f6f1f5ed786ca5d3ccb4f0fd29",
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
