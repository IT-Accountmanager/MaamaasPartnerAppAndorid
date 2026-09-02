import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../API/Auth_service.dart';
import '../Models/wallet_model.dart';

class LoadMoneyHelper {





  static void open({
  required BuildContext context,
  required Razorpay razorpay,
  required String? userType,
  required double cashbackAmount,
  required String? email,
  required String? mobile,
  required VoidCallback onSuccess,
  }) {
  if (userType == "PROFESSIONAL") {
  _professionalSheet(
  context,
  razorpay,
  cashbackAmount,
  email,
  mobile,
  onSuccess,
  );
  } else {
  _normalSheet(
  context,
  razorpay,
  email,
  mobile,
  onSuccess,
  );
  }
  }

  // 👇 move your existing methods here
  static void _professionalSheet(
      BuildContext context,
      Razorpay razorpay,
      double cashbackAmount,
      String? email,
      String? mobile,
      VoidCallback onSuccess,
      ) {
    final controller = TextEditingController();
    bool useCashback = false;
    double entered = 0;
    double payable = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Load Wallet",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(prefixText: "₹"),
                  onChanged: (v) {
                    setState(() {
                      entered = double.tryParse(v) ?? 0;
                      payable = (entered -
                          (useCashback ? cashbackAmount : 0))
                          .clamp(0, entered);
                    });
                  },
                ),

                CheckboxListTile(
                  value: useCashback,
                  title: Text(
                      "Use Cashback (₹${cashbackAmount.toStringAsFixed(2)})"),
                  onChanged: (v) {
                    setState(() {
                      useCashback = v!;
                      payable = (entered -
                          (useCashback ? cashbackAmount : 0))
                          .clamp(0, entered);
                    });
                  },
                ),

                ElevatedButton(
                  onPressed: payable <= 0
                      ? null
                      : () async {
                    Navigator.pop(context);

                    final orderId =
                    await AuthService.createOrder(payable);
                    if (orderId == null) return;

                    razorpay.open({
                      'key': 'rzp_test_TJECsclCivENpY',
                      'order_id': orderId,
                      'amount': (payable * 100).toInt(),
                      'name': 'Wallet Top-Up',
                      'prefill': {
                        'email': email,
                        'contact': mobile,
                      },
                    });

                    razorpay.on(
                      Razorpay.EVENT_PAYMENT_SUCCESS,
                          (res) async {
                        final ok =
                        await AuthService.professionalSelfLoaded(
                          amount: payable,
                          paymentId: res.paymentId!,
                          orderId: orderId,
                          useCashback: useCashback,
                        );
                        if (ok) onSuccess();
                      },
                    );
                  },
                  child: Text("Pay ₹${payable.toStringAsFixed(2)}"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  static void _normalSheet(
      BuildContext context,
      Razorpay razorpay,
      String? email,
      String? mobile,
      VoidCallback onSuccess,
      ) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text);
                if (amount == null || amount <= 0) return;

                Navigator.pop(context);

                final orderId = await AuthService.createOrder(amount);
                if (orderId == null) return;

                razorpay.open({
                  'key': 'rzp_test_TJECsclCivENpY',
                  'order_id': orderId,
                  'amount': (amount * 100).toInt(),
                  'prefill': {
                    'email': email,
                    'contact': mobile,
                  },
                });

                razorpay.on(
                  Razorpay.EVENT_PAYMENT_SUCCESS,
                      (_) => onSuccess(),
                );
              },
              child: const Text("Proceed to Pay"),
            )
          ],
        ),
      ),
    );
  }
}

