import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/custom_lint_core.dart' as clc;

class TabsNoSpaces extends DartLintRule
{
	const TabsNoSpaces() : super(code: _code);

	static const _code = clc.LintCode(
		name: "tabs_no_spaces",
		problemMessage: "🥊 Tabs, no spaces!",
		errorSeverity: ErrorSeverity.ERROR
	);

	@override
	void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context)
	{
		void checkForSpaces(AstNode node)
		{
			final start = node.offset;
			final startLine = resolver.lineInfo.getLocation(start).lineNumber - 1;

			final end = node.endToken.offset;
			final endLine = resolver.lineInfo.getLocation(end).lineNumber - 1;

			final runes = resolver.source.contents.data.substring(start, end).runes;
			final endPos = runes.length - 1;

			for (var lineIndex = startLine; lineIndex <= endLine; lineIndex++)
			{
				final lineOffset = resolver.lineInfo.getOffsetOfLine(lineIndex);

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
						currentPos ++;
						length ++;
						if (uniCode == 32)
							foundSpace = true;
						continue;
					}
					foundToken = true;
					break;
				}

				if (length > 0 && foundSpace)
					reporter.atOffset(errorCode:code, offset:lineOffset, length:length);
			}
		}

		context.registry.addClassDeclaration(checkForSpaces);
		context.registry.addEnumDeclaration(checkForSpaces);
		context.registry.addMixinDeclaration(checkForSpaces);
		context.registry.addExtensionDeclaration(checkForSpaces);
	}

	@override
	List<Fix> getFixes() => [];
}

