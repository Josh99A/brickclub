part of 'brickclub_app.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.background],
            ),
          ),
          child: Center(
            child: Container(
              width: 248,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
              decoration: BoxDecoration(
                color: AppColors.panel,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .18),
                    blurRadius: 36,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BrandLockup(height: 128),
                  SizedBox(height: 12),
                  Text(
                    'Property-backed ownership',
                    textAlign: TextAlign.center,
                    style: AppText.bodyLarge,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 96,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: AppColors.track,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

