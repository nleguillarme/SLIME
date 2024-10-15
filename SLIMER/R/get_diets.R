#' Retrieve diet information based on Taxonomy ID or scientific name from a specific SPARQL endpoint.
#'
#' The `get.diets` function constructs and executes a SPARQL query to retrieve diet information
#' based on specified Taxonomy ID or scientific name. It utilizes the `fill.query`, `send.sparql`,
#' and `format.result.df` functions.
#'
#' @param taxid An optional parameter representing the Taxonomy ID(s) to be used in the query.
#' @param sciName An optional parameter representing the scientific name(s) to be used in the query.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing diet information based on the specified parameters.
#'
#' @details
#' The function constructs a SPARQL query template, fills in placeholders based on provided parameters
#' using the `fill.query` function, sends the query to the specified SPARQL endpoint using `send.sparql`,
#' and formats the result data frame using `format.result.df`. The resulting data frame contains the following
#' information: query name, query ID, match name, match ID, diet ID, diet name, reference, source, and inferred.
#'
#' @examples
#' # Example for retrieving diet information based on Taxonomy ID
#' diet_info <- get.diets(taxid = c("GBIF:2130185", "NCBI:55786"), endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(diet_info)
#'
#' @author <Author 1>
#' 
#' @import dplyr
#' 
#' @export get.diets
get.diets <- function(taxid = NULL, sciName = NULL, endpoint) {
  query = "
    SELECT DISTINCT ?queryName ?queryId ?matchName ?matchId ?dietId ?dietName ?reference ?source ?inferred ?graph
    %s
    WHERE{
      %s
      %s
      { 
        GRAPH ?graph { ?occurrence obo:OBI_0000293 ?organism. }
        ?organism obo:RO_0000086 ?diet.
        ?diet rdf:type ?dietId.
        OPTIONAL { ?occurrence dwc:associatedReferences ?reference. }
      }
      UNION
      {
        GRAPH ?graph { ?organism rdf:type ?restriction . }
        ?restriction rdf:type owl:Restriction .
        ?restriction owl:onProperty obo:RO_0000086 .
        ?restriction owl:someValuesFrom ?dietId.
      }
      
      %s
      
      ?dietId rdfs:subClassOf obo:PATO_0000056.
      ?dietId rdfs:label ?dietName.

      FILTER(?matchId!=obo:CARO_0001010)
      FILTER(?dietId!=obo:PATO_0000056)
      FILTER(?dietId!=SFWO:0000475)
    }
  "
  
  query <- fill.query(query, taxid, sciName)
  df <- send.sparql(query, endpoint, verbose=FALSE)
  
  cols <- c("queryName", "queryId", "matchName", "matchId", "dietId", "dietName", "reference", "source", "inferred")
  df[cols[!(cols %in% colnames(df))]] = NA
  df <- df[,cols]
  
  if(nrow(df) == 0)
    return(df)
  
    df <- format.result.df(df, c("queryId", "matchId", "dietId", "source" ))
  return(df)
}
