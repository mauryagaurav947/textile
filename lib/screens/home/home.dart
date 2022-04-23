import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:textile/config/router/router.dart';
import 'package:textile/models/models.dart';
import 'package:textile/screens/home/widgets/order_status_dialog.dart';
import 'package:textile/screens/order_detail_page/order_detail_page.dart';
import 'package:textile/screens/widgets/circular_progress_indicator.dart';
import 'package:textile/utils/palette.dart';
import 'package:textile/utils/services/rest_api.dart';
import 'package:textile/utils/extensions/string_extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          )
        ],
      ),
      drawer: const Drawer(),
      body: FutureBuilder<Data<List<OrderModel>>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppProgressIndicator(color: Palette.primaryColor);
          }
          if (snapshot.hasData &&
              snapshot.data!.statusCode == 200 &&
              snapshot.data!.data!.isNotEmpty) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              separatorBuilder: (_, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final order = snapshot.data!.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  elevation: 10,
                  shadowColor: Palette.primaryColor.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    onTap: () => Navigate.to(OrderDetailPage(order: order)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _changeStatus(order),
                          child: Text(
                            "Order No.: ${order.orderNumber}",
                            style: TextStyle(
                              color: Palette.primaryColor.shade700,
                            ),
                          ),
                        ),
                        Text(
                          "${order.status}".toStudlyCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Palette.blackColor.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "Last updated: ${DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.tryParse("${order.modified}") ?? DateTime.now())}",
                      style: TextStyle(
                        color: Palette.primaryColor.shade300,
                      ),
                    ),
                  ),
                );
              },
              itemCount: snapshot.data!.data!.length,
            );
          } else {
            return const Center(
              child: Text("Data not found"),
            );
          }
        },
        future: Services.getActiveOrders(),
      ),
    );
  }

  /// Method to show dialog to change status
  void _changeStatus(OrderModel order) async {
    final data = await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ChangeStatusDialog(order: order),
    );
    if (data is bool) {
      setState(() {});
    }
  }
}
