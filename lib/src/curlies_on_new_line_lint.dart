import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/custom_lint_core.dart' as clc;

class CurlyNewLine extends DartLintRule
{
	CurlyNewLine() : super(code: codeFor("statement"));

	static clc.LintCode codeFor(String description) => clc.LintCode(
		name: "curly_brace_new_line",
		problemMessage: "↩️  Curly braces must go on new line in $description",
		errorSeverity: ErrorSeverity.ERROR
	);

	@override
	void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context)
	{
		context.registry.addMethodDeclaration((node)
		{
			final element = node.declaredFragment;
			if (element == null)
				return;
			final body = node.body;
			Token openToken = body.beginToken;
			if (body.isAsynchronous)
			{
				final nextToken = openToken.next;
				if (nextToken != null)
					openToken = nextToken;
			}
			final closeToken = node.body.endToken;
			final lineCurlyOpen = resolver.lineInfo.getLocation(openToken.offset).lineNumber;
			final lineCurlyClose = resolver.lineInfo.getLocation(closeToken.offset).lineNumber;
			final lineDeclared = resolver.lineInfo.getLocation(element.offset).lineNumber;
			if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
				reporter.atToken(openToken,codeFor("method definition"));
		});

		context.registry.addClassDeclaration((node)
		{
			final element = node.declaredFragment;
			if (element == null)
				return;
			final token = node.leftBracket;
			final lineDeclared = resolver.lineInfo.getLocation(element.offset).lineNumber;
			final lineCurly = resolver.lineInfo.getLocation(token.offset).lineNumber;
			if (lineDeclared == lineCurly)
				reporter.atToken(token,codeFor("class definition"));
		});

		context.registry.addExtensionDeclaration((node)
		{
			final element = node.declaredFragment;
			if (element == null)
				return;
			final token = node.leftBracket;
			final lineDeclared = resolver.lineInfo.getLocation(element.offset).lineNumber;
			final lineCurly = resolver.lineInfo.getLocation(token.offset).lineNumber;
			if (lineDeclared == lineCurly)
				reporter.atToken(token,codeFor("extension definition"));
		});

		context.registry.addEnumDeclaration((node)
		{
			final element = node.declaredFragment;
			if (element == null)
				return;
			final token = node.leftBracket;
			final lineDeclared = resolver.lineInfo.getLocation(element.offset).lineNumber;
			final lineCurly = resolver.lineInfo.getLocation(token.offset).lineNumber;
			if (lineDeclared == lineCurly)
				reporter.atToken(token,codeFor("enum definition"));
		});

		context.registry.addIfStatement((node)
		{
			final ifToken = node.ifKeyword;
			final openToken = node.thenStatement.beginToken;
			final closeToken = node.thenStatement.endToken;
			final lineDeclared = resolver.lineInfo.getLocation(ifToken.offset).lineNumber;
			final lineCurlyOpen = resolver.lineInfo.getLocation(openToken.offset).lineNumber;
			final lineCurlyClose = resolver.lineInfo.getLocation(closeToken.offset).lineNumber;
			if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
				reporter.atToken(openToken,codeFor("if statement"));

			final elseToken = node.elseKeyword;
			final elseStatement = node.elseStatement;
			if (elseToken != null && elseStatement != null)
			{
				final openToken = elseStatement.beginToken;
				final closeToken = elseStatement.endToken;
				final lineDeclared = resolver.lineInfo.getLocation(elseToken.offset).lineNumber;
				final lineCurlyOpen = resolver.lineInfo.getLocation(openToken.offset).lineNumber;
				final lineCurlyClose = resolver.lineInfo.getLocation(closeToken.offset).lineNumber;
				if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
					reporter.atToken(openToken,codeFor("else statement"));
				}
		});

		context.registry.addSwitchStatement((node)
		{
			final switchToken = node.switchKeyword;
			final token = node.leftBracket;
			final lineDeclared = resolver.lineInfo.getLocation(switchToken.offset).lineNumber;
			final lineCurly = resolver.lineInfo.getLocation(token.offset).lineNumber;
			if (lineDeclared == lineCurly)
				reporter.atToken(token,codeFor("switch statement"));
		});

		context.registry.addForStatement((node)
		{
			final forToken = node.forKeyword;
			final openToken = node.body.beginToken;
			final closeToken = node.body.endToken;
			final lineDeclared = resolver.lineInfo.getLocation(forToken.offset).lineNumber;
			final lineCurlyOpen = resolver.lineInfo.getLocation(openToken.offset).lineNumber;
			final lineCurlyClose = resolver.lineInfo.getLocation(closeToken.offset).lineNumber;
			if (openToken.type == TokenType.OPEN_CURLY_BRACKET && lineDeclared == lineCurlyOpen && lineCurlyOpen != lineCurlyClose)
				reporter.atToken(openToken,codeFor("for loop statement"));
		});
	}
	@override
	List<Fix> getFixes() => [];
}

