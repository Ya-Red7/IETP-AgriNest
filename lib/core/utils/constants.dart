import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'AgriNest';
  static const String appNameAmharic = 'አግሪኔስት';
  static const String version = '1.0.0';
  static const String developer = 'Group 81 - AASTU 2025';
  
  // Routes
  static const String authRoute = '/';
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String analyticsRoute = '/analytics';
  static const String settingsRoute = '/settings';
  static const String editProfileRoute = '/edit-profile';
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  
  // API Endpoints (placeholder)
  static const String baseUrl = 'https://api.agrinest.et';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String sensorDataEndpoint = '/sensors/data';
  static const String pumpActivateEndpoint = '/pump/activate';
  
  // Sensor Types
  static const String soilMoisture = 'soil_moisture';
  static const String temperature = 'temperature';
  static const String humidity = 'humidity';
  static const String light = 'light';
  static const String battery = 'battery';
  static const String waterUsed = 'water_used';
  
  // Units
  static const String percentUnit = '%';
  static const String celsiusUnit = '°C';
  static const String luxUnit = 'lux';
  static const String voltUnit = 'V';
  static const String mlUnit = 'ml';
  
  // Chart Time Periods
  static const String period24h = '24h';
  static const String period7days = '7days';
  static const String period30days = '30days';
}
