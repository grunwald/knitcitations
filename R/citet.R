#' Add a textual citation 
#'
#' Parameters listed here are the same for parenthetical 
#'  citation, \code{\link{citep}}.  
#' @param x a doi or list of dois, or a bibentry (or list of bibentries)
#' @param cito Semantic reason for the citation. Only active if linked=TRUE
#' @param tooltip Show a citation information on mouseover. Requires the
#'  tooltip javascript from http://twitter.github.com/bootstrap Pass 
#'  logical TRUE/FALSE or set default behavior with \code{\link{cite_options}}
#' @param linked link the inline citation text to the resource by doi 
#'  (if available) or url? Pass logical TRUE/FALSE or set default behavior 
#'  with \code{\link{cite_options}}
#' @param numerical use citation instead of author-year format? (Not 
#'  functional yet!) Pass logical TRUE/FALSE or set default behavior 
#'  with \code{\link{cite_options}}
#' @param format_inline_fn function to format a single inline citation
#' @param inline_format a function for formating the inline citation, defaults to authoryear_t (designed for internal use only)
#' @param page optional page range added after citation
#' @return a text inline citation
#' @details Stores the full citation in a "works_cited" list,
#' which can be printed with \code{\link{bibliography}}.
#' A variety of reasons for the citation can be provided following the
#' CiTO ontology: 
#' c("cites","citesAsAuthority", "citesAsMetadataDocument",
#'   "citesAsSourceDocument","citesForInformation",
#'   "isCitedBy","obtainsBackgroundFrom", "sharesAuthorsWith", "usesDataFrom",
#'   "usesMethodIn", "confirms", "credits", "extends", "obtainsSupportFrom",
#'   "supports", "updates", "corrects", "critiques", "disagreesWith",
#'   "qualifies", "refutes", "discusses", "reviews")
#' @export
#' @import knitr
#' @examples
#' library(knitcitations)
#'  citet("10.3998/3336451.0009.101")
#'  ## Read in the bibtex information for some packages:
#'  knitr <- citation("knitr") 
#'  citet(knitr)
#'  # generate the full bibliography:
#'  bibliography()
#' ## Assign a citation key to a doi and then use it later:
#' citet(c(Halpern2006="10.1111/j.1461-0248.2005.00827.x"))
#' citet("Halpern2006")
#'
citet <- function(x, cito = NULL, 
                  tooltip = get("tooltip", envir=knitcitations_options), 
                  linked = get("linked", envir=knitcitations_options), 
                  numerical = get("numerical", envir=knitcitations_options), 
                  format_inline_fn = format_authoryear_t,  
                  inline_format = authoryear_t, page = NULL){
  out <- cite(x, format_inline_fn = format_inline_fn)
  if(length(out) > 1) {
    output <- paste(sapply(out, citet, cito, tooltip, linked, format_inline_fn, inline_format), collapse="; ", sep="")
  } else {
    if(linked){
      citoproperty <- ""
      if(!is.null(cito))
        citoproperty <- paste(' rel="http://purl.org/spar/cito/', cito, '" ', sep='')
      if(!is.null(out$doi)) # Link by DOI if a DOI is available
        link <- paste('href="http://dx.doi.org/', out[[1]]$doi, '"', sep='')
      else ## Attempt to link by bibtex URL field.  
        link <- paste('href="', out$url, '"', sep='')
      output <- paste('<a ', link, citoproperty, '>', I(inline_format(out[[1]])), '</a>', sep='')
      if(tooltip){
        bibinfo <- format(out, "html")
        # Clean up silly default html formatting -- nope, just have to strip the html.  
        bibinfo <- gsub('<p>', '', bibinfo) 
#        bibinfo <- gsub('B>', 'strong>', bibinfo) 
#        bibinfo <- gsub('EM>', 'em>', bibinfo) 
         bibinfo <- gsub("&ldquo;", "'", bibinfo) # okay if data-html is on 
         bibinfo <- gsub("&rdquo;", "'", bibinfo) # okay if data-html is on 
         bibinfo <- gsub("&ndash;", "-", bibinfo)  # okay if data-html is on 
         bibinfo <- gsub('<a .*</a>', '', bibinfo) 
         bibinfo <- gsub('<B>', '', bibinfo) 
         bibinfo <- gsub('<EM>', '', bibinfo) 
         bibinfo <- gsub('</B>', '', bibinfo) 
         bibinfo <- gsub('</EM>', '', bibinfo) 
         bibinfo <- gsub('\\n', ' ', bibinfo) 
         bibinfo <- gsub(', \\.', '.', bibinfo) 
     output <- paste('<span class="showtooltip" title="', bibinfo, '">', output, '</span>', sep='')
      }
    } else { # not linked 
      output <- inline_format(out)
    }
  } 

  if(!is.null(page)){
    pgs <- ifelse(grepl("-", page), "pp.", "p.")
    page <- paste(",", pgs, page)
    pageout <- strsplit(output, ")</a>;|)</a>")
    pageout <- sapply(pageout, function(x) {
      paste0(x, page, ")</a>")
    })
    output <- paste(pageout, collapse= ";")
  }

  output
}
