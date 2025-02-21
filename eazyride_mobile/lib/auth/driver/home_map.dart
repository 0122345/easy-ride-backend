import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:eazyride_mobile/licence/privacy.dart';
import 'package:eazyride_mobile/components/drawer.dart';
import 'package:eazyride_mobile/home/search_screen.dart';
import 'package:eazyride_mobile/notifications/home.dart';
import 'package:eazyride_mobile/transport/request/passenger/ride_request.dart';

class HomeDriverWrapper extends StatelessWidget {
  final String userId;
  final String token;
  final String email;

  const HomeDriverWrapper({
    required this.userId,
    required this.token,
    required this.email,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyDrawerController>(
      builder: (_) => ZoomDrawer(
        controller: _.zoomDrawerController,
        menuScreen: const MenuScreen(),
        mainScreen: const HomeDriver(),
        borderRadius: 24.0,
        showShadow: true,
        angle: 12.0,
        drawerShadowsBackgroundColor: Colors.grey[300]!,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        openCurve: Curves.fastOutSlowIn,
        menuBackgroundColor: Colors.white,
      ),
    );
  }
}

class HomeDriver extends StatefulWidget {
  const HomeDriver({super.key});

  @override
  State<HomeDriver> createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> with WidgetsBindingObserver {
  late final MyDrawerController drawerController;
  GoogleMapController? mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  final bool _isMapReady = false;
  int _selectedIndex = 0;

  final List<IconData> _iconList = const [
    Icons.home,
    Icons.favorite,
    Icons.report,
    Icons.local_offer,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(
        'pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw');
    _initializeLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      mapController?.setMapStyle(null);
    }
  }

  Future<void> _initializeApp() async {
    Get.put(MyDrawerController());
    drawerController = Get.find<MyDrawerController>();
    await _requestPermissions();
    await _initLocationServices();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.location.request();
  }

  Future<void> _initializeLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to get location');
    }
  }

  void _onMapCreated(MapboxMap controller) {
    mapboxMap = controller;
    _addCurrentLocationMarker();
  }

  Future<void> _addCurrentLocationMarker() async {
    if (_currentPosition == null || mapboxMap == null) return;

    final point = {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          _currentPosition!.longitude,
          _currentPosition!.latitude
        ],
      },
      "properties": {},
    };

    await mapboxMap!.style.addSource(
      GeoJsonSource(
        id: "current-location",
        data: jsonEncode(point),
      ),
    );

    await mapboxMap!.style.addLayer(
      CircleLayer(
        id: "current-location-layer",
        sourceId: "current-location",
        circleColor: Colors.blue.value,
        circleRadius: 8.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            resourceOptions: ResourceOptions(
              accessToken: MapboxOptions.accessToken,
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: [
                  _currentPosition?.longitude ?? 30.0444,
                  _currentPosition?.latitude ?? -1.9441,
                ],
              ),
              zoom: 15.0,
            ),
            onMapCreated: _onMapCreated,
          ),
          if (_isMapReady) ...[
            _buildTopBar(context),
            _buildBottomSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomBar(context),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMenuButton(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: HexColor("#40D2B2"),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: GetBuilder<MyDrawerController>(
        builder: (controller) => IconButton(
          onPressed: controller.toggleDrawer,
          icon:
              Icon(controller.isDrawerOpen ? Icons.close_rounded : Icons.menu),
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          Icons.search,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => LocationSearchScreen())),
        ),
        const SizedBox(width: 16),
        _buildIconButton(
          Icons.notifications,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HomeNotifications())),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: HexColor("#40D2B2"),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: RideState(),
                    child: const Homepage(),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 255, 255),
              ),
              child: const Text('Request Ride'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return AnimatedBottomNavigationBar(
      icons: _iconList,
      activeIndex: _selectedIndex,
      gapLocation: GapLocation.end,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: _handleNavigation,
      activeColor: const Color.fromARGB(255, 7, 255, 255),
      inactiveColor: const Color.fromARGB(255, 112, 115, 139),
      backgroundColor: HexColor("#40D2B2"),
      iconSize: 30.0,
    );
  }

  void _handleNavigation(int index) {
    if (!mounted) return;

    final routes = [
      const HomeDriver(),
      const Homepage(),
      PrivacyPolicyScreen(),
      const HomeNotifications(),
    ];

    if (index >= 0 && index < routes.length) {
      setState(() => _selectedIndex = index);
      Navigator.push(context, MaterialPageRoute(builder: (_) => routes[index]));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapController?.dispose();
    super.dispose();
  }
}
