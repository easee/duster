import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class NoUnsafeFirst extends AnalysisRule
{
	static const LintCode code = LintCode(
		'no_unsafe_first',
		'Iterable.first throws when the iterable is empty.',
		correctionMessage: 'Use firstOrNull and handle the empty case.',
		severity: DiagnosticSeverity.ERROR,
	);

	NoUnsafeFirst()
		: super(
			name: 'no_unsafe_first',
			description: 'Disallows unsafe reads of Iterable.first.',
		);

	@override
	LintCode get diagnosticCode => code;

	@override
	void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context)
	{
		final visitor = _Visitor(this, context);
		registry.addPropertyAccess(this, visitor);
		registry.addPrefixedIdentifier(this, visitor);
	}
}

class _Visitor extends SimpleAstVisitor<void>
{
	_Visitor(this.rule, this.context);

	final NoUnsafeFirst rule;
	final RuleContext context;

	@override
	void visitPropertyAccess(PropertyAccess node)
	{
		_check(node.propertyName, node.realTarget.staticType);
	}

	@override
	void visitPrefixedIdentifier(PrefixedIdentifier node)
	{
		_check(node.identifier, node.prefix.staticType);
	}

	void _check(SimpleIdentifier name, DartType? targetType)
	{
		if (name.name != 'first' || !name.inGetterContext() || targetType == null) return;

		final nonNullableTargetType = context.typeSystem.promoteToNonNull(targetType);
		final iterableType = context.typeProvider.iterableType(context.typeProvider.dynamicType);
		if (context.typeSystem.isSubtypeOf(nonNullableTargetType, iterableType))
			rule.reportAtNode(name);
	}
}
