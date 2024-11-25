// import 'package:curve_vpn/api/api.dart';
import 'package:curve_vpn/assistant/assistant.dart';
import 'package:flutter/material.dart';
import 'package:curve_vpn/constants/constant.dart';
import 'package:get/get.dart';
import 'package:flag/flag.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//ignore: must_be_immutable
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RxBool isLoading = false.obs;
  var v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());
  late final FlutterV2ray flutterV2ray =
      FlutterV2ray(onStatusChanged: (V2RayStatus status) {
    v2rayStatus.value = status;
  });

  @override
  void initState() {
    super.initState();
    flutterV2ray.initializeV2Ray();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: '',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd rewardAd) {
          isLoading.value = false;
          debugPrint("loaded ad unitID: ${rewardAd.responseInfo!.responseId}");
          rewardAd.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              debugPrint(
                  'User earned a reward of ${reward.amount} ${reward.type}');
            },
          );
          rewardAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (AdWithoutView ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent:
                (AdWithoutView ad, AdError error) {
              debugPrint('Failed to show rewarded ad: $error');
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          isLoading.value = false;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void connect() async {
    final bool requestPerm = await flutterV2ray.requestPermission();
    if (!requestPerm) {
      Get.snackbar(
        "Permission Denied!",
        "${Constant.appName} requires vpn permission to establish a VPN connection",
        snackPosition: SnackPosition.TOP,
        colorText: Constant.appTextColor,
      );
      return;
    }

    flutterV2ray.startV2Ray(
        remark: Constant.appName,
        config: FlutterV2ray.parseFromURL(
                "vless://5e0cebed-d1d1-4438-8873-db7ba0c98892@194.5.178.153:443?security=none&encryption=none&headerType=none&type=tcp#%40v2city")
            .getFullConfiguration());
  }

  void disconnect() async {
    await flutterV2ray.stopV2Ray();
  }

  bool isConnected() {
    return v2rayStatus.value.state == "CONNECTED";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(Constant.appBackgroundColor),
      appBar: AppBar(
        backgroundColor: const Color(Constant.appBackgroundColor),
        title: const Text(
          Constant.appName,
          style: TextStyle(
            color: Color(Constant.appTitleColor),
            letterSpacing: 3,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                  valueListenable: v2rayStatus,
                  builder: (context, value, child) {
                    return InkResponse(
                      onTap: () {
                        isLoading.value = false;
                        _loadRewardedAd();

                        if (isConnected()) {
                          disconnect();
                        } else {
                          connect();
                        }
                      },
                      child: Container(
                        width: Get.size.width * 0.5,
                        height: Get.size.width * 0.5,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isConnected()
                                ? Colors.green
                                : const Color(Constant.appTitleSecondColor),
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          boxShadow: isConnected()
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.8),
                                    spreadRadius: 100,
                                    blurRadius: 100,
                                  ),
                                ]
                              : null,
                          color: const Color(Constant.appBackgroundColor),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(-1.0, -1.0, 1.0),
                            child: Icon(
                              Icons.flash_on,
                              size: Get.size.width * 0.4,
                              color: isConnected()
                                  ? const Color(Constant.appConnectColor)
                                  : const Color(Constant.appTitleSecondColor),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: v2rayStatus,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward,
                              color: Color(Constant.appTitleColor),
                              size: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "DOWN: ${formatBytes(value.download)}",
                              style: TextStyle(
                                  color: Constant.appTextColor, fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward,
                              color: Color(Constant.appTitleColor),
                              size: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "UP: ${formatBytes(value.upload)}",
                              style: TextStyle(
                                  color: Constant.appTextColor, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: Get.size.height * 0.3,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              color: Color(Constant.appBackgroundColor),
                            ),
                            child: const SingleChildScrollView(
                              child: Column(
                                children: [
                                  NewServer(
                                    countryName: "Germany",
                                    icon: Icons.ac_unit_outlined,
                                    countryCode: "de",
                                  ),
                                  NewServer(
                                    countryName: "Finland",
                                    icon: Icons.add_a_photo_rounded,
                                    countryCode: "fi",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        isScrollControlled: true);
                  },
                  child: Container(
                    width: Get.size.width * 0.7,
                    height: Get.size.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(Constant.appTitleColor),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Flag.fromString(
                              "de",
                              height: Get.size.height * 0.03,
                              width: Get.size.width * 0.09,
                              fit: BoxFit.cover,
                              borderRadius: 3,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Germany",
                              style: TextStyle(
                                  color: Constant.appTextColor, fontSize: 20),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.unfold_more_outlined,
                          color: Color(Constant.appTitleColor),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Obx(
            () {
              return Visibility(
                visible: isLoading.value,
                child: const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Color(Constant.appTitleColor),
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class NewServer extends StatelessWidget {
  final String countryName;
  final String countryCode;
  final IconData icon;
  const NewServer({
    super.key,
    required this.countryName,
    required this.icon,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: const Icon(
        Icons.network_wifi_outlined,
        color: Colors.greenAccent,
      ),
      leading: Flag.fromString(
        countryCode,
        height: Get.size.height * 0.03,
        width: Get.size.width * 0.09,
        fit: BoxFit.cover,
        borderRadius: 3,
      ),
      textColor: Constant.appTextColor,
      title: Text(
        countryName,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
