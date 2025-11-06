import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/custom_lint_core.dart' as clc;

class NoForceUnwraps extends DartLintRule
{
	const NoForceUnwraps() : super(code: _code);

	static const _code = clc.LintCode(
		name: "no_force_unwraps",
		problemMessage: "💥 Crash ops are not allowed. Unwrap the value or provide a fallback.",
		errorSeverity: ErrorSeverity.ERROR,
		correctionMessage: "Replace ! usage with nullsafe code",
	);

	@override
	void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context)
	{
		// context.registry.addExpression((node)
		// {
		// 	final token = node.endToken;
		// 	if (token.type == TokenType.BANG)
		// 	{
		// 		reporter.atToken(token,code);
		// 	}
		// });
		context.registry.addPostfixExpression((node)
		{
			if (node.operator.type == TokenType.BANG)
			{
				reporter.atToken(node.operator, code);
			}
		});
	}
}

