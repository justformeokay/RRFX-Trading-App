import 'dart:ui';
import 'package:cupertino_rrect/cupertino_rrect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/datetime_controller.dart';

class DefaultScaffold extends StatefulWidget {
  const DefaultScaffold({super.key, required this.children, this.onPressed, this.withBottomMenu, this.title});
  final List<Widget> children;
  final VoidCallback? onPressed;
  final bool? withBottomMenu;
  final String? title;

  @override
  State<DefaultScaffold> createState() => _DefaultScaffoldState();
}

class _DefaultScaffoldState extends State<DefaultScaffold> {
  RxBool acceptedStatement = false.obs;
  RxString selectedOption = "".obs;
  final DateTimeController dateTimeController = Get.put(DateTimeController());

  final ScrollController _scrollController = ScrollController();
  bool _showBottomContainer = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll >= maxScroll - 50) {
      if (!_showBottomContainer) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _showBottomContainer = true;
            });
          }
        });
      }
    } else {
      if (_showBottomContainer) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _showBottomContainer = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Stack(
          children: [
            // SCROLLABLE CONTENT
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 100.0, bottom: widget.withBottomMenu == true ? 170.0 : 20.0), // Bottom extra space
                child: Column(
                  children: widget.children,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(// Optional: rounded corners for the blurred area
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Adjust sigmaX and sigmaY for blur intensity
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.grey.withOpacity(0.2),
                            Colors.grey.withOpacity(0.7)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // HEADER BAR
            Positioned(
              top: 46,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0, left: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black26, width: 0.3),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.back, color: Colors.black54),
                          Text("Back", style: Theme.of(context).textTheme.bodyMedium)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.title ?? "", style: Theme.of(context).textTheme.titleSmall)
                  )
                ],
              ),
            ),

            // ANIMATED BOTTOM CONTAINER
            widget.withBottomMenu == true ? Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                opacity: _showBottomContainer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                child: AnimatedSlide(
                  offset: _showBottomContainer ? Offset.zero : const Offset(0, 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: ShapeDecoration(
                            color: Colors.white, // Background color of the new container
                            shadows: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            shape: CupertinoRectangleBorder(
                              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Text('Pernyataan Menerima / Tidak', style: Theme.of(context).textTheme.bodyLarge),
                                SizedBox(
                                  width: size.width / 1.3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Obx(() => RadioListTile(value: "ya", groupValue: selectedOption.value, onChanged: (value) => selectedOption.value = value!, title: const Text('Ya'), contentPadding: EdgeInsets.zero))),
                                      Expanded(child: Obx(() => RadioListTile(value: "tidak", groupValue: selectedOption.value, onChanged: (value) => selectedOption.value = value!, title: const Text('Tidak'), contentPadding: EdgeInsets.zero)))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Obx(
                                          () => Text(
                                            DateFormat('EEEE, dd MMMM yyyy').add_jms().format(dateTimeController.currentDateTime),
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Icon(CupertinoIcons.clock, color: Colors.black38)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Obx(
                              () => AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                secondCurve: Curves.easeInExpo,
                                crossFadeState: selectedOption.value == "" ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                firstChild: const SizedBox(),
                                secondChild: CupertinoButton(
                                  onPressed: widget.onPressed, // No need for selectedOption.value == "" ? null : widget.onPressed here
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Text("Submit", style: Theme.of(context).textTheme.bodyMedium),
                                        const SizedBox(width: 5.0),
                                        const Icon(CupertinoIcons.arrow_right, color: Colors.black45),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

