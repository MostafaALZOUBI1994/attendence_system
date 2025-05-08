import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/health_model.dart';


class HealthCard extends StatelessWidget {
  final HealthData healthData;

  const HealthCard({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "emphlth".tr(),
            style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _healthMetric("stps".tr(), healthData.steps.toString(), "assets/lottie/walking.json"),
              _healthMetric("hrtRate".tr(), "${healthData.heartRate} bpm", "assets/lottie/heart_pulse.json"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _healthMetric("cal".tr(), "${healthData.caloriesBurned} kcal", "assets/lottie/calories.json"),
              _healthMetric("sleep".tr(), "${healthData.sleepDuration} hrs", "assets/lottie/sleep.json"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _healthMetric(String title, String value, String animatedImage) {
    return Container(
      width: 150,
      child: Column(
        children: [
          Lottie.asset(animatedImage,width: 40,height: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}