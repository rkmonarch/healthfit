import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:health/health.dart';
import 'package:interview/resources/custom_icons.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_NOT_ADDED,
  STEPS_READY,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  List<HealthDataPoint> healthDataList = [];
  String caloriesburned = "0";
  HealthDataPoint? p;

  Future fetchData() async {
    AppState _state = AppState.DATA_NOT_FETCHED;
    int _nofSteps = 10;
    double _mgdl = 10.0;

    HealthFactory health = HealthFactory();
    setState(() => _state = AppState.FETCHING_DATA);

    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 300));

    bool requested =
        await health.requestAuthorization(types, permissions: permissions);

    await Permission.activityRecognition.request();

    if (requested) {
      try {
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(yesterday, now, types);
        healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
        setState(() {
          p = healthDataList[0];
        });
        for (var i = 0; i < healthData.length; i++) {
          if (healthData.elementAt(i).type.toString() ==
              "HealthDataType.ACTIVE_ENERGY_BURNED") {
            setState(() {
              caloriesburned = healthData.elementAt(i).value.toString();
            });
          }
        }
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      healthDataList = HealthFactory.removeDuplicates(healthDataList);

      healthDataList.forEach((x) => print(x));
      setState(() {
        _state =
            healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: screenWidth(context) * 0.05),
          child: healthDataList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight(context) * 0.07),
                    Text("Hi!",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: brightness == Brightness.light
                                ? Colors.black
                                : Colors.white)),
                    SizedBox(height: screenHeight(context) * 0.05),
                    Container(
                      height: screenHeight(context) * 0.16,
                      width: screenWidth(context) * 0.9,
                      decoration: BoxDecoration(
                        color: brightness == Brightness.light
                            ? Colors.grey.shade300
                            : Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenHeight(context) * 0.03,
                            vertical: screenHeight(context) * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Steps: ${p!.value}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            SizedBox(height: screenHeight(context) * 0.01),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: screenWidth(context) * 0.6,
                                    child: LinearProgressIndicator(
                                      minHeight: screenHeight(context) * 0.015,
                                      color: brightness == Brightness.dark
                                          ? Colors.grey.shade500
                                          : Colors.black,
                                      value: int.parse(p!.value.toString()) /
                                          (int.parse(p!.value.toString()) +
                                              1000),
                                      backgroundColor:
                                          brightness == Brightness.light
                                              ? Colors.grey.shade500
                                              : Colors.black38,
                                    ),
                                  ),
                                ),
                                Icon(
                                  CustomIcon.walking,
                                  size: screenHeight(context) * 0.04,
                                  color: brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                )
                              ],
                            ),
                            Container(
                              width: screenWidth(context) * 0.7,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${p!.value}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: brightness == Brightness.light
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  Text(
                                    "Goal ${int.parse(p!.value.toString()) + 1000}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: brightness == Brightness.light
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight(context) * 0.02),
                    Container(
                      height: screenHeight(context) * 0.16,
                      width: screenWidth(context) * 0.9,
                      decoration: BoxDecoration(
                        color: brightness == Brightness.light
                            ? Colors.grey.shade300
                            : Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenHeight(context) * 0.03,
                            vertical: screenHeight(context) * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Calories Burned: ${double.parse(caloriesburned).round()}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            SizedBox(height: screenHeight(context) * 0.01),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: screenWidth(context) * 0.6,
                                    child: LinearProgressIndicator(
                                      minHeight: screenHeight(context) * 0.015,
                                      color: brightness == Brightness.dark
                                          ? Colors.grey.shade500
                                          : Colors.black,
                                      value: double.parse(caloriesburned) /
                                          (double.parse(caloriesburned)
                                                  .round() +
                                              1000000),
                                      backgroundColor:
                                          brightness == Brightness.light
                                              ? Colors.grey.shade500
                                              : Colors.black38,
                                    ),
                                  ),
                                ),
                                Icon(
                                  CustomIcon.burn,
                                  size: screenHeight(context) * 0.04,
                                  color: brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                )
                              ],
                            ),
                            Container(
                              width: screenWidth(context) * 0.7,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${caloriesburned.toString()}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: brightness == Brightness.light
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  Text(
                                    "Goal ${double.parse(caloriesburned).round() + 1000000}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: brightness == Brightness.light
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : Center(
                  child: GestureDetector(
                    onTap: () async {
                      await fetchData();
                    },
                    child: Container(
                      height: screenHeight(context) * 0.07,
                      width: screenWidth(context) * 0.5,
                      decoration: BoxDecoration(
                        color: brightness == Brightness.light
                            ? Colors.grey.shade300
                            : Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Get Data",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white),
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }
}
