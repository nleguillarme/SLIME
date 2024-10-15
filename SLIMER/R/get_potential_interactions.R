#' Retrieve potential interaction information based on Taxonomy ID or scientific name from a specific SPARQL endpoint.
#'
#' The `get.potential.interactions` function constructs and executes a SPARQL query to retrieve potential interaction information
#' based on specified Taxonomy ID or scientific name. It utilizes the `fill.query`, `send.sparql`,
#' and `format.result.df` functions.
#' 
#' Potential interactions are relationships between a consumer and potential trophic resources which are inferred from its diet, 
#' e.g. a bacterivorous organism potentially interacts with Bacteria and Archaea.
#'
#' @param taxid An optional parameter representing the Taxonomy ID(s) to be used in the query.
#' @param sciName An optional parameter representing the scientific name(s) to be used in the query.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#'
#' @return A data frame containing potential interaction information based on the specified parameters.
#'
#' @details
#' The function constructs a SPARQL query template, fills in placeholders based on provided parameters
#' using the `fill.query` function, sends the query to the specified SPARQL endpoint using `send.sparql`,
#' and formats the result data frame using `format.result.df`. The resulting data frame contains the following
#' information: query name, query ID, match name, match ID, interaction ID, interaction name, resource ID,
#' resource name, reference, source, and inferred.
#'
#' @examples
#' # Example for retrieving potential interaction information based on Taxonomy ID from a specific SPARQL endpoint
#' interaction_info <- get.potential.interactions(taxid = c("GBIF:2130185", "NCBI:55786"), endpoint = "http://129.88.204.79:7200/repositories/gratin")
#' print(interaction_info)
#'
#' @author <Author 1>
#' 
#' @import dplyr
#' 
#' @export get.potential.interactions
get.potential.interactions <- function(taxid = NULL, sciName = NULL, endpoint = NULL) {

  query = "
    SELECT DISTINCT ?queryName ?queryId ?matchName ?matchId ?interactionId ?interactionName ?resourceId ?resourceName ?reference ?source ?inferred
    %s
    WHERE{
      %s
      %s
      
      GRAPH ?graph {
          ?organism rdf:type [rdfs:subClassOf ?restriction].
      }
      ?restriction rdf:type owl:Restriction .
      ?restriction owl:onProperty ?interactionId.
      ?interactionId rdfs:subPropertyOf obo:RO_0002437.  
    
      {
          # Set of resources/taxa
          ?restriction owl:someValuesFrom ?target.
          ?target owl:unionOf [rdf:rest*/rdf:first ?item].
          {
              ?item owl:someValuesFrom ?resourceId.
          }
          UNION
          {
              ?item rdfs:subClassOf obo:BFO_0000040.
              BIND(?item AS ?resourceId)
          }
      }
      UNION
      {
          {
              # Single resource
              ?restriction owl:someValuesFrom ?resourceId.
              ?resourceId rdfs:subClassOf obo:BFO_0000040.
          }
          UNION
          {
              # Single taxon
              ?restriction owl:someValuesFrom [owl:someValuesFrom ?resourceId].
              ?resourceId rdfs:subClassOf obo:NCBITaxon_131567.
          }
      }     
        
      ?resourceId rdfs:label ?resourceName.
      ?interactionId rdfs:label ?interactionName.
      OPTIONAL { 
        ?occurrence obo:OBI_0000293 ?organism.
        ?occurrence dwc:associatedReferences ?reference.
      }
      
      %s
          
      FILTER(?matchId!=obo:CARO_0001010)
      FILTER(?resourceId!=obo:PCO_0000059)
      FILTER(?resourceId!=obo:NCBITaxon_131567)
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
