import 'package:flutter/material.dart';
import 'package:invoicemaker/provider/signature_provider.dart';
import 'package:invoicemaker/utils/colors.dart';
import 'package:invoicemaker/utils/null_safety_pixel.dart';
import 'package:invoicemaker/view/widgets/buttons/preview_button.dart';
import 'package:invoicemaker/view/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

class SignatureCaptureScreen extends StatefulWidget {
  const SignatureCaptureScreen({super.key});

  @override
  SignatureCaptureScreenState createState() => SignatureCaptureScreenState();
}

class SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 8,
      penColor: Colors.teal,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(bool didPop) async {
    if (didPop) return true;
    if (_controller.isNotEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: whiteColor,
          title: const Text('Discard changes?'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );

      if (result == true) {
        Navigator.of(context).pop(transparentPixel);
        return true;
      }
      return false;
    }

    Navigator.of(context).pop(transparentPixel);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Signature Capture'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PreviewButton(
                      title: 'Clear',
                      onTap: () {
                        _controller.clear();
                      }),
                  SaveButton(
                    title: 'SAVE',
                    onTap: () async {
                      if (_controller.isNotEmpty) {
                        var signature = await _controller.toPngBytes();
                        if (signature != null) {
                          // ignore: use_build_context_synchronously
                          Provider.of<SignatureProvider>(context, listen: false)
                              .saveSignature(signature);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, signature);
                        } else {
                          // Handle the case where signature conversion failed
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Failed to save signature. Please try again.')),
                          );
                        }
                      } else {
                        // Handle the case where the signature pad is empty
                        Navigator.pop(context, transparentPixel);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
