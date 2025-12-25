// ============================================================================
// lib/features/recom/presentation/widgets/top_k_picker.dart
// ============================================================================
//
// [역할]
// 추천 개수(TopK) 선택 피커.
// Cupertino 스타일 휠 피커.
//
// [레이어]
// Presentation Layer > Widgets
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// TopK 피커 표시.
void showTopKPicker({
  required BuildContext context,
  required int initialValue,
  required void Function(int value) onSelected,
}) {
  final initialIndex = initialValue.clamp(1, 20) - 1;
  int tempIndex = initialIndex;

  showCupertinoModalPopup(
    context: context,
    builder: (sheetContext) {
      return Container(
        height: 260,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // 헤더
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('취소'),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      onSelected(tempIndex + 1);
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),

            // 피커
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex,
                ),
                itemExtent: 36,
                onSelectedItemChanged: (index) => tempIndex = index,
                children: [
                  for (var i = 1; i <= 20; i++) Center(child: Text('$i개')),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
