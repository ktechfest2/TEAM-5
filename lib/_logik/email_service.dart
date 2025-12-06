import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String formatNaira(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String formatNairaa(double amount) {
  // Convert to integer if whole number, otherwise 2 decimals
  final formatted =
      amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(2);

  // Add commas for thousands
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return '₦${formatted.replaceAllMapped(reg, (match) => ',')}';
}

String formatNara(double amount) {
  return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

/// --- EMAIL API CALL ---
Future<void> sendEmail({
  required String to,
  required String subject,
  required String body,
  String? html, // optional HTML
}) async {
  try {
    final response = await http.post(
      Uri.parse("https://farmket-email-notification.vercel.app/api/send-email"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "to": to,
        "subject": subject,
        "body": body,
        "html": html, // include if provided
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("❌ Email send failed: ${response.body}");
    }
  } catch (e) {
    debugPrint("❌ Email API error: $e");
  }
}

/// ---------------- EMAILS -----------------

///// --- SIGNUP EMAIL --- ////
///
Future<void> sendSignupEmail(String userEmail, String userName) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png"; // app logo

  final html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </head>

  <body style="margin:0; padding:0; background-color:#f5f3e8; font-family:Arial, sans-serif;">

    <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#f5f3e8">
      <tr>
        <td>

          <!-- MAIN CONTAINER -->
          <table align="center" width="600" cellpadding="20" cellspacing="0" 
            style="margin:25px auto; background:#ffffff; border-radius:12px;
                   box-shadow:0 4px 12px rgba(0,0,0,0.08);">

            <!-- HEADER -->
            <tr>
              <td align="center" style="padding-bottom:0;">
                <img src="$logoUrl" alt="Aurion Logo" width="110" style="border-radius:10px;"/>
                <h2 style="color:#D4AF37; margin-top:10px; font-size:26px;">
                  ✨ Welcome to Aurion, $userName!
                </h2>
              </td>
            </tr>

            <!-- BODY -->
            <tr>
              <td style="color:#333; font-size:15px; line-height:1.6;">

                <p>
                  We are delighted to welcome you to 
                  <strong style="color:#D4AF37;">Aurion Hotel & Hospitality</strong>, 
                  where luxury meets comfort and every stay becomes a memorable experience.
                </p>

                <p>Here's what you can explore:</p>

                <ul style="padding-left:20px;">
                  <li>🏨 Premium Rooms & Suites</li>
                  <li>🌆 Exclusive Experiences & Packages</li>
                  <li>🤝 World-class Hospitality</li>
                </ul>

                <!-- BUTTON -->
                <div style="text-align:center; margin:25px 0;">
                  <a href=" " 
                     style="background:#D4AF37; color:#000;
                            padding:14px 30px; border-radius:8px;
                            text-decoration:none; font-weight:bold;
                            font-size:16px;">
                    Book Your Perfect Stay
                  </a>
                </div>

                <p style="font-size:12px; color:#777; margin-top:25px;">
                  If you didn't create an Aurion account, you can safely ignore this email.
                </p>
              </td>
            </tr>

          </table>
          <!-- END MAIN CONTAINER -->

        </td>
      </tr>
    </table>

  </body>
</html>
""";

  await sendEmail(
    to: userEmail,
    subject: "👋 Welcome to Farmket 🌱",
    body: "Welcome to Farmket, $userName!", // fallback plain text
    html: html,
  );
}

/////// LOGIN ALERT EMAIL
Future<void> sendLoginAlertEmail(String userEmail, String userName) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png"; // Farmket logo

  final html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </head>
  <body style="margin:0; padding:0; background-color:#f6f6f6; font-family:Arial, sans-serif;">
    <span style="display:none; font-size:1px; color:#f6f6f6; line-height:1px; max-height:0; max-width:0; opacity:0; overflow:hidden;">
      Security alert for your Farmket account
    </span>
    <div style="display:none; line-height:0; max-height:0; overflow:hidden;">&nbsp;</div>
    <table width="100%" bgcolor="#f6f6f6" cellpadding="0" cellspacing="0">
      <tr>
        <td>
          <table align="center" width="600" bgcolor="#ffffff" cellpadding="20" cellspacing="0" style="margin:20px auto; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1);">
            <tr>
              <td align="center">
                <img src="$logoUrl" alt="Farmket Logo" width="100" style="border-radius:50%;"/>
                <h2 style="color:#d32f2f;">⚠️ Security Alert</h2>
              </td>
            </tr>
            <tr>
              <td>
                <p>Hello <b>$userName</b>,</p>
                <p>We noticed a login to your Farmket account with this email: <b>$userEmail</b>.</p>
                <p>If this was <b>you</b>, you can safely ignore this email.</p>
                <p>If this was <b>not you</b>, please open the <b>Farmket app</b> immediately and go to:</p>
                <ul>
                  <li><b>Profile → Reset Password</b></li>
                  <li>Update your password to secure your account</li>
                </ul>
                <p style="font-size:12px; color:#888; margin-top:20px;">
                  This security notice was sent automatically by Farmket for your protection.
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
""";

  await sendEmail(
    to: userEmail,
    subject: "⚠️ Security Alert: Login detected on your Farmket account",
    body:
        "Hello $userName, a login was detected on your Farmket account. If it wasn't you, open the app → Settings → Reset Password.",
    html: html,
  );
}

/// --- VERIFICATION EMAIL WITH APP ACCESS --- ///
Future<void> sendVerificationEmail(String userEmail, String userName) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png"; // app logo

  final html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </head>
  <body style="margin:0; padding:0; background-color:#f6f6f6; font-family:Arial, sans-serif;">
    <table width="100%" bgcolor="#f6f6f6" cellpadding="0" cellspacing="0">
      <tr>
        <td>
          <table align="center" width="600" bgcolor="#ffffff" cellpadding="20" cellspacing="0" style="margin:20px auto; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1);">
            <tr>
              <td align="center">
                <img src="$logoUrl" alt="Farmket Logo" width="100" style="border-radius:50%;"/>
                <h2 style="color:#2e7d32;">🔒 Account Under Review, $userName!</h2>
              </td>
            </tr>
            <tr>
              <td>
                <p>Thank you for signing up for Farmket! Your account is now under review by our team.</p>
                <p>While we verify your account, you can continue using the app with limited features:</p>
                <ul>
                  <li>🚀 Browse fresh agricultural products</li>
                  <li>🛒 Add products to your wishlist</li>
                  <li>🤝 Explore sellers & buyers</li>
                </ul>
                <p>Once approved, full access will be granted.</p>
                <div style="text-align:center; margin:20px 0;">
                  <a href="https://www.instagram.com/seedo_agro?igsh=MXVrczNrdzV1c2xsZA==" style="background:#2e7d32; color:#fff; padding:12px 20px; border-radius:6px; text-decoration:none; font-weight:bold;">Join our Community</a>
                </div>
                <p style="font-size:12px; color:#888;">If you didn't sign up for Farmket, you can safely ignore this email.</p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
""";

  await sendEmail(
    to: userEmail,
    subject: "🔒 Your Farmket Account is Under Review",
    body:
        "Hi $userName, your Farmket account is under review. You can continue using the app with limited features.", // plain text fallback
    html: html,
  );
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// --- BUYER ORDER CONFIRMATION EMAIL --- ///
Future<void> sendBuyersOrderInfoEmail({
  required String buyerEmail,
  required String buyerName,
  required String orderId,
  required String finalAddress,
  required List<Map<String, dynamic>> cartItems,
  required double totalCost,
  String paymentStatus = "Not Paid",
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  // Generate cart items table rows
  String itemsHtml = "";
  for (var item in cartItems) {
    final name = item["productName"] ?? "Product";
    final qty = item["quantity"] ?? 1;
    final sellingType = item["sellingType"] ?? ""; // new field
    final price = (item["price"] ?? 0).toDouble();
    final subtotal = qty * price;
    itemsHtml += """
      <tr>
        <td style="padding:8px; border-bottom:1px solid #ddd;">$name</td>
        <td style="padding:8px; border-bottom:1px solid #ddd; text-align:center;">$qty $sellingType</td>
        <td style="padding:8px; border-bottom:1px solid #ddd; text-align:right;">${formatNairaa(subtotal)}</td>
      </tr>
    """;
  }

  final html = """
<!DOCTYPE html>
<html>
  <head><meta charset="UTF-8"/></head>
  <body style="font-family:Arial, sans-serif; background:#f6f6f6; margin:0; padding:0;">
    <table width="100%" bgcolor="#f6f6f6" cellpadding="0" cellspacing="0">
      <tr><td>
        <table align="center" width="600" bgcolor="#ffffff" cellpadding="20" cellspacing="0" style="margin:20px auto; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1);">
          <tr>
            <td align="center">
              <img src="$logoUrl" width="100" style="border-radius:50%;"/>
              <h2 style="color:#2e7d32;">🌱 Order Confirmed: #$orderId</h2>
            </td>
          </tr>
          <tr>
            <td>
              <p>Hi $buyerName,</p>
              <p>Your order has been successfully placed. Here's a summary of your order:</p>
              
              <h3>📦 Items</h3>
              <table width="100%" style="border-collapse:collapse;">
                <tr>
                  <th style="text-align:left; padding:8px; border-bottom:2px solid #2e7d32;">Product</th>
                  <th style="text-align:center; padding:8px; border-bottom:2px solid #2e7d32;">Qty</th>
                  <th style="text-align:right; padding:8px; border-bottom:2px solid #2e7d32;">Subtotal</th>
                </tr>
                $itemsHtml
                <tr>
                  <td colspan="2" style="padding:8px; text-align:right; font-weight:bold;">Total</td>
                  <td style="padding:8px; text-align:right; font-weight:bold;">${formatNairaa(totalCost)}</td>
                </tr>
              </table>

              <h3>🏠 Delivery Information</h3>
              <p>$finalAddress</p>
              <p>Cost for delivery fee would be added & sent to you, once the checkout is confirmed.</p>

              <h3>💳 Payment Status</h3>
              <p>$paymentStatus</p>

              <div style="text-align:center; margin:20px 0;">
                <a href=" " style="background:#2e7d32; color:#fff; padding:12px 20px; border-radius:6px; text-decoration:none; font-weight:bold;">View Your Order</a>
              </div>

              <p style="font-size:12px; color:#888;">Thank you for choosing Farmket! 🌱</p>
            </td>
          </tr>
        </table>
      </td></tr>
    </table>
  </body>
</html>
""";

  await sendEmail(
    to: buyerEmail,
    subject: "🌱 Your Farmket Order #$orderId Confirmation",
    body:
        "Hi $buyerName, your order #$orderId has been placed. Total: ${formatNairaa(totalCost)}",
    html: html,
  );
}

/// --- SELLER NOTIFICATION EMAIL --- ///
Future<void> sendSellersOrderInfoEmail({
  required String sellerEmail,
  required String sellerName,
  required String orderId,
  required String buyerName,
  required String buyerAddress,
  // required String sellerId, // add sellerId here
  required List<Map<String, dynamic>> cartItems,
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  //Filter items by sellerId instead of sellerEmail
  final sellerItems = cartItems;

  String itemsHtml = "";
  double sellerTotal = 0;
  for (var item in sellerItems) {
    final name = item["productName"] ?? "Product";
    final qty = item["quantity"] ?? 1;
    final sellingType = item["sellingType"] ?? ""; // optional
    final price = (item["price"] ?? 0).toDouble();
    final subtotal = qty * price;
    sellerTotal += subtotal;

    itemsHtml += """
      <tr>
        <td style="padding:8px; border-bottom:1px solid #ddd;">$name</td>
        <td style="padding:8px; border-bottom:1px solid #ddd; text-align:center;">$qty $sellingType</td>
        <td style="padding:8px; border-bottom:1px solid #ddd; text-align:right;">${formatNairaa(subtotal)}</td>
      </tr>
    """;
  }

  // apply Farmket 7% service fee
  final farmketFee = sellerTotal * 0.07;
  final sellerEarnings = sellerTotal - farmketFee;
  //save sellerEarnings in Doc

  final html = """
<!DOCTYPE html>
<html>
  <head><meta charset="UTF-8"/></head>
  <body style="font-family:Arial, sans-serif; background:#f6f6f6; margin:0; padding:0;">
    <table width="100%" bgcolor="#f6f6f6" cellpadding="0" cellspacing="0">
      <tr><td>
        <table align="center" width="600" bgcolor="#ffffff" cellpadding="20" cellspacing="0" style="margin:20px auto; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1);">
          <tr>
            <td align="center">
              <img src="$logoUrl" width="100" style="border-radius:50%;"/>
              <h2 style="color:#2e7d32;">📦 New Order Received: #$orderId</h2>
            </td>
          </tr>
          <tr>
            <td>
              <p>Hi $sellerName,</p>
              <p>A new order has been placed containing your products. Here's the summary:</p>

              <h3>🛒 Items</h3>
              <table width="100%" style="border-collapse:collapse;">
                <tr>
                  <th style="text-align:left; padding:8px; border-bottom:2px solid #2e7d32;">Product</th>
                  <th style="text-align:center; padding:8px; border-bottom:2px solid #2e7d32;">Qty</th>
                  <th style="text-align:right; padding:8px; border-bottom:2px solid #2e7d32;">Subtotal</th>
                </tr>
                $itemsHtml
                <tr>
                  <td colspan="2" style="padding:8px; text-align:right; font-weight:bold;">Total</td>
                  <td style="padding:8px; text-align:right; font-weight:bold;">${formatNairaa(sellerTotal)}</td>
                </tr>
                <tr>
                  <td colspan="2" style="padding:8px; text-align:right; font-weight:bold; color:#d32f2f;">Farmket Fee (2%)</td>
                  <td style="padding:8px; text-align:right; color:#d32f2f;">-${formatNairaa(farmketFee)}</td>
                </tr>
                <tr>
                  <td colspan="2" style="padding:8px; text-align:right; font-weight:bold; color:#2e7d32;">Your Earnings</td>
                  <td style="padding:8px; text-align:right; font-weight:bold; color:#2e7d32;">${formatNairaa(sellerEarnings)}</td>
                </tr>
              </table>

              <div style="text-align:center; margin:20px 0;">
                <a href=" " style="background:#2e7d32; color:#fff; padding:12px 20px; border-radius:6px; text-decoration:none; font-weight:bold;">View Order</a>
              </div>

              <p style="font-size:12px; color:#888;">Farmket automatically notifies you of new orders. 🌱</p>
            </td>
          </tr>
        </table>
      </td></tr>
    </table>
  </body>
</html>
""";

  await sendEmail(
    to: sellerEmail,
    subject: "📦 New Farmket Order #$orderId",
    body:
        "Hi $sellerName, a new order #$orderId has been placed including your products. Your earnings after fees: ${formatNairaa(sellerEarnings)}",
    html: html,
  );
}

//////////////////////////////////////////////////////////////////////////////// BUYER CHECKOUT EMAIL ///////////////////////////////////
///

Future<void> sendBuyerCheckoutEmail({
  required String buyerEmail,
  required String buyerName,
  required String orderId,
  required String paymentMethod,
  required String paymentStatus,
  required String deliveryDay,
  required double totalCost,
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  final paymentNote = paymentMethod == "POD"
      ? "Payment will be collected on delivery. Please be ready to pay the delivery agent."
      : (paymentStatus.toLowerCase() == "not paid"
          ? "Please complete your payment to avoid delays."
          : "Payment received. Thank you!");

  final showPayNow =
      paymentMethod != "POD" && paymentStatus.toLowerCase() == "not paid";

  final html = """
<!DOCTYPE html>
<html>
<head>
  <meta charset='UTF-8'/>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
</head>
<body style="font-family: Arial, sans-serif; background: #f6f6f6; margin: 0; padding: 0;">
  <table width="100%" bgcolor="#f6f6f6" cellpadding="0" cellspacing="0">
    <tr>
      <td>
        <table align="center" width="600" bgcolor="#ffffff" cellpadding="20" cellspacing="0" 
               style="margin: 20px auto; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.1);">
          <tr>
            <td align="center">
              <img src="$logoUrl" width="100" style="border-radius: 50%;"/>
              <h2 style="color: #2e7d32;">✅ Checkout Completed: #$orderId</h2>
            </td>
          </tr>
          <tr>
            <td>
              <p>Hi $buyerName,</p>
              <p>Your checkout has been successfully completed. Here's a summary:</p>

              <h3>💳 Payment Information</h3>
              <p>
                Payment Method: <b>$paymentMethod</b><br/>
                Payment Status: <b>$paymentStatus</b><br/>
                <b>Total Cost: ₦${formatNara(totalCost)}</b>
              </p>
              <p style="color: #d32f2f;">$paymentNote</p>

              <h3>🏠 Delivery Info</h3>
              <p>Estimated delivery day: <b>$deliveryDay</b></p>

              ${showPayNow ? """
              <div style="text-align: center; margin: 20px 0;">
                <a href=" " 
                   style="background: #2e7d32; color: #fff; padding: 12px 20px; 
                          border-radius: 6px; text-decoration: none; font-weight: bold;">
                  Pay Now
                </a>
              </div>
              """ : ""}

              <p style="font-size: 12px; color: #888;">
                Thank you for choosing <b>Farmket</b>! 🌱
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
""";

  await sendEmail(
    to: buyerEmail,
    subject: "🌱 Checkout Completed: Order #$orderId",
    body:
        "Hi $buyerName, your checkout for order #$orderId is completed. Payment method: $paymentMethod. Payment status: $paymentStatus. Total: ₦${formatNara(totalCost)}.",
    html: html,
  );
}

//////////////////////////////////// SELLERS CHECKOUT EMAIL //////////////////////////////////////////////////////////
Future<void> sendSellerCheckoutEmail({
  required String sellerEmail,
  required String sellerName,
  required String orderId,
  required String buyerName,
  required String paymentMethod,
  required String paymentStatus,
  required String deliveryDay,
  required double sellerTotal, // total from their products only
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  final serviceFee = 0.07; // 7% Farmket fee
  final earning = sellerTotal - (sellerTotal * serviceFee);

  final html = """
<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'/>
<meta name='viewport' content='width=device-width, initial-scale=1.0'/>
</head>
<body style='font-family:Arial,sans-serif; background:#f6f6f6; margin:0; padding:0;'>
<table width='100%' bgcolor='#f6f6f6' cellpadding='0' cellspacing='0'>
<tr><td>
<table align='center' width='600' bgcolor='#ffffff' cellpadding='20' cellspacing='0' style='margin:20px auto; border-radius:10px; box-shadow:0 2px 6px rgba(0,0,0,0.1);'>
<tr><td align='center'>
<img src='$logoUrl' width='100' style='border-radius:50%;'/>
<h2 style='color:#2e7d32;'>📦 New Order Ready: #$orderId</h2>
</td></tr>
<tr><td>
<p>Hi $sellerName,</p>
<p>A Buyer has completed checkout for your products. Here's the info:</p>
<p>Farmket team will notify you when the buyer is ready for pickup.</p>
<h3>💰 Your Earning</h3>
<p>Total from your products (after 7% farmket service fee): <b>${formatNaira(earning)}</b></p>
<div style='text-align:center; margin:20px 0;'>
<a href=' ' style='background:#2e7d32; color:#fff; padding:12px 20px; border-radius:6px; text-decoration:none; font-weight:bold;'>View Order</a>
</div>
<p style='font-size:12px; color:#888;'>Farmket automatically notifies you of new orders. 🌱</p>
</td></tr>
</table>
</td></tr>
</table>
</body>
</html>
""";

  await sendEmail(
    to: sellerEmail,
    subject: "📦 Order #$orderId Ready for Processing",
    body:
        "Hi $sellerName, a buyer has checked out order #$orderId. Your earning: ₦${formatNara(earning)}",
    html: html,
  );
}

//////////////////////////////////////////////////////////// buyer cancellation email //////////////////////////

Future<void> sendBuyerCancellationEmail({
  required String buyerEmail,
  required String buyerName,
  required String orderId,
  required double totalCost,
  required List<dynamic> items, // pass the order['items']
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  // Build table rows
  final rows = items.map((item) {
    final name = item['productName'] ?? '';
    final qty = item['quantity'] ?? 0;
    final price = (item['price'] ?? 0).toDouble();
    final subtotal = price * qty;
    final seller = item['sellerName'] ?? '';
    final img = item['image'] ?? '';
    final sellingType = item["sellingType"] ?? "";

    return """
      <tr>
        <td style='padding:8px; border:1px solid #ddd;'>
          <img src='$img' width='50' style='border-radius:6px;'/>
        </td>
        <td style='padding:8px; border:1px solid #ddd;'>$name</td>
        <td style='padding:8px; border:1px solid #ddd;'>$seller</td>
        <td style='padding:8px; border:1px solid #ddd;'>$qty $sellingType</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(price)}</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(subtotal)}</td>
      </tr>
    """;
  }).join();

  final html = """
<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'/>
<meta name='viewport' content='width=device-width, initial-scale=1.0'/>
</head>
<body style='font-family:Arial,sans-serif; background:#f6f6f6; margin:0; padding:0;'>
<table width='100%' bgcolor='#f6f6f6' cellpadding='0' cellspacing='0'>
<tr><td>
<table align='center' width='650' bgcolor='#ffffff' cellpadding='25' cellspacing='0' 
style='margin:25px auto; border-radius:12px; box-shadow:0 3px 10px rgba(0,0,0,0.15);'>
<tr><td align='center'>
<img src='$logoUrl' width='120' style='border-radius:50%;'/>
<h1 style='color:#d32f2f; font-size:26px; margin:15px 0;'>❌ Order Cancelled</h1>
<h2 style='color:#333; font-size:22px;'>Order ID: <span style='color:#d32f2f;'>#$orderId</span></h2>
</td></tr>
<tr><td>
<p style='font-size:18px; color:#333;'>Hi <b>$buyerName</b>,</p>
<p style='font-size:17px; color:#444;'>You have successfully <b style='color:#d32f2f;'>cancelled</b> your order 
<b style='color:#d32f2f;'>#$orderId</b>.</p>

<h3 style='font-size:20px; margin-top:25px; color:#2c3e50;'>💰 Order Summary</h3>
<table width='100%' cellpadding='0' cellspacing='0' style='border-collapse:collapse; font-size:16px;'>
  <tr style='background:#f0f0f0; font-size:16px;'>
    <th style='padding:12px; border:1px solid #ddd;'>Image</th>
    <th style='padding:12px; border:1px solid #ddd;'>Product</th>
    <th style='padding:12px; border:1px solid #ddd;'>Seller</th>
    <th style='padding:12px; border:1px solid #ddd;'>Qty</th>
    <th style='padding:12px; border:1px solid #ddd;'>Price</th>
    <th style='padding:12px; border:1px solid #ddd;'>Subtotal</th>
  </tr>
  $rows
  <tr style='background:#fafafa;'>
    <td colspan='5' style='padding:12px; border:1px solid #ddd; text-align:right; font-size:17px;'><b>Total:</b></td>
    <td style='padding:12px; border:1px solid #ddd; font-size:18px; font-weight:bold; color:#2e7d32;'>${formatNaira(totalCost)}</td>
  </tr>
</table>

<p style='font-size:16px; color:#2e7d32; margin-top:25px; font-weight:bold;'>You can place a new order anytime.</p>
<br/>
<p style='font-size:13px; color:#777;'>Thank you for using <b>Farmket 🌱</b></p>
</td></tr>
</table>
</td></tr>
</table>
</body>
</html>
""";

  await sendEmail(
    to: buyerEmail,
    subject: "❌ Order #$orderId Cancelled Confirmation",
    body:
        "Hi $buyerName, you cancelled your order #$orderId. Total ₦${formatNaira(totalCost)}.",
    html: html,
  );
}

///////////////////////////////////////////////////// SELLER CANCELLATION EMAIL /////////////////////////////////////////////////////
Future<void> sendSellerCancellationEmail({
  required String sellerEmail,
  required String sellerName,
  required String orderId,
  required String buyerName,
  required List<dynamic> sellerItems, //only this seller’s items
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  final rows = sellerItems.map((item) {
    final name = item['productName'] ?? '';
    final qty = item['quantity'] ?? 0;
    final price = (item['price'] ?? 0).toDouble();
    final subtotal = price * qty;
    final img = item['image'] ?? '';
    final sellingType = item["sellingType"] ?? "";

    return """
      <tr>
        <td style='padding:8px; border:1px solid #ddd;'>
          <img src='$img' width='50' style='border-radius:6px;'/>
        </td>
        <td style='padding:8px; border:1px solid #ddd;'>$name</td>
        <td style='padding:8px; border:1px solid #ddd;'>$qty $sellingType</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(price)}</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(subtotal)}</td>
      </tr>
    """;
  }).join();

  final sellerTotal = sellerItems.fold<double>(0, (sum, item) {
    final qty = (item['quantity'] ?? 0) as int;
    final price = (item['price'] ?? 0).toDouble();
    return sum + (price * qty);
  });

  final html = """
<!DOCTYPE html>
<html>
<head><meta charset='UTF-8'/></head>
<body style='font-family:Arial,sans-serif; background:#f6f6f6; margin:0; padding:0;'>
<table align='center' width='650' bgcolor='#ffffff' cellpadding='25' cellspacing='0' 
style='margin:25px auto; border-radius:12px; box-shadow:0 3px 10px rgba(0,0,0,0.15);'>
<tr><td align='center'>
<img src='$logoUrl' width='120' style='border-radius:50%;'/>
<h1 style='color:#d32f2f; font-size:26px; margin:15px 0;'>❌ Order Cancelled</h1>
<h2 style='color:#333; font-size:22px;'>Order ID: <span style='color:#d32f2f;'>#$orderId</span></h2>
</td></tr>
<tr><td>
<p style='font-size:18px; color:#333;'>Hi <b>$sellerName</b>,</p>
<p style='font-size:17px; color:#444;'>The buyer <b style='color:#d32f2f;'>$buyerName</b> has <b style='color:#d32f2f;'>cancelled</b> order 
<b style='color:#d32f2f;'>#$orderId</b>.</p>

<h3 style='font-size:20px; margin-top:25px; color:#2c3e50;'>📦 Items from Your Store</h3>
<table width='100%' cellpadding='0' cellspacing='0' style='border-collapse:collapse; font-size:16px;'>
  <tr style='background:#f0f0f0; font-size:16px;'>
    <th style='padding:12px; border:1px solid #ddd;'>Image</th>
    <th style='padding:12px; border:1px solid #ddd;'>Product</th>
    <th style='padding:12px; border:1px solid #ddd;'>Qty</th>
    <th style='padding:12px; border:1px solid #ddd;'>Price</th>
    <th style='padding:12px; border:1px solid #ddd;'>Subtotal</th>
  </tr>
  $rows
  <tr style='background:#fafafa;'>
    <td colspan='4' style='padding:12px; border:1px solid #ddd; text-align:right; font-size:17px;'><b>Total:</b></td>
    <td style='padding:12px; border:1px solid #ddd; font-size:18px; font-weight:bold; color:#2e7d32;'>${formatNaira(sellerTotal)}</td>
  </tr>
</table>

<p style='font-size:16px; color:#2e7d32; margin-top:25px; font-weight:bold;'>This item stock has been restored to your store. 🌱</p>
<br/>
<p style='font-size:13px; color:#777;'>Thank you for selling with <b>Farmket</b></p>
</td></tr>
</table>
</body>
</html>
""";

  await sendEmail(
    to: sellerEmail,
    subject: "❌ Order #$orderId Cancelled by $buyerName",
    body:
        "Order #$orderId was cancelled by $buyerName. Total ₦${formatNaira(sellerTotal)} worth of your items restored.",
    html: html,
  );
}

//////////////////////////////////////////////////////////////////// buyer PAYMENT SUCCESSFUL /////////////////////////////////////
Future<void> sendBuyerPaymentSuccessfulEmail({
  required String buyerEmail,
  required String buyerName,
  required String orderId,
  required double totalCost,
  required String paymentMethod,
  required List<dynamic> items,
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  final rows = items.map((item) {
    final name = item['productName'] ?? '';
    final qty = item['quantity'] ?? 0;
    final price = (item['price'] ?? 0).toDouble();
    final subtotal = price * qty;
    final img = item['image'] ?? '';
    final sellingType = (item['sellingType'] ?? '').toString();

    return """
      <tr>
        <td style='padding:8px; border:1px solid #ddd;'><img src='$img' width='50' style='border-radius:6px;'/></td>
        <td style='padding:8px; border:1px solid #ddd;'>$name</td>
        <td style='padding:8px; border:1px solid #ddd;'>$qty $sellingType</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(price)}</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(subtotal)}</td>
      </tr>
    """;
  }).join();

  final html = """
<!DOCTYPE html>
<html>
<body style='font-family:Arial,sans-serif; background:#f6f6f6; margin:0; padding:0;'>
<table align='center' width='650' bgcolor='#ffffff' cellpadding='25' cellspacing='0' 
style='margin:25px auto; border-radius:12px; box-shadow:0 3px 10px rgba(0,0,0,0.15);'>
<tr><td align='center'>
  <img src='$logoUrl' width='120' style='border-radius:50%;'/>
  <h1 style='color:#2e7d32; font-size:28px; margin:15px 0;'>✅ Payment Successful</h1>
  <h2 style='color:#333; font-size:22px;'>Order ID: <span style='color:#2e7d32;'>#$orderId</span></h2>
</td></tr>
<tr><td>
<p style='font-size:18px; color:#333;'>Hi <b>$buyerName</b>,</p>
<p style='font-size:17px; color:#444;'>We've received your payment for order 
<b style='color:#2e7d32;'>#$orderId</b> via <b>$paymentMethod</b>.</p>
<p style='font-size:17px; color:#444;'>Our team is now sorting your items and will begin processing your order immediately.</p>

<h3 style='font-size:20px; margin-top:25px; color:#2c3e50;'>🛒 Order Summary</h3>
<table width='100%' cellpadding='0' cellspacing='0' style='border-collapse:collapse; font-size:16px; margin-top:10px;'>
<tr style='background:#f0f0f0; font-size:16px;'>
  <th style='padding:12px; border:1px solid #ddd;'>Image</th>
  <th style='padding:12px; border:1px solid #ddd;'>Product</th>
  <th style='padding:12px; border:1px solid #ddd;'>Qty</th>
  <th style='padding:12px; border:1px solid #ddd;'>Price</th>
  <th style='padding:12px; border:1px solid #ddd;'>Subtotal</th>
</tr>
$rows
<tr style='background:#fafafa;'>
  <td colspan='4' style='padding:12px; border:1px solid #ddd; text-align:right; font-size:17px;'><b>Total Paid:</b></td>
  <td style='padding:12px; border:1px solid #ddd; font-size:18px; font-weight:bold; color:#2e7d32;'>${formatNaira(totalCost)}</td>
</tr>
</table>

<p style='font-size:16px; color:#2e7d32; margin-top:25px; font-weight:bold;'>Your payment was successful 🎉. We’ll notify you once your order is on the way.</p>
<br/>
<p style='font-size:13px; color:#777;'>Thank you for shopping with <b>Farmket</b> 🌱</p>
</td></tr>
</table>
</body>
</html>
""";

  await sendEmail(
    to: buyerEmail,
    subject: "✅ Payment Received for Order #$orderId",
    body:
        "Hi $buyerName, your payment of ${formatNaira(totalCost)} via $paymentMethod was successful. We'll start processing your order #$orderId right away.",
    html: html,
  );
}

///////////////////////////////////////////////// seller payment successful email ////////////////////////////////////////////////////
Future<void> sendSellerPaymentSuccessfulEmail({
  required String sellerEmail,
  required String sellerName,
  required String buyerName,
  required String orderId,
  required double totalPayout,
  required List<dynamic> items,
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  final rows = items.map((item) {
    final name = item['productName'] ?? '';
    final qty = item['quantity'] ?? 0;
    final price = (item['price'] ?? 0).toDouble();
    final subtotal = price * qty;
    final img = item['image'] ?? '';
    final sellingType = (item['sellingType'] ?? '').toString();

    return """
      <tr>
        <td style='padding:8px; border:1px solid #ddd;'><img src='$img' width='50' style='border-radius:6px;'/></td>
        <td style='padding:8px; border:1px solid #ddd;'>$name</td>
        <td style='padding:8px; border:1px solid #ddd;'>$qty $sellingType</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(price)}</td>
        <td style='padding:8px; border:1px solid #ddd;'>${formatNaira(subtotal)}</td>
      </tr>
    """;
  }).join();

  final html = """
<!DOCTYPE html>
<html>
<body style='font-family:Arial,sans-serif; background:#f6f6f6; margin:0; padding:0;'>
<table align='center' width='650' bgcolor='#ffffff' cellpadding='25' cellspacing='0' 
style='margin:25px auto; border-radius:12px; box-shadow:0 3px 10px rgba(0,0,0,0.15);'>
<tr><td align='center'>
  <img src='$logoUrl' width='120' style='border-radius:50%;'/>
  <h1 style='color:#2e7d32; font-size:28px; margin:15px 0;'>💰 Buyer Payment Confirmed</h1>
  <h2 style='color:#333; font-size:22px;'>Order ID: <span style='color:#2e7d32;'>#$orderId</span></h2>
</td></tr>
<tr><td>
<p style='font-size:18px; color:#333;'>Hi <b>$sellerName</b>,</p>
<p style='font-size:17px; color:#444;'>The buyer <b style='color:#2e7d32;'>$buyerName</b> has <b>paid</b> for order 
<b style='color:#2e7d32;'>#$orderId</b>. Please prepare the items for delivery immediately.</p>

<h3 style='font-size:20px; margin-top:25px; color:#2c3e50;'>📦 Products Paid For</h3>
<table width='100%' cellpadding='0' cellspacing='0' style='border-collapse:collapse; font-size:16px; margin-top:10px;'>
<tr style='background:#f0f0f0; font-size:16px;'>
  <th style='padding:12px; border:1px solid #ddd;'>Image</th>
  <th style='padding:12px; border:1px solid #ddd;'>Product</th>
  <th style='padding:12px; border:1px solid #ddd;'>Qty</th>
  <th style='padding:12px; border:1px solid #ddd;'>Price</th>
  <th style='padding:12px; border:1px solid #ddd;'>Subtotal</th>
</tr>
$rows
<tr style='background:#fafafa;'>
  <td colspan='4' style='padding:12px; border:1px solid #ddd; text-align:right; font-size:17px;'><b>Amount You Will Receive:</b></td>
  <td style='padding:12px; border:1px solid #ddd; font-size:18px; font-weight:bold; color:#2e7d32;'>${formatNaira(totalPayout)}</td>
</tr>
</table>

<p style='font-size:16px; margin-top:25px; color:#444;'><i>Note:</i> Funds will be released once the buyer confirms delivery ✅</p>
<br/>
<p style='font-size:13px; color:#777;'>Thank you for selling with <b>Farmket</b> 🌱</p>
</td></tr>
</table>
</body>
</html>
""";

  await sendEmail(
    to: sellerEmail,
    subject: "💰 Buyer Payment Confirmed for Order #$orderId",
    body:
        "Hi $sellerName, the buyer $buyerName has paid for order #$orderId. You will receive ${formatNaira(totalPayout)} once delivery is confirmed.",
    html: html,
  );
}

////////////////////////////////BUyer payment Failed ////////////////////////

Future<void> sendBuyerPaymentFailedEmail({
  required String buyerEmail,
  required String buyerName,
  required String orderId,
  required double totalCost,
  required String paymentMethod,
}) async {
  final logoUrl =
      "https://res.cloudinary.com/dujehbdln/image/upload/v1764958788/logo2_kbtnrb.png";

  final html = """
<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'/>
<meta name='viewport' content='width=device-width, initial-scale=1.0'/>
</head>
<body style='font-family:Arial,sans-serif; background:#f6f6f6; margin:0; padding:0;'>
<table width='100%' bgcolor='#f6f6f6' cellpadding='0' cellspacing='0'>
<tr><td>
<table align='center' width='600' bgcolor='#ffffff' cellpadding='30' cellspacing='0' 
style='margin:20px auto; border-radius:12px; box-shadow:0 3px 8px rgba(0,0,0,0.15);'>
<tr><td align='center'>
<img src='$logoUrl' width='110' style='border-radius:50%;'/>
<h1 style='color:#d32f2f; font-size:26px;'>⚠ Payment Failed</h1>
<h2 style='color:#333; font-size:20px;'>Order ID: #$orderId</h2>
</td></tr>
<tr><td>
<p style='font-size:18px; color:#000;'><b>Hi $buyerName,</b></p>
<p style='font-size:16px; color:#444;'>Unfortunately, your payment for order <b>#$orderId</b> was <span style='color:#d32f2f; font-weight:bold;'>not successful</span>.</p>

<h3 style='color:#d32f2f; font-size:18px;'>❌ Payment Info</h3>
<p style='font-size:16px;'>
<b>Payment Method:</b> $paymentMethod<br/>
<b>Amount Attempted:</b> ${formatNaira(totalCost)}
</p>

<div style='text-align:center; margin:25px 0;'>
  <a href='#' style='background:#d32f2f; color:#fff; padding:14px 28px; 
     border-radius:8px; text-decoration:none; font-weight:bold; font-size:16px;'>
     Retry Payment
  </a>
</div>

<p style='font-size:14px; color:#555;'>Don't worry — you can retry your payment anytime, or choose another method.</p>
<p style='font-size:12px; color:#888;'>If you believe this is an error, please contact Farmket support.</p>
</td></tr>
</table>
</td></tr>
</table>
</body>
</html>
""";

  await sendEmail(
    to: buyerEmail,
    subject: "⚠ Payment Failed for Order #$orderId",
    body:
        "Hi $buyerName, your payment for order #$orderId was not successful. Amount attempted: ₦${formatNaira(totalCost)}. Payment method: $paymentMethod. Please retry.",
    html: html,
  );
}

/// ---------------- PUSH NOTIFICATIONS ----------------- //////////////////////////////////////////////////////////////////////////////////////////////////////////

Future<void> sendPushNotification({
  required String fcmToken,
  required String title,
  required String body,
}) async {
  try {
    final response = await http.post(
      Uri.parse(
          "https://farmket-email-notification.vercel.app/api/send-notification"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "token": fcmToken,
        "title": title,
        "body": body,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("❌ Push notification failed: ${response.body}");
    }
  } catch (e) {
    debugPrint("❌ Push notification error: $e");
  }
}

/// Example usage:
/// sendPushNotification(
///   fcmToken: userFcmToken,
///   title: "📦 Order Confirmed!",
///   body: "Your order #123 is being processed 🚀",
/// );
