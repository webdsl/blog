module jekyll/jekyll-drafts

  define page jekylldraft(postKey : String, postUrlTitle : String) {
    var urlTitle := /\d\d\d\d-\d\d-\d\d-(.*)/.replaceAll("$1", postUrlTitle)
    var post := findPost(postKey)
    
    mimetype("text/plain")
    if (postKey == "") {
      for (p in (from Post as p where p.public = false)) {
        output(/%..[\-]?/.replaceAll("", navigate(jekylldraft(p.key, p.urlTitle))))
      } separated-by { "\n" }
    } else {
      "---\n"
      "layout: blog\n"
      "number: ~post.number\n"
      "title: \"" output(/[\r\n]+/.replaceAll( " ", / ([\\\"]) /.replaceAll( "\\\\$1", post.title)))  "\"\n"
      "created: ~post.created.format("yyyy-MM-dd HH:mm:ss")\n"
      "modified: ~post.modified.format("yyyy-MM-dd HH:mm:ss")\n"
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