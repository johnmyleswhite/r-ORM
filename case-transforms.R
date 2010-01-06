capitalize.first.letter <- function(word)
{
  individual.characters <- strsplit(word, split = character(0))[[1]]
  return(paste(toupper(individual.characters[1]),
               paste(tolower(individual.characters[-1]),
                     collapse = ''),
               sep = ''))
}

r.case <- function(word)
{
  return(tolower(gsub('_', '.', word)))
}

camel.case <- function(word)
{
  return(paste(as.character(lapply(strsplit(word,
                                            '[\\._]',
                                            extended = TRUE)[[1]],
                                   capitalize.first.letter)),
               collapse = ''))
}

c.case <- function(word)
{
  return(tolower(gsub('\\.', '_', word)))
}
