import 'dart:async';
import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// `AccordionSection` is one section within the `Accordion` widget.
/// Usage:
/// ```dart
/// Accordion(
/// 	maxOpenSections: 1,
/// 	leftIcon: Icon(Icons.audiotrack, color: Colors.white),
/// 	children: [
/// 		AccordionSection(
/// 			isOpen: true,
/// 			header: Text('Introduction', style: TextStyle(color: Colors.white, fontSize: 20)),
/// 			content: Icon(Icons.airplanemode_active, size: 200),
/// 		),
/// 		AccordionSection(
/// 			isOpen: true,
/// 			header: Text('About Us', style: TextStyle(color: Colors.white, fontSize: 20)),
/// 			content: Icon(Icons.airline_seat_flat, size: 120),
/// 		),
/// 		AccordionSection(
/// 			isOpen: true,
/// 			header: Text('Company Info', style: TextStyle(color: Colors.white, fontSize: 20)),
/// 			content: Icon(Icons.airplay, size: 70, color: Colors.green[200]),
/// 		),
/// 	],
/// )
/// ```
class AccordionSection extends StatelessWidget with CommonParams {
  final SectionController sectionCtrl = SectionController();
  late final UniqueKey uniqueKey;
  late final int index;
  final bool isOpen;
  final Key? previuosKey;

  /// Callback function for when a section opens
  final Function? onOpenSection;
  final bool? selectedContainerColor;

  /// Callback functionf or when a section closes
  final Function? onCloseSection;

  /// The text to be displayed in the header
  final Widget header;

  /// The widget to be displayed as the content of the section when open
  final Widget content;

  AccordionSection({
    Key? key,
    this.previuosKey,
    this.index = 0,
    this.isOpen = false,
    required this.header,
    required this.content,
    Color? headerBackgroundColor,
    Color? headerBackgroundColorOpened,
    double? headerBorderRadius,
    EdgeInsets? headerPadding,
    Widget? leftIcon,
    Widget? rightIcon,
    bool? flipRightIconIfOpen = true,
    Color? contentBackgroundColor,
    Color? contentBorderColor,
    double? contentBorderWidth,
    double? contentBorderRadius,
    double? contentHorizontalPadding,
    double? contentVerticalPadding,
    double? paddingBetweenOpenSections,
    double? paddingBetweenClosedSections,
    ScrollIntoViewOfItems? scrollIntoViewOfItems,
    SectionHapticFeedback? sectionOpeningHapticFeedback,
    SectionHapticFeedback? sectionClosingHapticFeedback,
    String? accordionId,
    this.onOpenSection,
    this.onCloseSection,
    this.selectedContainerColor = false,
  }) : super(key: key) {
    final listCtrl = Get.put(ListController(), tag: accordionId);
    uniqueKey = listCtrl.keys.elementAt(index);
    sectionCtrl.isSectionOpen.value = listCtrl.openSections.contains(uniqueKey);
    sectionCtrl.isPreviusSectionOpen.value =
        listCtrl.openSections.contains(previuosKey);

    this.headerBackgroundColor = headerBackgroundColor;
    this.headerBackgroundColorOpened =
        headerBackgroundColorOpened ?? headerBackgroundColor;
    this.headerBorderRadius = headerBorderRadius;
    this.headerPadding = headerPadding;
    this.leftIcon = leftIcon;
    this.rightIcon = rightIcon;
    this.flipRightIconIfOpen?.value = flipRightIconIfOpen ?? true;
    this.contentBackgroundColor = contentBackgroundColor;
    this.contentBorderColor = contentBorderColor;
    this.contentBorderWidth = contentBorderWidth ?? 1;
    this.contentBorderRadius = contentBorderRadius ?? 10;
    this.contentHorizontalPadding = contentHorizontalPadding ?? 10;
    this.contentVerticalPadding = contentVerticalPadding ?? 10;
    this.paddingBetweenOpenSections = paddingBetweenOpenSections ?? 10;
    this.paddingBetweenClosedSections = paddingBetweenClosedSections ?? 10;
    this.scrollIntoViewOfItems =
        scrollIntoViewOfItems ?? ScrollIntoViewOfItems.fast;
    this.sectionOpeningHapticFeedback = sectionOpeningHapticFeedback;
    this.sectionClosingHapticFeedback = sectionClosingHapticFeedback;
    this.accordionId = accordionId;

    listCtrl.controllerIsOpen.stream.asBroadcastStream().listen((data) {
      sectionCtrl.isSectionOpen.value = listCtrl.openSections.contains(key);
      sectionCtrl.isPreviusSectionOpen.value =
          listCtrl.openSections.contains(previuosKey);
    });
  }

  /// getter to flip the widget vertically (Icon by default)
  /// on the right of this section header to visually indicate
  /// if this section is open or closed
  get _flipQuarterTurns =>
      flipRightIconIfOpen?.value == true ? (_isOpen ? 2 : 0) : 0;

  get _isPreviusOpen {
    final previusOpen = sectionCtrl.isPreviusSectionOpen.value;

    return previusOpen;
  }

  /// getter indication the open or closed status of this section

  get _isOpen {
    final listCtrl = Get.put(ListController(), tag: accordionId);
    final open = sectionCtrl.isSectionOpen.value;

    Timer(
      sectionCtrl.firstRun
          ? (listCtrl.initialOpeningSequenceDelay + min(index * 200, 1000))
              .milliseconds
          : 0.seconds,
      () {
        if (Accordion.sectionAnimation) {
          sectionCtrl.controller
              .fling(velocity: open ? 1 : -1, springDescription: springFast);
        } else {
          sectionCtrl.controller.value = open ? 1 : 0;
        }
        sectionCtrl.firstRun = false;
      },
    );

    return open;
  }

  /// play haptic feedback when opening/closing sections
  _playHapticFeedback(bool opening) {
    final feedback =
        opening ? sectionOpeningHapticFeedback : sectionClosingHapticFeedback;

    switch (feedback) {
      case SectionHapticFeedback.light:
        HapticFeedback.lightImpact();
        break;
      case SectionHapticFeedback.medium:
        HapticFeedback.mediumImpact();
        break;
      case SectionHapticFeedback.heavy:
        HapticFeedback.heavyImpact();
        break;
      case SectionHapticFeedback.selection:
        HapticFeedback.selectionClick();
        break;
      case SectionHapticFeedback.vibrate:
        HapticFeedback.vibrate();
        break;
      default:
    }
  }

  @override
  build(context) {
    final borderRadius = headerBorderRadius ?? 10;
    final listCtrl = Get.put(ListController(), tag: accordionId);

    return Obx(
      () => Column(
        key: uniqueKey,
        children: [
          Container(
            color: (index > 0) ? Colors.white : Color(0XFF142550),

            // color: (index > 0 && _isPreviusOpen)
            //     ? Color(0XFFFF4158)
            //     : Color(0XFF142550),
            // transform: Matrix4.translationValues(0.0, -45.0 * (index + 1), 0.0),
            child: InkWell(
              onTap: () {
                final listCtrl = Get.put(ListController(), tag: accordionId);
                listCtrl.updateSections(uniqueKey);
                _playHapticFeedback(_isOpen);

                if (_isOpen &&
                    scrollIntoViewOfItems != ScrollIntoViewOfItems.none &&
                    listCtrl.controller.hasClients) {
                  Timer(
                    250.milliseconds,
                    () {
                      listCtrl.controller.cancelAllHighlights();
                      listCtrl.controller.scrollToIndex(index,
                          preferPosition: AutoScrollPosition.middle,
                          duration: (scrollIntoViewOfItems ==
                                      ScrollIntoViewOfItems.fast
                                  ? .5
                                  : 1)
                              .seconds);
                    },
                  );
                }

                if (_isOpen) {
                  if (onCloseSection != null) onCloseSection!.call();
                } else {
                  if (onOpenSection != null) onOpenSection!.call();
                }
              },
              child: AnimatedContainer(
                duration: Accordion.sectionAnimation
                    ? 150.milliseconds
                    : 0.milliseconds,
                curve: Curves.easeOut,
                alignment: Alignment.center,
                padding: headerPadding,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 10, // changes position of shadow
                    ),
                  ],
                  color: (_isOpen
                          ? headerBackgroundColorOpened
                          : headerBackgroundColor) ??
                      Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                    bottom: Radius.circular(_isOpen ? 0 : 0),
                  ),
                ),
                child: Row(
                  children: [
                    if (leftIcon != null) leftIcon!,
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: leftIcon == null ? 0 : 15),
                        child: header,
                      ),
                    ),
                    if (rightIcon != null)
                      RotatedBox(
                          quarterTurns: _flipQuarterTurns, child: rightIcon!),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: _isOpen ? 0 : 0),
            child: SizeTransition(
              sizeFactor: sectionCtrl.controller,
              child: ScaleTransition(
                scale: Accordion.sectionScaleAnimation
                    ? sectionCtrl.controller
                    : const AlwaysStoppedAnimation(1.0),
                child: Center(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color:
                          contentBorderColor ?? Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        contentBorderWidth ?? 1,
                        0,
                        contentBorderWidth ?? 1,
                        contentBorderWidth ?? 1,
                      ),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(0))),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: _isOpen
                                  ? headerBackgroundColorOpened
                                  : headerBackgroundColor,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(0))),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentHorizontalPadding!,
                              vertical: contentVerticalPadding!,
                            ),
                            child: Center(
                              child: content,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
