source('abstract-database.R')
source('case-transforms.R')
source('inflections.R')

orm.build.model <- function(model.name, autoeval = TRUE)
{
	class.name <- model.name
  
	table.name <- pluralize(model.name)
  
	column.metadata <- fetch.as.data.frame(paste('SHOW COLUMNS FROM `', table.name, '`', sep = ''))
  
	code <- ''
	
	code <- paste(code, orm.build.create.method(class.name, table.name, column.metadata), sep = '\n')
	code <- paste(code, orm.build.find.method(class.name, table.name, column.metadata), sep = '\n')
	code <- paste(code, orm.build.store.method(class.name, table.name, column.metadata), sep = '\n')
	code <- paste(code, orm.build.delete.method(class.name, table.name, column.metadata), sep = '\n')
	code <- paste(code, orm.build.field.methods(class.name, table.name, column.metadata), sep = '\n')
	code <- paste(code, orm.build.print.method(class.name, table.name, column.metadata), sep = '\n')
	
	# Plainly doesn't work.
	if (autoeval)
	{
		eval(parse(text = code))
	}
	
	return(code)
}

orm.build.create.method <- function(class.name, table.name, column.metadata)
{
	code <- ''
	code <- paste(code,
	              'create.',
	              class.name,
	              ' <- function()\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\t',
	              class.name,
	              ' <- list(\n',
	              sep = '')
	code <- paste(code,
	              '\t\t',
	              paste(apply(column.metadata,
	                          1,
	                          function (r)
	                          {
	                            paste(as.character(r['Field']),
	                                  ' = NULL',
	                                  sep = '')
	                          }),
	                    collapse = ',\n\t\t'),
	              '\n',
	              sep = '')
	code <- paste(code,
	              '\t)\n',
	              sep = '')
	code <- paste(code,
	              '\tclass(',
	              class.name,
	              ') <- \'',
	              class.name,
	              '\'\n',
	              sep = '')
	code <- paste(code,
	              '\treturn(',
	              class.name,
	              ')\n',
	              sep = '')
	code <- paste(code,
	              '}\n',
	              sep = '')
	return(code)
}

orm.build.find.method <- function(class.name, table.name, column.metadata)
{
	code <- ''
	code <- paste(code,
	              'find.',
	              class.name,
	              ' <- function(x)\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\tif (is.numeric(x))\n',
	              sep = '')
	code <- paste(code,
	              '\t{\n',
	              sep = '')
	code <- paste(code,
	              '\t\tfind.sql <- paste(\'SELECT * FROM `',
	              table.name,
	              '` WHERE ',
	              class.name,
	              '_id = ',
	              '\', x , sep = \'\')\n',
	              sep = '')
	code <- paste(code,
	              '\t\t',
	              class.name,
	              ' <- fetch.as.list(find.sql)[[1]]\n',
	              sep = '')
	code <- paste(code,
	              '\t\tclass(',
	              class.name,
	              ') <- \'',
	              class.name,
	              '\'\n',
	              sep = '')
	code <- paste(code,
	              '\t\treturn(',
	              class.name,
	              ')\n',
	              sep = '')
	code <- paste(code,
	              '\t}\n\n',
	              sep = '')
	code <- paste(code,
	              '\tif (x == \'all\')\n',
	              sep = '')
	code <- paste(code,
	              '\t{\n',
	              sep = '')
	code <- paste(code,
	              '\t\tfind.sql <- paste(\'SELECT * FROM `',
	              table.name,
	              '`\', sep = \'\')\n',
	              sep = '')
	code <- paste(code,
	              '\t\t',
	              pluralize(class.name),
	              ' <- fetch.as.list(find.sql)\n',
	              sep = '')
	code <- paste(code,
	              '\t\treturn(lapply(',
	              pluralize(class.name),
	              ', function (x) { class(x) <- \'',
	              class.name,
	              '\'; x }))\n',
	              sep = '')
	code <- paste(code,
	              '\t}\n\n',
	              sep = '')
	code <- paste(code,
	              '\tstop(paste(\'Invalid parameter, \',x, \', passed to find.',
	              class.name,
	              '().\', sep = \'\'))\n',
	              sep = '')
	code <- paste(code,
	              '}\n',
	              sep = '')
	return(code)
}

orm.build.store.method <- function(class.name, table.name, column.metadata)
{
	code <- ''
	code <- paste(code,
	              'store <- function(x)\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\tUseMethod(\'store\', x)\n',
	              sep = '')
	code <- paste(code,
	              '}\n\n',
	              sep = '')
	code <- paste(code,
	              'store.',
	              class.name,
	              ' <- function(x)\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\tif (is.null(x[[\'',
	              class.name,
	              '_id\']]))\n',
	              sep = '')
	code <- paste(code,
	              '\t{\n',
	              sep = '')
	code <- paste(code,
	              '\t\tsql <- paste(\'INSERT INTO `',
	              table.name,
	              '` (',
	              sep = '')
  code <- paste(code,
                paste(apply(subset(column.metadata, Key != 'PRI'),
                            1,
                            function (r)
                            {
                              paste('`',
                                    as.character(r['Field']),
                                    '`',
                                    sep = '')
                            }),
                      collapse = ', '),
                sep = '')
	code <- paste(code,
	              ') VALUES (\', ',
	              sep = '')
  code <- paste(code,
                paste(apply(subset(column.metadata, Key != 'PRI'),
                            1,
                            function (r)
                            {
                              paste('\'\\\'\', x[[\'',
                                    as.character(r['Field']),
                                    '\']], \'\\\'\'',
                                    sep = '')
                            }),
                      collapse = ', \', \', '),
                sep = '')
  code <- paste(code,
                ', \')\', sep = \'\')\n',
                sep = '')
	code <- paste(code, '\t\trun.sql(sql)\n', sep = '')
	code <- paste(code, '\t\tsql <- \'SELECT LAST_INSERT_ID()\'\n', sep = '')
	code <- paste(code, '\t\t', r.case(class.name), '.id(x) <- fetch.as.list(sql)[[1]][[1]]\n', sep = '')
	code <- paste(code, '\t\treturn(x)\n')
	code <- paste(code, '\t}\n')
	code <- paste(code, '\telse\n', sep = '')
	code <- paste(code, '\t{\n', sep = '')
	code <- paste(code, '\t\tsql <- paste(\'UPDATE `', table.name, '` SET ', sep = '')
	code <- paste(code,
                paste(apply(column.metadata,
                            1,
                            function (r)
                            {
                              paste('`',
                                    as.character(r['Field']),
                                    '` = \', ',
                                    '\'\\\'\', x[[\'',
                                    as.character(r['Field']),
                                    '\']], \'\\\'\'',
                                    sep = '')
                            }),
                      collapse = ', \', '),
                ', \' ',
                sep = '')
	code <- paste(code, 'WHERE `', class.name, '_id` = \', x[[\'', class.name, '_id\']], sep = \'\')\n', sep = '')
  code <- paste(code, '\t\trun.sql(sql)\n', sep = '')
  code <- paste(code, '\t\treturn(x)\n', sep = '')
  code <- paste(code, '\t}\n', sep = '')
  code <- paste(code, '}\n', sep = '')
	return(code)
}

orm.build.delete.method <- function(class.name, table.name, column.metadata)
{
	code <- c()
	code <- paste(code,
	              'delete <- function(x)\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\tUseMethod(\'delete\', x)\n',
	              sep = '')
	code <- paste(code,
	              '}\n\n',
	              sep = '')
	code <- paste(code,
	              'delete.',
	              class.name,
	              ' <- function(x)\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\tsql <- paste(\'DELETE FROM `',
	              table.name,
	              '` WHERE ',
	              class.name,
	              '_id = \', ',
	              'x[[\'',
	              class.name,
	              '_id', '\']], sep = \'\')\n',
	              sep = '')
	code <- paste(code,
	              '\trun.sql(sql)\n',
	              sep = '')
	code <- paste(code,
	              '}\n\n',
	              sep = '')
	return(code)
}

orm.build.field.methods <- function(class.name, table.name, column.metadata)
{
	code <- ''
	for (i in 1:nrow(column.metadata))
	{
		column <- column.metadata[i,]
		field.name <- as.character(column['Field'])
		method.name <- r.case(field.name)
		code <- paste(code,
		              method.name,
		              ' <- function(x)\n',
		              sep = '')
		code <- paste(code,
		              '{\n',
		              sep = '')
		code <- paste(code,
		              '\tUseMethod(\'',
		              method.name,
		              '\', x)\n',
		              sep = '')
		code <- paste(code,
		              '}\n\n',
		              sep = '')
		code <- paste(code,
		              method.name,
		              '.',
		              class.name,
		              ' <- function(x)\n',
		              sep = '')
		code <- paste(code,
		              '{\n',
		              sep = '')
		code <- paste(code,
		              '\treturn(x[[\'',
		              field.name,
		              '\']])\n',
		              sep = '')
		code <- paste(code,
		              '}\n\n',
		              sep = '')
		code <- paste(code,
		              '"',
		              method.name,
		              '<-" <- function(x, value)\n',
		              sep = '')
		code <- paste(code,
		              '{\n',
		              sep = '')
		code <- paste(code,
		              '\tUseMethod(\'',
		              method.name,
		              '<-\', x)\n',
		              sep = '')
		code <- paste(code,
		              '}\n\n',
		              sep = '')
		code <- paste(code,
		              '"',
		              method.name,
		              '<-.',
		              class.name,
		              '" <- function(x, value)\n',
		              sep = '')
		code <- paste(code,
		              '{\n',
		              sep = '')
		code <- paste(code,
		              '\tx[[\'',
		              field.name,
		              '\']] <- value\n',
		              sep = '')
		code <- paste(code,
		              '\treturn(x)\n',
		              sep = '')
		code <- paste(code,
		              '}\n\n',
		              sep = '')
	}
	return(code)
}

orm.build.print.method <- function(class.name, table.name, column.metadata)
{
	code <- ''
	code <- paste(code,
	              'print.',
	              class.name,
	              ' <- function(x)\n',
	              sep = '')
	code <- paste(code,
	              '{\n',
	              sep = '')
	code <- paste(code,
	              '\tprint.default(str(x))\n',
	              sep = '')
	code <- paste(code,
	              '}\n\n',
	              sep = '')
	return(code)
}
