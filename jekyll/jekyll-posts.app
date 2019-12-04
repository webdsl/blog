module jekyll/jekyll-posts

  define page jekyllpost(y : String, postKey : String, postUrlTitle : String) {
    var urlTitle := /\d\d\d\d-\d\d-\d\d-(.*)/.replaceAll("$1", postUrlTitle)
    var post := findPost(postKey)
    
    mimetype("text/plain")
    if (y == "") {  
      for (y2 in getPostYears()) {
        output(navigate(jekyllpost(y2, "", "")))
      } separated-by {"\n"}
    } else if (postKey == "") {
      for (p in (from Post as p where year(p.created) = ~y.parseInt() and p.public = true)) {
        output(/%..[\-]?/.replaceAll("", navigate(jekyllpost(y, p.key, "~(p.created.format("yyyy-MM-dd"))-~p.urlTitle"))))
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
      "redirect_from:\n"
      "- /post/~post.key\n"
      "- /post/~post.key/~post.urlTitle\n"
      ""
      "---\n"
      "~toProperMarkdown(post.content)\n\n"
      "~toProperMarkdown(post.extended)\n\n"
    }
  }