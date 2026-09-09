import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoForceUnwraps extends AnalysisRule
{
	static const LintCode code = LintCode(
		'no_force_unwraps',
		'💥 Crash ops are not allowed. Unwrap the value or provide a fallback.',
		correctionMessage: 'Replace ! usage with nullsafe code',
		severity: DiagnosticSeverity.ERROR,
	);

	NoForceUnwraps()
		: super(
			name: 'no_force_unwraps',
			description: 'Disallows the null-check (!) operator.',
		);

	@override
	LintCode get diagnosticCode => code;

	@override
	void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context)
	{
		final visitor = _Visitor(this);
		registry.addPostfixExpression(this, visitor);
	}
}

class _Visitor extends SimpleAstVisitor<void>
{
	final AnalysisRule rule;

	_Visitor(this.rule);

	@override
	void visitPostfixExpression(PostfixExpression node)
	{
		if (node.operator.type == TokenType.BANG)
			rule.reportAtToken(node.operator);
	}
}
