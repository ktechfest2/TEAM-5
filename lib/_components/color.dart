import 'package:flutter/material.dart';

// *** CORE BRAND COLORS ***
const mainColor = Color(0xFF0A1A2F); // Midnight Navy – deep tech luxury
const auxColor = Color(0xFFD4A73B); // Gold Accent – premium highlight
const auxColor2 = Color(0xFF123456); // Slightly lighter navy for layering
const auxColor3 = Color(0xFFF8F9FA); // Soft White – clean, modern base

// *** ONBOARDING COLORS ***
const onboardingColorDark =
    Color(0xFF0A1A2F); // Deep Midnight Navy – elegant intro feel

const onboardingColor =
    Color(0xFFF8F9FA); // Soft White – smooth, premium onboarding

const white = Color(0xFFFFFFFF); // Pure White

// *** BOTTOMSHEET BACKGROUND (Navy → Gold fade) ***
const bottomsheetbkgndcolor = BoxDecoration(
  borderRadius: BorderRadius.horizontal(
    left: Radius.circular(20),
    right: Radius.circular(20),
  ),
  gradient: LinearGradient(
    colors: [
      Color(0xFF0A1A2F), // Midnight Navy
      Color(0xFFD4A73B), // Gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);

// *** APP BACKGROUND GRADIENT (Soft White → Light Navy Mist → Deep Navy) ***
const bkgndcolor_grad = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [
      Color(0xFFF8F9FA), // Soft White
      Color(0xFF264162), // Misty Navy (soft mid tone)
      Color(0xFF0A1A2F), // Midnight Navy
    ],
  ),
);

// *** CONTAINER STYLE (Navy → Gold luxury sweep) ***
var style_container = BoxDecoration(
  borderRadius: BorderRadius.circular(20),
  gradient: LinearGradient(
    colors: [
      Color(0xFF0A1A2F), // Midnight Navy
      Color(0xFFD4A73B), // Gold Accent
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);

// *** FORM BACKGROUND (Dark Navy → Elegant Warm Gold Shadow) ***
const form_bgGrad = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [
      Color(0xFF0A1A2F), // Midnight Navy
      Color(0xFFD4A73B), // Gold Accent (muted in gradient for elegance)
    ],
  ),
);


