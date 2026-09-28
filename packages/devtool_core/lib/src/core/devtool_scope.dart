/// The availability boundary for the toolkit.
///
/// * [disabled]  — toolkit is a complete no-op (release default).
/// * [debugOnly] — active only in debug builds (`kDebugMode`).
/// * [internal]  — active in debug builds or when `DEVTOOL_INTERNAL` is defined.
/// * [enabled]   — always active (dangerous, for targeted diagnosis only).
enum DevtoolScope { disabled, debugOnly, internal, enabled }
