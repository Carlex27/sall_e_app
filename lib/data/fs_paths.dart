class FsPaths {
  static String vehicle(String vehicleId) => 'vehicles/$vehicleId';
  static String device(String deviceId) => 'devices/$deviceId';
  static String deviceStatus(String deviceId) => 'devices/$deviceId/status/current';
  static String deviceLiveLocation(String deviceId) => 'devices/$deviceId/liveLocation/current';
}
