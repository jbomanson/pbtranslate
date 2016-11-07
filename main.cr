require "./src/pbtranslator"

exit_value = 0

translator_class = PBTranslator::Tool::CardinalityTranslator
translator = translator_class.new(STDIN, STDOUT)
result = translator.parse
if result
  STDERR.puts result
  exit_value = 1
end
  
exit exit_value
