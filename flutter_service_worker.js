'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "482bd7784d2d33b2fe1f62c3ed66013f",
".git/config": "b38751f19a2bfc40e4663bc74615f108",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "95ff0e031f3f9bee85f9178c53ab5ba1",
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
".git/index": "f21cbab1e4796dcc63f3a61fbfcd916f",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b56fe372545d2bcd14c050bdcfbf5aa6",
".git/logs/refs/heads/main": "e910af8195520918339bf591366425d0",
".git/logs/refs/heads/master": "5f57d7a636bae6d783d2324880a55452",
".git/logs/refs/remotes/origin/main": "64f65df4075383228ec9a942f3d5ba8e",
".git/logs/refs/remotes/origin/master": "029505f4d6669450b2a1f4ee2a0f05be",
".git/logs/refs/remotes/origin/source": "daaacec477a8d0603a116c7c0770d491",
".git/logs/refs/remotes/origin/sourcecode": "8fcdc68c8414ad24b545c189ec094f33",
".git/objects/03/47fc6d006f8f0c6d03d6395dd7827e0eb24492": "0edcbd238343a48333f3436e96601101",
".git/objects/04/4f9fea6a1cb3d19b3681ca25e81cddce663108": "2db89c0b75f656af8304b9b922e81e4a",
".git/objects/05/a9058f513cce5faf1704e06e3c150688b0a01f": "e8d02f60cf87abd4c1de4b153dd696dc",
".git/objects/07/6ede118a487cebaf828d182c478392a14b8072": "a85336bb35423cc4ffcdb29abf09db8d",
".git/objects/0a/1aa74ef14d4a57524a71f42c6f27452623c518": "0d55cbf628bfcd495ba0ef6febe46556",
".git/objects/15/812f20cc32e81f7065d2b9f04c8062610835fa": "f66aee9b0c94eb91bc9a86748edb6a49",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/23/a9bee4ff4d1399ce24a2341609083e6d756d0e": "2fe6e2849b0c796830803cc65f19be60",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/objects/26/9d14e30d66d4cbbe237b69829344a424b458c2": "ac04d2a6ef5ac74c60b5a5cf70401c8c",
".git/objects/27/a297abdda86a3cbc2d04f0036af1e62ae008c7": "51d74211c02d96c368704b99da4022d5",
".git/objects/2b/1fd9d404cb222f7a8ccb1d29b08098b6ec899d": "b822c345f7c1e3338292133813287341",
".git/objects/33/0b78ee33ece1f7ba5751d8dca2b8bb32fa8300": "91e7fff304e83d6971405386cf869b0a",
".git/objects/43/1cded09503d5af90f7f05be47407673c48bcad": "14e6f61ff738e5f48bdd39361db9b87e",
".git/objects/43/31e47760ef77cfcf98b6cc55242f3c2e3a9de0": "d15b8ba7ace25c59f7af38b8a8acfe67",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/48/2dff25312ea44e5fe525642e22936a6a90d599": "18c7d441a730d705ff4f74b006632f09",
".git/objects/4a/a93f875a620a35aa66e40fa66d996339032ec1": "63196c010743c31ba0a2a77da8eaf77b",
".git/objects/4a/bb09cb4d5e6832e9da5488bef9a27e2d78ff6a": "9eff2dbdea23f0539f604fc69f672f6e",
".git/objects/4a/f73788773967bcff1d22a119e4dfe0e36ca6d9": "08193f724a80fce0f610428ed2b965b0",
".git/objects/4d/7c47566ce20a4ab06b187356834d747d7ac2e6": "4e487beac0a588eddeb758f07133bdc2",
".git/objects/51/1666556f8d0f5aeeef9cd29bec7484f1e9349d": "7d418eec7705d8027c1e7aa461458a80",
".git/objects/5e/5a6fe1f84ace7683d891271c45184a88a7d0f6": "0894ae640e5e4f82fa531646e5db4a96",
".git/objects/63/6931bcaa0ab4c3ff63c22d54be8c048340177b": "8cc9c6021cbd64a862e0e47758619fb7",
".git/objects/68/3735f84c81f2b9ebf1195d46e9c06d36cacdc5": "62b1b879ed202ce0336edfdb169a8cda",
".git/objects/69/76da9c67eb5317fdb048cca110659607ccba58": "adf3254fd329c8d7d0a7f864301b5ba0",
".git/objects/69/8d5cdf69c43d7cf94a161b005e6f2c4acf278c": "7811be539071c68aabf49977ad86d138",
".git/objects/69/fe9abba9d1df33fdc98363bbceb4cbfcd11550": "4cdb3b75346c473106978f8e23202f35",
".git/objects/6d/5f0fdc7ccbdf7d01fc607eb818f81a0165627e": "2b2403c52cb620129b4bbc62f12abd57",
".git/objects/6d/a2dacb653717166e6fb06c0234e9ef9312a601": "a772de0fd08a0473717953acf6f47a13",
".git/objects/6f/59594a7df605e1b51d055fb3f950fba5d269d1": "d1f6de1e9f65278fcad11d972c646b12",
".git/objects/72/25678864af44cb4be2bb1b77b367d61bbed227": "308f828e224e6a648b0b767a5ac295e7",
".git/objects/73/7f149c855c9ccd61a5e24ce64783eaf921c709": "1d813736c393435d016c1bfc46a6a3a6",
".git/objects/74/1133354ea9d3140d7405c5a4bc56da876f5efb": "b10163932f0ea0cd40985596bc3885ea",
".git/objects/7c/3b469cb0ce25632c554f487e9218a54283dec1": "13ee90f6eab75b1be429fef6189ca554",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/88/a464c26a6958771ba4810fa9e7e9a2d53de725": "6e4d4c9b4217acfb9aef3b50f4ab5cbc",
".git/objects/8c/59773bee8314a8ffb4431593d0fb49f52e34c6": "2eb993d30677573ffd0e58484cc6a514",
".git/objects/92/e304b7f1bf58ada9c57a6e1ffeb3f720ae8830": "eb8e4171a3c3f693d7218533cbf57481",
".git/objects/94/f491cbd750337b5b6d76643e7f24cc92343036": "efee26e43c68dbad054733fdc46e56e8",
".git/objects/97/8a4d89de1d1e20408919ec3f54f9bba275d66f": "dbaa9c6711faa6123b43ef2573bc1457",
".git/objects/98/1bf2ba9a8a27306fdff80b7b838bd1a7ded4bc": "e0d807a47b6feb9c5439e953256db850",
".git/objects/9a/7738a379b432da915540887f212483422377f5": "b3a1ea04b37fed77f3b48b1e9b0a7bd4",
".git/objects/9e/7a577cc8b61fa793eec339d4f1a4403aa6eac7": "3b00e8587fcc422b9ca83337704281a6",
".git/objects/a0/06dd8b7e8eb30b128a4789aa162c0474f9d098": "841a438b5907a97382c88ab49df243c4",
".git/objects/a8/3802ea6e460b75ba77338d3f88c583baadfd33": "ad818685172241a27909b66169f64968",
".git/objects/af/31ef4d98c006d9ada76f407195ad20570cc8e1": "a9d4d1360c77d67b4bb052383a3bdfd9",
".git/objects/b1/1bb542819d111f8b12108e856ba7c52ade105a": "04fc8916f5d65e5099cdcab1c9d18f0b",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b1/afd5429fbe3cc7a88b89f454006eb7b018849a": "e4c2e016668208ba57348269fcb46d7b",
".git/objects/b4/0dd2148ff7122746575688c6aec32a565736de": "e1bd87bb6d93988b140a08141284361a",
".git/objects/b4/323c5686d4bbe51a2ef93cbef4d5547a0b2c81": "c3b087b5d0edfefe5a443c0ad671138a",
".git/objects/b6/ac476614800ec76e45563b12a9e1c370e24e9a": "83c29cb01d009b7e1699779baa18dfc9",
".git/objects/b7/c7d6f2b82de83595d05b9b3d41ebd5ea672d15": "d75af9d256788636e54ffae6eb245c7c",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/ba/8dfdd603ece3ae94356a176fcc2c10fe10fb67": "0188472e9fa3f08b71679e21f83ac67e",
".git/objects/bd/fa2ae76ecd142d09ada406a906bf6240eb71d2": "2b525171716df74d8dcd8922628abe08",
".git/objects/bf/cd3540f88d261f61ef67617463cb8ea8fab0eb": "1cfae47a61cd050b0b8a1839ed81658c",
".git/objects/c1/450572b497b674f049d306e3a184b5b85786b9": "3a1070cf9af3b460535d1d69c28a5103",
".git/objects/c3/e81f822689e3b8c05262eec63e4769e0dea74c": "8c6432dca0ea3fdc0d215dcc05d00a66",
".git/objects/c4/759bbba039b30fa42f3bee3374fa1e0ec80765": "262a61f7ac2242ff3213f01dfdfe4dfc",
".git/objects/c6/06caa16378473a4bb9e8807b6f43e69acf30ad": "ed187e1b169337b5fbbce611844136c6",
".git/objects/ca/0a5e407ba804e8f83ce1a033996d01ce5ddab5": "e303ad04fd7d747e642144dc0463fb36",
".git/objects/ca/991f80416b4ed4a0147d49ad1f90d0752b1815": "7e6b0d27577797c7ec22d08cc4823d8c",
".git/objects/cb/e8e1e3e8fcbb0252e1033570edbbc5715fffff": "1554a0755b64219bd86440c2b5dbf99f",
".git/objects/cc/ba64133f57d3cdb417be0758cdf6145e71c54d": "c575c0f1f8a8e5b6ef443a1a22bc1df2",
".git/objects/d0/31fdbf1719533cfd2defb287cb24972062bb37": "e1d02f974a78c6bb843a904cde1089ea",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/c88b87f3eaf2e72d04a256c5bd87d0d5c6e3b9": "5290588a3624d665aa2a9b47fc007e6d",
".git/objects/d5/c9c6d19167dcb029b00edd8b9fc0c238d8e8a0": "3b85e389ebef23137eca77a7fb7bb7bd",
".git/objects/d5/e60a678e8058d343629f9fb2a1c91413c5c4a0": "a40d6fe57e5566051064697f877588b1",
".git/objects/db/05fe2dc7bb308a30bc752fe486f85f84e9f369": "923271a262ef16117935f0bf14b36fce",
".git/objects/de/83c09cf7264cac72e8dd9e0325d04f07c9839c": "7893d799a7e8f8234fbdb2b4f21ebd40",
".git/objects/ea/dc130a12f5cde0577b31d819957d1c1c0412a6": "a377e13ecfddb0f8c954cb3481d416fc",
".git/objects/eb/617ce48301f9e2ca1d608a40d567ba66b93756": "0c3b871e619069554b89c3cc786c07ad",
".git/objects/ec/361605e9e785c47c62dd46a67f9c352731226b": "d1eafaea77b21719d7c450bcf18236d6",
".git/objects/ed/ff9ad5ec62fe3b88cda7675b63c07d08d214de": "e45f9711e26e4d40a44cc5fb978ba684",
".git/objects/ee/809523deba546ca6f508e5cbabd18e8d15607c": "968ebfcb572f40c0859ea9d086719c04",
".git/objects/ef/16ecd665358879e878214bc32357f600cde10d": "82ead0c98b04163e838ef44e688199fd",
".git/objects/ef/3242b3b6a63786bfe82a2ec37b501dac364963": "0b319ae9fde211c8fe70249da06cc2d4",
".git/objects/f0/eccb3e985bceddcdae277cbe37793d5c2edc94": "e286bfbbf71875b3880e0e6039a8c46e",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/18203c12e803ca269f48ca99b57cd23e87fd3b": "11c89b83600c445a41c19956d7b201d2",
".git/objects/f4/6d5d808fb0c076544e25ba61fddf2dac5729e7": "a7e0069955421c2736637ec91374617a",
".git/objects/f7/8bfb58043ae90e4dbe2e0bf61deb9a44eae507": "6f576d47f5bf9b70792644af7806fa61",
".git/objects/f9/05e62c0c9ed774b698bcc6bbb8bd1cdeb8d293": "4599441c691061d7c1cc31770d86f73e",
".git/objects/fd/dc93bf7aa9d38cab33c710940086b01410a7b6": "5d9001df9da0ab59375f386ef7eef246",
".git/objects/pack/pack-3c934430be3908518dbcf37f55e16bffd7276478.idx": "96834d557e74b6d3ae58bbc78b02bc15",
".git/objects/pack/pack-3c934430be3908518dbcf37f55e16bffd7276478.pack": "eacd0c94fc34e6f30131325af8dc90cd",
".git/objects/pack/pack-3c934430be3908518dbcf37f55e16bffd7276478.rev": "a1d60909d147cbdaa5615f9d446aa74b",
".git/objects/pack/pack-cd53b9929d4acc98a09cce1d9a97aa9e2d7039ae.idx": "09054c3d94bc330818e5ad37b0ba90f4",
".git/objects/pack/pack-cd53b9929d4acc98a09cce1d9a97aa9e2d7039ae.pack": "3b2f5099a11b34ecf8b1b87adb6738fb",
".git/objects/pack/pack-cd53b9929d4acc98a09cce1d9a97aa9e2d7039ae.rev": "c37a16e3dfd1e057c452e9f01ff3dac1",
".git/ORIG_HEAD": "c0ed7643d097556c32744ff232c455fd",
".git/refs/heads/main": "d6c276be4e1c28fcba4d3afebd5ad3d7",
".git/refs/heads/master": "8584cffc691e0a6ae8bbb9dc2c108dcd",
".git/refs/remotes/origin/main": "d6c276be4e1c28fcba4d3afebd5ad3d7",
".git/refs/remotes/origin/master": "8584cffc691e0a6ae8bbb9dc2c108dcd",
".git/refs/remotes/origin/source": "a03b1cf7ccbd3b36db1e30f63e09e545",
".git/refs/remotes/origin/sourcecode": "aa206d79d20380391bb9c730b6e30382",
"assets/AssetManifest.bin": "d540803318e27559e1656d02442efe0a",
"assets/AssetManifest.bin.json": "983a8641bdaad5b50eb71829167c74be",
"assets/AssetManifest.json": "1a03ee5fd77c9120df909c7c92269065",
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
"flutter_bootstrap.js": "5a6d01eb0508a6f1c18c2f2ef698862b",
"icons/Icon-192.png": "0d71245a60630e34a7563e8480921be9",
"icons/Icon-512.png": "f2a30dcd922e61868e8b2ee0ea3748f1",
"icons/Icon-maskable-192.png": "0d71245a60630e34a7563e8480921be9",
"icons/Icon-maskable-512.png": "f2a30dcd922e61868e8b2ee0ea3748f1",
"icons/main.png": "a8e18e707e65adaded2b27dc1aff909d",
"images/e1.png": "cad14ee8f385c6eab07e4b438788f9cb",
"index.html": "7f7291176206730c9ae260e9b480a4ff",
"/": "7f7291176206730c9ae260e9b480a4ff",
"main.dart.js": "939bf1ac2b2fc001e8937ba25c5907e1",
"manifest.json": "56781a6656016ff9f66f113529ea23f2",
"README.md": "2d88b8413fa5695bc939ece76dd6e470",
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
