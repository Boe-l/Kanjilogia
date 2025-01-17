'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "dbaf00bd1b388a399b06657d4cfc1d04",
".git/config": "77648d8c815437241a515014d39f46ad",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "adb67306437843ffe5082ee81be2f6b2",
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
".git/index": "2926bb5667302f5f9ca7b6448b1f3abd",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "137085feb397921972fa684c98b2e23a",
".git/logs/refs/heads/main": "b35b28b5b79b344c2a68460734ed7495",
".git/logs/refs/heads/master": "311d88e6de6d02baafe5f9eeea10ea94",
".git/logs/refs/remotes/origin/main": "299800d58801d2eaa604c72f137f2579",
".git/logs/refs/remotes/origin/source": "932319662aa0741f0bdd277534aad512",
".git/objects/06/8001edc8d59002e041678f7450b15e58fd42cf": "20259b32af87f563f5351fff0014a02b",
".git/objects/12/e3ec514bd302d2b317e74e6c0a20f1d422b278": "3e336d3bcdfbcd4b04f868586793803a",
".git/objects/19/3b019545f196f657dc5eaca3897107332ec253": "3688a9119f6397c5a47fd7a21848d199",
".git/objects/1c/bc638e05934ee6edc8378105b8343a78c69118": "e32fc8356becdac097360404c4bb3e4c",
".git/objects/1d/15aa8496f403b2d75d1ae93b284ff43adcb5da": "dd11c02a041619f7a1f49c711bfc8e7a",
".git/objects/1f/2e8512a0852605496fcb771474a72e2a0f428c": "5d94d9c1744fdafa8f38d6c99b91d0b0",
".git/objects/22/45b8b0e6597d07272d7d84cf4fdbfae0ceed68": "9f7c883def71b621859bfb1363cfb42c",
".git/objects/23/222c94413e63e36a5fb827700cc05e068024bf": "ec8276a5a0493c927f8751f368e82b36",
".git/objects/23/a9bee4ff4d1399ce24a2341609083e6d756d0e": "2fe6e2849b0c796830803cc65f19be60",
".git/objects/27/a297abdda86a3cbc2d04f0036af1e62ae008c7": "51d74211c02d96c368704b99da4022d5",
".git/objects/29/7e2abb7b963f2dec3a9d9cad2eb93ec8f5fd24": "c49a7552e9919ce71db3f9a173e3dcd8",
".git/objects/30/24a92d1659e392c833693bce10366bfef66043": "4b8f88399b020a60aaec8a67c5075cbd",
".git/objects/30/6cdc0b70c478ac9f21d7a104758110f3b39f29": "29c4636890d1c3f40b062770cf788e2b",
".git/objects/32/0f8c8cf2ddae18e87a21c7b76f2628f2f14dac": "4fb70fc2435a9b5f4dec4ab60383ffb6",
".git/objects/32/2af168a3550f1623b1413d348cd8fd7452538c": "cd35b8dc6e1befec4d2dfda097eb6d68",
".git/objects/34/7371461a2f65af7ed9e1238d924a655ff3441c": "3fb0804742021e65a50bfad2c55def1a",
".git/objects/3a/c5df7b1bf92d8d0320494e9e07edc8ea0748cd": "c61f4a5f627b04257b9b2b9c4577d445",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/56/dfc3f3be924871f2647d665c2608818c9efee9": "f4a74044fe0daee0ac4cf1beb86a5d5b",
".git/objects/57/d8049db906285767cd6176b40e560b40de0a75": "73518f899b18c754924c7b74dfc5c320",
".git/objects/58/b767f55b812c6e0fddb503f37789e6eda5fc91": "fd7a6f86f9673d858b3f1d61a49b0038",
".git/objects/5e/5a6fe1f84ace7683d891271c45184a88a7d0f6": "0894ae640e5e4f82fa531646e5db4a96",
".git/objects/5f/155308b936064e9271fc6af23fd190d52f3636": "41654021e206c79c8496e2883ecef05b",
".git/objects/63/6931bcaa0ab4c3ff63c22d54be8c048340177b": "8cc9c6021cbd64a862e0e47758619fb7",
".git/objects/69/8d5cdf69c43d7cf94a161b005e6f2c4acf278c": "7811be539071c68aabf49977ad86d138",
".git/objects/6d/5f0fdc7ccbdf7d01fc607eb818f81a0165627e": "2b2403c52cb620129b4bbc62f12abd57",
".git/objects/73/7f149c855c9ccd61a5e24ce64783eaf921c709": "1d813736c393435d016c1bfc46a6a3a6",
".git/objects/73/f0dcd3e1c8af596ef718b170a0aa1e7cee798b": "f0c2ee25fbc5a0b020af1fa27e95c321",
".git/objects/7d/d0c87cb4d9913b0a09123518a01d56b5f26e7a": "ca6c658d7881c83798e9a07dd13270a7",
".git/objects/82/b542b201bf689dacf8411bcea5283a1b65f9f4": "f4327fa8595e0c98a6468f65c42b74d0",
".git/objects/85/7472e08d35f8040a6b90ab9279815ca1ad33a3": "3cc404789913e8738affcb3e3099bccd",
".git/objects/88/ebe6d5247ad96cda0f9cadbd383cf3ceee7276": "595a3c3613b17144759e0a08b8317f5c",
".git/objects/90/adb36ec1471c4cb52c92fc6e50d440d9a890eb": "01401bee1785b67a4ee16c52ab1d25da",
".git/objects/92/e304b7f1bf58ada9c57a6e1ffeb3f720ae8830": "eb8e4171a3c3f693d7218533cbf57481",
".git/objects/93/2309bcf8cf5ccabe3888a83d957c20a126717c": "78791a874b39e603c5033a099dbca8ab",
".git/objects/95/bc84e377db821715cf5217dba63a16ebb6ec7e": "c50738b6ef7352ef7fee3a37ea776ed6",
".git/objects/97/8a4d89de1d1e20408919ec3f54f9bba275d66f": "dbaa9c6711faa6123b43ef2573bc1457",
".git/objects/9e/177798781527d3e813269ace11944617ab427f": "822ffd010b8266ac26646c0e63cc7008",
".git/objects/a6/245736cbf6d1903a4c30fc74ac6cdcb2f453f0": "20cca73814f1eebc8f1c708105a70457",
".git/objects/a6/51a531c8146109ffc563e1e830edc55e83d758": "1c0e2da5436a2a898cee0f4958a89ab9",
".git/objects/a9/23430cb64788bdf6be7c455f92ea466bfa44c1": "70ad0d67860ecb0e37dfabed5d15ea4c",
".git/objects/ad/1fa6c8e95c52e6c5d718d43e9005b66b22478a": "af38a86843465852f407d96c765bbc36",
".git/objects/af/31ef4d98c006d9ada76f407195ad20570cc8e1": "a9d4d1360c77d67b4bb052383a3bdfd9",
".git/objects/b1/1bb542819d111f8b12108e856ba7c52ade105a": "04fc8916f5d65e5099cdcab1c9d18f0b",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b1/824552fd182c0aa53fbd2b293ef3d906f259df": "c86e9c4b4e485a60c6d2b1ba47a9cd1e",
".git/objects/b1/90e6187ee2ec7eb43a942037b25d985db1f4a9": "06f5ce74240ce912a39a777b81ea90ef",
".git/objects/b1/afd5429fbe3cc7a88b89f454006eb7b018849a": "e4c2e016668208ba57348269fcb46d7b",
".git/objects/b4/0dd2148ff7122746575688c6aec32a565736de": "e1bd87bb6d93988b140a08141284361a",
".git/objects/b4/edd1c45fd539ba74f7579736a89fc952517a1c": "d5d6cc3dc43cfed035cf7a1fc3ffdbee",
".git/objects/b6/ac476614800ec76e45563b12a9e1c370e24e9a": "83c29cb01d009b7e1699779baa18dfc9",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/bb/f77e8a8174a211e2ae2ad21a8ba6a9d996ed12": "6e7a18dbade1be8d4008c0e1db8568a3",
".git/objects/bc/457a9f9c645f2e06b146dfb54be7db609eabcf": "01c60ec21109098bff1fca1566279799",
".git/objects/bf/85b46d788cf9f4cae136a156ef8865b2c8e528": "03789ec0b83db5ff75bc78b652b32ebb",
".git/objects/c3/e81f822689e3b8c05262eec63e4769e0dea74c": "8c6432dca0ea3fdc0d215dcc05d00a66",
".git/objects/c4/b1d3a51f3f1899da91950b7b40c86f2422c8aa": "f79781e503fab8e78ecf569d28769674",
".git/objects/c6/06caa16378473a4bb9e8807b6f43e69acf30ad": "ed187e1b169337b5fbbce611844136c6",
".git/objects/d1/4e1d4301f177517724ccf7f43aedcc84930dde": "9fec3cfa2013c9482a7ae80c0081662f",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/c7cd182b674258cc9bbd808c13368f803aaa31": "1adff5aed1f5778c0b833bb439495d6b",
".git/objects/d6/781e60d0fdbeade67ee20838b078d9f7df9ffe": "710beb67efc1ba3cd1ba7097c029c083",
".git/objects/dc/eeb3f72d824ccc3bd37b122e268dcecb75c5ff": "08d7eddc9daf4303142dc92f1d77fb53",
".git/objects/dd/8916f0dcc6aeab79d4e3970fd67783b18adbb2": "da7f18d781c185203ad1c29c2bb5d189",
".git/objects/ec/22d46614239a5716d8fe82c7ccd9331343634d": "2e34c29cb63ec440bfbd96a07a0625aa",
".git/objects/ec/361605e9e785c47c62dd46a67f9c352731226b": "d1eafaea77b21719d7c450bcf18236d6",
".git/objects/ee/809523deba546ca6f508e5cbabd18e8d15607c": "968ebfcb572f40c0859ea9d086719c04",
".git/objects/ef/3242b3b6a63786bfe82a2ec37b501dac364963": "0b319ae9fde211c8fe70249da06cc2d4",
".git/objects/f8/96ed43d873a6c7ba80c1b76af6f7a6323590b8": "b2b193e7d7dda79d974eb35bc9b89b05",
".git/objects/pack/pack-bc8ee70810144f458ae7af72abbee2ebc886aaef.idx": "42f789027ed3fd7196529d4970943af7",
".git/objects/pack/pack-bc8ee70810144f458ae7af72abbee2ebc886aaef.pack": "30046633402ea6e963601516546be98e",
".git/objects/pack/pack-bc8ee70810144f458ae7af72abbee2ebc886aaef.rev": "78cd7bbf913367f3eeb60346816f070d",
".git/ORIG_HEAD": "509a27739ab58b4fe96be128658d57e1",
".git/refs/heads/main": "e9cbe4337f3969a32fd87b20bb42a1f4",
".git/refs/heads/master": "93630cc58e6e90d48009bf8ad62978ff",
".git/refs/remotes/origin/main": "e9cbe4337f3969a32fd87b20bb42a1f4",
".git/refs/remotes/origin/source": "b7043b4c8468a071ca309c58a0105dbc",
"assets/AssetManifest.bin": "ec9c29c4204afe9bbf9e7d5c40201010",
"assets/AssetManifest.bin.json": "c9b4d06bc63f9f0ca6fafae56a4e8520",
"assets/AssetManifest.json": "835d563113e23f2e5c4fc184ba231ea3",
"assets/assets/flags/brazil.png": "bb0e4c272d25b2074e9531812660ae18",
"assets/assets/flags/china.png": "8097f5abbe93eb8f353e893b77fa58be",
"assets/assets/flags/default.png": "06bbaf25add8a02b0d3b213977f3a8bb",
"assets/assets/flags/japan.png": "a2542be9b1833ebbdf4c906e79969457",
"assets/assets/flags/southkorea.png": "e82f432f44c8c56d88321440414a0930",
"assets/assets/flags/spain.png": "74189fa01ec866d612de8acf53c305e3",
"assets/assets/flags/usa.png": "bff9fa1e3c746ba0b61821903c8f3b22",
"assets/assets/json/Chin%25C3%25AAs.json": "2b957a3ba148d2c4c5d8233331b22a00",
"assets/assets/json/Chines.json": "008be8a0d8fb15f16df5e29b4413697b",
"assets/assets/json/Espan%25C3%25B5l.json": "7745d6045896333d0135c65cb4d3f234",
"assets/assets/json/Hiragana.json": "b281a4f384c14d42afdaece617c60df0",
"assets/assets/json/Ingl%25C3%25AAs.json": "2d0516747d13a29291ddeebf5b52235f",
"assets/assets/json/Invalido.json": "e6d418ad6cd28c6b5b898e9eaaf553fc",
"assets/assets/json/Jap%25C3%25B4nes.json": "935c2d99bb8525d765d7e7b3f4b31166",
"assets/assets/json/Katakana.json": "a228bf43781b5beb3e97b4afddf0d2fd",
"assets/assets/json/Korean.json": "b5a261c5c1362a85dbdb69987bbdc950",
"assets/assets/json/N1.json": "7a16de20c0d175b74746d775749043c5",
"assets/assets/json/N2.json": "5d82ccf29b7d4bab1b46f082142f773e",
"assets/assets/json/N3.json": "b0a20374b93ba626dbfd91c356147d2b",
"assets/assets/json/N4.json": "0ff183f74ab5154b5c62a9bd6a76118c",
"assets/assets/json/N5.json": "830f8ffbd617b975b7b5e81956dd71ea",
"assets/assets/json/None.json": "e8e87fa3f71ceb7d317dec6f71932248",
"assets/assets/json/Portugues.json": "5b9589f919059f62031b08d08033c020",
"assets/assets/json/Romaji.json": "e1e7c2b98625bceb2962002671b67563",
"assets/assets/json/teste.json": "63a9bcb5f8063825b5be5ed8b4e77159",
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
"flutter_bootstrap.js": "6adb3516e6bb8f7919a72bc64ee3f0c9",
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
"README.md": "07023db9fd15e6e77f292562fe0d3af9",
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
