import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

void sendEmail(BuildContext context) async {
  final Email email = Email(
    subject: '[패로킷 문의]',
    recipients: ['cnsqodla2056@gmail.com'],
    body: '''
안녕하세요, 패로킷입니다.
문의 주셔서 감사합니다. 아래 항목을 작성해주시면 빠르게 확인할 수 있어요:

- 어떤 화면/기능에서 문제가 발생했나요?
- 재현 방법이 있으면 알려주세요:
- 추가하고 싶은 기능이나 개선 아이디어가 있나요?

-------------------
(여기에 문의 내용을 작성해주세요)
''',
    isHTML: false,
  );

  try {
    await FlutterEmailSender.send(email);
  } catch (error) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: cs.surface,
          title: Text(
            '메일 전송이 불가능합니다',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '현재 기기에서 기본 메일 앱을 열 수 없어 앱 내에서 바로 문의를 보낼 수 없어요.\n\n'
                    '불편하시겠지만 아래 주소로 직접 메일을 보내주시면 빠르게 답변드리겠습니다.\n\n'
                    '📧  cnsqodla2056@gmail.com',
                style: tt.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: cs.primary,
                    backgroundColor: cs.primary,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child:  Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tt.bodyMedium?.copyWith(height: 1.4).copyWith(color: cs.surface).color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
