import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:textile/config/router/router.dart';
import 'package:textile/constants/app_constants.dart';
import 'package:textile/models/data_model.dart';
import 'package:textile/models/order_design_model.dart';
import 'package:textile/screens/widgets/dropdown.dart';
import 'package:textile/utils/extensions/string_extension.dart';
import 'package:textile/utils/helpers/utils.dart';
import 'package:textile/utils/services/rest_api.dart';

class OrderRowStatusDialog extends StatefulWidget {
  const OrderRowStatusDialog({Key? key, required this.row}) : super(key: key);
  final RowModel row;

  @override
  State<OrderRowStatusDialog> createState() => _OrderRowStatusDialogState();
}

class _OrderRowStatusDialogState extends State<OrderRowStatusDialog> {
  final _future = Services.getOrderRowStatusList();
  String? _status;

  @override
  void initState() {
    super.initState();
    _status = widget.row.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: FutureBuilder<Data<List<String>>>(
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("Please wait..."),
            );
          }
          if (snapshot.data!.statusCode == 200 &&
              snapshot.data!.data != null &&
              snapshot.data!.data!.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Dropdown<String>(
                  label: "Status",
                  value: _status,
                  items: snapshot.data!.data!.map((status) {
                    return DropdownMenuItem<String>(
                      child: Text(status.toStudlyCase()),
                      value: status,
                    );
                  }).toList(),
                  onChanged: (value) {
                    _status = value!;
                    setState(() {});
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: TextButton(
                    onPressed: _changeStatus,
                    child: const Text("Save"),
                  ),
                )
              ],
            );
          } else {
            return const Text("Status not found");
          }
        },
        future: _future,
      ),
    );
  }

  void _changeStatus() async {
    final payload = {
      "order_id": widget.row.orderId?.toString(),
      "row_id": widget.row.id?.toString(),
      "type": kUserdata?.type,
      "status": _status,
      "date": DateFormat("yyyy-MM-dd").format(DateTime.now()),
      "remark": "Remark from API",
    };
    final response = await Services.changeOrderRowStatus(payload);
    Utils.showToast(response.message ?? "");
    if (response.statusCode == 200) {
      Navigate.close(true);
      return;
    }
    Navigate.close();
  }
}
