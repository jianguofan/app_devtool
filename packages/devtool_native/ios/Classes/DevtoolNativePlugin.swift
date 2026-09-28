import Flutter
import UIKit

public class DevtoolNativePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "devtool_native", binaryMessenger: registrar.messenger())
    let instance = DevtoolNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "crash" {
      // Deliberately crash so the stability probe can verify the crash-reporting
      // pipeline.
      fatalError("devtool native crash probe")
    }
    result(FlutterMethodNotImplemented)
  }
}
