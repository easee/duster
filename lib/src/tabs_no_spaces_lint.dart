import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// NOTE: this rule was disabled/commented-out prior to migration and has not
/// been re-tested against the new analysis_server_plugin API. Verify its
/// behavior before enabling it in analysis_options.yaml.
class TabsNoSpaces extends AnalysisRule
{
	static const LintCode code = LintCode(
		'tabs_no_spaces',
		'🥊 Tabs, no spaces!',
		severity: DiagnosticSeverity.ERROR,
	);

	TabsNoSpaces()
		: super(
			name: 'tabs_no_spaces',
			description: 'Disallows spaces used for indentation.',
		);

	@override
	LintCode get diagnosticCode => code;

	@override
	void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context)
	{
		final visitor = _Visitor(this, context);
		registry.addClassDeclaration(this, visitor);
		registry.addEnumDeclaration(this, visitor);
		registry.addMixinDeclaration(this, visitor);
		registry.addExtensionDeclaration(this, visitor);
	}
}

class _Visitor extends SimpleAstVisitor<void>
{
	final AnalysisRule rule;
	final RuleContext context;

	_Visitor(this.rule, this.context);

	void _checkForSpaces(AstNode node)
	{
		final unit = context.currentUnit;
		if (unit == null)
			return;
		final lineInfo = unit.unit.lineInfo;
		final content = unit.content;

		final start = node.offset;
		final startLine = lineInfo.getLocation(start).lineNumber - 1;

		final end = node.endToken.offset;
		final endLine = lineInfo.getLocation(end).lineNumber - 1;

		final runes = content.substring(start, end).runes;
		final endPos = runes.length - 1;

		for (var lineIndex = startLine; lineIndex <= endLine; lineIndex++)
		{
			final lineOffset = lineInfo.getOffsetOfLine(lineIndex);

			int length = 0;
			int currentPos = lineOffset - start;
			bool foundToken = false;
			bool foundSpace = false;

			while (!foundToken)
			{
				if (currentPos > endPos || currentPos < 0)
					break;
				final int uniCode = runes.elementAt(currentPos);
				if (uniCode == 32 || uniCode == 9)
				{
					currentPos++;
					length++;
					if (uniCode == 32)
						foundSpace = true;
					continue;
				}
				foundToken = true;
			}

			if (length > 0 && foundSpace)
				rule.reportAtOffset(lineOffset, length);
		}
	}

	@override
	void visitClassDeclaration(ClassDeclaration node) => _checkForSpaces(node);

	@override
	void visitEnumDeclaration(EnumDeclaration node) => _checkForSpaces(node);

	@override
	void visitMixinDeclaration(MixinDeclaration node) => _checkForSpaces(node);

	@override
	void visitExtensionDeclaration(ExtensionDeclaration node) => _checkForSpaces(node);
}
