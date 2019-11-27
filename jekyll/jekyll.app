module jekyll/jekyll

section main wiki page

  define page jekyllwiki(wikigroupkey : String, wikikey : String) {
    mimetype("text/plain")
    
    var wikigroup : WikiGroup := findWikiGroup(wikigroupkey)
    var wiki : Wiki := findWiki(wikikey)
    
    if (wikigroup == null) {
      for (wg2 : WikiGroup) {
        output(navigate(jekyllwiki(wg2.key, "")))
      } separated-by { "\n" }
      
    } else if (wiki == null) {      
      for (w2 in (from Wiki as w2 where w2.group = ~wikigroup)) {
        output(navigate(jekyllwiki(wikigroupkey, w2.key)))  
      } separated-by { "\n" }
    } else {
      "---\n"
			"layout: plain-title\n"
			"title: ~wiki.title\n"
			"public: ~wiki.public\n"
			"authors:\n"
				for (u : User in wiki.authors) {
				  "- ~u.fullname\n"
				}
			"---\n"
			
      "~toProperMarkdown(wiki.content)\n"
    }
  }
  
  define page jekyllblog(y : String, postKey : String, postUrlTitle : String) {
    var urlTitle := /\d\d\d\d-\d\d-\d\d-(.*)/.replaceAll("$1", postUrlTitle)
    var post := findPost(postKey)
    
    mimetype("text/plain")
    if (y == "") {  
	    for (y2 in getPostYears()) {
        output(navigate(jekyllblog(y2, "", "")))
	    } separated-by {"\n"}
    } else if (postKey == "") {
      for (p in (from Post as p where year(p.created) = ~y.parseInt())) {
        output(/%..[\-]?/.replaceAll("", navigate(jekyllblog(y, p.key, "~(p.created.format("yyyy-MM-dd"))-~p.urlTitle"))))
      } separated-by { "\n" }
    } else {
      "---\n"
			"layout: blog\n"
			"number: ~post.number\n"
			"title: \"" output(/[\r\n]+/.replaceAll( " ", / ([\\\"]) /.replaceAll( "\\\\$1", post.title)))  "\"\n"
			"categories: [blog]\n"
			"tags: []\n"
			"public: ~post.public\n"
			"deleted: ~post.deleted\n"
			"description: \"" output(/[\r\n]+/.replaceAll( " ", / ([\\\"]) /.replaceAll( "\\\\$1", post.description)))  "\"\n"
			"authors:\n"
			  for (u : User in post.authors) {
			    "- ~u.fullname\n"
			  }
			"---\n"
			"~toProperMarkdown(post.content)\n\n"
			"~toProperMarkdown(post.extended)\n\n"
    }
  }
  
  function getPostYears() : Set<String> {
    var seenYears := Set<String>();
    
    for (p in (from Post as p)) {
      if (!(p.created.format("yyyy") in seenYears)) {
        seenYears.add(p.created.format("yyyy"));
      }
    }
    
    return seenYears;
  }
  
  function toProperMarkdown(s : String) : String {   
    var replacedWikiLinks := /\[\[wiki\(([^\)]*)\)\|([^\]]*)\]\] /.replaceAll("[$2](/$1/)", s);
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
    
    return replacedPostLinks;
  }
