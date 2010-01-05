inflections.uncountable.words <- c('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep')

inflections.singularization.exception.table <- list('axes' = 'axis', 'testes' = 'testis', 'octupi' = 'octopus', 'viri' = 'virus', 'aliases' = 'alias', 'statuses' = 'status', 'buses' = 'bus', 'buffaloes' = 'buffalo', 'tomatoes' = 'tomato', 'ses' = 'sis', 'hives' = 'hive', 'mice' = 'mouse', 'lice' = 'louse', 'oxen' = 'ox', 'quizzes' = 'quiz', 'people' = 'person', 'men' = 'man', 'children' = 'child', 'sexes' = 'sex', 'moves' = 'move', 'kine' = 'cow')

inflections.pluralization.exception.table <- list('axis' = 'axes', 'testis' = 'testes', 'octopus' = 'octupi', 'virus' = 'viri', 'alias' = 'aliases', 'status' = 'statuses', 'bus' = 'buses', 'buffalo' = 'buffaloes', 'tomato' = 'tomatoes', 'sis' = 'ses', 'hive' = 'hives', 'mouse' = 'mice', 'louse' = 'lice', 'ox' = 'oxen', 'quiz' = 'quizzes', 'person' = 'people', 'man' = 'men', 'child' = 'children', 'sex' = 'sexes', 'move' = 'moves', 'cow' = 'kine')

singularize <- function(word)
{
  word <- tolower(word)
  
	if (is.null(word))
	{
		return(NULL)
	}
	
  if (nchar(word) == 0)
  {
    return('')
  }
  
  if (word %in% inflections.uncountable.words)
  {
    return(word)
  }

	if (!is.null(inflections.singularization.exception.table[[word]]))
	{
		return(inflections.singularization.exception.table[[word]])
	}
	
	return(strtrim(word, nchar(word) - 1))
}

pluralize <- function(word)
{
  word <- tolower(word)
  
	if (is.null(word))
	{
		return(NULL)
	}
	
  if (nchar(word) == 0)
  {
    return('')
  }
  
  if (word %in% inflections.uncountable.words)
  {
    return(word)
  }

	if (!is.null(inflections.pluralization.exception.table[[word]]))
	{
		return(inflections.pluralization.exception.table[[word]])
	}
  
  return(paste(word, 's', sep = ''))
}
