#' Retrieve interaction information based on Taxonomy ID or scientific name from a specific SPARQL endpoint.
#'
#' The `get.interactions` function constructs and executes a SPARQL query to retrieve interaction information
#' based on specified Taxonomy ID or scientific name. It utilizes the `fill.query`, `send.sparql`,
#' and `format.result.df` functions.
#'
#' @param taxid An optional parameter representing the Taxonomy ID(s) to be used in the query.
#' @param sciName An optional parameter representing the scientific name(s) to be used in the query.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing interaction information based on the specified parameters.
#'
#' @details
#' The function constructs a SPARQL query template, fills in placeholders based on provided parameters
#' using the `fill.query` function, sends the query to the specified SPARQL endpoint using `send.sparql`,
#' and formats the result data frame using `format.result.df`. The resulting data frame contains the following
#' information: query name, query ID, match name, match ID, interaction ID, interaction name, resource ID,
#' resource name, reference, source, and inferred.
#'
#' @examples
#' # Example for retrieving interaction information based on Taxonomy ID from a specific SPARQL endpoint
#' interaction_info <- get.interactions(taxid = c("GBIF:2130185", "NCBI:55786"), endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(interaction_info)
#'
#' @author <Author 1>
#' 
#' @import dplyr
#' 
#' @export get.interactions
get.interactions <- function(taxid = NULL, sciName = NULL, endpoint = NULL) {
  query = "
    SELECT DISTINCT ?queryName ?queryId ?matchName ?matchId ?interactionId ?interactionName ?resourceId ?resourceName ?reference ?source ?inferred
    %s
    WHERE{
      %s
      %s
      GRAPH ?graph {
        ?interaction obo:RO_0002233 ?organism.
        ?interaction obo:RO_0002233 ?target.
        ?organism ?interactionId ?target.
      }

      GRAPH <http://www.ontotext.com/explicit> {
        { ?target obo:RO_0002350 [rdf:type ?resourceId]. }
        UNION
        { ?target rdf:type ?resourceId. }
      }
      
      %s

      ?resourceId rdfs:label ?resourceName.
      ?interactionId rdfs:label ?interactionName.
      ?data obo:IAO_0000136 ?interaction.
      OPTIONAL { ?data dwc:associatedReferences ?reference. }

      FILTER(?matchId!=obo:CARO_0001010)
      FILTER(?organism!=?target)
      FILTER(?resourceId!=obo:PCO_0000059)
      FILTER(?resourceId!=obo:BFO_0000040)
    }
  "
  
  query <- fill.query(query, taxid, sciName)
  df <- send.sparql(query, endpoint, verbose=FALSE)
  
  cols <- c("queryName", "queryId", "matchName", "matchId", "interactionId", "interactionName", "resourceId", "resourceName", "reference", "source", "inferred")
  df[cols[!(cols %in% colnames(df))]] = NA
  df <- df[,cols]
  
  if(nrow(df) == 0)
    return(df)
  
  df <- format.result.df(df, c("queryId", "matchId", "interactionId", "resourceId", "source" ))
  return(df)
}
