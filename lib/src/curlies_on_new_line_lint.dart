import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class CurlyNewLine extends AnalysisRule
{
	/// Uses `{0}` interpolation instead of building a distinct LintCode per
	/// call, since diagnosticCode is required to be a single static instance.
	static const LintCode code = LintCode(
		'curly_brace_new_line',
		'↩️  Curly braces must go on new line in {0}',
		severity: DiagnosticSeverity.ERROR,
	);

	CurlyNewLine()
		: super(
			name: 'curly_brace_new_line',
			description: 'Requires multiline bodies to put opening curly braces on a new line.',
		);

	@override
	LintCode get diagnosticCode => code;

	@override
	void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context)
	{
		final visitor = _Visitor(this, context);
		registry.addMethodDeclaration(this, visitor);
		registry.addClassDeclaration(this, visitor);
		registry.addExtensionDeclaration(this, visitor);
		registry.addEnumDeclaration(this, visitor);
		registry.addIfStatement(this, visitor);
		registry.addSwitchStatement(this, visitor);
		registry.addForStatement(this, visitor);
	}
}

class _Visitor extends SimpleAstVisitor<void>
{
	final AnalysisRule rule;
	final RuleContext context;

	_Visitor(this.rule, this.context);

	int _lineOf(int offset) => context.currentUnit!.unit.lineInfo.getLocation(offset).lineNumber;

	@override
	void visitMethodDeclaration(MethodDeclaration node)
	{
		final element = node.declaredFragment;
		if (element == null)
			return;
		var openToken = node.body.beginToken;
		if (node.body.isAsynchronous)
		{
			final nextToken = openToken.next;
			if (nextToken != null)
				openToken = nextToken;
		}
		final closeToken = node.body.endToken;
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		final lineDeclared = _lineOf(element.offset);
		if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['method definition']);
	}

	@override
	void visitClassDeclaration(ClassDeclaration node)
	{
		final element = node.declaredFragment;
		final body = node.body;
		if (element == null || body is! BlockClassBody)
			return;
		final openToken = body.leftBracket;
		final closeToken = body.rightBracket;
		final lineDeclared = _lineOf(element.offset);
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		if (lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['class definition']);
	}

	@override
	void visitExtensionDeclaration(ExtensionDeclaration node)
	{
		final element = node.declaredFragment;
		final body = node.body;
		if (element == null || body is! BlockClassBody)
			return;
		final openToken = body.leftBracket;
		final closeToken = body.rightBracket;
		final lineDeclared = _lineOf(element.offset);
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		if (lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['extension definition']);
	}

	@override
	void visitEnumDeclaration(EnumDeclaration node)
	{
		final element = node.declaredFragment;
		final body = node.body;
		if (element == null || body is! BlockEnumBody)
			return;
		final openToken = body.leftBracket;
		final closeToken = body.rightBracket;
		final lineDeclared = _lineOf(element.offset);
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		if (lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['enum definition']);
	}

	@override
	void visitIfStatement(IfStatement node)
	{
		final ifToken = node.ifKeyword;
		final openToken = node.thenStatement.beginToken;
		final closeToken = node.thenStatement.endToken;
		final lineDeclared = _lineOf(ifToken.offset);
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['if statement']);

		final elseToken = node.elseKeyword;
		final elseStatement = node.elseStatement;
		if (elseToken != null && elseStatement != null)
		{
			final openToken = elseStatement.beginToken;
			final closeToken = elseStatement.endToken;
			final lineDeclared = _lineOf(elseToken.offset);
			final lineCurlyOpen = _lineOf(openToken.offset);
			final lineCurlyClose = _lineOf(closeToken.offset);
			if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
				rule.reportAtToken(openToken, arguments: ['else statement']);
		}
	}

	@override
	void visitSwitchStatement(SwitchStatement node)
	{
		final switchToken = node.switchKeyword;
		final openToken = node.leftBracket;
		final closeToken = node.rightBracket;
		final lineDeclared = _lineOf(switchToken.offset);
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		if (lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['switch statement']);
	}

	@override
	void visitForStatement(ForStatement node)
	{
		final forToken = node.forKeyword;
		final openToken = node.body.beginToken;
		final closeToken = node.body.endToken;
		final lineDeclared = _lineOf(forToken.offset);
		final lineCurlyOpen = _lineOf(openToken.offset);
		final lineCurlyClose = _lineOf(closeToken.offset);
		if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
			rule.reportAtToken(openToken, arguments: ['for loop statement']);
	}
}
