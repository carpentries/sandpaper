processTracker <- function(string) {
    string <- as.character(string)

    # default to whatever the user supplies
    analytics_str <- string

    if (identical(string, "carpentries")) {
        analytics_str <- '
        <!-- Matomo -->
        <script>
          var _paq = window._paq = window._paq || [];
          /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
          _paq.push(["setDocumentTitle", document.domain + "/" + document.title]);
          _paq.push(["setDomains", ["*.lessons.carpentries.org","*.datacarpentry.github.io","*.datacarpentry.org","*.librarycarpentry.github.io","*.librarycarpentry.org","*.swcarpentry.github.io", "*.carpentries.github.io"]]);
          _paq.push(["setDoNotTrack", true]);
          _paq.push(["disableCookies"]);
          _paq.push(["trackPageView"]);
          _paq.push(["enableLinkTracking"]);
          (function() {
              var u="https://matomo.carpentries.org/";
              _paq.push(["setTrackerUrl", u+"matomo.php"]);
              _paq.push(["setSiteId", "1"]);
              var d=document, g=d.createElement("script"), s=d.getElementsByTagName("script")[0];
              g.async=true; g.src="https://matomo.carpentries.org/matomo.js"; s.parentNode.insertBefore(g,s);
          })();
        </script>
        <!-- End Matomo Code -->
        '
    } else if (identical(string, "")) {
        analytics_str <- ""
    }

    return(analytics_str)
}
