// lib/mvp/mores/mores_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parrokit/pa_router.dart';
import 'package:parrokit/provider/iap_provider.dart';
import '../../utils/send_mail.dart';
import 'package:parrokit/dev/clip_seed.dart';
import 'package:parrokit/config/pa_config.dart';
import 'package:parrokit/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/show_toast.dart';
import '../../services/backup_service.dart';
import 'index.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {

  @override
  Widget build(BuildContext context) {
    final iap = context.watch<IapProvider>();

    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const SizedBox(height: 20),
            SectionTitle('플레이어'),
            const SizedBox(height: 10),
            CardContainer(
              child: Column(
                children: [
                  SwitchTile(
                    icon: Icons.repeat,
                    title: '구간 재생',
                    value: PaConfig.segmentLoop,
                    onChanged: (v) async {
                      setState(() => PaConfig.segmentLoop = v);
                      await PaConfig.saveToPrefs();
                    },
                  ),
                  const HairlineDivider(),
                  SwitchTile(
                    icon: Icons.loop,
                    title: '반복 재생',
                    value: PaConfig.repeatAll,
                    onChanged: (v) async {
                      setState(() => PaConfig.repeatAll = v);
                      await PaConfig.saveToPrefs();
                    },
                  ),
                  const HairlineDivider(),
                  SwitchTile(
                    icon: Icons.subtitles_outlined,
                    title: '자막 표시',
                    value: PaConfig.showSubtitles,
                    onChanged: (v) async {
                      setState(() => PaConfig.showSubtitles = v);
                      await PaConfig.saveToPrefs();
                    },
                  ),
                  const HairlineDivider(),
                  DropdownTile<double>(
                    icon: Icons.speed_outlined,
                    title: '기본 재생 속도',
                    value: PaConfig.defaultPlaybackRate,
                    display: (v) => '${v.toStringAsFixed(2)}x',
                    items: const [0.75, 1.0, 1.25, 1.5, 2.0],
                    onChanged: (v) async {
                      setState(() => PaConfig.defaultPlaybackRate = v);
                      await PaConfig.saveToPrefs();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle('쇼츠'),
            const SizedBox(height: 10),
            CardContainer(
              child: Column(
                children: [
                  SwitchTile(
                    icon: Icons.play_circle_outline,
                    title: '자동 넘기기',
                    value: PaConfig.autoNext,
                    onChanged: (v) async {
                      setState(() => PaConfig.autoNext = v);
                      await PaConfig.saveToPrefs();
                    },
                  ),
                  const HairlineDivider(),
                  SwitchTile(
                    icon: Icons.subtitles_outlined,
                    title: '자막 표시',
                    value: PaConfig.shortsShowSubtitles,
                    onChanged: (v) async {
                      setState(() => PaConfig.shortsShowSubtitles = v);
                      await PaConfig.saveToPrefs();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle('앱'),
            const SizedBox(height: 10),
            CardContainer(
              child: Column(
                children: [
                  ThemeTile(
                    value: context.watch<ThemeProvider>().themeMode,
                    onChanged: (mode) {
                      context.read<ThemeProvider>().setTheme(mode);
                    },
                  ),
                ],
              ),
            ),
            // MoreScreen build() 내 ListView children에 추가
            const SizedBox(height: 20),
            SectionTitle('결제'),
            const SizedBox(height: 10),
            // ... MoreScreen build() 내부의 결제 카드 부분
            CardContainer(
              child: Column(
                children: [
                  NavTile(
                    icon: Icons.add_shopping_cart_rounded,
                    title: '광고 제거',
                    showArrow: false,
                    trailing: Builder(
                      builder: (context) {
                        final iap = context.watch<IapProvider>();

                        // ✅ 1) 이미 프리미엄이면 '구매 완료' 비활성 버튼 노출
                        if (iap.isPremium) {
                          return FilledButton.icon(
                            onPressed: null, // 비활성
                            label: const Text('구매 완료'),
                            style: FilledButton.styleFrom(
                              disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          );
                        }

                        // ✅ 2) 아직 미구매면 결제 버튼
                        return FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final iap = context.read<IapProvider>();

                            if (iap.loading) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('결제 정보를 불러오는 중입니다… 잠시만요.')),
                              );
                              return;
                            }
                            if (!iap.available) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('스토어에 연결할 수 없습니다.')),
                              );
                              return;
                            }
                            if (iap.removeAdsProduct == null) {
                              await iap.init(); // 재조회
                              if (iap.removeAdsProduct == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('상품 정보를 찾을 수 없습니다.')),
                                );
                                return;
                              }
                            }

                            // 결제 다이얼로그
                            showPremiumDialog(
                              context,
                              price: iap.removeAdsProduct!.price,
                              onBuy: () => context.read<IapProvider>().buyRemoveAds(),
                              onRestore: () => context.read<IapProvider>().restorePurchases(),
                            );
                          },
                          child: Text(context.watch<IapProvider>().removeAdsProduct?.price ?? 'US\$0.99'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle('백업'),
            const SizedBox(height: 10),
            CardContainer(
              child: Column(
                children: [
                  NavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: '불러오기',
                    onTap: () async => await BackupService.instance.restoreBackup(),

                  ),
                  const HairlineDivider(),
                  NavTile(
                    icon: Icons.mail_outline,
                    title: '저장하기',
                    onTap: () async => await BackupService.instance.createBackup(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle('정보'),
            const SizedBox(height: 10),
            CardContainer(
              child: Column(
                children: [
                  NavTile(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    subtitle: '버전 1.0.0',
                    onTap: () {},
                    showArrow: false,
                  ),
                  const HairlineDivider(),
                  NavTile(
                    icon: Icons.help_outline,
                    title: '도움말',
                    onTap: () => context.go(PaRoutes.onboardingPath),
                  ),
                  const HairlineDivider(),
                  NavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보 처리방침',
                    onTap: () => showToast(context, '웹뷰/문서 열기'),
                  ),
                  const HairlineDivider(),
                  NavTile(
                    icon: Icons.mail_outline,
                    title: '문의/피드백',
                    subtitle: '팀에게 메일 보내기',
                    onTap: () => sendEmail(context),
                  ),
                ],
              ),
            ),

            SectionTitle('데모'),
            const SizedBox(height: 10),
            CardContainer(
              child: Column(
                children: [
                  NavTile(
                    icon: Icons.cloud_upload_outlined,
                    title: '데모 시드 넣기 (6개)',
                    subtitle: 'test용',
                    onTap: () async {
                      final ok = await runSeedFromFilePickerTmp(context);
                      showToast(context, (ok ? '시드 완료!' : '시드 실패 (파일 6개 선택 필요)'));
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

Future<void> showPremiumDialog(
    BuildContext context, {
      String price = 'US\$0.99',
      VoidCallback? onBuy,       // 결제 시작 콜백
      VoidCallback? onRestore,   // (선택) 복원 콜백
    }) {
  return showDialog(

  context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final tt = Theme.of(ctx).textTheme;
      final buttonTextStyle = tt.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      );
      const buttonHeight = 48.0;
      const buttonPadding = EdgeInsets.symmetric(vertical: 4);

      return AlertDialog(
        // 사각 느낌 (적당히 각진)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: cs.surface,
        title: Text(
          '프리미엄 (광고 제거)',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 간단 설명: 어디서 광고가 나오는지
            Text(
              '광고 노출 위치',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _Bullet(text: '쇼츠: 다음 영상으로 넘길 때 주기적으로 전면 광고'),
            _Bullet(text: '프리미엄 구입 시 모든 광고가 비활성화됩니다'),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(buttonHeight),
                  padding: buttonPadding,
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: cs.outlineVariant),
                  textStyle: buttonTextStyle,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(); // 모달 닫고
                  onBuy?.call();           // 결제 시작
                },
                child: Text('$price 결제하기'),
              ),
            ),

// 복원 버튼
            if (onRestore != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(buttonHeight),
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: cs.outlineVariant),
                    foregroundColor: cs.onSurface,
                    textStyle: buttonTextStyle,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onRestore.call();
                  },
                  child: const Text('구매 내역 복원'),
                ),
              ),
            ],

// 닫기 버튼
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(buttonHeight),
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: cs.primary,
                  textStyle: buttonTextStyle,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('나중에'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(.9),
              height: 1.35,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(.9),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}