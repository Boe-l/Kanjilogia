'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "01eb2c11c2685e04a0e3b0556549b914",
".git/config": "77648d8c815437241a515014d39f46ad",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "a9aba3ff78a71ace75836f4a62c5f7da",
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
".git/index": "93a7a80fcc4c2e535ba3a08aa8d79e02",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "13256f399caf1e899f3006c4665525ab",
".git/logs/refs/heads/main": "1ec99c8ce354e3c48d209aeaae5626cd",
".git/logs/refs/heads/master": "311d88e6de6d02baafe5f9eeea10ea94",
".git/logs/refs/remotes/origin/main": "0e34104ca279cecba514aedfb681e758",
".git/logs/refs/remotes/origin/source": "1fb5d9c44b83502f2c7062d07cff52c3",
".git/objects/00/071ace796fe8e6a8615378d9aca8716554deb0": "f2bbed24c8bf95fd01e7344d9636b1a4",
".git/objects/03/46314d7641b6172a563b850fd5f7f3f43a2e58": "7dc4b99ae9465629c04d58978086a3cf",
".git/objects/05/5971034723f9904f2db032ba4ae8c4c17e4769": "d879e0a4634f0340da6d50af738ee4f0",
".git/objects/06/8001edc8d59002e041678f7450b15e58fd42cf": "20259b32af87f563f5351fff0014a02b",
".git/objects/09/c5fb30187cf5c372fb7172687f9a5efc6d2791": "82edcce4505a5cb826bd84ac4d3cb93a",
".git/objects/0a/ed02b5d3d694f10d2a5035ea60e037a7759738": "f8bfbb218bbd3e148d7c19d59307540c",
".git/objects/0d/9997aaf1de3548cf28f1fe172bbcaf4c6f5adc": "6fc10ffc1d93bb8aae80e2e42c55ee6f",
".git/objects/0f/ec5acbe420f5e6e20b11cbbdea1f9884b4ed98": "a8f5b6d2329f87dd7c4484eceb25c17f",
".git/objects/12/e3ec514bd302d2b317e74e6c0a20f1d422b278": "3e336d3bcdfbcd4b04f868586793803a",
".git/objects/16/710512b814ca5ad59a08b2927403f02a89a680": "a24ad8ac5f24076dc3c9d8c911485ca4",
".git/objects/16/90a717785c713baf45a0ca70b3a21295c7f96a": "8f0933e9bac7917d686102cb1d0dc88c",
".git/objects/16/f3de0660ec9f75a131c7483e3b05f7085e0190": "94130d798d871e38faaea102c4398492",
".git/objects/17/9e4954a8db8a4f8c38647bc94d3ab46d2b1a9c": "6071ca4b896499c1e1c4b6fe92e1116b",
".git/objects/19/2c10477e1bd7ff6ae24c22121093d3f125c475": "65472ee059df169bdc78b478f2732e1a",
".git/objects/19/3b019545f196f657dc5eaca3897107332ec253": "3688a9119f6397c5a47fd7a21848d199",
".git/objects/1b/7c04b0a8b9d110ce396c1f1f83e8d40c29a6c7": "2b76285040a8e2170579edde25024f7e",
".git/objects/1c/bc638e05934ee6edc8378105b8343a78c69118": "e32fc8356becdac097360404c4bb3e4c",
".git/objects/1d/15aa8496f403b2d75d1ae93b284ff43adcb5da": "dd11c02a041619f7a1f49c711bfc8e7a",
".git/objects/1d/f5ce64e4fc99c3c8abb82e4dda37b8cb2ba554": "cba95c70104db9aad95a68c522f7b091",
".git/objects/1e/b46d0c656eaa614614ed7f09e72700fe563cd8": "79c07f098ec819a48c024802d9e358c1",
".git/objects/1f/2e8512a0852605496fcb771474a72e2a0f428c": "5d94d9c1744fdafa8f38d6c99b91d0b0",
".git/objects/22/45b8b0e6597d07272d7d84cf4fdbfae0ceed68": "9f7c883def71b621859bfb1363cfb42c",
".git/objects/23/222c94413e63e36a5fb827700cc05e068024bf": "ec8276a5a0493c927f8751f368e82b36",
".git/objects/23/a9bee4ff4d1399ce24a2341609083e6d756d0e": "2fe6e2849b0c796830803cc65f19be60",
".git/objects/25/39846586354a0b8308f1741f66be5ca17de46b": "ac00f09bb0ad102c18d029d1cc6811d9",
".git/objects/27/a297abdda86a3cbc2d04f0036af1e62ae008c7": "51d74211c02d96c368704b99da4022d5",
".git/objects/29/7e2abb7b963f2dec3a9d9cad2eb93ec8f5fd24": "c49a7552e9919ce71db3f9a173e3dcd8",
".git/objects/2a/2ff189703314a315c33b41d1515bdfcc116c33": "a1c1f72ea615db2f4eefeae4a5ddd34b",
".git/objects/2a/d20ac080b2676d0b610809e5a5b972694f37ae": "3b3f6b7bb086eb31afadf2225514d998",
".git/objects/2b/021622e7d190329abf0465b69134729c089ab9": "b0612c5fcdee7166357f136597e7db23",
".git/objects/2b/ca55477573b71f21bd5b8fa2b720d87626ed77": "ea752ea489f17486a492cbf10c23e22e",
".git/objects/30/24a92d1659e392c833693bce10366bfef66043": "4b8f88399b020a60aaec8a67c5075cbd",
".git/objects/30/6cdc0b70c478ac9f21d7a104758110f3b39f29": "29c4636890d1c3f40b062770cf788e2b",
".git/objects/32/0f8c8cf2ddae18e87a21c7b76f2628f2f14dac": "4fb70fc2435a9b5f4dec4ab60383ffb6",
".git/objects/32/2af168a3550f1623b1413d348cd8fd7452538c": "cd35b8dc6e1befec4d2dfda097eb6d68",
".git/objects/34/03683b2a2e4442f0e8ec0e6a7abb8425e24223": "dbb2c190011a939d785335bd1be9a8ed",
".git/objects/34/7371461a2f65af7ed9e1238d924a655ff3441c": "3fb0804742021e65a50bfad2c55def1a",
".git/objects/36/f0798047961c277c1ee30b77d6c9ad00a551ee": "1b8f5b5ed90562455c6a4e7b070bae38",
".git/objects/37/85ffd4ad2f4127b7e194baf93de51e5ae321c7": "adb333e65ca0583549879a38808faa99",
".git/objects/3a/c5df7b1bf92d8d0320494e9e07edc8ea0748cd": "c61f4a5f627b04257b9b2b9c4577d445",
".git/objects/3c/1736c61cfc80f7e4952dc6560baffb13012388": "729c58ce1dd404afc11acda45d274337",
".git/objects/3f/9b650b7638400021ef403bfdbbf7eead6fbb78": "86f31de1348dfc7eeb0ecc1d4df15dc1",
".git/objects/3f/a2cb832c4c0825687bfbe6c48719911a26553a": "4f6292560c41b153bbd792080d1fc07d",
".git/objects/44/a6e09e2ba97089170f7e3246c8cbd47db1a387": "ce8cf603693ba0140709204fa600bf79",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/46/f32d8493821fc72ae8db42142c254d1615cde0": "6b72a482eecf972698e673a124c04f3b",
".git/objects/4a/b2c71f7db76a12d7554e96d598a1f1db6a6633": "73d4b84cca9e2fc059c58720abeb618b",
".git/objects/4a/fb9e99cf12e36b8484497e15f7f3c6c085ec06": "6864ffadd7935ba2642c236528a27652",
".git/objects/4b/b06bec0d5f11f6fc6a10bc8d48288b309b680f": "bc8a9ee037fbf2033bb7dc673b434227",
".git/objects/4b/db26e1daf595de440d2e15a6efe89c91f91f26": "b939df7367e32c3155d95338bb996d22",
".git/objects/4f/c090d8779a2cdb511d3ca8a0cebf00e16d7789": "b15c33d7380a756b6ed59e6febe727b5",
".git/objects/50/e5a0cfec083b6b06ed4582376cc1cc59ba235f": "ea1450679133d1faf84b0858ff1120b5",
".git/objects/53/50d718b16d865d4e163d446b1aaa5eef86f165": "1efcba6b47b17e2732efaeaf35e9ce36",
".git/objects/53/8c49014564f7c056f113e61980c332f98ca448": "773c6263e4829c739987e6d44997200e",
".git/objects/53/bfcd7d383347b4fa99abff8c32a0f54261acb2": "20e52a055eaec65d9a5befb209264c83",
".git/objects/54/53b89fe99b21573267fd9c671c178b778820c7": "29c174decc5597f93c4e3c2c05154db2",
".git/objects/56/dfc3f3be924871f2647d665c2608818c9efee9": "f4a74044fe0daee0ac4cf1beb86a5d5b",
".git/objects/57/4b3f49b296eab74149be09af0fc780d220b7bb": "5e30570e07a90db97f9d73cedf87be2c",
".git/objects/57/a66bfac1e7cfa0142f0ba625190d6a2b59de6f": "70b9db665843c1b636330b33a5f20888",
".git/objects/57/d8049db906285767cd6176b40e560b40de0a75": "73518f899b18c754924c7b74dfc5c320",
".git/objects/58/b767f55b812c6e0fddb503f37789e6eda5fc91": "fd7a6f86f9673d858b3f1d61a49b0038",
".git/objects/5b/4e2ecfd63c2791bf02e96c40eda668c686de70": "5f65ff358480d0a4ae604a2b19b06422",
".git/objects/5d/9e7e5513bfc936bd6230517c051497f20b278f": "19285ebe021c459df1f5f67d94769473",
".git/objects/5e/5a6fe1f84ace7683d891271c45184a88a7d0f6": "0894ae640e5e4f82fa531646e5db4a96",
".git/objects/5f/155308b936064e9271fc6af23fd190d52f3636": "41654021e206c79c8496e2883ecef05b",
".git/objects/62/935b0ed773ecb9ecd49ff943c5ebb120bc9319": "b2b4fdaaf25950ffb07ec33cc8f72aa0",
".git/objects/63/5e509341c817f906249df24b72ee2fb8809193": "1db4f87b4081be7dcbd4202672d31f50",
".git/objects/63/6931bcaa0ab4c3ff63c22d54be8c048340177b": "8cc9c6021cbd64a862e0e47758619fb7",
".git/objects/66/2db8675e0deecf3b1c73daf5cb12eb57282a28": "7427564bc41f9fa6130fd5aafd8f70bf",
".git/objects/66/f93ae2a443f5544afda5992afd63f89cdacd03": "c8a5b317d3f4447568571f1c799bf077",
".git/objects/68/83737caee0f2821e719d7458aaae9039d35363": "ac2f156ed490f9ca9f9d15655f8e2582",
".git/objects/69/8d5cdf69c43d7cf94a161b005e6f2c4acf278c": "7811be539071c68aabf49977ad86d138",
".git/objects/69/e60b534cb93ebc593e88c7cdaaa7efc31abf65": "f6c857c2755aaa1d2e349d441bf87113",
".git/objects/6c/d2a724038daf34b6ce9e34f7d2ad83d7ae272f": "898c2e3864cbe9493c645ba3518bf442",
".git/objects/6d/040cac4880b9b784f34ef120e16c7098685e54": "c4822451e1ce01ac1d481e9c51ffae16",
".git/objects/6d/27cf80dfb44da7ff3aef9607236d4415eb2946": "9fd19d0575cade752327018d6a41b708",
".git/objects/6d/5f0fdc7ccbdf7d01fc607eb818f81a0165627e": "2b2403c52cb620129b4bbc62f12abd57",
".git/objects/6e/4d77427dc5bb18169101e885b4c26952a02652": "a39d2037e3812d71a94292a69e3bc30d",
".git/objects/70/693d264d575595c64b99bcf23e185e8402b7b0": "79609b917c4b16d1da102bb126f8e768",
".git/objects/70/7eb668b976cda29fd9fd8eaf0c573c55f39113": "b550148349128805de74f8bb7c5f3940",
".git/objects/70/df0e1de12966f65d3a2e6e7947d7fb57b654d1": "4998bd4feec3a2a5be8c00905a202250",
".git/objects/72/dd8531fe55c019c43a795d6a71a7584cbcfca0": "996c3efaf25ef9cf5281b462550ba5d5",
".git/objects/72/df95dd89849af7c25c0b38ff61ac8b465095a7": "31ddabbf19facd9c559c6997a62f4a41",
".git/objects/73/7f149c855c9ccd61a5e24ce64783eaf921c709": "1d813736c393435d016c1bfc46a6a3a6",
".git/objects/73/f0dcd3e1c8af596ef718b170a0aa1e7cee798b": "f0c2ee25fbc5a0b020af1fa27e95c321",
".git/objects/76/237378261f51bbc00345df3495f2b938bbf398": "e80aa2de29acac60f6b64c8d3b5ceb29",
".git/objects/78/4aa420675b04c085734080e7583cd6179db7ce": "0595b1c95ffb88273e47537764bd69c6",
".git/objects/7a/ba1775b7a845f2447e52f820948c4343fb2e07": "38cc773814eaf2d63796e35a91c977ac",
".git/objects/7b/cc03bf8b56bdf292c12baf2c738cae78bc033b": "3bb1b40492039d631ad650d8737b93fe",
".git/objects/7d/d0c87cb4d9913b0a09123518a01d56b5f26e7a": "ca6c658d7881c83798e9a07dd13270a7",
".git/objects/80/e25fbcba53bc59051bb909bc85af34e3577b40": "59570356316612f43a86ee73a301f82c",
".git/objects/82/b542b201bf689dacf8411bcea5283a1b65f9f4": "f4327fa8595e0c98a6468f65c42b74d0",
".git/objects/84/2505fab4a8ff51365f2e19dbd063556cebcb62": "85935d2f6bd517676b25175b6d6bc84d",
".git/objects/85/73cf198ffad59d2e223532b07b37a3204518be": "3c279513da3361ce4484ad6e1f221f85",
".git/objects/85/7472e08d35f8040a6b90ab9279815ca1ad33a3": "3cc404789913e8738affcb3e3099bccd",
".git/objects/87/07767c69cd5b2d9ffc5d8fdeabe3ae023c129c": "48d1616e7f02e5b6805fda76fef4a445",
".git/objects/88/ebe6d5247ad96cda0f9cadbd383cf3ceee7276": "595a3c3613b17144759e0a08b8317f5c",
".git/objects/89/f12157df990a63484b3c968e8dc77c251ed4e7": "8c9467a9c3abd8d23a8ac6032cfe31f1",
".git/objects/8b/56b7f51e3a5a1559eee23dcb0576c71d998024": "4d4e80a9d0c82072f77718dbe13bb560",
".git/objects/8d/b95ac3572b13c7a6464e8593f243e78ba22bec": "36b193aad05ec2b3ec24a18ec238e915",
".git/objects/90/6652f5118555c869947ca69a72bf5402852c3d": "c768568bd74a0bf0ee67235b994e406d",
".git/objects/90/adb36ec1471c4cb52c92fc6e50d440d9a890eb": "01401bee1785b67a4ee16c52ab1d25da",
".git/objects/91/7cf67a233448473f31ba4f441a823d8640d2e0": "754668bbdd7713034a0cea18037a201e",
".git/objects/92/2d974a09e1a897e47f863a0ce089778f043a6b": "0774a7695aabe6c4b735902b48ea970e",
".git/objects/92/e304b7f1bf58ada9c57a6e1ffeb3f720ae8830": "eb8e4171a3c3f693d7218533cbf57481",
".git/objects/93/2309bcf8cf5ccabe3888a83d957c20a126717c": "78791a874b39e603c5033a099dbca8ab",
".git/objects/94/3f9c7ce3da648118369d70a23048fe4f68182a": "fac84124f33a05fdd8a4ba62d365af8e",
".git/objects/94/d3005be3f8112547191bbfd1a1c23037b75c05": "0b8202b13819edec3c0191cf2f5ac37d",
".git/objects/95/bc84e377db821715cf5217dba63a16ebb6ec7e": "c50738b6ef7352ef7fee3a37ea776ed6",
".git/objects/97/77c0577d9f000cdd51120efe9974a268b18a6b": "5840c5c10ee7321dc321e761cc5f938c",
".git/objects/97/8a4d89de1d1e20408919ec3f54f9bba275d66f": "dbaa9c6711faa6123b43ef2573bc1457",
".git/objects/9b/3860431d6e3d58c52993c94a93d7c37b06ff97": "1482df4018d78023e3ffdf626983da41",
".git/objects/9c/2c144134da3fd401597440a7e002878fc5951c": "801c60d931c67392bfb3cb92fcb90f4b",
".git/objects/9d/97f263ae17697cfd392ef73374bfe723320616": "703418aa9088bab3307eae3ee594604f",
".git/objects/9d/e2bae9ebe9812b8d2633aeccfa6dcc7e3bc5e1": "83be2b4377d641881567bde4dc0b530a",
".git/objects/9e/177798781527d3e813269ace11944617ab427f": "822ffd010b8266ac26646c0e63cc7008",
".git/objects/a2/58da5d20be81200fecfab1c01e7d30c5407c41": "d54c0d68f90d8196197116981371028d",
".git/objects/a3/a109f41f98b04ae422b3646955315c5f0cdf2e": "d7c4026a9ae5d73c4c44f2750396c011",
".git/objects/a5/d41587adc4e3a13e9a2311317e6bf9df22b738": "3e6a1123c07e7e90e09355351bb1df6e",
".git/objects/a6/245736cbf6d1903a4c30fc74ac6cdcb2f453f0": "20cca73814f1eebc8f1c708105a70457",
".git/objects/a6/2d095bc704cc137781ad648a1465ce52468afe": "ecbe3f7481d0674210a14c5311bc0989",
".git/objects/a6/51a531c8146109ffc563e1e830edc55e83d758": "1c0e2da5436a2a898cee0f4958a89ab9",
".git/objects/a6/67798bece58de26521d13b2cf334868ab8752d": "92b760cf30689c598aa3f5b95c7ad522",
".git/objects/a7/c1d59118016d84fe5ada8c7c2c8ef07649b5ed": "684f5e493adaff04a424c771dfc92df9",
".git/objects/a9/23430cb64788bdf6be7c455f92ea466bfa44c1": "70ad0d67860ecb0e37dfabed5d15ea4c",
".git/objects/a9/74d9230892d69790d65379ff8223fff3225378": "e0d4a6889ab3985d248a5cac4825f9cf",
".git/objects/aa/8214836634981654ca289d0b45dc00a832c2dc": "96ddba8c67fab1613faad95b16804665",
".git/objects/ad/1fa6c8e95c52e6c5d718d43e9005b66b22478a": "af38a86843465852f407d96c765bbc36",
".git/objects/af/31ef4d98c006d9ada76f407195ad20570cc8e1": "a9d4d1360c77d67b4bb052383a3bdfd9",
".git/objects/b0/b7bd3eef22a5ee6ac3bfe785fd60104960022a": "a82cbe4a723005140d4bb415424bf7cc",
".git/objects/b0/f4f60b31bc13dde95effd05efc2eba9e7c3ac3": "0d3d8c449c43e2f2eceb747a6e79d3c1",
".git/objects/b1/1bb542819d111f8b12108e856ba7c52ade105a": "04fc8916f5d65e5099cdcab1c9d18f0b",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b1/824552fd182c0aa53fbd2b293ef3d906f259df": "c86e9c4b4e485a60c6d2b1ba47a9cd1e",
".git/objects/b1/90e6187ee2ec7eb43a942037b25d985db1f4a9": "06f5ce74240ce912a39a777b81ea90ef",
".git/objects/b1/afd5429fbe3cc7a88b89f454006eb7b018849a": "e4c2e016668208ba57348269fcb46d7b",
".git/objects/b2/e80f281ea4523fee9feae081309c35ef9db4f7": "fa7e03751f3119843a4a91af19ff3ecf",
".git/objects/b4/0dd2148ff7122746575688c6aec32a565736de": "e1bd87bb6d93988b140a08141284361a",
".git/objects/b4/edd1c45fd539ba74f7579736a89fc952517a1c": "d5d6cc3dc43cfed035cf7a1fc3ffdbee",
".git/objects/b5/bec63c761fbd44dd28d17899b669c6ac883113": "2da7da5930cbf17fed40b67b6f499fbe",
".git/objects/b6/ac476614800ec76e45563b12a9e1c370e24e9a": "83c29cb01d009b7e1699779baa18dfc9",
".git/objects/b9/3a2b1c4535717ecc12b5c683868512f607669c": "b31b3a352dc9184f8f3f5025315728fa",
".git/objects/b9/ba4d358aa9b5e14e8461b4c6df58042f2f8b4d": "8934985e197d68b62d56a1e98ededb8d",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/bb/8fd326f3ebf6560961c7a434154deeaf89d6e4": "d5d02f37e82c7a47ad5a012b51c908b0",
".git/objects/bb/a91d34b911fcbba3467b789639bae87f31428e": "c9923e7ad11c85e1b4261b6e8f460537",
".git/objects/bb/f77e8a8174a211e2ae2ad21a8ba6a9d996ed12": "6e7a18dbade1be8d4008c0e1db8568a3",
".git/objects/bc/457a9f9c645f2e06b146dfb54be7db609eabcf": "01c60ec21109098bff1fca1566279799",
".git/objects/be/14f5d6bba552befdf0c91e738ce6d39e4ae4f6": "47395ff50bedb6a4fd69d7cd1ffa63fa",
".git/objects/bf/85b46d788cf9f4cae136a156ef8865b2c8e528": "03789ec0b83db5ff75bc78b652b32ebb",
".git/objects/c3/e81f822689e3b8c05262eec63e4769e0dea74c": "8c6432dca0ea3fdc0d215dcc05d00a66",
".git/objects/c4/b1d3a51f3f1899da91950b7b40c86f2422c8aa": "f79781e503fab8e78ecf569d28769674",
".git/objects/c5/37046b4da7b4f976846f2374830dd7fcb81518": "41951a9073ab24b1a3b57328f56bb79a",
".git/objects/c5/41c2783fd13fdd4a25c9ff351dfe3ca0d473f7": "6bcaecc4d2274637c9123df4f63fa311",
".git/objects/c6/06caa16378473a4bb9e8807b6f43e69acf30ad": "ed187e1b169337b5fbbce611844136c6",
".git/objects/c8/4bce4e1d662e20295aac802818086fdfd76834": "cf12d2f2b570e5a2ca31c8f1c3db9bed",
".git/objects/c8/9889e1c138da93f358176e2c711d08f4c5e910": "c96d779f2497d7ebd08a17826b568ff7",
".git/objects/ca/bf8ab29d548721853c7c1d280ed7ac31d0640d": "0beacf46a8fb4baaaf7b91a99737179f",
".git/objects/cb/8e1f0a2edf596ca2825919043f98b1bbbe2f3c": "b48baae3d0f0ee68ddb34446a1fbafea",
".git/objects/ce/fd97d233cab5c9760f9f94767d9ae6a74a56bb": "4fc7c145082e82f481baf70c24c141f7",
".git/objects/d1/4e1d4301f177517724ccf7f43aedcc84930dde": "9fec3cfa2013c9482a7ae80c0081662f",
".git/objects/d2/f5cbce09cf8b439cf0b834b1d5e21edd136557": "e57fb85283b1e9eaf3136a5c81f9043e",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/c7cd182b674258cc9bbd808c13368f803aaa31": "1adff5aed1f5778c0b833bb439495d6b",
".git/objects/d6/781e60d0fdbeade67ee20838b078d9f7df9ffe": "710beb67efc1ba3cd1ba7097c029c083",
".git/objects/d7/469656f18ab014a6a6fcef53fe67fca6e1b7b5": "588f84573d57ef5ee32a650019611204",
".git/objects/d7/8cb96c2bc779b8c55a5ccb1fdaeef2798bc805": "8d5dfe91240f453c1933cda615addf70",
".git/objects/da/48d49c6afabecef9f93327bcd358666860e6e8": "53171cdbe7106fbc04663a8b2b3c78b6",
".git/objects/db/ab1be5913168d49c8e6102b80b0dcdee3f8305": "da814018e3fb6d257b61e936c5fb25eb",
".git/objects/dc/eeb3f72d824ccc3bd37b122e268dcecb75c5ff": "08d7eddc9daf4303142dc92f1d77fb53",
".git/objects/dd/8916f0dcc6aeab79d4e3970fd67783b18adbb2": "da7f18d781c185203ad1c29c2bb5d189",
".git/objects/df/d755e5e3d89f69a452ca919ff06803f4a0a682": "3e1aa643d7c1247a4778c8bd37c25911",
".git/objects/e0/c3df1de50b68469d7102bd8320f1f271fc3d9d": "299322663e0a5ff7c2ad1732f1c41961",
".git/objects/e2/f70f520cc1c704c0fd35e047bbe8d343071649": "b1e12ec290f2baaac67896b960b94244",
".git/objects/e3/a104fb5a28bce28fceffa35efdd96c402ed76f": "8912f8a382223c9396325f5f1ae20282",
".git/objects/e3/f72d4d8ec1b944ef94be06ec6c7c80c7b416b9": "09d4136d7042558320f1cf06390585e3",
".git/objects/e7/5dbdccc27704ca7cfd9cfbc31b3a4d4d6f3393": "c33e2ae3565187d25cb76bc61cba2c6b",
".git/objects/ec/22d46614239a5716d8fe82c7ccd9331343634d": "2e34c29cb63ec440bfbd96a07a0625aa",
".git/objects/ec/361605e9e785c47c62dd46a67f9c352731226b": "d1eafaea77b21719d7c450bcf18236d6",
".git/objects/ee/809523deba546ca6f508e5cbabd18e8d15607c": "968ebfcb572f40c0859ea9d086719c04",
".git/objects/ef/3242b3b6a63786bfe82a2ec37b501dac364963": "0b319ae9fde211c8fe70249da06cc2d4",
".git/objects/f0/9b8f9e2a682df25db89c831d6b3b1797f0ac62": "4ebefd1f07d4a43810e203a0ee62d63a",
".git/objects/f5/619e7266e0c4eaa3ae459dc2066c0f57388f86": "4fdd5619075b6123f8ed4bd64f45d289",
".git/objects/f8/14848e63df08b44f1da0f5336d306b591d956a": "4dab70212b0bee845c979260b2c49de8",
".git/objects/f8/96ed43d873a6c7ba80c1b76af6f7a6323590b8": "b2b193e7d7dda79d974eb35bc9b89b05",
".git/objects/f9/e08ec256017ed1ecbafd2374d6c90c1b2fc46a": "4657d6c96d1df1059408f41eea163f24",
".git/objects/fb/575b7884bc9b1c6e5880af9281c1284f5ae575": "2df3a6a40a9f996002724540dbc2f96d",
".git/objects/fc/757921f7f158bb6c18c8edebafc4e3aa265933": "3ce82ac6525df2e5032326b7528e9b0b",
".git/objects/fc/d248312a4244bd919627be3af68d0af97660da": "ff14afbc83825cc95ffd706daebdc984",
".git/objects/fd/d05252f668fc0d7f97ab42cc67a159a311d197": "6efc1d4cef4278d87b2bf2f0c6accc7c",
".git/objects/pack/pack-bc8ee70810144f458ae7af72abbee2ebc886aaef.idx": "42f789027ed3fd7196529d4970943af7",
".git/objects/pack/pack-bc8ee70810144f458ae7af72abbee2ebc886aaef.pack": "30046633402ea6e963601516546be98e",
".git/objects/pack/pack-bc8ee70810144f458ae7af72abbee2ebc886aaef.rev": "78cd7bbf913367f3eeb60346816f070d",
".git/ORIG_HEAD": "4e0918bc2bee5c43ada50fe0cac29310",
".git/refs/heads/main": "a49abc22668692a791f12f3261ad2e4c",
".git/refs/heads/master": "93630cc58e6e90d48009bf8ad62978ff",
".git/refs/remotes/origin/main": "a49abc22668692a791f12f3261ad2e4c",
".git/refs/remotes/origin/source": "ed1ee17659f6ceee12431585332d5de1",
"assets/AssetManifest.bin": "863d01ad0bb33f6d4427f9fd6a8a6826",
"assets/AssetManifest.bin.json": "be7172bfa58d6975dfb570d6427567f1",
"assets/AssetManifest.json": "5a0ec84193113a3d13a8747e75b8091b",
"assets/assets/flags/brazil.png": "bb0e4c272d25b2074e9531812660ae18",
"assets/assets/flags/china.png": "8097f5abbe93eb8f353e893b77fa58be",
"assets/assets/flags/default.png": "06bbaf25add8a02b0d3b213977f3a8bb",
"assets/assets/flags/japan.png": "a2542be9b1833ebbdf4c906e79969457",
"assets/assets/flags/southkorea.png": "e82f432f44c8c56d88321440414a0930",
"assets/assets/flags/spain.png": "74189fa01ec866d612de8acf53c305e3",
"assets/assets/flags/usa.png": "bff9fa1e3c746ba0b61821903c8f3b22",
"assets/assets/json/Chin%25C3%25AAs.json": "8ee4b8f520601a1c29c782e796561b31",
"assets/assets/json/Cores.json": "01db4450337db4c94f804488da7ad566",
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
"favicon.ico": "9a953bd1e19e5a6d8480c59812168360",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "e4793e82d1c771e8cd5cc1f4323532c2",
"icons/apple-touch-icon.png": "df1582fd4b85d81bb76cc3bd2acfd066",
"icons/icon-192.png": "d9c3d6923263404d9e326f0ffe0a874a",
"icons/icon-512.png": "4900ac314b8149271884b48394d1a7de",
"icons/Icon-maskable-192.png": "7e7f9284ba8b64443efe34a9cfb7c1ca",
"icons/Icon-maskable-512.png": "7e050d7d730a5b76fdcbd113dba4b348",
"icons/main.png": "d9c3d6923263404d9e326f0ffe0a874a",
"images/e1.png": "cad14ee8f385c6eab07e4b438788f9cb",
"index.html": "b729186a020fabde7f322a5ac1745698",
"/": "b729186a020fabde7f322a5ac1745698",
"main.dart.js": "7d956ebd5a55e9979077fcde13bcab79",
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
