#' Retrieve trophic group information based on Taxonomy ID or scientific name from a specific SPARQL endpoint.
#'
#' The `get.trophic.groups` function constructs and executes a SPARQL query to retrieve trophic group information
#' based on specified Taxonomy ID or scientific name. It utilizes the `fill.query`, `send.sparql`,
#' and `format.result.df` functions.
#'
#' @param taxid An optional parameter representing the Taxonomy ID(s) to be used in the query.
#' @param sciName An optional parameter representing the scientific name(s) to be used in the query.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing trophic group information based on the specified parameters.
#'
#' @details
#' The function constructs a SPARQL query template, fills in placeholders based on provided parameters
#' using the `fill.query` function, sends the query to the specified SPARQL endpoint using `send.sparql`,
#' and formats the result data frame using `format.result.df`. The resulting data frame contains the following
#' information: query name, query ID, match name, match ID, trophic group ID, trophic group name,
#' reference, source, and inferred.
#'
#' @examples
#' # Example for retrieving trophic group information based on Taxonomy ID from a specific SPARQL endpoint
#' trophic_group_info <- get.trophic.groups(taxid = c("GBIF:2130185", "NCBI:55786"), endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(trophic_group_info)
#'
#' @author <Author 1>
#' 
#' @import dplyr
#' 
#' @export get.trophic.groups
get.trophic.groups <- function(taxid = NULL, sciName = NULL, endpoint = NULL) {
  query = "
    SELECT DISTINCT ?queryName ?queryId ?matchName ?matchId ?trophicGroupId ?trophicGroupName ?reference ?source ?inferred
    %s
    WHERE{
      %s
      %s
      GRAPH ?graph { 
          ?organism obo:RO_0002350 ?trophicGroup. 
      }
      ?trophicGroup rdf:type ?trophicGroupId.
      ?trophicGroupId rdfs:subClassOf SFWO:0000127.
      ?trophicGroupId rdfs:label ?trophicGroupName.
      
      %s

      FILTER(?matchId!=obo:CARO_0001010)
      FILTER(?trophicGroupId!=SFWO:0000127)
    }
  "
  
  query <- fill.query(query, taxid, sciName)
  df <- send.sparql(query, endpoint, verbose=FALSE)
  
  cols <- c("queryName", "queryId", "matchName", "matchId", "trophicGroupId", "trophicGroupName", "reference", "source", "inferred")
  df[cols[!(cols %in% colnames(df))]] = NA
  df <- df[,cols]
  
  if(nrow(df) == 0)
    return(df)
  
  df <- format.result.df(df, c("queryId", "matchId", "trophicGroupId", "source" ))
  return(df)
}
