'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "01eb2c11c2685e04a0e3b0556549b914",
".git/config": "9f2dfa7cba9204e514bc175585edc1dd",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "26799bb578c4ec87e2da3b3f82a60c37",
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
".git/index": "307511d36e75363090451fa78b070203",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "1a266537bab1f52a16d18721bccecc1d",
".git/logs/refs/heads/main": "b5117e6cb6d1c7493da3a7c65cbc3d7b",
".git/logs/refs/heads/master": "f97d0ed3feaceb8d1b780128c9b45306",
".git/logs/refs/remotes/main/main": "224b820f814593b9b9cc8ddf16495a85",
".git/logs/refs/remotes/main/source": "ef1a09904a90085062929b5599cebeac",
".git/objects/05/a9058f513cce5faf1704e06e3c150688b0a01f": "e8d02f60cf87abd4c1de4b153dd696dc",
".git/objects/06/8001edc8d59002e041678f7450b15e58fd42cf": "20259b32af87f563f5351fff0014a02b",
".git/objects/08/b80a3e645b29635ceeda0ad6258c699fb732e7": "eb4ba8dbdfc2ddd4d2d12ea3df4d88ca",
".git/objects/15/812f20cc32e81f7065d2b9f04c8062610835fa": "f66aee9b0c94eb91bc9a86748edb6a49",
".git/objects/19/2c10477e1bd7ff6ae24c22121093d3f125c475": "65472ee059df169bdc78b478f2732e1a",
".git/objects/1a/c6bbed14297e2eb35271a74ffdcde59edd8818": "455bc2d84a79eece13d6288e00e28901",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/22/45b8b0e6597d07272d7d84cf4fdbfae0ceed68": "9f7c883def71b621859bfb1363cfb42c",
".git/objects/23/a9bee4ff4d1399ce24a2341609083e6d756d0e": "2fe6e2849b0c796830803cc65f19be60",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/objects/27/a297abdda86a3cbc2d04f0036af1e62ae008c7": "51d74211c02d96c368704b99da4022d5",
".git/objects/2a/a4edabb05c84b4ef7b1665343054e545009f76": "45b767d028c54abd3018b3d88fc95974",
".git/objects/2b/607c08de6a7a7f81fcf156dfea2a2fdbf50e16": "f9748074475d5113685cb145c1f55a75",
".git/objects/37/1bc57c3473e68cf6eeee7e2163e77874c23858": "ebb40671302b99af72d8cf15317eb602",
".git/objects/38/75c690fd8c50ced5cc50250c8a5f9811a3eb7f": "b0b1f0fd53cd82dba449261f80c7ac81",
".git/objects/42/774bd455391c6ed741004b8234791d56302d73": "6272f614b28b1035e19c54ed0ffd1515",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/46/fd391407af6afe17950562747691a376988845": "248f97e0531027e11b5ec8be3efd29ce",
".git/objects/48/a9583c6ed4da509e360ed95f8e182a172e8450": "b296989d59d1df9489b05f022f898d08",
".git/objects/4a/fb9e99cf12e36b8484497e15f7f3c6c085ec06": "6864ffadd7935ba2642c236528a27652",
".git/objects/4d/0c68a3d6bb49323d19b02598ec7acc022c5d52": "c60a6fa632be820a9b84fa3de68dc325",
".git/objects/50/20978ecf11eea7019027e37be72180c1f5dcef": "ef7ee807c651bff54bf5026d74e47ae1",
".git/objects/5a/e717e910c09523511e92f9bddc954517422974": "341a2489b2c44d2d4b0d4aa30224eb30",
".git/objects/5b/4e2ecfd63c2791bf02e96c40eda668c686de70": "5f65ff358480d0a4ae604a2b19b06422",
".git/objects/5b/685462eaf40ddd75eb9b85ecdf4736858af60f": "d66fcbc226ddfd531dc4608762d5138a",
".git/objects/5e/5a6fe1f84ace7683d891271c45184a88a7d0f6": "0894ae640e5e4f82fa531646e5db4a96",
".git/objects/5f/155308b936064e9271fc6af23fd190d52f3636": "41654021e206c79c8496e2883ecef05b",
".git/objects/62/935b0ed773ecb9ecd49ff943c5ebb120bc9319": "b2b4fdaaf25950ffb07ec33cc8f72aa0",
".git/objects/63/6931bcaa0ab4c3ff63c22d54be8c048340177b": "8cc9c6021cbd64a862e0e47758619fb7",
".git/objects/69/1aa773174f947bcd524fd5878344ef14b3236b": "79ec2ec8d51b94082ab33a3d09d28543",
".git/objects/69/8d5cdf69c43d7cf94a161b005e6f2c4acf278c": "7811be539071c68aabf49977ad86d138",
".git/objects/6d/5f0fdc7ccbdf7d01fc607eb818f81a0165627e": "2b2403c52cb620129b4bbc62f12abd57",
".git/objects/70/7eb668b976cda29fd9fd8eaf0c573c55f39113": "b550148349128805de74f8bb7c5f3940",
".git/objects/71/4d63d87b9545abb3327229d009208e3eca16c9": "47f2cf6fda33ccfed0455549e41ed82d",
".git/objects/72/46b3d37060ee66ee7208cba059fb2d18e12069": "d1b4218582b3a62ca267b1f164c3eacc",
".git/objects/73/7f149c855c9ccd61a5e24ce64783eaf921c709": "1d813736c393435d016c1bfc46a6a3a6",
".git/objects/79/b93bc8dc377d094fea5d52da437e27e250d3a1": "af556dd1fb8871be1918edf504b41d9b",
".git/objects/7d/d0c87cb4d9913b0a09123518a01d56b5f26e7a": "ca6c658d7881c83798e9a07dd13270a7",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/85/7472e08d35f8040a6b90ab9279815ca1ad33a3": "3cc404789913e8738affcb3e3099bccd",
".git/objects/8c/59773bee8314a8ffb4431593d0fb49f52e34c6": "2eb993d30677573ffd0e58484cc6a514",
".git/objects/90/adb36ec1471c4cb52c92fc6e50d440d9a890eb": "01401bee1785b67a4ee16c52ab1d25da",
".git/objects/91/7cf67a233448473f31ba4f441a823d8640d2e0": "754668bbdd7713034a0cea18037a201e",
".git/objects/91/ca96a97eb93aa04ea7a79023ac9c325e482cae": "f87ca904abaab59c803069a351102ba6",
".git/objects/92/e304b7f1bf58ada9c57a6e1ffeb3f720ae8830": "eb8e4171a3c3f693d7218533cbf57481",
".git/objects/94/3f9c7ce3da648118369d70a23048fe4f68182a": "fac84124f33a05fdd8a4ba62d365af8e",
".git/objects/94/d3005be3f8112547191bbfd1a1c23037b75c05": "0b8202b13819edec3c0191cf2f5ac37d",
".git/objects/97/8a4d89de1d1e20408919ec3f54f9bba275d66f": "dbaa9c6711faa6123b43ef2573bc1457",
".git/objects/99/1204f1f2e5b111e206f495eb146ad6fa6f997c": "fff162327cc7ca86da0c4083ba35fb98",
".git/objects/9c/2c144134da3fd401597440a7e002878fc5951c": "801c60d931c67392bfb3cb92fcb90f4b",
".git/objects/9d/e2bae9ebe9812b8d2633aeccfa6dcc7e3bc5e1": "83be2b4377d641881567bde4dc0b530a",
".git/objects/a2/0689cd13e3e47521942c6ae593ab3236f376a5": "3e589c4603eb33e896672f9cd0a4eeb2",
".git/objects/a6/51a531c8146109ffc563e1e830edc55e83d758": "1c0e2da5436a2a898cee0f4958a89ab9",
".git/objects/a9/23430cb64788bdf6be7c455f92ea466bfa44c1": "70ad0d67860ecb0e37dfabed5d15ea4c",
".git/objects/af/31ef4d98c006d9ada76f407195ad20570cc8e1": "a9d4d1360c77d67b4bb052383a3bdfd9",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b1/afd5429fbe3cc7a88b89f454006eb7b018849a": "e4c2e016668208ba57348269fcb46d7b",
".git/objects/b3/68dccfccace4b137b60a4048ae95d30bb2a5b8": "ef60b80fbc3f68b63bc4b87fe9413183",
".git/objects/b4/0dd2148ff7122746575688c6aec32a565736de": "e1bd87bb6d93988b140a08141284361a",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/bb/f77e8a8174a211e2ae2ad21a8ba6a9d996ed12": "6e7a18dbade1be8d4008c0e1db8568a3",
".git/objects/bc/457a9f9c645f2e06b146dfb54be7db609eabcf": "01c60ec21109098bff1fca1566279799",
".git/objects/c3/e81f822689e3b8c05262eec63e4769e0dea74c": "8c6432dca0ea3fdc0d215dcc05d00a66",
".git/objects/c5/7ddfee52797b7ba41a1006598082a17ff5171b": "106b38dd157e6542344fde2a963d41b3",
".git/objects/c6/06caa16378473a4bb9e8807b6f43e69acf30ad": "ed187e1b169337b5fbbce611844136c6",
".git/objects/cb/0fe3778f4b6b5f3a6077525fba4e4635ce0094": "01431bfedd78b2fb58cca001b16bd030",
".git/objects/cf/d69b923fcab1a6d00cbda55eecc1cb7f8b04f7": "e9ccdc80e117a3c6775038913e04c11e",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/c7cd182b674258cc9bbd808c13368f803aaa31": "1adff5aed1f5778c0b833bb439495d6b",
".git/objects/e4/07579c78dc23dd32cb6468d5d2c51b18cc9bc9": "aaf8c1a553f8d42a0d3a366539aa9dbf",
".git/objects/e6/3ad113992b326802bd7b74cf730b1ca8ecc79b": "4fe3befabb411e1420f98e38b40fcd19",
".git/objects/e7/5dbdccc27704ca7cfd9cfbc31b3a4d4d6f3393": "c33e2ae3565187d25cb76bc61cba2c6b",
".git/objects/e7/8fc8957f651ad77095c050c96c0731bb563935": "288151da2685fab81bf9086e39dba220",
".git/objects/ea/8ff6577fb282d094735343a43411443e2f5cba": "21b1adba7562314c40d2b90692a27a6e",
".git/objects/ec/361605e9e785c47c62dd46a67f9c352731226b": "d1eafaea77b21719d7c450bcf18236d6",
".git/objects/ed/8f3ffd763bd2b690efefcd296f8e8f9df79dfc": "45ba8040ddf612c5527bff6666213e2e",
".git/objects/ef/3242b3b6a63786bfe82a2ec37b501dac364963": "0b319ae9fde211c8fe70249da06cc2d4",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/pack/pack-76f4efed5d9f15c3f6c1d88d256815bc19ecebe6.idx": "ed60254d46add6bb7aa987a3e3b85177",
".git/objects/pack/pack-76f4efed5d9f15c3f6c1d88d256815bc19ecebe6.pack": "d738accb949f011f3c82370330d550d8",
".git/objects/pack/pack-76f4efed5d9f15c3f6c1d88d256815bc19ecebe6.rev": "751c38345f7b1fa70cde74d377da8bbb",
".git/ORIG_HEAD": "8c258901567cd18615542031753c9324",
".git/refs/heads/main": "8c258901567cd18615542031753c9324",
".git/refs/heads/master": "16b488aa6c0da2978e346462e3cc783a",
".git/refs/remotes/main/main": "8c258901567cd18615542031753c9324",
".git/refs/remotes/main/source": "e63d10704e2be1922f0d0697afa92d7a",
"assets/AssetManifest.bin": "511c5d6c0b0b2657ca166cdc85287441",
"assets/AssetManifest.bin.json": "887d7f7662ac783bdef025ab2505faf2",
"assets/AssetManifest.json": "e9107588c6274581e0b5bcd4a6a4102c",
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
"assets/assets/json/Chin%25C3%25AAs.json": "56c5f66098d1df9dc955fb3c4b616cae",
"assets/assets/json/Cores.json": "c57e2c252546f772795bd4a6eab61e98",
"assets/assets/json/Hiragana.json": "c7d69795792dc74db5fe6b35d8631ec9",
"assets/assets/json/Katakana.json": "7c57ceaccb4816f444584cc859326ed4",
"assets/assets/json/N1.json": "7a16de20c0d175b74746d775749043c5",
"assets/assets/json/N2.json": "5d82ccf29b7d4bab1b46f082142f773e",
"assets/assets/json/N3.json": "b0a20374b93ba626dbfd91c356147d2b",
"assets/assets/json/N4.json": "0ff183f74ab5154b5c62a9bd6a76118c",
"assets/assets/json/N5.json": "830f8ffbd617b975b7b5e81956dd71ea",
"assets/assets/json/Sauda%25C3%25A7%25C3%25B5es.json": "1accc7d8bb5ee9dc633b23511cfe08fa",
"assets/assets/json/Tempo.json": "807a732e95e623f18aa7e5c50e5f82bb",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "b9b2430d917d589d1b01cefb79e191dc",
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
"favicon.ico": "9a953bd1e19e5a6d8480c59812168360",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "af9113a7a6c72eb6c029dab4d8fcad53",
"icons/apple-touch-icon.png": "df1582fd4b85d81bb76cc3bd2acfd066",
"icons/icon-192.png": "d9c3d6923263404d9e326f0ffe0a874a",
"icons/icon-512.png": "4900ac314b8149271884b48394d1a7de",
"icons/Icon-maskable-192.png": "7e7f9284ba8b64443efe34a9cfb7c1ca",
"icons/Icon-maskable-512.png": "7e050d7d730a5b76fdcbd113dba4b348",
"icons/main.png": "d9c3d6923263404d9e326f0ffe0a874a",
"images/e1.png": "cad14ee8f385c6eab07e4b438788f9cb",
"index.html": "8e3084ed552f249fbda9fb2fd4c4d150",
"/": "8e3084ed552f249fbda9fb2fd4c4d150",
"main.dart.js": "3464009741a416a1168f667f24e65a9c",
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
