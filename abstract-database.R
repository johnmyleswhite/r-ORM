library('yaml')
library('RMySQL')

AbstractDatabase.configuration <- yaml.load_file('database.yml')

load.connection <- function()
{
  mysql.driver <- dbDriver("MySQL")

  connection <- dbConnect(mysql.driver,
                          user = AbstractDatabase.configuration[['user']],
                          password = AbstractDatabase.configuration[['password']],
                          host = AbstractDatabase.configuration[['host']],
                          dbname = AbstractDatabase.configuration[['dbname']])

  return(connection)
}

AbstractDatabase.connection <- load.connection()

run.sql <- function(sql)
{
  dbSendQuery(AbstractDatabase.connection, sql)
}

fetch.as.list <- function(sql)
{
  parcel.size <- 1000
  
  result.set <- dbSendQuery(AbstractDatabase.connection, sql)
  
  data.parcel <- fetch(result.set, n = parcel.size)

  if (nrow(data.parcel) == 0)
  {
    return(NULL)
  }

  values <- list()
  
  i <- 0
  
  for (j in 1:nrow(data.parcel))
  {
    i <- i + 1
    values[[i]] <- as.list(data.parcel[j,])
  }

  while (!dbHasCompleted(result.set))
  {
    data.parcel <- fetch(result.set, n = parcel.size)

    if (nrow(data.parcel) > 0)
    {
      for (j in 1:nrow(data.parcel))
      {
        i <- i + 1
        values[[i]] <- as.list(data.parcel[j,])
      }
    }
  }

  return(values)
}

fetch.as.data.frame <- function(sql)
{
  parcel.size <- 1000
  
  result.set <- dbSendQuery(AbstractDatabase.connection, sql)
  
  data.parcel <- fetch(result.set, n = parcel.size)

  if (nrow(data.parcel) == 0)
  {
    return(NULL)
  }

  values <- data.parcel
  
  while (!dbHasCompleted(result.set))
  {
    data.parcel <- fetch(result.set, n = parcel.size)

    if (nrow(data.parcel) > 0)
    {
      values <- rbind(values, data.parcel)
    }
  }

  return(values)
}
