import 'package:flutter/material.dart';
import 'core/core.dart';
import 'admin_home_page.dart';
import 'signalements.dart';
import 'notifications.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int myCurrentIndex = 0;

  final List<Widget> _pages = const [
    AdminHomePage(),
    SignalementsPage(),
    NotificationsPage(),
  ];

  bool _hasUnreadSignalements() {
    return false ;
  }

  Widget _buildIconWithDot(IconData icon, bool showDot) {
    final r = _Responsive(context);
    
    return Stack(
      children: [
        Icon(icon, size: r.scale(24)),
        if (showDot)
          Positioned(
            right: r.scale(2),
            top: r.scale(2),
            child: Container(
              width: r.scale(6),
              height: r.scale(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(r.scale(3)),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _pages[myCurrentIndex],
          ),

          Positioned(
            left: r.hp(20),
            right: r.hp(20),
            bottom: r.vp(20),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewInsets: EdgeInsets.zero,
                padding: EdgeInsets.zero,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: r.scale(20),
                      spreadRadius: r.scale(2),
                      offset: Offset(0, r.scale(8)),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.scale(30)),
                  child: Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: BottomNavigationBar(
                        currentIndex: myCurrentIndex,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedItemColor: const Color(0xFFA8C88A),
                        unselectedItemColor: AppColors.navInactive,
                        type: BottomNavigationBarType.fixed,
                        
                        selectedFontSize: r.fontSize(10),
                        unselectedFontSize: r.fontSize(10),
                        selectedLabelStyle: TextStyle(fontSize: r.fontSize(10)),
                        unselectedLabelStyle: TextStyle(fontSize: r.fontSize(10)),
                        
                        iconSize: r.scale(24),
                        
                        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
                        
                        onTap: (index) {
                          setState(() {
                            myCurrentIndex = index;
                          });
                        },

                        items: [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.space_dashboard_outlined),
                            label: 'Tableau de bord',
                          ),
                          BottomNavigationBarItem(
                            icon: _buildIconWithDot(Icons.warning_amber_rounded, _hasUnreadSignalements()), 
                            label: 'Signalements',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.notifications_none_rounded),
                            label: 'Notifications',
                          ),
                        ],
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

class _Responsive {
  _Responsive(BuildContext context)
      : _size = MediaQuery.of(context).size,
        _textScale = MediaQuery.of(context).textScaler;

  final Size _size;
  final TextScaler _textScale;

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  double get _widthRatio => (_size.width / _baseWidth).clamp(0.8, 1.2);
  double get _heightRatio => (_size.height / _baseHeight).clamp(0.8, 1.2);

  double scale(double value) =>
      value * ((_widthRatio + _heightRatio) / 2);

  double hp(double value) => value * _widthRatio;

  double vp(double value) => value * _heightRatio;

  double fontSize(double value) =>
      _textScale.scale(value * _widthRatio);
}
