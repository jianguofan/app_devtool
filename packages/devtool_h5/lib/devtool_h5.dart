/// H5 debugging capability for `devtool`.
///
/// SECURITY: arbitrary URL + JavaScript execution is a command-injection
/// surface. Only register this capability in internal debug builds; keep this
/// package out of release dependency trees.
library;

export 'src/h5_console_capability.dart' show H5ConsoleCapability, h5ConsoleEntry;
export 'src/h5_console_page.dart' show H5ConsolePage;
export 'src/h5_utils.dart' show parseHeaders, formatJsResult, buildRequest;
