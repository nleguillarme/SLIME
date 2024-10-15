#' Retrieve guild information based on Taxonomy ID or scientific name from a specific SPARQL endpoint.
#'
#' The `get.guilds` function constructs and executes a SPARQL query to retrieve guild information
#' based on specified Taxonomy ID or scientific name. It utilizes the `fill.query`, `send.sparql`,
#' and `format.result.df` functions.
#'
#' @param taxid An optional parameter representing the Taxonomy ID(s) to be used in the query.
#' @param sciName An optional parameter representing the scientific name(s) to be used in the query.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing guild information based on the specified parameters.
#'
#' @details
#' The function constructs a SPARQL query template, fills in placeholders based on provided parameters
#' using the `fill.query` function, sends the query to the specified SPARQL endpoint using `send.sparql`,
#' and formats the result data frame using `format.result.df`. The resulting data frame contains the following
#' information: query name, query ID, match name, match ID, guild ID, guild name, reference, source, and inferred.
#'
#' @examples
#' # Example for retrieving guild information based on Taxonomy ID from a specific SPARQL endpoint
#' guild_info <- get.guilds(taxid = c("GBIF:2130185", "NCBI:55786"), endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(guild_info)
#'
#' @author <Author 1>
#' 
#' @import dplyr
#' 
#' @export get.guilds
get.guilds <- function(taxid = NULL, sciName = NULL, endpoint) {
  query = "
    SELECT DISTINCT ?queryName ?queryId ?matchName ?matchId ?guildId ?guildName ?reference ?source ?inferred
    %s
    WHERE{
      %s
      %s
      
      GRAPH ?graph {
        OPTIONAL { 
          ?occurrence obo:OBI_0000293 ?organism.
          ?occurrence dwc:associatedReferences ?reference.
        }
        ?organism rdf:type ?guildId.
      }
      
      ?guildId rdfs:subClassOf obo:CARO_0001010.
      ?guildId rdfs:label ?guildName.
      %s
      FILTER(?matchId!=obo:CARO_0001010)
      FILTER(?guildId!=obo:CARO_0001010)
      FILTER(?guildId!=obo:OBI_0100026)
    }
  "
  
  query <- fill.query(query, taxid, sciName)
  df <- send.sparql(query, endpoint, verbose=TRUE)
  
  cols <- c("queryName", "queryId", "matchName", "matchId", "guildId", "guildName", "reference", "source", "inferred")
  df[cols[!(cols %in% colnames(df))]] = NA
  df <- df[,cols]

  if(nrow(df) == 0)
    return(df)
  
  df <- format.result.df(df, c("queryId", "matchId", "guildId", "source"))
  return(df)
}
