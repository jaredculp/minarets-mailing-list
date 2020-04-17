#!/usr/bin/env awk -f

function header() {
  return sprintf("<!DOCTYPE html>\n<body>\n\t<h1>minarets.net Mailing Archive (page %s)</h1>", curr_page)
}

function permalink() {
  return sprintf("<a href=\"#%s\">Permalink</a>", i)
}

function nav() {
  if (curr_page == 1)
    return next_page()
  else
    return sprintf("%s %s", prev_page(), next_page())
}

function next_page() {
  # files are 0-indexed, so the "next" page is the "current" which is 1-indexed
  return sprintf("<a href=\"page-%02d.html\">Next</a>", curr_page)
}

function prev_page() {
  # files are 0-indexed, so the "previous" page is "current" - 2 which is 1-indexed
  return sprintf("<a href=\"page-%02d.html\">Previous</a>", curr_page - 2)
}

BEGIN {
  curr_page = 1

  footer = "</body>"
  anchor = "<a href=\"#\">Top</a>"

  from = ""
  subj = ""
  body = ""
  page_size = 100

  print header()
  print nav()
  print "\t<p>"
  print "The minarets listserv started in late 1993 and ran until May 1995, and it served as the first organized, large-scale online gathering of DMB fans. The listserv gave subscribers discussions of DMB, songs, shows, tapes (literally), tour dates, etc." \
        "In 2006, Henry Hart, in conjunction with CIO David Todd of the University of Vermont, finally procured the archive of the listserv in the form of a massive text file." \
        "The purpose of this site is to format the archive for ease of reading, eliminating irrelevant information from the headers and dividing the posts up into weekly segments. This will take some time to complete, but just keep checking back for more reading!" \
        "As you read through these posts, keep in mind that in the early days of the band, not as much was known about them, so some of the information contained here may be inaccurate. Also remember that some songs were known to fans by different names than they are formally called today."
  print "\t</p>"
}

# Each message begins with "From: <email address> <date string>".
# After the first match, all subsequent matches mean new messages.
# This is checked by seeing if the "body" of the message is set.
# Pagination is used to provide links for "previous" and "next" pages.
/^From .[[:print:]]+.*[[:digit:]]{4}$/ {
  gsub("From ", "")
  if (body != "") {
    i++
    printf("\t<div id=\"%s\" class=\"message\">\n\t\t<h3>%s</h3>\n\t\t<h4><i>%s</i></h4>\n\t\t<p>\n\t\t\t<pre>%s\t\t\t</pre>\n\t\t</p>\n\t%s %s\n\t</div>\n<hr/>\n", i, subj, from, body, anchor, permalink())

    if (i % page_size == 0) {
      print nav()
      print footer

      curr_page++
      print header()
      print nav()
    }
  }

  from = $0
  body = ""
  subj = ""

  next
}
# Parse the subject line. Easy.
/^Subject:/ {
  gsub("Subject: ", "")
  subj = $0
  next
}
# Strip out all other headers like 'Content-Type:' and 'In-Reply-To:'.
/[A-Za-z'-]+:/ {
  next
}
# Skip all lines that start with non-printable characters.
# These are usually from multiline headers.
/^[[:blank:]]+/ {
  next
}
# Everything else must be the actual message body.
# Strip out any open and close tags at the expense of maintaining the original message.
# Otherwise, subsequent messages are malformed in the event that the input was bad.
// {
  gsub("<", "")
  gsub(">", "")
  body = sprintf("%s%s\n", body, $0)
}

END {
  print footer
  print "FIN. The source code to build these pages is available on <a href=\"http://github.com/jaredculp/minarets-mailing-list\">GitHub</a>. Data provided by <a href=\"http://dmbalmanac.com\">DMBAlmanac</a>."
}
