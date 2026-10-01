import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

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

		for (var lineIndex = startLine; lineIndex <= endLine; lineIndex++)
		{
			final lineOffset = lineInfo.getOffsetOfLine(lineIndex);
			if (lineOffset < start)
				continue;

			int length = 0;
			bool foundSpace = false;
			var offset = lineOffset;
			while (offset < content.length)
			{
				final codeUnit = content.codeUnitAt(offset);
				if (codeUnit == 32 || codeUnit == 9)
				{
					offset++;
					length++;
					if (codeUnit == 32)
						foundSpace = true;
				}
				else
					break;
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
