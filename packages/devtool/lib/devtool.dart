/// Aggregated entry point for the `devtool` toolkit.
///
/// Re-exports the safe core. Opt-in dangerous capabilities live in separate
/// packages: `devtool_h5` (H5/JS console) and `devtool_native` (native crash
/// probe). Keep those out of release dependency trees.
library;

export 'package:devtool_core/devtool.dart';
