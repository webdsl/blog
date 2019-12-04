module jekyll/jekyll-utils


  
  function getPostYears() : Set<String> {
    var seenYears := Set<String>();
    
    for (p in (from Post as p where p.public = true)) {
      if (!(p.created.format("yyyy") in seenYears)) {
        seenYears.add(p.created.format("yyyy"));
      }
    }
    
    return seenYears;
  }
  
  function toProperMarkdown(s : String) : String {   
    var replacedWikiLinks := /\[\[wiki\(([^\)]*)\)\|([^\]]*)\]\] /.replaceAll("[$2](/wiki/$1/)", s);
    var replacedPostLinks := replacedWikiLinks;
    
    var list := replacedWikiLinks.split("[[post(");
    
    if (list.length > 0) {
      for (x in list) {
        if (list.indexOf(x) > 0) {
          
          // Extract key of post from markdown link
          var postKey := x.split(")").get(0);
          var p := findPost(postKey);
          
          // Construct the correct url
          var postJekyllUrl := url("/blog/" + p.created.format("yyyy/MM/dd") + "/" + p.urlTitle + "/");
          postJekyllUrl := ( /%..[\-]?/.replaceAll("", postJekyllUrl) );
          
          // Replace the webdsl post link with a proper markdown link to a post
          replacedPostLinks := /\[\[post\(\d+\)\|([^\]]*)\]\]/.replaceFirst("[$1](~postJekyllUrl)", replacedPostLinks);
        }
      } 
    }
    
    var replacedVerbatimHtml := /<\/?verbatim>/.replaceAll("```", replacedPostLinks);
    
    return replacedVerbatimHtml;
  }