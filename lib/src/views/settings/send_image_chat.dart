import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';

class SendImageChat extends StatefulWidget {
  const SendImageChat({super.key, this.imageURL});
  final String? imageURL;

  @override
  State<SendImageChat> createState() => _SendImageChatState();
}

class _SendImageChatState extends State<SendImageChat> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          title: "Kirim Gambar",
          autoImplyLeading: true
        ),
        body: Column(
          children: [
            Expanded(
              child: Image.file(File(widget.imageURL ?? ''), fit: BoxFit.cover)
            ),
            _MessageBar()
          ],
        ),
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar();

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: 4,
                  minLines: 1,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _submitMessage(),
                tooltip: "Send Message",
                icon: const Icon(Bootstrap.send),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UtilitiesController utilitiesController = Get.find();

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    utilitiesController.sendMessage().then((result){
      if(!result){

      }
    });
  }
}