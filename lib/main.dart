import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/no_force_unwraps_lint.dart';
import 'src/no_unsafe_first_lint.dart';
import 'src/curlies_on_new_line_lint.dart';
import 'src/tabs_no_spaces_lint.dart';

/// Required top-level entrypoint. The Dart Analysis Server looks for this
/// exact variable name when it loads `lib/main.dart`.
final plugin = EaseeLints();

class EaseeLints extends Plugin
{
	@override
	String get name => 'duster';

	@override
	void register(PluginRegistry registry)
	{
		// Registered as *lint* rules, so they stay disabled by default and
		// must be turned on per-project in analysis_options.yaml, e.g.:
		//
		//   plugins:
		//     duster:
		//       diagnostics:
		//         no_force_unwraps: true
		//         no_unsafe_first: true
		//         curly_brace_new_line: true
		//         tabs_no_spaces: true
		//
		// (Mirrors the old custom_lint config: `custom_lint: rules: - no_force_unwraps: true`.)
		registry.registerLintRule(NoForceUnwraps());
		registry.registerLintRule(NoUnsafeFirst());
		registry.registerLintRule(CurlyNewLine());
		registry.registerLintRule(TabsNoSpaces());
	}
}
