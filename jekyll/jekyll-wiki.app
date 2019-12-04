module jekyll/jekyll-wiki

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
			"layout: wiki\n"
			"title: ~wiki.title\n"
			"created: ~wiki.created.format("yyyy-MM-dd HH:mm:ss")\n"
			"modified: ~wiki.modified.format("yyyy-MM-dd HH:mm:ss")\n"
			"public: ~wiki.public\n"
			"authors:\n"
				for (u : User in wiki.authors) {
				  "- ~u.fullname\n"
				}
			"---\n"
			
      "~toProperMarkdown(wiki.content)\n"
    }
  }
