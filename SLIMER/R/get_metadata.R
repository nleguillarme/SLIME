#' Retrieve metadata for a specified data source from a specific SPARQL endpoint.
#'
#' The `get.source.metadata` function constructs and executes a SPARQL query to retrieve metadata
#' for a specified data source. It utilizes the `get.sparql.values`, `send.sparql`, and `format.result.df`
#' functions.
#'
#' @param source A character string representing the shortened IRI of the data source for which metadata is to be retrieved.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing metadata for the specified data source.
#'
#' @details
#' The function constructs a SPARQL query template, fills in placeholders based on provided parameters
#' using the `get.sparql.values` function, sends the query to the specified SPARQL endpoint using `send.sparql`,
#' and formats the result data frame using `format.result.df`. The resulting data frame contains metadata
#' information such as field and value for the specified data source.
#'
#' @examples
#' # Example for retrieving metadata for a specific data source from a SPARQL endpoint
#' source_metadata <- get.source.metadata(source = "gratin:nematrait", endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(source_metadata)
#'
#' @author <Author 1>
#' 
#' @import dplyr
#' 
#' @export get.source.metadata
get.source.metadata <- function(source, endpoint = NULL) {
  query = "
    SELECT DISTINCT ?field ?value
    WHERE{
      %s
      ?graph ?field ?value.
      FILTER(?field!=rdf:type)
      FILTER(?field!=owl:sameAs)
    }
  "
  if(startsWith(source, "http")) {
    source <- paste0("<",source,">")
  }
  values = get.sparql.values("graph", source, is.iri=TRUE)
  query <- sprintf(query, values)
  df <- send.sparql(query, endpoint, verbose=TRUE)
  df <- format.result.df(df, c("field"), with.matchId=FALSE, with.reference=FALSE)
  return(df)
}

#' Retrieve a list of data sources from a specific SPARQL endpoint.
#'
#' The `get.sources` function constructs and executes a SPARQL query to retrieve a list of data sources
#' from a specified SPARQL endpoint. It utilizes the `request`, `req_retry`, `req_perform`, `resp_check_status`,
#' `read.table`, and `format.result.df` functions.
#'
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing a list of data sources available at the specified SPARQL endpoint.
#'
#' @details
#' The function constructs a SPARQL query to obtain the list of data sources, sends the query to the specified
#' SPARQL endpoint using `request`, `req_retry`, and `req_perform`, checks the response status with `resp_check_status`,
#' reads the response body with `read.table`, and formats the result data frame using `format.result.df`. The resulting
#' data frame contains information about data sources, specifically the source shortened IRIs.
#'
#' @examples
#' # Example for retrieving a list of data sources from a SPARQL endpoint
#' sources_list <- get.sources(endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(sources_list)
#'
#' @author <Author 1>
#' 
#' @import httr2
#' 
#' @export get.sources
get.sources <- function(endpoint = NULL) {
  url = paste(endpoint,"contexts",sep="/")
  resp = request(url) %>%
    req_retry(max_tries = 1) %>%
    req_perform()
  resp_check_status(resp)
  df <- read.table(text = resp_body_string(resp), sep ="\r", header = TRUE)
  df <- format.result.df(df, c("contextID"), with.matchId=FALSE, with.reference=FALSE)
  df <- df[!duplicated(df), ]
  return(df)
}
