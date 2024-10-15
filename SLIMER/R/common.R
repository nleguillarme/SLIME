prefixes <- c(obo="http://purl.obolibrary.org/obo/",
              dwc="http://rs.tdwg.org/dwc/terms/",
              rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#",
              rdfs="http://www.w3.org/2000/01/rdf-schema#",
              xsd="http://www.w3.org/2001/XMLSchema#",
              onto="http://www.ontotext.com/",
              NCBITaxon="http://purl.obolibrary.org/obo/NCBITaxon_",
              NCBI="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=",
              RO="http://purl.obolibrary.org/obo/RO_",
              SFWO="http://purl.org/sfwo/SFWO_",
              EOL="http://eol.org/pages/",
              ECOCORE="http://purl.obolibrary.org/obo/ECOCORE_",
              OBI="http://purl.obolibrary.org/obo/OBI_",
              BFO="http://purl.obolibrary.org/obo/BFO_",
              GBIF="http://www.gbif.org/species/",
              ITIS="http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=",
              SILVA="https://www.arb-silva.de/",
              IF= "http://www.indexfungorum.org/names/NamesRecord.asp?RecordID=",
              sesame="http://www.openrdf.org/schema/sesame#",
              SLIME="https://purl.slime.org/",
              dc="http://purl.org/dc/elements/1.1/"
)

#' Add SPARQL prefixes to a query.
#'
#' The `add_prefixes` function is designed to add SPARQL prefixes to a given query.
#' It takes a query as input and prefixes it with the specified namespace prefixes.
#'
#' @param query A character string representing the SPARQL query to which prefixes need to be added.
#'
#' @return A character string, which is the input query with SPARQL prefixes added.
#'
#' @details
#' The function utilizes an inner function `format.namespace` to format each namespace prefix
#' and its corresponding URI as a SPARQL PREFIX statement. The prefixes are defined in a
#' global variable named `prefixes`. The format of the global variable should be a named list
#' where each name corresponds to a prefix, and the corresponding value is the URI.
#'
#' @examples
#' # Define namespace prefixes
#' prefixes <- list(
#'   ex = "http://example.org/",
#'   foaf = "http://xmlns.com/foaf/0.1/",
#'   rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
#' )
#'
#' # Example query
#' query <- "SELECT ?person WHERE { ?person foaf:name ?name . }"
#'
#' # Add prefixes to the query
#' result_query <- add_prefixes(query)
#'
#' # Print the result
#' cat(result_query)
#'
#' @author <Author 1>
add_prefixes <- function(query) {
  format.namespace = function(x) sprintf("PREFIX %s: <%s>", x, prefixes[[x]])
  ns.str <- unlist(lapply(names(prefixes), format.namespace), use.names = FALSE)
  ns.str <- paste(ns.str, collapse = '\n')
  paste(ns.str, query, sep ="\n")
}

#' Generate a SPARQL VALUES clause for a variable with specified values.
#'
#' The `get.sparql.values` function generates a SPARQL VALUES clause for a specified variable
#' with associated values. The resulting SPARQL snippet can be used to filter query results based on
#' the specified variable values.
#'
#' @param var.name A character string representing the variable name for which values are specified.
#' @param var.values A vector of values for the specified variable.
#' @param is.iri Logical, indicating whether the values are IRIs. If FALSE, the values are wrapped
#' in double quotes.
#'
#' @return A character string representing the SPARQL VALUES clause for the specified variable and values.
#'
#' @details
#' If `is.iri` is set to FALSE, the function wraps each value in double quotes. The resulting
#' VALUES clause is then constructed and returned as a character string.
#'
#' @examples
#' # Example for generating a SPARQL VALUES clause
#' var_name <- "country"
#' var_values <- c("USA", "Canada", "UK")
#' sparql_values <- get.sparql.values(var_name, var_values, is.iri = FALSE)
#' cat(sparql_values)
#'
#' @author <Author 1>
#' 
#' @export get.sparql.values
get.sparql.values <- function(var.name, var.values, is.iri=TRUE) {
  values.string = ""
  if(!is.iri)
    var.values = sapply(var.values, function(x) sprintf('"%s"', x))
  var.values.string = paste0(var.values, collapse=" ")
  values.string = sprintf("VALUES ?%s { %s }", var.name, var.values.string)
  return(values.string)
}

#' Generate a SPARQL FROM NAMED clause for named graphs.
#'
#' The `get.named.graphs` function generates a SPARQL FROM NAMED clause with specified named graphs.
#' The resulting SPARQL snippet can be used to specify named graphs for a query.
#'
#' @return A character string representing the SPARQL FROM NAMED clause with specified named graphs.
#'
#' @details
#' The function returns a static SPARQL snippet with FROM NAMED clauses for three example named graphs.
#'
#' @examples
#' # Example for generating a SPARQL FROM NAMED clause
#' named_graphs <- get.named.graphs()
#' cat(named_graphs)
#'
#' @author <Author 1>
get.named.graphs <- function()
{
  return("
    FROM NAMED <http://www.ontotext.com/explicit>
    FROM NAMED <http://www.ontotext.com/implicit>
    FROM NAMED <http://www.ontotext.com/skip-redundant-implicit>
  ")
}

#' Send a SPARQL query to an endpoint and retrieve results.
#'
#' The `send.sparql` function sends a SPARQL query to a specified endpoint and retrieves the results.
#' The function also supports adding prefixes to the query using the `add_prefixes` function.
#'
#' @param query A character string representing the SPARQL query to be sent.
#' @param endpoint A character string representing the SPARQL endpoint to send the query to.
#' @param verbose Logical, indicating whether to print the SPARQL query before sending.
#'
#' @return A tibble containing the results of the SPARQL query.
#'
#' @details
#' The function sends a GET request to the specified SPARQL endpoint with the provided query.
#' It expects the response in the SPARQL Results JSON format and parses the results into a tibble.
#' The function also checks the response type and raises an error if it's not in the expected format.
#'
#' @examples
#' # Example for sending a SPARQL query to an endpoint
#' query <- "SELECT ?subject ?predicate ?object WHERE { ?subject ?predicate ?object } LIMIT 10"
#' endpoint <- "http://example.com/sparql"
#' result <- send.sparql(query, endpoint, verbose = TRUE)
#' print(result)
#'
#' @author <Author 1>
#' 
#' @import httr2
#' @import purrr
#' @import dplyr
#' @importFrom httr2 %>%
#' @importFrom rlang abort
#' @importFrom tibble tibble
#' @importFrom anytime anytime
#' @export send.sparql
send.sparql <- function (query, endpoint, verbose=FALSE)
{
  query <- add_prefixes(query)
  if(verbose == TRUE) { writeLines(query) }
  resp = request(endpoint) %>%
    #req_timeout(10) %>%
    req_url_query(query = query) %>%
    req_method("GET") %>% 
    req_headers(Accept = "application/sparql-results+json") %>%
    req_user_agent("admin") %>%
    req_retry(max_tries = 1) %>% #, max_seconds = 120) %>%
    req_perform()
  resp_check_status(resp)
  if (resp_content_type(resp) != "application/sparql-results+json") {
    abort("Not right response type")
  }
  content = resp_body_json(resp)
  if (length(content$results$bindings) > 0) {
    parse_binding = function(binding, name) {
      type <- sub("http://www.w3.org/2001/XMLSchema#", "", binding[["datatype"]] %||% "http://www.w3.org/2001/XMLSchema#character")
      parse = function(x, type) {
        switch(type, character = x, integer = x, datetime = anytime(x))
      }
      value = parse(binding[["value"]], type)
      tibble(.rows = 1) %>% mutate(`:=`({
        {
          name
        }
      }, value))
    }
    parse_result = function(result) {
      map2(result, names(result), parse_binding) %>%
        bind_cols()
    }
    data_frame <- map_df(content$results$bindings, parse_result)
  }
  else {
    data_frame <- as_tibble(matrix(character(), nrow = 0, ncol = length(content$head$vars), dimnames = list(c(), unlist(content$head$vars))))
  }
  return(data_frame)
}

#' Shorten a full IRI using specified namespaces.
#'
#' The `to.short.iri` function shortens a full Internationalized Resource Identifier (IRI)
#' using specified namespaces. It attempts to find the longest matching namespace and replaces
#' it with its associated prefix.
#'
#' @param full.iri A character string representing the full IRI to be shortened.
#' @param namespaces A named list containing namespace prefixes and their corresponding URIs.
#'
#' @return A character string representing the shortened IRI with the associated prefix.
#'
#' @details
#' The function iterates through the provided namespaces to find the longest matching namespace
#' for the given full IRI. If a matching namespace is found, it replaces the matching part with
#' the associated prefix and returns the shortened IRI. If no matching namespace is found, the
#' original full IRI is returned unchanged.
#'
#' @examples
#' # Example for shortening a full IRI using namespaces
#' full_iri <- "http://example.org/resource"
#' namespaces <- list(ex = "http://example.org/", foaf = "http://xmlns.com/foaf/0.1/")
#' shortened_iri <- to.short.iri(full_iri, namespaces)
#' cat(shortened_iri)
#'
#' @author <Author 1>
#' 
#' @import memoise
#' @importFrom stringr str_replace fixed
to.short.iri <- function(full.iri, namespaces=prefixes) {
  if (!is.na(full.iri)) {
    max.long.form.length <- 0
    long.form <- NULL
    prefix <- NULL
    for (ns in names(namespaces)) {
      long.form.candidate <- namespaces[[ns]]
      if (startsWith(full.iri, long.form.candidate)) {
        if (nchar(long.form.candidate) > max.long.form.length) {
          max.long.form.length <- nchar(long.form.candidate)
          long.form <- long.form.candidate
          prefix <- ns
        }
      }
    }
    if (!is.null(long.form)) {
      return(paste0(prefix, ":", str_replace(full.iri, fixed(long.form), "")))
    }
  }
  return(full.iri)
}

#' Shorten multiple full IRIs using specified namespaces.
#'
#' The `to.short.iris` function shortens a vector of full Internationalized Resource Identifiers (IRIs)
#' using the `to.short.iri` function. It applies the `to.short.iri` function to each element of the vector.
#'
#' @param iris A vector of character strings representing the full IRIs to be shortened.
#'
#' @return A vector of character strings representing the shortened IRIs.
#'
#' @details
#' The function applies the `to.short.iri` function to each element of the input vector of full IRIs.
#' It returns a vector of shortened IRIs with associated prefixes based on the specified namespaces.
#'
#' @examples
#' # Example for shortening multiple full IRIs using namespaces
#' full_iris <- c("http://example.org/resource1", "http://example.org/resource2")
#' shortened_iris <- to.short.iris(full_iris)
#' cat(shortened_iris)
#'
#' @author <Author 1>
to.short.iris <- function(iris)
{
  unlist(lapply(iris, function(x) { to.short.iri(x) })) 
}

#' Generate a static SPARQL snippet for retrieving information by Taxonomy ID.
#'
#' The `query.by.taxid` function generates a static SPARQL snippet for retrieving information based on
#' Taxonomy ID.
#'
#' @return A character string representing the static SPARQL snippet for retrieving information by Taxonomy ID.
#'
#'
#' @examples
#' # Example for generating a SPARQL query by Taxonomy ID
#' sparql_query <- query.by.taxid()
#' cat(sparql_query)
#'
#' @author <Author 1>
query.by.taxid <- function()
{
  "?organism obo:RO_0002350 [sesame:directType ?matchId].
	 ?matchId rdfs:subClassOf ?queryId.
   ?matchId rdfs:label ?matchName.
  "
}

#' Generate a static SPARQL snippet for retrieving information by taxon scientific name.
#'
#' The `query.by.name` function generates a static SPARQL snippet for retrieving information based on
#' a taxon scientific name.
#'
#' @return A character string representing the static SPARQL snippet for retrieving information by taxon scientific name.
#'
#'
#' @examples
#' # Example for generating a SPARQL query by taxon scientific name
#' sparql_query <- query.by.name()
#' cat(sparql_query)
#'
#' @author <Author 1>
query.by.name <- function()
{
  "?qId rdfs:label ?queryName.
   ?organism obo:RO_0002350 [sesame:directType ?matchId].
   ?matchId rdfs:subClassOf ?qId.
   ?matchId rdfs:label ?matchName.
  "
}

#' Generate a static SPARQL snippet for tracking the source of information about an organism
#'
#' This function returns a SPARQL query string that retrieves the source of information about the focal organism,
#' and includes a binding to check if the information has been inferred.
#'
#' @return A character string representing the static SPARQL snippet for tracking the source of information about an organism.
#'
#' @examples
#' query <- source.tracking()
#' cat(query)
#'
#' @author <Author 1>
source.tracking <- function()
{
  "GRAPH ?source {
      ?organism rdf:type obo:CARO_0001010.
  }
  BIND(IF(?graph!=<http://www.ontotext.com/implicit>, 'false', 'true') AS ?inferred)."
}

#' Fill in placeholders in a SPARQL query based on provided parameters.
#'
#' The `fill.query` function replaces placeholders in a SPARQL query with specified
#' values based on taxonomy ID or scientific name. It utilizes the `get.sparql.values`,
#' `get.named.graphs`, `query.by.name`, and `query.by.taxid` functions.
#'
#' @param query A character string representing the SPARQL query with placeholders.
#' @param taxid An optional parameter representing the Taxonomy ID to be used in the query.
#' @param sciName An optional parameter representing the scientific name to be used in the query.
#'
#' @return A character string representing the filled-in SPARQL query with specified values.
#'
#' @details
#' The function takes a SPARQL query with placeholders and optional parameters for Taxonomy ID
#' and scientific name. It uses the `get.sparql.values` function to generate VALUES clauses for
#' the provided parameters and replaces the placeholders in the query using `sprintf`. The
#' function also includes information from `get.named.graphs`, `query.by.name`, and `query.by.taxid`
#' in the resulting query.
#'
#' @examples
#' # Example for filling in placeholders in a SPARQL query
#' sparql_query_template <- "SELECT * WHERE { %s }"
#' filled_query <- fill.query(sparql_query_template, taxid = c("GBIF:2130185", "NCBI:55786"))
#' cat(filled_query)
#'
#' @author <Author 1>
#' 
#' @export fill.query
fill.query <- function(query, taxid = NULL, sciName = NULL)
{
  values = paste(
    { if(!is.null(sciName)) get.sparql.values("queryName", sciName, is.iri=FALSE) else "" },
    { if(!is.null(taxid)) get.sparql.values("queryId", taxid, is.iri=TRUE) else "" },
    sep = " "
  )
  if(!is.null(sciName)) {
    query <- sprintf(query, get.named.graphs(), values, query.by.name(), source.tracking())
  }
  if(!is.null(taxid)) {
    query <- sprintf(query, get.named.graphs(), values, query.by.taxid(), source.tracking())
  }
  
  return(query)
}

#' Format and process a data frame of results.
#'
#' The `format.result.df` function transforms IRIs in a data frame to their short, prefixed form
#' using the `to.short.iris` function. It also groups matching taxids into a list if specified,
#' and then deduplicates the data frame.
#'
#' @param df A data frame containing query results.
#' @param iri.cols A vector of character strings specifying the columns containing IRIs to be transformed.
#' @param with.matchId Logical, indicating whether to group matching taxids into a list.
#' @param with.reference Logical, indicating whether to group bibliographic references into a list.
#'
#' @return A modified data frame with transformed IRIs, grouped taxids, and deduplicated rows.
#'
#' @details
#' The function transforms specified columns containing IRIs to their short, prefixed form using
#' the `to.short.iris` function. It also provides an option to group matching taxids into a list
#' if the `with.matchId` parameter is set to TRUE. The resulting data frame is then deduplicated.
#'
#' @examples
#' # Example for formatting and processing a data frame of results
#' result_df <- data.frame(matchId = c(1, 1, 2, 3),
#'                         iri_col = c("http://example.org/1", "http://example.org/2", "http://example.org/3", "http://example.org/4"))
#' formatted_df <- format.result.df(result_df, iri.cols = "iri_col", with.matchId = TRUE, with.reference=FALSE)
#' print(formatted_df)
#'
#' @author <Author 1>
#' 
#' @importFrom tibble add_column
#' 
#' @export format.result.df
format.result.df <- function(df, iri.cols, with.matchId=TRUE, with.reference=TRUE)
{
  # Transform IRIs to their short, prefixed form
  df[iri.cols] <- lapply(df[iri.cols], to.short.iris)
  
  # Group matching taxids into a list
  if(with.matchId) {
    df_matchId <- df %>% group_by(across(c(-matchId))) %>% mutate(matchId = list(unique(matchId)))
    df$matchId <- df_matchId$matchId
  }
  
  # Group references into a list
  if(with.reference) {
    df_reference <- df %>% group_by(across(c(-reference))) %>% mutate(reference = list(unique(reference)))
    df$reference <- df_reference$reference
  }
  
  # Deduplicate
  df <- df %>% distinct()
}
