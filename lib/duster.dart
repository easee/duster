import 'package:custom_lint_builder/custom_lint_builder.dart';
// import 'package:duster/src/curlies_on_new_line_lint.dart';
import 'package:duster/src/no_force_unwraps_lint.dart';
// import 'package:duster/src/tabs_no_spaces_lint.dart';

PluginBase createPlugin() => _EaseeLints();

class _EaseeLints extends PluginBase
{
	@override
	List<LintRule> getLintRules(CustomLintConfigs configs)
	{
		// return [NoForceUnwraps(), CurlyNewLine(), TabsNoSpaces()];
		return const [NoForceUnwraps()];
	}
}
