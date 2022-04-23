import 'package:flutter/material.dart';
import 'package:textile/config/router/router.dart';
import 'package:textile/constants/app_constants.dart';
import 'package:textile/models/models.dart';
import 'package:textile/screens/widgets/dropdown.dart';
import 'package:textile/utils/extensions/string_extension.dart';
import 'package:textile/utils/helpers/utils.dart';
import 'package:textile/utils/services/rest_api.dart';

class ChangeStatusDialog extends StatefulWidget {
  const ChangeStatusDialog({Key? key, required this.order}) : super(key: key);
  final OrderModel order;

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog> {
  final _future = Services.getOrderStatusList();
  String? _status;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
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
            return Dropdown<String>(
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
            );
          } else {
            return const Text("Status not found");
          }
        },
        future: _future,
      ),
      actions: [
        TextButton(
          onPressed: _changeStatus,
          child: const Text("Save"),
        )
      ],
    );
  }

  void _changeStatus() async {
    final payload = {
      "id": "1",
      "order_id": widget.order.id?.toString(),
      "type": kUserdata?.type,
      "status": _status,
    };
    final response = await Services.changeOrderStatus(payload);
    Utils.showToast(response.message ?? "");
    if (response.statusCode == 200) {
      Navigate.close(true);
      return;
    }
    Navigate.close();
  }
}